package org.as3commons.collections
{
   import flash.utils.Dictionary;
   import org.as3commons.collections.framework.IIterator;
   import org.as3commons.collections.framework.IMap;
   import org.as3commons.collections.framework.core.MapIterator;
   import org.as3commons.collections.iterators.ArrayIterator;
   
   public class Map implements IMap
   {
      
      protected var _items:Dictionary;
      
      protected var _stringMap:Object;
      
      protected var _keys:Dictionary;
      
      protected var _size:uint = 0;
      
      public function Map()
      {
         super();
         this._items = new Dictionary();
         this._keys = new Dictionary();
         this._stringMap = new Object();
      }
      
      public function removeAll(item:*) : uint
      {
         var _loc3_:String = null;
         var _loc4_:* = undefined;
         var _loc2_:uint = 0;
         for(_loc3_ in this._stringMap)
         {
            if(this._stringMap[_loc3_] === item)
            {
               delete this._stringMap[_loc3_];
               --this._size;
               this.itemRemoved(_loc3_,item);
               _loc2_++;
            }
         }
         for(_loc4_ in this._items)
         {
            if(this._items[_loc4_] === item)
            {
               delete this._keys[_loc4_];
               delete this._items[_loc4_];
               --this._size;
               this.itemRemoved(_loc3_,item);
               _loc2_++;
            }
         }
         return _loc2_;
      }
      
      public function get size() : uint
      {
         return this._size;
      }
      
      public function keysToArray() : Array
      {
         var _loc2_:String = null;
         var _loc3_:* = undefined;
         var _loc1_:Array = new Array();
         for(_loc2_ in this._stringMap)
         {
            _loc1_.push(_loc2_);
         }
         for each(_loc3_ in this._keys)
         {
            _loc1_.push(_loc3_);
         }
         return _loc1_;
      }
      
      public function clear() : Boolean
      {
         if(!this._size)
         {
            return false;
         }
         this._keys = new Dictionary();
         this._items = new Dictionary();
         this._stringMap = new Object();
         this._size = 0;
         return true;
      }
      
      public function count(item:*) : uint
      {
         var _loc3_:* = undefined;
         var _loc2_:uint = 0;
         for each(_loc3_ in this._stringMap)
         {
            if(_loc3_ === item)
            {
               _loc2_++;
            }
         }
         for each(_loc3_ in this._items)
         {
            if(_loc3_ === item)
            {
               _loc2_++;
            }
         }
         return _loc2_;
      }
      
      public function has(item:*) : Boolean
      {
         var _loc2_:* = undefined;
         for each(_loc2_ in this._stringMap)
         {
            if(_loc2_ === item)
            {
               return true;
            }
         }
         for each(_loc2_ in this._items)
         {
            if(_loc2_ === item)
            {
               return true;
            }
         }
         return false;
      }
      
      public function remove(item:*) : Boolean
      {
         var _loc2_:String = null;
         var _loc3_:* = undefined;
         for(_loc2_ in this._stringMap)
         {
            if(this._stringMap[_loc2_] === item)
            {
               delete this._stringMap[_loc2_];
               --this._size;
               this.itemRemoved(_loc2_,item);
               return true;
            }
         }
         for(_loc3_ in this._items)
         {
            if(this._items[_loc3_] === item)
            {
               delete this._keys[_loc3_];
               delete this._items[_loc3_];
               --this._size;
               this.itemRemoved(_loc2_,item);
               return true;
            }
         }
         return false;
      }
      
      public function toArray() : Array
      {
         var _loc2_:* = undefined;
         var _loc1_:Array = new Array();
         for each(_loc2_ in this._stringMap)
         {
            _loc1_.push(_loc2_);
         }
         for each(_loc2_ in this._items)
         {
            _loc1_.push(_loc2_);
         }
         return _loc1_;
      }
      
      public function add(key:*, item:*) : Boolean
      {
         if(key is String)
         {
            if(this._stringMap[key] !== undefined)
            {
               return false;
            }
            this._stringMap[key] = item;
         }
         else
         {
            if(this._keys[key] !== undefined)
            {
               return false;
            }
            this._keys[key] = key;
            this._items[key] = item;
         }
         ++this._size;
         return true;
      }
      
      public function hasKey(key:*) : Boolean
      {
         return key is String ? this._stringMap[key] !== undefined : this._keys[key] !== undefined;
      }
      
      public function iterator(cursor:* = undefined) : IIterator
      {
         return new MapIterator(this);
      }
      
      protected function itemRemoved(key:*, item:*) : void
      {
      }
      
      public function keyIterator() : IIterator
      {
         return new ArrayIterator(this.keysToArray());
      }
      
      public function replaceFor(key:*, item:*) : Boolean
      {
         if(key is String)
         {
            if(this._stringMap[key] === undefined)
            {
               return false;
            }
            if(this._stringMap[key] === item)
            {
               return false;
            }
            this._stringMap[key] = item;
         }
         else
         {
            if(this._keys[key] === undefined)
            {
               return false;
            }
            if(this._items[key] === item)
            {
               return false;
            }
            this._items[key] = item;
         }
         return true;
      }
      
      public function removeKey(key:*) : *
      {
         var _loc2_:* = undefined;
         if(key is String)
         {
            if(this._stringMap[key] === undefined)
            {
               return undefined;
            }
            _loc2_ = this._stringMap[key];
            delete this._stringMap[key];
         }
         else
         {
            if(this._keys[key] === undefined)
            {
               return undefined;
            }
            _loc2_ = this._items[key];
            delete this._keys[key];
            delete this._items[key];
         }
         --this._size;
         return _loc2_;
      }
      
      public function itemFor(key:*) : *
      {
         if(key is String)
         {
            return this._stringMap[key];
         }
         return this._items[key];
      }
   }
}

