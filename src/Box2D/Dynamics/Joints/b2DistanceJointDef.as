package Box2D.Dynamics.Joints
{
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Common.b2internal;
   import Box2D.Dynamics.b2Body;
   
   use namespace b2internal;
   
   public class b2DistanceJointDef extends b2JointDef
   {
      
      public var localAnchorA:b2Vec2 = new b2Vec2();
      
      public var localAnchorB:b2Vec2 = new b2Vec2();
      
      public var length:Number;
      
      public var frequencyHz:Number;
      
      public var dampingRatio:Number;
      
      public function b2DistanceJointDef()
      {
         super();
         type = b2Joint.e_distanceJoint;
         this.length = 1;
         this.frequencyHz = 0;
         this.dampingRatio = 0;
      }
      
      public function Initialize(bA:b2Body, bB:b2Body, anchorA:b2Vec2, anchorB:b2Vec2) : void
      {
         bodyA = bA;
         bodyB = bB;
         this.localAnchorA.SetV(bodyA.GetLocalPoint(anchorA));
         this.localAnchorB.SetV(bodyB.GetLocalPoint(anchorB));
         var _loc5_:Number = anchorB.x - anchorA.x;
         var _loc6_:Number = anchorB.y - anchorA.y;
         this.length = Math.sqrt(_loc5_ * _loc5_ + _loc6_ * _loc6_);
         this.frequencyHz = 0;
         this.dampingRatio = 0;
      }
   }
}

