package Actor.Player.Input.DBMouseEvents
{
   import Actor.ActorGameObject;
   
   public class MouseOutOnActorEvent extends DBMouseEvent
   {
      
      public static const TYPE:String = "MouseOutOnActorEvent";
      
      public function MouseOutOnActorEvent(actor:ActorGameObject, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super("MouseOutOnActorEvent",actor,bubbles,cancelable);
      }
   }
}

