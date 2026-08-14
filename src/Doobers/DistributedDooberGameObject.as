package Doobers
{
   import Brain.GameObject.GameObject;
   import Brain.Utils.MemoryTracker;
   import DistributedObjects.HeroGameObjectOwner;
   import Facade.DBFacade;
   import GeneratedCode.DistributedDooberGameObjectNetworkComponent;
   import GeneratedCode.IDistributedDooberGameObject;
   import flash.geom.Vector3D;
   
   public class DistributedDooberGameObject extends GameObject implements IDistributedDooberGameObject
   {
      
      private var mDooberGameObject:DooberGameObject;
      
      private var localFacade:DBFacade;
      
      public function DistributedDooberGameObject(facade:DBFacade, remoteId:uint = 0)
      {
         localFacade = facade;
         super(facade,0);
         mDooberGameObject = new DooberGameObject(facade,remoteId);
         MemoryTracker.track(mDooberGameObject,"DooberGameObject - created in DistributedDooberGameObject.constructor()");
      }
      
      override public function getTrueObject() : GameObject
      {
         return mDooberGameObject;
      }
      
      public function setNetworkComponentDistributedDooberGameObject(iface:DistributedDooberGameObjectNetworkComponent) : void
      {
         mDooberGameObject.setNetworkComponentDistributedDooberGameObject(iface);
      }
      
      public function postGenerate() : void
      {
         if(mDooberGameObject)
         {
            mDooberGameObject.postGenerate();
         }
      }
      
      public function set type(val:uint) : void
      {
         if(mDooberGameObject)
         {
            mDooberGameObject.type = val;
         }
      }
      
      public function set position(val:Vector3D) : void
      {
         if(mDooberGameObject)
         {
            mDooberGameObject.position = val;
         }
      }
      
      public function collectedBy(heroId:uint) : void
      {
         if(mDooberGameObject)
         {
            mDooberGameObject.takeOwnership(heroId == HeroGameObjectOwner.currentHeroOwnerId,heroId);
            mDooberGameObject = null;
         }
      }
      
      public function spawnFrom(loc:Vector3D) : void
      {
         if(mDooberGameObject)
         {
            mDooberGameObject.spawnFrom(loc);
         }
      }
      
      public function set layer(val:int) : void
      {
         if(mDooberGameObject)
         {
            mDooberGameObject.layer = val;
         }
      }
      
      override public function destroy() : void
      {
         if(mDooberGameObject)
         {
            mDooberGameObject.destroy();
            mDooberGameObject = null;
         }
         super.destroy();
      }
   }
}

