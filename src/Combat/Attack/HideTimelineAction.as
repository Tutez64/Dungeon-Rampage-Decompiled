package Combat.Attack
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import Facade.DBFacade;
   
   public class HideTimelineAction extends AttackTimelineAction
   {
      
      public static const TYPE:String = "visible";
      
      protected var value:Boolean = false;
      
      public function HideTimelineAction(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, actionObj:Object)
      {
         super(actorGameObject,actorView,dbFacade);
         value = actionObj.value;
      }
      
      public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, actionObj:Object) : HideTimelineAction
      {
         return new HideTimelineAction(actorGameObject,actorView,dbFacade,actionObj);
      }
      
      override public function execute(timeline:ScriptTimeline) : void
      {
         super.execute(timeline);
         mActorGameObject.view.root.visible = value;
      }
      
      override public function stop() : void
      {
         mActorGameObject.view.root.visible = true;
      }
   }
}

