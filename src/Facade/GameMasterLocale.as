package Facade
{
   import Brain.AssetRepository.AssetLoaderInfo;
   import Brain.AssetRepository.JsonAsset;
   import Brain.Logger.Logger;
   
   public class GameMasterLocale
   {
      
      private static var mDefaultStringTable:Object;
      
      private static var mOverrideStringTable:Object;
      
      public function GameMasterLocale()
      {
         super();
      }
      
      public static function loadGameMasterStrings(facade:DBFacade, callback:Function) : void
      {
         var defaultLanguageAssetInfo:AssetLoaderInfo;
         var overrideLanguageAssetInfo:AssetLoaderInfo = new AssetLoaderInfo(DBFacade.buildFullDownloadPath("Resources/Locale/GameMasterLocale.override.json"),false);
         facade.assetRepository.getJsonAsset(overrideLanguageAssetInfo,function(param1:JsonAsset):void
         {
            Logger.debugch("Locale","Override GameMasterLocale loaded!");
            mOverrideStringTable = param1.json;
            callback();
         });
         defaultLanguageAssetInfo = new AssetLoaderInfo(DBFacade.buildFullDownloadPath("Resources/Locale/GameMasterLocale.default.json"),false);
         facade.assetRepository.getJsonAsset(defaultLanguageAssetInfo,function(param1:JsonAsset):void
         {
            Logger.debugch("Locale","Default Locale loaded!");
            mDefaultStringTable = param1.json;
         },function():void
         {
            Logger.warnch("Locale","Default GameMasterLocale Failed to Load.");
         });
      }
      
      public static function getGameMasterSubString(key:String, subKey:String) : String
      {
         var _loc7_:Boolean = false;
         if(mDefaultStringTable == null)
         {
            Logger.warnch("Locale","GM: You cannot call getGameMasterSubString before load has finished: " + key + " subKey: " + subKey);
            return key;
         }
         var _loc5_:Object = null;
         if(mOverrideStringTable != null && mOverrideStringTable.strings != null)
         {
            _loc5_ = mOverrideStringTable.strings[key];
            _loc7_ = true;
         }
         var _loc3_:Object = mDefaultStringTable.strings[key];
         if(_loc5_ == null && _loc3_ == null)
         {
            Logger.error("GM: Unable to find in the `strings` table a dictionary for key: " + key + " (when looking up subKey: " + subKey + ")");
            return "GML:" + key;
         }
         var _loc6_:String = null;
         if(_loc5_ != null)
         {
            _loc6_ = _loc5_[subKey];
            if(_loc6_ != null)
            {
               return _loc6_;
            }
         }
         var _loc4_:String = _loc3_ != null ? _loc3_[subKey] : null;
         if(_loc7_)
         {
            Logger.warnch("Locale","Game Master Localized sub string not found: " + key + " subKey: " + subKey + " Using English default value of: `" + _loc4_ + "`");
         }
         if(_loc4_ == null)
         {
            Logger.error("GM: Default sub string not found: " + key + " subKey: " + subKey);
            return "GML:" + key;
         }
         return _loc4_;
      }
   }
}

