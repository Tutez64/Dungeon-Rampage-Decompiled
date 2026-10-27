package DistributedObjects
{
   import Brain.Event.EventComponent;
   import Brain.GameObject.GameObject;
   import Brain.Logger.Logger;
   import Events.ClientExitCompleteEvent;
   import Events.MatchMakerLoadedEvent;
   import Events.RequestEntryFailedEvent;
   import Facade.DBFacade;
   import GeneratedCode.GameServerPartyMember;
   import GeneratedCode.IMatchMaker;
   import GeneratedCode.InfiniteMapNodeDetail;
   import GeneratedCode.MatchMakerNetworkComponent;
   import flash.events.Event;
   import org.as3commons.collections.Map;
   
   public class MatchMaker extends GameObject implements IMatchMaker
   {
      
      public static var EPOCH_ROLL_OVER_EVENT_NAME:String = "EPOCH_ROLL_OVER_EVENT_NAME";
      
      private var netIface:MatchMakerNetworkComponent;
      
      private var mDBFacade:DBFacade;
      
      private var mEventComponent:EventComponent;
      
      private var mInfiniteMapNodeDetails:Vector.<InfiniteMapNodeDetail>;
      
      private var mInfiniteDungeonDetails:Map;
      
      public function MatchMaker(facade:DBFacade, remoteId:uint = 0)
      {
         mDBFacade = facade;
         super(facade,remoteId);
         mEventComponent = new EventComponent(mDBFacade);
      }
      
      public function setNetworkComponentMatchMaker(iface:MatchMakerNetworkComponent) : void
      {
         netIface = iface;
      }
      
      public function InfiniteDetails(value_0:Vector.<InfiniteMapNodeDetail>) : void
      {
         mInfiniteMapNodeDetails = value_0;
         setInfiniteDungeonDetails();
         mEventComponent.dispatchEvent(new Event(EPOCH_ROLL_OVER_EVENT_NAME));
      }
      
      private function setInfiniteDungeonDetails() : void
      {
         var _loc1_:* = null;
         mInfiniteDungeonDetails = new Map();
         for each(_loc1_ in mInfiniteMapNodeDetails)
         {
            if(_loc1_)
            {
               mInfiniteDungeonDetails.add(_loc1_.nodeId,_loc1_);
            }
         }
      }
      
      public function ClientInformPartyComposition(partyMembers:Vector.<GameServerPartyMember>) : void
      {
         for each(var _loc2_:GameServerPartyMember in partyMembers)
         {
         }
      }
      
      public function postGenerate() : void
      {
         mDBFacade.mDistributedObjectManager.mMatchMaker = this;
         mEventComponent.dispatchEvent(new MatchMakerLoadedEvent(this));
      }
      
      public function RequestExit() : void
      {
         Logger.info("MatchMaker:RequestExit");
         netIface.send_RequestExit(0);
      }
      
      public function RequestEntry(mapdnodeID:uint, friendID:uint, mapID:uint, onlyfriends:uint, grouping:String) : void
      {
         Logger.info("MatchMaker:RequestEntry");
         netIface.send_ClientRequestEntry(mDBFacade.demographicsJson,mDBFacade.sCode,mapdnodeID,friendID,mapID,onlyfriends,grouping);
      }
      
      public function ClientRequestEntryResponce(ResponceCode:uint, truenode:uint) : void
      {
         Logger.info("MatchMaker:ClientRequestEntryResponce");
         if(ResponceCode != 0)
         {
            mEventComponent.dispatchEvent(new RequestEntryFailedEvent(ResponceCode));
         }
      }
      
      public function RequestPartyMemberInvite(partyInviteId:uint) : void
      {
         Logger.info("MatchMaker:RequestPartyMemberInvite");
         netIface.send_ClientRequestPartyMemberInvite(mDBFacade.demographicsJson,partyInviteId);
      }
      
      override public function destroy() : void
      {
         mDBFacade.mDistributedObjectManager.mMatchMaker = null;
         mInfiniteMapNodeDetails = null;
         mInfiniteDungeonDetails = null;
         if(mEventComponent)
         {
            mEventComponent.destroy();
         }
         super.destroy();
      }
      
      public function ClientExitComplete(ResponceCode:uint) : void
      {
         Logger.info("MatchMaker:ClientExitComplete" + ResponceCode.toString());
         mEventComponent.dispatchEvent(new ClientExitCompleteEvent());
      }
      
      public function getInfiniteDungeonDetailForNodeId(nodeId:uint) : InfiniteMapNodeDetail
      {
         return mInfiniteDungeonDetails.itemFor(nodeId);
      }
   }
}

