package Box2D.Collision
{
   import Box2D.Common.Math.b2Vec2;
   import flash.Boot;
   
   public class b2DistanceOutput
   {
      
      public var pointB:b2Vec2;
      
      public var pointA:b2Vec2;
      
      public var iterations:int;
      
      public var distance:Number;
      
      public function b2DistanceOutput()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         pointA = new b2Vec2();
         pointB = new b2Vec2();
      }
   }
}

