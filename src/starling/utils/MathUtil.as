package starling.utils
{
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import starling.errors.AbstractClassError;
   
   public class MathUtil
   {
      
      private static const TWO_PI:Number = 6.283185307179586;
      
      public function MathUtil()
      {
         super();
         throw new AbstractClassError();
      }
      
      public static function intersectLineWithXYPlane(pointA:Vector3D, pointB:Vector3D, out:Point = null) : Point
      {
         if(out == null)
         {
            out = new Point();
         }
         var _loc7_:Number = pointB.x - pointA.x;
         var _loc5_:Number = pointB.y - pointA.y;
         var _loc6_:Number = pointB.z - pointA.z;
         var _loc4_:Number = -pointA.z / _loc6_;
         out.x = pointA.x + _loc4_ * _loc7_;
         out.y = pointA.y + _loc4_ * _loc5_;
         return out;
      }
      
      public static function isPointInTriangle(p:Point, a:Point, b:Point, c:Point) : Boolean
      {
         var _loc15_:Number = c.x - a.x;
         var _loc13_:Number = c.y - a.y;
         var _loc8_:Number = b.x - a.x;
         var _loc16_:Number = b.y - a.y;
         var _loc12_:Number = p.x - a.x;
         var _loc9_:Number = p.y - a.y;
         var _loc10_:Number = _loc15_ * _loc15_ + _loc13_ * _loc13_;
         var _loc17_:Number = _loc15_ * _loc8_ + _loc13_ * _loc16_;
         var _loc14_:Number = _loc15_ * _loc12_ + _loc13_ * _loc9_;
         var _loc11_:Number = _loc8_ * _loc8_ + _loc16_ * _loc16_;
         var _loc18_:Number = _loc8_ * _loc12_ + _loc16_ * _loc9_;
         var _loc5_:Number = 1 / (_loc10_ * _loc11_ - _loc17_ * _loc17_);
         var _loc6_:Number = (_loc11_ * _loc14_ - _loc17_ * _loc18_) * _loc5_;
         var _loc7_:Number = (_loc10_ * _loc18_ - _loc17_ * _loc14_) * _loc5_;
         return _loc6_ >= 0 && _loc7_ >= 0 && _loc6_ + _loc7_ < 1;
      }
      
      public static function normalizeAngle(angle:Number) : Number
      {
         angle %= 6.283185307179586;
         if(angle < -3.141592653589793)
         {
            angle += 6.283185307179586;
         }
         if(angle > 3.141592653589793)
         {
            angle -= 6.283185307179586;
         }
         return angle;
      }
      
      public static function getNextPowerOfTwo(number:Number) : int
      {
         var _loc2_:int = 0;
         if(number is int && number > 0 && (number & number - 1) == 0)
         {
            return number;
         }
         _loc2_ = 1;
         number -= 1e-9;
         while(_loc2_ < number)
         {
            _loc2_ <<= 1;
         }
         return _loc2_;
      }
      
      public static function isEquivalent(a:Number, b:Number, epsilon:Number = 0.0001) : Boolean
      {
         return a - epsilon < b && a + epsilon > b;
      }
      
      public static function max(a:Number, b:Number) : Number
      {
         return a > b ? a : b;
      }
      
      public static function min(a:Number, b:Number) : Number
      {
         return a < b ? a : b;
      }
      
      public static function clamp(value:Number, min:Number, max:Number) : Number
      {
         return value < min ? min : (value > max ? max : value);
      }
   }
}

