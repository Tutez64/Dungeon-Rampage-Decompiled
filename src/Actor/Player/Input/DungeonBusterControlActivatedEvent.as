package Actor.Player.Input
{
   import flash.events.Event;
   
   public class DungeonBusterControlActivatedEvent extends Event
   {
      
      public static const TYPE:String = "DungeonBusterControlActivatedEvent";
      
      public function DungeonBusterControlActivatedEvent(bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super("DungeonBusterControlActivatedEvent",bubbles,cancelable);
      }
   }
}

