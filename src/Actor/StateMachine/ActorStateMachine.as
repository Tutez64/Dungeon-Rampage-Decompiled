package Actor.StateMachine
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import Brain.StateMachine.StateMachine;
   import Facade.DBFacade;
   
   public class ActorStateMachine extends StateMachine
   {
      
      protected var mDBFacade:DBFacade;
      
      protected var mActorGameObject:ActorGameObject;
      
      protected var mActorView:ActorView;
      
      public function ActorStateMachine(dbFacade:DBFacade, actorGameObject:ActorGameObject, actorView:ActorView)
      {
         super();
         mDBFacade = dbFacade;
         mActorGameObject = actorGameObject;
         mActorView = actorView;
      }
      
      override public function destroy() : void
      {
         mActorView = null;
         mActorGameObject = null;
         mDBFacade = null;
         super.destroy();
      }
   }
}

