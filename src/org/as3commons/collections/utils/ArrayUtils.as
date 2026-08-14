package org.as3commons.collections.utils
{
   import org.as3commons.collections.Map;
   import org.as3commons.collections.framework.IComparator;
   import org.as3commons.collections.framework.IMap;
   
   public class ArrayUtils
   {
      
      public function ArrayUtils()
      {
         super();
      }
      
      public static function shuffle(array:Array) : Boolean
      {
         var _loc3_:uint = 0;
         var _loc4_:* = undefined;
         var _loc2_:uint = array.length;
         if(_loc2_ < 2)
         {
            return false;
         }
         while(--_loc2_)
         {
            _loc3_ = Math.floor(Math.random() * (_loc2_ + 1));
            _loc4_ = array[_loc2_];
            array[_loc2_] = array[_loc3_];
            array[_loc3_] = _loc4_;
         }
         return true;
      }
      
      public static function arraysEqual(array1:Array, array2:Array) : Boolean
      {
         if(array1 == array2)
         {
            return true;
         }
         var _loc3_:Number = array1.length;
         if(_loc3_ != array2.length)
         {
            return false;
         }
         while(_loc3_--)
         {
            if(array1[_loc3_] !== array2[_loc3_])
            {
               return false;
            }
         }
         return true;
      }
      
      public static function arraysMatch(array1:Array, array2:Array) : Boolean
      {
         if(array1 == array2)
         {
            return true;
         }
         var _loc3_:Number = array1.length;
         if(_loc3_ != array2.length)
         {
            return false;
         }
         var _loc4_:IMap = new Map();
         while(_loc3_--)
         {
            if(_loc4_.hasKey(array1[_loc3_]))
            {
               _loc4_.replaceFor(array1[_loc3_],_loc4_.itemFor(array1[_loc3_]) + 1);
            }
            else
            {
               _loc4_.add(array1[_loc3_],1);
            }
         }
         _loc3_ = array2.length;
         while(_loc3_--)
         {
            if(!_loc4_.hasKey(array2[_loc3_]))
            {
               return false;
            }
            if(_loc4_.itemFor(array2[_loc3_]) == 1)
            {
               _loc4_.removeKey(array2[_loc3_]);
            }
            else
            {
               _loc4_.replaceFor(array2[_loc3_],_loc4_.itemFor(array2[_loc3_]) - 1);
            }
         }
         return _loc4_.size == 0;
      }
      
      public static function insertionSort(array:Array, comparator:IComparator) : Boolean
      {
         var _loc5_:* = undefined;
         var _loc6_:uint = 0;
         if(array.length < 2)
         {
            return false;
         }
         var _loc3_:uint = array.length;
         var _loc4_:uint = 1;
         while(_loc4_ < _loc3_)
         {
            _loc5_ = array[_loc4_];
            _loc6_ = _loc4_;
            while(_loc6_ > 0 && comparator.compare(array[_loc6_ - 1],_loc5_) == 1)
            {
               array[_loc6_] = array[_loc6_ - 1];
               _loc6_--;
            }
            array[_loc6_] = _loc5_;
            _loc4_++;
         }
         return true;
      }
      
      public static function mergeSort(array:Array, comparator:IComparator) : Boolean
      {
         if(array.length < 2)
         {
            return false;
         }
         var _loc3_:uint = Math.floor(array.length / 2);
         var _loc4_:uint = array.length - _loc3_;
         var _loc5_:Array = new Array(_loc3_);
         var _loc6_:Array = new Array(_loc4_);
         var _loc7_:uint = 0;
         _loc7_ = 0;
         while(_loc7_ < _loc3_)
         {
            _loc5_[_loc7_] = array[_loc7_];
            _loc7_++;
         }
         _loc7_ = _loc3_;
         while(_loc7_ < _loc3_ + _loc4_)
         {
            _loc6_[_loc7_ - _loc3_] = array[_loc7_];
            _loc7_++;
         }
         mergeSort(_loc5_,comparator);
         mergeSort(_loc6_,comparator);
         _loc7_ = 0;
         var _loc8_:uint = 0;
         var _loc9_:uint = 0;
         while(_loc5_.length != _loc8_ && _loc6_.length != _loc9_)
         {
            if(comparator.compare(_loc5_[_loc8_],_loc6_[_loc9_]) != 1)
            {
               array[_loc7_] = _loc5_[_loc8_];
               _loc7_++;
               _loc8_++;
            }
            else
            {
               array[_loc7_] = _loc6_[_loc9_];
               _loc7_++;
               _loc9_++;
            }
         }
         while(_loc5_.length != _loc8_)
         {
            array[_loc7_] = _loc5_[_loc8_];
            _loc7_++;
            _loc8_++;
         }
         while(_loc6_.length != _loc9_)
         {
            array[_loc7_] = _loc6_[_loc9_];
            _loc7_++;
            _loc9_++;
         }
         return true;
      }
   }
}

