package Actor.StateMachine.SubStateMachine
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import Actor.StateMachine.ActorNavigationState;
   import Actor.StateMachine.ActorState;
   import Actor.StateMachine.ActorStateMachine;
   import Brain.Utils.MemoryTracker;
   import Combat.Attack.ScriptTimeline;
   import Facade.DBFacade;
   
   public class ActorSubStateMachine extends ActorStateMachine
   {
      
      protected var mActorNavigationState:ActorNavigationState;
      
      protected var mActorChoreographyState:ActorChoreographySubState;
      
      public function ActorSubStateMachine(dbFacade:DBFacade, actorGameObject:ActorGameObject, actorView:ActorView)
      {
         super(dbFacade,actorGameObject,actorView);
         buildStates();
      }
      
      public function exit() : void
      {
         (this.currentState as ActorState).exitState();
         this.currentState = null;
      }
      
      private function buildStates() : void
      {
         mActorNavigationState = new ActorNavigationState(mDBFacade,mActorGameObject,mActorView);
         MemoryTracker.track(mActorNavigationState,"ActorNavigationState - created in ActorSubStateMachine.buildStates()");
         mActorChoreographyState = new ActorChoreographySubState(mDBFacade,mActorGameObject,mActorView);
         MemoryTracker.track(mActorChoreographyState,"ActorChoreographySubState - created in ActorSubStateMachine.buildStates()");
      }
      
      public function enterNavigationState() : void
      {
         this.transitionToState(mActorNavigationState);
      }
      
      public function enterChoreographyState(playSpeed:Number, targetActor:ActorGameObject, script:ScriptTimeline, finishedCallback:Function = null, stopCallback:Function = null, loop:Boolean = false) : void
      {
         var enterNavigationAndCallFinishedCallback:Function = function():void
         {
            enterNavigationState();
            if(finishedCallback != null)
            {
               finishedCallback();
            }
         };
         mActorChoreographyState.setChoreography(playSpeed,targetActor,script,enterNavigationAndCallFinishedCallback,stopCallback,loop);
         this.transitionToState(mActorChoreographyState);
      }
      
      override public function destroy() : void
      {
         if(this.currentState != null)
         {
            this.currentState.exitState();
         }
         this.currentState = null;
         mActorNavigationState.destroy();
         mActorNavigationState = null;
         mActorChoreographyState.destroy();
         mActorChoreographyState = null;
         super.destroy();
      }
   }
}

