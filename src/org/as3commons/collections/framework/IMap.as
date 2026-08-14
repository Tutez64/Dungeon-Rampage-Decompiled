package org.as3commons.collections.framework
{
   public interface IMap extends IDuplicates
   {
      
      function add(key:*, item:*) : Boolean;
      
      function hasKey(key:*) : Boolean;
      
      function itemFor(key:*) : *;
      
      function keysToArray() : Array;
      
      function removeKey(key:*) : *;
      
      function replaceFor(key:*, item:*) : Boolean;
      
      function keyIterator() : IIterator;
   }
}

