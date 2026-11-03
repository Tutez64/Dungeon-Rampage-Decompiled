package Collections
{
   import flash.Boot;
   
   public class LinkedListIterator implements ILinkedListIterator
   {
      
      public var _next:LinkedNode;
      
      public function LinkedListIterator(first:LinkedNode = undefined)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         _next = first;
      }
      
      public function next() : *
      {
         if(_next == null)
         {
            return undefined;
         }
         var _loc1_:* = _next.item;
         _next = _next.right;
         return _loc1_;
      }
      
      public function hasNext() : Boolean
      {
         return _next != null;
      }
   }
}

