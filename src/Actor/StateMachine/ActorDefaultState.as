package Actor.StateMachine
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import Actor.StateMachine.SubStateMachine.ActorSubStateMachine;
   import Combat.Attack.ScriptTimeline;
   import DistributedObjects.HeroGameObjectOwner;
   import Facade.DBFacade;
   
   public class ActorDefaultState extends ActorState
   {
      
      public static const NAME:String = "ActorDefaultState";
      
      private var mSubStateMachine:ActorSubStateMachine;
      
      public function ActorDefaultState(dbFacade:DBFacade, actorGameObject:ActorGameObject, actorView:ActorView, finishedCallback:Function = null)
      {
         super(dbFacade,actorGameObject,actorView,"ActorDefaultState",finishedCallback);
         mSubStateMachine = new ActorSubStateMachine(dbFacade,actorGameObject,actorView);
      }
      
      override public function enterState() : void
      {
         var _loc1_:HeroGameObjectOwner = null;
         super.enterState();
         if(mActorGameObject.isOwner)
         {
            _loc1_ = mActorGameObject as HeroGameObjectOwner;
            _loc1_.startUserInput();
         }
         mSubStateMachine.enterNavigationState();
      }
      
      override public function exitState() : void
      {
         var _loc1_:HeroGameObjectOwner = null;
         mSubStateMachine.exit();
         if(mActorGameObject.isOwner)
         {
            _loc1_ = mActorGameObject as HeroGameObjectOwner;
            _loc1_.stopUserInput();
         }
         super.exitState();
      }
      
      public function enterChoreographyState(playSpeed:Number, targetActor:ActorGameObject, scriptTimeline:ScriptTimeline, finishedCallback:Function = null, stopCallback:Function = null, loop:Boolean = false) : void
      {
         mSubStateMachine.enterChoreographyState(playSpeed,targetActor,scriptTimeline,finishedCallback,stopCallback,loop);
      }
      
      public function enterNavigationState() : void
      {
         mSubStateMachine.enterNavigationState();
      }
      
      public function get currentSubState() : ActorState
      {
         return mSubStateMachine.currentState as ActorState;
      }
      
      override public function destroy() : void
      {
         mSubStateMachine.destroy();
         mSubStateMachine = null;
         super.destroy();
      }
   }
}

