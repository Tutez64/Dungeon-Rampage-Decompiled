package Box2D.Collision
{
   import Box2D.Common.Math.b2Vec2;
   import flash.Boot;
   
   public class b2RayCastOutput
   {
      
      public var normal:b2Vec2;
      
      public var fraction:Number;
      
      public function b2RayCastOutput()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         normal = new b2Vec2();
      }
   }
}

