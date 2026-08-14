package org.as3commons.collections.framework.core
{
   import org.as3commons.collections.LinkedList;
   import org.as3commons.collections.framework.ILinkedListIterator;
   
   use namespace as3commons_collections;
   
   public class LinkedListIterator extends AbstractLinkedCollectionIterator implements ILinkedListIterator
   {
      
      public function LinkedListIterator(list:LinkedList)
      {
         super(list);
      }
      
      public function addBefore(item:*) : void
      {
         _current = null;
         LinkedList(_collection).addNodeBefore_internal(_next,new LinkedNode(item));
      }
      
      public function get previousItem() : *
      {
         return _next ? (_next.left ? _next.left.item : undefined) : (_collection.size ? _collection.lastNode_internal.item : undefined);
      }
      
      public function replace(item:*) : Boolean
      {
         if(!_current)
         {
            return false;
         }
         if(_current.item === item)
         {
            return false;
         }
         _current.item = item;
         return true;
      }
      
      override protected function removeCurrent() : void
      {
         LinkedList(_collection).removeNode_internal(_current);
      }
      
      public function addAfter(item:*) : void
      {
         _current = null;
         if(_next)
         {
            LinkedList(_collection).addNodeBefore_internal(_next,new LinkedNode(item));
            _next = _next.left;
         }
         else
         {
            LinkedList(_collection).addNodeBefore_internal(null,new LinkedNode(item));
            _next = _collection.lastNode_internal;
         }
      }
      
      public function get nextItem() : *
      {
         return _next ? _next.item : undefined;
      }
   }
}

