package Box2D.Collision
{
   import Box2D.Common.Math.b2Math;
   import Box2D.Common.Math.b2Transform;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Common.b2Settings;
   import flash.Boot;
   
   public class b2Simplex
   {
      
      public var m_vertices:Array;
      
      public var m_v3:b2SimplexVertex;
      
      public var m_v2:b2SimplexVertex;
      
      public var m_v1:b2SimplexVertex;
      
      public var m_count:int;
      
      public function b2Simplex()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         m_count = 0;
         m_v1 = new b2SimplexVertex();
         m_v2 = new b2SimplexVertex();
         m_v3 = new b2SimplexVertex();
         m_vertices = [];
         m_vertices[0] = m_v1;
         m_vertices[1] = m_v2;
         m_vertices[2] = m_v3;
      }
      
      public function writeCache(cache:b2SimplexCache) : void
      {
         WriteCache(cache);
      }
      
      public function solve3() : void
      {
         Solve3();
      }
      
      public function solve2() : void
      {
         Solve2();
      }
      
      public function readCache(cache:b2SimplexCache, proxyA:b2DistanceProxy, transformA:b2Transform, proxyB:b2DistanceProxy, transformB:b2Transform) : void
      {
         ReadCache(cache,proxyA,transformA,proxyB,transformB);
      }
      
      public function getWitnessPoints(pA:b2Vec2, pB:b2Vec2) : void
      {
         GetWitnessPoints(pA,pB);
      }
      
      public function getSearchDirection() : b2Vec2
      {
         return GetSearchDirection();
      }
      
      public function getMetric() : Number
      {
         return GetMetric();
      }
      
      public function getClosestPoint() : b2Vec2
      {
         return GetClosestPoint();
      }
      
      public function WriteCache(cache:b2SimplexCache) : void
      {
         var _loc5_:int = 0;
         cache.metric = getMetric();
         cache.count = int(m_count);
         var _loc2_:Array = m_vertices;
         var _loc3_:int = 0;
         var _loc4_:int = m_count;
         while(_loc3_ < _loc4_)
         {
            _loc5_ = _loc3_++;
            cache.indexA[_loc5_] = int(_loc2_[_loc5_].indexA);
            cache.indexB[_loc5_] = int(_loc2_[_loc5_].indexB);
         }
      }
      
      public function Solve3() : void
      {
         var _loc23_:Number = NaN;
         var _loc1_:b2Vec2 = m_v1.w;
         var _loc2_:b2Vec2 = m_v2.w;
         var _loc3_:b2Vec2 = m_v3.w;
         var _loc4_:b2Vec2 = b2Math.subtractVV(_loc2_,_loc1_);
         var _loc5_:Number = b2Math.dot(_loc1_,_loc4_);
         var _loc6_:Number;
         var _loc7_:Number = _loc6_ = b2Math.dot(_loc2_,_loc4_);
         var _loc8_:Number = -_loc5_;
         var _loc9_:b2Vec2 = b2Math.subtractVV(_loc3_,_loc1_);
         var _loc10_:Number = b2Math.dot(_loc1_,_loc9_);
         var _loc11_:Number;
         var _loc12_:Number = _loc11_ = b2Math.dot(_loc3_,_loc9_);
         var _loc13_:Number = -_loc10_;
         var _loc14_:b2Vec2 = b2Math.subtractVV(_loc3_,_loc2_);
         var _loc15_:Number = b2Math.dot(_loc2_,_loc14_);
         var _loc16_:Number;
         var _loc17_:Number = _loc16_ = b2Math.dot(_loc3_,_loc14_);
         var _loc18_:Number = -_loc15_;
         var _loc19_:Number = b2Math.crossVV(_loc4_,_loc9_);
         var _loc20_:Number = _loc19_ * b2Math.crossVV(_loc2_,_loc3_);
         var _loc21_:Number = _loc19_ * b2Math.crossVV(_loc3_,_loc1_);
         var _loc22_:Number = _loc19_ * b2Math.crossVV(_loc1_,_loc2_);
         if(_loc8_ <= 0 && _loc13_ <= 0)
         {
            m_v1.a = 1;
            m_count = 1;
            return;
         }
         if(_loc7_ > 0 && _loc8_ > 0 && _loc22_ <= 0)
         {
            _loc23_ = 1 / (_loc7_ + _loc8_);
            m_v1.a = _loc7_ * _loc23_;
            m_v2.a = _loc8_ * _loc23_;
            m_count = 2;
            return;
         }
         if(_loc12_ > 0 && _loc13_ > 0 && _loc21_ <= 0)
         {
            _loc23_ = 1 / (_loc12_ + _loc13_);
            m_v1.a = _loc12_ * _loc23_;
            m_v3.a = _loc13_ * _loc23_;
            m_count = 2;
            m_v2.set(m_v3);
            return;
         }
         if(_loc7_ <= 0 && _loc18_ <= 0)
         {
            m_v2.a = 1;
            m_count = 1;
            m_v1.set(m_v2);
            return;
         }
         if(_loc12_ <= 0 && _loc17_ <= 0)
         {
            m_v3.a = 1;
            m_count = 1;
            m_v1.set(m_v3);
            return;
         }
         if(_loc17_ > 0 && _loc18_ > 0 && _loc20_ <= 0)
         {
            _loc23_ = 1 / (_loc17_ + _loc18_);
            m_v2.a = _loc17_ * _loc23_;
            m_v3.a = _loc18_ * _loc23_;
            m_count = 2;
            m_v1.set(m_v3);
            return;
         }
         _loc23_ = 1 / (_loc20_ + _loc21_ + _loc22_);
         m_v1.a = _loc20_ * _loc23_;
         m_v2.a = _loc21_ * _loc23_;
         m_v3.a = _loc22_ * _loc23_;
         m_count = 3;
      }
      
      public function Solve2() : void
      {
         var _loc1_:b2Vec2 = m_v1.w;
         var _loc2_:b2Vec2 = m_v2.w;
         var _loc3_:b2Vec2 = b2Math.subtractVV(_loc2_,_loc1_);
         var _loc4_:Number = -(_loc1_.x * _loc3_.x + _loc1_.y * _loc3_.y);
         if(_loc4_ <= 0)
         {
            m_v1.a = 1;
            m_count = 1;
            return;
         }
         var _loc5_:Number = _loc2_.x * _loc3_.x + _loc2_.y * _loc3_.y;
         if(_loc5_ <= 0)
         {
            m_v2.a = 1;
            m_count = 1;
            m_v1.set(m_v2);
            return;
         }
         var _loc6_:Number = 1 / (_loc5_ + _loc4_);
         m_v1.a = _loc5_ * _loc6_;
         m_v2.a = _loc4_ * _loc6_;
         m_count = 2;
      }
      
      public function ReadCache(cache:b2SimplexCache, proxyA:b2DistanceProxy, transformA:b2Transform, proxyB:b2DistanceProxy, transformB:b2Transform) : void
      {
         var _loc6_:* = null as b2Vec2;
         var _loc7_:* = null as b2Vec2;
         var _loc9_:* = null as b2SimplexVertex;
         var _loc12_:int = 0;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         b2Settings.b2Assert(0 <= cache.count && cache.count <= 3);
         m_count = cache.count;
         var _loc8_:Array = m_vertices;
         var _loc10_:int = 0;
         var _loc11_:int = m_count;
         while(_loc10_ < _loc11_)
         {
            _loc12_ = _loc10_++;
            _loc9_ = _loc8_[_loc12_];
            _loc9_.indexA = int(cache.indexA[_loc12_]);
            _loc9_.indexB = int(cache.indexB[_loc12_]);
            _loc6_ = proxyA.getVertex(_loc9_.indexA);
            _loc7_ = proxyB.getVertex(_loc9_.indexB);
            _loc9_.wA = b2Math.mulX(transformA,_loc6_);
            _loc9_.wB = b2Math.mulX(transformB,_loc7_);
            _loc9_.w = b2Math.subtractVV(_loc9_.wB,_loc9_.wA);
            _loc9_.a = 0;
         }
         if(m_count > 1)
         {
            _loc13_ = cache.metric;
            _loc14_ = getMetric();
            if(_loc14_ < 0.5 * _loc13_ || 2 * _loc13_ < _loc14_ || _loc14_ < Number(Number.MIN_VALUE))
            {
               m_count = 0;
            }
         }
         if(m_count == 0)
         {
            _loc9_ = _loc8_[0];
            _loc9_.indexA = 0;
            _loc9_.indexB = 0;
            _loc6_ = proxyA.getVertex(0);
            _loc7_ = proxyB.getVertex(0);
            _loc9_.wA = b2Math.mulX(transformA,_loc6_);
            _loc9_.wB = b2Math.mulX(transformB,_loc7_);
            _loc9_.w = b2Math.subtractVV(_loc9_.wB,_loc9_.wA);
            m_count = 1;
         }
      }
      
      public function GetWitnessPoints(pA:b2Vec2, pB:b2Vec2) : void
      {
         var _loc3_:Number = NaN;
         switch(m_count)
         {
            case 0:
               b2Settings.b2Assert(false);
               break;
            case 1:
               pA.setV(m_v1.wA);
               pB.setV(m_v1.wB);
               break;
            case 2:
               pA.x = m_v1.a * m_v1.wA.x + m_v2.a * m_v2.wA.x;
               pA.y = m_v1.a * m_v1.wA.y + m_v2.a * m_v2.wA.y;
               pB.x = m_v1.a * m_v1.wB.x + m_v2.a * m_v2.wB.x;
               pB.y = m_v1.a * m_v1.wB.y + m_v2.a * m_v2.wB.y;
               break;
            case 3:
               pB.x = pA.x = m_v1.a * m_v1.wA.x + m_v2.a * m_v2.wA.x + m_v3.a * m_v3.wA.x;
               pB.y = pA.y = m_v1.a * m_v1.wA.y + m_v2.a * m_v2.wA.y + m_v3.a * m_v3.wA.y;
               break;
            default:
               b2Settings.b2Assert(false);
         }
      }
      
      public function GetSearchDirection() : b2Vec2
      {
         var _loc1_:* = null as b2Vec2;
         var _loc2_:Number = NaN;
         switch(m_count)
         {
            case 1:
               return m_v1.w.getNegative();
            case 2:
               _loc1_ = b2Math.subtractVV(m_v2.w,m_v1.w);
               _loc2_ = b2Math.crossVV(_loc1_,m_v1.w.getNegative());
               if(_loc2_ > 0)
               {
                  return b2Math.crossFV(1,_loc1_);
               }
               return b2Math.crossVF(_loc1_,1);
               break;
            default:
               b2Settings.b2Assert(false);
               return new b2Vec2();
         }
      }
      
      public function GetMetric() : Number
      {
         switch(m_count)
         {
            case 0:
               b2Settings.b2Assert(false);
               return 0;
            case 1:
               return 0;
            case 2:
               return b2Math.subtractVV(m_v1.w,m_v2.w).length();
            case 3:
               return b2Math.crossVV(b2Math.subtractVV(m_v2.w,m_v1.w),b2Math.subtractVV(m_v3.w,m_v1.w));
            default:
               b2Settings.b2Assert(false);
               return 0;
         }
      }
      
      public function GetClosestPoint() : b2Vec2
      {
         switch(m_count)
         {
            case 0:
               b2Settings.b2Assert(false);
               return new b2Vec2();
            case 1:
               return m_v1.w;
            case 2:
               return new b2Vec2(m_v1.a * m_v1.w.x + m_v2.a * m_v2.w.x,m_v1.a * m_v1.w.y + m_v2.a * m_v2.w.y);
            default:
               b2Settings.b2Assert(false);
               return new b2Vec2();
         }
      }
   }
}

