package org.as3commons.collections.framework.core
{
   import org.as3commons.collections.framework.ICollectionIterator;
   
   use namespace as3commons_collections;
   
   public class AbstractSortedCollectionIterator implements ICollectionIterator
   {
      
      protected var _next:SortedNode;
      
      protected var _current:SortedNode;
      
      protected var _collection:AbstractSortedCollection;
      
      public function AbstractSortedCollectionIterator(collection:AbstractSortedCollection, next:SortedNode = null)
      {
         super();
         this._collection = collection;
         if(next)
         {
            this._next = next;
         }
         else if(collection.size)
         {
            this._next = this._collection.mostLeftNode_internal();
         }
      }
      
      public function start() : void
      {
         this._next = this._collection.size ? this._collection.mostLeftNode_internal() : null;
         this._current = null;
      }
      
      public function remove() : Boolean
      {
         if(!this._current)
         {
            return false;
         }
         this._next = this._collection.nextNode_internal(this._current);
         this._collection.removeNode_internal(this._current);
         this._current = null;
         return true;
      }
      
      public function hasNext() : Boolean
      {
         return this._next != null;
      }
      
      public function hasPrevious() : Boolean
      {
         return this._next != this._collection.mostLeftNode_internal() && Boolean(this._collection.size);
      }
      
      public function next() : *
      {
         if(!this._next)
         {
            this._current = null;
            return undefined;
         }
         this._current = this._next;
         this._next = this._collection.nextNode_internal(this._next);
         return this._current.item;
      }
      
      public function previous() : *
      {
         if(this._next == this._collection.mostLeftNode_internal() || !this._collection.size)
         {
            this._current = null;
            return undefined;
         }
         this._next = this._next == null ? this._collection.mostRightNode_internal() : this._collection.previousNode_internal(this._next);
         this._current = this._next;
         return this._current.item;
      }
      
      public function get current() : *
      {
         if(!this._current)
         {
            return undefined;
         }
         return this._current.item;
      }
      
      public function end() : void
      {
         this._next = this._current = null;
      }
   }
}

