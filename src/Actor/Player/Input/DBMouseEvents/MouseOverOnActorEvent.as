package Actor.Player.Input.DBMouseEvents
{
   import Actor.ActorGameObject;
   
   public class MouseOverOnActorEvent extends DBMouseEvent
   {
      
      public static const TYPE:String = "MouseOverOnActorEvent";
      
      public function MouseOverOnActorEvent(actor:ActorGameObject, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super("MouseOverOnActorEvent",actor,bubbles,cancelable);
      }
   }
}

