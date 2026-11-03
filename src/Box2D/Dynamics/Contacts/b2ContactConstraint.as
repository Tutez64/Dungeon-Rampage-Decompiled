package Box2D.Dynamics.Contacts
{
   import Box2D.Collision.b2Manifold;
   import Box2D.Common.Math.b2Mat22;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Common.b2Settings;
   import Box2D.Dynamics.b2Body;
   import box2D.collision.B2ManifoldType;
   import flash.Boot;
   
   public class b2ContactConstraint
   {
      
      public var type:B2ManifoldType;
      
      public var restitution:Number;
      
      public var radius:Number;
      
      public var points:Array;
      
      public var pointCount:int;
      
      public var normalMass:b2Mat22;
      
      public var normal:b2Vec2;
      
      public var manifold:b2Manifold;
      
      public var localPoint:b2Vec2;
      
      public var localPlaneNormal:b2Vec2;
      
      public var friction:Number;
      
      public var bodyB:b2Body;
      
      public var bodyA:b2Body;
      
      public var K:b2Mat22;
      
      public function b2ContactConstraint()
      {
         var _loc3_:int = 0;
         if(Boot.skip_constructor)
         {
            return;
         }
         pointCount = 0;
         restitution = 0;
         friction = 0;
         radius = 0;
         localPlaneNormal = new b2Vec2();
         localPoint = new b2Vec2();
         normal = new b2Vec2();
         normalMass = new b2Mat22();
         K = new b2Mat22();
         points = [];
         var _loc1_:int = 0;
         var _loc2_:int = b2Settings.b2_maxManifoldPoints;
         while(_loc1_ < _loc2_)
         {
            _loc3_ = _loc1_++;
            points[_loc3_] = new b2ContactConstraintPoint();
         }
      }
   }
}

