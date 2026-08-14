package org.as3commons.collections.framework.core
{
   import org.as3commons.collections.framework.IComparator;
   import org.as3commons.collections.framework.IDuplicates;
   
   use namespace as3commons_collections;
   
   public class AbstractSortedDuplicatesCollection extends AbstractSortedCollection implements IDuplicates
   {
      
      public function AbstractSortedDuplicatesCollection(comparator:IComparator)
      {
         super(comparator);
      }
      
      public function removeAll(item:*) : uint
      {
         var _loc4_:SortedNode = null;
         var _loc2_:SortedNode = firstEqualNode(item);
         if(!_loc2_)
         {
            return 0;
         }
         var _loc3_:uint = 0;
         while(_loc2_)
         {
            if(_comparator.compare(item,_loc2_.item))
            {
               break;
            }
            if(_loc2_.item === item)
            {
               _loc4_ = nextNode_internal(_loc2_);
               removeNode(_loc2_);
               _loc2_ = _loc4_;
               _loc3_++;
            }
            else
            {
               _loc2_ = nextNode_internal(_loc2_);
            }
         }
         return _loc3_;
      }
      
      public function count(item:*) : uint
      {
         var _loc2_:SortedNode = firstEqualNode(item);
         if(!_loc2_)
         {
            return 0;
         }
         var _loc3_:uint = 0;
         if(_loc2_.item === item)
         {
            _loc3_++;
         }
         _loc2_ = nextNode_internal(_loc2_);
         while(_loc2_)
         {
            if(_comparator.compare(item,_loc2_.item))
            {
               break;
            }
            if(_loc2_.item === item)
            {
               _loc3_++;
            }
            _loc2_ = nextNode_internal(_loc2_);
         }
         return _loc3_;
      }
   }
}

