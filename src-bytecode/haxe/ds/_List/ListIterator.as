package haxe.ds._List
{
   import flash.Boot;
   
   public class ListIterator
   {
      
      public var head:ListNode;
      
      public function ListIterator(head:ListNode = undefined)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         this.head = head;
      }
      
      public function next() : Object
      {
         var _loc1_:Object = head.item;
         head = head.next;
         return _loc1_;
      }
      
      public function hasNext() : Boolean
      {
         return head != null;
      }
   }
}

