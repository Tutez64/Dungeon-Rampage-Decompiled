package Box2D.Collision
{
   import Box2D.Common.Math.b2Mat22;
   import Box2D.Common.Math.b2Transform;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Common.b2Settings;
   import flash.Boot;
   
   public class b2WorldManifold
   {
      
      public var m_points:Array;
      
      public var m_normal:b2Vec2;
      
      public function b2WorldManifold()
      {
         var _loc3_:int = 0;
         if(Boot.skip_constructor)
         {
            return;
         }
         m_normal = new b2Vec2();
         m_points = [];
         var _loc1_:int = 0;
         var _loc2_:int = b2Settings.b2_maxManifoldPoints;
         while(_loc1_ < _loc2_)
         {
            _loc3_ = _loc1_++;
            m_points[_loc3_] = new b2Vec2();
         }
      }
      
      public function initialize(manifold:b2Manifold, xfA:b2Transform, radiusA:Number, xfB:b2Transform, radiusB:Number) : void
      {
         Initialize(manifold,xfA,radiusA,xfB,radiusB);
      }
      
      public function Initialize(manifold:b2Manifold, xfA:b2Transform, radiusA:Number, xfB:b2Transform, radiusB:Number) : void
      {
         var _loc7_:* = null as b2Vec2;
         var _loc8_:* = null as b2Mat22;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc24_:Number = NaN;
         var _loc25_:Number = NaN;
         var _loc26_:int = 0;
         var _loc27_:int = 0;
         var _loc28_:int = 0;
         if(manifold.m_pointCount == 0)
         {
            return;
         }
         switch(manifold.m_type.index)
         {
            case 0:
               _loc8_ = xfA.R;
               _loc7_ = manifold.m_localPoint;
               _loc15_ = xfA.position.x + _loc8_.col1.x * _loc7_.x + _loc8_.col2.x * _loc7_.y;
               _loc16_ = xfA.position.y + _loc8_.col1.y * _loc7_.x + _loc8_.col2.y * _loc7_.y;
               _loc8_ = xfB.R;
               _loc7_ = manifold.m_points[0].m_localPoint;
               _loc17_ = xfB.position.x + _loc8_.col1.x * _loc7_.x + _loc8_.col2.x * _loc7_.y;
               _loc18_ = xfB.position.y + _loc8_.col1.y * _loc7_.x + _loc8_.col2.y * _loc7_.y;
               _loc19_ = _loc17_ - _loc15_;
               _loc20_ = _loc18_ - _loc16_;
               _loc21_ = _loc19_ * _loc19_ + _loc20_ * _loc20_;
               if(_loc21_ > Number(Number.MIN_VALUE) * Number(Number.MIN_VALUE))
               {
                  _loc22_ = Math.sqrt(_loc21_);
                  m_normal.x = _loc19_ / _loc22_;
                  m_normal.y = _loc20_ / _loc22_;
               }
               else
               {
                  m_normal.x = 1;
                  m_normal.y = 0;
               }
               _loc22_ = _loc15_ + radiusA * m_normal.x;
               _loc23_ = _loc16_ + radiusA * m_normal.y;
               _loc24_ = _loc17_ - radiusB * m_normal.x;
               _loc25_ = _loc18_ - radiusB * m_normal.y;
               m_points[0].x = 0.5 * (_loc22_ + _loc24_);
               m_points[0].y = 0.5 * (_loc23_ + _loc25_);
               break;
            case 1:
               _loc8_ = xfA.R;
               _loc7_ = manifold.m_localPlaneNormal;
               _loc9_ = _loc8_.col1.x * _loc7_.x + _loc8_.col2.x * _loc7_.y;
               _loc10_ = _loc8_.col1.y * _loc7_.x + _loc8_.col2.y * _loc7_.y;
               _loc8_ = xfA.R;
               _loc7_ = manifold.m_localPoint;
               _loc11_ = xfA.position.x + _loc8_.col1.x * _loc7_.x + _loc8_.col2.x * _loc7_.y;
               _loc12_ = xfA.position.y + _loc8_.col1.y * _loc7_.x + _loc8_.col2.y * _loc7_.y;
               m_normal.x = _loc9_;
               m_normal.y = _loc10_;
               _loc26_ = 0;
               _loc27_ = manifold.m_pointCount;
               while(_loc26_ < _loc27_)
               {
                  _loc28_ = _loc26_++;
                  _loc8_ = xfB.R;
                  _loc7_ = manifold.m_points[_loc28_].m_localPoint;
                  _loc13_ = xfB.position.x + _loc8_.col1.x * _loc7_.x + _loc8_.col2.x * _loc7_.y;
                  _loc14_ = xfB.position.y + _loc8_.col1.y * _loc7_.x + _loc8_.col2.y * _loc7_.y;
                  m_points[_loc28_].x = _loc13_ + 0.5 * (radiusA - (_loc13_ - _loc11_) * _loc9_ - (_loc14_ - _loc12_) * _loc10_ - radiusB) * _loc9_;
                  m_points[_loc28_].y = _loc14_ + 0.5 * (radiusA - (_loc13_ - _loc11_) * _loc9_ - (_loc14_ - _loc12_) * _loc10_ - radiusB) * _loc10_;
               }
               break;
            case 2:
               _loc8_ = xfB.R;
               _loc7_ = manifold.m_localPlaneNormal;
               _loc9_ = _loc8_.col1.x * _loc7_.x + _loc8_.col2.x * _loc7_.y;
               _loc10_ = _loc8_.col1.y * _loc7_.x + _loc8_.col2.y * _loc7_.y;
               _loc8_ = xfB.R;
               _loc7_ = manifold.m_localPoint;
               _loc11_ = xfB.position.x + _loc8_.col1.x * _loc7_.x + _loc8_.col2.x * _loc7_.y;
               _loc12_ = xfB.position.y + _loc8_.col1.y * _loc7_.x + _loc8_.col2.y * _loc7_.y;
               m_normal.x = -_loc9_;
               m_normal.y = -_loc10_;
               _loc26_ = 0;
               _loc27_ = manifold.m_pointCount;
               while(_loc26_ < _loc27_)
               {
                  _loc28_ = _loc26_++;
                  _loc8_ = xfA.R;
                  _loc7_ = manifold.m_points[_loc28_].m_localPoint;
                  _loc13_ = xfA.position.x + _loc8_.col1.x * _loc7_.x + _loc8_.col2.x * _loc7_.y;
                  _loc14_ = xfA.position.y + _loc8_.col1.y * _loc7_.x + _loc8_.col2.y * _loc7_.y;
                  m_points[_loc28_].x = _loc13_ + 0.5 * (radiusB - (_loc13_ - _loc11_) * _loc9_ - (_loc14_ - _loc12_) * _loc10_ - radiusA) * _loc9_;
                  m_points[_loc28_].y = _loc14_ + 0.5 * (radiusB - (_loc13_ - _loc11_) * _loc9_ - (_loc14_ - _loc12_) * _loc10_ - radiusA) * _loc10_;
               }
         }
      }
   }
}

