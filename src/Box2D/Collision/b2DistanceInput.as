package Box2D.Collision
{
   import Box2D.Common.Math.b2Transform;
   
   public class b2DistanceInput
   {
      
      public var useRadii:Boolean;
      
      public var transformB:b2Transform;
      
      public var transformA:b2Transform;
      
      public var proxyB:b2DistanceProxy;
      
      public var proxyA:b2DistanceProxy;
      
      public function b2DistanceInput()
      {
      }
   }
}

