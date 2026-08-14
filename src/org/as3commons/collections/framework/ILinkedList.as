package org.as3commons.collections.framework
{
   public interface ILinkedList extends IInsertionOrder, IDuplicates
   {
      
      function add(item:*) : void;
      
      function addLast(item:*) : void;
      
      function addFirst(item:*) : void;
   }
}

