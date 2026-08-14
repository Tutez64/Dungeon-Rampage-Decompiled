package org.as3commons.collections
{
   import org.as3commons.collections.framework.IComparator;
   import org.as3commons.collections.framework.IIterator;
   import org.as3commons.collections.framework.IOrderedList;
   import org.as3commons.collections.framework.core.AbstractList;
   import org.as3commons.collections.framework.core.ArrayListIterator;
   import org.as3commons.collections.utils.ArrayUtils;
   
   public class ArrayList extends AbstractList implements IOrderedList
   {
      
      public function ArrayList()
      {
         super();
      }
      
      public function reverse() : Boolean
      {
         if(_array.length < 2)
         {
            return false;
         }
         _array.reverse();
         return true;
      }
      
      public function sort(comparator:IComparator) : Boolean
      {
         if(_array.length < 2)
         {
            return false;
         }
         ArrayUtils.mergeSort(_array,comparator);
         return true;
      }
      
      public function addAllAt(index:uint, items:Array) : Boolean
      {
         if(index <= _array.length)
         {
            _array = _array.slice(0,index).concat(items).concat(_array.slice(index));
            return true;
         }
         return false;
      }
      
      public function replaceAt(index:uint, item:*) : Boolean
      {
         if(index < _array.length)
         {
            if(_array[index] === item)
            {
               return false;
            }
            _array[index] = item;
            return true;
         }
         return false;
      }
      
      public function addFirst(item:*) : void
      {
         _array.unshift(item);
      }
      
      public function addAt(index:uint, item:*) : Boolean
      {
         if(index <= _array.length)
         {
            _array.splice(index,0,item);
            return true;
         }
         return false;
      }
      
      override public function iterator(cursor:* = undefined) : IIterator
      {
         var _loc2_:uint = cursor is uint ? uint(cursor) : 0;
         return new ArrayListIterator(this,_loc2_);
      }
      
      public function addLast(item:*) : void
      {
         _array.push(item);
      }
   }
}

