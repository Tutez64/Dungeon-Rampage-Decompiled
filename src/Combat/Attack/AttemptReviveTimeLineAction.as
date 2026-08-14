package Combat.Attack
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import Brain.Clock.GameClock;
   import Brain.WorkLoop.Task;
   import Facade.DBFacade;
   
   public class AttemptReviveTimeLineAction extends AttackTimelineAction
   {
      
      public static const TYPE:String = "attemptRevive";
      
      private static const REVIVE_KEYCODE:int = 32;
      
      private var mKeyboardCheckTask:Task;
      
      private var mDeltaPerFrame:Number;
      
      public function AttemptReviveTimeLineAction(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade)
      {
         super(actorGameObject,actorView,dbFacade);
      }
      
      public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, actionObj:Object) : AttemptReviveTimeLineAction
      {
         return new AttemptReviveTimeLineAction(actorGameObject,actorView,dbFacade);
      }
      
      private function keyboardCheck(gameClock:GameClock) : void
      {
         var _loc2_:Boolean = isReviveActionDown();
         if(!_loc2_ || !this.mTimeline.targetActor.isInReviveState())
         {
            mTimeline.stop();
         }
      }
      
      private function isReviveActionDown() : Boolean
      {
         return mDBFacade.inputManager.check(32) || mDBFacade.steamInputManager.heldAction("revive_ally");
      }
      
      override public function execute(timeline:ScriptTimeline) : void
      {
         super.execute(timeline);
         mKeyboardCheckTask = mWorkComponent.doEveryFrame(keyboardCheck);
      }
      
      override public function stop() : void
      {
         if(mKeyboardCheckTask)
         {
            mKeyboardCheckTask.destroy();
            mKeyboardCheckTask = null;
         }
      }
   }
}

