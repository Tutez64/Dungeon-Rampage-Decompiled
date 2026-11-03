package Box2D.Dynamics.Joints
{
   import Box2D.Common.Math.b2Mat22;
   import Box2D.Common.Math.b2Mat33;
   import Box2D.Common.Math.b2Math;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Common.Math.b2Vec3;
   import Box2D.Common.b2Settings;
   import Box2D.Dynamics.b2Body;
   import Box2D.Dynamics.b2TimeStep;
   import flash.Boot;
   
   public class b2WeldJoint extends b2Joint
   {
      
      public var m_referenceAngle:Number;
      
      public var m_mass:b2Mat33;
      
      public var m_localAnchorB:b2Vec2;
      
      public var m_localAnchorA:b2Vec2;
      
      public var m_impulse:b2Vec3;
      
      public function b2WeldJoint(def:b2WeldJointDef = undefined)
      {
         if(!Boot.skip_constructor)
         {
            super(def);
            m_localAnchorA = new b2Vec2();
            m_localAnchorB = new b2Vec2();
            m_impulse = new b2Vec3();
            m_mass = new b2Mat33();
            m_localAnchorA.setV(def.localAnchorA);
            m_localAnchorB.setV(def.localAnchorB);
            m_referenceAngle = def.referenceAngle;
            m_impulse.setZero();
            m_mass = new b2Mat33();
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
      
      override public function initVelocityConstraints(step:b2TimeStep) : void
      {
         InitVelocityConstraints(step);
      }
      
      override public function getReactionTorque(inv_dt:Number) : Number
      {
         return GetReactionTorque(inv_dt);
      }
      
      override public function getReactionForce(inv_dt:Number) : b2Vec2
      {
         return GetReactionForce(inv_dt);
      }
      
      override public function getAnchorB() : b2Vec2
      {
         return GetAnchorB();
      }
      
      override public function getAnchorA() : b2Vec2
      {
         return GetAnchorA();
      }
      
      override public function SolveVelocityConstraints(step:b2TimeStep) : void
      {
         var _loc2_:b2Body = m_bodyA;
         var _loc3_:b2Body = m_bodyB;
         var _loc4_:b2Vec2 = _loc2_.m_linearVelocity;
         var _loc5_:Number = _loc2_.m_angularVelocity;
         var _loc6_:b2Vec2 = _loc3_.m_linearVelocity;
         var _loc7_:Number = _loc3_.m_angularVelocity;
         var _loc8_:Number = _loc2_.m_invMass;
         var _loc9_:Number = _loc3_.m_invMass;
         var _loc10_:Number = _loc2_.m_invI;
         var _loc11_:Number = _loc3_.m_invI;
         var _loc12_:b2Mat22 = _loc2_.m_xf.R;
         var _loc13_:Number = m_localAnchorA.x - _loc2_.m_sweep.localCenter.x;
         var _loc14_:Number = m_localAnchorA.y - _loc2_.m_sweep.localCenter.y;
         var _loc15_:Number = _loc12_.col1.x * _loc13_ + _loc12_.col2.x * _loc14_;
         _loc14_ = _loc12_.col1.y * _loc13_ + _loc12_.col2.y * _loc14_;
         _loc13_ = _loc15_;
         _loc12_ = _loc3_.m_xf.R;
         var _loc16_:Number = m_localAnchorB.x - _loc3_.m_sweep.localCenter.x;
         var _loc17_:Number = m_localAnchorB.y - _loc3_.m_sweep.localCenter.y;
         _loc15_ = _loc12_.col1.x * _loc16_ + _loc12_.col2.x * _loc17_;
         _loc17_ = _loc12_.col1.y * _loc16_ + _loc12_.col2.y * _loc17_;
         _loc16_ = _loc15_;
         var _loc18_:Number = _loc6_.x - _loc7_ * _loc17_ - _loc4_.x + _loc5_ * _loc14_;
         var _loc19_:Number = _loc6_.y + _loc7_ * _loc16_ - _loc4_.y - _loc5_ * _loc13_;
         var _loc20_:Number = _loc7_ - _loc5_;
         var _loc21_:b2Vec3 = new b2Vec3();
         m_mass.solve33(_loc21_,-_loc18_,-_loc19_,-_loc20_);
         m_impulse.add(_loc21_);
         _loc4_.x -= _loc8_ * _loc21_.x;
         _loc4_.y -= _loc8_ * _loc21_.y;
         _loc5_ -= _loc10_ * (_loc13_ * _loc21_.y - _loc14_ * _loc21_.x + _loc21_.z);
         _loc6_.x += _loc9_ * _loc21_.x;
         _loc6_.y += _loc9_ * _loc21_.y;
         _loc7_ += _loc11_ * (_loc16_ * _loc21_.y - _loc17_ * _loc21_.x + _loc21_.z);
         _loc2_.m_angularVelocity = _loc5_;
         _loc3_.m_angularVelocity = _loc7_;
      }
      
      override public function SolvePositionConstraints(baumgarte:Number) : Boolean
      {
         var _loc2_:b2Body = m_bodyA;
         var _loc3_:b2Body = m_bodyB;
         var _loc4_:b2Mat22 = _loc2_.m_xf.R;
         var _loc5_:Number = m_localAnchorA.x - _loc2_.m_sweep.localCenter.x;
         var _loc6_:Number = m_localAnchorA.y - _loc2_.m_sweep.localCenter.y;
         var _loc7_:Number = _loc4_.col1.x * _loc5_ + _loc4_.col2.x * _loc6_;
         _loc6_ = _loc4_.col1.y * _loc5_ + _loc4_.col2.y * _loc6_;
         _loc5_ = _loc7_;
         _loc4_ = _loc3_.m_xf.R;
         var _loc8_:Number = m_localAnchorB.x - _loc3_.m_sweep.localCenter.x;
         var _loc9_:Number = m_localAnchorB.y - _loc3_.m_sweep.localCenter.y;
         _loc7_ = _loc4_.col1.x * _loc8_ + _loc4_.col2.x * _loc9_;
         _loc9_ = _loc4_.col1.y * _loc8_ + _loc4_.col2.y * _loc9_;
         _loc8_ = _loc7_;
         var _loc10_:Number = _loc2_.m_invMass;
         var _loc11_:Number = _loc3_.m_invMass;
         var _loc12_:Number = _loc2_.m_invI;
         var _loc13_:Number = _loc3_.m_invI;
         var _loc14_:Number = _loc3_.m_sweep.c.x + _loc8_ - _loc2_.m_sweep.c.x - _loc5_;
         var _loc15_:Number = _loc3_.m_sweep.c.y + _loc9_ - _loc2_.m_sweep.c.y - _loc6_;
         var _loc16_:Number = _loc3_.m_sweep.a - _loc2_.m_sweep.a - m_referenceAngle;
         var _loc17_:Number = 10 * b2Settings.b2_linearSlop;
         var _loc18_:Number = Math.sqrt(_loc14_ * _loc14_ + _loc15_ * _loc15_);
         var _loc19_:Number = b2Math.abs(_loc16_);
         if(_loc18_ > _loc17_)
         {
            _loc12_ *= 1;
            _loc13_ *= 1;
         }
         m_mass.col1.x = _loc10_ + _loc11_ + _loc6_ * _loc6_ * _loc12_ + _loc9_ * _loc9_ * _loc13_;
         m_mass.col2.x = -_loc6_ * _loc5_ * _loc12_ - _loc9_ * _loc8_ * _loc13_;
         m_mass.col3.x = -_loc6_ * _loc12_ - _loc9_ * _loc13_;
         m_mass.col1.y = m_mass.col2.x;
         m_mass.col2.y = _loc10_ + _loc11_ + _loc5_ * _loc5_ * _loc12_ + _loc8_ * _loc8_ * _loc13_;
         m_mass.col3.y = _loc5_ * _loc12_ + _loc8_ * _loc13_;
         m_mass.col1.z = m_mass.col3.x;
         m_mass.col2.z = m_mass.col3.y;
         m_mass.col3.z = _loc12_ + _loc13_;
         var _loc20_:b2Vec3 = new b2Vec3();
         m_mass.solve33(_loc20_,-_loc14_,-_loc15_,-_loc16_);
         _loc2_.m_sweep.c.x -= _loc10_ * _loc20_.x;
         _loc2_.m_sweep.c.y -= _loc10_ * _loc20_.y;
         _loc2_.m_sweep.a -= _loc12_ * (_loc5_ * _loc20_.y - _loc6_ * _loc20_.x + _loc20_.z);
         _loc3_.m_sweep.c.x += _loc11_ * _loc20_.x;
         _loc3_.m_sweep.c.y += _loc11_ * _loc20_.y;
         _loc3_.m_sweep.a += _loc13_ * (_loc8_ * _loc20_.y - _loc9_ * _loc20_.x + _loc20_.z);
         _loc2_.synchronizeTransform();
         _loc3_.synchronizeTransform();
         if(_loc18_ <= b2Settings.b2_linearSlop)
         {
            return _loc19_ <= b2Settings.b2_angularSlop;
         }
         return false;
      }
      
      override public function InitVelocityConstraints(step:b2TimeStep) : void
      {
         var _loc2_:b2Body = m_bodyA;
         var _loc3_:b2Body = m_bodyB;
         var _loc4_:b2Mat22 = _loc2_.m_xf.R;
         var _loc5_:Number = m_localAnchorA.x - _loc2_.m_sweep.localCenter.x;
         var _loc6_:Number = m_localAnchorA.y - _loc2_.m_sweep.localCenter.y;
         var _loc7_:Number = _loc4_.col1.x * _loc5_ + _loc4_.col2.x * _loc6_;
         _loc6_ = _loc4_.col1.y * _loc5_ + _loc4_.col2.y * _loc6_;
         _loc5_ = _loc7_;
         _loc4_ = _loc3_.m_xf.R;
         var _loc8_:Number = m_localAnchorB.x - _loc3_.m_sweep.localCenter.x;
         var _loc9_:Number = m_localAnchorB.y - _loc3_.m_sweep.localCenter.y;
         _loc7_ = _loc4_.col1.x * _loc8_ + _loc4_.col2.x * _loc9_;
         _loc9_ = _loc4_.col1.y * _loc8_ + _loc4_.col2.y * _loc9_;
         _loc8_ = _loc7_;
         var _loc10_:Number = _loc2_.m_invMass;
         var _loc11_:Number = _loc3_.m_invMass;
         var _loc12_:Number = _loc2_.m_invI;
         var _loc13_:Number = _loc3_.m_invI;
         m_mass.col1.x = _loc10_ + _loc11_ + _loc6_ * _loc6_ * _loc12_ + _loc9_ * _loc9_ * _loc13_;
         m_mass.col2.x = -_loc6_ * _loc5_ * _loc12_ - _loc9_ * _loc8_ * _loc13_;
         m_mass.col3.x = -_loc6_ * _loc12_ - _loc9_ * _loc13_;
         m_mass.col1.y = m_mass.col2.x;
         m_mass.col2.y = _loc10_ + _loc11_ + _loc5_ * _loc5_ * _loc12_ + _loc8_ * _loc8_ * _loc13_;
         m_mass.col3.y = _loc5_ * _loc12_ + _loc8_ * _loc13_;
         m_mass.col1.z = m_mass.col3.x;
         m_mass.col2.z = m_mass.col3.y;
         m_mass.col3.z = _loc12_ + _loc13_;
         if(step.warmStarting)
         {
            m_impulse.x *= step.dtRatio;
            m_impulse.y *= step.dtRatio;
            m_impulse.z *= step.dtRatio;
            _loc2_.m_linearVelocity.x -= _loc10_ * m_impulse.x;
            _loc2_.m_linearVelocity.y -= _loc10_ * m_impulse.y;
            _loc2_.m_angularVelocity -= _loc12_ * (_loc5_ * m_impulse.y - _loc6_ * m_impulse.x + m_impulse.z);
            _loc3_.m_linearVelocity.x += _loc11_ * m_impulse.x;
            _loc3_.m_linearVelocity.y += _loc11_ * m_impulse.y;
            _loc3_.m_angularVelocity += _loc13_ * (_loc8_ * m_impulse.y - _loc9_ * m_impulse.x + m_impulse.z);
         }
         else
         {
            m_impulse.setZero();
         }
      }
      
      override public function GetReactionTorque(inv_dt:Number) : Number
      {
         return inv_dt * m_impulse.z;
      }
      
      override public function GetReactionForce(inv_dt:Number) : b2Vec2
      {
         return new b2Vec2(inv_dt * m_impulse.x,inv_dt * m_impulse.y);
      }
      
      override public function GetAnchorB() : b2Vec2
      {
         return m_bodyB.getWorldPoint(m_localAnchorB);
      }
      
      override public function GetAnchorA() : b2Vec2
      {
         return m_bodyA.getWorldPoint(m_localAnchorA);
      }
   }
}

