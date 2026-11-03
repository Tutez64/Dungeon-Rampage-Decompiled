package Box2D.Collision
{
   import flash.Boot;
   
   public class b2DynamicTreeNode
   {
      
      public static var currentID:int = 0;
      
      public var userData:*;
      
      public var parent:b2DynamicTreeNode;
      
      public var id:int;
      
      public var child2:b2DynamicTreeNode;
      
      public var child1:b2DynamicTreeNode;
      
      public var aabb:b2AABB;
      
      public function b2DynamicTreeNode()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         aabb = new b2AABB();
         var _temp_1:* = b2DynamicTreeNode;
         var _loc1_:int;
         _temp_1.currentID = (_loc1_ = int(_temp_1.currentID)) + 1;
         id = _loc1_;
      }
      
      public function isLeaf() : Boolean
      {
         return IsLeaf();
      }
      
      public function IsLeaf() : Boolean
      {
         return child1 == null;
      }
   }
}

