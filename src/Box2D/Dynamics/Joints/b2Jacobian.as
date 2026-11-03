package Box2D.Dynamics.Joints
{
   import Box2D.Common.Math.b2Vec2;
   import flash.Boot;
   
   public class b2Jacobian
   {
      
      public var linearB:b2Vec2;
      
      public var linearA:b2Vec2;
      
      public var angularB:Number;
      
      public var angularA:Number;
      
      public function b2Jacobian()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         linearA = new b2Vec2();
         linearB = new b2Vec2();
      }
      
      public function setZero() : void
      {
         SetZero();
      }
      
      public function set(x1:b2Vec2, a1:Number, x2:b2Vec2, a2:Number) : void
      {
         Set(x1,a1,x2,a2);
      }
      
      public function compute(x1:b2Vec2, a1:Number, x2:b2Vec2, a2:Number) : Number
      {
         return Compute(x1,a1,x2,a2);
      }
      
      public function SetZero() : void
      {
         linearA.setZero();
         angularA = 0;
         linearB.setZero();
         angularB = 0;
      }
      
      public function Set(x1:b2Vec2, a1:Number, x2:b2Vec2, a2:Number) : void
      {
         linearA.setV(x1);
         angularA = a1;
         linearB.setV(x2);
         angularB = a2;
      }
      
      public function Compute(x1:b2Vec2, a1:Number, x2:b2Vec2, a2:Number) : Number
      {
         return linearA.x * x1.x + linearA.y * x1.y + angularA * a1 + (linearB.x * x2.x + linearB.y * x2.y) + angularB * a2;
      }
   }
}

