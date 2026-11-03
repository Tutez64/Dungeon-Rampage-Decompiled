package Box2D.Dynamics
{
   import Box2D.Collision.Shapes.b2Shape;
   import flash.Boot;
   
   public class b2FixtureDef
   {
      
      public var userData:*;
      
      public var shape:b2Shape;
      
      public var restitution:Number;
      
      public var isSensor:Boolean;
      
      public var friction:Number;
      
      public var filter:b2FilterData;
      
      public var density:Number;
      
      public function b2FixtureDef()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         filter = new b2FilterData();
         shape = null;
         userData = null;
         friction = 0.2;
         restitution = 0;
         density = 0;
         filter.categoryBits = 1;
         filter.maskBits = 65535;
         filter.groupIndex = 0;
         isSensor = false;
      }
   }
}

