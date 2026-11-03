package Box2D.Collision
{
   import Box2D.Collision.Shapes.b2Shape;
   import Box2D.Common.Math.b2Vec2;
   import flash.Boot;
   
   public class b2ContactPoint
   {
      
      public var velocity:b2Vec2;
      
      public var shape2:b2Shape;
      
      public var shape1:b2Shape;
      
      public var separation:Number;
      
      public var restitution:Number;
      
      public var position:b2Vec2;
      
      public var normal:b2Vec2;
      
      public var id:b2ContactID;
      
      public var friction:Number;
      
      public function b2ContactPoint()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         position = new b2Vec2();
         velocity = new b2Vec2();
         normal = new b2Vec2();
         id = new b2ContactID();
      }
   }
}

