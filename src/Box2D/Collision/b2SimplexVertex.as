package Box2D.Collision
{
   import Box2D.Common.Math.b2Vec2;
   import flash.Boot;
   
   public class b2SimplexVertex
   {
      
      public var wB:b2Vec2;
      
      public var wA:b2Vec2;
      
      public var w:b2Vec2;
      
      public var indexB:int;
      
      public var indexA:int;
      
      public var a:Number;
      
      public function b2SimplexVertex()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         indexB = 0;
         indexA = 0;
         a = 0;
      }
      
      public function set(other:b2SimplexVertex) : void
      {
         Set(other);
      }
      
      public function Set(other:b2SimplexVertex) : void
      {
         wA.setV(other.wA);
         wB.setV(other.wB);
         w.setV(other.w);
         a = other.a;
         indexA = other.indexA;
         indexB = other.indexB;
      }
   }
}

