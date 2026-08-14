package Events
{
   import flash.events.Event;
   
   public class ClientExitCompleteEvent extends Event
   {
      
      public static const EVENT_NAME:String = "CLIENT_EXIT_COMPLETE";
      
      public function ClientExitCompleteEvent(bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super("CLIENT_EXIT_COMPLETE",bubbles,cancelable);
      }
   }
}

