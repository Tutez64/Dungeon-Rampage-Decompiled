package Events
{
   import flash.events.Event;
   
   public class FirstTreasureCollectedEvent extends Event
   {
      
      public static const EVENT_NAME:String = "FirstTreasureCollected";
      
      public function FirstTreasureCollectedEvent(bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super("FirstTreasureCollected",bubbles,cancelable);
      }
   }
}

