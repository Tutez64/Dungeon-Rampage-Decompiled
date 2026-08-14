package org.as3commons.collections.framework
{
   public interface ICollectionIterator extends IIterator
   {
      
      function hasPrevious() : Boolean;
      
      function start() : void;
      
      function remove() : Boolean;
      
      function previous() : *;
      
      function get current() : *;
      
      function end() : void;
   }
}

