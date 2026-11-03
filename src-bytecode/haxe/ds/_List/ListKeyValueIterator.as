package haxe.ds._List
{
   import flash.Boot;
   
   public class ListKeyValueIterator
   {
      
      public var idx:int;
      
      public var head:ListNode;
      
      public function ListKeyValueIterator(head:ListNode = undefined)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         this.head = head;
         idx = 0;
      }
      
      public function next() : Object
      {
         var _loc1_:Object = head.item;
         head = head.next;
         var _temp_4:* = "value";
         var _temp_3:* = _loc1_;
         var _temp_2:* = "key";
         var _loc2_:int;
         idx = (_loc2_ = idx) + 1;
         return {
            _temp_4:_temp_3,
            _temp_2:_loc2_
         };
      }
      
      public function hasNext() : Boolean
      {
         return head != null;
      }
   }
}

