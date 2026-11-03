package Collections
{
   import flash.Boot;
   
   public class MapIterator implements IMapIterator
   {
      
      public var _next:int;
      
      public var _map:Map;
      
      public var _keys:Array;
      
      public var _current:int;
      
      public function MapIterator(map:Map = undefined)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         _current = -1;
         _map = map;
         _keys = map.keysToArray();
         _next = int(_keys.length) == 0 ? -1 : 0;
      }
      
      public function next() : *
      {
         if(_next == -1)
         {
            _current = -1;
            return _map.itemFor(undefined);
         }
         _current = _next;
         _next = _next >= int(_keys.length) - 1 ? -1 : _next + 1;
         return _map.itemFor(_keys[_current]);
      }
      
      public function hasNext() : Boolean
      {
         return _next > -1;
      }
      
      public function get_key() : *
      {
         return _keys[_current];
      }
      
      public function get key() : *
      {
         return get_key();
      }
      
      public function get_current() : *
      {
         return _map.itemFor(_keys[_current]);
      }
      
      public function get current() : *
      {
         return get_current();
      }
   }
}

