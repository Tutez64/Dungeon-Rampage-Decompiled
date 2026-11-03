package Collections
{
   import flash.Boot;
   
   public class ArrayList
   {
      
      public var _array:Array;
      
      public function ArrayList()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         _array = [];
      }
      
      public function remove(item:*) : Boolean
      {
         var _loc2_:int = _array.indexOf(item);
         if(_loc2_ == -1)
         {
            return false;
         }
         _array.splice(_loc2_,1);
         return true;
      }
      
      public function iterator(cursor:* = undefined) : IIterator
      {
         return new ArrayListIterator(_array);
      }
      
      public function get_size() : uint
      {
         return int(_array.length);
      }
      
      public function get size() : uint
      {
         return get_size();
      }
      
      public function clear() : Boolean
      {
         if(int(_array.length) == 0)
         {
            return false;
         }
         _array = [];
         return true;
      }
      
      public function add(item:*) : uint
      {
         _array.push(item);
         return int(_array.length) - 1;
      }
   }
}

