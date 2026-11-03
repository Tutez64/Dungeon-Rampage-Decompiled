package Box2D.Dynamics.Contacts
{
   import Box2D.Common.Math.b2Mat22;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Common.b2Settings;
   import flash.Boot;
   
   public class b2PositionSolverManifold
   {
      
      public static var circlePointA:b2Vec2 = new b2Vec2();
      
      public static var circlePointB:b2Vec2 = new b2Vec2();
      
      public var m_separations:Array;
      
      public var m_points:Array;
      
      public var m_normal:b2Vec2;
      
      public function b2PositionSolverManifold()
      {
         var _loc3_:int = 0;
         if(Boot.skip_constructor)
         {
            return;
         }
         m_normal = new b2Vec2();
         m_separations = [];
         m_points = [];
         var _loc1_:int = 0;
         var _loc2_:int = b2Settings.b2_maxManifoldPoints;
         while(_loc1_ < _loc2_)
         {
            _loc3_ = _loc1_++;
            m_points[_loc3_] = new b2Vec2();
         }
      }
      
      public function initialize(cc:b2ContactConstraint) : void
      {
         Initialize(cc);
      }
      
      public function Initialize(cc:b2ContactConstraint) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:* = null as b2Mat22;
         var _loc6_:* = null as b2Vec2;
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
         var _loc17_:int = 0;
         var _loc18_:int = 0;
         var _loc19_:int = 0;
         b2Settings.b2Assert(cc.pointCount > 0);
         switch(cc.type.index)
         {
            case 0:
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
               if(_loc15_ > Number(Number.MIN_VALUE) * Number(Number.MIN_VALUE))
               {
                  _loc16_ = Math.sqrt(_loc15_);
                  m_normal.x = _loc13_ / _loc16_;
                  m_normal.y = _loc14_ / _loc16_;
               }
               else
               {
                  m_normal.x = 1;
                  m_normal.y = 0;
               }
               m_points[0].x = 0.5 * (_loc9_ + _loc11_);
               m_points[0].y = 0.5 * (_loc10_ + _loc12_);
               m_separations[0] = _loc13_ * m_normal.x + _loc14_ * m_normal.y - cc.radius;
               break;
            case 1:
               _loc5_ = cc.bodyA.m_xf.R;
               _loc6_ = cc.localPlaneNormal;
               m_normal.x = _loc5_.col1.x * _loc6_.x + _loc5_.col2.x * _loc6_.y;
               m_normal.y = _loc5_.col1.y * _loc6_.x + _loc5_.col2.y * _loc6_.y;
               _loc5_ = cc.bodyA.m_xf.R;
               _loc6_ = cc.localPoint;
               _loc7_ = cc.bodyA.m_xf.position.x + (_loc5_.col1.x * _loc6_.x + _loc5_.col2.x * _loc6_.y);
               _loc8_ = cc.bodyA.m_xf.position.y + (_loc5_.col1.y * _loc6_.x + _loc5_.col2.y * _loc6_.y);
               _loc5_ = cc.bodyB.m_xf.R;
               _loc17_ = 0;
               _loc18_ = cc.pointCount;
               while(_loc17_ < _loc18_)
               {
                  _loc19_ = _loc17_++;
                  _loc6_ = cc.points[_loc19_].localPoint;
                  _loc3_ = cc.bodyB.m_xf.position.x + (_loc5_.col1.x * _loc6_.x + _loc5_.col2.x * _loc6_.y);
                  _loc4_ = cc.bodyB.m_xf.position.y + (_loc5_.col1.y * _loc6_.x + _loc5_.col2.y * _loc6_.y);
                  m_separations[_loc19_] = (_loc3_ - _loc7_) * m_normal.x + (_loc4_ - _loc8_) * m_normal.y - cc.radius;
                  m_points[_loc19_].x = _loc3_;
                  m_points[_loc19_].y = _loc4_;
               }
               break;
            case 2:
               _loc5_ = cc.bodyB.m_xf.R;
               _loc6_ = cc.localPlaneNormal;
               m_normal.x = _loc5_.col1.x * _loc6_.x + _loc5_.col2.x * _loc6_.y;
               m_normal.y = _loc5_.col1.y * _loc6_.x + _loc5_.col2.y * _loc6_.y;
               _loc5_ = cc.bodyB.m_xf.R;
               _loc6_ = cc.localPoint;
               _loc7_ = cc.bodyB.m_xf.position.x + (_loc5_.col1.x * _loc6_.x + _loc5_.col2.x * _loc6_.y);
               _loc8_ = cc.bodyB.m_xf.position.y + (_loc5_.col1.y * _loc6_.x + _loc5_.col2.y * _loc6_.y);
               _loc5_ = cc.bodyA.m_xf.R;
               _loc17_ = 0;
               _loc18_ = cc.pointCount;
               while(_loc17_ < _loc18_)
               {
                  _loc19_ = _loc17_++;
                  _loc6_ = cc.points[_loc19_].localPoint;
                  _loc3_ = cc.bodyA.m_xf.position.x + (_loc5_.col1.x * _loc6_.x + _loc5_.col2.x * _loc6_.y);
                  _loc4_ = cc.bodyA.m_xf.position.y + (_loc5_.col1.y * _loc6_.x + _loc5_.col2.y * _loc6_.y);
                  m_separations[_loc19_] = (_loc3_ - _loc7_) * m_normal.x + (_loc4_ - _loc8_) * m_normal.y - cc.radius;
                  m_points[_loc19_].set(_loc3_,_loc4_);
               }
               m_normal.x *= -1;
               m_normal.y *= -1;
         }
      }
   }
}

