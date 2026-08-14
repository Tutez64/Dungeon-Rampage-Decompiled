package org.as3commons.collections.framework
{
   public interface IMapIterator extends ICollectionIterator
   {
      
      function get previousKey() : *;
      
      function get nextKey() : *;
      
      function get key() : *;
   }
}

