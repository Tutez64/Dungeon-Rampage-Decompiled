package Box2D.Dynamics.Joints
{
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.b2Body;
   import flash.Boot;
   
   public class b2DistanceJointDef extends b2JointDef
   {
      
      public var localAnchorB:b2Vec2;
      
      public var localAnchorA:b2Vec2;
      
      public var length:Number;
      
      public var frequencyHz:Number;
      
      public var dampingRatio:Number;
      
      public function b2DistanceJointDef()
      {
         if(!Boot.skip_constructor)
         {
            super();
            localAnchorA = new b2Vec2();
            localAnchorB = new b2Vec2();
            type = 3;
            length = 1;
            frequencyHz = 0;
            dampingRatio = 0;
         }
      }
      
      public function initialize(bA:b2Body, bB:b2Body, anchorA:b2Vec2, anchorB:b2Vec2) : void
      {
         Initialize(bA,bB,anchorA,anchorB);
      }
      
      public function Initialize(bA:b2Body, bB:b2Body, anchorA:b2Vec2, anchorB:b2Vec2) : void
      {
         bodyA = bA;
         bodyB = bB;
         localAnchorA.setV(bodyA.getLocalPoint(anchorA));
         localAnchorB.setV(bodyB.getLocalPoint(anchorB));
         var _loc5_:Number = anchorB.x - anchorA.x;
         var _loc6_:Number = anchorB.y - anchorA.y;
         length = Math.sqrt(_loc5_ * _loc5_ + _loc6_ * _loc6_);
         frequencyHz = 0;
         dampingRatio = 0;
      }
   }
}

