package Box2D.Dynamics.Contacts
{
   import Box2D.Dynamics.b2Body;
   
   public class b2ContactEdge
   {
      
      public var prev:b2ContactEdge;
      
      public var other:b2Body;
      
      public var next:b2ContactEdge;
      
      public var contact:b2Contact;
      
      public function b2ContactEdge()
      {
      }
   }
}

