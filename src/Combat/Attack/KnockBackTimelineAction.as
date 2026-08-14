package Combat.Attack
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import Facade.DBFacade;
   import GameMasterDictionary.GMAttack;
   import flash.geom.Vector3D;
   
   public class KnockBackTimelineAction extends AutoMoveTimelineAction
   {
      
      public static const TYPE:String = "knockback";
      
      public function KnockBackTimelineAction(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade)
      {
         super(actorGameObject,actorView,dbFacade);
      }
      
      public static function buildFromJson(actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade) : KnockBackTimelineAction
      {
         if(actorGameObject.isOwner)
         {
            return new KnockBackTimelineAction(actorGameObject,actorView,dbFacade);
         }
         return null;
      }
      
      override public function execute(timeline:ScriptTimeline) : void
      {
         var _loc2_:Vector3D = null;
         var _loc3_:GMAttack = mDBFacade.gameMaster.attackById.itemFor(mAttackType);
         if(_loc3_ && mAttacker != null)
         {
            mDistance = _loc3_.Knockback;
            mDuration = _loc3_.KnockbackDur;
            _loc2_ = new Vector3D(mActorGameObject.worldCenter.x - mAttacker.worldCenter.x,mActorGameObject.worldCenter.y - mAttacker.worldCenter.y);
            mAngle = Math.atan2(_loc2_.y,_loc2_.x) * 180 / 3.141592653589793;
         }
         if(mDuration > 0)
         {
            super.execute(timeline);
         }
      }
   }
}

