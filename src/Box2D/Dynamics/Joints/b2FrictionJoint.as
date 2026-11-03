package Box2D.Dynamics.Joints
{
   import Box2D.Common.Math.b2Mat22;
   import Box2D.Common.Math.b2Math;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.b2Body;
   import Box2D.Dynamics.b2TimeStep;
   import flash.Boot;
   
   public class b2FrictionJoint extends b2Joint
   {
      
      public var m_maxTorque:Number;
      
      public var m_maxForce:Number;
      
      public var m_localAnchorB:b2Vec2;
      
      public var m_localAnchorA:b2Vec2;
      
      public var m_linearMass:b2Mat22;
      
      public var m_linearImpulse:b2Vec2;
      
      public var m_angularMass:Number;
      
      public var m_angularImpulse:Number;
      
      public function b2FrictionJoint(def:b2FrictionJointDef = undefined)
      {
         if(!Boot.skip_constructor)
         {
            super(def);
            m_localAnchorA = new b2Vec2();
            m_localAnchorB = new b2Vec2();
            m_linearMass = new b2Mat22();
            m_linearImpulse = new b2Vec2();
            m_localAnchorA.setV(def.localAnchorA);
            m_localAnchorB.setV(def.localAnchorB);
            m_linearMass.setZero();
            m_angularMass = 0;
            m_linearImpulse.setZero();
            m_angularImpulse = 0;
            m_maxForce = def.maxForce;
            m_maxTorque = def.maxTorque;
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
      
      public function setMaxTorque(torque:Number) : void
      {
         SetMaxTorque(torque);
      }
      
      public function setMaxForce(force:Number) : void
      {
         SetMaxForce(force);
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
      
      public function getMaxTorque() : Number
      {
         return GetMaxTorque();
      }
      
      public function getMaxForce() : Number
      {
         return GetMaxForce();
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
         var _loc19_:Number = _loc7_ - _loc5_;
         var _loc20_:Number = -m_angularMass * _loc19_;
         var _loc21_:Number = m_angularImpulse;
         var _loc18_:Number = step.dt * m_maxTorque;
         m_angularImpulse = b2Math.clamp(m_angularImpulse + _loc20_,-_loc18_,_loc18_);
         _loc20_ = m_angularImpulse - _loc21_;
         _loc5_ -= _loc10_ * _loc20_;
         _loc7_ += _loc11_ * _loc20_;
         _loc19_ = _loc6_.x - _loc7_ * _loc17_ - _loc4_.x + _loc5_ * _loc14_;
         _loc20_ = _loc6_.y + _loc7_ * _loc16_ - _loc4_.y - _loc5_ * _loc13_;
         var _loc22_:b2Vec2 = b2Math.mulMV(m_linearMass,new b2Vec2(-_loc19_,-_loc20_));
         var _loc23_:b2Vec2 = m_linearImpulse.copy();
         m_linearImpulse.add(_loc22_);
         _loc18_ = step.dt * m_maxForce;
         if(m_linearImpulse.lengthSquared() > _loc18_ * _loc18_)
         {
            m_linearImpulse.normalize();
            m_linearImpulse.multiply(_loc18_);
         }
         _loc22_ = b2Math.subtractVV(m_linearImpulse,_loc23_);
         _loc4_.x -= _loc8_ * _loc22_.x;
         _loc4_.y -= _loc8_ * _loc22_.y;
         _loc5_ -= _loc10_ * (_loc13_ * _loc22_.y - _loc14_ * _loc22_.x);
         _loc6_.x += _loc9_ * _loc22_.x;
         _loc6_.y += _loc9_ * _loc22_.y;
         _loc7_ += _loc11_ * (_loc16_ * _loc22_.y - _loc17_ * _loc22_.x);
         _loc2_.m_angularVelocity = _loc5_;
         _loc3_.m_angularVelocity = _loc7_;
      }
      
      override public function SolvePositionConstraints(baumgarte:Number) : Boolean
      {
         return true;
      }
      
      public function SetMaxTorque(torque:Number) : void
      {
         m_maxTorque = torque;
      }
      
      public function SetMaxForce(force:Number) : void
      {
         m_maxForce = force;
      }
      
      override public function InitVelocityConstraints(step:b2TimeStep) : void
      {
         var _loc15_:* = null as b2Vec2;
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
         var _loc14_:b2Mat22 = new b2Mat22();
         _loc14_.col1.x = _loc10_ + _loc11_;
         _loc14_.col2.x = 0;
         _loc14_.col1.y = 0;
         _loc14_.col2.y = _loc10_ + _loc11_;
         _loc14_.col1.x += _loc12_ * _loc6_ * _loc6_;
         _loc14_.col2.x += -_loc12_ * _loc5_ * _loc6_;
         _loc14_.col1.y += -_loc12_ * _loc5_ * _loc6_;
         _loc14_.col2.y += _loc12_ * _loc5_ * _loc5_;
         _loc14_.col1.x += _loc13_ * _loc9_ * _loc9_;
         _loc14_.col2.x += -_loc13_ * _loc8_ * _loc9_;
         _loc14_.col1.y += -_loc13_ * _loc8_ * _loc9_;
         _loc14_.col2.y += _loc13_ * _loc8_ * _loc8_;
         _loc14_.getInverse(m_linearMass);
         m_angularMass = _loc12_ + _loc13_;
         if(m_angularMass > 0)
         {
            m_angularMass = 1 / m_angularMass;
         }
         if(step.warmStarting)
         {
            m_linearImpulse.x *= step.dtRatio;
            m_linearImpulse.y *= step.dtRatio;
            m_angularImpulse *= step.dtRatio;
            _loc15_ = m_linearImpulse;
            _loc2_.m_linearVelocity.x -= _loc10_ * _loc15_.x;
            _loc2_.m_linearVelocity.y -= _loc10_ * _loc15_.y;
            _loc2_.m_angularVelocity -= _loc12_ * (_loc5_ * _loc15_.y - _loc6_ * _loc15_.x + m_angularImpulse);
            _loc3_.m_linearVelocity.x += _loc11_ * _loc15_.x;
            _loc3_.m_linearVelocity.y += _loc11_ * _loc15_.y;
            _loc3_.m_angularVelocity += _loc13_ * (_loc8_ * _loc15_.y - _loc9_ * _loc15_.x + m_angularImpulse);
         }
         else
         {
            m_linearImpulse.setZero();
            m_angularImpulse = 0;
         }
      }
      
      override public function GetReactionTorque(inv_dt:Number) : Number
      {
         return inv_dt * m_angularImpulse;
      }
      
      override public function GetReactionForce(inv_dt:Number) : b2Vec2
      {
         return new b2Vec2(inv_dt * m_linearImpulse.x,inv_dt * m_linearImpulse.y);
      }
      
      public function GetMaxTorque() : Number
      {
         return m_maxTorque;
      }
      
      public function GetMaxForce() : Number
      {
         return m_maxForce;
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

