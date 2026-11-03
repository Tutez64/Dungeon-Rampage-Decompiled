package Box2D.Dynamics.Contacts
{
   import Box2D.Collision.Shapes.b2EdgeShape;
   import Box2D.Collision.Shapes.b2PolygonShape;
   import Box2D.Collision.Shapes.b2Shape;
   import Box2D.Collision.b2Manifold;
   import Box2D.Common.Math.b2Transform;
   import Box2D.Common.b2Settings;
   import Box2D.Dynamics.b2Body;
   import Box2D.Dynamics.b2Fixture;
   import flash.Boot;
   
   public class b2PolyAndEdgeContact extends b2Contact
   {
      
      public function b2PolyAndEdgeContact()
      {
         if(!Boot.skip_constructor)
         {
            super();
         }
      }
      
      public static function create(allocator:*) : b2Contact
      {
         return new b2PolyAndEdgeContact();
      }
      
      public static function destroy(contact:b2Contact, allocator:*) : void
      {
      }
      
      public static function Create(allocator:*) : b2Contact
      {
         return b2PolyAndEdgeContact.create(allocator);
      }
      
      public static function Destroy(contact:b2Contact, allocator:*) : void
      {
         b2PolyAndEdgeContact.destroy(contact,allocator);
      }
      
      override public function reset(fixtureA:b2Fixture = undefined, fixtureB:b2Fixture = undefined) : void
      {
         Reset(fixtureA,fixtureB);
      }
      
      override public function evaluate() : void
      {
         Evaluate();
      }
      
      public function b2CollidePolyAndEdge(manifold:b2Manifold, polygon:b2PolygonShape, xf1:b2Transform, edge:b2EdgeShape, xf2:b2Transform) : void
      {
      }
      
      override public function Reset(fixtureA:b2Fixture = undefined, fixtureB:b2Fixture = undefined) : void
      {
         super.Reset(fixtureA,fixtureB);
         b2Settings.b2Assert(fixtureA == null || fixtureA.getType() == 2);
         b2Settings.b2Assert(fixtureB == null || fixtureB.getType() == 3);
      }
      
      override public function Evaluate() : void
      {
         var _loc1_:b2Body = m_fixtureA.getBody();
         var _loc2_:b2Body = m_fixtureB.getBody();
         b2CollidePolyAndEdge(m_manifold,b2PolygonShape(m_fixtureA.getShape()),_loc1_.m_xf,b2EdgeShape(m_fixtureB.getShape()),_loc2_.m_xf);
      }
   }
}

