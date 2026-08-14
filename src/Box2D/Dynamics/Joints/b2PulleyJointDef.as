package Box2D.Dynamics.Joints
{
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Common.b2internal;
   import Box2D.Dynamics.b2Body;
   
   use namespace b2internal;
   
   public class b2PulleyJointDef extends b2JointDef
   {
      
      public var groundAnchorA:b2Vec2 = new b2Vec2();
      
      public var groundAnchorB:b2Vec2 = new b2Vec2();
      
      public var localAnchorA:b2Vec2 = new b2Vec2();
      
      public var localAnchorB:b2Vec2 = new b2Vec2();
      
      public var lengthA:Number;
      
      public var maxLengthA:Number;
      
      public var lengthB:Number;
      
      public var maxLengthB:Number;
      
      public var ratio:Number;
      
      public function b2PulleyJointDef()
      {
         super();
         type = b2Joint.e_pulleyJoint;
         this.groundAnchorA.Set(-1,1);
         this.groundAnchorB.Set(1,1);
         this.localAnchorA.Set(-1,0);
         this.localAnchorB.Set(1,0);
         this.lengthA = 0;
         this.maxLengthA = 0;
         this.lengthB = 0;
         this.maxLengthB = 0;
         this.ratio = 1;
         collideConnected = true;
      }
      
      public function Initialize(bA:b2Body, bB:b2Body, gaA:b2Vec2, gaB:b2Vec2, anchorA:b2Vec2, anchorB:b2Vec2, r:Number) : void
      {
         bodyA = bA;
         bodyB = bB;
         this.groundAnchorA.SetV(gaA);
         this.groundAnchorB.SetV(gaB);
         this.localAnchorA = bodyA.GetLocalPoint(anchorA);
         this.localAnchorB = bodyB.GetLocalPoint(anchorB);
         var _loc8_:Number = anchorA.x - gaA.x;
         var _loc9_:Number = anchorA.y - gaA.y;
         this.lengthA = Math.sqrt(_loc8_ * _loc8_ + _loc9_ * _loc9_);
         var _loc10_:Number = anchorB.x - gaB.x;
         var _loc11_:Number = anchorB.y - gaB.y;
         this.lengthB = Math.sqrt(_loc10_ * _loc10_ + _loc11_ * _loc11_);
         this.ratio = r;
         var _loc12_:Number = this.lengthA + this.ratio * this.lengthB;
         this.maxLengthA = _loc12_ - this.ratio * b2PulleyJoint.b2_minPulleyLength;
         this.maxLengthB = (_loc12_ - b2PulleyJoint.b2_minPulleyLength) / this.ratio;
      }
   }
}

