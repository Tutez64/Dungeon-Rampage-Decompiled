package Projectile
{
   import Actor.ActorGameObject;
   import DistributedObjects.DistributedDungeonFloor;
   import Facade.DBFacade;
   import flash.geom.Vector3D;
   
   public class FlightComponent
   {
      
      protected var mProjectile:ProjectileGameObject;
      
      protected var mParentActorId:uint;
      
      protected var mDBFacade:DBFacade;
      
      protected var mDungeonFloor:DistributedDungeonFloor;
      
      protected var mHeadingVector:Vector3D;
      
      protected var mSteeringUpdated:Boolean;
      
      protected var mSteeringVector:Vector3D;
      
      protected var mFriendly:Boolean;
      
      protected var mApplySteeringVector:Function;
      
      protected var mStartTime:uint;
      
      public function FlightComponent(position:Vector3D, directionVector:Vector3D, projectile:ProjectileGameObject, parentActorId:uint, dbFacade:DBFacade, dungeonFloor:DistributedDungeonFloor, friendly:Boolean, applySteeringVector:Function = null)
      {
         super();
         mProjectile = projectile;
         mHeadingVector = directionVector;
         mParentActorId = parentActorId;
         mDBFacade = dbFacade;
         mDungeonFloor = dungeonFloor;
         mApplySteeringVector = applySteeringVector;
         mFriendly = friendly;
         mSteeringUpdated = false;
         mStartTime = mDBFacade.gameClock.gameTime;
      }
      
      public function update() : void
      {
         if(mProjectile.gmProjectile.Lifetime > 0 && mDBFacade.gameClock.gameTime - mStartTime > mProjectile.gmProjectile.Lifetime)
         {
            mProjectile.destroy();
            return;
         }
      }
      
      public function informOfHit(hitActor:ActorGameObject) : void
      {
      }
      
      public function get steeringVector() : Vector3D
      {
         return mSteeringVector;
      }
      
      public function get steeringUpdated() : Boolean
      {
         return mSteeringUpdated;
      }
      
      public function destroy() : void
      {
         mProjectile = null;
         mDBFacade = null;
         mDungeonFloor = null;
         mApplySteeringVector = null;
      }
      
      protected function getSteeringVector(target_actor_position:Vector3D, steer_strength:Number) : Vector3D
      {
         var _loc3_:Vector3D = target_actor_position.subtract(mProjectile.position);
         var _loc5_:Number = _loc3_.normalize();
         _loc3_.scaleBy(mProjectile.gmProjectile.ProjSpeedF);
         var _loc4_:Vector3D = _loc3_.subtract(mProjectile.velocity);
         _loc4_.scaleBy(steer_strength);
         return _loc4_;
      }
      
      public function isTargetableTeam(targetTeam:uint) : Boolean
      {
         return mFriendly ? targetTeam == mProjectile.team : targetTeam != mProjectile.team;
      }
   }
}

