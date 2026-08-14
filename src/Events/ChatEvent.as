package Events
{
   public class ChatEvent extends GameObjectEvent
   {
      
      public static const INCOMING_CHAT_UPDATE:String = "ChatEvent_INCOMING_CHAT_UPDATE";
      
      public static const OUTGOING_CHAT_UPDATE:String = "ChatEvent_OUTGOING_CHAT_UPDATE";
      
      public var message:String;
      
      public function ChatEvent(type:String, id:uint, message:String, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         this.message = message;
         super(type,id,bubbles,cancelable);
      }
   }
}

