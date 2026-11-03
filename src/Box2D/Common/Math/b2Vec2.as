package Box2D.Common.Math
{
   import flash.Boot;
   
   public class b2Vec2
   {
      
      public var y:Number;
      
      public var x:Number;
      
      public function b2Vec2(x_:Number = 0, y_:Number = 0)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         x = x_;
         y = y_;
      }
      
      public static function make(x_:Number, y_:Number) : b2Vec2
      {
         return new b2Vec2(x_,y_);
      }
      
      public static function Make(x_:Number, y_:Number) : b2Vec2
      {
         return b2Vec2.make(x_,y_);
      }
      
      public function subtract(v:b2Vec2) : void
      {
         Subtract(v);
      }
      
      public function setZero() : void
      {
         SetZero();
      }
      
      public function setV(v:b2Vec2) : void
      {
         SetV(v);
      }
      
      public function set(x_:Number = 0, y_:Number = 0) : void
      {
         Set(x_,y_);
      }
      
      public function normalize() : Number
      {
         return Normalize();
      }
      
      public function negativeSelf() : void
      {
         NegativeSelf();
      }
      
      public function multiply(a:Number) : void
      {
         Multiply(a);
      }
      
      public function mulTM(A:b2Mat22) : void
      {
         MulTM(A);
      }
      
      public function mulM(A:b2Mat22) : void
      {
         MulM(A);
      }
      
      public function minV(b:b2Vec2) : void
      {
         MinV(b);
      }
      
      public function maxV(b:b2Vec2) : void
      {
         MaxV(b);
      }
      
      public function lengthSquared() : Number
      {
         return LengthSquared();
      }
      
      public function length() : Number
      {
         return Length();
      }
      
      public function isValid() : Boolean
      {
         return IsValid();
      }
      
      public function getNegative() : b2Vec2
      {
         return GetNegative();
      }
      
      public function crossVF(s:Number) : void
      {
         CrossVF(s);
      }
      
      public function crossFV(s:Number) : void
      {
         CrossFV(s);
      }
      
      public function copy() : b2Vec2
      {
         return Copy();
      }
      
      public function add(v:b2Vec2) : void
      {
         Add(v);
      }
      
      public function abs() : void
      {
         Abs();
      }
      
      public function Subtract(v:b2Vec2) : void
      {
         x -= v.x;
         y -= v.y;
      }
      
      public function SetZero() : void
      {
         x = 0;
         y = 0;
      }
      
      public function SetV(v:b2Vec2) : void
      {
         x = v.x;
         y = v.y;
      }
      
      public function Set(x_:Number = 0, y_:Number = 0) : void
      {
         x = x_;
         y = y_;
      }
      
      public function Normalize() : Number
      {
         var _loc1_:Number = Math.sqrt(x * x + y * y);
         if(_loc1_ < Number(Number.MIN_VALUE))
         {
            return 0;
         }
         var _loc2_:Number = 1 / _loc1_;
         x *= _loc2_;
         y *= _loc2_;
         return _loc1_;
      }
      
      public function NegativeSelf() : void
      {
         x = -x;
         y = -y;
      }
      
      public function Multiply(a:Number) : void
      {
         x *= a;
         y *= a;
      }
      
      public function MulTM(A:b2Mat22) : void
      {
         var _loc2_:Number = b2Math.dot(this,A.col1);
         y = b2Math.dot(this,A.col2);
         x = _loc2_;
      }
      
      public function MulM(A:b2Mat22) : void
      {
         var _loc2_:Number = x;
         x = A.col1.x * _loc2_ + A.col2.x * y;
         y = A.col1.y * _loc2_ + A.col2.y * y;
      }
      
      public function MinV(b:b2Vec2) : void
      {
         x = x < b.x ? x : b.x;
         y = y < b.y ? y : b.y;
      }
      
      public function MaxV(b:b2Vec2) : void
      {
         x = x > b.x ? x : b.x;
         y = y > b.y ? y : b.y;
      }
      
      public function LengthSquared() : Number
      {
         return x * x + y * y;
      }
      
      public function Length() : Number
      {
         return Math.sqrt(x * x + y * y);
      }
      
      public function IsValid() : Boolean
      {
         if(b2Math.isValid(x))
         {
            return b2Math.isValid(y);
         }
         return false;
      }
      
      public function GetNegative() : b2Vec2
      {
         return new b2Vec2(-x,-y);
      }
      
      public function CrossVF(s:Number) : void
      {
         var _loc2_:Number = x;
         x = s * y;
         y = -s * _loc2_;
      }
      
      public function CrossFV(s:Number) : void
      {
         var _loc2_:Number = x;
         x = -s * y;
         y = s * _loc2_;
      }
      
      public function Copy() : b2Vec2
      {
         return new b2Vec2(x,y);
      }
      
      public function Add(v:b2Vec2) : void
      {
         x += v.x;
         y += v.y;
      }
      
      public function Abs() : void
      {
         if(x < 0)
         {
            x = -x;
         }
         if(y < 0)
         {
            y = -y;
         }
      }
   }
}

