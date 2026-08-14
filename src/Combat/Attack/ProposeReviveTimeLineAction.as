package Combat.Attack
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import DistributedObjects.HeroGameObjectOwner;
   import Facade.DBFacade;
   
   public class ProposeReviveTimeLineAction extends AttackTimelineAction
   {
      
      public static const TYPE:String = "proposeRevive";
      
      public function ProposeReviveTimeLineAction(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade)
      {
         super(actorGameObject,actorView,dbFacade);
      }
      
      public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, actionObj:Object) : ProposeReviveTimeLineAction
      {
         return new ProposeReviveTimeLineAction(actorGameObject,actorView,dbFacade);
      }
      
      override public function execute(timeline:ScriptTimeline) : void
      {
         super.execute(timeline);
         var _loc2_:HeroGameObjectOwner = mActorGameObject as HeroGameObjectOwner;
         if(_loc2_)
         {
            _loc2_.proposeRevive();
         }
      }
   }
}

