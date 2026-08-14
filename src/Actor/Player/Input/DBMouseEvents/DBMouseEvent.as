package Actor.Player.Input.DBMouseEvents
{
   import Actor.ActorGameObject;
   import flash.events.Event;
   
   public class DBMouseEvent extends Event
   {
      
      protected var mActor:ActorGameObject;
      
      public function DBMouseEvent(type:String, actor:ActorGameObject, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super(type,bubbles,cancelable);
         mActor = actor;
      }
      
      public function get actor() : ActorGameObject
      {
         return mActor;
      }
   }
}

