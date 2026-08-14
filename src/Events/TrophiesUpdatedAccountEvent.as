package Events
{
   import flash.events.Event;
   
   public class TrophiesUpdatedAccountEvent extends Event
   {
      
      public static const EVENT_NAME:String = "TrophiesUpdatedAccountEvent";
      
      public var trophyCount:uint;
      
      public function TrophiesUpdatedAccountEvent(newTrophyCount:uint, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super("TrophiesUpdatedAccountEvent",bubbles,cancelable);
         trophyCount = newTrophyCount;
      }
   }
}

