package Box2D.Dynamics
{
   import Box2D.Collision.*;
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   import Box2D.Dynamics.Contacts.*;
   import Box2D.Dynamics.Joints.*;
   
   use namespace b2internal;
   
   public class b2Island
   {
      
      private static var s_impulse:b2ContactImpulse = new b2ContactImpulse();
      
      private var m_allocator:*;
      
      private var m_listener:b2ContactListener;
      
      private var m_contactSolver:b2ContactSolver;
      
      b2internal var m_bodies:Vector.<b2Body>;
      
      b2internal var m_contacts:Vector.<b2Contact>;
      
      b2internal var m_joints:Vector.<b2Joint>;
      
      b2internal var m_bodyCount:int;
      
      b2internal var m_jointCount:int;
      
      b2internal var m_contactCount:int;
      
      private var m_bodyCapacity:int;
      
      b2internal var m_contactCapacity:int;
      
      b2internal var m_jointCapacity:int;
      
      public function b2Island()
      {
         super();
         this.m_bodies = new Vector.<b2Body>();
         this.m_contacts = new Vector.<b2Contact>();
         this.m_joints = new Vector.<b2Joint>();
      }
      
      public function Initialize(bodyCapacity:int, contactCapacity:int, jointCapacity:int, allocator:*, listener:b2ContactListener, contactSolver:b2ContactSolver) : void
      {
         var _loc7_:* = 0;
         this.m_bodyCapacity = bodyCapacity;
         this.m_contactCapacity = contactCapacity;
         this.m_jointCapacity = jointCapacity;
         this.m_bodyCount = 0;
         this.m_contactCount = 0;
         this.m_jointCount = 0;
         this.m_allocator = allocator;
         this.m_listener = listener;
         this.m_contactSolver = contactSolver;
         _loc7_ = int(this.m_bodies.length);
         while(_loc7_ < bodyCapacity)
         {
            this.m_bodies[_loc7_] = null;
            _loc7_++;
         }
         _loc7_ = int(this.m_contacts.length);
         while(_loc7_ < contactCapacity)
         {
            this.m_contacts[_loc7_] = null;
            _loc7_++;
         }
         _loc7_ = int(this.m_joints.length);
         while(_loc7_ < jointCapacity)
         {
            this.m_joints[_loc7_] = null;
            _loc7_++;
         }
      }
      
      public function Clear() : void
      {
         this.m_bodyCount = 0;
         this.m_contactCount = 0;
         this.m_jointCount = 0;
      }
      
      public function Solve(step:b2TimeStep, gravity:b2Vec2, allowSleep:Boolean) : void
      {
         var _loc4_:* = 0;
         var _loc5_:* = 0;
         var _loc6_:b2Body = null;
         var _loc7_:b2Joint = null;
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc12_:Boolean = false;
         var _loc13_:Boolean = false;
         var _loc14_:Boolean = false;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         _loc4_ = 0;
         while(_loc4_ < this.m_bodyCount)
         {
            _loc6_ = this.m_bodies[_loc4_];
            if(_loc6_.GetType() == b2Body.b2_dynamicBody)
            {
               _loc6_.m_linearVelocity.x += step.dt * (gravity.x + _loc6_.m_invMass * _loc6_.m_force.x);
               _loc6_.m_linearVelocity.y += step.dt * (gravity.y + _loc6_.m_invMass * _loc6_.m_force.y);
               _loc6_.m_angularVelocity += step.dt * _loc6_.m_invI * _loc6_.m_torque;
               _loc6_.m_linearVelocity.Multiply(b2Math.Clamp(1 - step.dt * _loc6_.m_linearDamping,0,1));
               _loc6_.m_angularVelocity *= b2Math.Clamp(1 - step.dt * _loc6_.m_angularDamping,0,1);
            }
            _loc4_++;
         }
         this.m_contactSolver.Initialize(step,this.m_contacts,this.m_contactCount,this.m_allocator);
         var _loc8_:b2ContactSolver = this.m_contactSolver;
         _loc8_.InitVelocityConstraints(step);
         _loc4_ = 0;
         while(_loc4_ < this.m_jointCount)
         {
            _loc7_ = this.m_joints[_loc4_];
            _loc7_.InitVelocityConstraints(step);
            _loc4_++;
         }
         _loc4_ = 0;
         while(_loc4_ < step.velocityIterations)
         {
            _loc5_ = 0;
            while(_loc5_ < this.m_jointCount)
            {
               _loc7_ = this.m_joints[_loc5_];
               _loc7_.SolveVelocityConstraints(step);
               _loc5_++;
            }
            _loc8_.SolveVelocityConstraints();
            _loc4_++;
         }
         _loc4_ = 0;
         while(_loc4_ < this.m_jointCount)
         {
            _loc7_ = this.m_joints[_loc4_];
            _loc7_.FinalizeVelocityConstraints();
            _loc4_++;
         }
         _loc8_.FinalizeVelocityConstraints();
         _loc4_ = 0;
         while(_loc4_ < this.m_bodyCount)
         {
            _loc6_ = this.m_bodies[_loc4_];
            if(_loc6_.GetType() != b2Body.b2_staticBody)
            {
               _loc9_ = step.dt * _loc6_.m_linearVelocity.x;
               _loc10_ = step.dt * _loc6_.m_linearVelocity.y;
               if(_loc9_ * _loc9_ + _loc10_ * _loc10_ > b2Settings.b2_maxTranslationSquared)
               {
                  _loc6_.m_linearVelocity.Normalize();
                  _loc6_.m_linearVelocity.x *= b2Settings.b2_maxTranslation * step.inv_dt;
                  _loc6_.m_linearVelocity.y *= b2Settings.b2_maxTranslation * step.inv_dt;
               }
               _loc11_ = step.dt * _loc6_.m_angularVelocity;
               if(_loc11_ * _loc11_ > b2Settings.b2_maxRotationSquared)
               {
                  if(_loc6_.m_angularVelocity < 0)
                  {
                     _loc6_.m_angularVelocity = -b2Settings.b2_maxRotation * step.inv_dt;
                  }
                  else
                  {
                     _loc6_.m_angularVelocity = b2Settings.b2_maxRotation * step.inv_dt;
                  }
               }
               _loc6_.m_sweep.c0.SetV(_loc6_.m_sweep.c);
               _loc6_.m_sweep.a0 = _loc6_.m_sweep.a;
               _loc6_.m_sweep.c.x += step.dt * _loc6_.m_linearVelocity.x;
               _loc6_.m_sweep.c.y += step.dt * _loc6_.m_linearVelocity.y;
               _loc6_.m_sweep.a += step.dt * _loc6_.m_angularVelocity;
               _loc6_.SynchronizeTransform();
            }
            _loc4_++;
         }
         _loc4_ = 0;
         while(_loc4_ < step.positionIterations)
         {
            _loc12_ = _loc8_.SolvePositionConstraints(b2Settings.b2_contactBaumgarte);
            _loc13_ = true;
            _loc5_ = 0;
            while(_loc5_ < this.m_jointCount)
            {
               _loc7_ = this.m_joints[_loc5_];
               _loc14_ = _loc7_.SolvePositionConstraints(b2Settings.b2_contactBaumgarte);
               _loc13_ &&= _loc14_;
               _loc5_++;
            }
            if(_loc12_ && _loc13_)
            {
               break;
            }
            _loc4_++;
         }
         this.Report(_loc8_.m_constraints);
         if(allowSleep)
         {
            _loc15_ = Number.MAX_VALUE;
            _loc16_ = b2Settings.b2_linearSleepTolerance * b2Settings.b2_linearSleepTolerance;
            _loc17_ = b2Settings.b2_angularSleepTolerance * b2Settings.b2_angularSleepTolerance;
            _loc4_ = 0;
            while(_loc4_ < this.m_bodyCount)
            {
               _loc6_ = this.m_bodies[_loc4_];
               if(_loc6_.GetType() != b2Body.b2_staticBody)
               {
                  if((_loc6_.m_flags & b2Body.e_allowSleepFlag) == 0)
                  {
                     _loc6_.m_sleepTime = 0;
                     _loc15_ = 0;
                  }
                  if((_loc6_.m_flags & b2Body.e_allowSleepFlag) == 0 || _loc6_.m_angularVelocity * _loc6_.m_angularVelocity > _loc17_ || b2Math.Dot(_loc6_.m_linearVelocity,_loc6_.m_linearVelocity) > _loc16_)
                  {
                     _loc6_.m_sleepTime = 0;
                     _loc15_ = 0;
                  }
                  else
                  {
                     _loc6_.m_sleepTime += step.dt;
                     _loc15_ = b2Math.Min(_loc15_,_loc6_.m_sleepTime);
                  }
               }
               _loc4_++;
            }
            if(_loc15_ >= b2Settings.b2_timeToSleep)
            {
               _loc4_ = 0;
               while(_loc4_ < this.m_bodyCount)
               {
                  _loc6_ = this.m_bodies[_loc4_];
                  _loc6_.SetAwake(false);
                  _loc4_++;
               }
            }
         }
      }
      
      public function SolveTOI(subStep:b2TimeStep) : void
      {
         var _loc2_:* = 0;
         var _loc3_:* = 0;
         var _loc6_:b2Body = null;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:Boolean = false;
         var _loc11_:Boolean = false;
         var _loc12_:Boolean = false;
         this.m_contactSolver.Initialize(subStep,this.m_contacts,this.m_contactCount,this.m_allocator);
         var _loc4_:b2ContactSolver = this.m_contactSolver;
         _loc2_ = 0;
         while(_loc2_ < this.m_jointCount)
         {
            this.m_joints[_loc2_].InitVelocityConstraints(subStep);
            _loc2_++;
         }
         _loc2_ = 0;
         while(_loc2_ < subStep.velocityIterations)
         {
            _loc4_.SolveVelocityConstraints();
            _loc3_ = 0;
            while(_loc3_ < this.m_jointCount)
            {
               this.m_joints[_loc3_].SolveVelocityConstraints(subStep);
               _loc3_++;
            }
            _loc2_++;
         }
         _loc2_ = 0;
         while(_loc2_ < this.m_bodyCount)
         {
            _loc6_ = this.m_bodies[_loc2_];
            if(_loc6_.GetType() != b2Body.b2_staticBody)
            {
               _loc7_ = subStep.dt * _loc6_.m_linearVelocity.x;
               _loc8_ = subStep.dt * _loc6_.m_linearVelocity.y;
               if(_loc7_ * _loc7_ + _loc8_ * _loc8_ > b2Settings.b2_maxTranslationSquared)
               {
                  _loc6_.m_linearVelocity.Normalize();
                  _loc6_.m_linearVelocity.x *= b2Settings.b2_maxTranslation * subStep.inv_dt;
                  _loc6_.m_linearVelocity.y *= b2Settings.b2_maxTranslation * subStep.inv_dt;
               }
               _loc9_ = subStep.dt * _loc6_.m_angularVelocity;
               if(_loc9_ * _loc9_ > b2Settings.b2_maxRotationSquared)
               {
                  if(_loc6_.m_angularVelocity < 0)
                  {
                     _loc6_.m_angularVelocity = -b2Settings.b2_maxRotation * subStep.inv_dt;
                  }
                  else
                  {
                     _loc6_.m_angularVelocity = b2Settings.b2_maxRotation * subStep.inv_dt;
                  }
               }
               _loc6_.m_sweep.c0.SetV(_loc6_.m_sweep.c);
               _loc6_.m_sweep.a0 = _loc6_.m_sweep.a;
               _loc6_.m_sweep.c.x += subStep.dt * _loc6_.m_linearVelocity.x;
               _loc6_.m_sweep.c.y += subStep.dt * _loc6_.m_linearVelocity.y;
               _loc6_.m_sweep.a += subStep.dt * _loc6_.m_angularVelocity;
               _loc6_.SynchronizeTransform();
            }
            _loc2_++;
         }
         var _loc5_:Number = 0.75;
         _loc2_ = 0;
         while(_loc2_ < subStep.positionIterations)
         {
            _loc10_ = _loc4_.SolvePositionConstraints(_loc5_);
            _loc11_ = true;
            _loc3_ = 0;
            while(_loc3_ < this.m_jointCount)
            {
               _loc12_ = this.m_joints[_loc3_].SolvePositionConstraints(b2Settings.b2_contactBaumgarte);
               _loc11_ &&= _loc12_;
               _loc3_++;
            }
            if(_loc10_ && _loc11_)
            {
               break;
            }
            _loc2_++;
         }
         this.Report(_loc4_.m_constraints);
      }
      
      public function Report(constraints:Vector.<b2ContactConstraint>) : void
      {
         var _loc3_:b2Contact = null;
         var _loc4_:b2ContactConstraint = null;
         var _loc5_:* = 0;
         if(this.m_listener == null)
         {
            return;
         }
         var _loc2_:* = 0;
         while(_loc2_ < this.m_contactCount)
         {
            _loc3_ = this.m_contacts[_loc2_];
            _loc4_ = constraints[_loc2_];
            _loc5_ = 0;
            while(_loc5_ < _loc4_.pointCount)
            {
               s_impulse.normalImpulses[_loc5_] = _loc4_.points[_loc5_].normalImpulse;
               s_impulse.tangentImpulses[_loc5_] = _loc4_.points[_loc5_].tangentImpulse;
               _loc5_++;
            }
            this.m_listener.PostSolve(_loc3_,s_impulse);
            _loc2_++;
         }
      }
      
      public function AddBody(body:b2Body) : void
      {
         body.m_islandIndex = this.m_bodyCount;
         this.m_bodies[this.m_bodyCount++] = body;
      }
      
      public function AddContact(contact:b2Contact) : void
      {
         this.m_contacts[this.m_contactCount++] = contact;
      }
      
      public function AddJoint(joint:b2Joint) : void
      {
         this.m_joints[this.m_jointCount++] = joint;
      }
   }
}

