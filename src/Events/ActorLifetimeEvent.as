package Events
{
   import flash.events.Event;
   
   public class ActorLifetimeEvent extends Event
   {
      
      public static const ACTOR_CREATE_EVENT:String = "ACTOR_CREATED";
      
      public static const ACTOR_DESTROY_EVENT:String = "ACTOR_DESTROYED";
      
      private var mActorId:uint;
      
      public function ActorLifetimeEvent(type:String, actorId:uint, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super(type,bubbles,cancelable);
         mActorId = actorId;
      }
      
      public function get actorId() : uint
      {
         return mActorId;
      }
   }
}

