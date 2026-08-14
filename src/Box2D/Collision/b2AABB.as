package Box2D.Collision
{
   import Box2D.Common.Math.b2Vec2;
   
   public class b2AABB
   {
      
      public var lowerBound:b2Vec2 = new b2Vec2();
      
      public var upperBound:b2Vec2 = new b2Vec2();
      
      public function b2AABB()
      {
         super();
      }
      
      public static function Combine(aabb1:b2AABB, aabb2:b2AABB) : b2AABB
      {
         var _loc3_:b2AABB = new b2AABB();
         _loc3_.Combine(aabb1,aabb2);
         return _loc3_;
      }
      
      public function IsValid() : Boolean
      {
         var _loc1_:Number = this.upperBound.x - this.lowerBound.x;
         var _loc2_:Number = this.upperBound.y - this.lowerBound.y;
         var _loc3_:Boolean = _loc1_ >= 0 && _loc2_ >= 0;
         return _loc3_ && this.lowerBound.IsValid() && this.upperBound.IsValid();
      }
      
      public function GetCenter() : b2Vec2
      {
         return new b2Vec2((this.lowerBound.x + this.upperBound.x) / 2,(this.lowerBound.y + this.upperBound.y) / 2);
      }
      
      public function GetExtents() : b2Vec2
      {
         return new b2Vec2((this.upperBound.x - this.lowerBound.x) / 2,(this.upperBound.y - this.lowerBound.y) / 2);
      }
      
      public function Contains(aabb:b2AABB) : Boolean
      {
         var _loc2_:Boolean = true;
         _loc2_ &&= this.lowerBound.x <= aabb.lowerBound.x;
         _loc2_ &&= this.lowerBound.y <= aabb.lowerBound.y;
         _loc2_ &&= aabb.upperBound.x <= this.upperBound.x;
         return _loc2_ && aabb.upperBound.y <= this.upperBound.y;
      }
      
      public function RayCast(output:b2RayCastOutput, input:b2RayCastInput) : Boolean
      {
         var _loc11_:b2Vec2 = null;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc3_:Number = -Number.MAX_VALUE;
         var _loc4_:Number = Number.MAX_VALUE;
         var _loc5_:Number = input.p1.x;
         var _loc6_:Number = input.p1.y;
         var _loc7_:Number = input.p2.x - input.p1.x;
         var _loc8_:Number = input.p2.y - input.p1.y;
         var _loc9_:Number = Math.abs(_loc7_);
         var _loc10_:Number = Math.abs(_loc8_);
         _loc11_ = output.normal;
         if(_loc9_ < Number.MIN_VALUE)
         {
            if(_loc5_ < this.lowerBound.x || this.upperBound.x < _loc5_)
            {
               return false;
            }
         }
         else
         {
            _loc12_ = 1 / _loc7_;
            _loc13_ = (this.lowerBound.x - _loc5_) * _loc12_;
            _loc14_ = (this.upperBound.x - _loc5_) * _loc12_;
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
         if(_loc10_ < Number.MIN_VALUE)
         {
            if(_loc6_ < this.lowerBound.y || this.upperBound.y < _loc6_)
            {
               return false;
            }
         }
         else
         {
            _loc12_ = 1 / _loc8_;
            _loc13_ = (this.lowerBound.y - _loc6_) * _loc12_;
            _loc14_ = (this.upperBound.y - _loc6_) * _loc12_;
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
      
      public function TestOverlap(other:b2AABB) : Boolean
      {
         var _loc2_:Number = other.lowerBound.x - this.upperBound.x;
         var _loc3_:Number = other.lowerBound.y - this.upperBound.y;
         var _loc4_:Number = this.lowerBound.x - other.upperBound.x;
         var _loc5_:Number = this.lowerBound.y - other.upperBound.y;
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
      
      public function Combine(aabb1:b2AABB, aabb2:b2AABB) : void
      {
         this.lowerBound.x = Math.min(aabb1.lowerBound.x,aabb2.lowerBound.x);
         this.lowerBound.y = Math.min(aabb1.lowerBound.y,aabb2.lowerBound.y);
         this.upperBound.x = Math.max(aabb1.upperBound.x,aabb2.upperBound.x);
         this.upperBound.y = Math.max(aabb1.upperBound.y,aabb2.upperBound.y);
      }
   }
}

