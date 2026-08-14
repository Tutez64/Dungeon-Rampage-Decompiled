package Account
{
   import Brain.Logger.Logger;
   import Brain.jsonRPC.JSONRPCService;
   import Facade.DBFacade;
   
   public class DBAccountParams
   {
      
      private static const BETA_PLAYER:uint = 0;
      
      private static const CHARGE:uint = 1;
      
      private static const REPEATER:uint = 2;
      
      private static const SCALING:uint = 3;
      
      private static const COOLDOWN:uint = 4;
      
      private static const MOVEMENT:uint = 5;
      
      private static const REVIVE:uint = 6;
      
      private static const LOOT_SHARING:uint = 7;
      
      private static const CHEST_NEARBY:uint = 8;
      
      private static const CHEST_COLLECTED:uint = 9;
      
      private static const DUNGEON_BUSTER:uint = 10;
      
      private static const BETA_REWARDS:uint = 11;
      
      private static const KEY_INTRO:uint = 12;
      
      private static const LIFESTREET:uint = 13;
      
      private static const ACHIEVEMENT_1:uint = 14;
      
      private static const ACHIEVEMENT_2:uint = 15;
      
      private static const ACHIEVEMENT_3:uint = 16;
      
      private static const ACHIEVEMENT_4:uint = 17;
      
      private static const ACHIEVEMENT_5:uint = 18;
      
      private static const ACHIEVEMENT_6:uint = 19;
      
      private static const SUPER_WEAK:uint = 20;
      
      private static var staticDBAccountParamsHelper:DBAccountParamsHelper;
      
      private var mDBAccountInfo:DBAccountInfo;
      
      private var mDBFacade:DBFacade;
      
      public function DBAccountParams(dbFacade:DBFacade, accountInfo:DBAccountInfo)
      {
         super();
         mDBFacade = dbFacade;
         mDBAccountInfo = accountInfo;
         if(staticDBAccountParamsHelper == null)
         {
            staticDBAccountParamsHelper = new DBAccountParamsHelper();
            staticDBAccountParamsHelper.saved_account_flags = mDBAccountInfo.account_flags;
            staticDBAccountParamsHelper.current_account_flags = mDBAccountInfo.account_flags;
         }
      }
      
      public function hasParam(paramNum:uint) : Boolean
      {
         var _loc2_:Boolean = (staticDBAccountParamsHelper.current_account_flags & 1 << paramNum) != 0;
         return (staticDBAccountParamsHelper.current_account_flags & 1 << paramNum) != 0;
      }
      
      public function setParam(paramNum:uint, updateImmediately:Boolean = true) : void
      {
         staticDBAccountParamsHelper.current_account_flags |= 1 << paramNum;
         if(updateImmediately)
         {
            flushParams();
         }
      }
      
      public function flushParams() : void
      {
         var rpcSuccessCallback:Function;
         var rpcFailureCallback:Function;
         var rpcFunc:Function;
         if(staticDBAccountParamsHelper.saved_account_flags == staticDBAccountParamsHelper.current_account_flags)
         {
            return;
         }
         rpcSuccessCallback = function(param1:*):void
         {
         };
         rpcFailureCallback = function(param1:*):void
         {
            Logger.warn("Flushing Params failed!");
         };
         rpcFunc = JSONRPCService.getFunction("addAccountBits",mDBFacade.rpcRoot + "account");
         rpcFunc(mDBFacade.dbAccountInfo.id,mDBFacade.validationToken,staticDBAccountParamsHelper.current_account_flags,rpcSuccessCallback,rpcFailureCallback);
         staticDBAccountParamsHelper.saved_account_flags = staticDBAccountParamsHelper.current_account_flags;
      }
      
      public function hasBetaPlayerParam() : Boolean
      {
         return hasParam(0);
      }
      
      public function hasChargeTutorialParam() : Boolean
      {
         return hasParam(1);
      }
      
      public function setChargeTutorialParam() : void
      {
         setParam(1,false);
      }
      
      public function hasRepeaterTutorialParam() : Boolean
      {
         return hasParam(2);
      }
      
      public function setRepeaterTutorialParam() : void
      {
         setParam(2,false);
      }
      
      public function hasScalingTutorialParam() : Boolean
      {
         return hasParam(3);
      }
      
      public function setScalingTutorialParam() : void
      {
         setParam(3,false);
      }
      
      public function hasCooldownTutorialParam() : Boolean
      {
         return hasParam(4);
      }
      
      public function setCooldownTutorialParam() : void
      {
         setParam(4,false);
      }
      
      public function hasMovementTutorialParam() : Boolean
      {
         return hasParam(5);
      }
      
      public function setMovementTutorialParam() : void
      {
         setParam(5,false);
      }
      
      public function hasReviveTutorialParam() : Boolean
      {
         return hasParam(6);
      }
      
      public function setReviveTutorialParam() : void
      {
         setParam(6,false);
      }
      
      public function hasLootSharingTutorialParam() : Boolean
      {
         return hasParam(7);
      }
      
      public function setLootSharingTutorialParam() : void
      {
         setParam(7,false);
      }
      
      public function hasChestNearbyTutorialParam() : Boolean
      {
         return hasParam(8);
      }
      
      public function setChestNearbyTutorialParam() : void
      {
         setParam(8,false);
      }
      
      public function hasChestCollectedTutorialParam() : Boolean
      {
         return hasParam(9);
      }
      
      public function setChestCollectedTutorialParam() : void
      {
         setParam(9,false);
      }
      
      public function hasDungeonBusterTutorialParam() : Boolean
      {
         return hasParam(10);
      }
      
      public function setDungeonBusterTutorialParam() : void
      {
         setParam(10,false);
      }
      
      public function hasBetaRewardsParam() : Boolean
      {
         return hasParam(11);
      }
      
      public function setBetaRewardsParam() : void
      {
         setParam(11,true);
      }
      
      public function hasKeyIntroParam() : Boolean
      {
         return hasParam(12);
      }
      
      public function setKeyIntroParam() : void
      {
         setParam(12,true);
      }
      
      public function hasLifestreetParam() : Boolean
      {
         return hasParam(13);
      }
      
      public function setLifestreetParam() : void
      {
         setParam(13,true);
      }
      
      public function hasAchievement(achievementNum:uint) : Boolean
      {
         switch(int(achievementNum) - 1)
         {
            case 0:
               return hasParam(14);
            case 1:
               return hasParam(15);
            case 2:
               return hasParam(16);
            case 3:
               return hasParam(17);
            case 4:
               return hasParam(18);
            case 5:
               return hasParam(19);
            default:
               return false;
         }
      }
      
      public function setAchievement(achievementNum:uint) : void
      {
         switch(int(achievementNum) - 1)
         {
            case 0:
               return setParam(14,true);
            case 1:
               return setParam(15,true);
            case 2:
               return setParam(16,true);
            case 3:
               return setParam(17,true);
            case 4:
               return setParam(18,true);
            case 5:
               return setParam(19,true);
            default:
               return;
         }
      }
      
      public function hasSuperWeakParam() : Boolean
      {
         return hasParam(20);
      }
      
      public function setSuperWeakParam() : void
      {
         setParam(20,true);
      }
   }
}

class DBAccountParamsHelper
{
   
   public var saved_account_flags:uint;
   
   public var current_account_flags:uint;
   
   public function DBAccountParamsHelper()
   {
      super();
   }
}
