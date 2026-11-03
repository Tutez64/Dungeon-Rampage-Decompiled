package SteamAchievements
{
   import Account.AvatarInfo;
   import Account.ItemInfo;
   import Collections.IMapIterator;
   import Collections.Map;
   import DistributedObjects.HeroGameObject;
   import Facade.DBFacade;
   import GameMasterDictionary.GMMapNode;
   
   public class SteamAchievementsHelper
   {
      
      private static const ULTIMATE_RAMPAGE_TARGET_FLOOR:int = 25;
      
      private static const INITIAL_STORAGE_SLOTS:int = 15;
      
      private static const MAX_LEVEL_BEFORE_ASCENSION:uint = 100;
      
      private var mDBFacade:DBFacade;
      
      public function SteamAchievementsHelper(inDBFacade:DBFacade)
      {
         super();
         mDBFacade = inDBFacade;
      }
      
      public function unlockOwnedHeroes(inAvatars:Map) : void
      {
         var _loc3_:AvatarInfo = null;
         if(inAvatars == null)
         {
            return;
         }
         var _loc2_:IMapIterator = inAvatars.iterator() as IMapIterator;
         while(_loc2_.hasNext())
         {
            _loc3_ = _loc2_.next() as AvatarInfo;
            if(_loc3_ != null && _loc3_.gmHero != null && _loc3_.gmHero.Constant != "BERSERKER")
            {
               unlockAchievement(SteamAPINames.getUnlockHeroAchievementAPIName(_loc3_.gmHero.Constant));
            }
         }
      }
      
      public function updateHeroLevelStat(inHeroConstant:String, inLevel:uint, inAscensionLevel:uint) : void
      {
         var _loc4_:uint = Math.min(inLevel,AvatarInfo.MAX_EFFECTIVE_LEVEL);
         if(inAscensionLevel > 0)
         {
            _loc4_ = Math.max(_loc4_,100);
         }
         setHighestStatValueAchieved(_loc4_,SteamAPINames.getHighestLevelHeroStatAPIName(inHeroConstant));
      }
      
      public function updateHeroProgressStats(inAvatars:Map) : void
      {
         var _loc3_:AvatarInfo = null;
         if(inAvatars == null)
         {
            return;
         }
         var _loc2_:IMapIterator = inAvatars.iterator() as IMapIterator;
         while(_loc2_.hasNext())
         {
            _loc3_ = _loc2_.next() as AvatarInfo;
            if(_loc3_ != null && _loc3_.gmHero != null)
            {
               updateHeroLevelStat(_loc3_.gmHero.Constant,_loc3_.effectiveLevel,_loc3_.mAscensionLevel);
               setHighestStatValueAchieved(_loc3_.mAscensionLevel,SteamAPINames.getAscensionHeroStatAPIName(_loc3_.gmHero.Constant));
            }
         }
      }
      
      public function updateMapsAtFloor25Stat(inMapNode:GMMapNode) : Boolean
      {
         var _loc5_:String = null;
         if(inMapNode.NodeType != GMMapNode.INFINITE_NODE_TYPE || mDBFacade.steamAchievementsManager == null)
         {
            return false;
         }
         var _loc2_:int = 0;
         for each(var _loc3_:GMMapNode in mDBFacade.gameMaster.MapNodes)
         {
            if(_loc3_.NodeType == GMMapNode.INFINITE_NODE_TYPE)
            {
               _loc5_ = SteamAPINames.getUltimateRampageHighestFloorStatAPIName(_loc3_.Constant);
               if(mDBFacade.steamAchievementsManager.getCurrentSteamStatIntValue(_loc5_) >= 25)
               {
                  _loc2_++;
               }
            }
         }
         var _loc4_:int = mDBFacade.steamAchievementsManager.getCurrentSteamStatIntValue("ULTIMATE_RAMPAGE_MAPS_AT_FLOOR_25");
         if(_loc2_ != _loc4_)
         {
            return setValueToStatInt(_loc2_,"ULTIMATE_RAMPAGE_MAPS_AT_FLOOR_25");
         }
         return false;
      }
      
      public function setHighestStatValueAchieved(inCurrentValue:int, inStatAPIName:String) : void
      {
         var _loc3_:int = 0;
         if(mDBFacade.steamAchievementsManager)
         {
            _loc3_ = mDBFacade.steamAchievementsManager.getCurrentSteamStatIntValue(inStatAPIName);
            if(inCurrentValue > _loc3_)
            {
               setValueToStatInt(inCurrentValue,inStatAPIName);
            }
         }
      }
      
      public function checkHighestUltimateRampageFloorAchieved(inMapNode:GMMapNode, inCurrentFloor:uint) : void
      {
         if(inMapNode.NodeType != GMMapNode.INFINITE_NODE_TYPE)
         {
            return;
         }
         var _loc3_:String = SteamAPINames.getUltimateRampageHighestFloorStatAPIName(inMapNode.Constant);
         setHighestStatValueAchieved(int(inCurrentFloor),_loc3_);
      }
      
      public function checkStorageAchievements(inStorageSlots:int) : Boolean
      {
         var _loc2_:Boolean = false;
         if(inStorageSlots > 15)
         {
            _loc2_ = unlockAchievement("STORAGE_EXPAND_FIRST_TIME");
         }
         setHighestStatValueAchieved(inStorageSlots,"STORAGE_SLOTS");
         return _loc2_;
      }
      
      public function unlockDarkBarrowsAsVampireHunter(inHeroConstant:String, inMapConstant:String) : void
      {
         if(inHeroConstant == "VAMPIRE_HUNTER" && inMapConstant == "CATACOMBS_BOSS_2")
         {
            unlockAchievement("VAMPIRE_HUNTER_CHALLENGE_DEFEAT_DARK_BARROWS-2-6");
         }
      }
      
      public function unlockUpgradeStat(amount:uint) : void
      {
         var _loc2_:int = int(amount);
         if(_loc2_ > 0)
         {
            unlockAchievement("UPGRADE_HERO");
         }
      }
      
      private function unlockBerserkerBossChallenge(inHeroWeapons:Vector.<ItemInfo>) : void
      {
         var _loc3_:String = null;
         if(inHeroWeapons.length == 1)
         {
            for each(var _loc2_:ItemInfo in inHeroWeapons)
            {
               _loc3_ = _loc2_.gmWeaponItem.MasterType;
               if(_loc3_ == "HAMMER_TYPE")
               {
                  unlockAchievement("BESERKER_CHALLENGE_ONLY_HAMMER");
               }
            }
         }
      }
      
      private function unlockRangerBossChallenge(inHeroWeapons:Vector.<ItemInfo>) : void
      {
         var _loc3_:String = null;
         if(inHeroWeapons.length != 0)
         {
            for each(var _loc2_:ItemInfo in inHeroWeapons)
            {
               _loc3_ = _loc2_.gmWeaponItem.MasterType;
               if(_loc3_ == "BOW_TYPE")
               {
                  return;
               }
            }
            unlockAchievement("RANGER_CHALLENGE_NO_BOW");
         }
      }
      
      private function unlockBattleChefBossChallenge(inHeroWeapons:Vector.<ItemInfo>) : void
      {
         var _loc3_:String = null;
         if(inHeroWeapons.length != 0)
         {
            for each(var _loc2_:ItemInfo in inHeroWeapons)
            {
               _loc3_ = _loc2_.gmWeaponItem.MasterType;
               if(_loc3_ == "FRYING_PAN_TYPE" || _loc3_ == "COOKING_TYPE")
               {
                  return;
               }
            }
            unlockAchievement("BATTLE_CHEF_CHALLENGE_NO_POT_NO_PAN");
         }
      }
      
      private function unlockSorcererBossChallenge(inHeroWeapons:Vector.<ItemInfo>) : void
      {
         var _loc3_:String = null;
         if(inHeroWeapons.length != 0)
         {
            for each(var _loc2_:ItemInfo in inHeroWeapons)
            {
               _loc3_ = _loc2_.gmWeaponItem.MasterType;
               if(_loc3_ == "LIGHTNING_STAFF_TYPE" || _loc3_ == "LIGHTNING_MAGIC_TYPE")
               {
                  return;
               }
            }
            unlockAchievement("SORCERER_CHALLENGE_NO_STAFF_NO_TOME");
         }
      }
      
      public function unlockBossChallengeWithUncommonWeapon(inMapNode:GMMapNode, inHeroConstant:String, inHeroWeapons:Vector.<ItemInfo>) : void
      {
         if(inMapNode.NodeType == "BOSS" && inMapNode.Constant != "TUTORIAL")
         {
            switch(inHeroConstant)
            {
               case "BERSERKER":
                  unlockBerserkerBossChallenge(inHeroWeapons);
                  break;
               case "RANGER":
                  unlockRangerBossChallenge(inHeroWeapons);
                  break;
               case "BATTLE_CHEF":
                  unlockBattleChefBossChallenge(inHeroWeapons);
                  break;
               case "SORCERER":
                  unlockSorcererBossChallenge(inHeroWeapons);
            }
         }
      }
      
      public function unlockAchievement(inAPIName:String) : Boolean
      {
         var _loc2_:Boolean = false;
         if(mDBFacade.steamAchievementsManager)
         {
            _loc2_ = mDBFacade.steamAchievementsManager.unlockAchievement(inAPIName);
         }
         return _loc2_;
      }
      
      public function setValueToStatInt(inValue:Number, inStatAPIName:String) : Boolean
      {
         var _loc3_:Boolean = false;
         if(mDBFacade.steamAchievementsManager)
         {
            _loc3_ = mDBFacade.steamAchievementsManager.updateSteamStatInt(inStatAPIName,inValue,false);
         }
         return _loc3_;
      }
      
      public function addValueToStatInt(inValue:Number, inStatAPIName:String) : Boolean
      {
         var _loc3_:Boolean = false;
         if(mDBFacade.steamAchievementsManager)
         {
            _loc3_ = mDBFacade.steamAchievementsManager.updateSteamStatInt(inStatAPIName,inValue,true);
         }
         return _loc3_;
      }
      
      public function unlockFinishFloorWithThreeTeammatesDowned(mRemoteHeroes:Map) : void
      {
         var _loc4_:int = 0;
         var _loc5_:HeroGameObject = null;
         var _loc3_:IMapIterator = null;
         var _loc2_:uint = mRemoteHeroes.size;
         if(_loc2_ >= 3)
         {
            _loc4_ = 0;
            _loc3_ = mRemoteHeroes.iterator() as IMapIterator;
            while(_loc3_.hasNext())
            {
               _loc5_ = _loc3_.next() as HeroGameObject;
               if(_loc5_.isDead() || _loc5_.isInReviveState())
               {
                  _loc4_++;
               }
               if(_loc4_ >= 3)
               {
                  unlockAchievement("CHALLENGE_DUNGEON_COMPLETE_3_DOWNED_TEAMMATES");
               }
            }
         }
      }
      
      public function unlockThreeLegendaryWeapons(inEquippedItems:Vector.<ItemInfo>) : void
      {
         var _loc3_:int = 0;
         if(inEquippedItems.length >= 3)
         {
            _loc3_ = 0;
            for each(var _loc2_:ItemInfo in inEquippedItems)
            {
               if(_loc2_.rarity.Constant == "LEGENDARY")
               {
                  _loc3_++;
               }
            }
            if(_loc3_ >= 3)
            {
               unlockAchievement("EQUIP_3_LEGENDARY_WEAPONS");
            }
         }
      }
      
      public function finishDungeonWithFriends(mRemoteHeroes:Map, CurrentPlayerFriends:Map) : void
      {
         var _loc4_:HeroGameObject = null;
         var _loc3_:IMapIterator = mRemoteHeroes.iterator() as IMapIterator;
         while(_loc3_.hasNext())
         {
            _loc4_ = _loc3_.next() as HeroGameObject;
            if(_loc4_ != null && CurrentPlayerFriends.hasKey(_loc4_.playerID))
            {
               addValueToStatInt(1,"DUNGEONS_COMPLETED_WITH_FRIENDS");
               return;
            }
         }
      }
   }
}

