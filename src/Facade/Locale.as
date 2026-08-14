package Facade
{
   import Brain.AssetRepository.AssetLoaderInfo;
   import Brain.AssetRepository.JsonAsset;
   import Brain.Logger.Logger;
   
   public class Locale
   {
      
      public static const DEFAULT_NAMETAG:String = "DEFAULT_NAMETAG";
      
      private static var mDefaultStringTable:Object;
      
      private static var mOverrideStringTable:Object;
      
      private static var dbFacade:DBFacade;
      
      public function Locale()
      {
         super();
      }
      
      public static function get isDefaultLoaded() : Boolean
      {
         return mDefaultStringTable != null;
      }
      
      public static function loadStrings(facade:DBFacade, callback:Function) : void
      {
         var defaultLanguageAssetInfo:AssetLoaderInfo;
         dbFacade = facade;
         var overrideLanguageAssetInfo:AssetLoaderInfo = new AssetLoaderInfo(DBFacade.buildFullDownloadPath("Resources/Locale/Locale.override.json"),false);
         facade.assetRepository.getJsonAsset(overrideLanguageAssetInfo,function(param1:JsonAsset):void
         {
            Logger.debugch("Locale","Override Locale loaded!");
            mOverrideStringTable = param1.json;
            callback();
         },function():void
         {
            Logger.warnch("Locale","Failed to load Override Locale JSON.");
         });
         defaultLanguageAssetInfo = new AssetLoaderInfo(DBFacade.buildFullDownloadPath("Resources/Locale/Locale.default.json"),false);
         facade.assetRepository.getJsonAsset(defaultLanguageAssetInfo,function(param1:JsonAsset):void
         {
            Logger.debugch("Locale","Default Locale loaded!");
            mDefaultStringTable = param1.json;
            callback();
         },function():void
         {
            Logger.fatal("Default Locale File \'Locale.default.json\' failed to Load, cannot proceed with loading the game. Please run \'Verify integrity of game files\' on Steam.");
         });
      }
      
      public static function getString(key:String) : String
      {
         var _loc4_:Boolean = false;
         if(mDefaultStringTable == null)
         {
            Logger.warnch("Locale","You cannot call getString before load has finished: " + key);
            return key;
         }
         var _loc3_:String = null;
         if(mOverrideStringTable != null && mOverrideStringTable.strings != null)
         {
            _loc3_ = mOverrideStringTable.strings[key];
            _loc4_ = true;
            if(_loc3_ != null)
            {
               return _loc3_;
            }
         }
         var _loc2_:String = mDefaultStringTable.strings[key];
         if(_loc4_)
         {
            Logger.warnch("Locale","Localized string not found: " + key);
         }
         if(_loc2_ == null)
         {
            Logger.warnch("Locale","Default string not found: " + key);
            return "mia:" + key;
         }
         return _loc2_;
      }
      
      public static function getSubString(key:String, subKey:String) : String
      {
         var _loc7_:Boolean = false;
         if(mDefaultStringTable == null)
         {
            Logger.warnch("Locale","You cannot call getSubString before load has finished: " + key + " subKey: " + subKey);
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
            Logger.error("Unable to find in the `strings` table a dictionary for key: " + key + " (when looking up subKey: " + subKey + ")");
            return "mia:" + key;
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
            Logger.warnch("Locale","Localized sub string not found: " + key + " subKey: " + subKey + " Using English default value of: `" + _loc4_ + "`");
         }
         if(_loc4_ == null)
         {
            Logger.error("Default sub string not found: " + key + " subKey: " + subKey);
            return "mia:" + key;
         }
         return _loc4_;
      }
      
      public static function getError(key:int) : String
      {
         var _loc4_:Boolean = false;
         if(mDefaultStringTable == null)
         {
            Logger.warnch("Locale","You cannot call getError before load has finished: " + key.toString());
            return "Error (" + key.toString() + ")";
         }
         var _loc3_:String = null;
         if(mOverrideStringTable != null && mOverrideStringTable.errors != null)
         {
            _loc3_ = mOverrideStringTable.errors[key.toString()];
            _loc4_ = true;
            if(_loc3_ != null)
            {
               return _loc3_;
            }
         }
         var _loc2_:String = mDefaultStringTable.errors[key.toString()];
         if(_loc4_)
         {
            Logger.warnch("Locale","Localized error string not found: " + key.toString());
         }
         if(_loc2_ == null)
         {
            Logger.warnch("Locale","Default error string not found: " + key.toString());
            _loc2_ = mDefaultStringTable.errors["DEF"];
            if(_loc2_ == null)
            {
               _loc2_ = "Error ";
            }
            _loc2_ += "(" + key.toString() + ")";
         }
         return _loc2_;
      }
   }
}

