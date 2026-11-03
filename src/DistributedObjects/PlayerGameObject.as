package DistributedObjects
{
   import Brain.GameObject.GameObject;
   import Events.ChatEvent;
   import Events.ChatLogEvent;
   import Events.FriendStatusEvent;
   import Events.PlayerExitEvent;
   import Events.PlayerIsTypingEvent;
   import Facade.DBFacade;
   import Facade.LoadingPrewarm;
   import Facade.TrickleCacheLoader;
   import GeneratedCode.HeroPreloadLook;
   import GeneratedCode.IPlayerGameObject;
   import GeneratedCode.PlayerGameObjectNetworkComponent;
   import StateMachine.MainStateMachine.LoadingScreenState;
   import UI.UIChatLog;
   
   public class PlayerGameObject extends GameObject implements IPlayerGameObject
   {
      
      protected var mName:String;
      
      protected var mHeroPreloadLook:HeroPreloadLook;
      
      protected var mSteamHelper:SteamHelper;
      
      protected var mDBFacade:DBFacade;
      
      public function PlayerGameObject(dbFacade:DBFacade, remoteId:uint = 0)
      {
         super(dbFacade,remoteId);
         mDBFacade = dbFacade;
         mSteamHelper = new SteamHelper(dbFacade,remoteId);
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
      
      public function set heroPreloadLook(val:HeroPreloadLook) : void
      {
         mHeroPreloadLook = val;
         if(val != null && id != mDBFacade.dbAccountInfo.id)
         {
            TrickleCacheLoader.queueHeroLookAtlases(mDBFacade,val,!(mDBFacade.mainStateMachine.currentState is LoadingScreenState));
            LoadingPrewarm.heroJoined(mDBFacade,val);
         }
      }
      
      public function get heroPreloadLook() : HeroPreloadLook
      {
         return mHeroPreloadLook;
      }
      
      public function get steamAvatarUrl() : String
      {
         if(mSteamHelper)
         {
            return mSteamHelper.steamAvatarUrl;
         }
         return "";
      }
      
      public function get isFriend() : Boolean
      {
         return mSteamHelper.isFriend;
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
         if(mSteamHelper)
         {
            mSteamHelper.destroy();
         }
         mSteamHelper = null;
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
import Events.SteamAvatarUrlReceivedEvent;
import Facade.DBFacade;

class SteamHelper
{
   
   private var mSteamAvatarUrl:String;
   
   private var mIsFriend:Boolean = false;
   
   private var mPlayerId:uint;
   
   private var mDBFacade:DBFacade;
   
   public function SteamHelper(dbFacade:DBFacade, id:uint)
   {
      super();
      mDBFacade = dbFacade;
      mPlayerId = id;
      getSteamAvatar();
   }
   
   private function getSteamAvatar() : void
   {
      var friend:FriendInfo;
      if(mDBFacade.dbAccountInfo.id == mPlayerId)
      {
         mSteamAvatarUrl = mDBFacade.mSteamAvatarUrl;
      }
      else if(mDBFacade.dbAccountInfo.friendInfos.hasKey(mPlayerId))
      {
         mIsFriend = true;
         friend = mDBFacade.dbAccountInfo.friendInfos.itemFor(mPlayerId);
         if(friend)
         {
            mSteamAvatarUrl = friend.steamAvatarUrl;
         }
      }
      else
      {
         mDBFacade.dbAccountInfo.getSteamAvatarUrlRPC(mPlayerId,function(param1:String):void
         {
            if(param1 != "" && mDBFacade)
            {
               mDBFacade.eventManager.dispatchEvent(new SteamAvatarUrlReceivedEvent("STEAM_AVATAR_URL_RECEIVED_EVENT",mPlayerId,param1));
            }
            mSteamAvatarUrl = param1;
         });
      }
   }
   
   public function get steamAvatarUrl() : String
   {
      return mSteamAvatarUrl;
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
