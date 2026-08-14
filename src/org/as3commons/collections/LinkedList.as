package org.as3commons.collections
{
   import org.as3commons.collections.framework.IIterator;
   import org.as3commons.collections.framework.ILinkedList;
   import org.as3commons.collections.framework.core.AbstractLinkedDuplicatesCollection;
   import org.as3commons.collections.framework.core.LinkedListIterator;
   import org.as3commons.collections.framework.core.LinkedNode;
   import org.as3commons.collections.framework.core.as3commons_collections;
   
   use namespace as3commons_collections;
   
   public class LinkedList extends AbstractLinkedDuplicatesCollection implements ILinkedList
   {
      
      public function LinkedList()
      {
         super();
      }
      
      override public function iterator(cursor:* = undefined) : IIterator
      {
         return new LinkedListIterator(this);
      }
      
      public function addFirst(item:*) : void
      {
         addNodeFirst(new LinkedNode(item));
      }
      
      public function addLast(item:*) : void
      {
         addNodeLast(new LinkedNode(item));
      }
      
      public function add(item:*) : void
      {
         addNodeLast(new LinkedNode(item));
      }
      
      as3commons_collections function addNodeBefore_internal(next:LinkedNode, node:LinkedNode) : void
      {
         addNodeBefore(next,node);
      }
      
      as3commons_collections function removeNode_internal(node:LinkedNode) : void
      {
         removeNode(node);
      }
   }
}

