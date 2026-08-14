package Events
{
   import flash.events.Event;
   
   public class II_FloorCompleteEvent extends Event
   {
      
      public static const TYPE:String = "II_FLOOR_COMPLETE";
      
      public function II_FloorCompleteEvent(bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super("II_FLOOR_COMPLETE",bubbles,cancelable);
      }
   }
}

