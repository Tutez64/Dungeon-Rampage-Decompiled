package Collections
{
   public class LinkedList
   {
      
      public var _last:LinkedNode;
      
      public var _first:LinkedNode;
      
      public function LinkedList()
      {
      }
      
      public function iterator(cursor:* = undefined) : IIterator
      {
         return new LinkedListIterator(_first);
      }
      
      public function clear() : Boolean
      {
         if(_first == null)
         {
            return false;
         }
         _first = _last = null;
         return true;
      }
      
      public function add(item:*) : void
      {
         var _loc3_:* = null as LinkedNode;
         var _loc2_:LinkedNode = new LinkedNode(item);
         if(_first == null)
         {
            _first = _last = _loc2_;
         }
         else
         {
            _last.right = _loc2_;
            _last = _loc2_;
         }
      }
   }
}

