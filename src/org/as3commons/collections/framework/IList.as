package org.as3commons.collections.framework
{
   public interface IList extends IOrder, IDuplicates
   {
      
      function removeAllAt(index:uint, numItems:uint) : Array;
      
      function add(item:*) : uint;
      
      function set array(array:Array) : void;
      
      function lastIndexOf(item:*) : int;
      
      function itemAt(index:uint) : *;
      
      function removeAt(index:uint) : *;
      
      function firstIndexOf(item:*) : int;
   }
}

