package Box2D.Dynamics
{
   import Box2D.Common.Math.b2Vec2;
   import flash.Boot;
   
   public class b2BodyDef
   {
      
      public var userData:*;
      
      public var type:int;
      
      public var position:b2Vec2;
      
      public var linearVelocity:b2Vec2;
      
      public var linearDamping:Number;
      
      public var inertiaScale:Number;
      
      public var gravityScale:Number;
      
      public var fixedRotation:Boolean;
      
      public var bullet:Boolean;
      
      public var awake:Boolean;
      
      public var angularVelocity:Number;
      
      public var angularDamping:Number;
      
      public var angle:Number;
      
      public var allowSleep:Boolean;
      
      public var active:Boolean;
      
      public function b2BodyDef()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         position = new b2Vec2();
         linearVelocity = new b2Vec2();
         userData = null;
         angle = 0;
         angularVelocity = 0;
         linearDamping = 0;
         angularDamping = 0;
         allowSleep = true;
         awake = true;
         fixedRotation = false;
         bullet = false;
         type = 0;
         active = true;
         inertiaScale = 1;
         gravityScale = 1;
      }
   }
}

