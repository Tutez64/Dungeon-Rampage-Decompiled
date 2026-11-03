package Box2D.Collision
{
   import flash.Boot;
   
   public class b2SimplexCache
   {
      
      public var metric:Number;
      
      public var indexB:Array;
      
      public var indexA:Array;
      
      public var count:int;
      
      public function b2SimplexCache()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         count = 0;
         metric = 0;
         indexA = [];
         indexB = [];
      }
   }
}

