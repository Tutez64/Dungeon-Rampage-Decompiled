package Box2D.Dynamics.Contacts
{
   import Box2D.Collision.Shapes.b2CircleShape;
   import Box2D.Collision.Shapes.b2EdgeShape;
   import Box2D.Collision.Shapes.b2Shape;
   import Box2D.Collision.b2Manifold;
   import Box2D.Common.Math.b2Transform;
   import Box2D.Common.b2Settings;
   import Box2D.Dynamics.b2Body;
   import Box2D.Dynamics.b2Fixture;
   import flash.Boot;
   
   public class b2EdgeAndCircleContact extends b2Contact
   {
      
      public function b2EdgeAndCircleContact()
      {
         if(!Boot.skip_constructor)
         {
            super();
         }
      }
      
      public static function create(allocator:*) : b2Contact
      {
         return new b2EdgeAndCircleContact();
      }
      
      public static function destroy(contact:b2Contact, allocator:*) : void
      {
      }
      
      public static function Create(allocator:*) : b2Contact
      {
         return b2EdgeAndCircleContact.create(allocator);
      }
      
      public static function Destroy(contact:b2Contact, allocator:*) : void
      {
         b2EdgeAndCircleContact.destroy(contact,allocator);
      }
      
      override public function reset(fixtureA:b2Fixture = undefined, fixtureB:b2Fixture = undefined) : void
      {
         Reset(fixtureA,fixtureB);
      }
      
      override public function evaluate() : void
      {
         Evaluate();
      }
      
      public function b2CollideEdgeAndCircle(manifold:b2Manifold, edge:b2EdgeShape, xf1:b2Transform, circle:b2CircleShape, xf2:b2Transform) : void
      {
      }
      
      override public function Reset(fixtureA:b2Fixture = undefined, fixtureB:b2Fixture = undefined) : void
      {
         super.Reset(fixtureA,fixtureB);
         b2Settings.b2Assert(fixtureA == null || fixtureA.getType() == 3);
         b2Settings.b2Assert(fixtureB == null || fixtureA.getType() == 1);
      }
      
      override public function Evaluate() : void
      {
         var _loc1_:b2Body = m_fixtureA.getBody();
         var _loc2_:b2Body = m_fixtureB.getBody();
         b2CollideEdgeAndCircle(m_manifold,b2EdgeShape(m_fixtureA.getShape()),_loc1_.m_xf,b2CircleShape(m_fixtureB.getShape()),_loc2_.m_xf);
      }
   }
}

