package Combat.Attack
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import Facade.DBFacade;
   
   public class RunIdleMonitorTimelineAction extends AttackTimelineAction
   {
      
      public static const TYPE:String = "runIdleMonitor";
      
      public function RunIdleMonitorTimelineAction(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade)
      {
         super(actorGameObject,actorView,dbFacade);
      }
      
      public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, actionObj:Object) : RunIdleMonitorTimelineAction
      {
         return new RunIdleMonitorTimelineAction(actorGameObject,actorView,dbFacade);
      }
      
      override public function execute(timeline:ScriptTimeline) : void
      {
         super.execute(timeline);
         mActorGameObject.startRunIdleMonitoring();
      }
      
      override public function stop() : void
      {
         mActorGameObject.stopRunIdleMonitoring();
      }
   }
}

