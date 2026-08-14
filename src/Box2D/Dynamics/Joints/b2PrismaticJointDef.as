package Box2D.Dynamics.Joints
{
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Common.b2internal;
   import Box2D.Dynamics.b2Body;
   
   use namespace b2internal;
   
   public class b2PrismaticJointDef extends b2JointDef
   {
      
      public var localAnchorA:b2Vec2 = new b2Vec2();
      
      public var localAnchorB:b2Vec2 = new b2Vec2();
      
      public var localAxisA:b2Vec2 = new b2Vec2();
      
      public var referenceAngle:Number;
      
      public var enableLimit:Boolean;
      
      public var lowerTranslation:Number;
      
      public var upperTranslation:Number;
      
      public var enableMotor:Boolean;
      
      public var maxMotorForce:Number;
      
      public var motorSpeed:Number;
      
      public function b2PrismaticJointDef()
      {
         super();
         type = b2Joint.e_prismaticJoint;
         this.localAxisA.Set(1,0);
         this.referenceAngle = 0;
         this.enableLimit = false;
         this.lowerTranslation = 0;
         this.upperTranslation = 0;
         this.enableMotor = false;
         this.maxMotorForce = 0;
         this.motorSpeed = 0;
      }
      
      public function Initialize(bA:b2Body, bB:b2Body, anchor:b2Vec2, axis:b2Vec2) : void
      {
         bodyA = bA;
         bodyB = bB;
         this.localAnchorA = bodyA.GetLocalPoint(anchor);
         this.localAnchorB = bodyB.GetLocalPoint(anchor);
         this.localAxisA = bodyA.GetLocalVector(axis);
         this.referenceAngle = bodyB.GetAngle() - bodyA.GetAngle();
      }
   }
}

