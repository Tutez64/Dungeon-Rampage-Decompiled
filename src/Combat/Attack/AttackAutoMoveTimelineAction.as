package Combat.Attack
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import DistributedObjects.HeroGameObject;
   import Facade.DBFacade;
   
   public class AttackAutoMoveTimelineAction extends AutoMoveTimelineAction
   {
      
      public static const TYPE:String = "attackautomove";
      
      public function AttackAutoMoveTimelineAction(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade)
      {
         super(actorGameObject,actorView,dbFacade);
      }
      
      public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade) : AttackAutoMoveTimelineAction
      {
         if(actorGameObject.isOwner)
         {
            return new AttackAutoMoveTimelineAction(actorGameObject,actorView,dbFacade);
         }
         return null;
      }
      
      override public function execute(timeline:ScriptTimeline) : void
      {
         var _loc2_:AttackTimeline = null;
         mAttack = mDBFacade.gameMaster.attackById.itemFor(mAttackType);
         mDuration = mAttack.MoveDuration;
         mDistance = mAttack.MoveAmount;
         mAngle = mAttack.MoveAngle + mActorGameObject.heading;
         if(timeline is AttackTimeline)
         {
            _loc2_ = timeline as AttackTimeline;
            if(mActorGameObject is HeroGameObject)
            {
               mDuration = _loc2_.distanceScalingTime > 0 ? _loc2_.distanceScalingTime : mDuration;
               mDistance = _loc2_.distanceScalingHero > 0 ? _loc2_.distanceScalingHero : mDistance;
            }
         }
         if(mDuration > 0 && mDistance > 0)
         {
            super.execute(timeline);
         }
      }
   }
}

