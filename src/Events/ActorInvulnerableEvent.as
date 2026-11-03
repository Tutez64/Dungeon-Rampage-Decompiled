package Events
{
   public class ActorInvulnerableEvent extends GameObjectEvent
   {
      
      public var mIsInvulnerable:Boolean;
      
      public function ActorInvulnerableEvent(actorInvulnerableType:String, id:uint, isInvulnerable:Boolean, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super(actorInvulnerableType,id,bubbles,cancelable);
         mIsInvulnerable = isInvulnerable;
      }
   }
}

