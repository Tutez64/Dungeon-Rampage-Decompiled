package Box2D.Common.Math
{
   import box2dcompat.As3Array;
   
   public class b2Math
   {
      
      public static var MIN_VALUE:Number;
      
      public static var MAX_VALUE:Number;
      
      public static var b2Vec2_zero:b2Vec2 = new b2Vec2(0,0);
      
      public static var b2Mat22_identity:b2Mat22 = b2Mat22.fromVV(new b2Vec2(1,0),new b2Vec2(0,1));
      
      public static var b2Transform_identity:b2Transform = new b2Transform(b2Math.b2Vec2_zero,b2Math.b2Mat22_identity);
      
      public function b2Math()
      {
      }
      
      public static function isValid(x:Number) : Boolean
      {
         if(Math.isNaN(x) || x == Number(Math.NEGATIVE_INFINITY) || x == Number(Math.POSITIVE_INFINITY))
         {
            return false;
         }
         return true;
      }
      
      public static function dot(a:b2Vec2, b:b2Vec2) : Number
      {
         return a.x * b.x + a.y * b.y;
      }
      
      public static function crossVV(a:b2Vec2, b:b2Vec2) : Number
      {
         return a.x * b.y - a.y * b.x;
      }
      
      public static function crossVF(a:b2Vec2, s:Number) : b2Vec2
      {
         return new b2Vec2(s * a.y,-s * a.x);
      }
      
      public static function crossFV(s:Number, a:b2Vec2) : b2Vec2
      {
         return new b2Vec2(-s * a.y,s * a.x);
      }
      
      public static function mulMV(A:b2Mat22, v:b2Vec2) : b2Vec2
      {
         return new b2Vec2(A.col1.x * v.x + A.col2.x * v.y,A.col1.y * v.x + A.col2.y * v.y);
      }
      
      public static function mulTMV(A:b2Mat22, v:b2Vec2) : b2Vec2
      {
         return new b2Vec2(b2Math.dot(v,A.col1),b2Math.dot(v,A.col2));
      }
      
      public static function mulX(T:b2Transform, v:b2Vec2) : b2Vec2
      {
         var _loc3_:b2Vec2 = b2Math.mulMV(T.R,v);
         _loc3_.x += T.position.x;
         _loc3_.y += T.position.y;
         return _loc3_;
      }
      
      public static function mulXT(T:b2Transform, v:b2Vec2) : b2Vec2
      {
         var _loc3_:b2Vec2 = b2Math.subtractVV(v,T.position);
         var _loc4_:Number = _loc3_.x * T.R.col1.x + _loc3_.y * T.R.col1.y;
         _loc3_.y = _loc3_.x * T.R.col2.x + _loc3_.y * T.R.col2.y;
         _loc3_.x = _loc4_;
         return _loc3_;
      }
      
      public static function addVV(a:b2Vec2, b:b2Vec2) : b2Vec2
      {
         return new b2Vec2(a.x + b.x,a.y + b.y);
      }
      
      public static function subtractVV(a:b2Vec2, b:b2Vec2) : b2Vec2
      {
         return new b2Vec2(a.x - b.x,a.y - b.y);
      }
      
      public static function distance(a:b2Vec2, b:b2Vec2) : Number
      {
         var _loc3_:Number = a.x - b.x;
         var _loc4_:Number = a.y - b.y;
         return Math.sqrt(_loc3_ * _loc3_ + _loc4_ * _loc4_);
      }
      
      public static function distanceSquared(a:b2Vec2, b:b2Vec2) : Number
      {
         var _loc3_:Number = a.x - b.x;
         var _loc4_:Number = a.y - b.y;
         return _loc3_ * _loc3_ + _loc4_ * _loc4_;
      }
      
      public static function mulFV(s:Number, a:b2Vec2) : b2Vec2
      {
         return new b2Vec2(s * a.x,s * a.y);
      }
      
      public static function addMM(A:b2Mat22, B:b2Mat22) : b2Mat22
      {
         return b2Mat22.fromVV(b2Math.addVV(A.col1,B.col1),b2Math.addVV(A.col2,B.col2));
      }
      
      public static function mulMM(A:b2Mat22, B:b2Mat22) : b2Mat22
      {
         return b2Mat22.fromVV(b2Math.mulMV(A,B.col1),b2Math.mulMV(A,B.col2));
      }
      
      public static function mulTMM(A:b2Mat22, B:b2Mat22) : b2Mat22
      {
         var _loc3_:b2Vec2 = new b2Vec2(b2Math.dot(A.col1,B.col1),b2Math.dot(A.col2,B.col1));
         var _loc4_:b2Vec2 = new b2Vec2(b2Math.dot(A.col1,B.col2),b2Math.dot(A.col2,B.col2));
         return b2Mat22.fromVV(_loc3_,_loc4_);
      }
      
      public static function abs(a:Number) : Number
      {
         if(a > 0)
         {
            return a;
         }
         return -a;
      }
      
      public static function absV(a:b2Vec2) : b2Vec2
      {
         return new b2Vec2(b2Math.abs(a.x),b2Math.abs(a.y));
      }
      
      public static function absM(A:b2Mat22) : b2Mat22
      {
         return b2Mat22.fromVV(b2Math.absV(A.col1),b2Math.absV(A.col2));
      }
      
      public static function min(a:Number, b:Number) : Number
      {
         if(a < b)
         {
            return a;
         }
         return b;
      }
      
      public static function minV(a:b2Vec2, b:b2Vec2) : b2Vec2
      {
         return new b2Vec2(b2Math.min(a.x,b.x),b2Math.min(a.y,b.y));
      }
      
      public static function max(a:Number, b:Number) : Number
      {
         if(a > b)
         {
            return a;
         }
         return b;
      }
      
      public static function maxV(a:b2Vec2, b:b2Vec2) : b2Vec2
      {
         return new b2Vec2(b2Math.max(a.x,b.x),b2Math.max(a.y,b.y));
      }
      
      public static function clamp(a:Number, low:Number, high:Number) : Number
      {
         if(a < low)
         {
            return low;
         }
         if(a > high)
         {
            return high;
         }
         return a;
      }
      
      public static function clampV(a:b2Vec2, low:b2Vec2, high:b2Vec2) : b2Vec2
      {
         return b2Math.maxV(low,b2Math.minV(a,high));
      }
      
      public static function swap(a:Array, b:Array) : void
      {
         var _loc3_:* = a[0];
         a[0] = b[0];
         b[0] = _loc3_;
      }
      
      public static function random() : Number
      {
         return Math.random() * 2 - 1;
      }
      
      public static function randomRange(lo:Number, hi:Number) : Number
      {
         var _loc3_:Number = Math.random();
         return (hi - lo) * _loc3_ + lo;
      }
      
      public static function nextPowerOfTwo(x:int) : int
      {
         x |= x >> 1 & 0x7FFFFFFF;
         x |= x >> 2 & 0x3FFFFFFF;
         x |= x >> 4 & 0x0FFFFFFF;
         x |= x >> 8 & 0xFFFFFF;
         x |= x >> 16 & 0xFFFF;
         return x + 1;
      }
      
      public static function isPowerOfTwo(x:int) : Boolean
      {
         return x > 0 && (x & x - 1) == 0;
      }
      
      public static function get_MIN_VALUE() : Number
      {
         return Number(Number.MIN_VALUE);
      }
      
      public static function get_MAX_VALUE() : Number
      {
         return Number(Number.MAX_VALUE);
      }
      
      public static function IsValid(x:Number) : Boolean
      {
         return b2Math.isValid(x);
      }
      
      public static function Dot(a:b2Vec2, b:b2Vec2) : Number
      {
         return b2Math.dot(a,b);
      }
      
      public static function CrossVV(a:b2Vec2, b:b2Vec2) : Number
      {
         return b2Math.crossVV(a,b);
      }
      
      public static function CrossVF(a:b2Vec2, s:Number) : b2Vec2
      {
         return b2Math.crossVF(a,s);
      }
      
      public static function CrossFV(s:Number, a:b2Vec2) : b2Vec2
      {
         return b2Math.crossFV(s,a);
      }
      
      public static function MulMV(A:b2Mat22, v:b2Vec2) : b2Vec2
      {
         return b2Math.mulMV(A,v);
      }
      
      public static function MulTMV(A:b2Mat22, v:b2Vec2) : b2Vec2
      {
         return b2Math.mulTMV(A,v);
      }
      
      public static function MulX(T:b2Transform, v:b2Vec2) : b2Vec2
      {
         return b2Math.mulX(T,v);
      }
      
      public static function MulXT(T:b2Transform, v:b2Vec2) : b2Vec2
      {
         return b2Math.mulXT(T,v);
      }
      
      public static function AddVV(a:b2Vec2, b:b2Vec2) : b2Vec2
      {
         return b2Math.addVV(a,b);
      }
      
      public static function SubtractVV(a:b2Vec2, b:b2Vec2) : b2Vec2
      {
         return b2Math.subtractVV(a,b);
      }
      
      public static function Distance(a:b2Vec2, b:b2Vec2) : Number
      {
         return b2Math.distance(a,b);
      }
      
      public static function DistanceSquared(a:b2Vec2, b:b2Vec2) : Number
      {
         return b2Math.distanceSquared(a,b);
      }
      
      public static function MulFV(s:Number, a:b2Vec2) : b2Vec2
      {
         return b2Math.mulFV(s,a);
      }
      
      public static function AddMM(A:b2Mat22, B:b2Mat22) : b2Mat22
      {
         return b2Math.addMM(A,B);
      }
      
      public static function MulMM(A:b2Mat22, B:b2Mat22) : b2Mat22
      {
         return b2Math.mulMM(A,B);
      }
      
      public static function MulTMM(A:b2Mat22, B:b2Mat22) : b2Mat22
      {
         return b2Math.mulTMM(A,B);
      }
      
      public static function Abs(a:Number) : Number
      {
         return b2Math.abs(a);
      }
      
      public static function AbsV(a:b2Vec2) : b2Vec2
      {
         return b2Math.absV(a);
      }
      
      public static function AbsM(A:b2Mat22) : b2Mat22
      {
         return b2Math.absM(A);
      }
      
      public static function Min(a:Number, b:Number) : Number
      {
         return b2Math.min(a,b);
      }
      
      public static function MinV(a:b2Vec2, b:b2Vec2) : b2Vec2
      {
         return b2Math.minV(a,b);
      }
      
      public static function Max(a:Number, b:Number) : Number
      {
         return b2Math.max(a,b);
      }
      
      public static function MaxV(a:b2Vec2, b:b2Vec2) : b2Vec2
      {
         return b2Math.maxV(a,b);
      }
      
      public static function Clamp(a:Number, low:Number, high:Number) : Number
      {
         return b2Math.clamp(a,low,high);
      }
      
      public static function ClampV(a:b2Vec2, low:b2Vec2, high:b2Vec2) : b2Vec2
      {
         return b2Math.clampV(a,low,high);
      }
      
      public static function Swap(a:*, b:*) : void
      {
         b2Math.swap(As3Array.of(a),As3Array.of(b));
      }
      
      public static function Random() : Number
      {
         return b2Math.random();
      }
      
      public static function RandomRange(lo:Number, hi:Number) : Number
      {
         return b2Math.randomRange(lo,hi);
      }
      
      public static function NextPowerOfTwo(x:int) : int
      {
         return b2Math.nextPowerOfTwo(x);
      }
      
      public static function IsPowerOfTwo(x:int) : Boolean
      {
         return b2Math.isPowerOfTwo(x);
      }
   }
}

