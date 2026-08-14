package GeneratedCode
{
   import Brain.GameObject.GameObject;
   
   public interface IDistributedDungeonSummary
   {
      
      function setNetworkComponentDistributedDungeonSummary(iface:DistributedDungeonSummaryNetworkComponent) : void;
      
      function postGenerate() : void;
      
      function getTrueObject() : GameObject;
      
      function destroy() : void;
      
      function set map_node_id(val:uint) : void;
      
      function set report(val:Vector.<DungeonReport>) : void;
      
      function set dungeon_name(val:String) : void;
      
      function set dungeonSuccess(val:uint) : void;
      
      function set dungeonMod1(val:uint) : void;
      
      function set dungeonMod2(val:uint) : void;
      
      function set dungeonMod3(val:uint) : void;
      
      function set dungeonMod4(val:uint) : void;
      
      function TransactionResponse(account_id:uint, succeeded:uint, offer_id:uint, weapon_id:uint) : void;
   }
}

