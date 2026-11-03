package Box2D.Collision
{
   import Box2D.Common.Math.b2Math;
   import Box2D.Common.Math.b2Sweep;
   import Box2D.Common.Math.b2Transform;
   import Box2D.Common.b2Settings;
   
   public class b2TimeOfImpact
   {
      
      public static var b2_toiCalls:int = 0;
      
      public static var b2_toiIters:int = 0;
      
      public static var b2_toiMaxIters:int = 0;
      
      public static var b2_toiRootIters:int = 0;
      
      public static var b2_toiMaxRootIters:int = 0;
      
      public static var s_cache:b2SimplexCache = new b2SimplexCache();
      
      public static var s_distanceInput:b2DistanceInput = new b2DistanceInput();
      
      public static var s_xfA:b2Transform = new b2Transform();
      
      public static var s_xfB:b2Transform = new b2Transform();
      
      public static var s_fcn:b2SeparationFunction = new b2SeparationFunction();
      
      public static var s_distanceOutput:b2DistanceOutput = new b2DistanceOutput();
      
      public function b2TimeOfImpact()
      {
      }
      
      public static function timeOfImpact(input:b2TOIInput) : Number
      {
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:int = 0;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         ++b2TimeOfImpact.b2_toiCalls;
         var _loc2_:b2DistanceProxy = input.proxyA;
         var _loc3_:b2DistanceProxy = input.proxyB;
         var _loc4_:b2Sweep = input.sweepA;
         var _loc5_:b2Sweep = input.sweepB;
         b2Settings.b2Assert(_loc4_.t0 == _loc5_.t0);
         b2Settings.b2Assert(1 - _loc4_.t0 > Number(Number.MIN_VALUE));
         var _loc6_:Number = _loc2_.m_radius + _loc3_.m_radius;
         var _loc7_:Number = input.tolerance;
         var _loc8_:Number = 0;
         var _loc9_:int = 1000;
         var _loc10_:int = 0;
         var _loc11_:Number = 0;
         b2TimeOfImpact.s_cache.count = 0;
         b2TimeOfImpact.s_distanceInput.useRadii = false;
         do
         {
            _loc4_.getTransform(b2TimeOfImpact.s_xfA,_loc8_);
            _loc5_.getTransform(b2TimeOfImpact.s_xfB,_loc8_);
            b2TimeOfImpact.s_distanceInput.proxyA = _loc2_;
            b2TimeOfImpact.s_distanceInput.proxyB = _loc3_;
            b2TimeOfImpact.s_distanceInput.transformA = b2TimeOfImpact.s_xfA;
            b2TimeOfImpact.s_distanceInput.transformB = b2TimeOfImpact.s_xfB;
            b2Distance.distance(b2TimeOfImpact.s_distanceOutput,b2TimeOfImpact.s_cache,b2TimeOfImpact.s_distanceInput);
            if(b2TimeOfImpact.s_distanceOutput.distance <= 0)
            {
               _loc8_ = 1;
               break;
            }
            b2TimeOfImpact.s_fcn.initialize(b2TimeOfImpact.s_cache,_loc2_,b2TimeOfImpact.s_xfA,_loc3_,b2TimeOfImpact.s_xfB);
            _loc12_ = b2TimeOfImpact.s_fcn.evaluate(b2TimeOfImpact.s_xfA,b2TimeOfImpact.s_xfB);
            if(_loc12_ <= 0)
            {
               _loc8_ = 1;
               break;
            }
            if(_loc10_ == 0)
            {
               if(_loc12_ > _loc6_)
               {
                  _loc11_ = b2Math.max(_loc6_ - _loc7_,0.75 * _loc6_);
               }
               else
               {
                  _loc11_ = b2Math.max(_loc12_ - _loc7_,0.02 * _loc6_);
               }
            }
            if(_loc12_ - _loc11_ < 0.5 * _loc7_)
            {
               if(_loc10_ == 0)
               {
                  _loc8_ = 1;
               }
               break;
            }
            _loc13_ = _loc8_;
            _loc14_ = _loc8_;
            _loc15_ = 1;
            _loc16_ = _loc12_;
            _loc4_.getTransform(b2TimeOfImpact.s_xfA,_loc15_);
            _loc5_.getTransform(b2TimeOfImpact.s_xfB,_loc15_);
            _loc17_ = b2TimeOfImpact.s_fcn.evaluate(b2TimeOfImpact.s_xfA,b2TimeOfImpact.s_xfB);
            if(_loc17_ >= _loc11_)
            {
               _loc8_ = 1;
               break;
            }
            _loc18_ = 0;
            do
            {
               if((_loc18_ & 1) != 0)
               {
                  _loc19_ = _loc14_ + (_loc11_ - _loc16_) * (_loc15_ - _loc14_) / (_loc17_ - _loc16_);
               }
               else
               {
                  _loc19_ = 0.5 * (_loc14_ + _loc15_);
               }
               _loc4_.getTransform(b2TimeOfImpact.s_xfA,_loc19_);
               _loc5_.getTransform(b2TimeOfImpact.s_xfB,_loc19_);
               _loc20_ = b2TimeOfImpact.s_fcn.evaluate(b2TimeOfImpact.s_xfA,b2TimeOfImpact.s_xfB);
               if(b2Math.abs(_loc20_ - _loc11_) < 0.025 * _loc7_)
               {
                  _loc13_ = _loc19_;
                  break;
               }
               if(_loc20_ > _loc11_)
               {
                  _loc14_ = _loc19_;
                  _loc16_ = _loc20_;
               }
               else
               {
                  _loc15_ = _loc19_;
                  _loc17_ = _loc20_;
               }
               _loc18_++;
               ++b2TimeOfImpact.b2_toiRootIters;
            }
            while(_loc18_ != 50);
            b2TimeOfImpact.b2_toiMaxRootIters = int(b2Math.max(b2TimeOfImpact.b2_toiMaxRootIters,_loc18_));
            if(_loc13_ < (1 + 100 * Number(Number.MIN_VALUE)) * _loc8_)
            {
               break;
            }
            _loc8_ = _loc13_;
            _loc10_++;
            ++b2TimeOfImpact.b2_toiIters;
         }
         while(_loc10_ != _loc9_);
         b2TimeOfImpact.b2_toiMaxIters = int(b2Math.max(b2TimeOfImpact.b2_toiMaxIters,_loc10_));
         return _loc8_;
      }
      
      public static function TimeOfImpact(input:b2TOIInput) : Number
      {
         return b2TimeOfImpact.timeOfImpact(input);
      }
   }
}

