package Brain.Utils
{
   public class Tuple
   {
      
      private var mFirst:*;
      
      private var mSecond:*;
      
      public function Tuple(first:*, second:*)
      {
         super();
         mFirst = first;
         mSecond = second;
      }
      
      public function get first() : *
      {
         return mFirst;
      }
      
      public function get second() : *
      {
         return mSecond;
      }
   }
}

