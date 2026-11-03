package starling.core
{
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.display.Stage3D;
   import flash.display3D.Context3D;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.events.TouchEvent;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.system.Capabilities;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.ui.Mouse;
   import flash.ui.Multitouch;
   import flash.utils.getTimer;
   import flash.utils.setTimeout;
   import starling.animation.Juggler;
   import starling.display.DisplayObject;
   import starling.display.Stage;
   import starling.events.EventDispatcher;
   import starling.events.KeyboardEvent;
   import starling.events.ResizeEvent;
   import starling.events.TouchProcessor;
   import starling.rendering.Painter;
   import starling.textures.TextureSmoothing;
   import starling.utils.Color;
   import starling.utils.MatrixUtil;
   import starling.utils.Pool;
   import starling.utils.RectangleUtil;
   import starling.utils.SystemUtil;
   
   public class Starling extends EventDispatcher
   {
      
      public static const VERSION:String = "2.8";
      
      private static var sCurrent:Starling;
      
      private static var sAll:Vector.<Starling> = new Vector.<Starling>(0);
      
      private var _stage:starling.display.Stage;
      
      private var _rootClass:Class;
      
      private var _root:DisplayObject;
      
      private var _juggler:Juggler;
      
      private var _painter:Painter;
      
      private var _touchProcessor:TouchProcessor;
      
      private var _defaultTextureSmoothing:String;
      
      private var _antiAliasing:int;
      
      private var _frameTimestamp:Number;
      
      private var _frameID:uint;
      
      private var _leftMouseDown:Boolean;
      
      private var _statsDisplay:StatsDisplay;
      
      private var _statsDisplayAlign:Object;
      
      private var _started:Boolean;
      
      private var _rendering:Boolean;
      
      private var _supportHighResolutions:Boolean;
      
      private var _supportBrowserZoom:Boolean;
      
      private var _skipUnchangedFrames:Boolean;
      
      private var _showStats:Boolean;
      
      private var _supportsCursor:Boolean;
      
      private var _multitouchEnabled:Boolean;
      
      private var _viewPort:Rectangle;
      
      private var _previousViewPort:Rectangle;
      
      private var _clippedViewPort:Rectangle;
      
      private var _nativeStage:flash.display.Stage;
      
      private var _nativeStageEmpty:Boolean;
      
      private var _nativeOverlay:Sprite;
      
      public function Starling(rootClass:Class, stage:flash.display.Stage, viewPort:Rectangle = null, stage3D:Stage3D = null, renderMode:String = "auto", profile:Object = "auto")
      {
         var _loc8_:String = null;
         super();
         if(stage == null)
         {
            throw new ArgumentError("Stage must not be null");
         }
         if(viewPort == null)
         {
            viewPort = new Rectangle(0,0,stage.stageWidth,stage.stageHeight);
         }
         if(stage3D == null)
         {
            stage3D = stage.stage3Ds[0];
         }
         SystemUtil.initialize();
         sAll.push(this);
         makeCurrent();
         _rootClass = rootClass;
         _viewPort = viewPort;
         _previousViewPort = new Rectangle();
         _stage = new starling.display.Stage(viewPort.width,viewPort.height,stage.color);
         _nativeOverlay = new Sprite();
         _nativeStage = stage;
         _nativeStage.addChild(_nativeOverlay);
         _touchProcessor = new TouchProcessor(_stage);
         _touchProcessor.discardSystemGestures = !SystemUtil.isDesktop;
         _juggler = new Juggler();
         _antiAliasing = 0;
         _defaultTextureSmoothing = "bilinear";
         _supportHighResolutions = false;
         _painter = new Painter(stage3D);
         _frameTimestamp = getTimer() / 1000;
         _frameID = 1;
         _supportsCursor = Mouse.supportsCursor || Capabilities.os.indexOf("Windows") == 0;
         _statsDisplayAlign = {};
         setMultitouchEnabled(Multitouch.inputMode == "touchPoint",true);
         nativeOverlayBlocksTouches = true;
         stage.scaleMode = "noScale";
         stage.align = "TL";
         stage.addEventListener("enterFrame",onEnterFrame,false,0,true);
         stage.addEventListener("keyDown",onKey,false,0,true);
         stage.addEventListener("keyUp",onKey,false,0,true);
         stage.addEventListener("resize",onResize,false,0,true);
         stage.addEventListener("mouseLeave",onMouseLeave,false,0,true);
         stage.addEventListener("activate",onActivate,false,0,true);
         stage3D.addEventListener("context3DCreate",onContextCreated,false,10,true);
         stage3D.addEventListener("error",onStage3DError,false,10,true);
         var _loc7_:int = parseInt(SystemUtil.version.split(",").shift());
         if(_loc7_ < 19)
         {
            _loc8_ = SystemUtil.isAIR ? "Adobe AIR" : "Flash Player";
            stopWithFatalError("Your " + _loc8_ + " installation is outdated. " + "This software requires at least version 19.");
         }
         else if(_painter.shareContext)
         {
            setTimeout(initialize,1);
         }
         else
         {
            _painter.requestContext3D(renderMode,profile);
         }
      }
      
      public static function get current() : Starling
      {
         return sCurrent;
      }
      
      public static function get all() : Vector.<Starling>
      {
         return sAll;
      }
      
      public static function get context() : Context3D
      {
         return sCurrent ? sCurrent.context : null;
      }
      
      public static function get juggler() : Juggler
      {
         return sCurrent ? sCurrent._juggler : null;
      }
      
      public static function get painter() : Painter
      {
         return sCurrent ? sCurrent._painter : null;
      }
      
      public static function get contentScaleFactor() : Number
      {
         return sCurrent ? sCurrent.contentScaleFactor : 1;
      }
      
      public static function get multitouchEnabled() : Boolean
      {
         var _loc3_:Boolean = Multitouch.inputMode == "touchPoint";
         var _loc2_:Boolean = false;
         for each(var _loc1_:Starling in sAll)
         {
            if(_loc1_._multitouchEnabled != _loc3_)
            {
               _loc2_ = true;
            }
         }
         if(_loc2_)
         {
         }
         return _loc3_;
      }
      
      public static function set multitouchEnabled(value:Boolean) : void
      {
         var _loc4_:Boolean = Multitouch.inputMode == "touchPoint";
         Multitouch.inputMode = value ? "touchPoint" : "none";
         var _loc3_:Boolean = Multitouch.inputMode == "touchPoint";
         if(_loc4_ != _loc3_)
         {
            for each(var _loc2_:Starling in sAll)
            {
               _loc2_.setMultitouchEnabled(_loc3_);
            }
         }
      }
      
      public static function get frameID() : uint
      {
         return sCurrent ? sCurrent._frameID : 0;
      }
      
      public static function get currentDefaultTextureSmoothing() : String
      {
         return sCurrent ? sCurrent._defaultTextureSmoothing : "bilinear";
      }
      
      public function dispose() : void
      {
         stop(true);
         _nativeStage.removeEventListener("enterFrame",onEnterFrame,false);
         _nativeStage.removeEventListener("keyDown",onKey,false);
         _nativeStage.removeEventListener("keyUp",onKey,false);
         _nativeStage.removeEventListener("resize",onResize,false);
         _nativeStage.removeEventListener("mouseLeave",onMouseLeave,false);
         _nativeStage.removeEventListener("browserZoomChange",onBrowserZoomChange,false);
         _nativeStage.removeChild(_nativeOverlay);
         stage3D.removeEventListener("context3DCreate",onContextCreated,false);
         stage3D.removeEventListener("context3DCreate",onContextRestored,false);
         stage3D.removeEventListener("error",onStage3DError,false);
         for each(var _loc2_:String in getTouchEventTypes(_multitouchEnabled))
         {
            _nativeStage.removeEventListener(_loc2_,onTouch,false);
         }
         _touchProcessor.dispose();
         _stage.dispose();
         _painter.dispose();
         var _loc1_:int = sAll.indexOf(this);
         if(_loc1_ != -1)
         {
            sAll.removeAt(_loc1_);
         }
         if(sCurrent == this)
         {
            sCurrent = null;
         }
      }
      
      private function initialize() : void
      {
         makeCurrent();
         updateViewPort(true);
         dispatchEventWith("context3DCreate",false,context);
         initializeRoot();
         _frameTimestamp = getTimer() / 1000;
      }
      
      private function initializeRoot() : void
      {
         if(_root == null && _rootClass != null)
         {
            _root = new _rootClass() as DisplayObject;
            if(_root == null)
            {
               throw new Error("Invalid root class: " + _rootClass);
            }
            _stage.addChildAt(_root,0);
            dispatchEventWith("rootCreated",false,_root);
         }
      }
      
      public function nextFrame() : void
      {
         var _loc1_:Number = getTimer() / 1000;
         var _loc2_:Number = _loc1_ - _frameTimestamp;
         _frameTimestamp = _loc1_;
         if(_loc2_ > 1)
         {
            _loc2_ = 1;
         }
         if(_loc2_ < 0)
         {
            _loc2_ = 1 / _nativeStage.frameRate;
         }
         advanceTime(_loc2_);
         render();
      }
      
      public function advanceTime(passedTime:Number) : void
      {
         if(!contextValid)
         {
            return;
         }
         makeCurrent();
         _touchProcessor.advanceTime(passedTime);
         _stage.advanceTime(passedTime);
         _juggler.advanceTime(passedTime);
      }
      
      public function render() : void
      {
         var _loc5_:Boolean = false;
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:uint = 0;
         if(!contextValid)
         {
            return;
         }
         makeCurrent();
         updateViewPort();
         var _loc4_:Boolean = _stage.requiresRedraw || mustAlwaysRender;
         if(_loc4_)
         {
            _painter.nextFrame();
            dispatchEventWith("render");
            _loc5_ = _painter.shareContext;
            _loc1_ = _viewPort.width / _stage.stageWidth;
            _loc2_ = _viewPort.height / _stage.stageHeight;
            _loc3_ = _stage.color;
            _painter.pixelSize = 1 / contentScaleFactor;
            _painter.state.setProjectionMatrix(_viewPort.x < 0 ? -_viewPort.x / _loc1_ : 0,_viewPort.y < 0 ? -_viewPort.y / _loc2_ : 0,_clippedViewPort.width / _loc1_,_clippedViewPort.height / _loc2_,_stage.stageWidth,_stage.stageHeight,_stage.cameraPosition);
            if(!_loc5_)
            {
               _painter.clear(_loc3_,Color.getAlpha(_loc3_));
            }
            _stage.render(_painter);
            _painter.finishFrame();
            _painter.frameID = ++_frameID;
            if(!_loc5_)
            {
               _painter.present();
            }
            dispatchEventWith("renderComplete");
         }
         else
         {
            dispatchEventWith("skipFrame");
         }
         if(_statsDisplay)
         {
            _statsDisplay.drawCount = _painter.drawCount;
         }
      }
      
      private function updateViewPort(forceUpdate:Boolean = false) : void
      {
         var _loc2_:Number = NaN;
         if(forceUpdate || !RectangleUtil.compare(_viewPort,_previousViewPort))
         {
            _previousViewPort.setTo(_viewPort.x,_viewPort.y,_viewPort.width,_viewPort.height);
            updateClippedViewPort();
            updateStatsDisplayPosition();
            _loc2_ = _supportHighResolutions ? _nativeStage.contentsScaleFactor : 1;
            if(_supportBrowserZoom)
            {
               _loc2_ *= _nativeStage.browserZoomFactor;
            }
            _painter.configureBackBuffer(_clippedViewPort,_loc2_,_antiAliasing,true,_supportBrowserZoom);
            setRequiresRedraw();
         }
      }
      
      private function updateClippedViewPort() : void
      {
         var _loc1_:Rectangle = Pool.getRectangle(0,0,_nativeStage.stageWidth,_nativeStage.stageHeight);
         _clippedViewPort = RectangleUtil.intersect(_viewPort,_loc1_,_clippedViewPort);
         if(_clippedViewPort.width < 32)
         {
            _clippedViewPort.width = 32;
         }
         if(_clippedViewPort.height < 32)
         {
            _clippedViewPort.height = 32;
         }
         Pool.putRectangle(_loc1_);
      }
      
      private function updateNativeOverlay() : void
      {
         _nativeOverlay.x = _viewPort.x;
         _nativeOverlay.y = _viewPort.y;
         _nativeOverlay.scaleX = _viewPort.width / _stage.stageWidth;
         _nativeOverlay.scaleY = _viewPort.height / _stage.stageHeight;
      }
      
      public function stopWithFatalError(message:String) : void
      {
         var _loc2_:Shape = new Shape();
         _loc2_.graphics.beginFill(0,0.8);
         _loc2_.graphics.drawRect(0,0,_stage.stageWidth,_stage.stageHeight);
         _loc2_.graphics.endFill();
         var _loc3_:TextField = new TextField();
         var _loc4_:TextFormat = new TextFormat("Verdana",14,16777215);
         _loc4_.align = "center";
         _loc3_.defaultTextFormat = _loc4_;
         _loc3_.wordWrap = true;
         _loc3_.width = _stage.stageWidth * 0.75;
         _loc3_.autoSize = "center";
         _loc3_.text = message;
         _loc3_.x = (_stage.stageWidth - _loc3_.width) / 2;
         _loc3_.y = (_stage.stageHeight - _loc3_.height) / 2;
         _loc3_.background = true;
         _loc3_.backgroundColor = 5570560;
         updateNativeOverlay();
         nativeOverlay.addChild(_loc2_);
         nativeOverlay.addChild(_loc3_);
         stop(true);
         dispatchEventWith("fatalError",false,message);
      }
      
      public function makeCurrent() : void
      {
         sCurrent = this;
      }
      
      public function start() : void
      {
         _started = _rendering = true;
         _frameTimestamp = getTimer() / 1000;
      }
      
      public function stop(suspendRendering:Boolean = false) : void
      {
         _started = false;
         _rendering = !suspendRendering;
      }
      
      public function setRequiresRedraw() : void
      {
         _stage.setRequiresRedraw();
      }
      
      private function onStage3DError(event:ErrorEvent) : void
      {
         var _loc2_:String = null;
         if(event.errorID == 3702)
         {
            _loc2_ = Capabilities.playerType == "Desktop" ? "renderMode" : "wmode";
            stopWithFatalError("Context3D not available! Possible reasons: wrong " + _loc2_ + " or missing device support.");
         }
         else
         {
            stopWithFatalError("Stage3D error: " + event.text);
         }
      }
      
      private function onContextCreated(event:Event) : void
      {
         stage3D.removeEventListener("context3DCreate",onContextCreated);
         stage3D.addEventListener("context3DCreate",onContextRestored,false,10,true);
         initialize();
      }
      
      private function onContextRestored(event:Event) : void
      {
         updateViewPort(true);
         _painter.setupContextDefaults();
         dispatchEventWith("context3DCreate",false,context);
      }
      
      private function onEnterFrame(event:Event) : void
      {
         if(!shareContext)
         {
            if(_started)
            {
               nextFrame();
            }
            else if(_rendering)
            {
               render();
            }
         }
         updateNativeOverlay();
      }
      
      private function onActivate(event:Event) : void
      {
         setTimeout(setRequiresRedraw,100);
      }
      
      private function onKey(event:flash.events.KeyboardEvent) : void
      {
         if(!_started)
         {
            return;
         }
         var _loc2_:starling.events.KeyboardEvent = new starling.events.KeyboardEvent(event.type,event.charCode,event.keyCode,event.keyLocation,event.ctrlKey,event.altKey,event.shiftKey);
         makeCurrent();
         _stage.dispatchEvent(_loc2_);
         if(_loc2_.isDefaultPrevented())
         {
            event.preventDefault();
         }
      }
      
      private function onResize(event:Event) : void
      {
         var dispatchResizeEvent:* = function():void
         {
            makeCurrent();
            removeEventListener("context3DCreate",dispatchResizeEvent);
            _stage.dispatchEvent(new ResizeEvent("resize",stageWidth,stageHeight));
         };
         var stageWidth:int = int(event.target.stageWidth);
         var stageHeight:int = int(event.target.stageHeight);
         if(contextValid)
         {
            dispatchResizeEvent();
         }
         else
         {
            addEventListener("context3DCreate",dispatchResizeEvent);
         }
      }
      
      private function onBrowserZoomChange(event:Event) : void
      {
         _painter.refreshBackBufferSize(_nativeStage.contentsScaleFactor * _nativeStage.browserZoomFactor);
      }
      
      private function onMouseLeave(event:Event) : void
      {
         _touchProcessor.enqueueMouseLeftStage();
      }
      
      private function onTouch(event:Event) : void
      {
         var _loc5_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc6_:int = 0;
         var _loc2_:String = null;
         var _loc4_:MouseEvent = null;
         var _loc8_:TouchEvent = null;
         if(!_started)
         {
            return;
         }
         var _loc9_:Number = 1;
         var _loc7_:Number = 1;
         var _loc10_:Number = 1;
         if(event is MouseEvent)
         {
            _loc4_ = event as MouseEvent;
            _loc5_ = _loc4_.stageX;
            _loc3_ = _loc4_.stageY;
            _loc6_ = 0;
            if(event.type == "mouseDown")
            {
               _leftMouseDown = true;
            }
            else if(event.type == "mouseUp")
            {
               _leftMouseDown = false;
            }
         }
         else
         {
            _loc8_ = event as TouchEvent;
            if(_supportsCursor && _loc8_.isPrimaryTouchPoint)
            {
               return;
            }
            _loc5_ = _loc8_.stageX;
            _loc3_ = _loc8_.stageY;
            _loc6_ = _loc8_.touchPointID;
            _loc9_ = _loc8_.pressure;
            _loc7_ = _loc8_.sizeX;
            _loc10_ = _loc8_.sizeY;
         }
         switch(event.type)
         {
            case "touchBegin":
               _loc2_ = "began";
               break;
            case "touchMove":
               _loc2_ = "moved";
               break;
            case "touchEnd":
               _loc2_ = "ended";
               break;
            case "mouseDown":
               _loc2_ = "began";
               break;
            case "mouseUp":
               _loc2_ = "ended";
               break;
            case "mouseMove":
               _loc2_ = _leftMouseDown ? "moved" : "hover";
         }
         _loc5_ = _stage.stageWidth * (_loc5_ - _viewPort.x) / _viewPort.width;
         _loc3_ = _stage.stageHeight * (_loc3_ - _viewPort.y) / _viewPort.height;
         _touchProcessor.enqueue(_loc6_,_loc2_,_loc5_,_loc3_,_loc9_,_loc7_,_loc10_);
         if(event.type == "mouseUp" && _supportsCursor)
         {
            _touchProcessor.enqueue(_loc6_,"hover",_loc5_,_loc3_);
         }
      }
      
      private function hitTestNativeOverlay(localX:Number, localY:Number) : Boolean
      {
         var _loc5_:Point = null;
         var _loc4_:Matrix = null;
         var _loc3_:Boolean = false;
         if(_nativeOverlay.numChildren)
         {
            _loc5_ = Pool.getPoint();
            _loc4_ = Pool.getMatrix(_nativeOverlay.scaleX,0,0,_nativeOverlay.scaleY,_nativeOverlay.x,_nativeOverlay.y);
            MatrixUtil.transformCoords(_loc4_,localX,localY,_loc5_);
            _loc3_ = _nativeOverlay.hitTestPoint(_loc5_.x,_loc5_.y,true);
            Pool.putPoint(_loc5_);
            Pool.putMatrix(_loc4_);
            return _loc3_;
         }
         return false;
      }
      
      private function setMultitouchEnabled(value:Boolean, forceUpdate:Boolean = false) : void
      {
         var _loc6_:Array = null;
         var _loc4_:Array = null;
         if(forceUpdate || value != _multitouchEnabled)
         {
            _loc6_ = getTouchEventTypes(_multitouchEnabled);
            _loc4_ = getTouchEventTypes(value);
            for each(var _loc5_:String in _loc6_)
            {
               _nativeStage.removeEventListener(_loc5_,onTouch);
            }
            for each(var _loc3_:String in _loc4_)
            {
               _nativeStage.addEventListener(_loc3_,onTouch,false,0,true);
            }
            _touchProcessor.cancelTouches();
            _multitouchEnabled = value;
         }
      }
      
      private function getTouchEventTypes(multitouchEnabled:Boolean) : Array
      {
         var _loc2_:Array = [];
         if(multitouchEnabled)
         {
            _loc2_.push("touchBegin","touchMove","touchEnd");
         }
         if(!multitouchEnabled || _supportsCursor)
         {
            _loc2_.push("mouseDown","mouseMove","mouseUp");
         }
         return _loc2_;
      }
      
      private function get mustAlwaysRender() : Boolean
      {
         var _loc2_:Boolean = false;
         var _loc1_:Boolean = false;
         if(!_skipUnchangedFrames || _painter.shareContext)
         {
            return true;
         }
         if(SystemUtil.isDesktop && profile != "baselineConstrained")
         {
            return false;
         }
         _loc2_ = Boolean(isNativeDisplayObjectEmpty(_nativeStage));
         _loc1_ = !_loc2_ || !_nativeStageEmpty;
         _nativeStageEmpty = _loc2_;
         return _loc1_;
      }
      
      public function get isStarted() : Boolean
      {
         return _started;
      }
      
      public function get juggler() : Juggler
      {
         return _juggler;
      }
      
      public function get painter() : Painter
      {
         return _painter;
      }
      
      public function get context() : Context3D
      {
         return _painter.context;
      }
      
      public function get simulateMultitouch() : Boolean
      {
         return _touchProcessor.simulateMultitouch;
      }
      
      public function set simulateMultitouch(value:Boolean) : void
      {
         _touchProcessor.simulateMultitouch = value;
      }
      
      public function get enableErrorChecking() : Boolean
      {
         return _painter.enableErrorChecking;
      }
      
      public function set enableErrorChecking(value:Boolean) : void
      {
         _painter.enableErrorChecking = value;
      }
      
      public function get antiAliasing() : int
      {
         return _antiAliasing;
      }
      
      public function set antiAliasing(value:int) : void
      {
         if(_antiAliasing != value)
         {
            _antiAliasing = value;
            if(contextValid)
            {
               updateViewPort(true);
            }
         }
      }
      
      public function get defaultTextureSmoothing() : String
      {
         return _defaultTextureSmoothing;
      }
      
      public function set defaultTextureSmoothing(value:String) : void
      {
         if(!TextureSmoothing.isValid(value))
         {
            throw new ArgumentError("Invalid texture smoothing: " + value);
         }
         _defaultTextureSmoothing = value;
      }
      
      public function get viewPort() : Rectangle
      {
         return _viewPort;
      }
      
      public function set viewPort(value:Rectangle) : void
      {
         _viewPort.copyFrom(value);
      }
      
      public function get contentScaleFactor() : Number
      {
         return _viewPort.width * _painter.backBufferScaleFactor / _stage.stageWidth;
      }
      
      public function get nativeOverlay() : Sprite
      {
         return _nativeOverlay;
      }
      
      public function get nativeOverlayBlocksTouches() : Boolean
      {
         return _touchProcessor.occlusionTest != null;
      }
      
      public function set nativeOverlayBlocksTouches(value:Boolean) : void
      {
         if(value != this.nativeOverlayBlocksTouches)
         {
            _touchProcessor.occlusionTest = value ? hitTestNativeOverlay : null;
         }
      }
      
      public function get showStats() : Boolean
      {
         return _showStats;
      }
      
      public function set showStats(value:Boolean) : void
      {
         _showStats = value;
         if(value)
         {
            showStatsAt(_statsDisplayAlign.horizontal || "left",_statsDisplayAlign.vertical || "top");
         }
         else if(_statsDisplay)
         {
            _statsDisplay.removeFromParent();
         }
      }
      
      public function showStatsAt(horizontalAlign:String = "left", verticalAlign:String = "top", scale:Number = 1) : void
      {
         var onRootCreated:* = function():void
         {
            if(_showStats)
            {
               showStatsAt(horizontalAlign,verticalAlign,scale);
            }
            removeEventListener("rootCreated",onRootCreated);
         };
         _showStats = true;
         _statsDisplayAlign.horizontal = horizontalAlign;
         _statsDisplayAlign.vertical = verticalAlign;
         if(context == null)
         {
            addEventListener("rootCreated",onRootCreated);
         }
         else
         {
            if(_statsDisplay == null)
            {
               _statsDisplay = new StatsDisplay();
               _statsDisplay.touchable = false;
            }
            _stage.addChild(_statsDisplay);
            _statsDisplay.scaleX = _statsDisplay.scaleY = scale;
            _statsDisplay.showSkipped = _skipUnchangedFrames;
            updateClippedViewPort();
            updateStatsDisplayPosition();
         }
      }
      
      private function updateStatsDisplayPosition() : void
      {
         if(!_showStats || _statsDisplay == null)
         {
            return;
         }
         var _loc5_:String = _statsDisplayAlign.horizontal;
         var _loc2_:String = _statsDisplayAlign.vertical;
         var _loc1_:Number = _viewPort.width / _stage.stageWidth;
         var _loc3_:Number = _viewPort.height / _stage.stageHeight;
         var _loc4_:Rectangle = Pool.getRectangle(_viewPort.x < 0 ? -_viewPort.x / _loc1_ : 0,_viewPort.y < 0 ? -_viewPort.y / _loc3_ : 0,_clippedViewPort.width / _loc1_,_clippedViewPort.height / _loc3_);
         if(_loc5_ == "left")
         {
            _statsDisplay.x = _loc4_.x;
         }
         else if(_loc5_ == "right")
         {
            _statsDisplay.x = _loc4_.right - _statsDisplay.width;
         }
         else
         {
            if(_loc5_ != "center")
            {
               throw new ArgumentError("Invalid horizontal alignment: " + _loc5_);
            }
            _statsDisplay.x = (_loc4_.right - _statsDisplay.width) / 2;
         }
         if(_loc2_ == "top")
         {
            _statsDisplay.y = _loc4_.y;
         }
         else if(_loc2_ == "bottom")
         {
            _statsDisplay.y = _loc4_.bottom - _statsDisplay.height;
         }
         else
         {
            if(_loc2_ != "center")
            {
               throw new ArgumentError("Invalid vertical alignment: " + _loc2_);
            }
            _statsDisplay.y = (_loc4_.bottom - _statsDisplay.height) / 2;
         }
         Pool.putRectangle(_loc4_);
      }
      
      public function get stage() : starling.display.Stage
      {
         return _stage;
      }
      
      public function get stage3D() : Stage3D
      {
         return _painter.stage3D;
      }
      
      public function get nativeStage() : flash.display.Stage
      {
         return _nativeStage;
      }
      
      public function get root() : DisplayObject
      {
         return _root;
      }
      
      public function get rootClass() : Class
      {
         return _rootClass;
      }
      
      public function set rootClass(value:Class) : void
      {
         if(_rootClass != null && _root != null)
         {
            throw new Error("Root class may not change after root has been instantiated");
         }
         if(_rootClass == null)
         {
            _rootClass = value;
            if(context)
            {
               initializeRoot();
            }
         }
      }
      
      public function get shareContext() : Boolean
      {
         return _painter.shareContext;
      }
      
      public function set shareContext(value:Boolean) : void
      {
         if(!value)
         {
            _previousViewPort.setEmpty();
         }
         _painter.shareContext = value;
      }
      
      public function get profile() : String
      {
         return _painter.profile;
      }
      
      public function get supportHighResolutions() : Boolean
      {
         return _supportHighResolutions;
      }
      
      public function set supportHighResolutions(value:Boolean) : void
      {
         if(_supportHighResolutions != value)
         {
            _supportHighResolutions = value;
            if(contextValid)
            {
               updateViewPort(true);
            }
         }
      }
      
      public function get supportBrowserZoom() : Boolean
      {
         return _supportBrowserZoom;
      }
      
      public function set supportBrowserZoom(value:Boolean) : void
      {
         if(_supportBrowserZoom != value)
         {
            _supportBrowserZoom = value;
            if(contextValid)
            {
               updateViewPort(true);
            }
            if(value)
            {
               _nativeStage.addEventListener("browserZoomChange",onBrowserZoomChange,false,0,true);
            }
            else
            {
               _nativeStage.removeEventListener("browserZoomChange",onBrowserZoomChange,false);
            }
         }
      }
      
      public function get skipUnchangedFrames() : Boolean
      {
         return _skipUnchangedFrames;
      }
      
      public function set skipUnchangedFrames(value:Boolean) : void
      {
         _skipUnchangedFrames = value;
         _nativeStageEmpty = false;
         if(_statsDisplay)
         {
            _statsDisplay.showSkipped = value;
         }
      }
      
      public function get touchProcessor() : TouchProcessor
      {
         return _touchProcessor;
      }
      
      public function set touchProcessor(value:TouchProcessor) : void
      {
         if(value == null)
         {
            throw new ArgumentError("TouchProcessor must not be null");
         }
         if(value != _touchProcessor)
         {
            _touchProcessor.dispose();
            _touchProcessor = value;
         }
      }
      
      public function get discardSystemGestures() : Boolean
      {
         return _touchProcessor.discardSystemGestures;
      }
      
      public function set discardSystemGestures(value:Boolean) : void
      {
         _touchProcessor.discardSystemGestures = value;
      }
      
      public function get frameID() : uint
      {
         return _frameID;
      }
      
      public function get contextValid() : Boolean
      {
         return _painter.contextValid;
      }
   }
}

import flash.display.DisplayObject;
import flash.display.DisplayObjectContainer;

function isNativeDisplayObjectEmpty(object:DisplayObject):Boolean
{
   var _loc2_:DisplayObjectContainer = null;
   var _loc3_:int = 0;
   var _loc4_:int = 0;
   if(object == null)
   {
      return true;
   }
   if(object is DisplayObjectContainer)
   {
      _loc2_ = object as DisplayObjectContainer;
      _loc3_ = _loc2_.numChildren;
      _loc4_ = 0;
      while(_loc4_ < _loc3_)
      {
         if(!isNativeDisplayObjectEmpty(_loc2_.getChildAt(_loc4_)))
         {
            return false;
         }
         _loc4_++;
      }
      return true;
   }
   return !object.visible;
}
