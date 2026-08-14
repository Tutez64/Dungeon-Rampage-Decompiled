package Box2D.Dynamics.Contacts
{
   import Box2D.Collision.*;
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   import Box2D.Dynamics.*;
   
   use namespace b2internal;
   
   public class b2ContactConstraint
   {
      
      public var points:Vector.<b2ContactConstraintPoint>;
      
      public var localPlaneNormal:b2Vec2 = new b2Vec2();
      
      public var localPoint:b2Vec2 = new b2Vec2();
      
      public var normal:b2Vec2 = new b2Vec2();
      
      public var normalMass:b2Mat22 = new b2Mat22();
      
      public var K:b2Mat22 = new b2Mat22();
      
      public var bodyA:b2Body;
      
      public var bodyB:b2Body;
      
      public var type:int;
      
      public var radius:Number;
      
      public var friction:Number;
      
      public var restitution:Number;
      
      public var pointCount:int;
      
      public var manifold:b2Manifold;
      
      public function b2ContactConstraint()
      {
         super();
         this.points = new Vector.<b2ContactConstraintPoint>(b2Settings.b2_maxManifoldPoints);
         var _loc1_:* = 0;
         while(_loc1_ < b2Settings.b2_maxManifoldPoints)
         {
            this.points[_loc1_] = new b2ContactConstraintPoint();
            _loc1_++;
         }
      }
   }
}

