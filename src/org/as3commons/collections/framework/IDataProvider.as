package org.as3commons.collections.framework
{
   public interface IDataProvider
   {
      
      function get size() : uint;
      
      function itemAt(index:uint) : *;
   }
}

