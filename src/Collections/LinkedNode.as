package Collections
{
   import flash.Boot;
   
   public class LinkedNode
   {
      
      public var right:LinkedNode;
      
      public var item:*;
      
      public function LinkedNode(item:* = undefined)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         this.item = item;
      }
   }
}

