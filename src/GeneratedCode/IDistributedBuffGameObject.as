package GeneratedCode
{
   import Brain.GameObject.GameObject;
   
   public interface IDistributedBuffGameObject
   {
      
      function setNetworkComponentDistributedBuffGameObject(iface:DistributedBuffGameObjectNetworkComponent) : void;
      
      function postGenerate() : void;
      
      function getTrueObject() : GameObject;
      
      function destroy() : void;
      
      function set type(val:uint) : void;
      
      function set effectedActor(val:uint) : void;
      
      function set attackerActor(val:uint) : void;
   }
}

