package Combat.Attack
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import Facade.DBFacade;
   
   public class MovementAttackTimelineAction extends AttackTimelineAction
   {
      
      public static const TYPE:String = "move";
      
      protected var mMovementType:String;
      
      public function MovementAttackTimelineAction(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, movementType:String)
      {
         super(actorGameObject,actorView,dbFacade);
         mMovementType = movementType;
      }
      
      public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, actionObj:Object) : MovementAttackTimelineAction
      {
         var _loc5_:String = actionObj.movementType;
         return new MovementAttackTimelineAction(actorGameObject,actorView,dbFacade,_loc5_);
      }
      
      override public function execute(timeline:ScriptTimeline) : void
      {
         super.execute(timeline);
         mActorGameObject.movementControllerType = mMovementType;
      }
   }
}

