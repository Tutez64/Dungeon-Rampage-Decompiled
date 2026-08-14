package org.as3commons.collections
{
   import flash.utils.Dictionary;
   import org.as3commons.collections.framework.IComparator;
   import org.as3commons.collections.framework.IIterator;
   import org.as3commons.collections.framework.ISortedMap;
   import org.as3commons.collections.framework.core.AbstractSortedDuplicatesCollection;
   import org.as3commons.collections.framework.core.SortedMapIterator;
   import org.as3commons.collections.framework.core.SortedMapNode;
   import org.as3commons.collections.framework.core.SortedNode;
   import org.as3commons.collections.framework.core.as3commons_collections;
   
   use namespace as3commons_collections;
   
   public class SortedMap extends AbstractSortedDuplicatesCollection implements ISortedMap
   {
      
      protected var _items:Dictionary;
      
      protected var _stringMap:Object;
      
      protected var _keys:Dictionary;
      
      public function SortedMap(comparator:IComparator)
      {
         super(comparator);
         this._items = new Dictionary();
         this._keys = new Dictionary();
         this._stringMap = new Object();
      }
      
      override protected function addNode(node:SortedNode) : void
      {
         super.addNode(node);
         var _loc2_:* = SortedMapNode(node).key;
         if(_loc2_ is String)
         {
            this._stringMap[_loc2_] = node;
         }
         else
         {
            this._keys[_loc2_] = _loc2_;
            this._items[_loc2_] = node;
         }
      }
      
      public function equalKeys(item:*) : Array
      {
         var _loc2_:Array = new Array();
         var _loc3_:SortedNode = firstEqualNode(item);
         if(!_loc3_)
         {
            return _loc2_;
         }
         while(_loc3_)
         {
            if(_comparator.compare(item,_loc3_.item))
            {
               break;
            }
            _loc2_.push(SortedMapNode(_loc3_).key);
            _loc3_ = nextNode_internal(_loc3_);
         }
         return _loc2_;
      }
      
      public function keysToArray() : Array
      {
         var _loc1_:SortedNode = mostLeftNode_internal();
         var _loc2_:Array = new Array();
         while(_loc1_)
         {
            _loc2_.push(SortedMapNode(_loc1_).key);
            _loc1_ = nextNode_internal(_loc1_);
         }
         return _loc2_;
      }
      
      override public function clear() : Boolean
      {
         if(!_size)
         {
            return false;
         }
         this._keys = new Dictionary();
         this._items = new Dictionary();
         this._stringMap = new Object();
         super.clear();
         return true;
      }
      
      public function higherKey(item:*) : *
      {
         var _loc2_:SortedMapNode = higherNode(item) as SortedMapNode;
         if(!_loc2_)
         {
            return undefined;
         }
         return _loc2_.key;
      }
      
      public function add(key:*, item:*) : Boolean
      {
         if(key is String)
         {
            if(this._stringMap[key] !== undefined)
            {
               return false;
            }
         }
         else if(this._keys[key] !== undefined)
         {
            return false;
         }
         this.addNode(new SortedMapNode(key,item));
         return true;
      }
      
      public function hasKey(key:*) : Boolean
      {
         return key is String ? this._stringMap[key] !== undefined : this._keys[key] !== undefined;
      }
      
      public function keyIterator() : IIterator
      {
         return new KeyIterator(this);
      }
      
      override public function iterator(cursor:* = undefined) : IIterator
      {
         var _loc2_:SortedMapNode = null;
         if(cursor is String)
         {
            _loc2_ = this._stringMap[cursor];
         }
         else
         {
            _loc2_ = this._items[cursor];
         }
         return new SortedMapIterator(this,_loc2_);
      }
      
      public function replaceFor(key:*, item:*) : Boolean
      {
         var _loc3_:SortedMapNode = null;
         if(key is String)
         {
            _loc3_ = this._stringMap[key];
         }
         else
         {
            _loc3_ = this._items[key];
         }
         if(Boolean(_loc3_) && _loc3_.item !== item)
         {
            this.removeNode(_loc3_);
            _loc3_.item = item;
            this.addNode(_loc3_);
            return true;
         }
         return false;
      }
      
      public function itemFor(key:*) : *
      {
         var _loc2_:SortedMapNode = null;
         if(key is String)
         {
            _loc2_ = this._stringMap[key];
         }
         else
         {
            _loc2_ = this._items[key];
         }
         return _loc2_ ? _loc2_.item : undefined;
      }
      
      protected function getNode(key:*) : SortedMapNode
      {
         if(key is String)
         {
            return this._stringMap[key];
         }
         return this._items[key];
      }
      
      public function lesserKey(item:*) : *
      {
         var _loc2_:SortedMapNode = lesserNode(item) as SortedMapNode;
         if(!_loc2_)
         {
            return undefined;
         }
         return _loc2_.key;
      }
      
      public function removeKey(key:*) : *
      {
         var _loc2_:SortedMapNode = null;
         if(key is String)
         {
            if(this._stringMap[key] === undefined)
            {
               return undefined;
            }
            _loc2_ = this._stringMap[key];
         }
         else
         {
            if(this._keys[key] === undefined)
            {
               return undefined;
            }
            _loc2_ = this._items[key];
         }
         this.removeNode(_loc2_);
         return _loc2_.item;
      }
      
      override protected function removeNode(node:SortedNode) : void
      {
         super.removeNode(node);
         var _loc2_:* = SortedMapNode(node).key;
         if(_loc2_ is String)
         {
            delete this._stringMap[_loc2_];
         }
         else
         {
            delete this._keys[_loc2_];
            delete this._items[_loc2_];
         }
      }
   }
}

import org.as3commons.collections.SortedMap;
import org.as3commons.collections.framework.IIterator;
import org.as3commons.collections.framework.core.SortedMapNode;
import org.as3commons.collections.framework.core.SortedNode;
import org.as3commons.collections.framework.core.as3commons_collections;

use namespace as3commons_collections;

class KeyIterator implements IIterator
{
   
   private var _next:SortedNode;
   
   private var _map:SortedMap;
   
   public function KeyIterator(map:SortedMap)
   {
      super();
      this._map = map;
      this._next = map.mostLeftNode_internal();
   }
   
   public function next() : *
   {
      if(!this._next)
      {
         return undefined;
      }
      var _loc1_:SortedNode = this._next;
      this._next = this._map.as3commons_collections::nextNode_internal(this._next);
      return SortedMapNode(_loc1_).key;
   }
   
   public function hasNext() : Boolean
   {
      return this._next != null;
   }
}
