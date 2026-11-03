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
      
      public var hasPortrait:Boolean = false;
      
      public var skinId:uint;
      
      public var steamAvatarUrl:String;
      
      public function FriendSummaryNewsFeedEvent(friendSummaryNewsFeedEventType:String, message:String, picMC:MovieClip, friendName:String, isFriendNameInFront:Boolean = false, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         mFriendName = friendName;
         mIsFriendNameInFront = isFriendNameInFront;
         mMessage = message;
         mPic = picMC;
         super(friendSummaryNewsFeedEventType,bubbles,cancelable);
      }
      
      public static function forPortrait(message:String, skinId:uint, friendName:String, steamUrl:String = null) : FriendSummaryNewsFeedEvent
      {
         var _loc5_:FriendSummaryNewsFeedEvent = new FriendSummaryNewsFeedEvent("FRIEND_SUMMARY_NEWS_FEED_MESSAGE_EVENT",message,null,friendName);
         _loc5_.hasPortrait = true;
         _loc5_.skinId = skinId;
         _loc5_.steamAvatarUrl = steamUrl;
         return _loc5_;
      }
      
      override public function clone() : Event
      {
         var _loc1_:FriendSummaryNewsFeedEvent = new FriendSummaryNewsFeedEvent(type,mMessage,mPic,mFriendName,mIsFriendNameInFront,bubbles,cancelable);
         _loc1_.hasPortrait = hasPortrait;
         _loc1_.skinId = skinId;
         _loc1_.steamAvatarUrl = steamAvatarUrl;
         return _loc1_;
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

