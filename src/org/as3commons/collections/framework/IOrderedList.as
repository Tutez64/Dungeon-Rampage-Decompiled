package org.as3commons.collections.framework
{
   public interface IOrderedList extends IList, IInsertionOrder
   {
      
      function addAt(index:uint, item:*) : Boolean;
      
      function replaceAt(index:uint, item:*) : Boolean;
      
      function addAllAt(index:uint, items:Array) : Boolean;
      
      function addLast(item:*) : void;
      
      function addFirst(item:*) : void;
   }
}

