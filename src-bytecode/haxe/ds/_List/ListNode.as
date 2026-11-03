package haxe.ds._List
{
   import flash.Boot;
   
   public class ListNode
   {
      
      public var next:ListNode;
      
      public var item:Object;
      
      public function ListNode(item:Object = undefined, next:ListNode = undefined)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         this.item = item;
         this.next = next;
      }
   }
}

