package DistributedObjects
{
   import Brain.Facade.Facade;
   import Brain.GameObject.GameObject;
   import GeneratedCode.DistributedTownFloorNetworkComponent;
   import GeneratedCode.DungeonTileUsage;
   import GeneratedCode.IDistributedTownFloor;
   
   public class DistributedTownFloor extends GameObject implements IDistributedTownFloor
   {
      
      public function DistributedTownFloor(facade:Facade, remoteId:uint = 0)
      {
         super(facade,remoteId);
      }
      
      public function setNetworkComponentDistributedTownFloor(iface:DistributedTownFloorNetworkComponent) : void
      {
      }
      
      public function postGenerate() : void
      {
      }
      
      public function tileLibrary(tileLibrary:String) : void
      {
      }
      
      public function tiles(tiles:Vector.<DungeonTileUsage>) : void
      {
      }
   }
}

