package org.as3commons.collections.framework
{
   public interface IOrderedListIterator extends IListIterator
   {
      
      function addBefore(item:*) : uint;
      
      function addAfter(item:*) : uint;
      
      function replace(item:*) : Boolean;
   }
}

