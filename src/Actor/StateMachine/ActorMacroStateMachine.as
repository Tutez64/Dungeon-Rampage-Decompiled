package Actor.StateMachine
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import Brain.Logger.Logger;
   import Brain.Utils.MemoryTracker;
   import Combat.Attack.AttackTimeline;
   import Combat.Attack.ScriptTimeline;
   import Facade.DBFacade;
   import GeneratedCode.AttackChoreography;
   import GeneratedCode.CombatResult;
   
   public class ActorMacroStateMachine extends ActorStateMachine
   {
      
      protected var mDefaultState:ActorDefaultState;
      
      protected var mDeadState:ActorDeadState;
      
      public function ActorMacroStateMachine(dbFacade:DBFacade, actorGameObject:ActorGameObject, actorView:ActorView)
      {
         super(dbFacade,actorGameObject,actorView);
         mDefaultState = new ActorDefaultState(mDBFacade,mActorGameObject,mActorView);
         MemoryTracker.track(mDefaultState,"ActorDefaultState - created in ActorMacroStateMachine.ActorMacroStateMachine()");
         mDeadState = new ActorDeadState(mDBFacade,mActorGameObject,mActorView);
         MemoryTracker.track(mDeadState,"ActorDeadState - created in ActorMacroStateMachine.ActorMacroStateMachine()");
      }
      
      public function enterAttackChoreographyState(playSpeed:Number, targetActor:ActorGameObject, attackTimeline:AttackTimeline, attackChoreography:AttackChoreography, finishedCallback:Function = null, stopCallback:Function = null, loop:Boolean = false) : void
      {
         attackTimeline.appendChoreography(attackChoreography);
         var _loc8_:Boolean = attackChoreography.loop == 1 ? true : false;
         attackTimeline.currentAttackType = attackChoreography.attack.attackType;
         attackTimeline.projectileMultiplier = attackChoreography.scalingMaxProjectiles;
         enterChoreographyState(playSpeed,targetActor,attackTimeline,finishedCallback,stopCallback,loop);
      }
      
      public function enterCombatResultChoreographyState(playSpeed:Number, targetActor:ActorGameObject, scriptTimeline:ScriptTimeline, combatResult:CombatResult, attacker:ActorGameObject, finishedCallback:Function = null, stopCallback:Function = null, loop:Boolean = false) : void
      {
         scriptTimeline.currentAttackType = combatResult.attack.attackType;
         scriptTimeline.currentCombatResult = combatResult;
         scriptTimeline.currentAttacker = attacker;
         enterChoreographyState(playSpeed,targetActor,scriptTimeline,finishedCallback,stopCallback,loop);
      }
      
      public function enterChoreographyState(playSpeed:Number, targetActor:ActorGameObject, scriptTimeline:ScriptTimeline, finishedCallback:Function = null, stopCallback:Function = null, loop:Boolean = false, autoAim:Boolean = false) : void
      {
         var _loc8_:ActorDefaultState = null;
         if(this.currentState == mDefaultState)
         {
            _loc8_ = this.currentState as ActorDefaultState;
            scriptTimeline.autoAim = autoAim;
            _loc8_.enterChoreographyState(playSpeed,targetActor,scriptTimeline,finishedCallback,stopCallback,loop);
         }
         else
         {
            Logger.warn("Trying to enter a choreographyState when the macro state is not in the default state.");
         }
      }
      
      public function enterNavigationState() : void
      {
         var _loc1_:ActorDefaultState = null;
         if(this.currentState == mDefaultState)
         {
            _loc1_ = this.currentState as ActorDefaultState;
            _loc1_.enterNavigationState();
         }
         else
         {
            Logger.warn("Trying to enter a choreographyState when the macro state is not in the default state.");
         }
      }
      
      public function get currentSubState() : ActorState
      {
         if(this.currentState as ActorState == mDefaultState)
         {
            return mDefaultState.currentSubState;
         }
         return null;
      }
      
      public function enterDeadState(finishedDeathCallback:Function) : void
      {
         mDeadState.finishedCallback = finishedDeathCallback;
         this.transitionToState(mDeadState);
      }
      
      public function enterDefaultState() : void
      {
         this.transitionToState(mDefaultState);
      }
      
      override public function destroy() : void
      {
         mDefaultState.destroy();
         mDefaultState = null;
         mDeadState.destroy();
         mDeadState = null;
         super.destroy();
      }
   }
}

