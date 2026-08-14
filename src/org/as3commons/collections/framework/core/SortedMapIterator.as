package org.as3commons.collections.framework.core
{
   import org.as3commons.collections.SortedMap;
   import org.as3commons.collections.framework.IMapIterator;
   
   use namespace as3commons_collections;
   
   public class SortedMapIterator extends AbstractSortedCollectionIterator implements IMapIterator
   {
      
      public function SortedMapIterator(sortedMap:SortedMap, next:SortedMapNode)
      {
         super(sortedMap,next);
      }
      
      public function get previousKey() : *
      {
         var _loc1_:SortedMapNode = null;
         if(_next)
         {
            _loc1_ = _collection.previousNode_internal(_next) as SortedMapNode;
            return _loc1_ ? _loc1_.key : undefined;
         }
         return _collection.size ? SortedMapNode(_collection.mostRightNode_internal()).key : undefined;
      }
      
      public function get nextKey() : *
      {
         return _next ? SortedMapNode(_next).key : undefined;
      }
      
      public function get key() : *
      {
         return _current ? SortedMapNode(_current).key : undefined;
      }
   }
}

