package Box2D.Common.Math
{
   public class b2Vec2
   {
      
      public var x:Number;
      
      public var y:Number;
      
      public function b2Vec2(x_:Number = 0, y_:Number = 0)
      {
         super();
         this.x = x_;
         this.y = y_;
      }
      
      public static function Make(x_:Number, y_:Number) : b2Vec2
      {
         return new b2Vec2(x_,y_);
      }
      
      public function SetZero() : void
      {
         this.x = 0;
         this.y = 0;
      }
      
      public function Set(x_:Number = 0, y_:Number = 0) : void
      {
         this.x = x_;
         this.y = y_;
      }
      
      public function SetV(v:b2Vec2) : void
      {
         this.x = v.x;
         this.y = v.y;
      }
      
      public function GetNegative() : b2Vec2
      {
         return new b2Vec2(-this.x,-this.y);
      }
      
      public function NegativeSelf() : void
      {
         this.x = -this.x;
         this.y = -this.y;
      }
      
      public function Copy() : b2Vec2
      {
         return new b2Vec2(this.x,this.y);
      }
      
      public function Add(v:b2Vec2) : void
      {
         this.x += v.x;
         this.y += v.y;
      }
      
      public function Subtract(v:b2Vec2) : void
      {
         this.x -= v.x;
         this.y -= v.y;
      }
      
      public function Multiply(a:Number) : void
      {
         this.x *= a;
         this.y *= a;
      }
      
      public function MulM(A:b2Mat22) : void
      {
         var _loc2_:Number = this.x;
         this.x = A.col1.x * _loc2_ + A.col2.x * this.y;
         this.y = A.col1.y * _loc2_ + A.col2.y * this.y;
      }
      
      public function MulTM(A:b2Mat22) : void
      {
         var _loc2_:Number = b2Math.Dot(this,A.col1);
         this.y = b2Math.Dot(this,A.col2);
         this.x = _loc2_;
      }
      
      public function CrossVF(s:Number) : void
      {
         var _loc2_:Number = this.x;
         this.x = s * this.y;
         this.y = -s * _loc2_;
      }
      
      public function CrossFV(s:Number) : void
      {
         var _loc2_:Number = this.x;
         this.x = -s * this.y;
         this.y = s * _loc2_;
      }
      
      public function MinV(b:b2Vec2) : void
      {
         this.x = this.x < b.x ? this.x : b.x;
         this.y = this.y < b.y ? this.y : b.y;
      }
      
      public function MaxV(b:b2Vec2) : void
      {
         this.x = this.x > b.x ? this.x : b.x;
         this.y = this.y > b.y ? this.y : b.y;
      }
      
      public function Abs() : void
      {
         if(this.x < 0)
         {
            this.x = -this.x;
         }
         if(this.y < 0)
         {
            this.y = -this.y;
         }
      }
      
      public function Length() : Number
      {
         return Math.sqrt(this.x * this.x + this.y * this.y);
      }
      
      public function LengthSquared() : Number
      {
         return this.x * this.x + this.y * this.y;
      }
      
      public function Normalize() : Number
      {
         var _loc1_:Number = Math.sqrt(this.x * this.x + this.y * this.y);
         if(_loc1_ < Number.MIN_VALUE)
         {
            return 0;
         }
         var _loc2_:Number = 1 / _loc1_;
         this.x *= _loc2_;
         this.y *= _loc2_;
         return _loc1_;
      }
      
      public function IsValid() : Boolean
      {
         return b2Math.IsValid(this.x) && b2Math.IsValid(this.y);
      }
   }
}

