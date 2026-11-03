package UI.Hud.StarlingConverted
{
   import Brain.Starling.SwfConverter.BakedCell;
   import Brain.Starling.SwfConverter.BakedPages;
   import Brain.Starling.SwfConverter.BakedPicture;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.FrameLabel;
   import flash.display.GraphicsGradientFill;
   import flash.display.GraphicsSolidFill;
   import flash.display.GraphicsStroke;
   import flash.display.IGraphicsData;
   import flash.display.IGraphicsFill;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.filters.ColorMatrixFilter;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   import flash.utils.getTimer;
   import starling.core.Starling;
   
   public class HudArtConverter
   {
      
      private static var sPixels:Dictionary;
      
      private static var sGrays:Dictionary;
      
      private static var sAnonymous:Dictionary;
      
      private static var sNextAnonymous:int = 0;
      
      private static var sWorkDepth:int = 0;
      
      private var mPages:BakedPages;
      
      private var mFramePages:BakedPages;
      
      private var mOriginal:Object;
      
      private var mTouched:Dictionary = new Dictionary();
      
      private var mError:String;
      
      private var mScale:Number;
      
      private var mOptions:Object;
      
      private var mJobs:Vector.<Function> = new Vector.<Function>(0);
      
      private var mDriver:Shape;
      
      private var mWorking:Boolean = false;
      
      private var mWaitingForFrame:Boolean = false;
      
      private var mCapture:Function;
      
      private var mFinished:Boolean = false;
      
      private var mDone:Function;
      
      private var mBudget:Number;
      
      private var mRoot:ArtNode;
      
      private var mSymbol:String;
      
      private var mContexts:Dictionary = new Dictionary(true);
      
      private var mMasks:Dictionary = new Dictionary(true);
      
      private var mMaskProbed:Dictionary = new Dictionary(true);
      
      private var mSamples:Dictionary = new Dictionary();
      
      private var mSampleCounts:Dictionary = new Dictionary();
      
      private var mSampleBakes:Dictionary = new Dictionary();
      
      private var mFailures:int = 0;
      
      private var mSource:DisplayObject;
      
      private var mDrawParents:Dictionary = new Dictionary(true);
      
      private var mDrawMatrices:Dictionary = new Dictionary(true);
      
      private var mHudScale:Number;
      
      public function HudArtConverter()
      {
         super();
      }
      
      public static function convert(source:DisplayObject, pages:BakedPages, scale:Number, options:Object = null) : ArtNode
      {
         var _loc5_:HudArtConverter = new HudArtConverter();
         _loc5_.mWorking = true;
         sWorkDepth = sWorkDepth + 1;
         try
         {
            _loc5_.initialize(source,pages,scale,options);
            if(_loc5_.mError == null)
            {
               _loc5_.run(1.7976931348623157e+308);
            }
         }
         catch(error:*)
         {
            _loc5_.recordError(error);
         }
         finally
         {
            _loc5_.finishSafely();
            _loc5_.mWorking = false;
            sWorkDepth = sWorkDepth - 1;
         }
         return _loc5_.mRoot;
      }
      
      public static function convertAsync(source:DisplayObject, pages:BakedPages, scale:Number, options:Object, onDone:Function, budgetMs:Number = 8) : HudArtConverter
      {
         var _loc7_:HudArtConverter = new HudArtConverter();
         _loc7_.mDone = onDone;
         _loc7_.mBudget = Math.max(1,budgetMs);
         _loc7_.mDriver = new Shape();
         _loc7_.mWorking = true;
         sWorkDepth = sWorkDepth + 1;
         try
         {
            _loc7_.initialize(source,pages,scale,options);
         }
         catch(error:*)
         {
            _loc7_.recordError(error);
         }
         finally
         {
            _loc7_.mWorking = false;
            sWorkDepth = sWorkDepth - 1;
         }
         _loc7_.mDriver.addEventListener("exitFrame",_loc7_.onFrame);
         return _loc7_;
      }
      
      internal static function grayscaleFilter() : ColorMatrixFilter
      {
         return new ColorMatrixFilter([0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0.3086,0.6094,0.082,0,0,0,0,0,1,0]);
      }
      
      internal static function get busy() : Boolean
      {
         return sWorkDepth > 0;
      }
      
      internal static function beginWork() : void
      {
         sWorkDepth = sWorkDepth + 1;
      }
      
      internal static function endWork() : void
      {
         sWorkDepth = sWorkDepth - 1;
      }
      
      private static function buildBounds(node:ArtNode) : Rectangle
      {
         var _loc4_:ArtNode = null;
         var _loc5_:ArtFrame = null;
         var _loc3_:ArtChildState = null;
         var _loc2_:Rectangle = new Rectangle();
         for each(_loc4_ in node.children)
         {
            buildBounds(_loc4_);
         }
         addCellBounds(_loc2_,node.cell);
         if(node.model != null)
         {
            _loc2_ = node.model.getBounds(node.model);
         }
         for each(_loc5_ in node.frames)
         {
            if(_loc5_ != null)
            {
               addCellBounds(_loc2_,_loc5_.cell);
               for each(_loc3_ in _loc5_.children)
               {
                  if(_loc3_.visible && _loc3_.alpha > 0)
                  {
                     addTransformed(_loc2_,node.children[_loc3_.child].maximalBounds,_loc3_.matrix,_loc3_.parentClip);
                  }
               }
            }
         }
         if(node.frames.length == 0)
         {
            for each(_loc4_ in node.children)
            {
               addTransformed(_loc2_,_loc4_.maximalBounds,_loc4_.matrix,_loc4_.parentClip);
            }
         }
         node.maximalBounds = _loc2_;
         return _loc2_;
      }
      
      private static function addCellBounds(bounds:Rectangle, cell:BakedCell) : void
      {
         if(cell == null || cell.isEmpty)
         {
            return;
         }
         var _loc3_:Rectangle = new Rectangle(-cell.pivotX,-cell.pivotY,cell.pixelWidth / cell.pixelScale,cell.pixelHeight / cell.pixelScale);
         if(bounds.isEmpty())
         {
            bounds.copyFrom(_loc3_);
         }
         else
         {
            bounds.copyFrom(bounds.union(_loc3_));
         }
      }
      
      private static function addTransformed(bounds:Rectangle, rect:Rectangle, matrix:Matrix, clip:Rectangle = null) : void
      {
         if(rect == null || rect.isEmpty())
         {
            return;
         }
         var _loc5_:Point = matrix.transformPoint(rect.topLeft);
         var _loc6_:Point = matrix.transformPoint(new Point(rect.right,rect.top));
         var _loc7_:Point = matrix.transformPoint(rect.bottomRight);
         var _loc8_:Point = matrix.transformPoint(new Point(rect.left,rect.bottom));
         var _loc9_:Number = Math.min(_loc5_.x,_loc6_.x,_loc7_.x,_loc8_.x);
         var _loc10_:Number = Math.min(_loc5_.y,_loc6_.y,_loc7_.y,_loc8_.y);
         var _loc11_:Rectangle = new Rectangle(_loc9_,_loc10_,Math.max(_loc5_.x,_loc6_.x,_loc7_.x,_loc8_.x) - _loc9_,Math.max(_loc5_.y,_loc6_.y,_loc7_.y,_loc8_.y) - _loc10_);
         if(clip != null)
         {
            _loc11_ = _loc11_.intersection(clip);
         }
         if(_loc11_.isEmpty())
         {
            return;
         }
         if(bounds.isEmpty())
         {
            bounds.copyFrom(_loc11_);
         }
         else
         {
            bounds.copyFrom(bounds.union(_loc11_));
         }
      }
      
      private static function excluded(source:DisplayObject) : Boolean
      {
         return source.name == "tooltip" || source.name.indexOf("tooltip_modifier0") == 0 || source.name == "consumable_tooltip01" || source.name == "consumable_tooltip02" || source.name == "UI_chat" || source.name == "chatLogContainer";
      }
      
      private static function containsText(source:DisplayObjectContainer) : Boolean
      {
         var _loc2_:int = 0;
         var _loc3_:DisplayObject = null;
         _loc2_ = 0;
         while(_loc2_ < source.numChildren)
         {
            _loc3_ = source.getChildAt(_loc2_);
            if(!excluded(_loc3_))
            {
               if(_loc3_ is TextField || _loc3_ is DisplayObjectContainer && containsText(DisplayObjectContainer(_loc3_)))
               {
                  return true;
               }
            }
            _loc2_++;
         }
         return false;
      }
      
      private static function collectExcluded(source:DisplayObjectContainer, hidden:Vector.<DisplayObject>) : void
      {
         var _loc3_:int = 0;
         var _loc4_:DisplayObject = null;
         _loc3_ = 0;
         while(_loc3_ < source.numChildren)
         {
            _loc4_ = source.getChildAt(_loc3_);
            if(_loc4_ is TextField || excluded(_loc4_))
            {
               hidden.push(_loc4_);
            }
            else if(_loc4_ is DisplayObjectContainer)
            {
               collectExcluded(DisplayObjectContainer(_loc4_),hidden);
            }
            _loc3_++;
         }
      }
      
      private static function requiresSamples(source:DisplayObject) : Boolean
      {
         return source is Shape || source is Bitmap || source.filters.length > 0 || source.mask != null;
      }
      
      private static function opaqueFill(fill:IGraphicsFill) : void
      {
         var _loc3_:int = 0;
         var _loc2_:GraphicsGradientFill = fill as GraphicsGradientFill;
         if(fill is GraphicsSolidFill)
         {
            GraphicsSolidFill(fill).alpha = 1;
         }
         else if(_loc2_ != null)
         {
            _loc3_ = 0;
            while(_loc3_ < _loc2_.alphas.length)
            {
               _loc2_.alphas[_loc3_] = 1;
               _loc3_++;
            }
         }
      }
      
      private static function copyBake(source:BakedPicture) : BakedPicture
      {
         var _loc2_:BakedPicture = new BakedPicture();
         _loc2_.bitmap = source.bitmap.clone();
         _loc2_.originX = source.originX;
         _loc2_.originY = source.originY;
         _loc2_.pixelScale = source.pixelScale;
         _loc2_.empty = source.empty;
         StarlingRaster.limit(_loc2_,StarlingRaster.requestedScale(source));
         return _loc2_;
      }
      
      internal static function forgetPixels(cell:BakedCell) : void
      {
         var _loc2_:BakedPicture = sPixels[cell] as BakedPicture;
         if(_loc2_ != null)
         {
            _loc2_.dispose();
         }
         delete sPixels[cell];
      }
      
      internal static function grayscale(cell:BakedCell, pages:BakedPages) : BakedCell
      {
         if(cell == null)
         {
            return null;
         }
         var _loc6_:BakedCell = sGrays[cell] as BakedCell;
         if(_loc6_ != null && _loc6_.alive)
         {
            return _loc6_;
         }
         var _loc8_:String = cell.key + "|gray";
         var _loc3_:ArtNode = HudArt.content(_loc8_);
         if(_loc3_ != null)
         {
            sGrays[cell] = _loc3_.cell;
            return _loc3_.cell;
         }
         var _loc4_:BakedPicture = sPixels[cell] as BakedPicture;
         if(_loc4_ == null)
         {
            return null;
         }
         var _loc7_:BakedPicture = copyBake(_loc4_);
         _loc7_.bitmap.applyFilter(_loc7_.bitmap,_loc7_.bitmap.rect,new Point(),HudArtConverter.grayscaleFilter());
         var _loc5_:BakedCell = pages.add(_loc8_,_loc7_,true);
         if(_loc5_ == null)
         {
            return null;
         }
         if(_loc5_ is HudCell)
         {
            HudCell(_loc5_).mSource = cell as HudCell;
         }
         _loc3_ = new ArtNode();
         _loc3_.cell = _loc3_.hold(_loc5_,pages);
         HudArt.storeContent(_loc8_,_loc3_);
         sGrays[cell] = _loc5_;
         return _loc5_;
      }
      
      internal static function grayCell(cell:BakedCell) : BakedCell
      {
         if(cell == null)
         {
            return null;
         }
         return sGrays[cell] as BakedCell || cell;
      }
      
      private static function localBounds(bake:BakedPicture, matrix:Matrix) : Rectangle
      {
         var _loc8_:Number = -bake.originX / bake.pixelScale;
         var _loc6_:Number = -bake.originY / bake.pixelScale;
         var _loc12_:Number = _loc8_ + bake.bitmap.width / bake.pixelScale;
         var _loc9_:Number = _loc6_ + bake.bitmap.height / bake.pixelScale;
         var _loc3_:Point = matrix.transformPoint(new Point(_loc8_,_loc6_));
         var _loc4_:Point = matrix.transformPoint(new Point(_loc12_,_loc6_));
         var _loc5_:Point = matrix.transformPoint(new Point(_loc8_,_loc9_));
         var _loc7_:Point = matrix.transformPoint(new Point(_loc12_,_loc9_));
         var _loc10_:Number = Math.min(_loc3_.x,_loc4_.x,_loc5_.x,_loc7_.x);
         var _loc11_:Number = Math.min(_loc3_.y,_loc4_.y,_loc5_.y,_loc7_.y);
         return new Rectangle(_loc10_,_loc11_,Math.max(_loc3_.x,_loc4_.x,_loc5_.x,_loc7_.x) - _loc10_,Math.max(_loc3_.y,_loc4_.y,_loc5_.y,_loc7_.y) - _loc11_);
      }
      
      private static function positive(color:ColorTransform) : Boolean
      {
         return color.redOffset > 0 || color.greenOffset > 0 || color.blueOffset > 0;
      }
      
      private static function isButton(source:DisplayObject) : Boolean
      {
         var _loc2_:DisplayObjectContainer = source as DisplayObjectContainer;
         return _loc2_ != null && _loc2_.getChildByName("up") != null;
      }
      
      private static function isButtonState(source:DisplayObject) : Boolean
      {
         return source.parent != null && isButton(source.parent) && (source.name == "up" || source.name == "over" || source.name == "down" || source.name == "disabled" || source.name == "selected");
      }
      
      private static function rendererTree(source:DisplayObject) : Boolean
      {
         var _loc2_:DisplayObject = source;
         while(_loc2_ != null)
         {
            if(isButtonState(_loc2_) || _loc2_.name == "cooldown" || _loc2_.name == "UI_buster_glow" || _loc2_.name == "buster_activated_glow")
            {
               return true;
            }
            _loc2_ = _loc2_.parent;
         }
         return false;
      }
      
      private static function rememberTree(source:DisplayObject, descendants:Boolean = true) : Object
      {
         var _loc5_:int = 0;
         var _loc6_:MovieClip = source as MovieClip;
         var _loc3_:Object = {
            "className":getQualifiedClassName(source),
            "frame":(_loc6_ != null ? _loc6_.currentFrame : 0),
            "playing":_loc6_ != null && _loc6_.isPlaying,
            "children":[],
            "matrix":source.transform.matrix.clone(),
            "color":source.transform.colorTransform,
            "visible":source.visible,
            "filters":source.filters,
            "blendMode":source.blendMode,
            "scrollRect":source.scrollRect
         };
         var _loc4_:DisplayObjectContainer = source as DisplayObjectContainer;
         if(descendants && _loc4_ != null)
         {
            _loc5_ = 0;
            while(_loc5_ < _loc4_.numChildren)
            {
               _loc3_.children.push(rememberTree(_loc4_.getChildAt(_loc5_)));
               _loc5_++;
            }
         }
         return _loc3_;
      }
      
      private static function restoreTree(source:DisplayObject, state:Object) : void
      {
         var _loc4_:int = 0;
         if(source == null || state == null || getQualifiedClassName(source) != state.className)
         {
            return;
         }
         var _loc5_:MovieClip = source as MovieClip;
         if(_loc5_ != null)
         {
            if(_loc5_.currentFrame != state.frame)
            {
               if(state.playing)
               {
                  _loc5_.gotoAndPlay(state.frame);
               }
               else
               {
                  _loc5_.gotoAndStop(state.frame);
               }
            }
            else if(state.playing)
            {
               _loc5_.play();
            }
            else
            {
               _loc5_.stop();
            }
         }
         var _loc3_:DisplayObjectContainer = source as DisplayObjectContainer;
         if(_loc3_ != null)
         {
            _loc4_ = 0;
            while(_loc4_ < _loc3_.numChildren && _loc4_ < state.children.length)
            {
               restoreTree(_loc3_.getChildAt(_loc4_),state.children[_loc4_]);
               _loc4_++;
            }
         }
         restoreProperties(source,state);
      }
      
      private static function restoreProperties(source:DisplayObject, state:Object) : void
      {
         source.transform.matrix = state.matrix;
         source.transform.colorTransform = state.color;
         source.visible = state.visible;
         source.filters = state.filters;
         source.blendMode = state.blendMode;
         source.scrollRect = state.scrollRect;
      }
      
      private static function filterState(node:ArtNode, filters:Array) : int
      {
         var _loc4_:int = 0;
         var _loc3_:String = filterSignature(filters);
         _loc4_ = 0;
         while(_loc4_ < node.filterStates.length)
         {
            if(filterSignature(node.filterStates[_loc4_]) == _loc3_)
            {
               return _loc4_;
            }
            _loc4_++;
         }
         node.filterStates.push(filters);
         return node.filterStates.length - 1;
      }
      
      internal static function filterSignature(filters:Array) : String
      {
         var _loc3_:Object = null;
         var _loc4_:String = null;
         var _loc2_:String = "";
         var _loc5_:Array = ["color","alpha","blurX","blurY","strength","quality","inner","knockout","hideObject","distance","angle","matrix"];
         for each(_loc3_ in filters)
         {
            _loc2_ += getQualifiedClassName(_loc3_);
            for each(_loc4_ in _loc5_)
            {
               if(_loc4_ in _loc3_)
               {
                  _loc2_ += "|" + _loc4_ + ":" + _loc3_[_loc4_];
               }
            }
            _loc2_ += ";";
         }
         return _loc2_;
      }
      
      public static function maxFrames(source:DisplayObject) : int
      {
         var _loc4_:int = 0;
         var _loc5_:MovieClip = source as MovieClip;
         var _loc3_:int = int(_loc5_ != null ? _loc5_.totalFrames : 1);
         var _loc2_:DisplayObjectContainer = source as DisplayObjectContainer;
         if(_loc2_ != null)
         {
            _loc4_ = 0;
            while(_loc4_ < _loc2_.numChildren)
            {
               _loc3_ = Math.max(_loc3_,maxFrames(_loc2_.getChildAt(_loc4_)));
               _loc4_++;
            }
         }
         return _loc3_;
      }
      
      public static function stopTree(source:DisplayObject) : void
      {
         var _loc3_:int = 0;
         var _loc4_:MovieClip = source as MovieClip;
         if(_loc4_ != null)
         {
            _loc4_.stop();
         }
         var _loc2_:DisplayObjectContainer = source as DisplayObjectContainer;
         if(_loc2_ != null)
         {
            _loc3_ = 0;
            while(_loc3_ < _loc2_.numChildren)
            {
               stopTree(_loc2_.getChildAt(_loc3_));
               _loc3_++;
            }
         }
      }
      
      private static function readLabels(node:ArtNode, clip:MovieClip) : void
      {
         var _loc3_:FrameLabel = null;
         for each(_loc3_ in clip.currentLabels)
         {
            node.labels[_loc3_.name] = _loc3_.frame - 1;
            if(node.labelLoop == 0 && _loc3_.name == "loop")
            {
               node.labelLoop = 1;
               node.loopFrame = _loc3_.frame - 1;
            }
            else if(node.labelLoop == 0 && _loc3_.name == "noloop")
            {
               node.labelLoop = -1;
            }
         }
      }
      
      private function initialize(source:DisplayObject, pages:BakedPages, scale:Number, options:Object) : void
      {
         if(sPixels == null)
         {
            sPixels = new Dictionary(true);
         }
         if(sGrays == null)
         {
            sGrays = new Dictionary(true);
         }
         if(sAnonymous == null)
         {
            sAnonymous = new Dictionary(true);
         }
         mPages = pages;
         mFramePages = options != null ? options.framePages as BakedPages : null;
         mScale = scale;
         mHudScale = options != null && options.hudScale > 0 ? Number(options.hudScale) : HudArt.pixelScale;
         mOptions = options;
         mSymbol = getQualifiedClassName(source);
         mSource = source;
         mDrawParents[source] = new Matrix(scale / mHudScale,0,0,scale / mHudScale);
         captureMatrix(source);
         mOriginal = rememberTree(source);
         rememberTouched(source);
         stopTree(source);
         mJobs.push(function():void
         {
            constructTree(source);
            mRoot = makeNode(source,"",true);
         });
      }
      
      private function run(budget:Number) : void
      {
         var _loc3_:Function = null;
         var _loc2_:int = getTimer();
         while(!(mJobs.length == 0 || mWaitingForFrame))
         {
            _loc3_ = mJobs.pop();
            _loc3_();
            if(mError != null)
            {
               break;
            }
            if(getTimer() - _loc2_ >= budget)
            {
               break;
            }
         }
      }
      
      private function onFrame(event:Event) : void
      {
         var _loc3_:Function = null;
         var _loc5_:Number = NaN;
         var _loc4_:Function = null;
         if(HudArt.fatalFailure)
         {
            cancel();
            return;
         }
         if(Starling.current == null || !Starling.current.contextValid)
         {
            return;
         }
         if(mWorking || busy || mDriver == null || mFinished)
         {
            return;
         }
         mWorking = true;
         sWorkDepth = sWorkDepth + 1;
         mDriver.removeEventListener("exitFrame",onFrame);
         var _loc2_:int = getTimer();
         try
         {
            try
            {
               if(mError == null && mCapture != null)
               {
                  _loc3_ = mCapture;
                  mCapture = null;
                  mWaitingForFrame = false;
                  _loc3_();
               }
               _loc5_ = mBudget - (getTimer() - _loc2_);
               if(mError == null && _loc5_ > 0)
               {
                  run(_loc5_);
               }
            }
            catch(error:*)
            {
               recordError(error);
            }
            if(mError == null && (mJobs.length > 0 || mWaitingForFrame))
            {
               return;
            }
            mJobs.length = 0;
            mCapture = null;
            mDriver = null;
            finishSafely();
            _loc4_ = mDone;
            mDone = null;
            try
            {
               if(_loc4_ != null)
               {
                  _loc4_(mRoot);
               }
            }
            catch(callbackError:*)
            {
               HudArt.fail("HUD conversion callback: " + mSymbol + " " + String(callbackError),callbackError as Error);
            }
         }
         finally
         {
            mWorking = false;
            sWorkDepth = sWorkDepth - 1;
            if(mDriver != null)
            {
               mDriver.addEventListener("exitFrame",onFrame);
            }
         }
      }
      
      internal function cancel() : void
      {
         if(mDriver != null)
         {
            mDriver.removeEventListener("exitFrame",onFrame);
         }
         mDriver = null;
         mDone = null;
         mCapture = null;
         mWaitingForFrame = false;
         mJobs.length = 0;
         mWorking = true;
         sWorkDepth = sWorkDepth + 1;
         try
         {
            finishSafely(false);
            if(mRoot != null)
            {
               mRoot.release(mPages);
               mRoot = null;
            }
         }
         catch(error:*)
         {
            recordError(error);
         }
         finally
         {
            mWorking = false;
            sWorkDepth = sWorkDepth - 1;
         }
      }
      
      private function recordError(error:*) : void
      {
         if(error is HudFatalError)
         {
            HudArt.fatal(Error(error).message);
         }
         StarlingHud.reportError(error is Error ? error as Error : new Error(String(error)));
         if(mError == null)
         {
            mError = error is Error ? Error(error).errorID + " " + Error(error).message : (error is ErrorEvent ? ErrorEvent(error).text : String(error));
         }
         mFailures = mFailures + 1;
         if(mRoot != null)
         {
            mRoot.failures++;
         }
      }
      
      private function finishSafely(silhouettes:Boolean = true) : void
      {
         if(mFinished)
         {
            return;
         }
         mFinished = true;
         try
         {
            finish(silhouettes);
         }
         catch(error:*)
         {
            recordError(error);
         }
         finally
         {
            if(mRoot != null)
            {
               mRoot.failures = mFailures;
            }
         }
      }
      
      private function finish(silhouettes:Boolean = true) : void
      {
         var _loc3_:DisplayObject = null;
         try
         {
            if(silhouettes && mRoot != null && mError == null)
            {
               inheritSilhouettes(mRoot,false);
            }
         }
         catch(error:*)
         {
            recordError(error);
         }
         finally
         {
            for(var _loc2_:Object in mTouched)
            {
               _loc3_ = _loc2_ as DisplayObject;
               try
               {
                  restoreTree(_loc3_,mTouched[_loc2_]);
               }
               catch(propertyError:*)
               {
                  recordError(propertyError);
               }
            }
            try
            {
               restoreTree(mSource,mOriginal);
            }
            catch(restoreError:*)
            {
               recordError(restoreError);
            }
            for(_loc2_ in mTouched)
            {
               try
               {
                  restoreProperties(_loc2_ as DisplayObject,mTouched[_loc2_]);
               }
               catch(overrideError:*)
               {
                  recordError(overrideError);
               }
            }
            mSource = null;
            mOriginal = null;
            mTouched = new Dictionary();
         }
         try
         {
            if(mRoot != null)
            {
               labelBehaviour(mRoot);
            }
         }
         catch(labelError:*)
         {
            recordError(labelError);
         }
         if(mRoot != null)
         {
            buildBounds(mRoot);
         }
         if(mRoot != null)
         {
            mRoot.failures = mFailures;
         }
      }
      
      private function labelBehaviour(node:ArtNode) : int
      {
         var _loc3_:ArtNode = null;
         var _loc2_:int = 0;
         for each(_loc3_ in node.children)
         {
            _loc2_ = labelBehaviour(_loc3_);
            if(_loc2_ != 0)
            {
               node.labelLoop = _loc2_;
            }
         }
         return node.labelLoop;
      }
      
      internal function get failures() : int
      {
         return mFailures;
      }
      
      internal function get error() : String
      {
         return mError;
      }
      
      private function option(name:String, path:String) : Boolean
      {
         var _loc3_:* = mOptions != null ? mOptions[name] : null;
         return _loc3_ is Function ? Boolean(_loc3_(path)) : _loc3_ === true;
      }
      
      private function keep(source:DisplayObject, path:String) : Boolean
      {
         var _loc4_:int = 0;
         var _loc5_:DisplayObject = null;
         if(option("flatten",path))
         {
            return false;
         }
         if(source is TextField || source.name != null && source.name.indexOf("instance") != 0)
         {
            return true;
         }
         if(maxFrames(source) > 1)
         {
            return true;
         }
         var _loc3_:DisplayObjectContainer = source as DisplayObjectContainer;
         if(_loc3_ != null)
         {
            _loc4_ = 0;
            while(_loc4_ < _loc3_.numChildren)
            {
               _loc5_ = _loc3_.getChildAt(_loc4_);
               if(keep(_loc5_,childPath(path,_loc5_,_loc4_)))
               {
                  return true;
               }
               _loc4_++;
            }
         }
         return false;
      }
      
      private function childPath(path:String, child:DisplayObject, depth:int) : String
      {
         return (path.length > 0 ? path + "." : "") + (child.name != null && child.name.indexOf("instance") != 0 ? child.name : "@" + depth);
      }
      
      private function makeNode(source:DisplayObject, path:String, root:Boolean = false, sampled:Boolean = false) : ArtNode
      {
         var node:ArtNode;
         var fillRoot:DisplayObject;
         var container:DisplayObjectContainer;
         var clip:MovieClip;
         var field:TextField;
         var forced:String;
         var count:int;
         var format:TextFormat;
         constructTree(source);
         node = new ArtNode();
         captureMatrix(source);
         node.filterStates.push(source.filters);
         if(source.parent != null && option("clipMasks",path))
         {
            node.parentClip = TimelineMasks.clip(source.parent,source);
         }
         node.name = path.length == 0 ? (source.name != null && source.name.length > 0 && source.name.indexOf("instance") != 0 ? source.name : mSymbol) : path.substr(path.lastIndexOf(".") + 1);
         node.masked = source.mask != null;
         node.barFill = isBar(source,path);
         if(node.barFill)
         {
            fillRoot = source.name == "bar" ? source.parent : source;
            node.masked = node.masked || fillRoot.mask != null || hasMasks(source.parent) || hasMasks(fillRoot.parent);
         }
         if(node.barFill)
         {
            node.registrationWidth = source.getBounds(source).right;
         }
         node.wantsSilhouette = positive(source.transform.colorTransform);
         node.matrix = source.transform.matrix.clone();
         node.alpha = source.alpha;
         node.visible = source.visible;
         node.blendMode = source.blendMode;
         node.colorTransform = source.transform.colorTransform;
         container = source as DisplayObjectContainer;
         clip = source as MovieClip;
         field = source as TextField;
         forced = mOptions != null && mOptions.kind is Function ? mOptions.kind(path) : null;
         count = maxFrames(source);
         assignContext(source,path);
         node.key = contentKey(source,path,0);
         if(field != null)
         {
            node.kind = "text";
            node.model = field;
            node.textBounds = field.getBounds(field);
            node.textPages = mPages;
            node.pixelScale = scaleOf(source);
            node.initialText = field.text;
            format = field.length > 0 ? field.getTextFormat() : field.defaultTextFormat;
            node.alignment = field.autoSize == "center" || field.autoSize == "right" ? field.autoSize : format.align;
            return node;
         }
         if(clip != null)
         {
            readLabels(node,clip);
         }
         if(clip != null && source.name == "cooldown")
         {
            node.kind = "timeline";
            node.totalFrames = node.authoredFrames = clip.totalFrames;
            node.frames.length = clip.totalFrames;
            mJobs.push(function():void
            {
               buildSweep(node,clip,path);
            });
            return node;
         }
         if(forced == "flipbook" || forced == "states" || forced == "timeline")
         {
            node.kind = forced;
         }
         else if(clip != null && (clip.totalFrames > 1 || isButtonState(source) || count > 1 && (source.name == "UI_buster_glow" || source.name == "buster_activated_glow" || mSymbol.indexOf("UI_teamloot_") == 0)) && !option("flatten",path))
         {
            node.kind = "timeline";
         }
         else if((root || keep(source,path)) && container != null && (root || container.numChildren > 0) && !option("flatten",path))
         {
            node.kind = "container";
         }
         else
         {
            node.kind = "static";
         }
         if(!node.barFill && (source.mask != null && node.parentClip == null || container != null && container.scrollRect != null))
         {
            node.kind = count > 1 ? "flipbook" : "static";
         }
         if(container != null && source.filters.length > 0 && node.kind != "static")
         {
            node.kind = count > 1 ? "flipbook" : "static";
         }
         if(isButton(source))
         {
            node.kind = "container";
            scheduleButtonHit(node,container,path);
         }
         if(container != null && containsText(container))
         {
            if(node.kind == "static")
            {
               node.kind = "container";
            }
            else if(node.kind == "flipbook")
            {
               node.kind = "timeline";
            }
         }
         if(!node.barFill && !barRoot(source,path) && container != null && !containsText(container) && (hasMasks(container) && !option("clipMasks",path) || isButtonState(source) && count == 1))
         {
            node.kind = count > 1 ? "flipbook" : "static";
         }
         node.stageRate = (node.kind == "timeline" || node.kind == "flipbook") && !rendererTree(source) && mSymbol.indexOf("UI_teamloot_") != 0;
         if(option("stageRate",path))
         {
            node.stageRate = true;
         }
         if(node.barFill)
         {
            node.kind = "static";
         }
         if(option("flatten",path) && !(container != null && containsText(container)))
         {
            node.kind = "static";
         }
         if(sampled && !(container != null && containsText(container)))
         {
            node.kind = "static";
         }
         if(node.kind == "static")
         {
            scheduleBake(node,source,path,0,null);
         }
         else if(node.kind == "container")
         {
            mJobs.push(function():void
            {
               buildContainer(node,container,path);
            });
         }
         else
         {
            node.totalFrames = count;
            node.authoredFrames = clip != null ? clip.totalFrames : count;
            node.frames.length = node.kind == "flipbook" ? count : node.authoredFrames;
            mJobs.push(function():void
            {
               record(node,source,path,0,new Dictionary(),{});
            });
         }
         return node;
      }
      
      private function scheduleButtonHit(node:ArtNode, source:DisplayObjectContainer, path:String) : void
      {
         if(source.getChildByName("hit") != null)
         {
            return;
         }
         mJobs.push(function():void
         {
            var _loc2_:Sprite = null;
            var _loc1_:BakedPicture = null;
            var _loc4_:String = contentKey(source,path,0) + "|buttonHit";
            var _loc3_:BakedCell = mPages.acquire(_loc4_);
            if(_loc3_ == null)
            {
               _loc2_ = new Sprite();
               _loc2_.addChild(hitGeometry(source.getChildByName("up"),false,true));
               _loc1_ = StarlingRaster.bake(_loc2_,scaleOf(source));
               if(_loc1_ != null)
               {
                  _loc3_ = mPages.add(_loc4_,_loc1_,true);
               }
            }
            node.hitCell = node.hold(_loc3_,mPages);
            if(_loc3_ == null)
            {
               mFailures = mFailures + 1;
               node.failures++;
            }
         });
      }
      
      private function buildSweep(node:ArtNode, clip:MovieClip, path:String) : void
      {
         var _loc6_:BakedCell = null;
         var _loc5_:BakedPicture = null;
         var _loc7_:String = null;
         var _loc4_:BakedPicture = null;
         rememberTouched(clip);
         node.sweep = StarlingSweepArt.of(clip,rememberTouched);
         if(node.sweep != null)
         {
            _loc7_ = contentKey(clip,path,0) + "|disc";
            _loc6_ = mPages.acquire(_loc7_);
            if(_loc6_ == null)
            {
               _loc5_ = node.sweep.bakeDisc(clip,scaleOf(clip),rememberTouched);
               if(_loc5_ != null)
               {
                  _loc4_ = copyBake(_loc5_);
                  _loc6_ = mPages.add(_loc7_,_loc5_,true);
                  if(_loc6_ != null)
                  {
                     sPixels[_loc6_] = _loc4_;
                  }
                  else
                  {
                     _loc4_.dispose();
                  }
               }
            }
         }
         node.cell = node.hold(_loc6_,mPages);
         if(_loc6_ == null)
         {
            mFailures = mFailures + 1;
            node.failures++;
            mError = "Cooldown sweep: " + path + " " + StarlingSweepArt.lastRefusal;
         }
      }
      
      private function buildContainer(node:ArtNode, source:DisplayObjectContainer, path:String) : void
      {
         var _loc6_:int = 0;
         var _loc8_:DisplayObject = null;
         var _loc7_:ArtNode = null;
         var _loc5_:Vector.<DisplayObject> = undefined;
         constructTree(source);
         discoverMasks(source);
         var _loc4_:Sprite = source as Sprite;
         if(_loc4_ != null && _loc4_.graphics.readGraphicsData(false).length > 0)
         {
            _loc7_ = new ArtNode();
            _loc7_.name = "@graphics";
            _loc7_.kind = "static";
            _loc5_ = new Vector.<DisplayObject>(0);
            _loc6_ = 0;
            while(_loc6_ < source.numChildren)
            {
               _loc5_.push(source.getChildAt(_loc6_));
               _loc6_++;
            }
            scheduleBake(_loc7_,source,path + ".@graphics",0,null,_loc5_);
            node.children.push(_loc7_);
         }
         _loc6_ = 0;
         while(_loc6_ < source.numChildren)
         {
            _loc8_ = source.getChildAt(_loc6_);
            if(!(isMask(source,_loc8_) || excluded(_loc8_)))
            {
               node.children.push(makeNode(_loc8_,childPath(path,_loc8_,_loc6_)));
            }
            _loc6_++;
         }
      }
      
      private function record(node:ArtNode, source:DisplayObject, path:String, index:int, identities:Dictionary, depths:Object) : void
      {
         var target:int;
         var clip:MovieClip = source as MovieClip;
         var constructed:Boolean = true;
         if(node.kind == "flipbook")
         {
            constructed = seekTree(source,index);
         }
         else
         {
            rememberTouched(source);
            target = clip != null ? index % clip.totalFrames + 1 : 1;
            if(clip != null)
            {
               clip.gotoAndStop(target);
               constructed = clip.currentFrame == target;
            }
            constructed = constructChildren(source) && constructed;
            rememberTouched(source);
         }
         stopTree(source);
         if(mDriver != null && !constructed)
         {
            mWaitingForFrame = true;
            mCapture = function():void
            {
               captureRecord(node,source,path,index,identities,depths);
            };
         }
         else
         {
            captureRecord(node,source,path,index,identities,depths);
         }
      }
      
      private function captureRecord(node:ArtNode, source:DisplayObject, path:String, index:int, identities:Dictionary, depths:Object) : void
      {
         var frame:ArtFrame;
         var container:DisplayObjectContainer;
         var i:int;
         var child:DisplayObject;
         var childNode:ArtNode;
         var id:int;
         var depthKey:String;
         var state:ArtChildState;
         var signature:String;
         var samples:Object;
         var sample:ArtFrame;
         var next:Function;
         constructChildren(source);
         stopTree(source);
         frame = new ArtFrame();
         frame.filterState = filterState(node,source.filters);
         node.frames[index] = frame;
         if(node.kind == "flipbook" || node.kind == "states" && option("flatten",path))
         {
            scheduleBake(node,source,path,index,frame);
         }
         else
         {
            container = source as DisplayObjectContainer;
            recordGraphics(node,source,path,index,frame,identities);
            if(container != null)
            {
               discoverMasks(container);
               i = 0;
               while(i < container.numChildren)
               {
                  child = container.getChildAt(i);
                  if(!(isMask(container,child) || excluded(child)))
                  {
                     mDrawParents[child] = Matrix(mDrawMatrices[source]).clone();
                     captureMatrix(child);
                     depthKey = getQualifiedClassName(child) + "|" + (child.name != null && child.name.length > 0 && child.name.indexOf("instance") != 0 ? child.name : "@" + i);
                     if(identities[child] !== undefined)
                     {
                        id = int(identities[child]);
                     }
                     else if(depths[depthKey] !== undefined)
                     {
                        id = int(depths[depthKey]);
                     }
                     else
                     {
                        id = int(node.children.length);
                        childNode = makeNode(child,childPath(path,child,i),false,requiresSamples(child) && !(option("clipMasks",path) && TimelineMasks.clip(container,child) != null));
                        node.children.push(childNode);
                     }
                     identities[child] = id;
                     depths[depthKey] = id;
                     childNode = node.children[id];
                     assignContext(child,childPath(path,child,i));
                     state = new ArtChildState();
                     state.child = id;
                     state.matrix = child.transform.matrix.clone();
                     state.alpha = child.alpha;
                     state.visible = child.visible;
                     state.blendMode = child.blendMode;
                     state.colorTransform = child.transform.colorTransform;
                     state.frame = index % childNode.totalFrames;
                     state.filterState = filterState(childNode,child.filters);
                     if(option("clipMasks",path))
                     {
                        state.parentClip = TimelineMasks.clip(container,child);
                     }
                     frame.children.push(state);
                     if(positive(state.colorTransform))
                     {
                        childNode.wantsSilhouette = true;
                     }
                     if((requiresSamples(child) || childNode.kind == "static" || mSamples[childNode] != null) && !childNode.barFill && childNode.kind != "text" && !(option("stillChildren",path) && (child is DisplayObjectContainer || child is Shape) && maxFrames(child) == 1 && child.filters.length == 0 && child.mask == null) && !(child is DisplayObjectContainer && containsText(DisplayObjectContainer(child))))
                     {
                        if(childNode.kind == "static")
                        {
                           childNode.kind = "flipbook";
                           childNode.totalFrames = node.frames.length;
                           childNode.authoredFrames = node.frames.length;
                           childNode.frames.length = node.frames.length;
                           mSamples[childNode] = {};
                           mSampleCounts[childNode] = 0;
                        }
                        if(childNode.kind == "flipbook" && mSamples[childNode] != null)
                        {
                           state.frame = index;
                           signature = pixelsSignature(child,index);
                           samples = mSamples[childNode];
                           sample = samples[signature];
                           if(sample == null)
                           {
                              sample = new ArtFrame();
                              samples[signature] = sample;
                              mSampleCounts[childNode] = int(mSampleCounts[childNode]) + 1;
                              rememberSample(childNode,sample,source,child,childPath(path,child,i),index,i);
                           }
                           Object(mSampleBakes[sample]).scales.push(scaleOf(child));
                           childNode.frames[index] = sample;
                        }
                     }
                  }
                  i = i + 1;
               }
            }
         }
         if(index + 1 < node.frames.length)
         {
            next = function():void
            {
               record(node,source,path,index + 1,identities,depths);
            };
            mJobs.unshift(next);
         }
         else
         {
            mJobs.unshift(function():void
            {
               bakeSamples(node);
            });
         }
      }
      
      private function rememberSample(node:ArtNode, frame:ArtFrame, parent:DisplayObject, source:DisplayObject, path:String, index:int, depth:int) : void
      {
         mSampleBakes[frame] = {
            "node":node,
            "frame":frame,
            "parent":parent,
            "path":path,
            "index":index,
            "depth":depth,
            "scales":[],
            "matrix":drawMatrix(source),
            "state":rememberTree(source)
         };
      }
      
      private function bakeSamples(node:ArtNode) : void
      {
         var child:ArtNode;
         var sample:Object;
         var frame:ArtFrame;
         mJobs.push(function():void
         {
            finishSamples(node);
         });
         for each(child in node.children)
         {
            if(mSamples[child] != null)
            {
               for each(frame in mSamples[child])
               {
                  sample = mSampleBakes[frame];
                  if(sample != null)
                  {
                     queueSample(sample);
                  }
               }
            }
         }
      }
      
      private function queueSample(sample:Object) : void
      {
         mJobs.push(function():void
         {
            var constructed:Boolean;
            var parent:DisplayObject = sample.parent;
            var clip:MovieClip = parent as MovieClip;
            var target:int = clip != null ? int(sample.index) % clip.totalFrames + 1 : 1;
            rememberTouched(parent);
            if(clip != null)
            {
               clip.gotoAndStop(target);
            }
            constructed = constructChildren(parent) && (clip == null || clip.currentFrame == target);
            stopTree(parent);
            if(mDriver != null && !constructed)
            {
               mWaitingForFrame = true;
               mCapture = function():void
               {
                  bakeSample(sample);
               };
            }
            else
            {
               bakeSample(sample);
            }
         });
      }
      
      private function bakeSample(sample:Object) : void
      {
         var _loc4_:Vector.<DisplayObject> = undefined;
         var _loc7_:int = 0;
         var _loc2_:DisplayObjectContainer = sample.parent as DisplayObjectContainer;
         constructChildren(_loc2_);
         var _loc8_:DisplayObject = int(sample.depth) < 0 ? _loc2_ : _loc2_.getChildAt(int(sample.depth));
         rememberTouched(_loc8_);
         restoreTree(_loc8_,sample.state);
         constructTree(_loc8_);
         stopTree(_loc8_);
         mDrawMatrices[_loc8_] = Matrix(sample.matrix).clone();
         assignContext(_loc8_,sample.path);
         var _loc5_:Array = sample.scales;
         _loc5_.sort(16);
         var _loc3_:int = _loc5_.length / 2;
         var _loc6_:Number = _loc5_.length % 2 == 0 ? (Number(_loc5_[_loc3_ - 1]) + Number(_loc5_[_loc3_])) / 2 : Number(_loc5_[_loc3_]);
         if(int(sample.depth) < 0)
         {
            _loc4_ = new Vector.<DisplayObject>(0);
            _loc7_ = 0;
            while(_loc7_ < _loc2_.numChildren)
            {
               _loc4_.push(_loc2_.getChildAt(_loc7_));
               _loc7_++;
            }
         }
         scheduleBake(sample.node,_loc8_,sample.path,sample.index,sample.frame,_loc4_,_loc6_);
         delete mSampleBakes[sample.frame];
      }
      
      private function finishSamples(node:ArtNode) : void
      {
         var _loc2_:ArtNode = null;
         var _loc3_:ArtFrame = null;
         for each(_loc2_ in node.children)
         {
            if(mSampleCounts[_loc2_] == 1)
            {
               _loc3_ = null;
               for each(_loc3_ in _loc2_.frames)
               {
                  if(_loc3_ != null)
                  {
                     break;
                  }
               }
               if(_loc3_ != null)
               {
                  _loc2_.cell = _loc3_.cell;
                  _loc2_.kind = "static";
                  _loc2_.frames.length = 0;
                  _loc2_.totalFrames = _loc2_.authoredFrames = 1;
               }
            }
         }
      }
      
      private function recordGraphics(node:ArtNode, source:DisplayObject, path:String, index:int, frame:ArtFrame, identities:Dictionary) : void
      {
         var _loc12_:int = 0;
         var _loc8_:ArtNode = null;
         var _loc11_:Sprite = source as Sprite;
         if(_loc11_ == null || _loc11_.graphics.readGraphicsData(false).length == 0)
         {
            return;
         }
         if(identities[source] !== undefined)
         {
            _loc12_ = int(identities[source]);
         }
         else
         {
            _loc12_ = int(node.children.length);
            _loc8_ = new ArtNode();
            _loc8_.name = "@graphics";
            _loc8_.kind = "flipbook";
            _loc8_.totalFrames = _loc8_.authoredFrames = node.frames.length;
            _loc8_.frames.length = node.frames.length;
            node.children.push(_loc8_);
            identities[source] = _loc12_;
            mSamples[_loc8_] = {};
            mSampleCounts[_loc8_] = 0;
         }
         _loc8_ = node.children[_loc12_];
         var _loc10_:Object = mSamples[_loc8_];
         var _loc7_:String = JSON.stringify(_loc11_.graphics.readGraphicsData(false));
         var _loc9_:ArtFrame = _loc10_[_loc7_];
         if(_loc9_ == null)
         {
            _loc9_ = new ArtFrame();
            _loc10_[_loc7_] = _loc9_;
            mSampleCounts[_loc8_] = int(mSampleCounts[_loc8_]) + 1;
            rememberSample(_loc8_,_loc9_,source,source,path + ".@graphics",index,-1);
         }
         Object(mSampleBakes[_loc9_]).scales.push(scaleOf(source));
         _loc8_.frames[index] = _loc9_;
         var _loc13_:ArtChildState = new ArtChildState();
         _loc13_.child = _loc12_;
         _loc13_.matrix = new Matrix();
         _loc13_.alpha = 1;
         _loc13_.visible = true;
         _loc13_.blendMode = "normal";
         _loc13_.colorTransform = new ColorTransform();
         _loc13_.frame = index;
         frame.children.push(_loc13_);
      }
      
      private function pixelsSignature(source:DisplayObject, frame:int) : String
      {
         var _loc6_:int = 0;
         var _loc3_:BakedPicture = source.mask != null ? inPlaceBake(source,null,false,mScale) : StarlingRaster.bake(source,mScale);
         if(_loc3_ == null)
         {
            return "refused:" + frame;
         }
         var _loc7_:* = 2166136261;
         var _loc5_:Vector.<uint> = _loc3_.bitmap.getVector(_loc3_.bitmap.rect);
         _loc6_ = 0;
         while(_loc6_ < _loc5_.length)
         {
            _loc7_ ^= _loc5_[_loc6_];
            _loc7_ += (_loc7_ << 1) + (_loc7_ << 4) + (_loc7_ << 7) + (_loc7_ << 8) + (_loc7_ << 24);
            _loc6_++;
         }
         var _loc4_:String = _loc3_.pixelScale + ":" + _loc3_.bitmap.width + ":" + _loc3_.bitmap.height + ":" + _loc3_.originX + ":" + _loc3_.originY + ":" + _loc7_;
         _loc3_.dispose();
         return _loc4_;
      }
      
      private function assignContext(source:DisplayObject, path:String) : void
      {
         var _loc3_:String = null;
         var _loc4_:DisplayObject = source;
         var _loc5_:String = "";
         while(_loc4_ != null)
         {
            _loc3_ = getQualifiedClassName(_loc4_);
            if(_loc3_.indexOf("flash.") != 0)
            {
               break;
            }
            if(_loc4_.parent == null)
            {
               if(sAnonymous[_loc4_] == null)
               {
                  sAnonymous[_loc4_] = ++sNextAnonymous;
               }
               _loc3_ = "anonymous:" + sAnonymous[_loc4_];
               break;
            }
            _loc5_ = "." + _loc4_.parent.getChildIndex(_loc4_) + _loc5_;
            _loc4_ = _loc4_.parent;
         }
         mContexts[source] = {
            "symbol":_loc3_,
            "path":_loc5_,
            "original":path
         };
      }
      
      private function scheduleBake(node:ArtNode, source:DisplayObject, path:String, frame:int, target:ArtFrame, hidden:Vector.<DisplayObject> = null, scale:Number = NaN) : void
      {
         var content:String;
         var pixelScale:Number = isNaN(scale) ? scaleOf(source,node.barFill) : scale;
         if(mDrawMatrices[source] == null)
         {
            captureMatrix(source);
         }
         content = contentKey(source,path,frame,pixelScale);
         mJobs.push(function():void
         {
            var _loc3_:BakedPicture = null;
            var _loc4_:BakedPicture = null;
            var _loc5_:String = null;
            var _loc2_:BakedCell = null;
            var _loc6_:DisplayObject = null;
            if(target == null && node.kind != "static")
            {
               return;
            }
            var _loc1_:BakedPages = node.kind == "flipbook" ? mFramePages : mPages;
            var _loc8_:String = content;
            if(node.barFill)
            {
               _loc8_ += "|fullFill";
            }
            var _loc7_:BakedCell = _loc1_.acquire(_loc8_);
            if(_loc7_ == null)
            {
               if(source is DisplayObjectContainer)
               {
                  if(hidden == null)
                  {
                     hidden = new Vector.<DisplayObject>(0);
                  }
                  collectExcluded(DisplayObjectContainer(source),hidden);
               }
               _loc3_ = source.mask != null || node.barFill ? inPlaceBake(source,hidden,node.barFill,pixelScale) : StarlingRaster.bake(source,pixelScale,hidden);
               if(_loc3_ != null)
               {
                  _loc4_ = copyBake(_loc3_);
                  _loc7_ = _loc1_.add(_loc8_,_loc3_,true);
                  if(_loc7_ != null)
                  {
                     sPixels[_loc7_] = _loc4_;
                  }
                  else
                  {
                     _loc4_.dispose();
                  }
               }
            }
            node.hold(_loc7_,_loc1_);
            if(target != null)
            {
               target.cell = _loc7_;
            }
            else
            {
               node.cell = _loc7_;
            }
            if(target == null && (source.name == "hit" || isButtonState(source) || _loc7_ != null && _loc7_.isEmpty && source is Shape))
            {
               _loc5_ = _loc8_ + "|hit";
               _loc2_ = _loc1_.acquire(_loc5_);
               if(_loc2_ == null)
               {
                  _loc6_ = hitGeometry(source,true,source.name == "hit");
                  _loc3_ = StarlingRaster.bake(_loc6_,pixelScale);
                  if(_loc3_ != null)
                  {
                     _loc2_ = _loc1_.add(_loc5_,_loc3_,true);
                  }
               }
               node.hitCell = node.hold(_loc2_,_loc1_);
            }
            if(_loc7_ == null)
            {
               mFailures = mFailures + 1;
               node.failures++;
            }
         });
      }
      
      private function scaleOf(source:DisplayObject, fullFill:Boolean = false) : Number
      {
         return mHudScale * BakeScale.magnitude(drawMatrix(source,fullFill));
      }
      
      private function captureMatrix(source:DisplayObject) : void
      {
         var _loc2_:DisplayObject = null;
         if(mDrawParents[source] == null)
         {
            _loc2_ = source.parent;
            if(_loc2_ == null)
            {
               throw new Error("HUD draw transform unavailable: " + source.name);
            }
            if(mDrawMatrices[_loc2_] == null)
            {
               captureMatrix(_loc2_);
            }
            mDrawParents[source] = Matrix(mDrawMatrices[_loc2_]).clone();
         }
         var _loc3_:Matrix = source.transform.matrix.clone();
         _loc3_.concat(mDrawParents[source]);
         mDrawMatrices[source] = _loc3_;
      }
      
      private function drawMatrix(source:DisplayObject, fullFill:Boolean = false) : Matrix
      {
         if(mDrawMatrices[source] == null)
         {
            captureMatrix(source);
         }
         if(!fullFill)
         {
            return Matrix(mDrawMatrices[source]).clone();
         }
         var _loc4_:Matrix = source.transform.matrix.clone();
         var _loc3_:Number = Math.sqrt(_loc4_.a * _loc4_.a + _loc4_.b * _loc4_.b);
         if(_loc3_ > 0)
         {
            _loc4_.a /= _loc3_;
            _loc4_.b /= _loc3_;
         }
         _loc4_.concat(mDrawParents[source]);
         return _loc4_;
      }
      
      private function contentKey(source:DisplayObject, path:String, frame:int, scale:Number = NaN) : String
      {
         var _loc5_:Object = mContexts[source];
         return (_loc5_ != null ? _loc5_.symbol : mSymbol) + "|" + (_loc5_ != null ? _loc5_.path + path.substr(String(_loc5_.original).length) : path) + "|" + frame + "|" + BakedPages.scaleKey(isNaN(scale) ? scaleOf(source) : scale);
      }
      
      private function hitGeometry(source:DisplayObject, root:Boolean, ignoreVisibility:Boolean) : DisplayObject
      {
         var _loc7_:Vector.<IGraphicsData> = undefined;
         var _loc5_:IGraphicsData = null;
         var _loc13_:DisplayObject = null;
         var _loc12_:DisplayObject = null;
         var _loc8_:int = 0;
         var _loc11_:Rectangle = null;
         var _loc9_:Sprite = new Sprite();
         var _loc4_:DisplayObjectContainer = source as DisplayObjectContainer;
         var _loc10_:Sprite = source as Sprite;
         var _loc6_:Shape = source as Shape;
         if(!root)
         {
            _loc9_.transform.matrix = source.transform.matrix;
         }
         if(_loc6_ != null || _loc10_ != null)
         {
            _loc7_ = _loc6_ != null ? _loc6_.graphics.readGraphicsData(false) : _loc10_.graphics.readGraphicsData(false);
            for each(_loc5_ in _loc7_)
            {
               if(_loc5_ is IGraphicsFill)
               {
                  opaqueFill(_loc5_ as IGraphicsFill);
               }
               else if(_loc5_ is GraphicsStroke)
               {
                  opaqueFill(GraphicsStroke(_loc5_).fill);
               }
            }
            _loc9_.graphics.drawGraphicsData(_loc7_);
         }
         else if(source is TextField || source is Bitmap)
         {
            _loc11_ = source.getBounds(source);
            _loc9_.graphics.beginFill(16777215);
            _loc9_.graphics.drawRect(_loc11_.x,_loc11_.y,_loc11_.width,_loc11_.height);
            _loc9_.graphics.endFill();
         }
         if(_loc4_ != null)
         {
            _loc8_ = 0;
            while(_loc8_ < _loc4_.numChildren)
            {
               _loc13_ = _loc4_.getChildAt(_loc8_);
               if(!(!ignoreVisibility && !_loc13_.visible || excluded(_loc13_) || isMask(_loc4_,_loc13_)))
               {
                  _loc12_ = hitGeometry(_loc13_,false,ignoreVisibility);
                  _loc9_.addChild(_loc12_);
               }
               _loc8_++;
            }
         }
         return _loc9_;
      }
      
      private function inheritSilhouettes(node:ArtNode, inherited:Boolean) : void
      {
         var _loc3_:ArtNode = null;
         node.wantsSilhouette = inherited || node.wantsSilhouette;
         for each(_loc3_ in node.children)
         {
            inheritSilhouettes(_loc3_,node.wantsSilhouette);
         }
      }
      
      private function inPlaceBake(source:DisplayObject, hidden:Vector.<DisplayObject>, fullFill:Boolean, scale:Number = NaN) : BakedPicture
      {
         var _loc6_:BakedPicture = null;
         var _loc8_:BakedPicture = null;
         var _loc14_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc21_:Matrix = null;
         var _loc20_:DisplayObject = null;
         var _loc9_:Number = NaN;
         var _loc24_:Rectangle = null;
         var _loc23_:int = 0;
         var _loc11_:int = 0;
         var _loc25_:int = 0;
         var _loc17_:int = 0;
         var _loc13_:Matrix = null;
         var _loc12_:Rectangle = null;
         var _loc15_:BitmapData = null;
         var _loc5_:DisplayObjectContainer = source.parent;
         if(_loc5_ == null)
         {
            return StarlingRaster.bake(source,isNaN(scale) ? scaleOf(source,fullFill) : scale,hidden);
         }
         var _loc16_:DisplayObject = source.mask;
         while(_loc16_ != null && !_loc5_.contains(_loc16_) && _loc5_.parent != null)
         {
            _loc5_ = _loc5_.parent;
         }
         var _loc22_:Vector.<DisplayObject> = hidden != null ? hidden.concat() : new Vector.<DisplayObject>(0);
         hideOthers(_loc5_,source,_loc16_,_loc22_);
         var _loc10_:ColorTransform = source.transform.colorTransform;
         var _loc19_:Boolean = source.visible;
         var _loc7_:Number = source.scaleX;
         try
         {
            source.visible = true;
            source.transform.colorTransform = new ColorTransform();
            if(fullFill)
            {
               source.scaleX = 1;
            }
            _loc18_ = _loc14_ = isNaN(scale) ? scaleOf(source,fullFill) : scale;
            _loc21_ = source.transform.matrix;
            _loc20_ = source.parent;
            while(_loc20_ != null && _loc20_ != _loc5_)
            {
               _loc21_.concat(_loc20_.transform.matrix);
               _loc20_ = _loc20_.parent;
            }
            _loc9_ = _loc14_ / BakeScale.magnitude(_loc21_);
            _loc21_.invert();
            _loc6_ = StarlingRaster.bake(_loc5_,_loc9_,_loc22_,false);
            if(_loc6_ == null)
            {
               return null;
            }
            if(_loc6_.empty)
            {
               _loc6_.pixelScale = _loc14_;
               return _loc6_;
            }
            _loc9_ = _loc6_.pixelScale;
            _loc24_ = localBounds(_loc6_,_loc21_);
            _loc23_ = Math.floor(_loc24_.x * _loc14_) - 1;
            _loc11_ = Math.floor(_loc24_.y * _loc14_) - 1;
            _loc25_ = Math.ceil(_loc24_.right * _loc14_) - _loc23_ + 1;
            _loc17_ = Math.ceil(_loc24_.bottom * _loc14_) - _loc11_ + 1;
            if(_loc25_ > 1024 || _loc17_ > 1024)
            {
               _loc14_ *= (1024 - 4) / Math.max(_loc25_,_loc17_);
               _loc23_ = Math.floor(_loc24_.x * _loc14_) - 1;
               _loc11_ = Math.floor(_loc24_.y * _loc14_) - 1;
               _loc25_ = Math.ceil(_loc24_.right * _loc14_) - _loc23_ + 1;
               _loc17_ = Math.ceil(_loc24_.bottom * _loc14_) - _loc11_ + 1;
            }
            _loc8_ = new BakedPicture();
            _loc8_.bitmap = new BitmapData(Math.max(2,_loc25_),Math.max(2,_loc17_),true,0);
            _loc13_ = new Matrix(1 / _loc9_,0,0,1 / _loc9_,-_loc6_.originX / _loc9_,-_loc6_.originY / _loc9_);
            _loc13_.concat(_loc21_);
            _loc13_.scale(_loc14_,_loc14_);
            _loc13_.translate(-_loc23_,-_loc11_);
            _loc8_.bitmap.draw(_loc6_.bitmap,_loc13_,null,null,null,true);
            _loc6_.dispose();
            _loc12_ = _loc8_.bitmap.getColorBoundsRect(4278190080,0,false);
            if(_loc12_.width == 0 || _loc12_.height == 0)
            {
               _loc12_.setTo(0,0,1,1);
            }
            _loc15_ = new BitmapData(_loc12_.width + 2,_loc12_.height + 2,true,0);
            _loc15_.copyPixels(_loc8_.bitmap,_loc12_,new Point(1,1));
            _loc8_.bitmap.dispose();
            _loc8_.bitmap = _loc15_;
            _loc8_.originX = -_loc23_ - _loc12_.x + 1;
            _loc8_.originY = -_loc11_ - _loc12_.y + 1;
            _loc8_.pixelScale = _loc14_;
            StarlingRaster.limit(_loc8_,_loc18_);
            return _loc8_;
         }
         finally
         {
            if(fullFill)
            {
               source.scaleX = _loc7_;
            }
            source.transform.colorTransform = _loc10_;
            source.visible = _loc19_;
         }
         return null;
      }
      
      private function hideOthers(parent:DisplayObjectContainer, source:DisplayObject, mask:DisplayObject, hide:Vector.<DisplayObject>) : void
      {
         var _loc6_:int = 0;
         var _loc7_:DisplayObject = null;
         var _loc5_:DisplayObjectContainer = null;
         _loc6_ = 0;
         while(_loc6_ < parent.numChildren)
         {
            _loc7_ = parent.getChildAt(_loc6_);
            if(!(_loc7_ == source || _loc7_ == mask || isMask(parent,_loc7_)))
            {
               _loc5_ = _loc7_ as DisplayObjectContainer;
               if(_loc5_ != null && (_loc5_.contains(source) || mask != null && _loc5_.contains(mask)))
               {
                  hideOthers(_loc5_,source,mask,hide);
               }
               else
               {
                  hide.push(_loc7_);
               }
            }
            _loc6_++;
         }
      }
      
      private function barRoot(source:DisplayObject, path:String) : Boolean
      {
         return /^(HP_bar(?:_delta|_invincible)?|mana_bar(?:_delta)?|xp_bar(?:_delta)?|buster_bar|hpBar)$/.test(source.name);
      }
      
      private function isBar(source:DisplayObject, path:String) : Boolean
      {
         var _loc3_:DisplayObjectContainer = source as DisplayObjectContainer;
         if(barRoot(source,path))
         {
            return _loc3_ == null || _loc3_.getChildByName("bar") == null;
         }
         var _loc4_:int = path.lastIndexOf(".");
         return source.name == "bar" && source.parent != null && barRoot(source.parent,_loc4_ >= 0 ? path.substr(0,_loc4_) : "");
      }
      
      private function rememberTouched(source:DisplayObject) : void
      {
         var _loc3_:int = 0;
         if(mTouched[source] == null)
         {
            mTouched[source] = rememberTree(source,false);
         }
         var _loc2_:DisplayObjectContainer = source as DisplayObjectContainer;
         if(_loc2_ != null)
         {
            _loc3_ = 0;
            while(_loc3_ < _loc2_.numChildren)
            {
               rememberTouched(_loc2_.getChildAt(_loc3_));
               _loc3_++;
            }
         }
      }
      
      private function seekTree(source:DisplayObject, frame:int) : Boolean
      {
         var _loc5_:int = 0;
         rememberTouched(source);
         var _loc6_:MovieClip = source as MovieClip;
         var _loc7_:int = _loc6_ != null ? frame % _loc6_.totalFrames + 1 : 1;
         if(_loc6_ != null)
         {
            _loc6_.gotoAndStop(_loc7_);
         }
         var _loc4_:Boolean = _loc6_ == null || _loc6_.currentFrame == _loc7_;
         var _loc3_:DisplayObjectContainer = source as DisplayObjectContainer;
         if(_loc3_ != null)
         {
            _loc5_ = 0;
            while(_loc5_ < _loc3_.numChildren)
            {
               _loc4_ = seekTree(_loc3_.getChildAt(_loc5_),frame) && _loc4_;
               _loc5_++;
            }
         }
         return _loc4_;
      }
      
      private function constructTree(source:DisplayObject) : Boolean
      {
         rememberTouched(source);
         var _loc2_:MovieClip = source as MovieClip;
         var _loc3_:int = _loc2_ != null ? Math.max(1,_loc2_.currentFrame) : 1;
         if(_loc2_ != null)
         {
            _loc2_.gotoAndStop(_loc3_);
         }
         return constructChildren(source) && (_loc2_ == null || _loc2_.currentFrame == _loc3_);
      }
      
      private function constructChildren(source:DisplayObject) : Boolean
      {
         var _loc4_:int = 0;
         var _loc2_:DisplayObjectContainer = source as DisplayObjectContainer;
         var _loc3_:Boolean = true;
         if(_loc2_ != null)
         {
            _loc4_ = 0;
            while(_loc4_ < _loc2_.numChildren)
            {
               _loc3_ = constructTree(_loc2_.getChildAt(_loc4_)) && _loc3_;
               _loc4_++;
            }
         }
         return _loc3_;
      }
      
      private function hasMasks(parent:DisplayObjectContainer) : Boolean
      {
         var _loc2_:int = 0;
         if(parent == null)
         {
            return false;
         }
         discoverMasks(parent);
         _loc2_ = 0;
         while(_loc2_ < parent.numChildren)
         {
            if(isMask(parent,parent.getChildAt(_loc2_)))
            {
               return true;
            }
            _loc2_++;
         }
         return false;
      }
      
      private function discoverMasks(source:DisplayObjectContainer) : void
      {
         var _loc4_:int = 0;
         var _loc5_:DisplayObject = null;
         var _loc2_:Rectangle = null;
         var _loc6_:BakedPicture = null;
         var _loc3_:Boolean = false;
         _loc4_ = 0;
         while(_loc4_ < source.numChildren)
         {
            _loc5_ = source.getChildAt(_loc4_);
            if(TimelineMasks.isMask(source,_loc5_))
            {
               mMasks[_loc5_] = true;
            }
            else if(!(!(_loc5_ is Shape) || mMaskProbed[_loc5_] || !_loc5_.visible || _loc5_.alpha <= 0))
            {
               mMaskProbed[_loc5_] = true;
               _loc2_ = _loc5_.getBounds(_loc5_);
               if(!(_loc2_.width <= 0 || _loc2_.height <= 0))
               {
                  _loc6_ = StarlingRaster.bake(_loc5_,scaleOf(_loc5_));
                  if(_loc6_ != null)
                  {
                     _loc3_ = !_loc6_.empty;
                     _loc6_.dispose();
                     if(_loc3_)
                     {
                        _loc6_ = inPlaceBake(_loc5_,null,false);
                        if(_loc6_ != null)
                        {
                           if(_loc6_.empty)
                           {
                              mMasks[_loc5_] = true;
                           }
                           _loc6_.dispose();
                        }
                     }
                  }
               }
            }
            _loc4_++;
         }
      }
      
      private function isMask(source:DisplayObjectContainer, child:DisplayObject) : Boolean
      {
         var _loc3_:int = 0;
         if(mMasks[child])
         {
            return true;
         }
         _loc3_ = 0;
         while(_loc3_ < source.numChildren)
         {
            if(source.getChildAt(_loc3_).mask == child)
            {
               return true;
            }
            _loc3_++;
         }
         return false;
      }
   }
}

