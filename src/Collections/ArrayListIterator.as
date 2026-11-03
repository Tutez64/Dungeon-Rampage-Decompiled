package Collections
{
   import flash.Boot;
   
   public class ArrayListIterator implements IListIterator
   {
      
      public var _next:int;
      
      public var _array:Array;
      
      public function ArrayListIterator(array:Array = undefined)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         _array = array;
         _next = int(_array.length) == 0 ? -1 : 0;
      }
      
      public function next() : *
      {
         if(_next == -1)
         {
            return undefined;
         }
         var _loc1_:int = _next;
         _next = _next >= int(_array.length) - 1 ? -1 : _next + 1;
         return _array[_loc1_];
      }
      
      public function hasNext() : Boolean
      {
         return _next > -1;
      }
   }
}

