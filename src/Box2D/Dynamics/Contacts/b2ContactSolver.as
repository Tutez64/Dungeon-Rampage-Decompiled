package Box2D.Dynamics.Contacts
{
   import Box2D.Collision.Shapes.b2Shape;
   import Box2D.Collision.b2Manifold;
   import Box2D.Collision.b2ManifoldPoint;
   import Box2D.Collision.b2WorldManifold;
   import Box2D.Common.Math.b2Mat22;
   import Box2D.Common.Math.b2Math;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Common.b2Settings;
   import Box2D.Dynamics.b2Body;
   import Box2D.Dynamics.b2Fixture;
   import Box2D.Dynamics.b2TimeStep;
   import box2dcompat.As3Array;
   import flash.Boot;
   
   public class b2ContactSolver
   {
      
      public static var staticFix:int = b2Settings.b2_maxManifoldPoints;
      
      public static var s_worldManifold:b2WorldManifold = new b2WorldManifold();
      
      public static var s_psm:b2PositionSolverManifold = new b2PositionSolverManifold();
      
      public var m_step:b2TimeStep;
      
      public var m_constraints:Array;
      
      public var m_constraintCount:int;
      
      public var m_allocator:*;
      
      public function b2ContactSolver()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         m_constraintCount = 0;
         m_step = new b2TimeStep();
         m_constraints = [];
      }
      
      public function solveVelocityConstraints() : void
      {
         SolveVelocityConstraints();
      }
      
      public function solvePositionConstraints(baumgarte:Number) : Boolean
      {
         return SolvePositionConstraints(baumgarte);
      }
      
      public function initialize(step:b2TimeStep, contacts:Array, contactCount:int, allocator:*) : void
      {
         var _loc5_:* = null as b2Contact;
         var _loc11_:int = 0;
         var _loc12_:* = null as b2Fixture;
         var _loc13_:* = null as b2Fixture;
         var _loc14_:* = null as b2Shape;
         var _loc15_:* = null as b2Shape;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:* = null as b2Body;
         var _loc19_:* = null as b2Body;
         var _loc20_:* = null as b2Manifold;
         var _loc21_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc24_:Number = NaN;
         var _loc25_:Number = NaN;
         var _loc26_:Number = NaN;
         var _loc27_:Number = NaN;
         var _loc28_:Number = NaN;
         var _loc29_:Number = NaN;
         var _loc30_:Number = NaN;
         var _loc31_:* = null as b2ContactConstraint;
         var _loc32_:int = 0;
         var _loc33_:int = 0;
         var _loc34_:int = 0;
         var _loc35_:* = null as b2ManifoldPoint;
         var _loc36_:* = null as b2ContactConstraintPoint;
         var _loc37_:Number = NaN;
         var _loc38_:Number = NaN;
         var _loc39_:Number = NaN;
         var _loc40_:Number = NaN;
         var _loc41_:Number = NaN;
         var _loc42_:Number = NaN;
         var _loc43_:Number = NaN;
         var _loc44_:Number = NaN;
         var _loc45_:Number = NaN;
         var _loc46_:Number = NaN;
         var _loc47_:Number = NaN;
         var _loc48_:Number = NaN;
         var _loc49_:Number = NaN;
         var _loc50_:Number = NaN;
         var _loc51_:Number = NaN;
         var _loc52_:Number = NaN;
         var _loc53_:* = null as b2ContactConstraintPoint;
         m_step.set(step);
         m_allocator = allocator;
         m_constraintCount = contactCount;
         while(int(m_constraints.length) < m_constraintCount)
         {
            m_constraints[int(m_constraints.length)] = new b2ContactConstraint();
         }
         var _loc9_:int = 0;
         var _loc10_:int = contactCount;
         while(_loc9_ < _loc10_)
         {
            _loc11_ = _loc9_++;
            _loc5_ = contacts[_loc11_];
            _loc12_ = _loc5_.m_fixtureA;
            _loc13_ = _loc5_.m_fixtureB;
            _loc14_ = _loc12_.m_shape;
            _loc15_ = _loc13_.m_shape;
            _loc16_ = _loc14_.m_radius;
            _loc17_ = _loc15_.m_radius;
            _loc18_ = _loc12_.m_body;
            _loc19_ = _loc13_.m_body;
            _loc20_ = _loc5_.getManifold();
            _loc21_ = b2Settings.b2MixFriction(_loc12_.getFriction(),_loc13_.getFriction());
            _loc22_ = b2Settings.b2MixRestitution(_loc12_.getRestitution(),_loc13_.getRestitution());
            _loc23_ = _loc18_.m_linearVelocity.x;
            _loc24_ = _loc18_.m_linearVelocity.y;
            _loc25_ = _loc19_.m_linearVelocity.x;
            _loc26_ = _loc19_.m_linearVelocity.y;
            _loc27_ = _loc18_.m_angularVelocity;
            _loc28_ = _loc19_.m_angularVelocity;
            b2Settings.b2Assert(_loc20_.m_pointCount > 0);
            b2ContactSolver.s_worldManifold.initialize(_loc20_,_loc18_.m_xf,_loc16_,_loc19_.m_xf,_loc17_);
            _loc29_ = b2ContactSolver.s_worldManifold.m_normal.x;
            _loc30_ = b2ContactSolver.s_worldManifold.m_normal.y;
            _loc31_ = m_constraints[_loc11_];
            _loc31_.bodyA = _loc18_;
            _loc31_.bodyB = _loc19_;
            _loc31_.manifold = _loc20_;
            _loc31_.normal.x = _loc29_;
            _loc31_.normal.y = _loc30_;
            _loc31_.pointCount = _loc20_.m_pointCount;
            _loc31_.friction = _loc21_;
            _loc31_.restitution = _loc22_;
            _loc31_.localPlaneNormal.x = _loc20_.m_localPlaneNormal.x;
            _loc31_.localPlaneNormal.y = _loc20_.m_localPlaneNormal.y;
            _loc31_.localPoint.x = _loc20_.m_localPoint.x;
            _loc31_.localPoint.y = _loc20_.m_localPoint.y;
            _loc31_.radius = _loc16_ + _loc17_;
            _loc31_.type = _loc20_.m_type;
            _loc32_ = 0;
            _loc33_ = _loc31_.pointCount;
            while(_loc32_ < _loc33_)
            {
               _loc34_ = _loc32_++;
               _loc35_ = _loc20_.m_points[_loc34_];
               _loc36_ = _loc31_.points[_loc34_];
               _loc36_.normalImpulse = _loc35_.m_normalImpulse;
               _loc36_.tangentImpulse = _loc35_.m_tangentImpulse;
               _loc36_.localPoint.setV(_loc35_.m_localPoint);
               _loc37_ = _loc36_.rA.x = b2ContactSolver.s_worldManifold.m_points[_loc34_].x - _loc18_.m_sweep.c.x;
               _loc38_ = _loc36_.rA.y = b2ContactSolver.s_worldManifold.m_points[_loc34_].y - _loc18_.m_sweep.c.y;
               _loc39_ = _loc36_.rB.x = b2ContactSolver.s_worldManifold.m_points[_loc34_].x - _loc19_.m_sweep.c.x;
               _loc40_ = _loc36_.rB.y = b2ContactSolver.s_worldManifold.m_points[_loc34_].y - _loc19_.m_sweep.c.y;
               _loc41_ = _loc37_ * _loc30_ - _loc38_ * _loc29_;
               _loc42_ = _loc39_ * _loc30_ - _loc40_ * _loc29_;
               _loc41_ *= _loc41_;
               _loc42_ *= _loc42_;
               _loc43_ = _loc18_.m_invMass + _loc19_.m_invMass + _loc18_.m_invI * _loc41_ + _loc19_.m_invI * _loc42_;
               _loc36_.normalMass = 1 / _loc43_;
               _loc44_ = _loc18_.m_mass * _loc18_.m_invMass + _loc19_.m_mass * _loc19_.m_invMass;
               _loc44_ = _loc44_ + (_loc18_.m_mass * _loc18_.m_invI * _loc41_ + _loc19_.m_mass * _loc19_.m_invI * _loc42_);
               _loc36_.equalizedMass = 1 / _loc44_;
               _loc45_ = _loc30_;
               _loc46_ = -_loc29_;
               _loc47_ = _loc37_ * _loc46_ - _loc38_ * _loc45_;
               _loc48_ = _loc39_ * _loc46_ - _loc40_ * _loc45_;
               _loc47_ *= _loc47_;
               _loc48_ *= _loc48_;
               _loc49_ = _loc18_.m_invMass + _loc19_.m_invMass + _loc18_.m_invI * _loc47_ + _loc19_.m_invI * _loc48_;
               _loc36_.tangentMass = 1 / _loc49_;
               _loc36_.velocityBias = 0;
               _loc50_ = _loc25_ + -_loc28_ * _loc40_ - _loc23_ - -_loc27_ * _loc38_;
               _loc51_ = _loc26_ + _loc28_ * _loc39_ - _loc24_ - _loc27_ * _loc37_;
               _loc52_ = _loc31_.normal.x * _loc50_ + _loc31_.normal.y * _loc51_;
               if(_loc52_ < -b2Settings.b2_velocityThreshold)
               {
                  _loc36_.velocityBias += -_loc31_.restitution * _loc52_;
               }
            }
            if(_loc31_.pointCount == 2)
            {
               _loc36_ = _loc31_.points[0];
               _loc53_ = _loc31_.points[1];
               _loc37_ = _loc18_.m_invMass;
               _loc38_ = _loc18_.m_invI;
               _loc39_ = _loc19_.m_invMass;
               _loc40_ = _loc19_.m_invI;
               _loc41_ = _loc36_.rA.x * _loc30_ - _loc36_.rA.y * _loc29_;
               _loc42_ = _loc36_.rB.x * _loc30_ - _loc36_.rB.y * _loc29_;
               _loc43_ = _loc53_.rA.x * _loc30_ - _loc53_.rA.y * _loc29_;
               _loc44_ = _loc53_.rB.x * _loc30_ - _loc53_.rB.y * _loc29_;
               _loc45_ = _loc37_ + _loc39_ + _loc38_ * _loc41_ * _loc41_ + _loc40_ * _loc42_ * _loc42_;
               _loc46_ = _loc37_ + _loc39_ + _loc38_ * _loc43_ * _loc43_ + _loc40_ * _loc44_ * _loc44_;
               _loc47_ = _loc37_ + _loc39_ + _loc38_ * _loc41_ * _loc43_ + _loc40_ * _loc42_ * _loc44_;
               _loc48_ = 100;
               if(_loc45_ * _loc45_ < _loc48_ * (_loc45_ * _loc46_ - _loc47_ * _loc47_))
               {
                  _loc31_.K.col1.set(_loc45_,_loc47_);
                  _loc31_.K.col2.set(_loc47_,_loc46_);
                  _loc31_.K.getInverse(_loc31_.normalMass);
               }
               else
               {
                  _loc31_.pointCount = 1;
               }
            }
         }
      }
      
      public function initVelocityConstraints(step:b2TimeStep) : void
      {
         InitVelocityConstraints(step);
      }
      
      public function finalizeVelocityConstraints() : void
      {
         FinalizeVelocityConstraints();
      }
      
      public function SolveVelocityConstraints() : void
      {
         var _loc2_:* = null as b2ContactConstraintPoint;
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
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc22_:* = null as b2Mat22;
         var _loc26_:int = 0;
         var _loc27_:* = null as b2ContactConstraint;
         var _loc28_:* = null as b2Body;
         var _loc29_:* = null as b2Body;
         var _loc30_:Number = NaN;
         var _loc31_:Number = NaN;
         var _loc32_:* = null as b2Vec2;
         var _loc33_:* = null as b2Vec2;
         var _loc34_:Number = NaN;
         var _loc35_:Number = NaN;
         var _loc36_:Number = NaN;
         var _loc37_:Number = NaN;
         var _loc38_:Number = NaN;
         var _loc39_:Number = NaN;
         var _loc40_:Number = NaN;
         var _loc41_:Number = NaN;
         var _loc42_:Number = NaN;
         var _loc44_:int = 0;
         var _loc45_:int = 0;
         var _loc46_:int = 0;
         var _loc47_:* = null as b2ContactConstraintPoint;
         var _loc48_:* = null as b2ContactConstraintPoint;
         var _loc49_:Number = NaN;
         var _loc50_:Number = NaN;
         var _loc51_:Number = NaN;
         var _loc52_:Number = NaN;
         var _loc53_:Number = NaN;
         var _loc54_:Number = NaN;
         var _loc55_:Number = NaN;
         var _loc56_:Number = NaN;
         var _loc57_:Number = NaN;
         var _loc58_:Number = NaN;
         var _loc59_:Number = NaN;
         var _loc60_:Number = NaN;
         var _loc61_:Number = NaN;
         var _loc24_:int = 0;
         var _loc25_:int = m_constraintCount;
         while(_loc24_ < _loc25_)
         {
            _loc26_ = _loc24_++;
            _loc27_ = m_constraints[_loc26_];
            _loc28_ = _loc27_.bodyA;
            _loc29_ = _loc27_.bodyB;
            _loc30_ = _loc28_.m_angularVelocity;
            _loc31_ = _loc29_.m_angularVelocity;
            _loc32_ = _loc28_.m_linearVelocity;
            _loc33_ = _loc29_.m_linearVelocity;
            _loc34_ = _loc28_.m_invMass;
            _loc35_ = _loc28_.m_invI;
            _loc36_ = _loc29_.m_invMass;
            _loc37_ = _loc29_.m_invI;
            _loc38_ = _loc27_.normal.x;
            _loc40_ = _loc39_ = _loc27_.normal.y;
            _loc41_ = -_loc38_;
            _loc42_ = _loc27_.friction;
            _loc44_ = 0;
            _loc45_ = _loc27_.pointCount;
            while(_loc44_ < _loc45_)
            {
               _loc46_ = _loc44_++;
               _loc2_ = _loc27_.points[_loc46_];
               _loc7_ = _loc33_.x - _loc31_ * _loc2_.rB.y - _loc32_.x + _loc30_ * _loc2_.rA.y;
               _loc8_ = _loc33_.y + _loc31_ * _loc2_.rB.x - _loc32_.y - _loc30_ * _loc2_.rA.x;
               _loc10_ = _loc7_ * _loc40_ + _loc8_ * _loc41_;
               _loc11_ = _loc2_.tangentMass * -_loc10_;
               _loc12_ = _loc42_ * _loc2_.normalImpulse;
               _loc13_ = b2Math.clamp(_loc2_.tangentImpulse + _loc11_,-_loc12_,_loc12_);
               _loc11_ = _loc13_ - _loc2_.tangentImpulse;
               _loc14_ = _loc11_ * _loc40_;
               _loc15_ = _loc11_ * _loc41_;
               _loc32_.x -= _loc34_ * _loc14_;
               _loc32_.y -= _loc34_ * _loc15_;
               _loc30_ -= _loc35_ * (_loc2_.rA.x * _loc15_ - _loc2_.rA.y * _loc14_);
               _loc33_.x += _loc36_ * _loc14_;
               _loc33_.y += _loc36_ * _loc15_;
               _loc31_ += _loc37_ * (_loc2_.rB.x * _loc15_ - _loc2_.rB.y * _loc14_);
               _loc2_.tangentImpulse = _loc13_;
            }
            _loc44_ = _loc27_.pointCount;
            if(_loc27_.pointCount == 1)
            {
               _loc2_ = _loc27_.points[0];
               _loc7_ = _loc33_.x + -_loc31_ * _loc2_.rB.y - _loc32_.x - -_loc30_ * _loc2_.rA.y;
               _loc8_ = _loc33_.y + _loc31_ * _loc2_.rB.x - _loc32_.y - _loc30_ * _loc2_.rA.x;
               _loc9_ = _loc7_ * _loc38_ + _loc8_ * _loc39_;
               _loc11_ = -_loc2_.normalMass * (_loc9_ - _loc2_.velocityBias);
               _loc13_ = _loc2_.normalImpulse + _loc11_;
               if(_loc13_ <= 0)
               {
                  _loc13_ = 0;
               }
               _loc11_ = _loc13_ - _loc2_.normalImpulse;
               _loc14_ = _loc11_ * _loc38_;
               _loc15_ = _loc11_ * _loc39_;
               _loc32_.x -= _loc34_ * _loc14_;
               _loc32_.y -= _loc34_ * _loc15_;
               _loc30_ -= _loc35_ * (_loc2_.rA.x * _loc15_ - _loc2_.rA.y * _loc14_);
               _loc33_.x += _loc36_ * _loc14_;
               _loc33_.y += _loc36_ * _loc15_;
               _loc31_ += _loc37_ * (_loc2_.rB.x * _loc15_ - _loc2_.rB.y * _loc14_);
               _loc2_.normalImpulse = _loc13_;
            }
            else
            {
               _loc47_ = _loc27_.points[0];
               _loc48_ = _loc27_.points[1];
               _loc49_ = _loc47_.normalImpulse;
               _loc50_ = _loc48_.normalImpulse;
               _loc51_ = _loc33_.x - _loc31_ * _loc47_.rB.y - _loc32_.x + _loc30_ * _loc47_.rA.y;
               _loc52_ = _loc33_.y + _loc31_ * _loc47_.rB.x - _loc32_.y - _loc30_ * _loc47_.rA.x;
               _loc53_ = _loc33_.x - _loc31_ * _loc48_.rB.y - _loc32_.x + _loc30_ * _loc48_.rA.y;
               _loc54_ = _loc33_.y + _loc31_ * _loc48_.rB.x - _loc32_.y - _loc30_ * _loc48_.rA.x;
               _loc55_ = _loc51_ * _loc38_ + _loc52_ * _loc39_;
               _loc56_ = _loc53_ * _loc38_ + _loc54_ * _loc39_;
               _loc57_ = _loc55_ - _loc47_.velocityBias;
               _loc58_ = _loc56_ - _loc48_.velocityBias;
               _loc22_ = _loc27_.K;
               _loc57_ -= _loc22_.col1.x * _loc49_ + _loc22_.col2.x * _loc50_;
               _loc58_ -= _loc22_.col1.y * _loc49_ + _loc22_.col2.y * _loc50_;
               _loc59_ = 0.001;
               _loc45_ = 0;
               if(_loc45_ < 1)
               {
                  _loc46_ = _loc45_++;
                  _loc22_ = _loc27_.normalMass;
                  _loc60_ = -(_loc22_.col1.x * _loc57_ + _loc22_.col2.x * _loc58_);
                  _loc61_ = -(_loc22_.col1.y * _loc57_ + _loc22_.col2.y * _loc58_);
                  if(_loc60_ >= 0 && _loc61_ >= 0)
                  {
                     _loc16_ = _loc60_ - _loc49_;
                     _loc17_ = _loc61_ - _loc50_;
                     _loc18_ = _loc16_ * _loc38_;
                     _loc19_ = _loc16_ * _loc39_;
                     _loc20_ = _loc17_ * _loc38_;
                     _loc21_ = _loc17_ * _loc39_;
                     _loc32_.x -= _loc34_ * (_loc18_ + _loc20_);
                     _loc32_.y -= _loc34_ * (_loc19_ + _loc21_);
                     _loc30_ -= _loc35_ * (_loc47_.rA.x * _loc19_ - _loc47_.rA.y * _loc18_ + _loc48_.rA.x * _loc21_ - _loc48_.rA.y * _loc20_);
                     _loc33_.x += _loc36_ * (_loc18_ + _loc20_);
                     _loc33_.y += _loc36_ * (_loc19_ + _loc21_);
                     _loc31_ += _loc37_ * (_loc47_.rB.x * _loc19_ - _loc47_.rB.y * _loc18_ + _loc48_.rB.x * _loc21_ - _loc48_.rB.y * _loc20_);
                     _loc47_.normalImpulse = _loc60_;
                     _loc48_.normalImpulse = _loc61_;
                  }
                  else
                  {
                     _loc60_ = -_loc47_.normalMass * _loc57_;
                     _loc61_ = 0;
                     _loc55_ = 0;
                     _loc56_ = _loc27_.K.col1.y * _loc60_ + _loc58_;
                     if(_loc60_ >= 0 && _loc56_ >= 0)
                     {
                        _loc16_ = _loc60_ - _loc49_;
                        _loc17_ = _loc61_ - _loc50_;
                        _loc18_ = _loc16_ * _loc38_;
                        _loc19_ = _loc16_ * _loc39_;
                        _loc20_ = _loc17_ * _loc38_;
                        _loc21_ = _loc17_ * _loc39_;
                        _loc32_.x -= _loc34_ * (_loc18_ + _loc20_);
                        _loc32_.y -= _loc34_ * (_loc19_ + _loc21_);
                        _loc30_ -= _loc35_ * (_loc47_.rA.x * _loc19_ - _loc47_.rA.y * _loc18_ + _loc48_.rA.x * _loc21_ - _loc48_.rA.y * _loc20_);
                        _loc33_.x += _loc36_ * (_loc18_ + _loc20_);
                        _loc33_.y += _loc36_ * (_loc19_ + _loc21_);
                        _loc31_ += _loc37_ * (_loc47_.rB.x * _loc19_ - _loc47_.rB.y * _loc18_ + _loc48_.rB.x * _loc21_ - _loc48_.rB.y * _loc20_);
                        _loc47_.normalImpulse = _loc60_;
                        _loc48_.normalImpulse = _loc61_;
                     }
                     else
                     {
                        _loc60_ = 0;
                        _loc61_ = -_loc48_.normalMass * _loc58_;
                        _loc55_ = _loc27_.K.col2.x * _loc61_ + _loc57_;
                        _loc56_ = 0;
                        if(_loc61_ >= 0 && _loc55_ >= 0)
                        {
                           _loc16_ = _loc60_ - _loc49_;
                           _loc17_ = _loc61_ - _loc50_;
                           _loc18_ = _loc16_ * _loc38_;
                           _loc19_ = _loc16_ * _loc39_;
                           _loc20_ = _loc17_ * _loc38_;
                           _loc21_ = _loc17_ * _loc39_;
                           _loc32_.x -= _loc34_ * (_loc18_ + _loc20_);
                           _loc32_.y -= _loc34_ * (_loc19_ + _loc21_);
                           _loc30_ -= _loc35_ * (_loc47_.rA.x * _loc19_ - _loc47_.rA.y * _loc18_ + _loc48_.rA.x * _loc21_ - _loc48_.rA.y * _loc20_);
                           _loc33_.x += _loc36_ * (_loc18_ + _loc20_);
                           _loc33_.y += _loc36_ * (_loc19_ + _loc21_);
                           _loc31_ += _loc37_ * (_loc47_.rB.x * _loc19_ - _loc47_.rB.y * _loc18_ + _loc48_.rB.x * _loc21_ - _loc48_.rB.y * _loc20_);
                           _loc47_.normalImpulse = _loc60_;
                           _loc48_.normalImpulse = _loc61_;
                        }
                        else
                        {
                           _loc60_ = 0;
                           _loc61_ = 0;
                           _loc55_ = _loc57_;
                           _loc56_ = _loc58_;
                           if(_loc55_ >= 0 && _loc56_ >= 0)
                           {
                              _loc16_ = _loc60_ - _loc49_;
                              _loc17_ = _loc61_ - _loc50_;
                              _loc18_ = _loc16_ * _loc38_;
                              _loc19_ = _loc16_ * _loc39_;
                              _loc20_ = _loc17_ * _loc38_;
                              _loc21_ = _loc17_ * _loc39_;
                              _loc32_.x -= _loc34_ * (_loc18_ + _loc20_);
                              _loc32_.y -= _loc34_ * (_loc19_ + _loc21_);
                              _loc30_ -= _loc35_ * (_loc47_.rA.x * _loc19_ - _loc47_.rA.y * _loc18_ + _loc48_.rA.x * _loc21_ - _loc48_.rA.y * _loc20_);
                              _loc33_.x += _loc36_ * (_loc18_ + _loc20_);
                              _loc33_.y += _loc36_ * (_loc19_ + _loc21_);
                              _loc31_ += _loc37_ * (_loc47_.rB.x * _loc19_ - _loc47_.rB.y * _loc18_ + _loc48_.rB.x * _loc21_ - _loc48_.rB.y * _loc20_);
                              _loc47_.normalImpulse = _loc60_;
                              _loc48_.normalImpulse = _loc61_;
                           }
                        }
                     }
                  }
               }
            }
            _loc28_.m_angularVelocity = _loc30_;
            _loc29_.m_angularVelocity = _loc31_;
         }
      }
      
      public function SolvePositionConstraints(baumgarte:Number) : Boolean
      {
         var _loc5_:int = 0;
         var _loc6_:* = null as b2ContactConstraint;
         var _loc7_:* = null as b2Body;
         var _loc8_:* = null as b2Body;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:* = null as b2Vec2;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc17_:* = null as b2ContactConstraintPoint;
         var _loc18_:* = null as b2Vec2;
         var _loc19_:Number = NaN;
         var _loc20_:Number = NaN;
         var _loc21_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc24_:Number = NaN;
         var _loc25_:Number = NaN;
         var _loc26_:Number = NaN;
         var _loc27_:Number = NaN;
         var _loc2_:Number = 0;
         var _loc3_:int = 0;
         var _loc4_:int = m_constraintCount;
         while(_loc3_ < _loc4_)
         {
            _loc5_ = _loc3_++;
            _loc6_ = m_constraints[_loc5_];
            _loc7_ = _loc6_.bodyA;
            _loc8_ = _loc6_.bodyB;
            _loc9_ = _loc7_.m_mass * _loc7_.m_invMass;
            _loc10_ = _loc7_.m_mass * _loc7_.m_invI;
            _loc11_ = _loc8_.m_mass * _loc8_.m_invMass;
            _loc12_ = _loc8_.m_mass * _loc8_.m_invI;
            b2ContactSolver.s_psm.initialize(_loc6_);
            _loc13_ = b2ContactSolver.s_psm.m_normal;
            _loc14_ = 0;
            _loc15_ = _loc6_.pointCount;
            while(_loc14_ < _loc15_)
            {
               _loc16_ = _loc14_++;
               _loc17_ = _loc6_.points[_loc16_];
               _loc18_ = b2ContactSolver.s_psm.m_points[_loc16_];
               _loc19_ = Number(b2ContactSolver.s_psm.m_separations[_loc16_]);
               _loc20_ = _loc18_.x - _loc7_.m_sweep.c.x;
               _loc21_ = _loc18_.y - _loc7_.m_sweep.c.y;
               _loc22_ = _loc18_.x - _loc8_.m_sweep.c.x;
               _loc23_ = _loc18_.y - _loc8_.m_sweep.c.y;
               if(_loc2_ >= _loc19_)
               {
                  _loc2_ = _loc19_;
               }
               _loc24_ = b2Math.clamp(baumgarte * (_loc19_ + b2Settings.b2_linearSlop),-b2Settings.b2_maxLinearCorrection,0);
               _loc25_ = -_loc17_.equalizedMass * _loc24_;
               _loc26_ = _loc25_ * _loc13_.x;
               _loc27_ = _loc25_ * _loc13_.y;
               _loc7_.m_sweep.c.x -= _loc9_ * _loc26_;
               _loc7_.m_sweep.c.y -= _loc9_ * _loc27_;
               _loc7_.m_sweep.a -= _loc10_ * (_loc20_ * _loc27_ - _loc21_ * _loc26_);
               _loc7_.synchronizeTransform();
               _loc8_.m_sweep.c.x += _loc11_ * _loc26_;
               _loc8_.m_sweep.c.y += _loc11_ * _loc27_;
               _loc8_.m_sweep.a += _loc12_ * (_loc22_ * _loc27_ - _loc23_ * _loc26_);
               _loc8_.synchronizeTransform();
            }
         }
         return _loc2_ > -1.5 * b2Settings.b2_linearSlop;
      }
      
      public function Initialize(step:b2TimeStep, contacts:*, contactCount:int, allocator:*) : void
      {
         initialize(step,As3Array.of(contacts),contactCount,allocator);
      }
      
      public function InitVelocityConstraints(step:b2TimeStep) : void
      {
         var _loc7_:int = 0;
         var _loc8_:* = null as b2ContactConstraint;
         var _loc9_:* = null as b2Body;
         var _loc10_:* = null as b2Body;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc21_:int = 0;
         var _loc22_:int = 0;
         var _loc23_:int = 0;
         var _loc24_:int = 0;
         var _loc25_:* = null as b2ContactConstraintPoint;
         var _loc26_:Number = NaN;
         var _loc27_:Number = NaN;
         var _loc5_:int = 0;
         var _loc6_:int = m_constraintCount;
         while(_loc5_ < _loc6_)
         {
            _loc7_ = _loc5_++;
            _loc8_ = m_constraints[_loc7_];
            _loc9_ = _loc8_.bodyA;
            _loc10_ = _loc8_.bodyB;
            _loc11_ = _loc9_.m_invMass;
            _loc12_ = _loc9_.m_invI;
            _loc13_ = _loc10_.m_invMass;
            _loc14_ = _loc10_.m_invI;
            _loc15_ = _loc8_.normal.x;
            _loc17_ = _loc16_ = _loc8_.normal.y;
            _loc18_ = -_loc15_;
            if(step.warmStarting)
            {
               _loc21_ = _loc8_.pointCount;
               _loc22_ = 0;
               _loc23_ = _loc21_;
               while(_loc22_ < _loc23_)
               {
                  _loc24_ = _loc22_++;
                  _loc25_ = _loc8_.points[_loc24_];
                  _loc25_.normalImpulse *= step.dtRatio;
                  _loc25_.tangentImpulse *= step.dtRatio;
                  _loc26_ = _loc25_.normalImpulse * _loc15_ + _loc25_.tangentImpulse * _loc17_;
                  _loc27_ = _loc25_.normalImpulse * _loc16_ + _loc25_.tangentImpulse * _loc18_;
                  _loc9_.m_angularVelocity -= _loc12_ * (_loc25_.rA.x * _loc27_ - _loc25_.rA.y * _loc26_);
                  _loc9_.m_linearVelocity.x -= _loc11_ * _loc26_;
                  _loc9_.m_linearVelocity.y -= _loc11_ * _loc27_;
                  _loc10_.m_angularVelocity += _loc14_ * (_loc25_.rB.x * _loc27_ - _loc25_.rB.y * _loc26_);
                  _loc10_.m_linearVelocity.x += _loc13_ * _loc26_;
                  _loc10_.m_linearVelocity.y += _loc13_ * _loc27_;
               }
            }
            else
            {
               _loc21_ = _loc8_.pointCount;
               _loc22_ = 0;
               _loc23_ = _loc21_;
               while(_loc22_ < _loc23_)
               {
                  _loc24_ = _loc22_++;
                  _loc25_ = _loc8_.points[_loc24_];
                  _loc25_.normalImpulse = 0;
                  _loc25_.tangentImpulse = 0;
               }
            }
         }
      }
      
      public function FinalizeVelocityConstraints() : void
      {
         var _loc3_:int = 0;
         var _loc4_:* = null as b2ContactConstraint;
         var _loc5_:* = null as b2Manifold;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:* = null as b2ManifoldPoint;
         var _loc10_:* = null as b2ContactConstraintPoint;
         var _loc1_:int = 0;
         var _loc2_:int = m_constraintCount;
         while(_loc1_ < _loc2_)
         {
            _loc3_ = _loc1_++;
            _loc4_ = m_constraints[_loc3_];
            _loc5_ = _loc4_.manifold;
            _loc6_ = 0;
            _loc7_ = _loc4_.pointCount;
            while(_loc6_ < _loc7_)
            {
               _loc8_ = _loc6_++;
               _loc9_ = _loc5_.m_points[_loc8_];
               _loc10_ = _loc4_.points[_loc8_];
               _loc9_.m_normalImpulse = _loc10_.normalImpulse;
               _loc9_.m_tangentImpulse = _loc10_.tangentImpulse;
            }
         }
      }
   }
}

