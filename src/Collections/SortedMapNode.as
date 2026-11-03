package Collections
{
   import flash.Boot;
   
   public class SortedMapNode
   {
      
      public var key:*;
      
      public var item:*;
      
      public function SortedMapNode(key:* = undefined, item:* = undefined)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         this.key = key;
         this.item = item;
      }
   }
}

