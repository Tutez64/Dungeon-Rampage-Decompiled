package org.as3commons.collections.framework.core
{
   import org.as3commons.collections.framework.IListIterator;
   import org.as3commons.collections.iterators.ArrayIterator;
   
   use namespace as3commons_collections;
   
   public class AbstractListIterator extends ArrayIterator implements IListIterator
   {
      
      protected var _list:AbstractList;
      
      public function AbstractListIterator(list:AbstractList, index:uint = 0)
      {
         this._list = list;
         super(this._list.array_internal,index);
      }
      
      override protected function removeCurrent() : void
      {
         this._list.removeAt(_current);
      }
   }
}

