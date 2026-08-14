package Events
{
   import Facade.Locale;
   import flash.events.Event;
   
   public class XPBonusEvent extends Event
   {
      
      public static const NAME:String = "XP_BONUS_EVENT";
      
      private var mXPMultiplier:Number;
      
      private var mIsActive:Boolean;
      
      public function XPBonusEvent(type:String, isActive:Boolean, xpMultiplier:Number = 1, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super(type,bubbles,cancelable);
         mIsActive = isActive;
         mXPMultiplier = xpMultiplier;
      }
      
      public function get isActive() : Boolean
      {
         return mIsActive;
      }
      
      public function get xpMultiplier() : Number
      {
         return mXPMultiplier;
      }
      
      public function get xpMultiplierBonusTextForHUD() : String
      {
         return Locale.getString("BONUS_XP_" + mXPMultiplier.toString());
      }
      
      public function get xpMultiplierBonusTextForNewsFeed() : String
      {
         return Locale.getString("NEWS_FEED_BONUS_XP_" + mXPMultiplier.toString());
      }
   }
}

