package Projectile
{
   import Actor.ActorGameObject;
   import DistributedObjects.DistributedDungeonFloor;
   import Facade.DBFacade;
   import flash.geom.Vector3D;
   
   public class BoomerangFlightComponent extends FlightComponent
   {
      
      public function BoomerangFlightComponent(position:Vector3D, directionVector:Vector3D, projectile:ProjectileGameObject, parentActorId:uint, dbFacade:DBFacade, dungeonFloor:DistributedDungeonFloor, friendly:Boolean, applySteeringVector:Function = null)
      {
         super(position,directionVector,projectile,parentActorId,dbFacade,dungeonFloor,friendly,applySteeringVector);
      }
      
      override public function update() : void
      {
         var _loc2_:ActorGameObject = mDungeonFloor.getActor(mParentActorId);
         if(_loc2_ == null)
         {
            return;
         }
         var _loc7_:Vector3D = _loc2_.worldCenter;
         var _loc3_:Vector3D = _loc7_.subtract(mProjectile.position);
         var _loc6_:Number = _loc3_.normalize();
         var _loc5_:Number = mProjectile.gmProjectile.ProjSpeedF;
         if(_loc6_ > mProjectile.gmProjectile.Range / 4 || mProjectile.velocity.lengthSquared < _loc5_ * _loc5_ * 0.9)
         {
            mApplySteeringVector(getSteeringVector(_loc7_,0.1 * mProjectile.gmProjectile.SteeringRate));
         }
         var _loc1_:Number = mProjectile.velocity.length / mProjectile.gmProjectile.ProjSpeedF;
         _loc1_ *= _loc1_;
         var _loc4_:Number = -mProjectile.gmProjectile.RotationSpeedF * _loc1_;
         mProjectile.rotationSpeed += _loc4_ - mProjectile.rotationSpeed;
         mProjectile.rotationSpeed = Math.min(mProjectile.rotationSpeed,-mProjectile.gmProjectile.RotationSpeedF / 6);
         if(approachingTarget(_loc6_,_loc3_,_loc2_))
         {
            mProjectile.destroy();
         }
      }
      
      private function approachingTarget(distance:Number, direction:Vector3D, actor:ActorGameObject) : Boolean
      {
         var _loc5_:Number = mProjectile.gmProjectile.CollisionSize + actor.actorData.gMActor.CollisionSize;
         var _loc4_:Boolean = mProjectile.velocity.length >= mProjectile.gmProjectile.ProjSpeedF - 0.1 && distance < 40;
         if(!_loc4_ && distance < _loc5_ && direction.dotProduct(mProjectile.velocity) > 0)
         {
            return true;
         }
         return false;
      }
   }
}

