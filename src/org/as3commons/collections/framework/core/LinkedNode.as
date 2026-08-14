package org.as3commons.collections.framework.core
{
   public class LinkedNode
   {
      
      public var item:*;
      
      public var left:LinkedNode;
      
      public var right:LinkedNode;
      
      public function LinkedNode(theItem:*)
      {
         super();
         this.item = theItem;
      }
   }
}

