package Events
{
   import flash.events.Event;
   
   public class PlayerExitEvent extends Event
   {
      
      public static const EVENT_STRING:String = "PlayerExitEvent_str";
      
      public var id:uint;
      
      public function PlayerExitEvent(in_id:uint, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         id = in_id;
         super("PlayerExitEvent_str",bubbles,cancelable);
      }
   }
}

