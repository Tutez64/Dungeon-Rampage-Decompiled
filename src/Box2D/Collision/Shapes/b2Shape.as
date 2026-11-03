package Box2D.Collision.Shapes
{
   import Box2D.Collision.b2AABB;
   import Box2D.Collision.b2Distance;
   import Box2D.Collision.b2DistanceInput;
   import Box2D.Collision.b2DistanceOutput;
   import Box2D.Collision.b2DistanceProxy;
   import Box2D.Collision.b2RayCastInput;
   import Box2D.Collision.b2RayCastOutput;
   import Box2D.Collision.b2SimplexCache;
   import Box2D.Common.Math.b2Transform;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Common.b2Settings;
   import flash.Boot;
   
   public class b2Shape
   {
      
      public static var e_hitCollide:int = 1;
      
      public static var e_missCollide:int = 0;
      
      public static var e_startsInsideCollide:int = -1;
      
      public var m_type:int;
      
      public var m_radius:Number;
      
      public function b2Shape()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         m_type = 0;
         m_radius = b2Settings.b2_linearSlop;
      }
      
      public static function testOverlap(shape1:b2Shape, transform1:b2Transform, shape2:b2Shape, transform2:b2Transform) : Boolean
      {
         var _loc5_:b2DistanceInput = new b2DistanceInput();
         _loc5_.proxyA = new b2DistanceProxy();
         _loc5_.proxyA.set(shape1);
         _loc5_.proxyB = new b2DistanceProxy();
         _loc5_.proxyB.set(shape2);
         _loc5_.transformA = transform1;
         _loc5_.transformB = transform2;
         _loc5_.useRadii = true;
         var _loc6_:b2SimplexCache = new b2SimplexCache();
         _loc6_.count = 0;
         var _loc7_:b2DistanceOutput = new b2DistanceOutput();
         b2Distance.distance(_loc7_,_loc6_,_loc5_);
         return _loc7_.distance < 10 * Number(Number.MIN_VALUE);
      }
      
      public static function TestOverlap(shape1:b2Shape, transform1:b2Transform, shape2:b2Shape, transform2:b2Transform) : Boolean
      {
         return b2Shape.testOverlap(shape1,transform1,shape2,transform2);
      }
      
      public function testPoint(xf:b2Transform, p:b2Vec2) : Boolean
      {
         return TestPoint(xf,p);
      }
      
      public function set(other:b2Shape) : void
      {
         Set(other);
      }
      
      public function rayCast(output:b2RayCastOutput, input:b2RayCastInput, transform:b2Transform) : Boolean
      {
         return RayCast(output,input,transform);
      }
      
      public function getType() : int
      {
         return GetType();
      }
      
      public function copy() : b2Shape
      {
         return Copy();
      }
      
      public function computeSubmergedArea(normal:b2Vec2, offset:Number, xf:b2Transform, c:b2Vec2) : Number
      {
         return ComputeSubmergedArea(normal,offset,xf,c);
      }
      
      public function computeMass(massData:b2MassData, density:Number) : void
      {
         ComputeMass(massData,density);
      }
      
      public function computeAABB(aabb:b2AABB, xf:b2Transform) : void
      {
         ComputeAABB(aabb,xf);
      }
      
      public function TestPoint(xf:b2Transform, p:b2Vec2) : Boolean
      {
         return false;
      }
      
      public function Set(other:b2Shape) : void
      {
         m_radius = other.m_radius;
      }
      
      public function RayCast(output:b2RayCastOutput, input:b2RayCastInput, transform:b2Transform) : Boolean
      {
         return false;
      }
      
      public function GetType() : int
      {
         return m_type;
      }
      
      public function Copy() : b2Shape
      {
         return null;
      }
      
      public function ComputeSubmergedArea(normal:b2Vec2, offset:Number, xf:b2Transform, c:b2Vec2) : Number
      {
         return 0;
      }
      
      public function ComputeMass(massData:b2MassData, density:Number) : void
      {
      }
      
      public function ComputeAABB(aabb:b2AABB, xf:b2Transform) : void
      {
      }
   }
}

