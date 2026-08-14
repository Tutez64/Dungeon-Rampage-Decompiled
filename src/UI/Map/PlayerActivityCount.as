package UI.Map
{
   import Brain.AssetRepository.AssetLoaderInfo;
   import Brain.AssetRepository.AssetRepository;
   import Brain.AssetRepository.JsonAsset;
   import Brain.Clock.GameClock;
   import Brain.Logger.Logger;
   import Facade.DBFacade;
   import Facade.Locale;
   
   public class PlayerActivityCount
   {
      
      private static const PLAYER_ACTIVITY_LOCALE_PREFIX:String = "PLAYER_ACTIVITY_";
      
      public var publicDungeonActivityLevel:Object = {};
      
      private var mAssetRepository:AssetRepository;
      
      private var mStatusURL:String;
      
      public function PlayerActivityCount(dbFacade:DBFacade)
      {
         super();
         mAssetRepository = dbFacade.assetRepository;
         mStatusURL = dbFacade.webServicesUrl + "/game-status";
         fetchPublicDungeonActivityLevel();
      }
      
      public function fetchPublicDungeonActivityLevel(gameClock:GameClock = null) : void
      {
         var info:AssetLoaderInfo = new AssetLoaderInfo(mStatusURL,false);
         mAssetRepository.getJsonAsset(info,function(param1:JsonAsset):void
         {
            if(param1.json && param1.json.publicDungeonActivityLevel)
            {
               publicDungeonActivityLevel = param1.json.publicDungeonActivityLevel;
            }
         },function():void
         {
            Logger.warn("game-status request failed: " + mStatusURL);
         });
      }
      
      public function getActivityString(id:int) : String
      {
         var _loc2_:String = publicDungeonActivityLevel[id] as String;
         if(_loc2_)
         {
            return getLocalizedActivityString(_loc2_.toUpperCase());
         }
         return getLocalizedActivityString("UNKNOWN");
      }
      
      private function getLocalizedActivityString(activityString:String) : String
      {
         return Locale.getString("PLAYER_ACTIVITY_" + activityString);
      }
   }
}

