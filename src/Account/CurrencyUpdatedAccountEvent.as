package Account
{
   import flash.events.Event;
   
   public class CurrencyUpdatedAccountEvent extends Event
   {
      
      public static const EVENT_NAME:String = "CurrencyUpdatedAccountEvent";
      
      private var mBasicCurrency:uint;
      
      private var mPremiumCurrency:uint;
      
      public function CurrencyUpdatedAccountEvent(basicCurrency:uint, premiumCurrency:uint, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         super("CurrencyUpdatedAccountEvent",bubbles,cancelable);
         mPremiumCurrency = premiumCurrency;
         mBasicCurrency = basicCurrency;
      }
      
      public function get basicCurrency() : uint
      {
         return mBasicCurrency;
      }
      
      public function get premiumCurrency() : uint
      {
         return mPremiumCurrency;
      }
   }
}

