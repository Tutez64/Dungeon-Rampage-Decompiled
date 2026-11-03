package Box2D.Collision
{
   import Box2D.Common.Math.b2Sweep;
   import flash.Boot;
   
   public class b2TOIInput
   {
      
      public var tolerance:Number;
      
      public var sweepB:b2Sweep;
      
      public var sweepA:b2Sweep;
      
      public var proxyB:b2DistanceProxy;
      
      public var proxyA:b2DistanceProxy;
      
      public function b2TOIInput()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         proxyA = new b2DistanceProxy();
         proxyB = new b2DistanceProxy();
         sweepA = new b2Sweep();
         sweepB = new b2Sweep();
      }
   }
}

