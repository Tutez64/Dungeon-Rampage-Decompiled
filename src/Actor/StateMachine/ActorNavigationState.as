package Actor.StateMachine
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import Brain.WorkLoop.Task;
   import DistributedObjects.HeroGameObjectOwner;
   import Facade.DBFacade;
   
   public class ActorNavigationState extends ActorState
   {
      
      public static const NAME:String = "ActorNavigationState";
      
      protected var mUpdateTask:Task;
      
      public function ActorNavigationState(dbFacade:DBFacade, actorGameObject:ActorGameObject, actorView:ActorView, finishedCallback:Function = null)
      {
         super(dbFacade,actorGameObject,actorView,"ActorNavigationState",finishedCallback);
      }
      
      override public function enterState() : void
      {
         var _loc1_:HeroGameObjectOwner = null;
         super.enterState();
         mActorGameObject.startRunIdleMonitoring();
         if(mActorGameObject.isOwner)
         {
            _loc1_ = mActorGameObject as HeroGameObjectOwner;
            _loc1_.inputController.inputType = "free";
         }
         mActorGameObject.movementControllerType = "normal";
      }
      
      override public function exitState() : void
      {
         mActorGameObject.stopRunIdleMonitoring();
         super.exitState();
      }
   }
}

