package Box2D.Collision
{
   import Box2D.Common.Math.b2Mat22;
   import Box2D.Common.Math.b2Vec2;
   import flash.Boot;
   
   public class b2OBB
   {
      
      public var extents:b2Vec2;
      
      public var center:b2Vec2;
      
      public var R:b2Mat22;
      
      public function b2OBB()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         R = new b2Mat22();
         center = new b2Vec2();
         extents = new b2Vec2();
      }
   }
}

