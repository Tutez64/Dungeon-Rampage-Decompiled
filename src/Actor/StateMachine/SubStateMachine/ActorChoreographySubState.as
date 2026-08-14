package Actor.StateMachine.SubStateMachine
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import Actor.StateMachine.ActorState;
   import Brain.Event.EventComponent;
   import Brain.Logger.Logger;
   import Combat.Attack.ScriptTimeline;
   import Events.HeroOwnerEndedAttackStateEvent;
   import Facade.DBFacade;
   
   public class ActorChoreographySubState extends ActorState
   {
      
      public static const NAME:String = "ActorChoreographySubState";
      
      protected var mCurrentScript:ScriptTimeline;
      
      protected var mQueuedScript:ScriptTimeline;
      
      protected var mQueuedPlaySpeed:Number = 1;
      
      protected var mQueuedFinishedCallback:Function;
      
      protected var mQueuedStopCallback:Function;
      
      protected var mQueuedLoop:Boolean;
      
      protected var mQueuedTargetActor:ActorGameObject;
      
      protected var mEventComponent:EventComponent;
      
      public function ActorChoreographySubState(dbFacade:DBFacade, actorGameObject:ActorGameObject, actorView:ActorView, finishedCallback:Function = null)
      {
         super(dbFacade,actorGameObject,actorView,"ActorChoreographySubState",finishedCallback);
         mEventComponent = new EventComponent(mDBFacade);
      }
      
      public function setChoreography(playSpeed:Number, target:ActorGameObject, script:ScriptTimeline, finishedCallback:Function = null, stopCallback:Function = null, loop:Boolean = false) : void
      {
         mQueuedScript = script;
         mQueuedPlaySpeed = playSpeed;
         mQueuedFinishedCallback = finishedCallback;
         mQueuedStopCallback = stopCallback;
         mQueuedLoop = loop;
         mQueuedTargetActor = target;
      }
      
      override public function enterState() : void
      {
         super.enterState();
         if(mQueuedScript != null)
         {
            if(mCurrentScript != null)
            {
               mCurrentScript.stop();
            }
            mCurrentScript = mQueuedScript;
            mQueuedScript = null;
            mCurrentScript.play(mQueuedPlaySpeed,mQueuedTargetActor,mQueuedFinishedCallback,mQueuedStopCallback,mQueuedLoop);
         }
         else
         {
            Logger.error("No script in choreography!");
            mQueuedFinishedCallback();
         }
      }
      
      override public function exitState() : void
      {
         if(mActorGameObject.isOwner)
         {
            mEventComponent.dispatchEvent(new HeroOwnerEndedAttackStateEvent("PLAYER_ENDED_ATTACK_STATE"));
         }
         if(mCurrentScript != null)
         {
            if(mCurrentScript.isPlaying)
            {
               mCurrentScript.stop();
            }
            mCurrentScript = null;
         }
         super.exitState();
      }
      
      override public function destroy() : void
      {
         exitState();
         if(mEventComponent)
         {
            mEventComponent.destroy();
            mEventComponent = null;
         }
         super.destroy();
      }
   }
}

