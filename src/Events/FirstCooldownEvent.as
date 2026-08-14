package Events
{
   import flash.events.Event;
   
   public class FirstCooldownEvent extends Event
   {
      
      public static const EVENT_NAME:String = "FirstCooldown";
      
      public function FirstCooldownEvent(bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super("FirstCooldown",bubbles,cancelable);
      }
   }
}

