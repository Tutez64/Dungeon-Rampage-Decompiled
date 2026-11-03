package Box2D.Dynamics.Joints
{
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.b2Body;
   import flash.Boot;
   
   public class b2PulleyJointDef extends b2JointDef
   {
      
      public var ratio:Number;
      
      public var maxLengthB:Number;
      
      public var maxLengthA:Number;
      
      public var localAnchorB:b2Vec2;
      
      public var localAnchorA:b2Vec2;
      
      public var lengthB:Number;
      
      public var lengthA:Number;
      
      public var groundAnchorB:b2Vec2;
      
      public var groundAnchorA:b2Vec2;
      
      public function b2PulleyJointDef()
      {
         if(!Boot.skip_constructor)
         {
            super();
            groundAnchorA = new b2Vec2();
            groundAnchorB = new b2Vec2();
            localAnchorA = new b2Vec2();
            localAnchorB = new b2Vec2();
            type = 4;
            groundAnchorA.set(-1,1);
            groundAnchorB.set(1,1);
            localAnchorA.set(-1,0);
            localAnchorB.set(1,0);
            lengthA = 0;
            maxLengthA = 0;
            lengthB = 0;
            maxLengthB = 0;
            ratio = 1;
            collideConnected = true;
         }
      }
      
      public function initialize(bA:b2Body, bB:b2Body, gaA:b2Vec2, gaB:b2Vec2, anchorA:b2Vec2, anchorB:b2Vec2, r:Number) : void
      {
         Initialize(bA,bB,gaA,gaB,anchorA,anchorB,r);
      }
      
      public function Initialize(bA:b2Body, bB:b2Body, gaA:b2Vec2, gaB:b2Vec2, anchorA:b2Vec2, anchorB:b2Vec2, r:Number) : void
      {
         bodyA = bA;
         bodyB = bB;
         groundAnchorA.setV(gaA);
         groundAnchorB.setV(gaB);
         localAnchorA = bodyA.getLocalPoint(anchorA);
         localAnchorB = bodyB.getLocalPoint(anchorB);
         var _loc8_:Number = anchorA.x - gaA.x;
         var _loc9_:Number = anchorA.y - gaA.y;
         lengthA = Math.sqrt(_loc8_ * _loc8_ + _loc9_ * _loc9_);
         var _loc10_:Number = anchorB.x - gaB.x;
         var _loc11_:Number = anchorB.y - gaB.y;
         lengthB = Math.sqrt(_loc10_ * _loc10_ + _loc11_ * _loc11_);
         ratio = r;
         var _loc12_:Number = lengthA + ratio * lengthB;
         maxLengthA = _loc12_ - ratio * b2PulleyJoint.b2_minPulleyLength;
         maxLengthB = (_loc12_ - b2PulleyJoint.b2_minPulleyLength) / ratio;
      }
   }
}

