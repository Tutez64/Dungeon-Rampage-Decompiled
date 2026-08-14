package Events
{
   import flash.events.Event;
   
   public class RequestEntryFailedEvent extends Event
   {
      
      public static const EVENT_NAME:String = "REQUEST_ENTRY_FAILED";
      
      protected var mErrorCode:uint;
      
      public function RequestEntryFailedEvent(errorCode:uint, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super("REQUEST_ENTRY_FAILED",bubbles,cancelable);
         mErrorCode = errorCode;
      }
      
      public function get errorCode() : uint
      {
         return mErrorCode;
      }
   }
}

