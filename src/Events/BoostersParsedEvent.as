package Events
{
   import flash.events.Event;
   
   public class BoostersParsedEvent extends Event
   {
      
      public static const BOOSTERS_PARSED_UPDATE:String = "BoostersParsedEvent_BOOSTERS_PARSED_UPDATE";
      
      public function BoostersParsedEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super(type,bubbles,cancelable);
      }
   }
}

