package Actor.Player.Input.DBMouseEvents
{
   import Actor.ActorGameObject;
   
   public class MouseUpOnActorEvent extends DBMouseEvent
   {
      
      public static const TYPE:String = "MouseUpOnActorEvent";
      
      public function MouseUpOnActorEvent(actor:ActorGameObject, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super("MouseUpOnActorEvent",actor,bubbles,cancelable);
      }
   }
}

