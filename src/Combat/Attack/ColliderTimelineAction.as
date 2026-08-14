package Combat.Attack
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import Brain.Logger.Logger;
   import Combat.CombatGameObject;
   import Combat.Weapon.WeaponGameObject;
   import DistributedObjects.DistributedDungeonFloor;
   import Facade.DBFacade;
   import flash.geom.Vector3D;
   
   public class ColliderTimelineAction extends AttackTimelineAction
   {
      
      protected var mHeadingOffset:Vector3D;
      
      protected var mGlobalOffset:Vector3D;
      
      protected var mWeapon:WeaponGameObject;
      
      protected var mDistributedDungeonFloor:DistributedDungeonFloor;
      
      protected var mCombatGameObject:CombatGameObject;
      
      protected var mCombatResultCallback:Function;
      
      protected var mLifeTime:uint;
      
      protected var mHitDelayPerObject:uint;
      
      public function ColliderTimelineAction(weapon:WeaponGameObject, actorGameObject:ActorGameObject, actorView:ActorView, dbFacade:DBFacade, distributedDungeonFloor:DistributedDungeonFloor, combatResultCallback:Function, headingOffset:Vector3D, globalOffset:Vector3D, lifeTime:uint = 0, hitDelayPerObject:uint = 0)
      {
         mLifeTime = lifeTime;
         mWeapon = weapon;
         mCombatResultCallback = combatResultCallback;
         mHeadingOffset = headingOffset;
         mGlobalOffset = globalOffset;
         mDistributedDungeonFloor = distributedDungeonFloor;
         mHitDelayPerObject = hitDelayPerObject;
         super(actorGameObject,actorView,dbFacade);
      }
      
      override public function execute(timeline:ScriptTimeline) : void
      {
         super.execute(timeline);
         mCombatGameObject = buildCombatGameObject(mLifeTime,mHitDelayPerObject);
         perFrameUpCall(timeline);
         if(mLifeTime > 0)
         {
            timeline.addContinuousCollision(this);
         }
      }
      
      protected function buildCombatGameObject(lifetime:uint, hitDelayPerObj:uint) : CombatGameObject
      {
         Logger.error("Build Combat Game Object should be overriden.  Implement it in the sub class.");
         return null;
      }
      
      private function returnPositionForCollision() : Vector3D
      {
         var _loc4_:Vector3D = mActorGameObject.getHeadingAsVector();
         var _loc3_:Number = mActorGameObject.heading;
         var _loc1_:Vector3D = new Vector3D(0,0);
         _loc1_.x += mHeadingOffset.x * _loc4_.x * mActorGameObject.actorData.scale;
         _loc1_.y += mHeadingOffset.x * _loc4_.y * mActorGameObject.actorData.scale;
         var _loc2_:Vector3D = mActorView.worldCenter.add(_loc1_);
         return _loc2_.add(mGlobalOffset);
      }
      
      public function perFrameUpCall(timeline:ScriptTimeline) : Boolean
      {
         if(mCombatGameObject != null)
         {
            mCombatGameObject.position = returnPositionForCollision();
            mCombatGameObject.perFrameUpCall(timeline.currentFrame);
            if(!mCombatGameObject.isAlive())
            {
               mCombatGameObject.destroy();
               mCombatGameObject = null;
               return false;
            }
            return true;
         }
         return false;
      }
   }
}

