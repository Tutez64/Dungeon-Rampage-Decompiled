package Events
{
   import flash.events.Event;
   
   public class GenericNewsFeedEvent extends Event
   {
      
      public static const NAME:String = "GENERIC_NEWS_FEED_MESSAGE_EVENT";
      
      private var mMessage:String;
      
      private var mPicSwfLocation:String;
      
      private var mPicSwfClassName:String;
      
      public function GenericNewsFeedEvent(type:String, message:String, picSwfLocation:String = "", picSwfClassName:String = "", bubbles:Boolean = false, cancelable:Boolean = false)
      {
         mMessage = message;
         mPicSwfLocation = picSwfLocation;
         mPicSwfClassName = picSwfClassName;
         super(type,bubbles,cancelable);
      }
      
      public function get message() : String
      {
         return mMessage;
      }
      
      public function get picLocation() : String
      {
         return mPicSwfLocation;
      }
      
      public function get picClassName() : String
      {
         return mPicSwfClassName;
      }
   }
}

