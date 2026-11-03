package Events
{
   import flash.events.Event;
   
   public class LevelUpPostEvent extends Event
   {
      
      public static const NAME:String = "LevelUpPostEvent";
      
      private var mLevel:uint;
      
      public function LevelUpPostEvent(levelUpPostType:String, level:uint, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super(levelUpPostType,bubbles,cancelable);
         mLevel = level;
      }
      
      public function get level() : uint
      {
         return mLevel;
      }
   }
}

