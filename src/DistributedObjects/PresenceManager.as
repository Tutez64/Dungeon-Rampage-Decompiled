package DistributedObjects
{
   import Brain.Event.EventComponent;
   import Brain.GameObject.GameObject;
   import Events.FriendStatusEvent;
   import Facade.DBFacade;
   import GeneratedCode.IPresenceManager;
   import GeneratedCode.PresenceManagerNetworkComponent;
   import flash.events.Event;
   import flash.events.TimerEvent;
   import flash.utils.Timer;
   import org.as3commons.collections.Map;
   
   public class PresenceManager extends GameObject implements IPresenceManager
   {
      
      private static var mInstance:PresenceManager;
      
      private var mDBFacade:DBFacade;
      
      private var mPresence:Map = new Map();
      
      private var mEventComponent:EventComponent;
      
      private var mNetworkComponent:PresenceManagerNetworkComponent;
      
      private var mAddFriendsTimer:Timer;
      
      private var mPendingAccountIds:Vector.<uint>;
      
      public function PresenceManager(facade:DBFacade, remoteId:uint = 0)
      {
         mEventComponent = new EventComponent(facade);
         mDBFacade = facade;
         super(facade,remoteId);
         mInstance = this;
      }
      
      public static function instance() : PresenceManager
      {
         return mInstance;
      }
      
      public function isOnline(who:uint) : Boolean
      {
         return mPresence.hasKey(who);
      }
      
      public function isInDungeon(who:uint) : Boolean
      {
         return mPresence.hasKey(who) && mPresence.itemFor(who) != 0;
      }
      
      public function InDungeonId(who:uint) : uint
      {
         if(mPresence.hasKey(who))
         {
            return mPresence.itemFor(who);
         }
         return 0;
      }
      
      public function setNetworkComponentPresenceManager(iface:PresenceManagerNetworkComponent) : void
      {
         mNetworkComponent = iface;
      }
      
      public function postGenerate() : void
      {
         mDBFacade.mDistributedObjectManager.mPresenceManager = this;
      }
      
      public function friendState(yesno:uint, who:uint, state:uint) : void
      {
         var _loc4_:* = 0;
         if(yesno == 0)
         {
            if(mPresence.hasKey(who))
            {
               mPresence.removeKey(who);
               mEventComponent.dispatchEvent(new FriendStatusEvent("FRIEND_STATUS_EVENT",who,false));
            }
         }
         else if(!mPresence.hasKey(who))
         {
            mPresence.add(who,state);
            mEventComponent.dispatchEvent(new FriendStatusEvent("FRIEND_STATUS_EVENT",who,true));
         }
         else
         {
            _loc4_ = uint(mPresence.itemFor(who));
            if(_loc4_ != state)
            {
               mPresence.replaceFor(who,state);
            }
         }
         mEventComponent.dispatchEvent(new Event("REFRESH_FRIENDS_EVENT"));
      }
      
      public function addFriends(who:Vector.<uint>) : void
      {
         mPendingAccountIds = who;
         if(mAddFriendsTimer != null)
         {
            mAddFriendsTimer.stop();
            mAddFriendsTimer.removeEventListener("timer",onAddFriendsTimerComplete);
         }
         mAddFriendsTimer = new Timer(2000,1);
         mAddFriendsTimer.addEventListener("timer",onAddFriendsTimerComplete);
         mAddFriendsTimer.start();
      }
      
      private function onAddFriendsTimerComplete(event:TimerEvent) : void
      {
         if(mPendingAccountIds != null && mPendingAccountIds.length > 0)
         {
            mNetworkComponent.send_addFriends(mPendingAccountIds);
            mPendingAccountIds = null;
         }
      }
   }
}

