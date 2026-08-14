package org.as3commons.collections.framework.core
{
   import org.as3commons.collections.ArrayList;
   import org.as3commons.collections.framework.IOrderedList;
   import org.as3commons.collections.framework.IOrderedListIterator;
   
   public class ArrayListIterator extends AbstractListIterator implements IOrderedListIterator
   {
      
      public function ArrayListIterator(list:ArrayList, index:uint = 0)
      {
         super(list,index);
      }
      
      public function addBefore(item:*) : uint
      {
         var _loc2_:uint = 0;
         _current = -1;
         if(_next == -1)
         {
            _loc2_ = uint(this._arrayList.size);
         }
         else
         {
            _loc2_ = uint(_next);
            ++_next;
         }
         this._arrayList.addAt(_loc2_,item);
         return _loc2_;
      }
      
      public function replace(item:*) : Boolean
      {
         if(_current == -1)
         {
            return false;
         }
         return this._arrayList.replaceAt(_current,item);
      }
      
      private function get _arrayList() : IOrderedList
      {
         return _list as IOrderedList;
      }
      
      public function addAfter(item:*) : uint
      {
         var _loc2_:uint = 0;
         _current = -1;
         if(_next == -1)
         {
            _loc2_ = uint(this._arrayList.size);
            _next = _loc2_;
         }
         else
         {
            _loc2_ = uint(_next);
         }
         this._arrayList.addAt(_loc2_,item);
         return _loc2_;
      }
   }
}

