package Brain.Sound
{
   import flash.events.Event;
   
   public class SoundCategoryVoumeChangedEvent extends Event
   {
      
      public static const TYPE:String = "SoundCategoryVoumeChangedEvent";
      
      public function SoundCategoryVoumeChangedEvent(bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super("SoundCategoryVoumeChangedEvent",bubbles,cancelable);
      }
   }
}

