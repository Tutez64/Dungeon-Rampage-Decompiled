package Box2D.Dynamics.Joints
{
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.b2Body;
   import flash.Boot;
   
   public class b2FrictionJointDef extends b2JointDef
   {
      
      public var maxTorque:Number;
      
      public var maxForce:Number;
      
      public var localAnchorB:b2Vec2;
      
      public var localAnchorA:b2Vec2;
      
      public function b2FrictionJointDef()
      {
         if(!Boot.skip_constructor)
         {
            super();
            localAnchorA = new b2Vec2();
            localAnchorB = new b2Vec2();
            type = 9;
            maxForce = 0;
            maxTorque = 0;
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
         localAnchorA.setV(bodyA.getLocalPoint(anchor));
         localAnchorB.setV(bodyB.getLocalPoint(anchor));
      }
   }
}

