package DistributedObjects
{
   import Brain.Event.EventComponent;
   import Brain.Logger.Logger;
   import Events.ChatEvent;
   import Events.GameObjectEvent;
   import Facade.DBFacade;
   import GeneratedCode.IPlayerGameObjectOwner;
   import GeneratedCode.PlayerGameObjectOwnerNetworkComponent;
   import flash.events.Event;
   
   public class PlayerGameObjectOwner extends PlayerGameObject implements IPlayerGameObjectOwner
   {
      
      public static const REQUEST_ENTRY_PLAYER_FLOOR:String = "REQUEST_ENTRY_PLAYER_FLOOR";
      
      public static const REQUEST_ENTRY_PLAYER_HERO:String = "REQUEST_ENTRY_PLAYER_HERO";
      
      protected var mEventComponent:EventComponent;
      
      protected var mBasicCurrency:uint;
      
      protected var mPlayerGameObjectOwnerNetworkComponent:PlayerGameObjectOwnerNetworkComponent;
      
      public function PlayerGameObjectOwner(dbFacade:DBFacade, remoteId:uint = 0)
      {
         Logger.debug("New  PlayerGameObjectOwner******************************");
         super(dbFacade,remoteId);
         mBasicCurrency = 0;
         mEventComponent = new EventComponent(dbFacade);
         mEventComponent.addListener("REQUEST_ENTRY_PLAYER_FLOOR",event_request_entry);
         mEventComponent.addListener("REQUEST_ENTRY_PLAYER_HERO",event_request_entry_hero);
         mEventComponent.addListener(GameObjectEvent.uniqueEvent("ChatEvent_OUTGOING_CHAT_UPDATE",0),this.handleOutgoingChat);
      }
      
      private function event_request_entry_hero(e:Event) : void
      {
         Logger.debug(" Sending Request Hero");
         mPlayerGameObjectOwnerNetworkComponent.send_requesthero();
      }
      
      private function event_request_entry(e:Event) : void
      {
         Logger.debug(" Sending Request Entry Floor");
         mPlayerGameObjectOwnerNetworkComponent.send_requestentry();
      }
      
      public function setOwnerNetworkComponentPlayerGameObject(iface:PlayerGameObjectOwnerNetworkComponent) : void
      {
         mPlayerGameObjectOwnerNetworkComponent = iface;
      }
      
      private function handleOutgoingChat(event:ChatEvent) : void
      {
         var _loc2_:String = this.screenName + ": " + event.message;
         this.sendChat(_loc2_);
      }
      
      public function sendChat(message:String) : void
      {
         this.Chat(message);
         mPlayerGameObjectOwnerNetworkComponent.send_Chat(message);
      }
      
      public function sendPlayerIsTyping(value:Boolean) : void
      {
         if(value)
         {
            this.ShowPlayerIsTyping(1);
            mPlayerGameObjectOwnerNetworkComponent.send_ShowPlayerIsTyping(1);
         }
         else
         {
            this.ShowPlayerIsTyping(0);
            mPlayerGameObjectOwnerNetworkComponent.send_ShowPlayerIsTyping(0);
         }
      }
      
      override public function get basicCurrency() : uint
      {
         return mBasicCurrency;
      }
      
      public function set basicCurrency(val:uint) : void
      {
         mBasicCurrency = val;
         if(mDBFacade.hud)
         {
            mDBFacade.hud.setBasicCurrency(mBasicCurrency);
         }
      }
      
      override public function destroy() : void
      {
         super.destroy();
         mEventComponent.destroy();
         mEventComponent = null;
      }
   }
}

