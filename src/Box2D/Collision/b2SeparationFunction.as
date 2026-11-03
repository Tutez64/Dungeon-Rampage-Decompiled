package Box2D.Collision
{
   import Box2D.Common.Math.b2Mat22;
   import Box2D.Common.Math.b2Math;
   import Box2D.Common.Math.b2Transform;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Common.b2Settings;
   import box2D.collision.B2SeparationFunctionType;
   import flash.Boot;
   
   public class b2SeparationFunction
   {
      
      public var m_type:B2SeparationFunctionType;
      
      public var m_proxyB:b2DistanceProxy;
      
      public var m_proxyA:b2DistanceProxy;
      
      public var m_localPoint:b2Vec2;
      
      public var m_axis:b2Vec2;
      
      public function b2SeparationFunction()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         m_localPoint = new b2Vec2();
         m_axis = new b2Vec2();
      }
      
      public function initialize(cache:b2SimplexCache, proxyA:b2DistanceProxy, transformA:b2Transform, proxyB:b2DistanceProxy, transformB:b2Transform) : void
      {
         Initialize(cache,proxyA,transformA,proxyB,transformB);
      }
      
      public function evaluate(transformA:b2Transform, transformB:b2Transform) : Number
      {
         return Evaluate(transformA,transformB);
      }
      
      public function Initialize(cache:b2SimplexCache, proxyA:b2DistanceProxy, transformA:b2Transform, proxyB:b2DistanceProxy, transformB:b2Transform) : void
      {
         var _loc8_:* = null as b2Vec2;
         var _loc9_:* = null as b2Vec2;
         var _loc11_:* = null as b2Vec2;
         var _loc12_:* = null as b2Vec2;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:* = null as b2Mat22;
         var _loc20_:* = null as b2Vec2;
         var _loc21_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc23_:* = null as b2Vec2;
         var _loc24_:* = null as b2Vec2;
         var _loc25_:* = null as b2Vec2;
         var _loc26_:* = null as b2Vec2;
         var _loc27_:Number = NaN;
         var _loc28_:Number = NaN;
         var _loc29_:* = null as b2Vec2;
         var _loc30_:Number = NaN;
         var _loc31_:Number = NaN;
         var _loc32_:Number = NaN;
         var _loc33_:Number = NaN;
         var _loc34_:Number = NaN;
         m_proxyA = proxyA;
         m_proxyB = proxyB;
         var _loc6_:int = cache.count;
         b2Settings.b2Assert(0 < _loc6_ && _loc6_ < 3);
         var _loc7_:b2Vec2 = new b2Vec2();
         var _loc10_:b2Vec2 = new b2Vec2();
         if(_loc6_ == 1)
         {
            m_type = B2SeparationFunctionType.POINTS;
            _loc7_ = m_proxyA.getVertex(int(cache.indexA[0]));
            _loc10_ = m_proxyB.getVertex(int(cache.indexB[0]));
            _loc20_ = _loc7_;
            _loc19_ = transformA.R;
            _loc13_ = transformA.position.x + (_loc19_.col1.x * _loc20_.x + _loc19_.col2.x * _loc20_.y);
            _loc14_ = transformA.position.y + (_loc19_.col1.y * _loc20_.x + _loc19_.col2.y * _loc20_.y);
            _loc20_ = _loc10_;
            _loc19_ = transformB.R;
            _loc15_ = transformB.position.x + (_loc19_.col1.x * _loc20_.x + _loc19_.col2.x * _loc20_.y);
            _loc16_ = transformB.position.y + (_loc19_.col1.y * _loc20_.x + _loc19_.col2.y * _loc20_.y);
            m_axis.x = _loc15_ - _loc13_;
            m_axis.y = _loc16_ - _loc14_;
            m_axis.normalize();
         }
         else if(int(cache.indexB[0]) == int(cache.indexB[1]))
         {
            m_type = B2SeparationFunctionType.FACE_A;
            _loc8_ = m_proxyA.getVertex(int(cache.indexA[0]));
            _loc9_ = m_proxyA.getVertex(int(cache.indexA[1]));
            _loc10_ = m_proxyB.getVertex(int(cache.indexB[0]));
            m_localPoint.x = 0.5 * (_loc8_.x + _loc9_.x);
            m_localPoint.y = 0.5 * (_loc8_.y + _loc9_.y);
            m_axis = b2Math.crossVF(b2Math.subtractVV(_loc9_,_loc8_),1);
            m_axis.normalize();
            _loc20_ = m_axis;
            _loc19_ = transformA.R;
            _loc17_ = _loc19_.col1.x * _loc20_.x + _loc19_.col2.x * _loc20_.y;
            _loc18_ = _loc19_.col1.y * _loc20_.x + _loc19_.col2.y * _loc20_.y;
            _loc20_ = m_localPoint;
            _loc19_ = transformA.R;
            _loc13_ = transformA.position.x + (_loc19_.col1.x * _loc20_.x + _loc19_.col2.x * _loc20_.y);
            _loc14_ = transformA.position.y + (_loc19_.col1.y * _loc20_.x + _loc19_.col2.y * _loc20_.y);
            _loc20_ = _loc10_;
            _loc19_ = transformB.R;
            _loc15_ = transformB.position.x + (_loc19_.col1.x * _loc20_.x + _loc19_.col2.x * _loc20_.y);
            _loc16_ = transformB.position.y + (_loc19_.col1.y * _loc20_.x + _loc19_.col2.y * _loc20_.y);
            _loc21_ = (_loc15_ - _loc13_) * _loc17_ + (_loc16_ - _loc14_) * _loc18_;
            if(_loc21_ < 0)
            {
               m_axis.negativeSelf();
            }
         }
         else if(int(cache.indexA[0]) == int(cache.indexA[0]))
         {
            m_type = B2SeparationFunctionType.FACE_B;
            _loc11_ = m_proxyB.getVertex(int(cache.indexB[0]));
            _loc12_ = m_proxyB.getVertex(int(cache.indexB[1]));
            _loc7_ = m_proxyA.getVertex(int(cache.indexA[0]));
            m_localPoint.x = 0.5 * (_loc11_.x + _loc12_.x);
            m_localPoint.y = 0.5 * (_loc11_.y + _loc12_.y);
            m_axis = b2Math.crossVF(b2Math.subtractVV(_loc12_,_loc11_),1);
            m_axis.normalize();
            _loc20_ = m_axis;
            _loc19_ = transformB.R;
            _loc17_ = _loc19_.col1.x * _loc20_.x + _loc19_.col2.x * _loc20_.y;
            _loc18_ = _loc19_.col1.y * _loc20_.x + _loc19_.col2.y * _loc20_.y;
            _loc20_ = m_localPoint;
            _loc19_ = transformB.R;
            _loc15_ = transformB.position.x + (_loc19_.col1.x * _loc20_.x + _loc19_.col2.x * _loc20_.y);
            _loc16_ = transformB.position.y + (_loc19_.col1.y * _loc20_.x + _loc19_.col2.y * _loc20_.y);
            _loc20_ = _loc7_;
            _loc19_ = transformA.R;
            _loc13_ = transformA.position.x + (_loc19_.col1.x * _loc20_.x + _loc19_.col2.x * _loc20_.y);
            _loc14_ = transformA.position.y + (_loc19_.col1.y * _loc20_.x + _loc19_.col2.y * _loc20_.y);
            _loc21_ = (_loc13_ - _loc15_) * _loc17_ + (_loc14_ - _loc16_) * _loc18_;
            if(_loc21_ < 0)
            {
               m_axis.negativeSelf();
            }
         }
         else
         {
            _loc8_ = m_proxyA.getVertex(int(cache.indexA[0]));
            _loc9_ = m_proxyA.getVertex(int(cache.indexA[1]));
            _loc11_ = m_proxyB.getVertex(int(cache.indexB[0]));
            _loc12_ = m_proxyB.getVertex(int(cache.indexB[1]));
            _loc23_ = b2Math.mulX(transformA,_loc7_);
            _loc24_ = b2Math.mulMV(transformA.R,b2Math.subtractVV(_loc9_,_loc8_));
            _loc25_ = b2Math.mulX(transformB,_loc10_);
            _loc26_ = b2Math.mulMV(transformB.R,b2Math.subtractVV(_loc12_,_loc11_));
            _loc27_ = _loc24_.x * _loc24_.x + _loc24_.y * _loc24_.y;
            _loc28_ = _loc26_.x * _loc26_.x + _loc26_.y * _loc26_.y;
            _loc29_ = b2Math.subtractVV(_loc26_,_loc24_);
            _loc30_ = _loc24_.x * _loc29_.x + _loc24_.y * _loc29_.y;
            _loc31_ = _loc26_.x * _loc29_.x + _loc26_.y * _loc29_.y;
            _loc32_ = _loc24_.x * _loc26_.x + _loc24_.y * _loc26_.y;
            _loc33_ = _loc27_ * _loc28_ - _loc32_ * _loc32_;
            _loc21_ = 0;
            if(_loc33_ != 0)
            {
               _loc21_ = b2Math.clamp((_loc32_ * _loc31_ - _loc30_ * _loc28_) / _loc33_,0,1);
            }
            _loc34_ = (_loc32_ * _loc21_ + _loc31_) / _loc28_;
            if(_loc34_ < 0)
            {
               _loc34_ = 0;
               _loc21_ = b2Math.clamp((_loc32_ - _loc30_) / _loc27_,0,1);
            }
            _loc7_ = new b2Vec2();
            _loc7_.x = _loc8_.x + _loc21_ * (_loc9_.x - _loc8_.x);
            _loc7_.y = _loc8_.y + _loc21_ * (_loc9_.y - _loc8_.y);
            _loc10_ = new b2Vec2();
            _loc10_.x = _loc11_.x + _loc21_ * (_loc12_.x - _loc11_.x);
            _loc10_.y = _loc11_.y + _loc21_ * (_loc12_.y - _loc11_.y);
            if(_loc21_ == 0 || _loc21_ == 1)
            {
               m_type = B2SeparationFunctionType.FACE_B;
               m_axis = b2Math.crossVF(b2Math.subtractVV(_loc12_,_loc11_),1);
               m_axis.normalize();
               m_localPoint = _loc10_;
               _loc20_ = m_axis;
               _loc19_ = transformB.R;
               _loc17_ = _loc19_.col1.x * _loc20_.x + _loc19_.col2.x * _loc20_.y;
               _loc18_ = _loc19_.col1.y * _loc20_.x + _loc19_.col2.y * _loc20_.y;
               _loc20_ = m_localPoint;
               _loc19_ = transformB.R;
               _loc15_ = transformB.position.x + (_loc19_.col1.x * _loc20_.x + _loc19_.col2.x * _loc20_.y);
               _loc16_ = transformB.position.y + (_loc19_.col1.y * _loc20_.x + _loc19_.col2.y * _loc20_.y);
               _loc20_ = _loc7_;
               _loc19_ = transformA.R;
               _loc13_ = transformA.position.x + (_loc19_.col1.x * _loc20_.x + _loc19_.col2.x * _loc20_.y);
               _loc14_ = transformA.position.y + (_loc19_.col1.y * _loc20_.x + _loc19_.col2.y * _loc20_.y);
               _loc22_ = (_loc13_ - _loc15_) * _loc17_ + (_loc14_ - _loc16_) * _loc18_;
               if(_loc21_ < 0)
               {
                  m_axis.negativeSelf();
               }
            }
            else
            {
               m_type = B2SeparationFunctionType.FACE_A;
               m_axis = b2Math.crossVF(b2Math.subtractVV(_loc9_,_loc8_),1);
               m_localPoint = _loc7_;
               _loc20_ = m_axis;
               _loc19_ = transformA.R;
               _loc17_ = _loc19_.col1.x * _loc20_.x + _loc19_.col2.x * _loc20_.y;
               _loc18_ = _loc19_.col1.y * _loc20_.x + _loc19_.col2.y * _loc20_.y;
               _loc20_ = m_localPoint;
               _loc19_ = transformA.R;
               _loc13_ = transformA.position.x + (_loc19_.col1.x * _loc20_.x + _loc19_.col2.x * _loc20_.y);
               _loc14_ = transformA.position.y + (_loc19_.col1.y * _loc20_.x + _loc19_.col2.y * _loc20_.y);
               _loc20_ = _loc10_;
               _loc19_ = transformB.R;
               _loc15_ = transformB.position.x + (_loc19_.col1.x * _loc20_.x + _loc19_.col2.x * _loc20_.y);
               _loc16_ = transformB.position.y + (_loc19_.col1.y * _loc20_.x + _loc19_.col2.y * _loc20_.y);
               _loc22_ = (_loc15_ - _loc13_) * _loc17_ + (_loc16_ - _loc14_) * _loc18_;
               if(_loc21_ < 0)
               {
                  m_axis.negativeSelf();
               }
            }
         }
      }
      
      public function Evaluate(transformA:b2Transform, transformB:b2Transform) : Number
      {
         var _loc3_:* = null as b2Vec2;
         var _loc4_:* = null as b2Vec2;
         var _loc5_:* = null as b2Vec2;
         var _loc6_:* = null as b2Vec2;
         var _loc7_:* = null as b2Vec2;
         var _loc8_:* = null as b2Vec2;
         var _loc9_:Number = NaN;
         var _loc10_:* = null as b2Vec2;
         switch(m_type.index)
         {
            case 0:
               _loc3_ = b2Math.mulTMV(transformA.R,m_axis);
               _loc4_ = b2Math.mulTMV(transformB.R,m_axis.getNegative());
               _loc5_ = m_proxyA.getSupportVertex(_loc3_);
               _loc6_ = m_proxyB.getSupportVertex(_loc4_);
               _loc7_ = b2Math.mulX(transformA,_loc5_);
               _loc8_ = b2Math.mulX(transformB,_loc6_);
               return (_loc8_.x - _loc7_.x) * m_axis.x + (_loc8_.y - _loc7_.y) * m_axis.y;
            case 1:
               _loc10_ = b2Math.mulMV(transformA.R,m_axis);
               _loc7_ = b2Math.mulX(transformA,m_localPoint);
               _loc4_ = b2Math.mulTMV(transformB.R,_loc10_.getNegative());
               _loc6_ = m_proxyB.getSupportVertex(_loc4_);
               _loc8_ = b2Math.mulX(transformB,_loc6_);
               return (_loc8_.x - _loc7_.x) * _loc10_.x + (_loc8_.y - _loc7_.y) * _loc10_.y;
            case 2:
               _loc10_ = b2Math.mulMV(transformB.R,m_axis);
               _loc8_ = b2Math.mulX(transformB,m_localPoint);
               _loc3_ = b2Math.mulTMV(transformA.R,_loc10_.getNegative());
               _loc5_ = m_proxyA.getSupportVertex(_loc3_);
               _loc7_ = b2Math.mulX(transformA,_loc5_);
               return (_loc7_.x - _loc8_.x) * _loc10_.x + (_loc7_.y - _loc8_.y) * _loc10_.y;
            default:
               return undefined;
         }
      }
   }
}

