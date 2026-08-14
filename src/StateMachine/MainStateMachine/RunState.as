package StateMachine.MainStateMachine
{
   import Brain.Event.EventComponent;
   import Brain.Logger.Logger;
   import Brain.StateMachine.State;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Brain.WorkLoop.Task;
   import Events.BusterPointsEvent;
   import Events.ClientExitCompleteEvent;
   import Events.FirstCooldownEvent;
   import Events.FirstRepeaterEvent;
   import Events.FirstScalingEvent;
   import Events.FirstTreasureCollectedEvent;
   import Events.FirstTreasureNearbyEvent;
   import Events.GameObjectEvent;
   import Events.LEClientEvent;
   import Facade.DBFacade;
   import UI.Hud.UITutorialController;
   import UI.UINewsFeed.UINewsFeedController;
   import flash.events.Event;
   
   public class RunState extends State
   {
      
      public static const NAME:String = "RunState";
      
      public static const ENTER_RUN_STATE_EVENT:String = "ENTER_RUN_STATE_EVENT";
      
      protected var mDBFacade:DBFacade;
      
      private var mGoToSplashScreenCallback:Function;
      
      private var mEventComponent:EventComponent;
      
      private var mLogicalWorkComponent:LogicalWorkComponent;
      
      private var mDungeonTutorialWaitTask:Task;
      
      private var mTutorialController:UITutorialController;
      
      protected var mNewsFeedController:UINewsFeedController;
      
      private var mMovementTutorialStarted:Boolean = false;
      
      private var mChargeTutorialStarted:Boolean = false;
      
      private var mCooldownTutorialStarted:Boolean = false;
      
      public function RunState(dbFacade:DBFacade, goToSplashScreenCallback:Function)
      {
         super("RunState");
         mDBFacade = dbFacade;
         mGoToSplashScreenCallback = goToSplashScreenCallback;
         mEventComponent = new EventComponent(mDBFacade);
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"RunState");
         mTutorialController = new UITutorialController(mDBFacade);
      }
      
      override public function destroy() : void
      {
         mEventComponent.destroy();
         mLogicalWorkComponent.destroy();
         mNewsFeedController.destroy();
         mNewsFeedController = null;
         mGoToSplashScreenCallback = null;
         mDBFacade = null;
         mTutorialController.destroy();
         super.destroy();
      }
      
      override public function enterState() : void
      {
         var dungeonsCompletedCount:uint;
         var eventName:String;
         Logger.debug("MAIN STATE MACHINE TRANSITION -- ENTERING RUN STATE");
         super.enterState();
         dungeonsCompletedCount = mDBFacade.dbAccountInfo.getDungeonsCompleted();
         mDBFacade.metrics.log("DungeonRunState",{});
         if(!mNewsFeedController)
         {
            mNewsFeedController = new UINewsFeedController(mDBFacade);
         }
         mNewsFeedController.startFeedTask();
         mDBFacade.regainFocus();
         mDBFacade.dbAccountInfo.setPresenceTask("DUNGEON");
         mEventComponent.dispatchEvent(new Event("ENTER_RUN_STATE_EVENT"));
         mEventComponent.addListener("CLIENT_EXIT_COMPLETE",gracefulSocketClose);
         if(!mDBFacade.dbAccountInfo.dbAccountParams.hasDungeonBusterTutorialParam())
         {
            eventName = GameObjectEvent.uniqueEvent("BusterPointEvent_BUSTER_POINTS_UPDATE",mDBFacade.dbAccountInfo.activeAvatarInfo.id);
            mEventComponent.addListener(eventName,function(param1:BusterPointsEvent):void
            {
               if(param1.busterPoints >= param1.maxBusterPoints)
               {
                  mEventComponent.removeListener(eventName);
                  mTutorialController.queueTutorial("BUSTER_TUTORIAL");
               }
            });
         }
         if(dungeonsCompletedCount >= 1)
         {
            if(!mDBFacade.dbAccountInfo.dbAccountParams.hasLootSharingTutorialParam())
            {
               mTutorialController.queueTutorial("LOOT_SHARING_TUTORIAL");
            }
            if(!mDBFacade.dbAccountInfo.dbAccountParams.hasChestNearbyTutorialParam())
            {
               mEventComponent.addListener("FirstTreasureNearby",function(param1:FirstTreasureNearbyEvent):void
               {
                  mEventComponent.removeListener("FirstTreasureNearby");
                  mTutorialController.queueTutorial("CHEST_TUTORIAL_NEARBY");
               });
            }
            if(!mDBFacade.dbAccountInfo.dbAccountParams.hasChestCollectedTutorialParam())
            {
               mEventComponent.addListener("FirstTreasureCollected",function(param1:FirstTreasureCollectedEvent):void
               {
                  mEventComponent.removeListener("FirstTreasureCollected");
                  mTutorialController.endChestTutorial();
               });
            }
            if(!mDBFacade.dbAccountInfo.dbAccountParams.hasCooldownTutorialParam())
            {
               mEventComponent.addListener("FirstCooldown",function(param1:FirstCooldownEvent):void
               {
                  mEventComponent.removeListener("FirstCooldown");
                  mTutorialController.queueTutorial("COOLDOWN_TUTORIAL");
               });
            }
         }
         if(!mDBFacade.dbAccountInfo.dbAccountParams.hasScalingTutorialParam())
         {
            mEventComponent.addListener("FirstScaling",function(param1:FirstScalingEvent):void
            {
               mEventComponent.removeListener("FirstScaling");
               mTutorialController.queueTutorial("SCALING_TUTORIAL");
            });
         }
         if(!mDBFacade.dbAccountInfo.dbAccountParams.hasRepeaterTutorialParam())
         {
            mEventComponent.addListener("FirstRepeater",function(param1:FirstRepeaterEvent):void
            {
               mEventComponent.removeListener("FirstRepeater");
               mTutorialController.queueTutorial("REPEATER_TUTORIAL");
            });
         }
         if(dungeonsCompletedCount >= 7)
         {
            if(!mDBFacade.dbAccountInfo.dbAccountParams.hasSuperWeakParam())
            {
               mTutorialController.queueTutorial("SUPER_WEAK_TUTORIAL");
            }
         }
         mDBFacade.eventManager.addEventListener("SEND_EVENT",receivedClientEvent);
      }
      
      private function receivedClientEvent(lecEvt:LEClientEvent) : void
      {
         if(!mMovementTutorialStarted && lecEvt.eventName == "FIRE_MOVEMENT_TUTORIAL")
         {
            if(!mDBFacade.dbAccountInfo.dbAccountParams.hasMovementTutorialParam())
            {
               mTutorialController.queueTutorial("MOVEMENT_TUTORIAL");
            }
            mMovementTutorialStarted = true;
         }
         else if(!mChargeTutorialStarted && lecEvt.eventName == "FIRE_CHARGE_TUTORIAL")
         {
            if(!mDBFacade.dbAccountInfo.dbAccountParams.hasChargeTutorialParam())
            {
               mTutorialController.queueTutorial("CHARGE_TUTORIAL");
            }
            mChargeTutorialStarted = true;
         }
         else if(!mCooldownTutorialStarted && lecEvt.eventName == "START_COOLDOWN_TUTORIAL")
         {
            if(!mDBFacade.dbAccountInfo.dbAccountParams.hasCooldownTutorialParam())
            {
               mEventComponent.addListener("FirstCooldown",function(param1:FirstCooldownEvent):void
               {
                  mEventComponent.removeListener("FirstCooldown");
                  mTutorialController.queueTutorial("COOLDOWN_TUTORIAL");
               });
            }
            mCooldownTutorialStarted = true;
         }
      }
      
      private function gracefulSocketClose(event:ClientExitCompleteEvent) : void
      {
         mDBFacade.mainStateMachine.enterReloadTownState();
      }
      
      override public function exitState() : void
      {
         mNewsFeedController.stopFeedTask();
         mEventComponent.removeAllListeners();
         mDBFacade.assetRepository.removeCacheForAllSpriteSheetAssets();
         super.exitState();
      }
   }
}

