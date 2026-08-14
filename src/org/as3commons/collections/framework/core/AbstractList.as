package org.as3commons.collections.framework.core
{
   import org.as3commons.collections.framework.IDataProvider;
   import org.as3commons.collections.framework.IIterator;
   import org.as3commons.collections.framework.IList;
   
   use namespace as3commons_collections;
   
   public class AbstractList implements IList, IDataProvider
   {
      
      protected var _array:Array;
      
      public function AbstractList()
      {
         super();
         this._array = new Array();
      }
      
      public function firstIndexOf(item:*) : int
      {
         return this._array.indexOf(item);
      }
      
      public function set array(array:Array) : void
      {
         this._array = array.concat();
      }
      
      public function get size() : uint
      {
         return this._array.length;
      }
      
      public function removeLast() : *
      {
         return this._array.pop();
      }
      
      public function remove(item:*) : Boolean
      {
         var _loc2_:int = this._array.indexOf(item);
         if(_loc2_ == -1)
         {
            return false;
         }
         this._array.splice(_loc2_,1);
         this.itemRemoved(_loc2_,item);
         return true;
      }
      
      public function removeFirst() : *
      {
         return this._array.shift();
      }
      
      public function clear() : Boolean
      {
         if(!this._array.length)
         {
            return false;
         }
         this._array = new Array();
         return true;
      }
      
      public function removeAllAt(index:uint, numItems:uint) : Array
      {
         return this._array.splice(index,numItems);
      }
      
      protected function itemRemoved(index:uint, item:*) : void
      {
      }
      
      public function removeAt(index:uint) : *
      {
         return this._array.splice(index,1)[0];
      }
      
      public function get last() : *
      {
         return this._array[this._array.length - 1];
      }
      
      public function count(item:*) : uint
      {
         var _loc2_:uint = 0;
         var _loc3_:uint = this._array.length;
         var _loc4_:* = 0;
         while(_loc4_ < _loc3_)
         {
            if(this._array[_loc4_] === item)
            {
               _loc2_++;
            }
            _loc4_++;
         }
         return _loc2_;
      }
      
      public function add(item:*) : uint
      {
         this._array.push(item);
         return this._array.length - 1;
      }
      
      public function lastIndexOf(item:*) : int
      {
         var _loc2_:* = int(this._array.length - 1);
         while(_loc2_ >= 0)
         {
            if(item === this._array[_loc2_])
            {
               return _loc2_;
            }
            _loc2_--;
         }
         return -1;
      }
      
      public function toArray() : Array
      {
         return this._array.concat();
      }
      
      public function itemAt(index:uint) : *
      {
         return this._array[index];
      }
      
      public function has(item:*) : Boolean
      {
         return this.firstIndexOf(item) > -1;
      }
      
      as3commons_collections function get array_internal() : Array
      {
         return this._array;
      }
      
      public function iterator(cursor:* = undefined) : IIterator
      {
         var _loc2_:uint = cursor is uint ? uint(cursor) : 0;
         return new AbstractListIterator(this,_loc2_);
      }
      
      public function get first() : *
      {
         return this._array[0];
      }
      
      public function removeAll(item:*) : uint
      {
         var _loc2_:uint = this._array.length;
         var _loc3_:* = 0;
         while(_loc3_ < _loc2_)
         {
            if(this._array[_loc3_] === item)
            {
               this._array.splice(_loc3_,1);
               this.itemRemoved(_loc3_,item);
               _loc3_--;
            }
            _loc3_++;
         }
         return _loc2_ - this._array.length;
      }
   }
}

