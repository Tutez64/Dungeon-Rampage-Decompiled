package Projectile
{
   import Actor.ActorGameObject;
   import DistributedObjects.DistributedDungeonFloor;
   import Facade.DBFacade;
   import GameMasterDictionary.GMAttack;
   import flash.geom.Vector3D;
   
   public class BounceBackCollisionComponent extends CollisionComponent
   {
      
      private static const DAMPING_FACTOR:Number = 0.5;
      
      public function BounceBackCollisionComponent(dbFacade:DBFacade, projectile:ProjectileGameObject, parentActorId:uint, dungeonFloor:DistributedDungeonFloor, weaponType:uint, weaponPower:uint, gmAttack:GMAttack, combatResultCallback:Function, weaponSlot:int, additiveHits:Number)
      {
         super(dbFacade,projectile,parentActorId,dungeonFloor,weaponType,weaponPower,gmAttack,combatResultCallback,weaponSlot,additiveHits,false);
      }
      
      override public function hitWall() : void
      {
         var _loc1_:ActorGameObject = mDungeonFloor.getActor(mParentActorId);
         if(_loc1_ == null || _loc1_.isDestroyed)
         {
            mProjectile.destroy();
            return;
         }
         var _loc2_:Vector3D = _loc1_.worldCenter.subtract(mProjectile.position);
         _loc2_.normalize();
         _loc2_.scaleBy(mProjectile.velocity.length * 0.5);
         mProjectile.velocity = _loc2_;
         mUpdatedVelocity = true;
      }
   }
}

