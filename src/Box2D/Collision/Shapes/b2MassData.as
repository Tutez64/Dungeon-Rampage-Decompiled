package Box2D.Collision.Shapes
{
   import Box2D.Common.Math.b2Vec2;
   import flash.Boot;
   
   public class b2MassData
   {
      
      public var mass:Number;
      
      public var center:b2Vec2;
      
      public var I:Number;
      
      public function b2MassData()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         mass = 0;
         center = new b2Vec2(0,0);
         I = 0;
      }
   }
}

