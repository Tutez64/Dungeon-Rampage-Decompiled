package haxe
{
   public interface IMap
   {
      
      function toString() : String;
      
      function set(k:Object, v:Object) : void;
      
      function remove(k:Object) : Boolean;
      
      function keys() : Object;
      
      function keyValueIterator() : Object;
      
      function iterator() : Object;
      
      function get(k:Object) : Object;
      
      function exists(k:Object) : Boolean;
      
      function copy() : IMap;
      
      function clear() : void;
   }
}

