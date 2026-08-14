package Box2D.Collision
{
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   
   use namespace b2internal;
   
   public class b2WorldManifold
   {
      
      public var m_normal:b2Vec2 = new b2Vec2();
      
      public var m_points:Vector.<b2Vec2>;
      
      public function b2WorldManifold()
      {
         super();
         this.m_points = new Vector.<b2Vec2>(b2Settings.b2_maxManifoldPoints);
         var _loc1_:* = 0;
         while(_loc1_ < b2Settings.b2_maxManifoldPoints)
         {
            this.m_points[_loc1_] = new b2Vec2();
            _loc1_++;
         }
      }
      
      public function Initialize(manifold:b2Manifold, xfA:b2Transform, radiusA:Number, xfB:b2Transform, radiusB:Number) : void
      {
         var _loc6_:* = 0;
         var _loc7_:b2Vec2 = null;
         var _loc8_:b2Mat22 = null;
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
         var _loc26_:Number = NaN;
         if(manifold.m_pointCount == 0)
         {
            return;
         }
         switch(manifold.m_type)
         {
            case b2Manifold.e_circles:
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
               if(_loc21_ > Number.MIN_VALUE * Number.MIN_VALUE)
               {
                  _loc26_ = Math.sqrt(_loc21_);
                  this.m_normal.x = _loc19_ / _loc26_;
                  this.m_normal.y = _loc20_ / _loc26_;
               }
               else
               {
                  this.m_normal.x = 1;
                  this.m_normal.y = 0;
               }
               _loc22_ = _loc15_ + radiusA * this.m_normal.x;
               _loc23_ = _loc16_ + radiusA * this.m_normal.y;
               _loc24_ = _loc17_ - radiusB * this.m_normal.x;
               _loc25_ = _loc18_ - radiusB * this.m_normal.y;
               this.m_points[0].x = 0.5 * (_loc22_ + _loc24_);
               this.m_points[0].y = 0.5 * (_loc23_ + _loc25_);
               break;
            case b2Manifold.e_faceA:
               _loc8_ = xfA.R;
               _loc7_ = manifold.m_localPlaneNormal;
               _loc9_ = _loc8_.col1.x * _loc7_.x + _loc8_.col2.x * _loc7_.y;
               _loc10_ = _loc8_.col1.y * _loc7_.x + _loc8_.col2.y * _loc7_.y;
               _loc8_ = xfA.R;
               _loc7_ = manifold.m_localPoint;
               _loc11_ = xfA.position.x + _loc8_.col1.x * _loc7_.x + _loc8_.col2.x * _loc7_.y;
               _loc12_ = xfA.position.y + _loc8_.col1.y * _loc7_.x + _loc8_.col2.y * _loc7_.y;
               this.m_normal.x = _loc9_;
               this.m_normal.y = _loc10_;
               _loc6_ = 0;
               while(_loc6_ < manifold.m_pointCount)
               {
                  _loc8_ = xfB.R;
                  _loc7_ = manifold.m_points[_loc6_].m_localPoint;
                  _loc13_ = xfB.position.x + _loc8_.col1.x * _loc7_.x + _loc8_.col2.x * _loc7_.y;
                  _loc14_ = xfB.position.y + _loc8_.col1.y * _loc7_.x + _loc8_.col2.y * _loc7_.y;
                  this.m_points[_loc6_].x = _loc13_ + 0.5 * (radiusA - (_loc13_ - _loc11_) * _loc9_ - (_loc14_ - _loc12_) * _loc10_ - radiusB) * _loc9_;
                  this.m_points[_loc6_].y = _loc14_ + 0.5 * (radiusA - (_loc13_ - _loc11_) * _loc9_ - (_loc14_ - _loc12_) * _loc10_ - radiusB) * _loc10_;
                  _loc6_++;
               }
               break;
            case b2Manifold.e_faceB:
               _loc8_ = xfB.R;
               _loc7_ = manifold.m_localPlaneNormal;
               _loc9_ = _loc8_.col1.x * _loc7_.x + _loc8_.col2.x * _loc7_.y;
               _loc10_ = _loc8_.col1.y * _loc7_.x + _loc8_.col2.y * _loc7_.y;
               _loc8_ = xfB.R;
               _loc7_ = manifold.m_localPoint;
               _loc11_ = xfB.position.x + _loc8_.col1.x * _loc7_.x + _loc8_.col2.x * _loc7_.y;
               _loc12_ = xfB.position.y + _loc8_.col1.y * _loc7_.x + _loc8_.col2.y * _loc7_.y;
               this.m_normal.x = -_loc9_;
               this.m_normal.y = -_loc10_;
               _loc6_ = 0;
               while(_loc6_ < manifold.m_pointCount)
               {
                  _loc8_ = xfA.R;
                  _loc7_ = manifold.m_points[_loc6_].m_localPoint;
                  _loc13_ = xfA.position.x + _loc8_.col1.x * _loc7_.x + _loc8_.col2.x * _loc7_.y;
                  _loc14_ = xfA.position.y + _loc8_.col1.y * _loc7_.x + _loc8_.col2.y * _loc7_.y;
                  this.m_points[_loc6_].x = _loc13_ + 0.5 * (radiusB - (_loc13_ - _loc11_) * _loc9_ - (_loc14_ - _loc12_) * _loc10_ - radiusA) * _loc9_;
                  this.m_points[_loc6_].y = _loc14_ + 0.5 * (radiusB - (_loc13_ - _loc11_) * _loc9_ - (_loc14_ - _loc12_) * _loc10_ - radiusA) * _loc10_;
                  _loc6_++;
               }
         }
      }
   }
}

