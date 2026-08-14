package Actor.Player.Input.DBMouseEvents
{
   import Actor.ActorGameObject;
   
   public class MouseDownOnActorEvent extends DBMouseEvent
   {
      
      public static const TYPE:String = "MouseDownOnActorEvent";
      
      public function MouseDownOnActorEvent(actor:ActorGameObject, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super("MouseDownOnActorEvent",actor,bubbles,cancelable);
      }
   }
}

