package Box2D.Collision
{
   public class b2DynamicTreeNode
   {
      
      public var userData:*;
      
      public var aabb:b2AABB = new b2AABB();
      
      public var parent:b2DynamicTreeNode;
      
      public var child1:b2DynamicTreeNode;
      
      public var child2:b2DynamicTreeNode;
      
      public function b2DynamicTreeNode()
      {
         super();
      }
      
      public function IsLeaf() : Boolean
      {
         return this.child1 == null;
      }
   }
}

