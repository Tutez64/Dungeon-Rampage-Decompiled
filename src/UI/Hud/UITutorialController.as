package UI.Hud
{
   import Brain.Clock.GameClock;
   import Brain.Event.EventComponent;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Brain.WorkLoop.Task;
   import Facade.DBFacade;
   import StateMachine.MainStateMachine.DungeonTutorial;
   import flash.events.Event;
   import org.as3commons.collections.Map;
   
   public class UITutorialController
   {
      
      private var mDBFacade:DBFacade;
      
      private var mDungeonTutorial:DungeonTutorial;
      
      private var mTutorialsCallbackQueue:Vector.<Function>;
      
      private var mLogicalWorkComponent:LogicalWorkComponent;
      
      private var mEventComponent:EventComponent;
      
      private var mTutorialTask:Task;
      
      private var mTutorialEventMap:Map;
      
      public function UITutorialController(dbFacade:DBFacade)
      {
         super();
         mDBFacade = dbFacade;
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"UITutorialController");
         mEventComponent = new EventComponent(mDBFacade);
         mTutorialsCallbackQueue = new Vector.<Function>();
         mTutorialEventMap = new Map();
         mEventComponent.addListener("DUNGEON_FLOOR_DESTROY",function(param1:Event):void
         {
            flushTutorialQueue();
            destroyTutorial();
         });
      }
      
      public function queueTutorial(type:String) : void
      {
         if(mTutorialEventMap.itemFor(type))
         {
            return;
         }
         switch(type)
         {
            case "COOLDOWN_TUTORIAL":
               mTutorialsCallbackQueue.push(startCooldownTutorial);
               break;
            case "SCALING_TUTORIAL":
               mTutorialsCallbackQueue.push(startScalingTutorial);
               break;
            case "REPEATER_TUTORIAL":
               mTutorialsCallbackQueue.push(startRepeaterTutorial);
               break;
            case "CHEST_TUTORIAL_NEARBY":
               mTutorialsCallbackQueue.push(startChestTutorial);
               break;
            case "BUSTER_TUTORIAL":
               mTutorialsCallbackQueue.push(startBusterTutorial);
               break;
            case "CHARGE_TUTORIAL":
               mTutorialsCallbackQueue.push(startChargeTutorial);
               break;
            case "LOOT_SHARING_TUTORIAL":
               mTutorialsCallbackQueue.push(startLootSharingTutorial);
               break;
            case "MOVEMENT_TUTORIAL":
               mTutorialsCallbackQueue.push(startMovementTutorial);
               break;
            case "SUPER_WEAK_TUTORIAL":
               mTutorialsCallbackQueue.push(startSuperWeakTutorial);
         }
         mTutorialEventMap.add(type,1);
         if(!mTutorialTask)
         {
            mTutorialTask = mLogicalWorkComponent.doEverySeconds(1,checkTutorials);
         }
      }
      
      private function checkTutorials(gameClock:GameClock) : void
      {
         if(mTutorialsCallbackQueue.length == 0)
         {
            if(mTutorialTask)
            {
               mTutorialTask.destroy();
            }
            mTutorialTask = null;
         }
         if(mDungeonTutorial)
         {
            if(!mDungeonTutorial.isTutorialComplete)
            {
               return;
            }
            destroyTutorial();
         }
         var _loc2_:Function = mTutorialsCallbackQueue.shift();
         if(_loc2_ != null)
         {
            _loc2_();
         }
      }
      
      private function destroyTutorial() : void
      {
         if(mDungeonTutorial)
         {
            mDungeonTutorial.destroy();
            mDungeonTutorial = null;
         }
      }
      
      private function startChestTutorial() : void
      {
         mDungeonTutorial = new DungeonTutorial(mDBFacade);
         mDungeonTutorial.showChestTutorial();
      }
      
      private function startCooldownTutorial() : void
      {
         mDungeonTutorial = new DungeonTutorial(mDBFacade);
         mDungeonTutorial.showCooldownTutorial();
      }
      
      private function startScalingTutorial() : void
      {
         mDungeonTutorial = new DungeonTutorial(mDBFacade);
         mDungeonTutorial.showScalingTutorial();
      }
      
      private function startRepeaterTutorial() : void
      {
         mDungeonTutorial = new DungeonTutorial(mDBFacade);
         mDungeonTutorial.showRepeaterTutorial();
      }
      
      public function endChestTutorial() : void
      {
         if(mDungeonTutorial)
         {
            mDungeonTutorial.finishChestTutorial();
         }
      }
      
      private function startBusterTutorial() : void
      {
         mDungeonTutorial = new DungeonTutorial(mDBFacade);
         mDungeonTutorial.showBusterTutorial();
      }
      
      private function startChargeTutorial() : void
      {
         mDungeonTutorial = new DungeonTutorial(mDBFacade);
         mDungeonTutorial.showChargeTutorial();
      }
      
      private function startMovementTutorial() : void
      {
         mDungeonTutorial = new DungeonTutorial(mDBFacade);
         mDungeonTutorial.showMovementTutorial();
      }
      
      private function startLootSharingTutorial() : void
      {
         mDungeonTutorial = new DungeonTutorial(mDBFacade);
         mDungeonTutorial.showLootSharingTutorial();
      }
      
      private function startSuperWeakTutorial() : void
      {
         mDungeonTutorial = new DungeonTutorial(mDBFacade);
         mDungeonTutorial.showSuperWeakTutorial("tutorial_enemy_defense1");
      }
      
      public function flushTutorialQueue() : void
      {
         var _loc2_:* = 0;
         var _loc1_:Function = null;
         if(mTutorialTask)
         {
            mTutorialTask.destroy();
         }
         mTutorialTask = null;
         _loc2_ = 0;
         while(_loc2_ < mTutorialsCallbackQueue.length)
         {
            _loc1_ = mTutorialsCallbackQueue.shift();
            _loc1_ = null;
         }
      }
      
      public function destroy() : void
      {
         mDBFacade = null;
         flushTutorialQueue();
         destroyTutorial();
         if(mLogicalWorkComponent)
         {
            mLogicalWorkComponent.destroy();
         }
         mLogicalWorkComponent = null;
         if(mEventComponent)
         {
            mEventComponent.destroy();
         }
         mEventComponent = null;
      }
   }
}

