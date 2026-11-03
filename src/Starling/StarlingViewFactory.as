package Starling
{
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.StarlingAssetMapper;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Logger.Logger;
   import Brain.Starling.*;
   import Collections.Map;
   import Facade.DBFacade;
   import GameMasterDictionary.GMProp;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   import starling.display.DisplayObjectContainer;
   import starling.display.Image;
   import starling.extensions.animate.Animation;
   import starling.textures.Texture;
   
   public class StarlingViewFactory
   {
      
      protected var mFacade:DBFacade;
      
      protected var mAssetLoadingComponent:AssetLoadingComponent;
      
      protected var mStarlingLayerManager:StarlingLayerManager;
      
      protected var mLibraryMap:Map;
      
      private var mDisposed:Boolean = false;
      
      private var mFloorBackgrounds:Dictionary;
      
      public function StarlingViewFactory(inFacade:DBFacade)
      {
         super();
         mFacade = inFacade;
         mStarlingLayerManager = mFacade.starlingLayerManager;
         mAssetLoadingComponent = mFacade.assetLoadingComponent;
         mLibraryMap = new Map();
         mFloorBackgrounds = new Dictionary(true);
         buildLibraryMap();
      }
      
      public function get starlingLayerManager() : StarlingLayerManager
      {
         return mStarlingLayerManager;
      }
      
      public function get assetLoadingComponent() : AssetLoadingComponent
      {
         return mAssetLoadingComponent;
      }
      
      public function initializeBatch() : void
      {
         starlingLayerManager.cleanLayers();
      }
      
      protected function buildLibraryMap() : void
      {
         var _loc3_:int = 0;
         var _loc1_:Object = null;
         var _loc2_:Array = mFacade.libraryJson;
         while(_loc3_ < _loc2_.length)
         {
            _loc1_ = _loc2_[_loc3_];
            mLibraryMap.add(_loc1_.constant,_loc1_);
            _loc3_++;
         }
      }
      
      public function getPivotJson(constant:String) : Object
      {
         var _loc2_:Object = mLibraryMap.itemFor(constant);
         if(_loc2_)
         {
            return _loc2_.pivot;
         }
         return null;
      }
      
      public function buildViewFromAsset(inMovieClipKey:String, inX:Number, inY:Number, inScaleX:Number, inScaleY:Number, inRotation:Number, inIsOnStage:Boolean, inIsFiller:Boolean = false) : void
      {
         var swfPath:String;
         var assetClassName:String;
         var gmProp:GMProp = mFacade.gameMaster.propByConstant.itemFor(inMovieClipKey) as GMProp;
         if(gmProp == null)
         {
            Logger.warn("createProp constant not found in GM data: " + inMovieClipKey);
            return;
         }
         swfPath = DBFacade.buildFullDownloadPath(gmProp.SwfFilepath);
         assetClassName = gmProp.AssetClassName;
         assetLoadingComponent.queueStarlingAssetsForPath(swfPath,function():void
         {
            if(mDisposed || mAssetLoadingComponent == null)
            {
               return;
            }
            var _loc1_:Texture = mAssetLoadingComponent.getTextureFromAssetManager(assetClassName,StarlingAssetMapper.getBiomeKeyFromPath(swfPath));
            if(_loc1_ == null)
            {
               SwfFallbackDebug.report(mFacade,"TILE",inMovieClipKey + " (" + assetClassName + ")",swfPath,"no Starling texture for tile background in the floor biome atlas");
               loadSwfAsset(swfPath,assetClassName,inMovieClipKey,inX,inY,inScaleX,inScaleY,inRotation,inIsOnStage,inIsFiller);
            }
            else
            {
               placeBackground(onTextureAssetLoaded(_loc1_,inMovieClipKey,inX,inY,inScaleX,inScaleY,inRotation,inIsOnStage,5,"none"),inIsFiller);
            }
         },true);
      }
      
      private function loadSwfAsset(swfPath:String, assetClassName:String, inMovieClipKey:String, inX:Number, inY:Number, inScaleX:Number, inScaleY:Number, inRotation:Number, inIsOnStage:Boolean, inIsFiller:Boolean) : void
      {
         mAssetLoadingComponent.getSwfAsset(swfPath,function(param1:SwfAsset):void
         {
            if(mDisposed)
            {
               return;
            }
            var _loc2_:Class = param1.getClass(assetClassName);
            var _loc3_:MovieClip = new _loc2_() as MovieClip;
            placeBackground(onAssetLoaded(_loc3_,inMovieClipKey,inX,inY,inScaleX,inScaleY,inRotation,inIsOnStage),inIsFiller);
         });
      }
      
      public function onTextureAssetLoaded(inTexture:Texture, inMovieClipKey:String, inX:Number, inY:Number, inScaleX:Number, inScaleY:Number, inRotation:Number, inIsOnStage:Boolean, inTargetLayer:int = 10, inBlendMode:String = null) : StarlingView
      {
         inTargetLayer = resolveTargetLayer(inTargetLayer,"onTextureAssetLoaded");
         var _loc13_:StarlingView = new StarlingView(mFacade,inMovieClipKey);
         var _loc11_:Image = new StarlingSceneryImage(inTexture);
         _loc11_.name = inMovieClipKey;
         _loc11_.scaleX = inScaleX;
         _loc11_.scaleY = inScaleY;
         var _loc12_:Object = getPivotJson(inMovieClipKey);
         if(_loc12_ != null)
         {
            _loc11_.pivotX = _loc12_.pivotX;
            _loc11_.pivotY = _loc12_.pivotY;
         }
         _loc11_.touchable = false;
         _loc11_.pixelSnapping = false;
         if(inBlendMode != null)
         {
            _loc11_.blendMode = inBlendMode;
         }
         _loc11_.visible = true;
         _loc13_.image = _loc11_;
         _loc13_.x = inX;
         _loc13_.y = inY;
         _loc13_.rotation = inRotation;
         addChildToLayer(_loc13_,inTargetLayer);
         return _loc13_;
      }
      
      public function onAnimationLoaded(inAnimation:Animation, inMovieClipKey:String, inX:Number, inY:Number, inScaleX:Number, inScaleY:Number, inRotation:Number, inIsOnStage:Boolean, inTargetLayer:int = 10, inBlendMode:String = null) : StarlingView
      {
         inTargetLayer = resolveTargetLayer(inTargetLayer,"onAnimationLoaded");
         var _loc11_:StarlingView = new StarlingView(mFacade,inMovieClipKey);
         if(inBlendMode != null)
         {
            inAnimation.blendMode = inBlendMode;
         }
         _loc11_.animation = inAnimation;
         _loc11_.x = inX;
         _loc11_.y = inY;
         _loc11_.scaleX = inScaleX;
         _loc11_.scaleY = inScaleY;
         _loc11_.rotation = inRotation;
         addChildToLayer(_loc11_,inTargetLayer);
         return _loc11_;
      }
      
      public function onAssetLoaded(inMovieClip:MovieClip, inMovieClipKey:String, inX:Number, inY:Number, inScaleX:Number, inScaleY:Number, inRotation:Number, inIsOnStage:Boolean, inBlendMode:String = null) : StarlingView
      {
         for each(var _loc13_:DisplayObject in StarlingHelper.findNavCollisions(inMovieClip))
         {
            _loc13_.parent.removeChild(_loc13_);
         }
         for each(var _loc12_:DisplayObject in StarlingHelper.findCombatCollisions(inMovieClip))
         {
            _loc12_.parent.removeChild(_loc12_);
         }
         var _loc15_:Rectangle = inMovieClip.getBounds(inMovieClip);
         var _loc16_:BitmapData = new BitmapData(Math.ceil(_loc15_.width),Math.ceil(_loc15_.height),true,0);
         var _loc14_:Matrix = new Matrix();
         _loc14_.translate(-_loc15_.x,-_loc15_.y);
         _loc16_.draw(inMovieClip,_loc14_);
         SwfFallbackDebug.markFallbackBitmap(mFacade,_loc16_,"TILE");
         var _loc11_:Texture = starlingLayerManager.sourceCache.getOrCreate(inMovieClipKey,_loc16_);
         var _loc17_:StarlingView = new StarlingView(mFacade,inMovieClipKey);
         var _loc10_:Image = new StarlingSceneryImage(_loc11_);
         _loc10_.name = inMovieClipKey;
         _loc10_.scaleX = inScaleX;
         _loc10_.scaleY = inScaleY;
         _loc10_.touchable = false;
         _loc10_.pixelSnapping = false;
         if(inBlendMode != null)
         {
            _loc10_.blendMode = inBlendMode;
         }
         _loc10_.visible = true;
         _loc17_.image = _loc10_;
         _loc17_.x = inX + _loc15_.x * inScaleX;
         _loc17_.y = inY + _loc15_.y * inScaleY;
         _loc17_.rotation = inRotation;
         addChildToLayer(_loc17_,5);
         return _loc17_;
      }
      
      private function resolveTargetLayer(inTargetLayer:int, inCallerName:String) : int
      {
         if(starlingLayerManager.getLayer(inTargetLayer) == null)
         {
            Logger.warn(inCallerName + ": no Starling layer for index " + inTargetLayer + ", falling back to SORTED");
            return 20;
         }
         return inTargetLayer;
      }
      
      private function addChildToLayer(inChild:StarlingView, inLayer:int) : void
      {
         starlingLayerManager.getLayer(inLayer).addChild(inChild);
         starlingLayerManager.markLayerDirty(inLayer);
      }
      
      private function placeBackground(inChild:StarlingView, inIsFiller:Boolean) : void
      {
         var _loc4_:int = 0;
         var _loc5_:DisplayObjectContainer = inChild.parent;
         if(!inIsFiller)
         {
            mFloorBackgrounds[inChild] = true;
            _loc5_.setChildIndex(inChild,0);
            return;
         }
         var _loc3_:int = 0;
         _loc4_ = 0;
         while(_loc4_ < _loc5_.numChildren)
         {
            if(mFloorBackgrounds[_loc5_.getChildAt(_loc4_)])
            {
               _loc3_++;
            }
            _loc4_++;
         }
         _loc5_.setChildIndex(inChild,_loc3_);
      }
      
      public function destroy() : void
      {
         mDisposed = true;
         mFacade = null;
         mAssetLoadingComponent = null;
         mStarlingLayerManager.cleanLayers();
         mStarlingLayerManager = null;
         mLibraryMap = null;
         mFloorBackgrounds = null;
      }
   }
}

