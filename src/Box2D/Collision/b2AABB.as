package Box2D.Collision
{
   import Box2D.Common.Math.b2Vec2;
   import flash.Boot;
   
   public class b2AABB
   {
      
      public var upperBound:b2Vec2;
      
      public var lowerBound:b2Vec2;
      
      public function b2AABB()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         lowerBound = new b2Vec2();
         upperBound = new b2Vec2();
      }
      
      public function testOverlap(other:b2AABB) : Boolean
      {
         return TestOverlap(other);
      }
      
      public function rayCast(output:b2RayCastOutput, input:b2RayCastInput) : Boolean
      {
         return RayCast(output,input);
      }
      
      public function isValid() : Boolean
      {
         return IsValid();
      }
      
      public function getExtents() : b2Vec2
      {
         return GetExtents();
      }
      
      public function getCenter() : b2Vec2
      {
         return GetCenter();
      }
      
      public function contains(aabb:b2AABB) : Boolean
      {
         return Contains(aabb);
      }
      
      public function combine(aabb1:b2AABB, aabb2:b2AABB) : void
      {
         Combine(aabb1,aabb2);
      }
      
      public function TestOverlap(other:b2AABB) : Boolean
      {
         var _loc2_:Number = other.lowerBound.x - upperBound.x;
         var _loc3_:Number = other.lowerBound.y - upperBound.y;
         var _loc4_:Number = lowerBound.x - other.upperBound.x;
         var _loc5_:Number = lowerBound.y - other.upperBound.y;
         if(_loc2_ > 0 || _loc3_ > 0)
         {
            return false;
         }
         if(_loc4_ > 0 || _loc5_ > 0)
         {
            return false;
         }
         return true;
      }
      
      public function RayCast(output:b2RayCastOutput, input:b2RayCastInput) : Boolean
      {
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc3_:Number = -Number(Number.MAX_VALUE);
         var _loc4_:Number = Number(Number.MAX_VALUE);
         var _loc5_:Number = input.p1.x;
         var _loc6_:Number = input.p1.y;
         var _loc7_:Number = input.p2.x - input.p1.x;
         var _loc8_:Number = input.p2.y - input.p1.y;
         var _loc9_:Number = Math.abs(_loc7_);
         var _loc10_:Number = Math.abs(_loc8_);
         var _loc11_:b2Vec2 = output.normal;
         if(_loc9_ < Number(Number.MIN_VALUE))
         {
            if(_loc5_ < lowerBound.x || upperBound.x < _loc5_)
            {
               return false;
            }
         }
         else
         {
            _loc12_ = 1 / _loc7_;
            _loc13_ = (lowerBound.x - _loc5_) * _loc12_;
            _loc14_ = (upperBound.x - _loc5_) * _loc12_;
            _loc16_ = -1;
            if(_loc13_ > _loc14_)
            {
               _loc15_ = _loc13_;
               _loc13_ = _loc14_;
               _loc14_ = _loc15_;
               _loc16_ = 1;
            }
            if(_loc13_ > _loc3_)
            {
               _loc11_.x = _loc16_;
               _loc11_.y = 0;
               _loc3_ = _loc13_;
            }
            _loc4_ = Math.min(_loc4_,_loc14_);
            if(_loc3_ > _loc4_)
            {
               return false;
            }
         }
         if(_loc10_ < Number(Number.MIN_VALUE))
         {
            if(_loc6_ < lowerBound.y || upperBound.y < _loc6_)
            {
               return false;
            }
         }
         else
         {
            _loc12_ = 1 / _loc8_;
            _loc13_ = (lowerBound.y - _loc6_) * _loc12_;
            _loc14_ = (upperBound.y - _loc6_) * _loc12_;
            _loc16_ = -1;
            if(_loc13_ > _loc14_)
            {
               _loc15_ = _loc13_;
               _loc13_ = _loc14_;
               _loc14_ = _loc15_;
               _loc16_ = 1;
            }
            if(_loc13_ > _loc3_)
            {
               _loc11_.y = _loc16_;
               _loc11_.x = 0;
               _loc3_ = _loc13_;
            }
            _loc4_ = Math.min(_loc4_,_loc14_);
            if(_loc3_ > _loc4_)
            {
               return false;
            }
         }
         output.fraction = _loc3_;
         return true;
      }
      
      public function IsValid() : Boolean
      {
         var _loc1_:Number = upperBound.x - lowerBound.x;
         var _loc2_:Number = upperBound.y - lowerBound.y;
         var _loc3_:Boolean = _loc1_ >= 0 && _loc2_ >= 0;
         return _loc3_ && lowerBound.isValid() && upperBound.isValid();
      }
      
      public function GetExtents() : b2Vec2
      {
         return new b2Vec2((upperBound.x - lowerBound.x) / 2,(upperBound.y - lowerBound.y) / 2);
      }
      
      public function GetCenter() : b2Vec2
      {
         return new b2Vec2((lowerBound.x + upperBound.x) / 2,(lowerBound.y + upperBound.y) / 2);
      }
      
      public function Contains(aabb:b2AABB) : Boolean
      {
         var _loc2_:Boolean = true;
         _loc2_ &&= lowerBound.x <= aabb.lowerBound.x;
         _loc2_ &&= lowerBound.y <= aabb.lowerBound.y;
         _loc2_ &&= aabb.upperBound.x <= upperBound.x;
         return _loc2_ && aabb.upperBound.y <= upperBound.y;
      }
      
      public function Combine(aabb1:b2AABB, aabb2:b2AABB) : void
      {
         lowerBound.x = Math.min(aabb1.lowerBound.x,aabb2.lowerBound.x);
         lowerBound.y = Math.min(aabb1.lowerBound.y,aabb2.lowerBound.y);
         upperBound.x = Math.max(aabb1.upperBound.x,aabb2.upperBound.x);
         upperBound.y = Math.max(aabb1.upperBound.y,aabb2.upperBound.y);
      }
   }
}

