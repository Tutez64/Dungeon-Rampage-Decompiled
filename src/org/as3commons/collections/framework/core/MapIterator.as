package org.as3commons.collections.framework.core
{
   import org.as3commons.collections.Map;
   import org.as3commons.collections.framework.IMapIterator;
   import org.as3commons.collections.iterators.ArrayIterator;
   
   public class MapIterator extends ArrayIterator implements IMapIterator
   {
      
      protected var _map:Map;
      
      public function MapIterator(map:Map)
      {
         this._map = map;
         super(this._map.keysToArray());
      }
      
      override public function next() : *
      {
         return this._map.itemFor(super.next());
      }
      
      public function get previousKey() : *
      {
         return _array[previousIndex];
      }
      
      override protected function removeCurrent() : void
      {
         this._map.removeKey(super.current);
         super.removeCurrent();
      }
      
      override public function previous() : *
      {
         return this._map.itemFor(super.previous());
      }
      
      override public function get current() : *
      {
         return this._map.itemFor(super.current);
      }
      
      public function get nextKey() : *
      {
         return _array[_next];
      }
      
      public function get key() : *
      {
         return super.current;
      }
   }
}

