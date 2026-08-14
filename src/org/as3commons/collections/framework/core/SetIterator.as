package org.as3commons.collections.framework.core
{
   import org.as3commons.collections.Set;
   import org.as3commons.collections.framework.ISetIterator;
   import org.as3commons.collections.iterators.ArrayIterator;
   
   public class SetIterator extends ArrayIterator implements ISetIterator
   {
      
      protected var _set:Set;
      
      public function SetIterator(theSet:Set)
      {
         this._set = theSet;
         super(this._set.toArray());
      }
      
      public function get nextItem() : *
      {
         return _array[_next];
      }
      
      public function get previousItem() : *
      {
         return _array[previousIndex];
      }
      
      override protected function removeCurrent() : void
      {
         this._set.remove(super.current);
         super.removeCurrent();
      }
   }
}

