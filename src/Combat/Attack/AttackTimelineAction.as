package Combat.Attack
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Facade.DBFacade;
   import GameMasterDictionary.GMAttack;
   import GeneratedCode.CombatResult;
   
   public class AttackTimelineAction
   {
      
      protected var mActorGameObject:ActorGameObject;
      
      protected var mActorView:ActorView;
      
      protected var mDBFacade:DBFacade;
      
      protected var mAttackType:uint;
      
      protected var mCombatResult:CombatResult;
      
      protected var mAttacker:ActorGameObject;
      
      protected var mGMAttack:GMAttack;
      
      protected var mWorkComponent:LogicalWorkComponent;
      
      protected var mTimeline:ScriptTimeline;
      
      public function AttackTimelineAction(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade)
      {
         super();
         mActorGameObject = actorGameObject;
         mActorView = actorView;
         mDBFacade = dbFacade;
         mWorkComponent = new LogicalWorkComponent(mDBFacade,"AttackTimelineAction");
      }
      
      public function set attackType(attack:uint) : void
      {
         if(mAttackType != attack)
         {
            mAttackType = attack;
            mGMAttack = mDBFacade.gameMaster.attackById.itemFor(attack);
         }
      }
      
      public function set combatResult(combatResult:CombatResult) : void
      {
         mCombatResult = combatResult;
      }
      
      public function set attacker(attackingActor:ActorGameObject) : void
      {
         mAttacker = attackingActor;
      }
      
      public function execute(timeline:ScriptTimeline) : void
      {
         mTimeline = timeline;
      }
      
      public function destroy() : void
      {
         mActorGameObject = null;
         mActorView = null;
         mDBFacade = null;
         mCombatResult = null;
         mAttacker = null;
         mGMAttack = null;
         if(mWorkComponent)
         {
            mWorkComponent.destroy();
            mWorkComponent = null;
         }
      }
      
      public function stop() : void
      {
      }
   }
}

