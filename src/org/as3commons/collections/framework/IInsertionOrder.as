package org.as3commons.collections.framework
{
   public interface IInsertionOrder extends IOrder
   {
      
      function reverse() : Boolean;
      
      function sort(comparator:IComparator) : Boolean;
   }
}

