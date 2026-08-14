package org.as3commons.collections.framework
{
   public interface ICollection extends IIterable
   {
      
      function get size() : uint;
      
      function remove(item:*) : Boolean;
      
      function has(item:*) : Boolean;
      
      function clear() : Boolean;
      
      function toArray() : Array;
   }
}

