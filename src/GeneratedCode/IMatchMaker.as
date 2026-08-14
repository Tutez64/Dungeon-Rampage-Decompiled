package GeneratedCode
{
   import Brain.GameObject.GameObject;
   
   public interface IMatchMaker
   {
      
      function setNetworkComponentMatchMaker(iface:MatchMakerNetworkComponent) : void;
      
      function postGenerate() : void;
      
      function getTrueObject() : GameObject;
      
      function destroy() : void;
      
      function InfiniteDetails(value_0:Vector.<InfiniteMapNodeDetail>) : void;
      
      function ClientRequestEntryResponce(ResponceCode:uint, truenode:uint) : void;
      
      function ClientExitComplete(ResponceCode:uint) : void;
      
      function ClientInformPartyComposition(partyMembers:Vector.<GameServerPartyMember>) : void;
   }
}

