package org.as3commons.collections.framework
{
   public interface ISortedMap extends IMap, ISortOrder
   {
      
      function higherKey(item:*) : *;
      
      function lesserKey(item:*) : *;
      
      function equalKeys(item:*) : Array;
   }
}

