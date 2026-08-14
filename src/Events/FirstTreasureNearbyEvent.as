package Events
{
   import flash.events.Event;
   
   public class FirstTreasureNearbyEvent extends Event
   {
      
      public static const EVENT_NAME:String = "FirstTreasureNearby";
      
      public function FirstTreasureNearbyEvent(bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super("FirstTreasureNearby",bubbles,cancelable);
      }
   }
}

