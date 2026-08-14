package org.as3commons.collections.framework
{
   public interface ILinkedListIterator extends ICollectionIterator
   {
      
      function addBefore(item:*) : void;
      
      function replace(item:*) : Boolean;
      
      function get nextItem() : *;
      
      function get previousItem() : *;
      
      function addAfter(item:*) : void;
   }
}

