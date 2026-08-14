package Events
{
   import flash.events.Event;
   
   public class FacebookLevelUpPostEvent extends Event
   {
      
      public static const NAME:String = "FacebookLevelUpPostEvent";
      
      private var mLevel:uint;
      
      public function FacebookLevelUpPostEvent(type:String, level:uint, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super(type,bubbles,cancelable);
         mLevel = level;
      }
      
      public function get level() : uint
      {
         return mLevel;
      }
   }
}

