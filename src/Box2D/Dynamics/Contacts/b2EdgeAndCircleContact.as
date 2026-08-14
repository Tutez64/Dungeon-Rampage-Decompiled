package Box2D.Dynamics.Contacts
{
   import Box2D.Collision.Shapes.b2CircleShape;
   import Box2D.Collision.Shapes.b2EdgeShape;
   import Box2D.Collision.b2Manifold;
   import Box2D.Common.Math.b2Transform;
   import Box2D.Common.b2internal;
   import Box2D.Dynamics.b2Body;
   import Box2D.Dynamics.b2Fixture;
   
   use namespace b2internal;
   
   public class b2EdgeAndCircleContact extends b2Contact
   {
      
      public function b2EdgeAndCircleContact()
      {
         super();
      }
      
      public static function Create(allocator:*) : b2Contact
      {
         return new b2EdgeAndCircleContact();
      }
      
      public static function Destroy(contact:b2Contact, allocator:*) : void
      {
      }
      
      public function Reset(fixtureA:b2Fixture, fixtureB:b2Fixture) : void
      {
         super.b2internal::Reset(fixtureA,fixtureB);
      }
      
      override b2internal function Evaluate() : void
      {
         var _loc1_:b2Body = m_fixtureA.GetBody();
         var _loc2_:b2Body = m_fixtureB.GetBody();
         this.b2CollideEdgeAndCircle(m_manifold,m_fixtureA.GetShape() as b2EdgeShape,_loc1_.m_xf,m_fixtureB.GetShape() as b2CircleShape,_loc2_.m_xf);
      }
      
      private function b2CollideEdgeAndCircle(manifold:b2Manifold, edge:b2EdgeShape, xf1:b2Transform, circle:b2CircleShape, xf2:b2Transform) : void
      {
      }
   }
}

