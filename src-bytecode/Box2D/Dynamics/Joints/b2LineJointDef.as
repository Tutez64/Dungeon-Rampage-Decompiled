package Box2D.Dynamics.Joints
{
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.b2Body;
   import flash.Boot;
   
   public class b2LineJointDef extends b2JointDef
   {
      
      public var upperTranslation:Number;
      
      public var motorSpeed:Number;
      
      public var maxMotorForce:Number;
      
      public var lowerTranslation:Number;
      
      public var localAxisA:b2Vec2;
      
      public var localAnchorB:b2Vec2;
      
      public var localAnchorA:b2Vec2;
      
      public var enableMotor:Boolean;
      
      public var enableLimit:Boolean;
      
      public function b2LineJointDef()
      {
         if(!Boot.skip_constructor)
         {
            super();
         }
      }
      
      public function initialize(bA:b2Body, bB:b2Body, anchor:b2Vec2, axis:b2Vec2) : void
      {
         Initialize(bA,bB,anchor,axis);
      }
      
      public function b2LineJointDef() : void
      {
         localAnchorA = new b2Vec2();
         localAnchorB = new b2Vec2();
         localAxisA = new b2Vec2();
         type = 7;
         localAxisA.set(1,0);
         enableLimit = false;
         lowerTranslation = 0;
         upperTranslation = 0;
         enableMotor = false;
         maxMotorForce = 0;
         motorSpeed = 0;
      }
      
      public function Initialize(bA:b2Body, bB:b2Body, anchor:b2Vec2, axis:b2Vec2) : void
      {
         bodyA = bA;
         bodyB = bB;
         localAnchorA = bodyA.getLocalPoint(anchor);
         localAnchorB = bodyB.getLocalPoint(anchor);
         localAxisA = bodyA.getLocalVector(axis);
      }
   }
}

