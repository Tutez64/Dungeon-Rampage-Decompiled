package Collections
{
   import flash.Boot;
   
   public class SortedMapIterator implements IMapIterator
   {
      
      public var _nextIndex:int;
      
      public var _next:SortedMapNode;
      
      public var _map:SortedMap;
      
      public var _current:SortedMapNode;
      
      public function SortedMapIterator(map:SortedMap = undefined)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         _nextIndex = 0;
         _map = map;
         _next = map.nodeAt(0);
      }
      
      public function next() : *
      {
         if(_next == null)
         {
            _current = null;
            return undefined;
         }
         _current = _next;
         var _loc1_:int = _map.indexOfNode(_current,_nextIndex);
         _nextIndex = _loc1_ + 1;
         _next = _loc1_ == -1 ? null : _map.nodeAt(_nextIndex);
         return _current.item;
      }
      
      public function hasNext() : Boolean
      {
         return _next != null;
      }
      
      public function get_key() : *
      {
         if(_current != null)
         {
            return _current.key;
         }
         return undefined;
      }
      
      public function get key() : *
      {
         return get_key();
      }
      
      public function get_current() : *
      {
         if(_current != null)
         {
            return _current.item;
         }
         return undefined;
      }
      
      public function get current() : *
      {
         return get_current();
      }
   }
}

