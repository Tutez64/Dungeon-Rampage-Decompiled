package Collections
{
   public class ArrayUtils
   {
      
      public function ArrayUtils()
      {
      }
      
      public static function insertionSort(array:Array, comparator:IComparator) : Boolean
      {
         var _loc6_:int = 0;
         var _loc7_:* = null;
         var _loc8_:int = 0;
         if(int(array.length) < 2)
         {
            return false;
         }
         var _loc3_:int = int(array.length);
         var _loc4_:int = 1;
         var _loc5_:int = _loc3_;
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc4_++;
            _loc7_ = array[_loc6_];
            _loc8_ = _loc6_;
            while(_loc8_ > 0 && comparator.compare(array[_loc8_ - 1],_loc7_) == 1)
            {
               array[_loc8_] = array[_loc8_ - 1];
               _loc8_--;
            }
            array[_loc8_] = _loc7_;
         }
         return true;
      }
   }
}

