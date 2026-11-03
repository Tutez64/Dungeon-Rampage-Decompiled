package Brain.Starling
{
   import Brain.Facade.Facade;
   import Brain.Logger.Logger;
   import Brain.Starling.SwfConverter.BakeScheduler;
   import Brain.Starling.SwfConverter.BakedPages;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.display3D.Context3D;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   import starling.animation.Juggler;
   import starling.core.Starling;
   import starling.display.DisplayObject;
   import starling.display.Sprite;
   import starling.display.Stage;
   import starling.utils.Color;
   import starling.utils.Pool;
   import starling.utils.SystemUtil;
   
   public class StarlingLayerManager
   {
      
      protected static const LAYER_BACKGROUND:String = "background";
      
      protected static const LAYER_GROUND:String = "ground";
      
      protected static const LAYER_SORTED:String = "sorted";
      
      protected static const LAYER_FOREGROUND:String = "foreground";
      
      protected static const LAYER_OVERFADE:String = "overfade";
      
      protected static const LAYER_TWEEN:String = "tween";
      
      protected static const LAYER_STARLING_OVERLAY:String = "starlingOverlay";
      
      protected static const LAYER_HUD:String = "hud";
      
      protected var mStarling:Starling;
      
      protected var mDBFacade:Facade;
      
      protected var mSourceCache:StarlingSourceCache;
      
      private var mWorldCameraOffsetX:Number = 0;
      
      private var mWorldCameraOffsetY:Number = 0;
      
      protected var mLayerMap:Dictionary = new Dictionary();
      
      protected var mLayers:Vector.<StarlingLayer>;
      
      protected var mOnContextReady:Function;
      
      public function StarlingLayerManager(inFacade:Facade, stage:flash.display.Stage, designWidth:Number, designHeight:Number, onContextReady:Function = null)
      {
         super();
         mDBFacade = inFacade;
         mOnContextReady = onContextReady;
         mSourceCache = new StarlingSourceCache();
         mLayers = new Vector.<StarlingLayer>();
         init(stage,designWidth,designHeight);
      }
      
      private static function keepAddOrder(a:DisplayObject, b:DisplayObject) : int
      {
         return 0;
      }
      
      public function get worldCameraOffsetX() : Number
      {
         return mWorldCameraOffsetX;
      }
      
      public function get worldCameraOffsetY() : Number
      {
         return mWorldCameraOffsetY;
      }
      
      public function init(stage:flash.display.Stage, designWidth:Number, designHeight:Number) : void
      {
         mStarling = new Starling(starling.display.Sprite,stage);
         mStarling.stage.stageWidth = designWidth;
         mStarling.stage.stageHeight = designHeight;
         mStarling.stage.color = 0;
         mStarling.shareContext = true;
         mStarling.addEventListener("rootCreated",onRootCreated);
      }
      
      public function isReady() : Boolean
      {
         return mStarling.isStarted;
      }
      
      public function get starlingInstance() : Starling
      {
         return mStarling;
      }
      
      public function toggleStats() : void
      {
         mStarling.showStats = !mStarling.showStats;
      }
      
      public function toggleStatsAt(horizontalAlign:String = "right", verticalAlign:String = "center", scale:Number = 5) : void
      {
         if(mStarling.showStats)
         {
            mStarling.showStats = false;
         }
         else
         {
            mStarling.showStatsAt(horizontalAlign,verticalAlign,scale);
         }
      }
      
      public function cleanLayers() : void
      {
         for each(var _loc1_:StarlingLayer in mLayers)
         {
            if(!(_loc1_.sortIndex == 36 || _loc1_.sortIndex == 64))
            {
               _loc1_.clean();
            }
         }
      }
      
      public function get layers() : Vector.<StarlingLayer>
      {
         return mLayers;
      }
      
      public function get starlingStage() : starling.display.Stage
      {
         return mStarling.stage;
      }
      
      public function get viewPort() : Rectangle
      {
         return mStarling.viewPort;
      }
      
      public function get juggler() : Juggler
      {
         return mStarling.juggler;
      }
      
      public function getLayer(inIndex:int) : StarlingLayer
      {
         return mLayerMap[inIndex];
      }
      
      private function onRootCreated(event:Object) : void
      {
         Logger.info("StarlingLayerManager: On root created! Start layer initialization...");
         configureBackBuffer();
         mStarling.addEventListener("context3DCreate",onContextRestored);
         var _loc2_:flash.display.Sprite = mStarling.nativeOverlay;
         var _loc4_:flash.display.Sprite = mDBFacade.scalingRoot;
         _loc2_.scaleX = _loc4_.scaleX;
         _loc2_.scaleY = _loc4_.scaleY;
         _loc2_.x = _loc4_.x;
         _loc2_.y = _loc4_.y;
         while(_loc4_.numChildren > 0)
         {
            _loc2_.addChild(_loc4_.getChildAt(0));
         }
         mDBFacade.stageRef.removeChild(mDBFacade.scalingRoot);
         mDBFacade.scalingRoot = _loc2_;
         Logger.info("StarlingLayerManager: NativeOverlay swap complete!");
         var _loc3_:Boolean = mDBFacade.featureFlags.getFlagValue("bake-static-layers");
         createLayer(5,"ground","none").bakeStaticImages = _loc3_;
         createLayer(10,"background","normal",false,StarlingLayer.compareByY).bakeStaticImages = _loc3_;
         createLayer(20,"sorted","normal",true);
         createLayer(30,"foreground","normal");
         createLayer(46,"overfade","normal");
         createLayer(50,"tween","normal",false,null,true);
         BakeScheduler.enabled = mDBFacade.featureFlags.getFlagValue("starling-overlays") || mDBFacade.featureFlags.getFlagValue("starling-hud");
         Logger.info("StarlingLayerManager: Game layer instantiated!");
         mStarling.start();
         Logger.info("StarlingLayerManager: Starling started!");
         if(mOnContextReady != null)
         {
            mOnContextReady();
            mOnContextReady = null;
         }
      }
      
      private function createLayer(inSortIndex:int, inName:String, inBlendMode:String, inSortEveryFrame:Boolean = false, inCustomSortFunction:Function = null, inScreenSpace:Boolean = false) : StarlingLayer
      {
         var _loc8_:StarlingLayer = new StarlingLayer(inSortIndex,inName,inBlendMode,inSortEveryFrame,inCustomSortFunction,inScreenSpace);
         var _loc7_:starling.display.Sprite = mStarling.root as starling.display.Sprite;
         mLayerMap[inSortIndex] = _loc8_;
         mLayers.push(_loc8_);
         _loc7_.addChild(_loc8_);
         return _loc8_;
      }
      
      public function get starlingOverlayLayer() : StarlingLayer
      {
         return overlayLayer(36,"starlingOverlay",keepAddOrder,false);
      }
      
      public function get hudLayer() : StarlingLayer
      {
         return overlayLayer(64,"hud",null,true);
      }
      
      private function overlayLayer(sortIndex:int, name:String, sort:Function, screenSpace:Boolean) : StarlingLayer
      {
         var _loc7_:StarlingLayer = mLayerMap[sortIndex];
         var _loc6_:starling.display.Sprite = mStarling != null ? mStarling.root as starling.display.Sprite : null;
         if(_loc7_ != null || _loc6_ == null)
         {
            return _loc7_;
         }
         _loc7_ = new StarlingLayer(sortIndex,name,"normal",false,sort,screenSpace);
         var _loc5_:int = 0;
         while(_loc5_ < _loc6_.numChildren && _loc6_.getChildAt(_loc5_) is StarlingLayer && StarlingLayer(_loc6_.getChildAt(_loc5_)).sortIndex < sortIndex)
         {
            _loc5_++;
         }
         _loc6_.addChildAt(_loc7_,_loc5_);
         mLayerMap[sortIndex] = _loc7_;
         mLayers.push(_loc7_);
         BakedPages.attach(mStarling);
         return _loc7_;
      }
      
      private function onContextRestored(event:Object) : void
      {
         configureBackBuffer();
         BakedPages.restoreAll();
         if(mSourceCache != null)
         {
            mSourceCache.restoreSources();
         }
      }
      
      private function configureBackBuffer() : void
      {
         var _loc2_:Context3D = mStarling.context;
         if(_loc2_ == null)
         {
            return;
         }
         var _loc1_:Rectangle = mStarling.viewPort;
         mStarling.stage3D.x = _loc1_.x;
         mStarling.stage3D.y = _loc1_.y;
         _loc2_.configureBackBuffer(_loc1_.width,_loc1_.height,mStarling.antiAliasing,SystemUtil.supportsDepthAndStencil);
      }
      
      public function syncWorldTransform(worldTransformNode:flash.display.Sprite) : void
      {
         if(!isReady())
         {
            return;
         }
         var _loc5_:Matrix = Pool.getMatrix();
         _loc5_.copyFrom(worldTransformNode.transform.matrix);
         _loc5_.concat(worldTransformNode.parent.transform.matrix);
         var _loc6_:Number = _loc5_.tx;
         var _loc3_:Number = _loc5_.ty;
         var _loc7_:Number = 1 / mStarling.contentScaleFactor;
         if(_loc7_ > 0 && isFinite(_loc7_))
         {
            _loc5_.tx = Math.round(_loc5_.tx / _loc7_) * _loc7_;
            _loc5_.ty = Math.round(_loc5_.ty / _loc7_) * _loc7_;
         }
         mWorldCameraOffsetX = _loc6_ - _loc5_.tx;
         mWorldCameraOffsetY = _loc3_ - _loc5_.ty;
         StarlingLayer.propsCulledLastFrame = 0;
         var _loc4_:Boolean = mDBFacade.featureFlags.getFlagValue("bake-static-layers");
         for each(var _loc8_:StarlingLayer in mLayers)
         {
            if(_loc8_.sortIndex == 5 || _loc8_.sortIndex == 10)
            {
               _loc8_.bakeStaticImages = _loc4_;
            }
            _loc8_.evaluateFrameLayerUpdate(_loc5_);
         }
         Pool.putMatrix(_loc5_);
         if(!mStarling.contextValid)
         {
            return;
         }
         var _loc2_:uint = mStarling.stage.color;
         mStarling.painter.clear(_loc2_,Color.getAlpha(_loc2_));
         mStarling.nextFrame();
         mStarling.painter.present();
      }
      
      public function updateViewPort(rect:Rectangle) : void
      {
         if(mStarling != null)
         {
            mStarling.viewPort = rect;
            configureBackBuffer();
         }
      }
      
      public function get sourceCache() : StarlingSourceCache
      {
         return mSourceCache;
      }
      
      public function markLayerDirty(inLayerIndex:int) : void
      {
         var _loc2_:StarlingLayer = mLayerMap[inLayerIndex];
         if(_loc2_ != null)
         {
            _loc2_.markDirty();
         }
      }
      
      public function destroy() : void
      {
         mOnContextReady = null;
         mStarling.stop(true);
         mStarling.removeEventListener("rootCreated",onRootCreated);
         mStarling.removeEventListener("context3DCreate",onContextRestored);
         BakedPages.disposeAll();
         mStarling = null;
         for each(var _loc1_:StarlingLayer in mLayers)
         {
            _loc1_.destroy();
         }
         mLayers.length = 0;
         mLayerMap.clear();
      }
   }
}

