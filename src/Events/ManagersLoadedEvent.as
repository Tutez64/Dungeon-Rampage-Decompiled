package Events
{
   import flash.events.Event;
   
   public class ManagersLoadedEvent extends Event
   {
      
      public static const EVENT_NAME:String = "ManagersLoadedEvent";
      
      public function ManagersLoadedEvent(bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super("ManagersLoadedEvent",bubbles,cancelable);
      }
   }
}

