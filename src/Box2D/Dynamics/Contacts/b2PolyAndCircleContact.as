package Box2D.Dynamics.Contacts
{
   import Box2D.Collision.Shapes.b2CircleShape;
   import Box2D.Collision.Shapes.b2PolygonShape;
   import Box2D.Collision.Shapes.b2Shape;
   import Box2D.Collision.b2Collision;
   import Box2D.Common.b2Settings;
   import Box2D.Common.b2internal;
   import Box2D.Dynamics.b2Body;
   import Box2D.Dynamics.b2Fixture;
   
   use namespace b2internal;
   
   public class b2PolyAndCircleContact extends b2Contact
   {
      
      public function b2PolyAndCircleContact()
      {
         super();
      }
      
      public static function Create(allocator:*) : b2Contact
      {
         return new b2PolyAndCircleContact();
      }
      
      public static function Destroy(contact:b2Contact, allocator:*) : void
      {
      }
      
      public function Reset(fixtureA:b2Fixture, fixtureB:b2Fixture) : void
      {
         super.b2internal::Reset(fixtureA,fixtureB);
         b2Settings.b2Assert(fixtureA.GetType() == b2Shape.e_polygonShape);
         b2Settings.b2Assert(fixtureB.GetType() == b2Shape.e_circleShape);
      }
      
      override b2internal function Evaluate() : void
      {
         var _loc1_:b2Body = m_fixtureA.m_body;
         var _loc2_:b2Body = m_fixtureB.m_body;
         b2Collision.CollidePolygonAndCircle(m_manifold,m_fixtureA.GetShape() as b2PolygonShape,_loc1_.m_xf,m_fixtureB.GetShape() as b2CircleShape,_loc2_.m_xf);
      }
   }
}

