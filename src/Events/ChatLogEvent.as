package Events
{
   import flash.events.Event;
   
   public class ChatLogEvent extends Event
   {
      
      public static const NAME:String = "CHAT_LOG_EVENT";
      
      private var mMessage:String;
      
      private var mChatLogType:String;
      
      private var mPlayerName:String;
      
      public function ChatLogEvent(eventName:String, message:String, chatLogType:String, playerName:String = "", bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super(eventName,bubbles,cancelable);
         mMessage = message;
         mChatLogType = chatLogType;
         mPlayerName = playerName;
      }
      
      public function get chat() : String
      {
         return mMessage;
      }
      
      public function get chatLogType() : String
      {
         return mChatLogType;
      }
      
      public function get playerName() : String
      {
         return mPlayerName;
      }
   }
}

