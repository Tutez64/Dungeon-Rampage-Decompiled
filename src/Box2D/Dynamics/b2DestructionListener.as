package Box2D.Dynamics
{
   import Box2D.Dynamics.Joints.b2Joint;
   
   public class b2DestructionListener
   {
      
      public function b2DestructionListener()
      {
      }
      
      public function sayGoodbyeJoint(joint:b2Joint) : void
      {
         SayGoodbyeJoint(joint);
      }
      
      public function sayGoodbyeFixture(fixture:b2Fixture) : void
      {
         SayGoodbyeFixture(fixture);
      }
      
      public function SayGoodbyeJoint(joint:b2Joint) : void
      {
      }
      
      public function SayGoodbyeFixture(fixture:b2Fixture) : void
      {
      }
   }
}

