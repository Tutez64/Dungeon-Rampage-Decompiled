package Box2D.Dynamics.Joints
{
   import Box2D.Common.Math.b2Mat22;
   import Box2D.Common.Math.b2Mat33;
   import Box2D.Common.Math.b2Math;
   import Box2D.Common.Math.b2Transform;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Common.Math.b2Vec3;
   import Box2D.Common.b2Settings;
   import Box2D.Dynamics.b2Body;
   import Box2D.Dynamics.b2TimeStep;
   import flash.Boot;
   
   public class b2PrismaticJoint extends b2Joint
   {
      
      public var m_upperTranslation:Number;
      
      public var m_s2:Number;
      
      public var m_s1:Number;
      
      public var m_refAngle:Number;
      
      public var m_perp:b2Vec2;
      
      public var m_motorSpeed:Number;
      
      public var m_motorMass:Number;
      
      public var m_motorImpulse:Number;
      
      public var m_maxMotorForce:Number;
      
      public var m_lowerTranslation:Number;
      
      public var m_localYAxis1:b2Vec2;
      
      public var m_localXAxis1:b2Vec2;
      
      public var m_localAnchor2:b2Vec2;
      
      public var m_localAnchor1:b2Vec2;
      
      public var m_limitState:int;
      
      public var m_impulse:b2Vec3;
      
      public var m_enableMotor:Boolean;
      
      public var m_enableLimit:Boolean;
      
      public var m_axis:b2Vec2;
      
      public var m_a2:Number;
      
      public var m_a1:Number;
      
      public var m_K:b2Mat33;
      
      public function b2PrismaticJoint(def:b2PrismaticJointDef = undefined)
      {
         if(!Boot.skip_constructor)
         {
            super(def);
            m_localAnchor1 = new b2Vec2();
            m_localAnchor2 = new b2Vec2();
            m_localXAxis1 = new b2Vec2();
            m_localYAxis1 = new b2Vec2();
            m_axis = new b2Vec2();
            m_perp = new b2Vec2();
            m_K = new b2Mat33();
            m_impulse = new b2Vec3();
            m_localAnchor1.setV(def.localAnchorA);
            m_localAnchor2.setV(def.localAnchorB);
            m_localXAxis1.setV(def.localAxisA);
            m_localYAxis1.x = -m_localXAxis1.y;
            m_localYAxis1.y = m_localXAxis1.x;
            m_refAngle = def.referenceAngle;
            m_impulse.setZero();
            m_motorMass = 0;
            m_motorImpulse = 0;
            m_lowerTranslation = def.lowerTranslation;
            m_upperTranslation = def.upperTranslation;
            m_maxMotorForce = def.maxMotorForce;
            m_motorSpeed = def.motorSpeed;
            m_enableLimit = def.enableLimit;
            m_enableMotor = def.enableMotor;
            m_limitState = 0;
            m_axis.setZero();
            m_perp.setZero();
         }
      }
      
      override public function solveVelocityConstraints(step:b2TimeStep) : void
      {
         SolveVelocityConstraints(step);
      }
      
      override public function solvePositionConstraints(baumgarte:Number) : Boolean
      {
         return SolvePositionConstraints(baumgarte);
      }
      
      public function setMotorSpeed(speed:Number) : void
      {
         SetMotorSpeed(speed);
      }
      
      public function setMaxMotorForce(force:Number) : void
      {
         SetMaxMotorForce(force);
      }
      
      public function setLimits(lower:Number, upper:Number) : void
      {
         SetLimits(lower,upper);
      }
      
      public function isMotorEnabled() : Boolean
      {
         return IsMotorEnabled();
      }
      
      public function isLimitEnabled() : Boolean
      {
         return IsLimitEnabled();
      }
      
      override public function initVelocityConstraints(step:b2TimeStep) : void
      {
         InitVelocityConstraints(step);
      }
      
      public function getUpperLimit() : Number
      {
         return GetUpperLimit();
      }
      
      override public function getReactionTorque(inv_dt:Number) : Number
      {
         return GetReactionTorque(inv_dt);
      }
      
      override public function getReactionForce(inv_dt:Number) : b2Vec2
      {
         return GetReactionForce(inv_dt);
      }
      
      public function getMotorSpeed() : Number
      {
         return GetMotorSpeed();
      }
      
      public function getMotorForce() : Number
      {
         return GetMotorForce();
      }
      
      public function getLowerLimit() : Number
      {
         return GetLowerLimit();
      }
      
      public function getJointTranslation() : Number
      {
         return GetJointTranslation();
      }
      
      public function getJointSpeed() : Number
      {
         return GetJointSpeed();
      }
      
      override public function getAnchorB() : b2Vec2
      {
         return GetAnchorB();
      }
      
      override public function getAnchorA() : b2Vec2
      {
         return GetAnchorA();
      }
      
      public function enableMotor(flag:Boolean) : void
      {
         EnableMotor(flag);
      }
      
      public function enableLimit(flag:Boolean) : void
      {
         EnableLimit(flag);
      }
      
      override public function SolveVelocityConstraints(step:b2TimeStep) : void
      {
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:* = null as b2Vec3;
         var _loc17_:* = null as b2Vec3;
         var _loc18_:Number = NaN;
         var _loc19_:* = null as b2Vec2;
         var _loc2_:b2Body = m_bodyA;
         var _loc3_:b2Body = m_bodyB;
         var _loc4_:b2Vec2 = _loc2_.m_linearVelocity;
         var _loc5_:Number = _loc2_.m_angularVelocity;
         var _loc6_:b2Vec2 = _loc3_.m_linearVelocity;
         var _loc7_:Number = _loc3_.m_angularVelocity;
         if(m_enableMotor && m_limitState != 3)
         {
            _loc12_ = m_axis.x * (_loc6_.x - _loc4_.x) + m_axis.y * (_loc6_.y - _loc4_.y) + m_a2 * _loc7_ - m_a1 * _loc5_;
            _loc13_ = m_motorMass * (m_motorSpeed - _loc12_);
            _loc14_ = m_motorImpulse;
            _loc15_ = step.dt * m_maxMotorForce;
            m_motorImpulse = b2Math.clamp(m_motorImpulse + _loc13_,-_loc15_,_loc15_);
            _loc13_ = m_motorImpulse - _loc14_;
            _loc8_ = _loc13_ * m_axis.x;
            _loc9_ = _loc13_ * m_axis.y;
            _loc10_ = _loc13_ * m_a1;
            _loc11_ = _loc13_ * m_a2;
            _loc4_.x -= m_invMassA * _loc8_;
            _loc4_.y -= m_invMassA * _loc9_;
            _loc5_ -= m_invIA * _loc10_;
            _loc6_.x += m_invMassB * _loc8_;
            _loc6_.y += m_invMassB * _loc9_;
            _loc7_ += m_invIB * _loc11_;
         }
         _loc12_ = m_perp.x * (_loc6_.x - _loc4_.x) + m_perp.y * (_loc6_.y - _loc4_.y) + m_s2 * _loc7_ - m_s1 * _loc5_;
         _loc13_ = _loc7_ - _loc5_;
         if(m_enableLimit && m_limitState != 0)
         {
            _loc14_ = m_axis.x * (_loc6_.x - _loc4_.x) + m_axis.y * (_loc6_.y - _loc4_.y) + m_a2 * _loc7_ - m_a1 * _loc5_;
            _loc16_ = m_impulse.copy();
            _loc17_ = m_K.solve33(new b2Vec3(),-_loc12_,-_loc13_,-_loc14_);
            m_impulse.add(_loc17_);
            if(m_limitState == 1)
            {
               m_impulse.z = b2Math.max(m_impulse.z,0);
            }
            else if(m_limitState == 2)
            {
               m_impulse.z = b2Math.min(m_impulse.z,0);
            }
            _loc15_ = -_loc12_ - (m_impulse.z - _loc16_.z) * m_K.col3.x;
            _loc18_ = -_loc13_ - (m_impulse.z - _loc16_.z) * m_K.col3.y;
            _loc19_ = m_K.solve22(new b2Vec2(),_loc15_,_loc18_);
            _loc19_.x += _loc16_.x;
            _loc19_.y += _loc16_.y;
            m_impulse.x = _loc19_.x;
            m_impulse.y = _loc19_.y;
            _loc17_.x = m_impulse.x - _loc16_.x;
            _loc17_.y = m_impulse.y - _loc16_.y;
            _loc17_.z = m_impulse.z - _loc16_.z;
            _loc8_ = _loc17_.x * m_perp.x + _loc17_.z * m_axis.x;
            _loc9_ = _loc17_.x * m_perp.y + _loc17_.z * m_axis.y;
            _loc10_ = _loc17_.x * m_s1 + _loc17_.y + _loc17_.z * m_a1;
            _loc11_ = _loc17_.x * m_s2 + _loc17_.y + _loc17_.z * m_a2;
            _loc4_.x -= m_invMassA * _loc8_;
            _loc4_.y -= m_invMassA * _loc9_;
            _loc5_ -= m_invIA * _loc10_;
            _loc6_.x += m_invMassB * _loc8_;
            _loc6_.y += m_invMassB * _loc9_;
            _loc7_ += m_invIB * _loc11_;
         }
         else
         {
            _loc19_ = m_K.solve22(new b2Vec2(),-_loc12_,-_loc13_);
            m_impulse.x += _loc19_.x;
            m_impulse.y += _loc19_.y;
            _loc8_ = _loc19_.x * m_perp.x;
            _loc9_ = _loc19_.x * m_perp.y;
            _loc10_ = _loc19_.x * m_s1 + _loc19_.y;
            _loc11_ = _loc19_.x * m_s2 + _loc19_.y;
            _loc4_.x -= m_invMassA * _loc8_;
            _loc4_.y -= m_invMassA * _loc9_;
            _loc5_ -= m_invIA * _loc10_;
            _loc6_.x += m_invMassB * _loc8_;
            _loc6_.y += m_invMassB * _loc9_;
            _loc7_ += m_invIB * _loc11_;
         }
         _loc2_.m_linearVelocity.setV(_loc4_);
         _loc2_.m_angularVelocity = _loc5_;
         _loc3_.m_linearVelocity.setV(_loc6_);
         _loc3_.m_angularVelocity = _loc7_;
      }
      
      override public function SolvePositionConstraints(baumgarte:Number) : Boolean
      {
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc28_:Number = NaN;
         var _loc31_:Number = NaN;
         var _loc32_:Number = NaN;
         var _loc33_:Number = NaN;
         var _loc34_:* = null as b2Vec2;
         var _loc4_:b2Body = m_bodyA;
         var _loc5_:b2Body = m_bodyB;
         var _loc6_:b2Vec2 = _loc4_.m_sweep.c;
         var _loc7_:Number = _loc4_.m_sweep.a;
         var _loc8_:b2Vec2 = _loc5_.m_sweep.c;
         var _loc9_:Number = _loc5_.m_sweep.a;
         var _loc14_:Number = 0;
         var _loc15_:Number = 0;
         var _loc16_:Boolean = false;
         var _loc17_:Number = 0;
         var _loc18_:b2Mat22 = b2Mat22.fromAngle(_loc7_);
         var _loc19_:b2Mat22 = b2Mat22.fromAngle(_loc9_);
         var _loc20_:b2Mat22 = _loc18_;
         var _loc21_:Number = m_localAnchor1.x - m_localCenterA.x;
         var _loc22_:Number = m_localAnchor1.y - m_localCenterA.y;
         var _loc23_:Number = _loc20_.col1.x * _loc21_ + _loc20_.col2.x * _loc22_;
         _loc22_ = _loc20_.col1.y * _loc21_ + _loc20_.col2.y * _loc22_;
         _loc21_ = _loc23_;
         _loc20_ = _loc19_;
         var _loc24_:Number = m_localAnchor2.x - m_localCenterB.x;
         var _loc25_:Number = m_localAnchor2.y - m_localCenterB.y;
         _loc23_ = _loc20_.col1.x * _loc24_ + _loc20_.col2.x * _loc25_;
         _loc25_ = _loc20_.col1.y * _loc24_ + _loc20_.col2.y * _loc25_;
         _loc24_ = _loc23_;
         var _loc26_:Number = _loc8_.x + _loc24_ - _loc6_.x - _loc21_;
         var _loc27_:Number = _loc8_.y + _loc25_ - _loc6_.y - _loc22_;
         if(m_enableLimit)
         {
            m_axis = b2Math.mulMV(_loc18_,m_localXAxis1);
            m_a1 = (_loc26_ + _loc21_) * m_axis.y - (_loc27_ + _loc22_) * m_axis.x;
            m_a2 = _loc24_ * m_axis.y - _loc25_ * m_axis.x;
            _loc28_ = m_axis.x * _loc26_ + m_axis.y * _loc27_;
            if(b2Math.abs(m_upperTranslation - m_lowerTranslation) < 2 * b2Settings.b2_linearSlop)
            {
               _loc17_ = b2Math.clamp(_loc28_,-b2Settings.b2_maxLinearCorrection,b2Settings.b2_maxLinearCorrection);
               _loc14_ = b2Math.abs(_loc28_);
               _loc16_ = true;
            }
            else if(_loc28_ <= m_lowerTranslation)
            {
               _loc17_ = b2Math.clamp(_loc28_ - m_lowerTranslation + b2Settings.b2_linearSlop,-b2Settings.b2_maxLinearCorrection,0);
               _loc14_ = m_lowerTranslation - _loc28_;
               _loc16_ = true;
            }
            else if(_loc28_ >= m_upperTranslation)
            {
               _loc17_ = b2Math.clamp(_loc28_ - m_upperTranslation + b2Settings.b2_linearSlop,0,b2Settings.b2_maxLinearCorrection);
               _loc14_ = _loc28_ - m_upperTranslation;
               _loc16_ = true;
            }
         }
         m_perp = b2Math.mulMV(_loc18_,m_localYAxis1);
         m_s1 = (_loc26_ + _loc21_) * m_perp.y - (_loc27_ + _loc22_) * m_perp.x;
         m_s2 = _loc24_ * m_perp.y - _loc25_ * m_perp.x;
         var _loc29_:b2Vec3 = new b2Vec3();
         _loc28_ = m_perp.x * _loc26_ + m_perp.y * _loc27_;
         var _loc30_:Number = _loc9_ - _loc7_ - m_refAngle;
         _loc14_ = b2Math.max(_loc14_,b2Math.abs(_loc28_));
         _loc15_ = b2Math.abs(_loc30_);
         if(_loc16_)
         {
            _loc10_ = m_invMassA;
            _loc11_ = m_invMassB;
            _loc12_ = m_invIA;
            _loc13_ = m_invIB;
            m_K.col1.x = _loc10_ + _loc11_ + _loc12_ * m_s1 * m_s1 + _loc13_ * m_s2 * m_s2;
            m_K.col1.y = _loc12_ * m_s1 + _loc13_ * m_s2;
            m_K.col1.z = _loc12_ * m_s1 * m_a1 + _loc13_ * m_s2 * m_a2;
            m_K.col2.x = m_K.col1.y;
            m_K.col2.y = _loc12_ + _loc13_;
            m_K.col2.z = _loc12_ * m_a1 + _loc13_ * m_a2;
            m_K.col3.x = m_K.col1.z;
            m_K.col3.y = m_K.col2.z;
            m_K.col3.z = _loc10_ + _loc11_ + _loc12_ * m_a1 * m_a1 + _loc13_ * m_a2 * m_a2;
            m_K.solve33(_loc29_,-_loc28_,-_loc30_,-_loc17_);
         }
         else
         {
            _loc10_ = m_invMassA;
            _loc11_ = m_invMassB;
            _loc12_ = m_invIA;
            _loc13_ = m_invIB;
            _loc31_ = _loc10_ + _loc11_ + _loc12_ * m_s1 * m_s1 + _loc13_ * m_s2 * m_s2;
            _loc32_ = _loc12_ * m_s1 + _loc13_ * m_s2;
            _loc33_ = _loc12_ + _loc13_;
            m_K.col1.set(_loc31_,_loc32_,0);
            m_K.col2.set(_loc32_,_loc33_,0);
            _loc34_ = m_K.solve22(new b2Vec2(),-_loc28_,-_loc30_);
            _loc29_.x = _loc34_.x;
            _loc29_.y = _loc34_.y;
            _loc29_.z = 0;
         }
         _loc31_ = _loc29_.x * m_perp.x + _loc29_.z * m_axis.x;
         _loc32_ = _loc29_.x * m_perp.y + _loc29_.z * m_axis.y;
         _loc33_ = _loc29_.x * m_s1 + _loc29_.y + _loc29_.z * m_a1;
         var _loc35_:Number = _loc29_.x * m_s2 + _loc29_.y + _loc29_.z * m_a2;
         _loc6_.x -= m_invMassA * _loc31_;
         _loc6_.y -= m_invMassA * _loc32_;
         _loc7_ -= m_invIA * _loc33_;
         _loc8_.x += m_invMassB * _loc31_;
         _loc8_.y += m_invMassB * _loc32_;
         _loc9_ += m_invIB * _loc35_;
         _loc4_.m_sweep.a = _loc7_;
         _loc5_.m_sweep.a = _loc9_;
         _loc4_.synchronizeTransform();
         _loc5_.synchronizeTransform();
         if(_loc14_ <= b2Settings.b2_linearSlop)
         {
            return _loc15_ <= b2Settings.b2_angularSlop;
         }
         return false;
      }
      
      public function SetMotorSpeed(speed:Number) : void
      {
         m_bodyA.setAwake(true);
         m_bodyB.setAwake(true);
         m_motorSpeed = speed;
      }
      
      public function SetMaxMotorForce(force:Number) : void
      {
         m_bodyA.setAwake(true);
         m_bodyB.setAwake(true);
         m_maxMotorForce = force;
      }
      
      public function SetLimits(lower:Number, upper:Number) : void
      {
         m_bodyA.setAwake(true);
         m_bodyB.setAwake(true);
         m_lowerTranslation = lower;
         m_upperTranslation = upper;
      }
      
      public function IsMotorEnabled() : Boolean
      {
         return m_enableMotor;
      }
      
      public function IsLimitEnabled() : Boolean
      {
         return m_enableLimit;
      }
      
      override public function InitVelocityConstraints(step:b2TimeStep) : void
      {
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc2_:b2Body = m_bodyA;
         var _loc3_:b2Body = m_bodyB;
         m_localCenterA.setV(_loc2_.getLocalCenter());
         m_localCenterB.setV(_loc3_.getLocalCenter());
         var _loc4_:b2Transform = _loc2_.getTransform();
         var _loc5_:b2Transform = _loc3_.getTransform();
         var _loc6_:b2Mat22 = _loc2_.m_xf.R;
         var _loc7_:Number = m_localAnchor1.x - m_localCenterA.x;
         var _loc8_:Number = m_localAnchor1.y - m_localCenterA.y;
         var _loc9_:Number = _loc6_.col1.x * _loc7_ + _loc6_.col2.x * _loc8_;
         _loc8_ = _loc6_.col1.y * _loc7_ + _loc6_.col2.y * _loc8_;
         _loc7_ = _loc9_;
         _loc6_ = _loc3_.m_xf.R;
         var _loc10_:Number = m_localAnchor2.x - m_localCenterB.x;
         var _loc11_:Number = m_localAnchor2.y - m_localCenterB.y;
         _loc9_ = _loc6_.col1.x * _loc10_ + _loc6_.col2.x * _loc11_;
         _loc11_ = _loc6_.col1.y * _loc10_ + _loc6_.col2.y * _loc11_;
         _loc10_ = _loc9_;
         var _loc12_:Number = _loc3_.m_sweep.c.x + _loc10_ - _loc2_.m_sweep.c.x - _loc7_;
         var _loc13_:Number = _loc3_.m_sweep.c.y + _loc11_ - _loc2_.m_sweep.c.y - _loc8_;
         m_invMassA = _loc2_.m_invMass;
         m_invMassB = _loc3_.m_invMass;
         m_invIA = _loc2_.m_invI;
         m_invIB = _loc3_.m_invI;
         m_axis.setV(b2Math.mulMV(_loc4_.R,m_localXAxis1));
         m_a1 = (_loc12_ + _loc7_) * m_axis.y - (_loc13_ + _loc8_) * m_axis.x;
         m_a2 = _loc10_ * m_axis.y - _loc11_ * m_axis.x;
         m_motorMass = m_invMassA + m_invMassB + m_invIA * m_a1 * m_a1 + m_invIB * m_a2 * m_a2;
         if(m_motorMass > Number(Number.MIN_VALUE))
         {
            m_motorMass = 1 / m_motorMass;
         }
         m_perp.setV(b2Math.mulMV(_loc4_.R,m_localYAxis1));
         m_s1 = (_loc12_ + _loc7_) * m_perp.y - (_loc13_ + _loc8_) * m_perp.x;
         m_s2 = _loc10_ * m_perp.y - _loc11_ * m_perp.x;
         _loc14_ = m_invMassA;
         _loc15_ = m_invMassB;
         _loc16_ = m_invIA;
         _loc17_ = m_invIB;
         m_K.col1.x = _loc14_ + _loc15_ + _loc16_ * m_s1 * m_s1 + _loc17_ * m_s2 * m_s2;
         m_K.col1.y = _loc16_ * m_s1 + _loc17_ * m_s2;
         m_K.col1.z = _loc16_ * m_s1 * m_a1 + _loc17_ * m_s2 * m_a2;
         m_K.col2.x = m_K.col1.y;
         m_K.col2.y = _loc16_ + _loc17_;
         m_K.col2.z = _loc16_ * m_a1 + _loc17_ * m_a2;
         m_K.col3.x = m_K.col1.z;
         m_K.col3.y = m_K.col2.z;
         m_K.col3.z = _loc14_ + _loc15_ + _loc16_ * m_a1 * m_a1 + _loc17_ * m_a2 * m_a2;
         if(m_enableLimit)
         {
            _loc14_ = m_axis.x * _loc12_ + m_axis.y * _loc13_;
            if(b2Math.abs(m_upperTranslation - m_lowerTranslation) < 2 * b2Settings.b2_linearSlop)
            {
               m_limitState = 3;
            }
            else if(_loc14_ <= m_lowerTranslation)
            {
               if(m_limitState != 1)
               {
                  m_limitState = 1;
                  m_impulse.z = 0;
               }
            }
            else if(_loc14_ >= m_upperTranslation)
            {
               if(m_limitState != 2)
               {
                  m_limitState = 2;
                  m_impulse.z = 0;
               }
            }
            else
            {
               m_limitState = 0;
               m_impulse.z = 0;
            }
         }
         else
         {
            m_limitState = 0;
         }
         if(m_enableMotor == false)
         {
            m_motorImpulse = 0;
         }
         if(step.warmStarting)
         {
            m_impulse.x *= step.dtRatio;
            m_impulse.y *= step.dtRatio;
            m_motorImpulse *= step.dtRatio;
            _loc14_ = m_impulse.x * m_perp.x + (m_motorImpulse + m_impulse.z) * m_axis.x;
            _loc15_ = m_impulse.x * m_perp.y + (m_motorImpulse + m_impulse.z) * m_axis.y;
            _loc16_ = m_impulse.x * m_s1 + m_impulse.y + (m_motorImpulse + m_impulse.z) * m_a1;
            _loc17_ = m_impulse.x * m_s2 + m_impulse.y + (m_motorImpulse + m_impulse.z) * m_a2;
            _loc2_.m_linearVelocity.x -= m_invMassA * _loc14_;
            _loc2_.m_linearVelocity.y -= m_invMassA * _loc15_;
            _loc2_.m_angularVelocity -= m_invIA * _loc16_;
            _loc3_.m_linearVelocity.x += m_invMassB * _loc14_;
            _loc3_.m_linearVelocity.y += m_invMassB * _loc15_;
            _loc3_.m_angularVelocity += m_invIB * _loc17_;
         }
         else
         {
            m_impulse.setZero();
            m_motorImpulse = 0;
         }
      }
      
      public function GetUpperLimit() : Number
      {
         return m_upperTranslation;
      }
      
      override public function GetReactionTorque(inv_dt:Number) : Number
      {
         return inv_dt * m_impulse.y;
      }
      
      override public function GetReactionForce(inv_dt:Number) : b2Vec2
      {
         return new b2Vec2(inv_dt * (m_impulse.x * m_perp.x + (m_motorImpulse + m_impulse.z) * m_axis.x),inv_dt * (m_impulse.x * m_perp.y + (m_motorImpulse + m_impulse.z) * m_axis.y));
      }
      
      public function GetMotorSpeed() : Number
      {
         return m_motorSpeed;
      }
      
      public function GetMotorForce() : Number
      {
         return m_motorImpulse;
      }
      
      public function GetLowerLimit() : Number
      {
         return m_lowerTranslation;
      }
      
      public function GetJointTranslation() : Number
      {
         var _loc1_:b2Body = m_bodyA;
         var _loc2_:b2Body = m_bodyB;
         var _loc4_:b2Vec2 = _loc1_.getWorldPoint(m_localAnchor1);
         var _loc5_:b2Vec2 = _loc2_.getWorldPoint(m_localAnchor2);
         var _loc6_:Number = _loc5_.x - _loc4_.x;
         var _loc7_:Number = _loc5_.y - _loc4_.y;
         var _loc8_:b2Vec2 = _loc1_.getWorldVector(m_localXAxis1);
         return _loc8_.x * _loc6_ + _loc8_.y * _loc7_;
      }
      
      public function GetJointSpeed() : Number
      {
         var _loc1_:b2Body = m_bodyA;
         var _loc2_:b2Body = m_bodyB;
         var _loc3_:b2Mat22 = _loc1_.m_xf.R;
         var _loc4_:Number = m_localAnchor1.x - _loc1_.m_sweep.localCenter.x;
         var _loc5_:Number = m_localAnchor1.y - _loc1_.m_sweep.localCenter.y;
         var _loc6_:Number = _loc3_.col1.x * _loc4_ + _loc3_.col2.x * _loc5_;
         _loc5_ = _loc3_.col1.y * _loc4_ + _loc3_.col2.y * _loc5_;
         _loc4_ = _loc6_;
         _loc3_ = _loc2_.m_xf.R;
         var _loc7_:Number = m_localAnchor2.x - _loc2_.m_sweep.localCenter.x;
         var _loc8_:Number = m_localAnchor2.y - _loc2_.m_sweep.localCenter.y;
         _loc6_ = _loc3_.col1.x * _loc7_ + _loc3_.col2.x * _loc8_;
         _loc8_ = _loc3_.col1.y * _loc7_ + _loc3_.col2.y * _loc8_;
         _loc7_ = _loc6_;
         var _loc9_:Number = _loc1_.m_sweep.c.x + _loc4_;
         var _loc10_:Number = _loc1_.m_sweep.c.y + _loc5_;
         var _loc11_:Number = _loc2_.m_sweep.c.x + _loc7_;
         var _loc12_:Number = _loc2_.m_sweep.c.y + _loc8_;
         var _loc13_:Number = _loc11_ - _loc9_;
         var _loc14_:Number = _loc12_ - _loc10_;
         var _loc15_:b2Vec2 = _loc1_.getWorldVector(m_localXAxis1);
         var _loc16_:b2Vec2 = _loc1_.m_linearVelocity;
         var _loc17_:b2Vec2 = _loc2_.m_linearVelocity;
         var _loc18_:Number = _loc1_.m_angularVelocity;
         var _loc19_:Number = _loc2_.m_angularVelocity;
         return _loc13_ * (-_loc18_ * _loc15_.y) + _loc14_ * (_loc18_ * _loc15_.x) + (_loc15_.x * (_loc17_.x + -_loc19_ * _loc8_ - _loc16_.x - -_loc18_ * _loc5_) + _loc15_.y * (_loc17_.y + _loc19_ * _loc7_ - _loc16_.y - _loc18_ * _loc4_));
      }
      
      override public function GetAnchorB() : b2Vec2
      {
         return m_bodyB.getWorldPoint(m_localAnchor2);
      }
      
      override public function GetAnchorA() : b2Vec2
      {
         return m_bodyA.getWorldPoint(m_localAnchor1);
      }
      
      public function EnableMotor(flag:Boolean) : void
      {
         m_bodyA.setAwake(true);
         m_bodyB.setAwake(true);
         m_enableMotor = flag;
      }
      
      public function EnableLimit(flag:Boolean) : void
      {
         m_bodyA.setAwake(true);
         m_bodyB.setAwake(true);
         m_enableLimit = flag;
      }
   }
}

