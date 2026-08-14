package Combat.Attack
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import Brain.Clock.GameClock;
   import Brain.Logger.Logger;
   import Brain.WorkLoop.Task;
   import Facade.DBFacade;
   
   public class TimeScaleTimelineAction extends AttackTimelineAction
   {
      
      public static const TYPE:String = "timeScale";
      
      private var mTask:Task;
      
      private var mDuration:Number = 0;
      
      private var mTimeScale:Number = 1;
      
      public function TimeScaleTimelineAction(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, parameterJson:Object)
      {
         super(actorGameObject,actorView,dbFacade);
         if(parameterJson.duration == null)
         {
            Logger.error("TimeScaleTimelineAction: Must specify duration");
         }
         if(parameterJson.timeScale == null)
         {
            Logger.error("TimeScaleTimelineAction: Must specify timeScale");
         }
         var _loc5_:uint = 24;
         mDuration = parameterJson.duration / _loc5_;
         mTimeScale = parameterJson.timeScale;
      }
      
      public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, parameterJson:Object) : TimeScaleTimelineAction
      {
         if(actorGameObject.isOwner)
         {
            return new TimeScaleTimelineAction(actorGameObject,actorView,dbFacade,parameterJson);
         }
         return null;
      }
      
      override public function execute(timeline:ScriptTimeline) : void
      {
         super.execute(timeline);
         this.mDBFacade.gameClock.timeScale = mTimeScale;
         mTask = mWorkComponent.doLater(mDuration,resetTimeScale);
      }
      
      private function resetTimeScale(gameClock:GameClock) : void
      {
         this.mDBFacade.gameClock.timeScale = 1;
      }
      
      override public function destroy() : void
      {
         super.destroy();
      }
      
      override public function stop() : void
      {
         this.mDBFacade.gameClock.timeScale = 1;
         if(mTask)
         {
            mTask.destroy();
            mTask = null;
         }
      }
   }
}

