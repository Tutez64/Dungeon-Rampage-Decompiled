package Box2D.Dynamics.Contacts
{
   import Box2D.Collision.*;
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   import Box2D.Dynamics.*;
   
   use namespace b2internal;
   
   internal class b2PositionSolverManifold
   {
      
      private static var circlePointA:b2Vec2 = new b2Vec2();
      
      private static var circlePointB:b2Vec2 = new b2Vec2();
      
      public var m_normal:b2Vec2;
      
      public var m_points:Vector.<b2Vec2>;
      
      public var m_separations:Vector.<Number>;
      
      public function b2PositionSolverManifold()
      {
         super();
         this.m_normal = new b2Vec2();
         this.m_separations = new Vector.<Number>(b2Settings.b2_maxManifoldPoints);
         this.m_points = new Vector.<b2Vec2>(b2Settings.b2_maxManifoldPoints);
         var _loc1_:* = 0;
         while(_loc1_ < b2Settings.b2_maxManifoldPoints)
         {
            this.m_points[_loc1_] = new b2Vec2();
            _loc1_++;
         }
      }
      
      public function Initialize(cc:b2ContactConstraint) : void
      {
         var _loc2_:* = 0;
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:b2Mat22 = null;
         var _loc6_:b2Vec2 = null;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         b2Settings.b2Assert(cc.pointCount > 0);
         switch(cc.type)
         {
            case b2Manifold.e_circles:
               _loc5_ = cc.bodyA.m_xf.R;
               _loc6_ = cc.localPoint;
               _loc9_ = cc.bodyA.m_xf.position.x + (_loc5_.col1.x * _loc6_.x + _loc5_.col2.x * _loc6_.y);
               _loc10_ = cc.bodyA.m_xf.position.y + (_loc5_.col1.y * _loc6_.x + _loc5_.col2.y * _loc6_.y);
               _loc5_ = cc.bodyB.m_xf.R;
               _loc6_ = cc.points[0].localPoint;
               _loc11_ = cc.bodyB.m_xf.position.x + (_loc5_.col1.x * _loc6_.x + _loc5_.col2.x * _loc6_.y);
               _loc12_ = cc.bodyB.m_xf.position.y + (_loc5_.col1.y * _loc6_.x + _loc5_.col2.y * _loc6_.y);
               _loc13_ = _loc11_ - _loc9_;
               _loc14_ = _loc12_ - _loc10_;
               _loc15_ = _loc13_ * _loc13_ + _loc14_ * _loc14_;
               if(_loc15_ > Number.MIN_VALUE * Number.MIN_VALUE)
               {
                  _loc16_ = Math.sqrt(_loc15_);
                  this.m_normal.x = _loc13_ / _loc16_;
                  this.m_normal.y = _loc14_ / _loc16_;
               }
               else
               {
                  this.m_normal.x = 1;
                  this.m_normal.y = 0;
               }
               this.m_points[0].x = 0.5 * (_loc9_ + _loc11_);
               this.m_points[0].y = 0.5 * (_loc10_ + _loc12_);
               this.m_separations[0] = _loc13_ * this.m_normal.x + _loc14_ * this.m_normal.y - cc.radius;
               break;
            case b2Manifold.e_faceA:
               _loc5_ = cc.bodyA.m_xf.R;
               _loc6_ = cc.localPlaneNormal;
               this.m_normal.x = _loc5_.col1.x * _loc6_.x + _loc5_.col2.x * _loc6_.y;
               this.m_normal.y = _loc5_.col1.y * _loc6_.x + _loc5_.col2.y * _loc6_.y;
               _loc5_ = cc.bodyA.m_xf.R;
               _loc6_ = cc.localPoint;
               _loc7_ = cc.bodyA.m_xf.position.x + (_loc5_.col1.x * _loc6_.x + _loc5_.col2.x * _loc6_.y);
               _loc8_ = cc.bodyA.m_xf.position.y + (_loc5_.col1.y * _loc6_.x + _loc5_.col2.y * _loc6_.y);
               _loc5_ = cc.bodyB.m_xf.R;
               _loc2_ = 0;
               while(_loc2_ < cc.pointCount)
               {
                  _loc6_ = cc.points[_loc2_].localPoint;
                  _loc3_ = cc.bodyB.m_xf.position.x + (_loc5_.col1.x * _loc6_.x + _loc5_.col2.x * _loc6_.y);
                  _loc4_ = cc.bodyB.m_xf.position.y + (_loc5_.col1.y * _loc6_.x + _loc5_.col2.y * _loc6_.y);
                  this.m_separations[_loc2_] = (_loc3_ - _loc7_) * this.m_normal.x + (_loc4_ - _loc8_) * this.m_normal.y - cc.radius;
                  this.m_points[_loc2_].x = _loc3_;
                  this.m_points[_loc2_].y = _loc4_;
                  _loc2_++;
               }
               break;
            case b2Manifold.e_faceB:
               _loc5_ = cc.bodyB.m_xf.R;
               _loc6_ = cc.localPlaneNormal;
               this.m_normal.x = _loc5_.col1.x * _loc6_.x + _loc5_.col2.x * _loc6_.y;
               this.m_normal.y = _loc5_.col1.y * _loc6_.x + _loc5_.col2.y * _loc6_.y;
               _loc5_ = cc.bodyB.m_xf.R;
               _loc6_ = cc.localPoint;
               _loc7_ = cc.bodyB.m_xf.position.x + (_loc5_.col1.x * _loc6_.x + _loc5_.col2.x * _loc6_.y);
               _loc8_ = cc.bodyB.m_xf.position.y + (_loc5_.col1.y * _loc6_.x + _loc5_.col2.y * _loc6_.y);
               _loc5_ = cc.bodyA.m_xf.R;
               _loc2_ = 0;
               while(_loc2_ < cc.pointCount)
               {
                  _loc6_ = cc.points[_loc2_].localPoint;
                  _loc3_ = cc.bodyA.m_xf.position.x + (_loc5_.col1.x * _loc6_.x + _loc5_.col2.x * _loc6_.y);
                  _loc4_ = cc.bodyA.m_xf.position.y + (_loc5_.col1.y * _loc6_.x + _loc5_.col2.y * _loc6_.y);
                  this.m_separations[_loc2_] = (_loc3_ - _loc7_) * this.m_normal.x + (_loc4_ - _loc8_) * this.m_normal.y - cc.radius;
                  this.m_points[_loc2_].Set(_loc3_,_loc4_);
                  _loc2_++;
               }
               this.m_normal.x *= -1;
               this.m_normal.y *= -1;
         }
      }
   }
}

