package Projectile
{
   import Actor.ActorGameObject;
   import Box2D.Collision.b2AABB;
   import Box2D.Dynamics.b2Fixture;
   import DistributedObjects.DistributedDungeonFloor;
   import Dungeon.NavCollider;
   import Facade.DBFacade;
   import flash.geom.Vector3D;
   
   public class HomingFlightComponent extends FlightComponent
   {
      
      private var mCurrentTargetId:uint;
      
      private var mBestScore:Number;
      
      private var mLastHitActor:ActorGameObject;
      
      public function HomingFlightComponent(position:Vector3D, directionVector:Vector3D, projectile:ProjectileGameObject, parentActorId:uint, dbFacade:DBFacade, dungeonFloor:DistributedDungeonFloor, friendly:Boolean, applySteeringVector:Function = null)
      {
         super(position,directionVector,projectile,parentActorId,dbFacade,dungeonFloor,friendly,applySteeringVector);
         findTarget();
      }
      
      private function findTarget() : void
      {
         mBestScore = -99999;
         var _loc2_:Vector3D = new Vector3D(mDBFacade.camera.visibleRectangle.left,mDBFacade.camera.visibleRectangle.top);
         var _loc1_:Vector3D = new Vector3D(mDBFacade.camera.visibleRectangle.right,mDBFacade.camera.visibleRectangle.bottom);
         var _loc3_:b2AABB = new b2AABB();
         _loc3_.lowerBound = NavCollider.convertToB2Vec2(_loc2_);
         _loc3_.upperBound = NavCollider.convertToB2Vec2(_loc1_);
         mProjectile.distributedDungeonFloor.box2DWorld.QueryAABB(targetSelectCallback,_loc3_);
      }
      
      override public function informOfHit(hitActor:ActorGameObject) : void
      {
         mLastHitActor = hitActor;
         findTarget();
      }
      
      public function targetSelectCallback(fixture:b2Fixture) : Boolean
      {
         var _loc2_:ActorGameObject = mDungeonFloor.getActor(mParentActorId);
         if(_loc2_ == null)
         {
            return false;
         }
         var _loc3_:uint = fixture.GetBody().GetUserData() as uint;
         var _loc4_:ActorGameObject = mDBFacade.gameObjectManager.getReferenceFromId(_loc3_) as ActorGameObject;
         if(_loc4_ != null && (_loc4_.isProp && !mProjectile.gmAttack.AffectsProps))
         {
            return false;
         }
         if(_loc4_ == null || !_loc4_.isAttackable || _loc4_ == mLastHitActor)
         {
            return true;
         }
         if(isTargetableTeam(_loc4_.team) && isBetterTargetThanCurrent(_loc4_))
         {
            mCurrentTargetId = _loc4_.id;
            mBestScore = calculateTargetScore(_loc4_,_loc2_);
         }
         return true;
      }
      
      private function isBetterTargetThanCurrent(newTarget:ActorGameObject) : Boolean
      {
         var _loc3_:Number = NaN;
         var _loc4_:ActorGameObject = mDungeonFloor.getActor(mParentActorId);
         var _loc2_:ActorGameObject = mDungeonFloor.getActor(mCurrentTargetId);
         if(_loc2_ == null || _loc2_.hitPoints == 0)
         {
            return true;
         }
         if(newTarget.hitPoints == 0)
         {
            return false;
         }
         if(_loc2_.team == 1 && newTarget.team != 1)
         {
            return true;
         }
         if(_loc2_.team != 1 && newTarget.team != 1 || _loc2_.team == 1 && newTarget.team == 1)
         {
            _loc3_ = calculateTargetScore(newTarget,_loc4_);
            if(_loc3_ > mBestScore)
            {
               return true;
            }
            return false;
         }
         return false;
      }
      
      private function calculateTargetScore(target:ActorGameObject, parent:ActorGameObject) : Number
      {
         if(parent == null)
         {
            return 0;
         }
         var _loc5_:Number = 20 / Vector3D.distance(target.worldCenter,parent.worldCenter);
         var _loc6_:Vector3D = target.worldCenter.subtract(parent.worldCenter);
         _loc6_.normalize();
         var _loc3_:Number = _loc6_.dotProduct(parent.getHeadingAsVector());
         return _loc5_ * mProjectile.gmProjectile.HomingDistWeight + _loc3_ * mProjectile.gmProjectile.HomingAngleWeight;
      }
      
      override public function update() : void
      {
         var _loc1_:ActorGameObject = mDungeonFloor.getActor(mCurrentTargetId);
         if(_loc1_ == null || _loc1_.hitPoints == 0)
         {
            findTarget();
            return;
         }
         var _loc5_:Vector3D = _loc1_.worldCenter;
         var _loc2_:Vector3D = _loc5_.subtract(mProjectile.position);
         var _loc3_:Number = _loc2_.normalize();
         var _loc4_:Number = 1 - 20 / _loc3_;
         _loc4_ = 1 - _loc4_ * _loc4_;
         mSteeringVector = getSteeringVector(_loc5_,Math.min(1,_loc4_ * mProjectile.gmProjectile.SteeringRate));
         mApplySteeringVector(mSteeringVector);
         if(mProjectile.gmProjectile.RotationSpeedF == 0)
         {
            mProjectile.rotation = Math.atan2(mProjectile.velocity.y,mProjectile.velocity.x) * 180 / 3.141592653589793;
         }
      }
   }
}

