package org.as3commons.collections.framework.core
{
   public class SortedMapNode extends SortedNode
   {
      
      public var key:*;
      
      public function SortedMapNode(theKey:*, theItem:*)
      {
         super(theItem);
         this.key = theKey;
      }
   }
}

