package Box2D.Dynamics
{
   import Box2D.Common.b2Settings;
   
   public class b2ContactImpulse
   {
      
      public var normalImpulses:Vector.<Number> = new Vector.<Number>(b2Settings.b2_maxManifoldPoints);
      
      public var tangentImpulses:Vector.<Number> = new Vector.<Number>(b2Settings.b2_maxManifoldPoints);
      
      public function b2ContactImpulse()
      {
         super();
      }
   }
}

