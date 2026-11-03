package Dungeon
{
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.StarlingAssetMapper;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Logger.Logger;
   import Collections.Map;
   import Facade.DBFacade;
   import GameMasterDictionary.GMProp;
   import Starling.SwfFallbackDebug;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import starling.extensions.animate.Animation;
   import starling.textures.Texture;
   
   public class PropFactory
   {
      
      protected var mDBFacade:DBFacade;
      
      protected var mLibraryJson:Array;
      
      protected var mConstantToJsonMap:Map;
      
      protected var mAssetClassToJsonMap:Map;
      
      protected var mAssetLoadingComponent:AssetLoadingComponent;
      
      public function PropFactory(facade:DBFacade, libraryJson:Array)
      {
         super();
         mDBFacade = facade;
         mLibraryJson = libraryJson;
         mConstantToJsonMap = new Map();
         mAssetClassToJsonMap = new Map();
         mAssetLoadingComponent = facade.assetLoadingComponent;
         buildLibraryMap();
      }
      
      public function destroy() : void
      {
         mDBFacade = null;
         mLibraryJson = null;
         mConstantToJsonMap.clear();
         mConstantToJsonMap = null;
         mAssetClassToJsonMap.clear();
         mAssetClassToJsonMap = null;
         mAssetLoadingComponent = null;
      }
      
      protected function buildLibraryMap() : void
      {
         var _loc2_:int = 0;
         var _loc1_:Object = null;
         while(_loc2_ < mLibraryJson.length)
         {
            _loc1_ = mLibraryJson[_loc2_];
            mConstantToJsonMap.add(_loc1_.constant,_loc1_);
            if(_loc1_.assetClassName != null)
            {
               mAssetClassToJsonMap.add(_loc1_.assetClassName,_loc1_);
            }
            _loc2_++;
         }
      }
      
      public function getNavCollisionJson(constant:String) : Array
      {
         var _loc2_:Object = mConstantToJsonMap.itemFor(constant);
         if(_loc2_)
         {
            return _loc2_.navCollisions;
         }
         return null;
      }
      
      public function getNavCollisionTriggerOffJson(constant:String) : Array
      {
         var _loc2_:Object = mConstantToJsonMap.itemFor(constant);
         if(_loc2_)
         {
            return _loc2_.navCollisions_off;
         }
         return null;
      }
      
      public function isPropAnimated(assetClassName:String) : Boolean
      {
         var _loc2_:Object = mAssetClassToJsonMap.itemFor(assetClassName);
         if(_loc2_ && _loc2_.hasOwnProperty("isAnimated"))
         {
            return _loc2_.isAnimated;
         }
         return false;
      }
      
      public function createProp(constant:String, assetLoadedCallback:Function, textureLoadedCallback:Function = null, animationLoadedCallback:Function = null) : void
      {
         var swfPath:String;
         var assetClassName:String;
         var isAnimated:Boolean;
         var libraryKey:String;
         var gmProp:GMProp = mDBFacade.gameMaster.propByConstant.itemFor(constant) as GMProp;
         if(gmProp == null)
         {
            Logger.warn("createProp constant not found in GM data: " + constant);
            return;
         }
         swfPath = DBFacade.buildFullDownloadPath(gmProp.SwfFilepath);
         assetClassName = gmProp.AssetClassName;
         isAnimated = isPropAnimated(assetClassName);
         libraryKey = StarlingAssetMapper.getBiomeKeyFromPath(swfPath);
         mAssetLoadingComponent.queueStarlingAssetsForProps(swfPath,isAnimated ? [assetClassName] : [],function():void
         {
            var _loc3_:Animation = null;
            var _loc2_:Texture = null;
            if(mAssetLoadingComponent == null)
            {
               return;
            }
            var _loc1_:String = null;
            if(isAnimated)
            {
               _loc3_ = mAssetLoadingComponent.createAnimationFromAtlas(StarlingAssetMapper.getActorAtlasKeyFromPath(swfPath),assetClassName);
               if(_loc3_ == null)
               {
                  _loc3_ = mAssetLoadingComponent.createAnimationFromAssetManager(assetClassName,libraryKey);
               }
               if(_loc3_ != null && animationLoadedCallback != null)
               {
                  animationLoadedCallback(_loc3_);
                  return;
               }
               _loc1_ = _loc3_ == null ? "no Starling animation for animated prop" : "animation resolved but no animationLoadedCallback was provided";
            }
            else
            {
               _loc2_ = mAssetLoadingComponent.getTextureFromAssetManager(assetClassName,libraryKey);
               if(_loc2_ != null && textureLoadedCallback != null)
               {
                  textureLoadedCallback(_loc2_);
                  return;
               }
               _loc1_ = _loc2_ == null ? "no atlas texture for static prop" : "texture resolved but no textureLoadedCallback was provided";
            }
            SwfFallbackDebug.report(mDBFacade,"PROP",constant + " (" + assetClassName + ")",swfPath,_loc1_);
            loadSwfAsset(swfPath,assetClassName,assetLoadedCallback);
         });
      }
      
      private function loadSwfAsset(swfPath:String, assetClassName:String, assetLoadedCallback:Function) : void
      {
         mAssetLoadingComponent.getSwfAsset(swfPath,function(param1:SwfAsset):void
         {
            var _loc2_:Class = param1.getClass(assetClassName);
            var _loc3_:MovieClip = new _loc2_() as MovieClip;
            if(_loc3_.totalFrames <= 1 && !hasAnimatedDescendant(_loc3_))
            {
               Logger.warnch("Starling","Prop did not load into Starling Pipeline: " + assetClassName);
            }
            assetLoadedCallback(_loc3_);
         });
      }
      
      private function hasAnimatedDescendant(container:DisplayObjectContainer) : Boolean
      {
         var _loc2_:int = 0;
         var _loc3_:DisplayObject = null;
         _loc2_ = 0;
         while(_loc2_ < container.numChildren)
         {
            _loc3_ = container.getChildAt(_loc2_);
            if(_loc3_ is MovieClip && MovieClip(_loc3_).totalFrames > 1)
            {
               return true;
            }
            if(_loc3_ is DisplayObjectContainer && hasAnimatedDescendant(DisplayObjectContainer(_loc3_)))
            {
               return true;
            }
            _loc2_++;
         }
         return false;
      }
   }
}

