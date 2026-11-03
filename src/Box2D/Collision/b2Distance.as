package Box2D.Collision
{
   import Box2D.Common.Math.b2Math;
   import Box2D.Common.Math.b2Transform;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Common.b2Settings;
   
   public class b2Distance
   {
      
      public static var b2_gjkCalls:int = 0;
      
      public static var b2_gjkIters:int = 0;
      
      public static var b2_gjkMaxIters:int = 0;
      
      public static var s_simplex:b2Simplex = new b2Simplex();
      
      public static var s_saveA:Array = [];
      
      public static var s_saveB:Array = [];
      
      public function b2Distance()
      {
      }
      
      public static function distance(output:b2DistanceOutput, cache:b2SimplexCache, input:b2DistanceInput) : void
      {
         var _loc18_:* = null as b2Vec2;
         var _loc20_:int = 0;
         var _loc21_:int = 0;
         var _loc22_:int = 0;
         var _loc23_:Boolean = false;
         var _loc24_:* = null as b2Vec2;
         var _loc25_:* = null as b2SimplexVertex;
         var _loc26_:Boolean = false;
         var _loc27_:Number = NaN;
         var _loc28_:Number = NaN;
         var _loc29_:Number = NaN;
         ++b2Distance.b2_gjkCalls;
         var _loc4_:b2DistanceProxy = input.proxyA;
         var _loc5_:b2DistanceProxy = input.proxyB;
         var _loc6_:b2Transform = input.transformA;
         var _loc7_:b2Transform = input.transformB;
         var _loc8_:b2Simplex = b2Distance.s_simplex;
         _loc8_.readCache(cache,_loc4_,_loc6_,_loc5_,_loc7_);
         var _loc9_:Array = _loc8_.m_vertices;
         var _loc10_:int = 20;
         var _loc11_:Array = b2Distance.s_saveA;
         var _loc12_:Array = b2Distance.s_saveB;
         var _loc13_:int = 0;
         var _loc14_:b2Vec2 = _loc8_.getClosestPoint();
         var _loc15_:Number;
         var _loc16_:Number = _loc15_ = _loc14_.lengthSquared();
         var _loc19_:int = 0;
         while(_loc19_ < _loc10_)
         {
            _loc13_ = _loc8_.m_count;
            _loc20_ = 0;
            _loc21_ = _loc13_;
            while(_loc20_ < _loc21_)
            {
               _loc22_ = _loc20_++;
               _loc11_[_loc22_] = _loc9_[_loc22_].indexA;
               _loc12_[_loc22_] = _loc9_[_loc22_].indexB;
            }
            switch(_loc8_.m_count)
            {
               case 1:
                  break;
               case 2:
                  _loc8_.solve2();
                  break;
               case 3:
                  _loc8_.solve3();
                  break;
               default:
                  b2Settings.b2Assert(false);
            }
            if(_loc8_.m_count == 3)
            {
               break;
            }
            _loc18_ = _loc8_.getClosestPoint();
            _loc16_ = _loc18_.lengthSquared();
            _loc23_ = _loc16_ > _loc15_;
            _loc15_ = _loc16_;
            _loc24_ = _loc8_.getSearchDirection();
            if(_loc24_.lengthSquared() < Number(Number.MIN_VALUE) * Number(Number.MIN_VALUE))
            {
               break;
            }
            _loc25_ = _loc9_[_loc8_.m_count];
            _loc25_.indexA = int(_loc4_.getSupport(b2Math.mulTMV(_loc6_.R,_loc24_.getNegative())));
            _loc25_.wA = b2Math.mulX(_loc6_,_loc4_.getVertex(_loc25_.indexA));
            _loc25_.indexB = int(_loc5_.getSupport(b2Math.mulTMV(_loc7_.R,_loc24_)));
            _loc25_.wB = b2Math.mulX(_loc7_,_loc5_.getVertex(_loc25_.indexB));
            _loc25_.w = b2Math.subtractVV(_loc25_.wB,_loc25_.wA);
            _loc19_++;
            ++b2Distance.b2_gjkIters;
            _loc26_ = false;
            _loc20_ = 0;
            _loc21_ = _loc13_;
            while(_loc20_ < _loc21_)
            {
               _loc22_ = _loc20_++;
               if(_loc25_.indexA == int(_loc11_[_loc22_]) && _loc25_.indexB == int(_loc12_[_loc22_]))
               {
                  _loc26_ = true;
                  break;
               }
            }
            if(_loc26_)
            {
               break;
            }
            ++_loc8_.m_count;
         }
         b2Distance.b2_gjkMaxIters = int(b2Math.max(b2Distance.b2_gjkMaxIters,_loc19_));
         _loc8_.getWitnessPoints(output.pointA,output.pointB);
         output.distance = b2Math.subtractVV(output.pointA,output.pointB).length();
         output.iterations = _loc19_;
         _loc8_.writeCache(cache);
         if(input.useRadii)
         {
            _loc27_ = _loc4_.m_radius;
            _loc28_ = _loc5_.m_radius;
            if(output.distance > _loc27_ + _loc28_ && output.distance > Number(Number.MIN_VALUE))
            {
               output.distance -= _loc27_ + _loc28_;
               _loc24_ = b2Math.subtractVV(output.pointB,output.pointA);
               _loc24_.normalize();
               output.pointA.x += _loc27_ * _loc24_.x;
               output.pointA.y += _loc27_ * _loc24_.y;
               output.pointB.x -= _loc28_ * _loc24_.x;
               output.pointB.y -= _loc28_ * _loc24_.y;
            }
            else
            {
               _loc18_ = new b2Vec2();
               _loc18_.x = 0.5 * (output.pointA.x + output.pointB.x);
               _loc18_.y = 0.5 * (output.pointA.y + output.pointB.y);
               output.pointA.x = output.pointB.x = _loc18_.x;
               output.pointA.y = output.pointB.y = _loc18_.y;
               output.distance = 0;
            }
         }
      }
      
      public static function Distance(output:b2DistanceOutput, cache:b2SimplexCache, input:b2DistanceInput) : void
      {
         b2Distance.distance(output,cache,input);
      }
   }
}

