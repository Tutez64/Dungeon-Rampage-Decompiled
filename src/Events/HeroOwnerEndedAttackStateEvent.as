package Events
{
   import flash.events.Event;
   
   public class HeroOwnerEndedAttackStateEvent extends Event
   {
      
      public static const EVENT_NAME:String = "PLAYER_ENDED_ATTACK_STATE";
      
      public function HeroOwnerEndedAttackStateEvent(type:String, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super(type,bubbles,cancelable);
      }
   }
}

