package Box2D.Dynamics
{
   import flash.Boot;
   
   public class b2TimeStep
   {
      
      public var warmStarting:Boolean;
      
      public var velocityIterations:int;
      
      public var positionIterations:int;
      
      public var inv_dt:Number;
      
      public var dtRatio:Number;
      
      public var dt:Number;
      
      public function b2TimeStep()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         positionIterations = 0;
         velocityIterations = 0;
         dtRatio = 0;
         inv_dt = 0;
         dt = 0;
      }
      
      public function set(step:b2TimeStep) : void
      {
         Set(step);
      }
      
      public function Set(step:b2TimeStep) : void
      {
         dt = step.dt;
         inv_dt = step.inv_dt;
         positionIterations = step.positionIterations;
         velocityIterations = step.velocityIterations;
         warmStarting = step.warmStarting;
      }
   }
}

