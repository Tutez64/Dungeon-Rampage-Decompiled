package Box2D.Dynamics.Joints
{
   import Box2D.Dynamics.b2Body;
   import flash.Boot;
   
   public class b2JointDef
   {
      
      public var userData:*;
      
      public var type:int;
      
      public var collideConnected:Boolean;
      
      public var bodyB:b2Body;
      
      public var bodyA:b2Body;
      
      public function b2JointDef()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         type = 0;
         userData = null;
         bodyA = null;
         bodyB = null;
         collideConnected = false;
      }
   }
}

