package Collections
{
   import flash.Boot;
   
   public class SetIterator implements ISetIterator
   {
      
      public var _set:Set;
      
      public var _next:int;
      
      public var _items:Array;
      
      public var _current:int;
      
      public function SetIterator(theSet:Set = undefined)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         _current = -1;
         _set = theSet;
         _items = theSet.toArray();
         _next = int(_items.length) == 0 ? -1 : 0;
      }
      
      public function remove() : Boolean
      {
         if(_current == -1)
         {
            return false;
         }
         if(_next > 0)
         {
            --_next;
         }
         _set.remove(_items[_current]);
         _items.splice(_current,1);
         _current = -1;
         return true;
      }
      
      public function next() : *
      {
         if(_next == -1)
         {
            _current = -1;
            return undefined;
         }
         _current = _next;
         _next = _next >= int(_items.length) - 1 ? -1 : _next + 1;
         return _items[_current];
      }
      
      public function hasNext() : Boolean
      {
         return _next > -1;
      }
   }
}

