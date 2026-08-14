package org.as3commons.collections.framework.core
{
   import org.as3commons.collections.framework.IComparator;
   import org.as3commons.collections.framework.IInsertionOrder;
   import org.as3commons.collections.framework.IIterator;
   
   use namespace as3commons_collections;
   
   public class AbstractLinkedCollection implements IInsertionOrder
   {
      
      protected var _size:uint = 0;
      
      protected var _first:LinkedNode;
      
      protected var _last:LinkedNode;
      
      public function AbstractLinkedCollection()
      {
         super();
      }
      
      public function get size() : uint
      {
         return this._size;
      }
      
      public function reverse() : Boolean
      {
         var _loc2_:LinkedNode = null;
         var _loc3_:LinkedNode = null;
         if(this._size < 2)
         {
            return false;
         }
         var _loc1_:LinkedNode = this._last;
         while(_loc1_)
         {
            _loc2_ = _loc1_.left;
            if(!_loc1_.right)
            {
               _loc1_.right = _loc1_.left;
               _loc1_.left = null;
               this._first = _loc1_;
            }
            else if(!_loc1_.left)
            {
               _loc1_.left = _loc1_.right;
               _loc1_.right = null;
               this._last = _loc1_;
            }
            else
            {
               _loc3_ = _loc1_.right;
               _loc1_.right = _loc1_.left;
               _loc1_.left = _loc3_;
            }
            _loc1_ = _loc2_;
         }
         return true;
      }
      
      protected function mergeSort(comparator:IComparator) : void
      {
         var _loc3_:LinkedNode = null;
         var _loc4_:LinkedNode = null;
         var _loc5_:LinkedNode = null;
         var _loc6_:LinkedNode = null;
         var _loc8_:* = 0;
         var _loc9_:* = 0;
         var _loc10_:* = 0;
         var _loc11_:* = 0;
         var _loc2_:LinkedNode = this._first;
         var _loc7_:int = 1;
         while(true)
         {
            _loc3_ = _loc2_;
            _loc2_ = _loc6_ = null;
            _loc8_ = 0;
            while(_loc3_)
            {
               _loc8_++;
               _loc11_ = 0;
               _loc9_ = 0;
               _loc4_ = _loc3_;
               while(_loc11_ < _loc7_)
               {
                  _loc9_++;
                  _loc4_ = _loc4_.right;
                  if(!_loc4_)
                  {
                     break;
                  }
                  _loc11_++;
               }
               _loc10_ = _loc7_;
               while(_loc9_ > 0 || Boolean(_loc10_ > 0) && Boolean(_loc4_))
               {
                  if(_loc9_ == 0)
                  {
                     _loc5_ = _loc4_;
                     _loc4_ = _loc4_.right;
                     _loc10_--;
                  }
                  else if(_loc10_ == 0 || !_loc4_)
                  {
                     _loc5_ = _loc3_;
                     _loc3_ = _loc3_.right;
                     _loc9_--;
                  }
                  else if(comparator.compare(_loc3_.item,_loc4_.item) <= 0)
                  {
                     _loc5_ = _loc3_;
                     _loc3_ = _loc3_.right;
                     _loc9_--;
                  }
                  else
                  {
                     _loc5_ = _loc4_;
                     _loc4_ = _loc4_.right;
                     _loc10_--;
                  }
                  if(_loc6_)
                  {
                     _loc6_.right = _loc5_;
                  }
                  else
                  {
                     _loc2_ = _loc5_;
                  }
                  _loc5_.left = _loc6_;
                  _loc6_ = _loc5_;
               }
               _loc3_ = _loc4_;
            }
            this._first.left = _loc6_;
            _loc6_.right = null;
            if(_loc8_ <= 1)
            {
               break;
            }
            _loc7_ <<= 1;
         }
         this._first = _loc2_;
         this._last = _loc6_;
      }
      
      as3commons_collections function get firstNode_internal() : LinkedNode
      {
         return this._first;
      }
      
      public function remove(item:*) : Boolean
      {
         var _loc2_:LinkedNode = this.firstNodeOf(item);
         if(!_loc2_)
         {
            return false;
         }
         this.removeNode(_loc2_);
         return true;
      }
      
      public function removeFirst() : *
      {
         if(!this._size)
         {
            return undefined;
         }
         var _loc1_:* = this._first.item;
         this._first = this._first.right;
         if(this._first)
         {
            this._first.left = null;
         }
         else
         {
            this._last = null;
         }
         --this._size;
         return _loc1_;
      }
      
      public function clear() : Boolean
      {
         if(!this._size)
         {
            return false;
         }
         this._first = this._last = null;
         this._size = 0;
         return true;
      }
      
      protected function addNodeBefore(next:LinkedNode, node:LinkedNode) : void
      {
         if(!next)
         {
            this.addNodeLast(node);
            return;
         }
         if(!next.left)
         {
            this._first = node;
         }
         node.left = next.left;
         node.right = next;
         if(next.left)
         {
            next.left.right = node;
         }
         next.left = node;
         ++this._size;
      }
      
      protected function firstNodeOf(item:*) : LinkedNode
      {
         var _loc2_:LinkedNode = this._first;
         while(_loc2_)
         {
            if(item === _loc2_.item)
            {
               return _loc2_;
            }
            _loc2_ = _loc2_.right;
         }
         return null;
      }
      
      public function get last() : *
      {
         if(this._last)
         {
            return this._last.item;
         }
         return undefined;
      }
      
      protected function addNodeAfter(previous:LinkedNode, node:LinkedNode) : void
      {
         if(!previous)
         {
            this.addNodeFirst(node);
            return;
         }
         if(!previous.right)
         {
            this._last = node;
         }
         node.left = previous;
         node.right = previous.right;
         if(previous.right)
         {
            previous.right.left = node;
         }
         previous.right = node;
         ++this._size;
      }
      
      public function sort(comparator:IComparator) : Boolean
      {
         if(this._size < 2)
         {
            return false;
         }
         this.mergeSort(comparator);
         return true;
      }
      
      public function has(item:*) : Boolean
      {
         return this.firstNodeOf(item) != null;
      }
      
      as3commons_collections function get lastNode_internal() : LinkedNode
      {
         return this._last;
      }
      
      protected function removeNode(node:LinkedNode) : void
      {
         if(node.left)
         {
            node.left.right = node.right;
         }
         else
         {
            this._first = node.right;
         }
         if(node.right)
         {
            node.right.left = node.left;
         }
         else
         {
            this._last = node.left;
         }
         --this._size;
      }
      
      public function toArray() : Array
      {
         var _loc1_:LinkedNode = this._first;
         var _loc2_:Array = new Array();
         while(_loc1_)
         {
            _loc2_.push(_loc1_.item);
            _loc1_ = _loc1_.right;
         }
         return _loc2_;
      }
      
      public function iterator(cursor:* = undefined) : IIterator
      {
         return null;
      }
      
      public function get first() : *
      {
         if(this._first)
         {
            return this._first.item;
         }
         return undefined;
      }
      
      protected function addNodeFirst(node:LinkedNode) : void
      {
         if(!this._first)
         {
            this._first = this._last = node;
            this._size = 1;
            return;
         }
         this._first.left = node;
         node.right = this._first;
         this._first = node;
         ++this._size;
      }
      
      protected function addNodeLast(node:LinkedNode) : void
      {
         if(!this._first)
         {
            this._first = this._last = node;
            this._size = 1;
            return;
         }
         this._last.right = node;
         node.left = this._last;
         this._last = node;
         ++this._size;
      }
      
      public function removeLast() : *
      {
         if(!this._size)
         {
            return undefined;
         }
         var _loc1_:* = this._last.item;
         this._last = this._last.left;
         if(this._last)
         {
            this._last.right = null;
         }
         else
         {
            this._first = null;
         }
         --this._size;
         return _loc1_;
      }
   }
}

