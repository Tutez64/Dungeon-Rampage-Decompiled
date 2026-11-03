package Box2D.Dynamics.Joints
{
   import Box2D.Common.Math.b2Mat22;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.b2Body;
   import Box2D.Dynamics.b2TimeStep;
   import flash.Boot;
   
   public class b2MouseJoint extends b2Joint
   {
      
      public var m_target:b2Vec2;
      
      public var m_maxForce:Number;
      
      public var m_mass:b2Mat22;
      
      public var m_localAnchor:b2Vec2;
      
      public var m_impulse:b2Vec2;
      
      public var m_gamma:Number;
      
      public var m_frequencyHz:Number;
      
      public var m_dampingRatio:Number;
      
      public var m_beta:Number;
      
      public var m_C:b2Vec2;
      
      public var K2:b2Mat22;
      
      public var K1:b2Mat22;
      
      public var K:b2Mat22;
      
      public function b2MouseJoint(def:b2MouseJointDef = undefined)
      {
         if(!Boot.skip_constructor)
         {
            super(def);
            K = new b2Mat22();
            K1 = new b2Mat22();
            K2 = new b2Mat22();
            m_localAnchor = new b2Vec2();
            m_target = new b2Vec2();
            m_impulse = new b2Vec2();
            m_mass = new b2Mat22();
            m_C = new b2Vec2();
            m_target.setV(def.target);
            var _loc2_:Number = m_target.x - m_bodyB.m_xf.position.x;
            var _loc3_:Number = m_target.y - m_bodyB.m_xf.position.y;
            var _loc4_:b2Mat22 = m_bodyB.m_xf.R;
            m_localAnchor.x = _loc2_ * _loc4_.col1.x + _loc3_ * _loc4_.col1.y;
            m_localAnchor.y = _loc2_ * _loc4_.col2.x + _loc3_ * _loc4_.col2.y;
            m_maxForce = def.maxForce;
            m_impulse.setZero();
            m_frequencyHz = def.frequencyHz;
            m_dampingRatio = def.dampingRatio;
            m_beta = 0;
            m_gamma = 0;
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
      
      public function setTarget(target:b2Vec2) : void
      {
         SetTarget(target);
      }
      
      public function setMaxForce(maxForce:Number) : void
      {
         SetMaxForce(maxForce);
      }
      
      public function setFrequency(hz:Number) : void
      {
         SetFrequency(hz);
      }
      
      public function setDampingRatio(ratio:Number) : void
      {
         SetDampingRatio(ratio);
      }
      
      override public function initVelocityConstraints(step:b2TimeStep) : void
      {
         InitVelocityConstraints(step);
      }
      
      public function getTarget() : b2Vec2
      {
         return GetTarget();
      }
      
      override public function getReactionTorque(inv_dt:Number) : Number
      {
         return GetReactionTorque(inv_dt);
      }
      
      override public function getReactionForce(inv_dt:Number) : b2Vec2
      {
         return GetReactionForce(inv_dt);
      }
      
      public function getMaxForce() : Number
      {
         return GetMaxForce();
      }
      
      public function getFrequency() : Number
      {
         return GetFrequency();
      }
      
      public function getDampingRatio() : Number
      {
         return GetDampingRatio();
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
         var _loc2_:b2Body = m_bodyB;
         var _loc3_:b2Mat22 = _loc2_.m_xf.R;
         var _loc4_:Number = m_localAnchor.x - _loc2_.m_sweep.localCenter.x;
         var _loc5_:Number = m_localAnchor.y - _loc2_.m_sweep.localCenter.y;
         var _loc6_:Number = _loc3_.col1.x * _loc4_ + _loc3_.col2.x * _loc5_;
         _loc5_ = _loc3_.col1.y * _loc4_ + _loc3_.col2.y * _loc5_;
         _loc4_ = _loc6_;
         var _loc7_:Number = _loc2_.m_linearVelocity.x + -_loc2_.m_angularVelocity * _loc5_;
         var _loc8_:Number = _loc2_.m_linearVelocity.y + _loc2_.m_angularVelocity * _loc4_;
         _loc3_ = m_mass;
         _loc6_ = _loc7_ + m_beta * m_C.x + m_gamma * m_impulse.x;
         var _loc9_:Number = _loc8_ + m_beta * m_C.y + m_gamma * m_impulse.y;
         var _loc10_:Number = -(_loc3_.col1.x * _loc6_ + _loc3_.col2.x * _loc9_);
         var _loc11_:Number = -(_loc3_.col1.y * _loc6_ + _loc3_.col2.y * _loc9_);
         var _loc12_:Number = m_impulse.x;
         var _loc13_:Number = m_impulse.y;
         m_impulse.x += _loc10_;
         m_impulse.y += _loc11_;
         var _loc14_:Number = step.dt * m_maxForce;
         if(m_impulse.lengthSquared() > _loc14_ * _loc14_)
         {
            m_impulse.multiply(_loc14_ / m_impulse.length());
         }
         _loc10_ = m_impulse.x - _loc12_;
         _loc11_ = m_impulse.y - _loc13_;
         _loc2_.m_linearVelocity.x += _loc2_.m_invMass * _loc10_;
         _loc2_.m_linearVelocity.y += _loc2_.m_invMass * _loc11_;
         _loc2_.m_angularVelocity += _loc2_.m_invI * (_loc4_ * _loc11_ - _loc5_ * _loc10_);
      }
      
      override public function SolvePositionConstraints(baumgarte:Number) : Boolean
      {
         return true;
      }
      
      public function SetTarget(target:b2Vec2) : void
      {
         if((m_bodyB.m_flags & b2Body.e_awakeFlag) == b2Body.e_awakeFlag == false)
         {
            m_bodyB.setAwake(true);
         }
         m_target = target;
      }
      
      public function SetMaxForce(maxForce:Number) : void
      {
         m_maxForce = maxForce;
      }
      
      public function SetFrequency(hz:Number) : void
      {
         m_frequencyHz = hz;
      }
      
      public function SetDampingRatio(ratio:Number) : void
      {
         m_dampingRatio = ratio;
      }
      
      override public function InitVelocityConstraints(step:b2TimeStep) : void
      {
         var _loc2_:b2Body = m_bodyB;
         var _loc3_:Number = _loc2_.getMass();
         var _loc4_:Number = 2 * Math.PI * m_frequencyHz;
         var _loc5_:Number = 2 * _loc3_ * m_dampingRatio * _loc4_;
         var _loc6_:Number = _loc3_ * _loc4_ * _loc4_;
         m_gamma = step.dt * (_loc5_ + step.dt * _loc6_);
         m_gamma = m_gamma != 0 ? 1 / m_gamma : 0;
         m_beta = step.dt * _loc6_ * m_gamma;
         var _loc7_:b2Mat22 = _loc2_.m_xf.R;
         var _loc8_:Number = m_localAnchor.x - _loc2_.m_sweep.localCenter.x;
         var _loc9_:Number = m_localAnchor.y - _loc2_.m_sweep.localCenter.y;
         var _loc10_:Number = _loc7_.col1.x * _loc8_ + _loc7_.col2.x * _loc9_;
         _loc9_ = _loc7_.col1.y * _loc8_ + _loc7_.col2.y * _loc9_;
         _loc8_ = _loc10_;
         var _loc11_:Number = _loc2_.m_invMass;
         var _loc12_:Number = _loc2_.m_invI;
         K1.col1.x = _loc11_;
         K1.col2.x = 0;
         K1.col1.y = 0;
         K1.col2.y = _loc11_;
         K2.col1.x = _loc12_ * _loc9_ * _loc9_;
         K2.col2.x = -_loc12_ * _loc8_ * _loc9_;
         K2.col1.y = -_loc12_ * _loc8_ * _loc9_;
         K2.col2.y = _loc12_ * _loc8_ * _loc8_;
         K.setM(K1);
         K.addM(K2);
         K.col1.x += m_gamma;
         K.col2.y += m_gamma;
         K.getInverse(m_mass);
         m_C.x = _loc2_.m_sweep.c.x + _loc8_ - m_target.x;
         m_C.y = _loc2_.m_sweep.c.y + _loc9_ - m_target.y;
         _loc2_.m_angularVelocity *= 0.98;
         m_impulse.x *= step.dtRatio;
         m_impulse.y *= step.dtRatio;
         _loc2_.m_linearVelocity.x += _loc11_ * m_impulse.x;
         _loc2_.m_linearVelocity.y += _loc11_ * m_impulse.y;
         _loc2_.m_angularVelocity += _loc12_ * (_loc8_ * m_impulse.y - _loc9_ * m_impulse.x);
      }
      
      public function GetTarget() : b2Vec2
      {
         return m_target;
      }
      
      override public function GetReactionTorque(inv_dt:Number) : Number
      {
         return 0;
      }
      
      override public function GetReactionForce(inv_dt:Number) : b2Vec2
      {
         return new b2Vec2(inv_dt * m_impulse.x,inv_dt * m_impulse.y);
      }
      
      public function GetMaxForce() : Number
      {
         return m_maxForce;
      }
      
      public function GetFrequency() : Number
      {
         return m_frequencyHz;
      }
      
      public function GetDampingRatio() : Number
      {
         return m_dampingRatio;
      }
      
      override public function GetAnchorB() : b2Vec2
      {
         return m_bodyB.getWorldPoint(m_localAnchor);
      }
      
      override public function GetAnchorA() : b2Vec2
      {
         return m_target;
      }
   }
}

