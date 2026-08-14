package GeneratedCode
{
   import Brain.GameObject.GameObject;
   
   public interface IDistributedTownArea
   {
      
      function setNetworkComponentDistributedTownArea(iface:DistributedTownAreaNetworkComponent) : void;
      
      function postGenerate() : void;
      
      function getTrueObject() : GameObject;
      
      function destroy() : void;
      
      function tileLibrary(tileLibrary:String) : void;
   }
}

