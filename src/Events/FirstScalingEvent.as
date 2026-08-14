package Events
{
   import flash.events.Event;
   
   public class FirstScalingEvent extends Event
   {
      
      public static const EVENT_NAME:String = "FirstScaling";
      
      public function FirstScalingEvent(bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super("FirstScaling",bubbles,cancelable);
      }
   }
}

