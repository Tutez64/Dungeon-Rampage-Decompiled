package Dungeon
{
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Logger.Logger;
   import Facade.DBFacade;
   import GameMasterDictionary.GMProp;
   import flash.display.MovieClip;
   import org.as3commons.collections.Map;
   
   public class PropFactory
   {
      
      protected var mDBFacade:DBFacade;
      
      protected var mLibraryJson:Array;
      
      protected var mConstantToJsonMap:Map;
      
      protected var mAssetLoadingComponent:AssetLoadingComponent;
      
      public function PropFactory(facade:DBFacade, libraryJson:Array)
      {
         super();
         mDBFacade = facade;
         mLibraryJson = libraryJson;
         mConstantToJsonMap = new Map();
         mAssetLoadingComponent = new AssetLoadingComponent(facade);
         buildLibraryMap();
      }
      
      public function destroy() : void
      {
         mDBFacade = null;
         mLibraryJson = null;
         mConstantToJsonMap.clear();
         mConstantToJsonMap = null;
         mAssetLoadingComponent.destroy();
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
      
      public function createProp(constant:String, assetLoadedCallback:Function) : void
      {
         var swfPath:String;
         var assetClassName:String;
         var gmProp:GMProp = mDBFacade.gameMaster.propByConstant.itemFor(constant) as GMProp;
         if(gmProp == null)
         {
            Logger.warn("createProp constant not found in GM data: " + constant);
            return;
         }
         swfPath = DBFacade.buildFullDownloadPath(gmProp.SwfFilepath);
         assetClassName = gmProp.AssetClassName;
         mAssetLoadingComponent.getSwfAsset(swfPath,function(param1:SwfAsset):void
         {
            var _loc2_:Class = param1.getClass(assetClassName);
            var _loc3_:MovieClip = new _loc2_() as MovieClip;
            assetLoadedCallback(_loc3_);
         });
      }
   }
}

