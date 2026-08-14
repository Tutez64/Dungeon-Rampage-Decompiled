package Box2D.Common.Math
{
   public class b2Transform
   {
      
      public var position:b2Vec2 = new b2Vec2();
      
      public var R:b2Mat22 = new b2Mat22();
      
      public function b2Transform(pos:b2Vec2 = null, r:b2Mat22 = null)
      {
         super();
         if(pos)
         {
            this.position.SetV(pos);
            this.R.SetM(r);
         }
      }
      
      public function Initialize(pos:b2Vec2, r:b2Mat22) : void
      {
         this.position.SetV(pos);
         this.R.SetM(r);
      }
      
      public function SetIdentity() : void
      {
         this.position.SetZero();
         this.R.SetIdentity();
      }
      
      public function Set(x:b2Transform) : void
      {
         this.position.SetV(x.position);
         this.R.SetM(x.R);
      }
      
      public function GetAngle() : Number
      {
         return Math.atan2(this.R.col1.y,this.R.col1.x);
      }
   }
}

