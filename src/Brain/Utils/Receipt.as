package Brain.Utils
{
   public class Receipt
   {
      
      private var mUnregisterFunction:Function;
      
      public function Receipt(unregisterDelegate:Function)
      {
         super();
         mUnregisterFunction = unregisterDelegate;
      }
      
      public function exit() : void
      {
         mUnregisterFunction();
      }
   }
}

