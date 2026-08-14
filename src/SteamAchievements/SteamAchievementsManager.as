package SteamAchievements
{
   import Brain.Logger.Logger;
   import Facade.DBFacade;
   import GameMasterDictionary.GMHero;
   import GameMasterDictionary.GMMapNode;
   import com.amanitadesign.steam.SteamEvent;
   import org.as3commons.collections.Map;
   import org.as3commons.collections.framework.IMapIterator;
   
   public class SteamAchievementsManager
   {
      
      private static const LEVEL_COMPLETION:String = "_LEVEL_COMPLETE";
      
      private static const ULTIMATE_RAMPAGE_FLOOR_25_COMPLETE:String = "_FLOOR_25_STAT";
      
      public static const BASIC_ACHIEVEMENT_TEST_NAME_1:String = "TEST_ACHIEVEMENT_1";
      
      public static const BASIC_ACHIEVEMENT_TEST_NAME_2:String = "TEST_ACHIEVEMENT_2";
      
      public static const COLLECT_DAILY_REWARD:String = "COLLECT_DAILY_REWARD";
      
      public static const REROLL_DAILY_REWARD:String = "REROLL_DAILY_REWARD";
      
      public static const EQUIP_PET:String = "EQUIP_PET";
      
      public static const SELL_AN_ITEM:String = "SELL_AN_ITEM";
      
      public static const RETRAIN_CHARACTER:String = "RETRAIN_CHARACTER";
      
      public static const MUSIC_VOLUME_SET_TO_11:String = "MUSIC_VOLUME_SET_TO_11";
      
      public static const STORAGE_EXPAND_FIRST_TIME:String = "STORAGE_EXPAND_FIRST_TIME";
      
      public static const SEND_A_GIFT:String = "SEND_A_GIFT";
      
      public static const PURCHASE_WEAPON_FIRST_TIME:String = "PURCHASE_WEAPON_FIRST_TIME";
      
      public static const USE_CONSUMABLE_FIRST_TIME:String = "USE_CONSUMABLE_FIRST_TIME";
      
      public static const BASIC_INT_STAT_TEST_1:String = "TEST_STAT_INT_1";
      
      public static const BASIC_INT_STAT_TEST_2:String = "TEST_STAT_INT_2";
      
      public static const SPEND_COINS_INT_STAT:String = "SPEND_COINS_INT";
      
      public static const BERSERKER_LEVEL_UP_STAT:String = "BERSERKER_LEVEL_STAT";
      
      public static const RANGER_LEVEL_UP_STAT:String = "RANGER_LEVEL_STAT";
      
      public static const REROLL_DAILY_REWARD_STAT:String = "REROLL_DAILY_REWARD_STAT";
      
      public static const SELL_ITEM_STAT:String = "SELL_ITEM_STAT";
      
      public static const RETRAIN_STAT:String = "RETRAIN_STAT";
      
      public static const INFINITE_PRISON_25_STAT:String = "INFINITE_PRISON_FLOOR_25_STAT";
      
      public static const INFINITE_DINO_25_STAT:String = "INFINITE_DINO_FLOOR_25_STAT";
      
      public static const INFINITE_AZTECH_25_STAT:String = "INFINITE_AZTECH_FLOOR_25_STAT";
      
      public static const INFINITE_TEMPLE_25_STAT:String = "INFINITE_TEMPLE_FLOOR_25_STAT";
      
      public static const INFINITE_ARENA_25_STAT:String = "INFINITE_ARENA_FLOOR_25_STAT";
      
      public static const INFINITE_ICE_CAVES_25_STAT:String = "INFINITE_ICE_CAVES_FLOOR_25_STAT";
      
      public static const INFINITE_CATACOMBS_CAVES_25_STAT:String = "INFINITE_CATACOMBS_FLOOR_25_STAT";
      
      public static const INFINITE_TRIBAL_CAVES_25_STAT:String = "INFINITE_TRIBAL_FLOOR_25_STAT";
      
      public static const INFINITE_VILLAGE_CAVES_25_STAT:String = "INFINITE_VILLAGE_FLOOR_25_STAT";
      
      public static const STORAGE_MAX_STAT:String = "STORAGE_MAX_STAT";
      
      protected var mDBFacade:DBFacade;
      
      private var mAppID:uint;
      
      private var mIsSteamAchsManagerInitialized:Boolean = false;
      
      private var mAchievements:Vector.<SteamAchievement>;
      
      private var mStats:Map;
      
      public function SteamAchievementsManager(inDBFacade:DBFacade)
      {
         super();
         mDBFacade = inDBFacade;
         if(mDBFacade.featureFlags.getFlagValue("want-steam-achievements"))
         {
            mAppID = mDBFacade.mSteamworks.getAppID();
            mAchievements = new Vector.<SteamAchievement>();
            mStats = new Map();
            mIsSteamAchsManagerInitialized = true;
            addSteamAchievement("TEST_ACHIEVEMENT_1");
            addSteamAchievement("TEST_ACHIEVEMENT_2");
            addSteamAchievement("COLLECT_DAILY_REWARD");
            addSteamAchievement("REROLL_DAILY_REWARD");
            addSteamAchievement("RETRAIN_CHARACTER");
            addSteamAchievement("EQUIP_PET");
            addSteamAchievement("SELL_AN_ITEM");
            addSteamAchievement("SEND_A_GIFT");
            addSteamAchievement("USE_CONSUMABLE_FIRST_TIME");
            addSteamStat("TEST_STAT_INT_1",0,5);
            addSteamStat("TEST_STAT_INT_2",0,5);
            addSteamStat("SPEND_COINS_INT",0,10000);
            addSteamStat("BERSERKER_LEVEL_STAT",0,1);
            addSteamStat("RANGER_LEVEL_STAT",0,1);
            addSteamStat("REROLL_DAILY_REWARD_STAT",0,10);
            addSteamStat("SELL_ITEM_STAT",0,10);
            addSteamStat("RETRAIN_STAT",0,50);
            addSteamStat("INFINITE_PRISON_FLOOR_25_STAT",0,1);
            addSteamStat("INFINITE_DINO_FLOOR_25_STAT",0,1);
            addSteamStat("INFINITE_AZTECH_FLOOR_25_STAT",0,1);
            addSteamStat("INFINITE_TEMPLE_FLOOR_25_STAT",0,1);
            addSteamStat("INFINITE_ARENA_FLOOR_25_STAT",0,1);
            addSteamStat("INFINITE_ICE_CAVES_FLOOR_25_STAT",0,1);
            addSteamStat("INFINITE_CATACOMBS_FLOOR_25_STAT",0,1);
            addSteamStat("INFINITE_TRIBAL_FLOOR_25_STAT",0,1);
            addSteamStat("INFINITE_VILLAGE_FLOOR_25_STAT",0,1);
            addSteamStat("STORAGE_MAX_STAT",0,1);
            mDBFacade.mSteamworks.addEventListener(SteamEvent.STEAM_RESPONSE,onUserStatsReceived);
            mDBFacade.mSteamworks.addEventListener(SteamEvent.STEAM_RESPONSE,onStoreStats);
         }
      }
      
      private function addSteamAchievement(inAPIName:String) : void
      {
         if(!mIsSteamAchsManagerInitialized)
         {
            return;
         }
         mAchievements.push(SteamAchievement.steamAchievementFactory(inAPIName));
      }
      
      private function addSteamStat(inAPIName:String, inType:int, inUpdateThreshold:int) : void
      {
         if(!mIsSteamAchsManagerInitialized)
         {
            return;
         }
         mStats.add(inAPIName,SteamStats.steamStatFactory(inAPIName,inType,inUpdateThreshold));
      }
      
      private function onUserStatsReceived(e:SteamEvent) : void
      {
         var _loc3_:* = 0;
         var _loc5_:Boolean = false;
         var _loc2_:IMapIterator = null;
         var _loc4_:int = 0;
         if(!mIsSteamAchsManagerInitialized)
         {
            return;
         }
         if(e.req_type == 0)
         {
            Logger.infoch("SteamAchievements","onUserStatsReceived()");
            _loc3_ = 0;
            while(_loc3_ < mAchievements.length)
            {
               _loc5_ = Boolean(mDBFacade.mSteamworks.isAchievement(mAchievements[_loc3_].APIName));
               mAchievements[_loc3_].setIsAchieved(_loc5_);
               _loc3_++;
            }
            _loc2_ = mStats.iterator() as IMapIterator;
            while(_loc2_.next())
            {
               _loc4_ = int(mDBFacade.mSteamworks.getStatInt(_loc2_.key));
               _loc2_.current.setClientIntValue(_loc4_);
            }
         }
      }
      
      private function onStoreStats(e:SteamEvent) : void
      {
         var _loc2_:* = 0;
         var _loc3_:Boolean = false;
         if(!mIsSteamAchsManagerInitialized)
         {
            return;
         }
         Logger.infoch("SteamAchievements","onStoreStats()");
         if(e.req_type == 1)
         {
            _loc2_ = 0;
            while(_loc2_ < mAchievements.length)
            {
               _loc3_ = Boolean(mDBFacade.mSteamworks.isAchievement(mAchievements[_loc2_].APIName));
               mAchievements[_loc2_].setIsAchieved(_loc3_);
               _loc2_++;
            }
         }
      }
      
      private function setStatToSteam(inAPIName:String) : void
      {
         if(!mIsSteamAchsManagerInitialized)
         {
            return;
         }
         var _loc2_:SteamStats = getCurrentSteamStats(inAPIName);
         switch(_loc2_.StatType)
         {
            case 0:
               mDBFacade.mSteamworks.setStatInt(inAPIName,_loc2_.ClientIntValue);
         }
      }
      
      private function storeStatsIfThresholdPassed(oldClientValue:int, newClientValue:int, inThreshold:int) : void
      {
         var _loc5_:int = oldClientValue / inThreshold;
         var _loc4_:int = newClientValue / inThreshold;
         if(_loc5_ != _loc4_)
         {
            storeSteamStats();
         }
      }
      
      private function getCurrentSteamStats(inAPIName:String) : SteamStats
      {
         return mStats.itemFor(inAPIName) as SteamStats;
      }
      
      private function updateSteamStatInt(inAPIName:String, inValue:int, isToIncrease:Boolean) : void
      {
         var _loc4_:SteamStats = getCurrentSteamStats(inAPIName);
         var _loc7_:int = _loc4_.StoreStatsThreshold;
         var _loc5_:int = _loc4_.ClientIntValue;
         if(isToIncrease)
         {
            _loc4_.increaseClientIntValue(inValue);
         }
         else
         {
            _loc4_.setClientIntValue(inValue);
         }
         setStatToSteam(inAPIName);
         var _loc6_:int = _loc4_.ClientIntValue;
         storeStatsIfThresholdPassed(_loc5_,_loc6_,_loc7_);
      }
      
      private function storeSteamStats() : Boolean
      {
         if(!mIsSteamAchsManagerInitialized)
         {
            return false;
         }
         return mDBFacade.mSteamworks.storeStats();
      }
      
      private function isAchievementUnlocked(inAPIName:String) : Boolean
      {
         return Boolean(mDBFacade.mSteamworks.isAchievement(inAPIName));
      }
      
      public function setAchievement(inAPIName:String) : Boolean
      {
         if(!mIsSteamAchsManagerInitialized)
         {
            return false;
         }
         Logger.infoch("SteamAchievements","SetAchievement(" + inAPIName + ")");
         if(isAchievementUnlocked(inAPIName))
         {
            Logger.infoch("SteamAchievements","False. Achievement " + inAPIName + " is already unlocked");
            return false;
         }
         mDBFacade.mSteamworks.setAchievement(inAPIName);
         var _loc2_:Boolean = Boolean(mDBFacade.mSteamworks.isAchievement(inAPIName));
         Logger.infoch("SteamAchievements","Achievement " + inAPIName + " set: " + _loc2_);
         if(_loc2_)
         {
            storeSteamStats();
            return _loc2_;
         }
         return _loc2_;
      }
      
      public function resetStatsAndAchievements() : void
      {
         mDBFacade.mSteamworks.resetAllStats(true);
         mDBFacade.mSteamworks.requestStats();
      }
      
      public function findUnlockHeroAchievementAPIName(hero:GMHero) : String
      {
         if(!mIsSteamAchsManagerInitialized)
         {
            return null;
         }
         return hero.Constant + "_UNLOCK_HERO";
      }
      
      public function unlockFloorCompleted(inLevelConstant:String) : void
      {
         if(!mIsSteamAchsManagerInitialized)
         {
            return;
         }
         var _loc2_:String = inLevelConstant + "_LEVEL_COMPLETE";
         setAchievement(_loc2_);
      }
      
      public function setHeroLevelStat(inLevel:uint, inHero:GMHero) : void
      {
         if(!mIsSteamAchsManagerInitialized)
         {
            return;
         }
         var _loc3_:String = inHero.Constant + "_LEVEL_STAT";
         updateSteamStatInt(_loc3_,inLevel,false);
      }
      
      public function setValueToStatInt(inAPIName:String, inValue:int) : void
      {
         if(!mIsSteamAchsManagerInitialized)
         {
            return;
         }
         updateSteamStatInt(inAPIName,inValue,false);
      }
      
      public function addToStatInt(inAPIName:String, inValue:int) : void
      {
         if(!mIsSteamAchsManagerInitialized)
         {
            return;
         }
         updateSteamStatInt(inAPIName,inValue,true);
      }
      
      public function setHighestFloorAchieved(mMapNode:GMMapNode, inCurrentFloor:uint) : void
      {
         if(!mIsSteamAchsManagerInitialized)
         {
            return;
         }
         if(mMapNode.NodeType != "INFINITE")
         {
            return;
         }
         var _loc3_:int = int(inCurrentFloor);
         var _loc4_:String = mMapNode.Constant + "_FLOOR_25_STAT";
         var _loc5_:int = int(mDBFacade.mSteamworks.getStatInt(_loc4_));
         if(inCurrentFloor > _loc5_)
         {
            updateSteamStatInt(_loc4_,_loc3_,false);
         }
      }
      
      public function setMaxStorageStat(previousBucketsWeapon:int, currentBucketsWeapon:int) : void
      {
         var _loc4_:int = 15;
         var _loc3_:int = 30;
         var _loc5_:int = Math.abs(currentBucketsWeapon - _loc3_) / _loc4_;
         setValueToStatInt("STORAGE_MAX_STAT",_loc5_);
      }
      
      public function checkStorageAchievements() : void
      {
         var _loc2_:int = int(mDBFacade.dbAccountInfo.inventoryInfo.storageLimitWeapon);
         var _loc3_:int = 30;
         var _loc1_:int = 120;
         var _loc4_:int = 6;
         if(_loc2_ > _loc3_)
         {
            mDBFacade.steamAchievementsManager.setAchievement("STORAGE_EXPAND_FIRST_TIME");
         }
         if(_loc2_ == _loc1_)
         {
            mDBFacade.steamAchievementsManager.setValueToStatInt("STORAGE_MAX_STAT",_loc4_);
         }
      }
   }
}

