package DistributedObjects
{
   import Brain.Facade.Facade;
   import Brain.GameObject.GameObject;
   import GeneratedCode.DistributedTownAreaNetworkComponent;
   import GeneratedCode.IDistributedTownArea;
   
   public class DistributedTownArea extends GameObject implements IDistributedTownArea
   {
      
      public function DistributedTownArea(facade:Facade, remoteId:uint = 0)
      {
         super(facade,remoteId);
      }
      
      public function setNetworkComponentDistributedTownArea(iface:DistributedTownAreaNetworkComponent) : void
      {
      }
      
      public function postGenerate() : void
      {
      }
      
      public function tileLibrary(tileLibrary:String) : void
      {
      }
   }
}

