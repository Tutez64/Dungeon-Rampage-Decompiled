package Box2D.Dynamics.Joints
{
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.b2Body;
   import flash.Boot;
   
   public class b2RevoluteJointDef extends b2JointDef
   {
      
      public var upperAngle:Number;
      
      public var referenceAngle:Number;
      
      public var motorSpeed:Number;
      
      public var maxMotorTorque:Number;
      
      public var lowerAngle:Number;
      
      public var localAnchorB:b2Vec2;
      
      public var localAnchorA:b2Vec2;
      
      public var enableMotor:Boolean;
      
      public var enableLimit:Boolean;
      
      public function b2RevoluteJointDef()
      {
         if(!Boot.skip_constructor)
         {
            super();
            localAnchorA = new b2Vec2();
            localAnchorB = new b2Vec2();
            type = 1;
            localAnchorA.set(0,0);
            localAnchorB.set(0,0);
            referenceAngle = 0;
            lowerAngle = 0;
            upperAngle = 0;
            maxMotorTorque = 0;
            motorSpeed = 0;
            enableLimit = false;
            enableMotor = false;
         }
      }
      
      public function initialize(bA:b2Body, bB:b2Body, anchor:b2Vec2) : void
      {
         Initialize(bA,bB,anchor);
      }
      
      public function Initialize(bA:b2Body, bB:b2Body, anchor:b2Vec2) : void
      {
         bodyA = bA;
         bodyB = bB;
         localAnchorA = bodyA.getLocalPoint(anchor);
         localAnchorB = bodyB.getLocalPoint(anchor);
         referenceAngle = bodyB.getAngle() - bodyA.getAngle();
      }
   }
}

