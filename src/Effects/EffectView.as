package Effects
{
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.StarlingAssetMapper;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Clock.GameClock;
   import Brain.Logger.Logger;
   import Brain.Render.Layer;
   import Brain.Render.MovieClipRenderController;
   import Brain.WorkLoop.LayerWorkComponent;
   import Facade.DBFacade;
   import Floor.FloorView;
   import Starling.SwfFallbackDebug;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.filesystem.File;
   import flash.geom.Matrix;
   import starling.display.Image;
   import starling.extensions.animate.Animation;
   import starling.utils.Pool;
   
   public class EffectView extends FloorView
   {
      
      private var mAssetLoadingComponent:AssetLoadingComponent;
      
      private var mEffect:MovieClip;
      
      private var mEffectClassName:String;
      
      private var mSwfPath:String;
      
      protected var mLoop:Boolean;
      
      private var mShouldBePlaying:ShouldBePlaying;
      
      protected var mAssetLoadedCallback:Function;
      
      private var mPlayRate:Number = 1;
      
      private var mIconInsert:EffectIconInsert;
      
      private var mUseStarling:Boolean;
      
      private var mStarlingRenderer:StarlingEffectRenderer;
      
      private var mStarlingSyncComponent:LayerWorkComponent;
      
      private var mAnchor:DisplayObject;
      
      private var mSortAnchor:DisplayObject;
      
      private var mBehindAnchor:Boolean;
      
      private var mOnStage:Boolean;
      
      private var mFlipX:Boolean = false;
      
      private var mRotationX:Number = 0;
      
      private var mStarlingPurgeStamp:int = -1;
      
      private var mStatusTintColor:uint;
      
      private var mStatusTintAmount:Number = 0;
      
      private var mIsPlaying:Boolean = false;
      
      private var mLastPlayLoop:Boolean;
      
      private var mLastPlayFinishedCallback:Function;
      
      private var mSwfFallbackReason:String = "effect did not attempt the Starling path";
      
      public var artResolvedCallback:Function;
      
      public function EffectView(facade:DBFacade, effectGameObject:EffectGameObject, assetLoadedCallback:Function = null)
      {
         super(facade,effectGameObject,"pool");
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mEffectClassName = effectGameObject.className;
         mSwfPath = effectGameObject.swfPath;
         mAssetLoadedCallback = assetLoadedCallback;
         mIconInsert = effectGameObject.iconInsert;
         var _loc4_:String = starlingUnavailableReason(mSwfPath);
         if(_loc4_ == null)
         {
            mUseStarling = true;
            queueStarlingEffectAssets();
         }
         else
         {
            mSwfFallbackReason = _loc4_;
            mAssetLoadingComponent.getSwfAsset(mSwfPath,assetLoaded);
         }
      }
      
      private static function computeLayerSpaceMatrix(node:DisplayObject) : Matrix
      {
         var _loc5_:Matrix = null;
         var _loc4_:Matrix = null;
         var _loc2_:Matrix = node.transform.matrix;
         if(_loc2_ == null)
         {
            _loc2_ = compose2DMatrix(node);
         }
         else
         {
            _loc5_ = Pool.getMatrix();
            _loc5_.copyFrom(_loc2_);
            _loc2_ = _loc5_;
         }
         var _loc3_:DisplayObject = node.parent;
         while(_loc3_ != null && !(_loc3_ is Layer))
         {
            _loc4_ = _loc3_.transform.matrix;
            if(_loc4_ == null)
            {
               _loc4_ = compose2DMatrix(_loc3_);
            }
            _loc2_.concat(_loc4_);
            _loc3_ = _loc3_.parent;
         }
         return _loc2_;
      }
      
      private static function compose2DMatrix(node:DisplayObject) : Matrix
      {
         var _loc2_:Matrix = Pool.getMatrix();
         _loc2_.createBox(node.scaleX,node.scaleY,node.rotation * 3.141592653589793 / 180,node.x,node.y);
         return _loc2_;
      }
      
      private static function computeLayerSpaceAlpha(node:DisplayObject) : Number
      {
         var _loc3_:Number = 1;
         var _loc2_:DisplayObject = node;
         while(_loc2_ != null && !(_loc2_ is Layer))
         {
            _loc3_ *= _loc2_.alpha;
            _loc2_ = _loc2_.parent;
         }
         return _loc3_;
      }
      
      private static function computeLayerSpaceVisible(node:DisplayObject) : Boolean
      {
         var _loc2_:DisplayObject = node;
         while(_loc2_ != null && !(_loc2_ is Layer))
         {
            if(!_loc2_.visible)
            {
               return false;
            }
            _loc2_ = _loc2_.parent;
         }
         return true;
      }
      
      private function starlingUnavailableReason(swfPath:String) : String
      {
         if(mDBFacade.assetLoadingComponent == null)
         {
            return "no asset loading component";
         }
         if(mDBFacade.starlingLayerManager == null)
         {
            return "no Starling layer manager (Stage3D not up)";
         }
         var _loc2_:Boolean = StarlingAssetMapper.isKnownBiome(StarlingAssetMapper.getBiomeKeyFromPath(swfPath));
         if(!_loc2_ && StarlingAssetMapper.getActorAtlasFile(swfPath,true) == null)
         {
            return "no atlas folder or biome key mapped for the effect SWF path";
         }
         return null;
      }
      
      private function queueStarlingEffectAssets() : void
      {
         var _loc1_:File = StarlingAssetMapper.getActorAtlasFile(mSwfPath,true);
         if(_loc1_ != null)
         {
            mDBFacade.assetLoadingComponent.queueStarlingAssets(StarlingAssetMapper.getActorAtlasKeyFromPath(mSwfPath),onStarlingAtlasLoaded,false,[_loc1_]);
         }
         else if(StarlingAssetMapper.isPropLibraryPath(mSwfPath))
         {
            mDBFacade.assetLoadingComponent.queueStarlingAssetsForProps(mSwfPath,[mEffectClassName],onStarlingAtlasLoaded);
         }
         else
         {
            mDBFacade.assetLoadingComponent.queueStarlingAssetsForPath(mSwfPath,onStarlingAtlasLoaded);
         }
      }
      
      public function prewarmRenderer() : StarlingEffectRenderer
      {
         revalidateStarlingRenderer();
         return mStarlingRenderer;
      }
      
      public function get isArtLoaded() : Boolean
      {
         return mMovieClipRenderer != null || mStarlingRenderer != null;
      }
      
      private function get fallbackCategory() : String
      {
         var _loc1_:EffectGameObject = mParentFloorObject as EffectGameObject;
         return _loc1_ != null && _loc1_.fallbackCategory != null ? _loc1_.fallbackCategory : "EFFECT";
      }
      
      public function get artDurationInSeconds() : Number
      {
         if(mStarlingRenderer != null)
         {
            return mStarlingRenderer.artDurationInSeconds;
         }
         if(mMovieClipRenderer != null)
         {
            return mMovieClipRenderer.durationInSeconds;
         }
         return 0;
      }
      
      public function setIconInsert(iconInsert:EffectIconInsert) : void
      {
         mIconInsert = iconInsert;
         if(mStarlingRenderer != null)
         {
            mStarlingRenderer.clearMarkerContent();
            if(mIconInsert != null)
            {
               loadStarlingIcon();
            }
         }
      }
      
      public function setPlayRate(val:Number) : void
      {
         mPlayRate = val;
         if(mMovieClipRenderer)
         {
            mMovieClipRenderer.playRate = val;
         }
         if(mStarlingRenderer != null)
         {
            mStarlingRenderer.setPlayRate(val);
         }
      }
      
      public function attachToParent(parentRoot:Sprite, behind:Boolean, sortAnchor:DisplayObject = null) : void
      {
         var _loc4_:int = 0;
         mAnchor = parentRoot;
         mSortAnchor = sortAnchor ?? parentRoot;
         mBehindAnchor = behind;
         if(behind)
         {
            parentRoot.addChildAt(mRoot,0);
         }
         else
         {
            parentRoot.addChild(mRoot);
         }
         if(mStarlingRenderer != null)
         {
            _loc4_ = resolveStarlingLayer();
            if(_loc4_ != 0)
            {
               mStarlingRenderer.setLayer(_loc4_);
            }
            syncStarlingTransform();
         }
      }
      
      public function play(loop:Boolean, finishedCallback:Function) : void
      {
         mIsPlaying = true;
         mLastPlayLoop = loop;
         mLastPlayFinishedCallback = finishedCallback;
         revalidateStarlingRenderer();
         if(mStarlingRenderer != null)
         {
            mStarlingRenderer.play(loop,finishedCallback);
            if(mIsPlaying)
            {
               startStarlingSync();
            }
         }
         else if(mMovieClipRenderer)
         {
            mMovieClipRenderer.play(0,loop,finishedCallback);
         }
         else
         {
            mShouldBePlaying = new ShouldBePlaying(loop,finishedCallback);
         }
      }
      
      public function stop() : void
      {
         mShouldBePlaying = null;
         mAssetLoadedCallback = null;
         mIsPlaying = false;
         mLastPlayFinishedCallback = null;
         stopStarlingSync();
         if(mStarlingRenderer != null)
         {
            mStarlingRenderer.stop();
            mStarlingRenderer.setLayer(0);
         }
         if(mMovieClipRenderer)
         {
            mMovieClipRenderer.stop();
            mMovieClipRenderer.finishedCallback = null;
         }
         this.removeFromStage();
         if(mRoot.parent)
         {
            mRoot.parent.removeChild(mRoot);
         }
         mAnchor = null;
         mSortAnchor = null;
      }
      
      override public function addToStage() : void
      {
         if(mUseStarling && mDBFacade.starlingLayerManager.getLayer(this.layer) == null)
         {
            fallbackToSwf("no Starling layer for layer index " + this.layer);
         }
         mOnStage = true;
         super.addToStage();
         if(mStarlingRenderer != null)
         {
            mStarlingRenderer.setLayer(this.layer);
            syncStarlingTransform();
         }
      }
      
      override public function removeFromStage() : void
      {
         mOnStage = false;
         if(mStarlingRenderer != null)
         {
            mStarlingRenderer.setLayer(0);
         }
         super.removeFromStage();
      }
      
      override public function set rotationY(rot:Number) : void
      {
         if(mUseStarling)
         {
            mFlipX = rot != 0;
         }
         else
         {
            super.rotationY = rot;
         }
      }
      
      override public function get rotationY() : Number
      {
         return mUseStarling ? (mFlipX ? 180 : 0) : super.rotationY;
      }
      
      override public function set rotationX(rot:Number) : void
      {
         if(mUseStarling)
         {
            mRotationX = rot;
         }
         else
         {
            super.rotationX = rot;
         }
      }
      
      override public function get rotationX() : Number
      {
         return mUseStarling ? mRotationX : super.rotationX;
      }
      
      private function onStarlingAtlasLoaded() : void
      {
         var _loc5_:String = null;
         var _loc1_:ShouldBePlaying = null;
         if(!mUseStarling || mDBFacade == null)
         {
            return;
         }
         var _loc2_:String = StarlingAssetMapper.getActorAtlasKeyFromPath(mSwfPath);
         var _loc4_:Animation = mDBFacade.assetLoadingComponent.createAnimationFromAtlas(_loc2_,mEffectClassName);
         var _loc3_:String = null;
         if(_loc4_ == null)
         {
            _loc5_ = StarlingAssetMapper.isPropLibraryPath(mSwfPath) ? StarlingAssetMapper.getBiomeKeyFromPath(mSwfPath) : null;
            _loc4_ = mDBFacade.assetLoadingComponent.createAnimationFromAssetManager(mEffectClassName,_loc5_);
         }
         if(_loc4_ == null)
         {
            _loc4_ = mDBFacade.assetLoadingComponent.createAnimationFromAssetManager(_loc2_);
            if(_loc4_ != null && _loc4_.getFrame(mEffectClassName) >= 0)
            {
               _loc3_ = mEffectClassName;
            }
            else if(_loc4_ != null)
            {
               _loc4_.dispose();
               _loc4_ = null;
            }
         }
         if(_loc4_ == null)
         {
            Logger.warnch("Starling","EffectView: no Starling effect \'" + mEffectClassName + "\' in atlas \'" + _loc2_ + "\', using SWF");
            mSwfFallbackReason = "no Starling animation for effect class in atlas \'" + _loc2_ + "\'";
            mUseStarling = false;
            mAssetLoadingComponent.getSwfAsset(mSwfPath,assetLoaded);
            return;
         }
         var _loc6_:int = resolveStarlingLayer();
         if(_loc6_ != 0 && mDBFacade.starlingLayerManager.getLayer(_loc6_) == null)
         {
            _loc4_.dispose();
            fallbackToSwf("anchor\'s layer " + _loc6_ + " has no Starling counterpart");
            return;
         }
         mStarlingRenderer = new StarlingEffectRenderer(mDBFacade,mEffectClassName,_loc6_,_loc4_,_loc3_);
         mStarlingPurgeStamp = mDBFacade.assetLoadingComponent.starlingPurgeCount;
         mStarlingRenderer.setPlayRate(mPlayRate);
         if(mStatusTintAmount > 0)
         {
            mStarlingRenderer.setStatusTint(mStatusTintColor,mStatusTintAmount);
         }
         if(mIconInsert != null)
         {
            loadStarlingIcon();
         }
         if(mShouldBePlaying != null)
         {
            _loc1_ = mShouldBePlaying;
            mShouldBePlaying = null;
            play(_loc1_.loop,_loc1_.finishedCallback);
         }
         else
         {
            syncStarlingTransform();
         }
         if(artResolvedCallback != null)
         {
            artResolvedCallback();
         }
      }
      
      public function applyStatusTint(color:uint, amount:Number) : void
      {
         mStatusTintColor = color;
         mStatusTintAmount = amount;
         if(mStarlingRenderer != null)
         {
            mStarlingRenderer.setStatusTint(color,amount);
         }
      }
      
      public function clearStatusTint() : void
      {
         mStatusTintAmount = 0;
         if(mStarlingRenderer != null)
         {
            mStarlingRenderer.clearStatusTint();
         }
      }
      
      private function loadStarlingIcon() : void
      {
         var iconInsert:EffectIconInsert = mIconInsert;
         var fullPath:String = DBFacade.buildFullDownloadPath(iconInsert.iconPath);
         mAssetLoadingComponent.getSwfAsset(fullPath,function(param1:SwfAsset):void
         {
            if(mStarlingRenderer == null || mIconInsert != iconInsert)
            {
               return;
            }
            var _loc3_:Class = param1.getClass(iconInsert.iconName);
            if(_loc3_ == null)
            {
               Logger.error("Unable to find icon class: " + iconInsert.iconName);
               return;
            }
            var _loc2_:Image = StarlingEffectRenderer.createIconImage(fullPath + ":" + iconInsert.iconName,new _loc3_());
            mStarlingRenderer.attachMarkerContent(iconInsert.markerName,_loc2_);
         });
      }
      
      private function startStarlingSync() : void
      {
         if(mStarlingSyncComponent == null)
         {
            mStarlingSyncComponent = new LayerWorkComponent(mDBFacade,"EffectView");
         }
         mStarlingSyncComponent.doEveryFrame(onStarlingSyncFrame);
         syncStarlingTransform();
      }
      
      private function stopStarlingSync() : void
      {
         if(mStarlingSyncComponent != null)
         {
            mStarlingSyncComponent.destroy();
            mStarlingSyncComponent = null;
         }
      }
      
      private function onStarlingSyncFrame(clock:GameClock) : void
      {
         syncStarlingTransform();
      }
      
      private function revalidateStarlingRenderer() : void
      {
         if(mStarlingRenderer == null || mDBFacade == null || mDBFacade.assetLoadingComponent == null)
         {
            return;
         }
         if(mStarlingPurgeStamp == mDBFacade.assetLoadingComponent.starlingPurgeCount)
         {
            return;
         }
         mStarlingRenderer.destroy();
         mStarlingRenderer = null;
         if(mIsPlaying && mShouldBePlaying == null)
         {
            mShouldBePlaying = new ShouldBePlaying(mLastPlayLoop,mLastPlayFinishedCallback);
         }
         queueStarlingEffectAssets();
      }
      
      private function syncStarlingTransform() : void
      {
         var _loc5_:int = 0;
         var _loc4_:Matrix = null;
         revalidateStarlingRenderer();
         if(mStarlingRenderer == null || mRoot == null || mDBFacade == null)
         {
            return;
         }
         if(mAnchor != null)
         {
            _loc5_ = resolveStarlingLayer();
            if(_loc5_ == 0)
            {
               mStarlingRenderer.visible = false;
               return;
            }
            if(_loc5_ != mStarlingRenderer.layerIndex)
            {
               if(mDBFacade.starlingLayerManager.getLayer(_loc5_) == null)
               {
                  fallbackToSwf("anchor\'s layer " + _loc5_ + " has no Starling counterpart");
                  return;
               }
               mStarlingRenderer.setLayer(_loc5_);
            }
         }
         var _loc1_:Matrix = computeLayerSpaceMatrix(mRoot);
         var _loc2_:Number = _loc1_.tx;
         var _loc3_:Number = _loc1_.ty;
         if(mAnchor != null)
         {
            _loc4_ = computeLayerSpaceMatrix(mSortAnchor ?? mAnchor);
            _loc2_ = _loc4_.tx;
            _loc3_ = _loc4_.ty + (mBehindAnchor ? -0.2 : 0.2);
            Pool.putMatrix(_loc4_);
         }
         if(mFlipX)
         {
            _loc1_.a = -_loc1_.a;
            _loc1_.c = -_loc1_.c;
         }
         mStarlingRenderer.setWorldTransform(_loc1_,_loc2_,_loc3_,computeLayerSpaceAlpha(mRoot));
         Pool.putMatrix(_loc1_);
         mStarlingRenderer.visible = computeLayerSpaceVisible(mRoot) && (mOnStage || mAnchor != null);
      }
      
      private function resolveStarlingLayer() : int
      {
         if(mOnStage)
         {
            return this.layer;
         }
         var _loc1_:DisplayObject = mAnchor;
         while(_loc1_ != null && !(_loc1_ is Layer))
         {
            _loc1_ = _loc1_.parent;
         }
         return _loc1_ is Layer ? Layer(_loc1_).sortIndex : 0;
      }
      
      private function fallbackToSwf(reason:String = null) : void
      {
         if(reason != null)
         {
            mSwfFallbackReason = reason;
         }
         mUseStarling = false;
         stopStarlingSync();
         if(mStarlingRenderer != null)
         {
            mStarlingRenderer.destroy();
            mStarlingRenderer = null;
         }
         if(mIsPlaying)
         {
            mShouldBePlaying = new ShouldBePlaying(mLastPlayLoop,mLastPlayFinishedCallback);
         }
         mAssetLoadingComponent.getSwfAsset(mSwfPath,assetLoaded);
      }
      
      private function assetLoaded(swfAsset:SwfAsset) : void
      {
         var _loc2_:ShouldBePlaying = null;
         var _loc3_:Class = swfAsset.getClass(mEffectClassName);
         if(_loc3_ == null)
         {
            Logger.error("Unable to find class: " + mEffectClassName);
            return;
         }
         mEffect = new _loc3_();
         mMovieClipRenderer = new MovieClipRenderController(mDBFacade,mEffect);
         mMovieClipRenderer.playRate = mPlayRate;
         if(mShouldBePlaying)
         {
            _loc2_ = mShouldBePlaying;
            mShouldBePlaying = null;
            mMovieClipRenderer.play(0,_loc2_.loop,_loc2_.finishedCallback);
         }
         SwfFallbackDebug.report(mDBFacade,fallbackCategory,mEffectClassName,mSwfPath,mSwfFallbackReason);
         SwfFallbackDebug.applyOutline(mDBFacade,mEffect,fallbackCategory);
         mRoot.mouseChildren = false;
         mRoot.mouseEnabled = false;
         mRoot.addChild(mEffect);
         if(mAssetLoadedCallback != null)
         {
            mAssetLoadedCallback(mEffect);
         }
         if(artResolvedCallback != null)
         {
            artResolvedCallback();
         }
      }
      
      override public function destroy() : void
      {
         mShouldBePlaying = null;
         mAssetLoadedCallback = null;
         artResolvedCallback = null;
         mIconInsert = null;
         mAnchor = null;
         mSortAnchor = null;
         mEffect = null;
         stopStarlingSync();
         if(mStarlingRenderer != null)
         {
            mStarlingRenderer.destroy();
            mStarlingRenderer = null;
         }
         if(mAssetLoadingComponent)
         {
            mAssetLoadingComponent.destroy();
            mAssetLoadingComponent = null;
         }
         super.destroy();
      }
   }
}

class ShouldBePlaying
{
   
   public var loop:Boolean;
   
   public var finishedCallback:Function;
   
   public function ShouldBePlaying(l:Boolean, f:Function)
   {
      super();
      loop = l;
      finishedCallback = f;
   }
}
