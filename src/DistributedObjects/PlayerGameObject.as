package DistributedObjects
{
   import Brain.GameObject.GameObject;
   import Events.ChatEvent;
   import Events.ChatLogEvent;
   import Events.FriendStatusEvent;
   import Events.PlayerExitEvent;
   import Events.PlayerIsTypingEvent;
   import Facade.DBFacade;
   import GeneratedCode.IPlayerGameObject;
   import GeneratedCode.PlayerGameObjectNetworkComponent;
   import UI.UIChatLog;
   
   public class PlayerGameObject extends GameObject implements IPlayerGameObject
   {
      
      protected var mName:String;
      
      protected var mFacebookHelper:FacebookHelper;
      
      protected var mDBFacade:DBFacade;
      
      public function PlayerGameObject(dbFacade:DBFacade, remoteId:uint = 0)
      {
         super(dbFacade,remoteId);
         mDBFacade = dbFacade;
         mFacebookHelper = new FacebookHelper(dbFacade,remoteId);
         mFacade.eventManager.dispatchEvent(new FriendStatusEvent("FRIEND_DUNGEON_STATUS_EVENT",this.id,true));
      }
      
      public function setNetworkComponentPlayerGameObject(iface:PlayerGameObjectNetworkComponent) : void
      {
      }
      
      public function postGenerate() : void
      {
      }
      
      public function set screenName(val:String) : void
      {
         mName = val;
      }
      
      public function get screenName() : String
      {
         return mName;
      }
      
      public function get facebookId() : String
      {
         if(mFacebookHelper)
         {
            return mFacebookHelper.facebookId;
         }
         return "";
      }
      
      public function get isFriend() : Boolean
      {
         return mFacebookHelper.isFriend;
      }
      
      public function Chat(text:String) : void
      {
         mFacade.eventManager.dispatchEvent(new ChatEvent("ChatEvent_INCOMING_CHAT_UPDATE",id,text));
         mFacade.eventManager.dispatchEvent(new ChatLogEvent("CHAT_LOG_EVENT",text,UIChatLog.CHAT_TYPE,mName));
      }
      
      public function ShowPlayerIsTyping(value:uint) : void
      {
         if(value)
         {
            mFacade.eventManager.dispatchEvent(new PlayerIsTypingEvent("PLAYER_IS_TYPING",id,"CHAT_BOX_FOCUS_IN"));
         }
         else
         {
            mFacade.eventManager.dispatchEvent(new PlayerIsTypingEvent("PLAYER_IS_TYPING",id,"CHAT_BOX_FOCUS_OUT"));
         }
      }
      
      override public function destroy() : void
      {
         mFacade.eventManager.dispatchEvent(new FriendStatusEvent("FRIEND_DUNGEON_STATUS_EVENT",this.id,false));
         mFacade.eventManager.dispatchEvent(new PlayerExitEvent(id));
         if(mFacebookHelper)
         {
            mFacebookHelper.destroy();
         }
         mFacebookHelper = null;
         mDBFacade = null;
         super.destroy();
      }
      
      public function get basicCurrency() : uint
      {
         return mDBFacade.dbAccountInfo.basicCurrency;
      }
   }
}

import Account.FriendInfo;
import Events.FacebookIdReceivedEvent;
import Facade.DBFacade;

class FacebookHelper
{
   
   private var mFacebookId:String;
   
   private var mIsFriend:Boolean = false;
   
   private var mPlayerId:uint;
   
   private var mDBFacade:DBFacade;
   
   public function FacebookHelper(dbFacade:DBFacade, id:uint)
   {
      super();
      mDBFacade = dbFacade;
      mPlayerId = id;
      getFacebookId();
   }
   
   private function getFacebookId() : void
   {
      var friend:FriendInfo;
      if(mDBFacade.dbAccountInfo.id == mPlayerId)
      {
         mFacebookId = mDBFacade.facebookPlayerId;
      }
      else if(mDBFacade.dbAccountInfo.friendInfos.hasKey(mPlayerId))
      {
         mIsFriend = true;
         friend = mDBFacade.dbAccountInfo.friendInfos.itemFor(mPlayerId);
         if(friend)
         {
            mFacebookId = friend.facebookId;
         }
      }
      else
      {
         mDBFacade.dbAccountInfo.getFacebookIdRPC(mPlayerId,function(param1:String):void
         {
            if(param1 != "")
            {
               mDBFacade.eventManager.dispatchEvent(new FacebookIdReceivedEvent("FACEBOOK_ID_RECEIVED_EVENT",mPlayerId,param1));
            }
            mFacebookId = param1;
         });
      }
   }
   
   public function get facebookId() : String
   {
      return mFacebookId;
   }
   
   public function get isFriend() : Boolean
   {
      return mIsFriend;
   }
   
   public function destroy() : void
   {
      mDBFacade = null;
   }
}
