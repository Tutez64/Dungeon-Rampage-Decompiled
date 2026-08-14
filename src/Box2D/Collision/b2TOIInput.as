package Box2D.Collision
{
   import Box2D.Common.Math.b2Sweep;
   
   public class b2TOIInput
   {
      
      public var proxyA:b2DistanceProxy = new b2DistanceProxy();
      
      public var proxyB:b2DistanceProxy = new b2DistanceProxy();
      
      public var sweepA:b2Sweep = new b2Sweep();
      
      public var sweepB:b2Sweep = new b2Sweep();
      
      public var tolerance:Number;
      
      public function b2TOIInput()
      {
         super();
      }
   }
}

