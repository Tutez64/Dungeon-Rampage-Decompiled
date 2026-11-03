package Box2D.Common.Math
{
   import flash.Boot;
   
   public class b2Transform
   {
      
      public var position:b2Vec2;
      
      public var R:b2Mat22;
      
      public function b2Transform(pos:b2Vec2 = undefined, r:b2Mat22 = undefined)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         position = new b2Vec2();
         R = new b2Mat22();
         if(pos != null)
         {
            position.setV(pos);
            R.setM(r);
         }
      }
      
      public function setIdentity() : void
      {
         SetIdentity();
      }
      
      public function set(x:b2Transform) : void
      {
         Set(x);
      }
      
      public function initialize(pos:b2Vec2, r:b2Mat22) : void
      {
         Initialize(pos,r);
      }
      
      public function getAngle() : Number
      {
         return GetAngle();
      }
      
      public function SetIdentity() : void
      {
         position.setZero();
         R.setIdentity();
      }
      
      public function Set(x:b2Transform) : void
      {
         position.setV(x.position);
         R.setM(x.R);
      }
      
      public function Initialize(pos:b2Vec2, r:b2Mat22) : void
      {
         position.setV(pos);
         R.setM(r);
      }
      
      public function GetAngle() : Number
      {
         return Math.atan2(R.col1.y,R.col1.x);
      }
   }
}

