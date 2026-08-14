package Brain.Utils
{
   public interface IPoolable
   {
      
      function postCheckout(isNewObject:Boolean) : void;
      
      function postCheckin() : void;
      
      function destroy() : void;
      
      function getPoolKey() : String;
   }
}

