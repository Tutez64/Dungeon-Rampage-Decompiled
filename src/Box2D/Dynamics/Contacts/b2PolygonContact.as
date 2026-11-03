package Box2D.Dynamics.Contacts
{
   import Box2D.Collision.Shapes.b2PolygonShape;
   import Box2D.Collision.Shapes.b2Shape;
   import Box2D.Collision.b2Collision;
   import Box2D.Dynamics.b2Body;
   import Box2D.Dynamics.b2Fixture;
   import flash.Boot;
   
   public class b2PolygonContact extends b2Contact
   {
      
      public function b2PolygonContact()
      {
         if(!Boot.skip_constructor)
         {
            super();
         }
      }
      
      public static function create(allocator:*) : b2Contact
      {
         return new b2PolygonContact();
      }
      
      public static function destroy(contact:b2Contact, allocator:*) : void
      {
      }
      
      public static function Create(allocator:*) : b2Contact
      {
         return b2PolygonContact.create(allocator);
      }
      
      public static function Destroy(contact:b2Contact, allocator:*) : void
      {
         b2PolygonContact.destroy(contact,allocator);
      }
      
      override public function reset(fixtureA:b2Fixture = undefined, fixtureB:b2Fixture = undefined) : void
      {
         Reset(fixtureA,fixtureB);
      }
      
      override public function evaluate() : void
      {
         Evaluate();
      }
      
      override public function Reset(fixtureA:b2Fixture = undefined, fixtureB:b2Fixture = undefined) : void
      {
         super.Reset(fixtureA,fixtureB);
      }
      
      override public function Evaluate() : void
      {
         var _loc1_:b2Body = m_fixtureA.getBody();
         var _loc2_:b2Body = m_fixtureB.getBody();
         b2Collision.collidePolygons(m_manifold,b2PolygonShape(m_fixtureA.getShape()),_loc1_.m_xf,b2PolygonShape(m_fixtureB.getShape()),_loc2_.m_xf);
      }
   }
}

