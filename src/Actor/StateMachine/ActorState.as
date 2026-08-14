package Actor.StateMachine
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import Brain.StateMachine.State;
   import Facade.DBFacade;
   
   public class ActorState extends State
   {
      
      protected var mDBFacade:DBFacade;
      
      protected var mActorGameObject:ActorGameObject;
      
      protected var mActorView:ActorView;
      
      public function ActorState(dbFacade:DBFacade, actorGameObject:ActorGameObject, actorView:ActorView, stateName:String, finishedCallback:Function = null)
      {
         super(stateName,finishedCallback);
         mDBFacade = dbFacade;
         mActorGameObject = actorGameObject;
         mActorView = actorView;
      }
      
      override public function destroy() : void
      {
         mDBFacade = null;
         mActorGameObject = null;
         mActorView = null;
         super.destroy();
      }
   }
}

