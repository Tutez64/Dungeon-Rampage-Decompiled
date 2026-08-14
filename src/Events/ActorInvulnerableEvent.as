package Events
{
   public class ActorInvulnerableEvent extends GameObjectEvent
   {
      
      public var mIsInvulnerable:Boolean;
      
      public function ActorInvulnerableEvent(type:String, id:uint, isInvulnerable:Boolean, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super(type,id,bubbles,cancelable);
         mIsInvulnerable = isInvulnerable;
      }
   }
}

