package Box2D.Dynamics
{
   import Box2D.Collision.b2Manifold;
   import Box2D.Dynamics.Contacts.b2Contact;
   
   public class b2ContactListener
   {
      
      public static var b2_defaultListener:b2ContactListener = new b2ContactListener();
      
      public function b2ContactListener()
      {
      }
      
      public function preSolve(contact:b2Contact, oldManifold:b2Manifold) : void
      {
         PreSolve(contact,oldManifold);
      }
      
      public function postSolve(contact:b2Contact, impulse:b2ContactImpulse) : void
      {
         PostSolve(contact,impulse);
      }
      
      public function endContact(contact:b2Contact) : void
      {
         EndContact(contact);
      }
      
      public function beginContact(contact:b2Contact) : void
      {
         BeginContact(contact);
      }
      
      public function PreSolve(contact:b2Contact, oldManifold:b2Manifold) : void
      {
      }
      
      public function PostSolve(contact:b2Contact, impulse:b2ContactImpulse) : void
      {
      }
      
      public function EndContact(contact:b2Contact) : void
      {
      }
      
      public function BeginContact(contact:b2Contact) : void
      {
      }
   }
}

