package Actor.Player
{
   import Actor.ActorView;
   import Actor.StateMachine.ActorMacroStateMachine;
   import Actor.StateMachine.ActorReviveState;
   import Brain.Utils.MemoryTracker;
   import DistributedObjects.HeroGameObject;
   import Facade.DBFacade;
   
   public class HeroStateMachine extends ActorMacroStateMachine
   {
      
      protected var mReviveState:ActorReviveState;
      
      public function HeroStateMachine(dbFacade:DBFacade, heroGameObject:HeroGameObject, actorView:ActorView)
      {
         super(dbFacade,heroGameObject,actorView);
         mReviveState = new ActorReviveState(mDBFacade,heroGameObject,mActorView);
         MemoryTracker.track(mReviveState,"ActorReviveState - created in HeroStateMachine.HeroStateMachine()");
      }
      
      override public function destroy() : void
      {
         mReviveState.destroy();
         super.destroy();
      }
      
      public function enterReviveState() : void
      {
         this.transitionToState(mReviveState);
      }
   }
}

