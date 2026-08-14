package GeneratedCode
{
   import Brain.GameObject.GameObject;
   
   public interface IDistributedTownFloor
   {
      
      function setNetworkComponentDistributedTownFloor(iface:DistributedTownFloorNetworkComponent) : void;
      
      function postGenerate() : void;
      
      function getTrueObject() : GameObject;
      
      function destroy() : void;
      
      function tileLibrary(tileLibrary:String) : void;
      
      function tiles(tiles:Vector.<DungeonTileUsage>) : void;
   }
}

