package Box2D.Common.Math
{
   public class b2Math
   {
      
      public static const b2Vec2_zero:b2Vec2 = new b2Vec2(0,0);
      
      public static const b2Mat22_identity:b2Mat22 = b2Mat22.FromVV(new b2Vec2(1,0),new b2Vec2(0,1));
      
      public static const b2Transform_identity:b2Transform = new b2Transform(b2Vec2_zero,b2Mat22_identity);
      
      public function b2Math()
      {
         super();
      }
      
      public static function IsValid(x:Number) : Boolean
      {
         return isFinite(x);
      }
      
      public static function Dot(a:b2Vec2, b:b2Vec2) : Number
      {
         return a.x * b.x + a.y * b.y;
      }
      
      public static function CrossVV(a:b2Vec2, b:b2Vec2) : Number
      {
         return a.x * b.y - a.y * b.x;
      }
      
      public static function CrossVF(a:b2Vec2, s:Number) : b2Vec2
      {
         return new b2Vec2(s * a.y,-s * a.x);
      }
      
      public static function CrossFV(s:Number, a:b2Vec2) : b2Vec2
      {
         return new b2Vec2(-s * a.y,s * a.x);
      }
      
      public static function MulMV(A:b2Mat22, v:b2Vec2) : b2Vec2
      {
         return new b2Vec2(A.col1.x * v.x + A.col2.x * v.y,A.col1.y * v.x + A.col2.y * v.y);
      }
      
      public static function MulTMV(A:b2Mat22, v:b2Vec2) : b2Vec2
      {
         return new b2Vec2(Dot(v,A.col1),Dot(v,A.col2));
      }
      
      public static function MulX(T:b2Transform, v:b2Vec2) : b2Vec2
      {
         var _loc3_:b2Vec2 = null;
         _loc3_ = MulMV(T.R,v);
         _loc3_.x += T.position.x;
         _loc3_.y += T.position.y;
         return _loc3_;
      }
      
      public static function MulXT(T:b2Transform, v:b2Vec2) : b2Vec2
      {
         var _loc3_:b2Vec2 = null;
         var _loc4_:Number = NaN;
         _loc3_ = SubtractVV(v,T.position);
         _loc4_ = _loc3_.x * T.R.col1.x + _loc3_.y * T.R.col1.y;
         _loc3_.y = _loc3_.x * T.R.col2.x + _loc3_.y * T.R.col2.y;
         _loc3_.x = _loc4_;
         return _loc3_;
      }
      
      public static function AddVV(a:b2Vec2, b:b2Vec2) : b2Vec2
      {
         return new b2Vec2(a.x + b.x,a.y + b.y);
      }
      
      public static function SubtractVV(a:b2Vec2, b:b2Vec2) : b2Vec2
      {
         return new b2Vec2(a.x - b.x,a.y - b.y);
      }
      
      public static function Distance(a:b2Vec2, b:b2Vec2) : Number
      {
         var _loc3_:Number = a.x - b.x;
         var _loc4_:Number = a.y - b.y;
         return Math.sqrt(_loc3_ * _loc3_ + _loc4_ * _loc4_);
      }
      
      public static function DistanceSquared(a:b2Vec2, b:b2Vec2) : Number
      {
         var _loc3_:Number = a.x - b.x;
         var _loc4_:Number = a.y - b.y;
         return _loc3_ * _loc3_ + _loc4_ * _loc4_;
      }
      
      public static function MulFV(s:Number, a:b2Vec2) : b2Vec2
      {
         return new b2Vec2(s * a.x,s * a.y);
      }
      
      public static function AddMM(A:b2Mat22, B:b2Mat22) : b2Mat22
      {
         return b2Mat22.FromVV(AddVV(A.col1,B.col1),AddVV(A.col2,B.col2));
      }
      
      public static function MulMM(A:b2Mat22, B:b2Mat22) : b2Mat22
      {
         return b2Mat22.FromVV(MulMV(A,B.col1),MulMV(A,B.col2));
      }
      
      public static function MulTMM(A:b2Mat22, B:b2Mat22) : b2Mat22
      {
         var _loc3_:b2Vec2 = new b2Vec2(Dot(A.col1,B.col1),Dot(A.col2,B.col1));
         var _loc4_:b2Vec2 = new b2Vec2(Dot(A.col1,B.col2),Dot(A.col2,B.col2));
         return b2Mat22.FromVV(_loc3_,_loc4_);
      }
      
      public static function Abs(a:Number) : Number
      {
         return a > 0 ? a : -a;
      }
      
      public static function AbsV(a:b2Vec2) : b2Vec2
      {
         return new b2Vec2(Abs(a.x),Abs(a.y));
      }
      
      public static function AbsM(A:b2Mat22) : b2Mat22
      {
         return b2Mat22.FromVV(AbsV(A.col1),AbsV(A.col2));
      }
      
      public static function Min(a:Number, b:Number) : Number
      {
         return a < b ? a : b;
      }
      
      public static function MinV(a:b2Vec2, b:b2Vec2) : b2Vec2
      {
         return new b2Vec2(Min(a.x,b.x),Min(a.y,b.y));
      }
      
      public static function Max(a:Number, b:Number) : Number
      {
         return a > b ? a : b;
      }
      
      public static function MaxV(a:b2Vec2, b:b2Vec2) : b2Vec2
      {
         return new b2Vec2(Max(a.x,b.x),Max(a.y,b.y));
      }
      
      public static function Clamp(a:Number, low:Number, high:Number) : Number
      {
         return a < low ? low : (a > high ? high : a);
      }
      
      public static function ClampV(a:b2Vec2, low:b2Vec2, high:b2Vec2) : b2Vec2
      {
         return MaxV(low,MinV(a,high));
      }
      
      public static function Swap(a:Array, b:Array) : void
      {
         var _loc3_:* = a[0];
         a[0] = b[0];
         b[0] = _loc3_;
      }
      
      public static function Random() : Number
      {
         return Math.random() * 2 - 1;
      }
      
      public static function RandomRange(lo:Number, hi:Number) : Number
      {
         var _loc3_:Number = Math.random();
         return (hi - lo) * _loc3_ + lo;
      }
      
      public static function NextPowerOfTwo(x:uint) : uint
      {
         x |= x >> 1 & 0x7FFFFFFF;
         x |= x >> 2 & 0x3FFFFFFF;
         x |= x >> 4 & 0x0FFFFFFF;
         x |= x >> 8 & 0xFFFFFF;
         x |= x >> 16 & 0xFFFF;
         return x + 1;
      }
      
      public static function IsPowerOfTwo(x:uint) : Boolean
      {
         return x > 0 && (x & x - 1) == 0;
      }
   }
}

