package Projectile
{
   import Actor.ActorGameObject;
   import DistributedObjects.DistributedDungeonFloor;
   import Facade.DBFacade;
   import flash.geom.Vector3D;
   
   public class OrbiterFlightComponent extends FlightComponent
   {
      
      private var mDistance:Number;
      
      private var mTargetDistance:Number;
      
      public function OrbiterFlightComponent(position:Vector3D, directionVector:Vector3D, projectile:ProjectileGameObject, parentActorId:uint, dbFacade:DBFacade, dungeonFloor:DistributedDungeonFloor, friendly:Boolean, applySteeringVector:Function = null)
      {
         super(position,directionVector,projectile,parentActorId,dbFacade,dungeonFloor,friendly,applySteeringVector);
         mDistance = 100;
         mTargetDistance = 100;
      }
      
      override public function update() : void
      {
         var _loc2_:ActorGameObject = mDungeonFloor.getActor(mParentActorId);
         if(_loc2_ == null)
         {
            return;
         }
         var _loc3_:Vector3D = _loc2_.worldCenter.subtract(mProjectile.position);
         var _loc7_:Number = _loc3_.normalize();
         var _loc5_:Vector3D = new Vector3D(-_loc3_.y,_loc3_.x);
         _loc5_.scaleBy(60);
         var _loc8_:Vector3D = mProjectile.position.add(_loc5_);
         var _loc4_:Vector3D = _loc8_.subtract(_loc2_.worldCenter);
         _loc4_.normalize();
         if(Math.abs(mTargetDistance - mDistance) < 2)
         {
            mTargetDistance = mProjectile.gmProjectile.Range + Math.random() * 80;
         }
         mDistance += (mTargetDistance - mDistance) * 0.125;
         _loc4_.scaleBy(mDistance);
         _loc8_ = _loc2_.worldCenter.add(_loc4_);
         mApplySteeringVector(getSteeringVector(_loc8_,0.5 * mProjectile.gmProjectile.SteeringRate));
         var _loc1_:Number = mProjectile.velocity.length / mProjectile.gmProjectile.ProjSpeedF;
         _loc1_ *= _loc1_;
         var _loc6_:Number = mProjectile.gmProjectile.RotationSpeedF * _loc1_;
         mProjectile.rotationSpeed += _loc6_ - mProjectile.rotationSpeed;
         mProjectile.rotationSpeed = Math.max(mProjectile.rotationSpeed,mProjectile.gmProjectile.RotationSpeedF / 6);
         super.update();
      }
   }
}

