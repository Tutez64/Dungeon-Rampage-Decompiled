package UI.Map
{
   import Brain.AssetRepository.AssetLoaderInfo;
   import Brain.AssetRepository.AssetRepository;
   import Brain.AssetRepository.JsonAsset;
   import Brain.Clock.GameClock;
   import Brain.Logger.Logger;
   import Facade.DBFacade;
   import Facade.Locale;
   import flash.filters.GlowFilter;
   
   public class PlayerActivityCount
   {
      
      private static const PLAYER_ACTIVITY_LOCALE_PREFIX:String = "PLAYER_ACTIVITY_";
      
      public static const UI_POPULATION_ACTIVE_FILTER:GlowFilter = new GlowFilter(3457628,1,6,6,12);
      
      public static const UI_POPULATION_POPULAR_FILTER:GlowFilter = new GlowFilter(9909442,1,6,6,12);
      
      public static const UI_POPULATION_BUSTLING_FILTER:GlowFilter = new GlowFilter(12727407,1,6,6,12);
      
      public static const UI_POPULATION_RAMPAGING_FILTER:GlowFilter = new GlowFilter(12727348,1,6,6,12);
      
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
      
      public function getPopulationGlow(activityLevel:String) : GlowFilter
      {
         if(activityLevel)
         {
            activityLevel = activityLevel.toUpperCase();
            if(activityLevel == "QUIET")
            {
               return null;
            }
            if(activityLevel == "ACTIVE")
            {
               return UI_POPULATION_ACTIVE_FILTER;
            }
            if(activityLevel == "POPULAR")
            {
               return UI_POPULATION_POPULAR_FILTER;
            }
            if(activityLevel == "BUSTLING")
            {
               return UI_POPULATION_BUSTLING_FILTER;
            }
            if(activityLevel == "RAMPAGING!")
            {
               return UI_POPULATION_RAMPAGING_FILTER;
            }
         }
         return null;
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
         var _loc2_:String = null;
         if(publicDungeonActivityLevel)
         {
            _loc2_ = publicDungeonActivityLevel[id] as String;
            if(_loc2_)
            {
               return getLocalizedActivityString(_loc2_.toUpperCase());
            }
         }
         return getLocalizedActivityString("UNKNOWN");
      }
      
      private function getLocalizedActivityString(activityString:String) : String
      {
         return Locale.getString("PLAYER_ACTIVITY_" + activityString);
      }
   }
}

