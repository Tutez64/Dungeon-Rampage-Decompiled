package Actor.Buffs
{
   import Actor.ActorGameObject;
   import Brain.Facade.Facade;
   import Brain.GameObject.GameObject;
   import GeneratedCode.DistributedBuffGameObjectNetworkComponent;
   import GeneratedCode.IDistributedBuffGameObject;
   
   public class DistributedBuffGameObject extends GameObject implements IDistributedBuffGameObject
   {
      
      private var mType:uint;
      
      private var mEffectedActor:uint;
      
      private var mAttackerActor:uint;
      
      public var buffHandler:BuffHandler;
      
      public function DistributedBuffGameObject(facade:Facade, remoteId:uint = 0)
      {
         super(facade,remoteId);
      }
      
      public function setNetworkComponentDistributedBuffGameObject(iface:DistributedBuffGameObjectNetworkComponent) : void
      {
      }
      
      public function postGenerate() : void
      {
         var _loc2_:GameObject = mFacade.gameObjectManager.getReferenceFromId(mEffectedActor);
         var _loc1_:ActorGameObject = _loc2_ as ActorGameObject;
         if(_loc1_)
         {
            _loc1_.buffHandler.addBuff(this);
            _loc1_.ponderBuffChanges();
         }
      }
      
      override public function destroy() : void
      {
         if(buffHandler)
         {
            buffHandler.removeBuff(this);
            super.destroy();
         }
      }
      
      public function get type() : uint
      {
         return this.mType;
      }
      
      public function set effectedActor(val:uint) : void
      {
         mEffectedActor = val;
      }
      
      public function set attackerActor(val:uint) : void
      {
         mAttackerActor = val;
      }
      
      public function get attackerActor() : uint
      {
         return mAttackerActor;
      }
      
      public function set type(val:uint) : void
      {
         mType = val;
      }
   }
}

