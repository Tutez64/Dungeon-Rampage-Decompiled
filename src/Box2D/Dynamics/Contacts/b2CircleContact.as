package Box2D.Dynamics.Contacts
{
   import Box2D.Collision.Shapes.b2CircleShape;
   import Box2D.Collision.Shapes.b2Shape;
   import Box2D.Collision.b2Collision;
   import Box2D.Dynamics.b2Body;
   import Box2D.Dynamics.b2Fixture;
   import flash.Boot;
   
   public class b2CircleContact extends b2Contact
   {
      
      public function b2CircleContact()
      {
         if(!Boot.skip_constructor)
         {
            super();
         }
      }
      
      public static function create(allocator:*) : b2Contact
      {
         return new b2CircleContact();
      }
      
      public static function destroy(contact:b2Contact, allocator:*) : void
      {
      }
      
      public static function Create(allocator:*) : b2Contact
      {
         return b2CircleContact.create(allocator);
      }
      
      public static function Destroy(contact:b2Contact, allocator:*) : void
      {
         b2CircleContact.destroy(contact,allocator);
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
         b2Collision.collideCircles(m_manifold,b2CircleShape(m_fixtureA.getShape()),_loc1_.m_xf,b2CircleShape(m_fixtureB.getShape()),_loc2_.m_xf);
      }
   }
}

