package Events
{
   import flash.events.Event;
   
   public class FriendStatusEvent extends Event
   {
      
      public static const FRIEND_ONLINE_STATUS:String = "FRIEND_STATUS_EVENT";
      
      public static const FRIEND_DUNGEON_STATUS:String = "FRIEND_DUNGEON_STATUS_EVENT";
      
      private var mFriendId:uint;
      
      private var mStatus:Boolean;
      
      public function FriendStatusEvent(type:String, friendId:uint, status:Boolean, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super(type,bubbles,cancelable);
         mFriendId = friendId;
         mStatus = status;
      }
      
      public function get friendId() : uint
      {
         return mFriendId;
      }
      
      public function get status() : Boolean
      {
         return mStatus;
      }
   }
}

