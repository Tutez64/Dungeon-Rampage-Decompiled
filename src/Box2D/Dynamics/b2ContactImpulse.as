package Box2D.Dynamics
{
   import flash.Boot;
   
   public class b2ContactImpulse
   {
      
      public var tangentImpulses:Array;
      
      public var normalImpulses:Array;
      
      public function b2ContactImpulse()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         normalImpulses = [];
         tangentImpulses = [];
      }
   }
}

