package Events
{
   import flash.events.Event;
   
   public class LEClientEvent extends Event
   {
      
      public static const SEND_EVENT:String = "SEND_EVENT";
      
      public var eventName:String = "";
      
      public function LEClientEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super("SEND_EVENT",bubbles,cancelable);
         eventName = type;
      }
   }
}

