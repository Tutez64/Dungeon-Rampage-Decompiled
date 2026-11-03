package Box2D.Collision
{
   import Box2D.Common.Math.b2Vec2;
   import flash.Boot;
   
   public class b2RayCastInput
   {
      
      public var p2:b2Vec2;
      
      public var p1:b2Vec2;
      
      public var maxFraction:Number;
      
      public function b2RayCastInput(p1:b2Vec2 = undefined, p2:b2Vec2 = undefined, maxFraction:Number = 1)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         this.p1 = new b2Vec2();
         this.p2 = new b2Vec2();
         if(p1 != null)
         {
            this.p1.setV(p1);
         }
         if(p2 != null)
         {
            this.p2.setV(p2);
         }
         this.maxFraction = maxFraction;
      }
   }
}

