package GeneratedCode
{
   import Brain.GameObject.GameObject;
   import flash.geom.Vector3D;
   
   public interface IDistributedDooberGameObject
   {
      
      function setNetworkComponentDistributedDooberGameObject(iface:DistributedDooberGameObjectNetworkComponent) : void;
      
      function postGenerate() : void;
      
      function getTrueObject() : GameObject;
      
      function destroy() : void;
      
      function set type(val:uint) : void;
      
      function set position(val:Vector3D) : void;
      
      function set layer(val:int) : void;
      
      function spawnFrom(loc:Vector3D) : void;
      
      function collectedBy(hero:uint) : void;
   }
}

