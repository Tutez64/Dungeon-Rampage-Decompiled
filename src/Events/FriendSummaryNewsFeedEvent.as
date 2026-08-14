package Events
{
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class FriendSummaryNewsFeedEvent extends Event
   {
      
      public static const NAME:String = "FRIEND_SUMMARY_NEWS_FEED_MESSAGE_EVENT";
      
      public static var FRIEND_NAME_HIGHLIGHT_COLOR:uint = 65280;
      
      private var mFriendName:String;
      
      private var mIsFriendNameInFront:Boolean;
      
      private var mMessage:String;
      
      private var mPic:MovieClip;
      
      public function FriendSummaryNewsFeedEvent(type:String, message:String, picMC:MovieClip, friendName:String, isFriendNameInFront:Boolean = false, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         mFriendName = friendName;
         mIsFriendNameInFront = isFriendNameInFront;
         mMessage = message;
         mPic = picMC;
         super(type,bubbles,cancelable);
      }
      
      public function get friendName() : String
      {
         return mFriendName;
      }
      
      public function get message() : String
      {
         return mMessage;
      }
      
      public function get isFriendNameInFront() : Boolean
      {
         return mIsFriendNameInFront;
      }
      
      public function get pic() : MovieClip
      {
         return mPic;
      }
   }
}

