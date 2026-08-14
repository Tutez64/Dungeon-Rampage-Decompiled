package Combat.Attack
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import Brain.Logger.Logger;
   import DistributedObjects.DistributedDungeonFloor;
   import Facade.DBFacade;
   import GeneratedCode.CombatResult;
   
   public class CombatResultAttackTimelineAction extends AttackTimelineAction
   {
      
      protected var mDungeonFloor:DistributedDungeonFloor;
      
      public function CombatResultAttackTimelineAction(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, combatResult:CombatResult, dungeonFloor:DistributedDungeonFloor)
      {
         super(actorGameObject,actorView,dbFacade);
         mCombatResult = combatResult;
         mDungeonFloor = dungeonFloor;
      }
      
      override public function execute(timeline:ScriptTimeline) : void
      {
         super.execute(timeline);
         var _loc2_:ActorGameObject = mDungeonFloor.getActor(mCombatResult.attackee);
         if(_loc2_ == null)
         {
            Logger.warn("Tried to execute a combat result on an actor that is not on the dungeon floor.  Actor id: " + mCombatResult.attackee.toString());
            return;
         }
         _loc2_.ReceiveCombatResult(mCombatResult);
      }
   }
}

