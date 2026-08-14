package org.as3commons.collections.framework.core
{
   import org.as3commons.collections.framework.IComparator;
   import org.as3commons.collections.framework.IIterator;
   import org.as3commons.collections.framework.ISortOrder;
   
   use namespace as3commons_collections;
   
   public class AbstractSortedCollection implements ISortOrder
   {
      
      protected var _root:SortedNode;
      
      protected var _size:uint = 0;
      
      protected var _comparator:IComparator;
      
      public function AbstractSortedCollection(comparator:IComparator)
      {
         super();
         this._comparator = comparator;
      }
      
      protected function addNode(newNode:SortedNode) : void
      {
         var _loc3_:int = 0;
         if(!this._root)
         {
            this._comparator.compare(newNode.item,newNode.item);
            this._root = newNode;
            ++this._size;
            return;
         }
         var _loc2_:SortedNode = this._root;
         while(_loc2_)
         {
            _loc3_ = this._comparator.compare(newNode.item,_loc2_.item);
            if(!_loc3_)
            {
               _loc3_ = newNode.order < _loc2_.order ? -1 : 1;
            }
            if(_loc3_ == -1)
            {
               if(!_loc2_.left)
               {
                  newNode.parent = _loc2_;
                  _loc2_.left = newNode;
                  _loc2_ = _loc2_.left;
                  break;
               }
               _loc2_ = _loc2_.left;
            }
            else
            {
               if(_loc3_ != 1)
               {
                  return;
               }
               if(!_loc2_.right)
               {
                  newNode.parent = _loc2_;
                  _loc2_.right = newNode;
                  _loc2_ = _loc2_.right;
                  break;
               }
               _loc2_ = _loc2_.right;
            }
         }
         while(_loc2_.parent)
         {
            if(_loc2_.parent.priority >= _loc2_.priority)
            {
               break;
            }
            this.rotate(_loc2_.parent,_loc2_);
         }
         ++this._size;
      }
      
      public function remove(item:*) : Boolean
      {
         var _loc2_:SortedNode = this.firstEqualNode(item);
         if(!_loc2_)
         {
            return false;
         }
         if(_loc2_.item === item)
         {
            this.removeNode(_loc2_);
            return true;
         }
         _loc2_ = this.nextNode_internal(_loc2_);
         while(_loc2_)
         {
            if(this._comparator.compare(item,_loc2_.item))
            {
               break;
            }
            if(_loc2_.item === item)
            {
               this.removeNode(_loc2_);
               return true;
            }
            _loc2_ = this.nextNode_internal(_loc2_);
         }
         return false;
      }
      
      protected function firstEqualNode(item:*) : SortedNode
      {
         var _loc3_:SortedNode = null;
         var _loc4_:int = 0;
         var _loc2_:SortedNode = this._root;
         while(_loc2_)
         {
            _loc4_ = this._comparator.compare(item,_loc2_.item);
            if(_loc4_ == -1)
            {
               if(_loc3_)
               {
                  return _loc3_;
               }
               _loc2_ = _loc2_.left;
            }
            else if(_loc4_ == 1)
            {
               _loc2_ = _loc2_.right;
            }
            else
            {
               _loc3_ = _loc2_;
               _loc2_ = _loc2_.left;
            }
         }
         return _loc3_;
      }
      
      public function get size() : uint
      {
         return this._size;
      }
      
      public function removeLast() : *
      {
         var _loc1_:SortedNode = this.mostRightNode_internal();
         if(!_loc1_)
         {
            return undefined;
         }
         this.removeNode(_loc1_);
         return _loc1_.item;
      }
      
      public function removeFirst() : *
      {
         var _loc1_:SortedNode = this.mostLeftNode_internal();
         if(!_loc1_)
         {
            return undefined;
         }
         this.removeNode(_loc1_);
         return _loc1_.item;
      }
      
      public function clear() : Boolean
      {
         if(!this._size)
         {
            return false;
         }
         this._root = null;
         this._size = 0;
         return true;
      }
      
      public function hasEqual(item:*) : Boolean
      {
         var _loc3_:int = 0;
         var _loc2_:SortedNode = this._root;
         while(_loc2_)
         {
            _loc3_ = this._comparator.compare(item,_loc2_.item);
            if(_loc3_ == -1)
            {
               _loc2_ = _loc2_.left;
            }
            else
            {
               if(_loc3_ != 1)
               {
                  return true;
               }
               _loc2_ = _loc2_.right;
            }
         }
         return false;
      }
      
      public function get last() : *
      {
         if(!this._root)
         {
            return undefined;
         }
         return this.mostRightNode_internal().item;
      }
      
      as3commons_collections function mostLeftNode_internal(node:SortedNode = null) : SortedNode
      {
         if(!this._root)
         {
            return null;
         }
         if(!node)
         {
            node = this._root;
         }
         while(node.left)
         {
            node = node.left;
         }
         return node;
      }
      
      as3commons_collections function mostRightNode_internal(node:SortedNode = null) : SortedNode
      {
         if(!this._root)
         {
            return null;
         }
         if(!node)
         {
            node = this._root;
         }
         while(node.right)
         {
            node = node.right;
         }
         return node;
      }
      
      protected function rotate(parent:SortedNode, child:SortedNode) : void
      {
         var _loc3_:SortedNode = parent.parent;
         var _loc4_:String = "right";
         var _loc5_:String = "left";
         if(child == parent.left)
         {
            _loc4_ = "left";
            _loc5_ = "right";
         }
         parent[_loc4_] = child[_loc5_];
         if(child[_loc5_])
         {
            SortedNode(child[_loc5_]).parent = parent;
         }
         parent.parent = child;
         child[_loc5_] = parent;
         child.parent = _loc3_;
         if(_loc3_)
         {
            if(_loc3_[_loc5_] == parent)
            {
               _loc3_[_loc5_] = child;
            }
            else
            {
               _loc3_[_loc4_] = child;
            }
         }
         else
         {
            this._root = child;
         }
      }
      
      public function has(item:*) : Boolean
      {
         var _loc2_:SortedNode = this.firstEqualNode(item);
         if(!_loc2_)
         {
            return false;
         }
         if(_loc2_.item === item)
         {
            return true;
         }
         _loc2_ = this.nextNode_internal(_loc2_);
         while(_loc2_)
         {
            if(this._comparator.compare(item,_loc2_.item))
            {
               break;
            }
            if(_loc2_.item === item)
            {
               return true;
            }
            _loc2_ = this.nextNode_internal(_loc2_);
         }
         return false;
      }
      
      as3commons_collections function previousNode_internal(node:SortedNode) : SortedNode
      {
         var _loc2_:SortedNode = null;
         if(node.left)
         {
            node = this.mostRightNode_internal(node.left);
         }
         else
         {
            _loc2_ = node.parent;
            while(Boolean(_loc2_) && node == _loc2_.left)
            {
               node = _loc2_;
               _loc2_ = _loc2_.parent;
            }
            node = _loc2_;
         }
         return node;
      }
      
      public function toArray() : Array
      {
         var _loc1_:Array = new Array();
         var _loc2_:SortedNode = this.mostLeftNode_internal();
         while(_loc2_)
         {
            _loc1_.push(_loc2_.item);
            _loc2_ = this.nextNode_internal(_loc2_);
         }
         return _loc1_;
      }
      
      protected function removeNode(node:SortedNode) : void
      {
         var _loc2_:SortedNode = null;
         while(Boolean(node.left) || Boolean(node.right))
         {
            if(Boolean(node.left) && Boolean(node.right))
            {
               _loc2_ = node.left.priority < node.right.priority ? node.left : node.right;
            }
            else if(node.left)
            {
               _loc2_ = node.left;
            }
            else
            {
               if(!node.right)
               {
                  break;
               }
               _loc2_ = node.right;
            }
            this.rotate(node,_loc2_);
         }
         if(node.parent)
         {
            if(node.parent.left == node)
            {
               node.parent.left = null;
            }
            else
            {
               node.parent.right = null;
            }
            node.parent = null;
         }
         else
         {
            this._root = null;
         }
         --this._size;
      }
      
      as3commons_collections function nextNode_internal(node:SortedNode) : SortedNode
      {
         var _loc2_:SortedNode = null;
         if(node.right)
         {
            node = this.mostLeftNode_internal(node.right);
         }
         else
         {
            _loc2_ = node.parent;
            while(Boolean(_loc2_) && node == _loc2_.right)
            {
               node = _loc2_;
               _loc2_ = _loc2_.parent;
            }
            node = _loc2_;
         }
         return node;
      }
      
      protected function lesserNode(item:*) : SortedNode
      {
         var _loc3_:SortedNode = null;
         var _loc4_:int = 0;
         var _loc2_:SortedNode = this._root;
         while(_loc2_)
         {
            _loc4_ = this._comparator.compare(item,_loc2_.item);
            if(_loc4_ == -1)
            {
               _loc2_ = _loc2_.left;
            }
            else if(_loc4_ == 1)
            {
               _loc3_ = _loc2_;
               _loc2_ = _loc2_.right;
            }
            else
            {
               _loc2_ = _loc2_.left;
            }
         }
         return _loc3_;
      }
      
      public function iterator(cursor:* = undefined) : IIterator
      {
         return null;
      }
      
      protected function higherNode(item:*) : SortedNode
      {
         var _loc3_:SortedNode = null;
         var _loc4_:int = 0;
         var _loc2_:SortedNode = this._root;
         while(_loc2_)
         {
            _loc4_ = this._comparator.compare(item,_loc2_.item);
            if(_loc4_ == -1)
            {
               _loc3_ = _loc2_;
               _loc2_ = _loc2_.left;
            }
            else if(_loc4_ == 1)
            {
               _loc2_ = _loc2_.right;
            }
            else
            {
               _loc2_ = _loc2_.right;
            }
         }
         return _loc3_;
      }
      
      as3commons_collections function removeNode_internal(node:SortedNode) : void
      {
         this.removeNode(node);
      }
      
      public function get first() : *
      {
         if(!this._root)
         {
            return undefined;
         }
         return this.mostLeftNode_internal().item;
      }
   }
}

