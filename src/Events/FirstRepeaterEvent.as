package Events
{
   import flash.events.Event;
   
   public class FirstRepeaterEvent extends Event
   {
      
      public static const EVENT_NAME:String = "FirstRepeater";
      
      public function FirstRepeaterEvent(bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super("FirstRepeater",bubbles,cancelable);
      }
   }
}

