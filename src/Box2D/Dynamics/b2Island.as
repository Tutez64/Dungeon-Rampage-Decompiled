package Box2D.Dynamics
{
   import Box2D.Common.Math.b2Math;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Common.b2Settings;
   import Box2D.Dynamics.Contacts.b2Contact;
   import Box2D.Dynamics.Contacts.b2ContactConstraint;
   import Box2D.Dynamics.Contacts.b2ContactConstraintPoint;
   import Box2D.Dynamics.Contacts.b2ContactSolver;
   import Box2D.Dynamics.Joints.b2Joint;
   import box2dcompat.As3Array;
   import flash.Boot;
   
   public class b2Island
   {
      
      public static var s_impulse:b2ContactImpulse = new b2ContactImpulse();
      
      public var m_listener:b2ContactListener;
      
      public var m_joints:Array;
      
      public var m_jointCount:int;
      
      public var m_jointCapacity:int;
      
      public var m_contacts:Array;
      
      public var m_contactSolver:b2ContactSolver;
      
      public var m_contactCount:int;
      
      public var m_contactCapacity:int;
      
      public var m_bodyCount:int;
      
      public var m_bodyCapacity:int;
      
      public var m_bodies:Array;
      
      public var m_allocator:*;
      
      public function b2Island()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         m_jointCapacity = 0;
         m_contactCapacity = 0;
         m_bodyCapacity = 0;
         m_contactCount = 0;
         m_jointCount = 0;
         m_bodyCount = 0;
         m_bodies = [];
         m_contacts = [];
         m_joints = [];
      }
      
      public function solveTOI(subStep:b2TimeStep) : void
      {
         SolveTOI(subStep);
      }
      
      public function solve(step:b2TimeStep, gravity:b2Vec2, allowSleep:Boolean) : void
      {
         Solve(step,gravity,allowSleep);
      }
      
      public function report(constraints:Array) : void
      {
         var _loc4_:int = 0;
         var _loc5_:* = null as b2Contact;
         var _loc6_:* = null as b2ContactConstraint;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         if(m_listener == null)
         {
            return;
         }
         var _loc2_:int = 0;
         var _loc3_:int = m_contactCount;
         while(_loc2_ < _loc3_)
         {
            _loc4_ = _loc2_++;
            _loc5_ = m_contacts[_loc4_];
            _loc6_ = constraints[_loc4_];
            _loc7_ = 0;
            _loc8_ = _loc6_.pointCount;
            while(_loc7_ < _loc8_)
            {
               _loc9_ = _loc7_++;
               b2Island.s_impulse.normalImpulses[_loc9_] = _loc6_.points[_loc9_].normalImpulse;
               b2Island.s_impulse.tangentImpulses[_loc9_] = _loc6_.points[_loc9_].tangentImpulse;
            }
            m_listener.postSolve(_loc5_,b2Island.s_impulse);
         }
      }
      
      public function initialize(bodyCapacity:int, contactCapacity:int, jointCapacity:int, allocator:*, listener:b2ContactListener, contactSolver:b2ContactSolver) : void
      {
         Initialize(bodyCapacity,contactCapacity,jointCapacity,allocator,listener,contactSolver);
      }
      
      public function clear() : void
      {
         Clear();
      }
      
      public function addJoint(joint:b2Joint) : void
      {
         AddJoint(joint);
      }
      
      public function addContact(contact:b2Contact) : void
      {
         AddContact(contact);
      }
      
      public function addBody(body:b2Body) : void
      {
         AddBody(body);
      }
      
      public function SolveTOI(subStep:b2TimeStep) : void
      {
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc11_:* = null as b2Body;
         var _loc12_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Boolean = false;
         var _loc16_:Boolean = false;
         var _loc17_:Boolean = false;
         m_contactSolver.initialize(subStep,m_contacts,m_contactCount,m_allocator);
         var _loc4_:b2ContactSolver = m_contactSolver;
         var _loc5_:int = 0;
         var _loc6_:int = m_jointCount;
         while(_loc5_ < _loc6_)
         {
            _loc7_ = _loc5_++;
            m_joints[_loc7_].initVelocityConstraints(subStep);
         }
         _loc5_ = 0;
         _loc6_ = subStep.velocityIterations;
         while(_loc5_ < _loc6_)
         {
            _loc7_ = _loc5_++;
            _loc4_.solveVelocityConstraints();
            _loc8_ = 0;
            _loc9_ = m_jointCount;
            while(_loc8_ < _loc9_)
            {
               _loc10_ = _loc8_++;
               m_joints[_loc10_].solveVelocityConstraints(subStep);
            }
         }
         _loc5_ = 0;
         _loc6_ = m_bodyCount;
         while(_loc5_ < _loc6_)
         {
            _loc7_ = _loc5_++;
            _loc11_ = m_bodies[_loc7_];
            if(_loc11_.m_type != 0)
            {
               _loc12_ = subStep.dt * _loc11_.m_linearVelocity.x;
               _loc13_ = subStep.dt * _loc11_.m_linearVelocity.y;
               if(_loc12_ * _loc12_ + _loc13_ * _loc13_ > b2Settings.b2_maxTranslationSquared)
               {
                  _loc11_.m_linearVelocity.normalize();
                  _loc11_.m_linearVelocity.x *= b2Settings.b2_maxTranslation * subStep.inv_dt;
                  _loc11_.m_linearVelocity.y *= b2Settings.b2_maxTranslation * subStep.inv_dt;
               }
               _loc14_ = subStep.dt * _loc11_.m_angularVelocity;
               if(_loc14_ * _loc14_ > b2Settings.b2_maxRotationSquared)
               {
                  if(_loc11_.m_angularVelocity < 0)
                  {
                     _loc11_.m_angularVelocity = -b2Settings.b2_maxRotation * subStep.inv_dt;
                  }
                  else
                  {
                     _loc11_.m_angularVelocity = b2Settings.b2_maxRotation * subStep.inv_dt;
                  }
               }
               _loc11_.m_sweep.c0.setV(_loc11_.m_sweep.c);
               _loc11_.m_sweep.a0 = _loc11_.m_sweep.a;
               _loc11_.m_sweep.c.x += subStep.dt * _loc11_.m_linearVelocity.x;
               _loc11_.m_sweep.c.y += subStep.dt * _loc11_.m_linearVelocity.y;
               _loc11_.m_sweep.a += subStep.dt * _loc11_.m_angularVelocity;
               _loc11_.synchronizeTransform();
            }
         }
         _loc12_ = 0.75;
         _loc5_ = 0;
         _loc6_ = subStep.positionIterations;
         while(_loc5_ < _loc6_)
         {
            _loc7_ = _loc5_++;
            _loc15_ = _loc4_.solvePositionConstraints(_loc12_);
            _loc16_ = true;
            _loc8_ = 0;
            _loc9_ = m_jointCount;
            while(_loc8_ < _loc9_)
            {
               _loc10_ = _loc8_++;
               _loc17_ = m_joints[_loc10_].solvePositionConstraints(b2Settings.b2_contactBaumgarte);
               _loc16_ &&= _loc17_;
            }
            if(_loc15_ && _loc16_)
            {
               break;
            }
         }
         report(_loc4_.m_constraints);
      }
      
      public function Solve(step:b2TimeStep, gravity:b2Vec2, allowSleep:Boolean) : void
      {
         var _loc6_:* = null as b2Body;
         var _loc7_:* = null as b2Joint;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc18_:Boolean = false;
         var _loc19_:Boolean = false;
         var _loc20_:Boolean = false;
         _loc8_ = 0;
         _loc9_ = m_bodyCount;
         while(_loc8_ < _loc9_)
         {
            _loc10_ = _loc8_++;
            _loc6_ = m_bodies[_loc10_];
            if(_loc6_.m_type == 2)
            {
               _loc6_.m_linearVelocity.x += step.dt * (_loc6_.m_gravityScale * gravity.x + _loc6_.m_invMass * _loc6_.m_force.x);
               _loc6_.m_linearVelocity.y += step.dt * (_loc6_.m_gravityScale * gravity.y + _loc6_.m_invMass * _loc6_.m_force.y);
               _loc6_.m_angularVelocity += step.dt * _loc6_.m_invI * _loc6_.m_torque;
               _loc6_.m_linearVelocity.multiply(b2Math.clamp(1 - step.dt * _loc6_.m_linearDamping,0,1));
               _loc6_.m_angularVelocity *= b2Math.clamp(1 - step.dt * _loc6_.m_angularDamping,0,1);
            }
         }
         m_contactSolver.initialize(step,m_contacts,m_contactCount,m_allocator);
         var _loc11_:b2ContactSolver = m_contactSolver;
         _loc11_.initVelocityConstraints(step);
         _loc8_ = 0;
         _loc9_ = m_jointCount;
         while(_loc8_ < _loc9_)
         {
            _loc10_ = _loc8_++;
            _loc7_ = m_joints[_loc10_];
            _loc7_.initVelocityConstraints(step);
         }
         _loc8_ = 0;
         _loc9_ = step.velocityIterations;
         while(_loc8_ < _loc9_)
         {
            _loc10_ = _loc8_++;
            _loc12_ = 0;
            _loc13_ = m_jointCount;
            while(_loc12_ < _loc13_)
            {
               _loc14_ = _loc12_++;
               _loc7_ = m_joints[_loc14_];
               _loc7_.solveVelocityConstraints(step);
            }
            _loc11_.solveVelocityConstraints();
         }
         _loc8_ = 0;
         _loc9_ = m_jointCount;
         while(_loc8_ < _loc9_)
         {
            _loc10_ = _loc8_++;
            _loc7_ = m_joints[_loc10_];
            _loc7_.finalizeVelocityConstraints();
         }
         _loc11_.finalizeVelocityConstraints();
         _loc8_ = 0;
         _loc9_ = m_bodyCount;
         while(_loc8_ < _loc9_)
         {
            _loc10_ = _loc8_++;
            _loc6_ = m_bodies[_loc10_];
            if(_loc6_.m_type != 0)
            {
               _loc15_ = step.dt * _loc6_.m_linearVelocity.x;
               _loc16_ = step.dt * _loc6_.m_linearVelocity.y;
               if(_loc15_ * _loc15_ + _loc16_ * _loc16_ > b2Settings.b2_maxTranslationSquared)
               {
                  _loc6_.m_linearVelocity.normalize();
                  _loc6_.m_linearVelocity.x *= b2Settings.b2_maxTranslation * step.inv_dt;
                  _loc6_.m_linearVelocity.y *= b2Settings.b2_maxTranslation * step.inv_dt;
               }
               _loc17_ = step.dt * _loc6_.m_angularVelocity;
               if(_loc17_ * _loc17_ > b2Settings.b2_maxRotationSquared)
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
               _loc6_.m_sweep.c0.setV(_loc6_.m_sweep.c);
               _loc6_.m_sweep.a0 = _loc6_.m_sweep.a;
               _loc6_.m_sweep.c.x += step.dt * _loc6_.m_linearVelocity.x;
               _loc6_.m_sweep.c.y += step.dt * _loc6_.m_linearVelocity.y;
               _loc6_.m_sweep.a += step.dt * _loc6_.m_angularVelocity;
               _loc6_.synchronizeTransform();
            }
         }
         _loc8_ = 0;
         _loc9_ = step.positionIterations;
         while(_loc8_ < _loc9_)
         {
            _loc10_ = _loc8_++;
            _loc18_ = _loc11_.solvePositionConstraints(b2Settings.b2_contactBaumgarte);
            _loc19_ = true;
            _loc12_ = 0;
            _loc13_ = m_jointCount;
            while(_loc12_ < _loc13_)
            {
               _loc14_ = _loc12_++;
               _loc7_ = m_joints[_loc14_];
               _loc20_ = _loc7_.solvePositionConstraints(b2Settings.b2_contactBaumgarte);
               _loc19_ &&= _loc20_;
            }
            if(_loc18_ && _loc19_)
            {
               break;
            }
         }
         report(_loc11_.m_constraints);
         if(allowSleep)
         {
            _loc15_ = Number(Number.MAX_VALUE);
            _loc16_ = b2Settings.b2_linearSleepTolerance * b2Settings.b2_linearSleepTolerance;
            _loc17_ = b2Settings.b2_angularSleepTolerance * b2Settings.b2_angularSleepTolerance;
            _loc8_ = 0;
            _loc9_ = m_bodyCount;
            while(_loc8_ < _loc9_)
            {
               _loc10_ = _loc8_++;
               _loc6_ = m_bodies[_loc10_];
               if(_loc6_.m_type != 0)
               {
                  if((_loc6_.m_flags & b2Body.e_allowSleepFlag) == 0)
                  {
                     _loc6_.m_sleepTime = 0;
                     _loc15_ = 0;
                  }
                  if((_loc6_.m_flags & b2Body.e_allowSleepFlag) == 0 || _loc6_.m_angularVelocity * _loc6_.m_angularVelocity > _loc17_ || b2Math.dot(_loc6_.m_linearVelocity,_loc6_.m_linearVelocity) > _loc16_)
                  {
                     _loc6_.m_sleepTime = 0;
                     _loc15_ = 0;
                  }
                  else
                  {
                     _loc6_.m_sleepTime += step.dt;
                     _loc15_ = b2Math.min(_loc15_,_loc6_.m_sleepTime);
                  }
               }
            }
            if(_loc15_ >= b2Settings.b2_timeToSleep)
            {
               _loc8_ = 0;
               _loc9_ = m_bodyCount;
               while(_loc8_ < _loc9_)
               {
                  _loc10_ = _loc8_++;
                  _loc6_ = m_bodies[_loc10_];
                  _loc6_.setAwake(false);
               }
            }
         }
      }
      
      public function Report(constraints:*) : void
      {
         report(As3Array.of(constraints));
      }
      
      public function Initialize(bodyCapacity:int, contactCapacity:int, jointCapacity:int, allocator:*, listener:b2ContactListener, contactSolver:b2ContactSolver) : void
      {
         var _loc10_:int = 0;
         m_bodyCapacity = bodyCapacity;
         m_contactCapacity = contactCapacity;
         m_jointCapacity = jointCapacity;
         m_bodyCount = 0;
         m_contactCount = 0;
         m_jointCount = 0;
         m_allocator = allocator;
         m_listener = listener;
         m_contactSolver = contactSolver;
         var _loc8_:int = int(m_bodies.length);
         var _loc9_:int = bodyCapacity;
         while(_loc8_ < _loc9_)
         {
            _loc10_ = _loc8_++;
            m_bodies[_loc10_] = null;
         }
         _loc8_ = int(m_contacts.length);
         _loc9_ = contactCapacity;
         while(_loc8_ < _loc9_)
         {
            _loc10_ = _loc8_++;
            m_contacts[_loc10_] = null;
         }
         _loc8_ = int(m_joints.length);
         _loc9_ = jointCapacity;
         while(_loc8_ < _loc9_)
         {
            _loc10_ = _loc8_++;
            m_joints[_loc10_] = null;
         }
      }
      
      public function Clear() : void
      {
         m_bodyCount = 0;
         m_contactCount = 0;
         m_jointCount = 0;
      }
      
      public function AddJoint(joint:b2Joint) : void
      {
         var _temp_2:* = m_joints;
         var _loc2_:int;
         m_jointCount = (_loc2_ = m_jointCount) + 1;
         _temp_2[_loc2_] = joint;
      }
      
      public function AddContact(contact:b2Contact) : void
      {
         var _temp_2:* = m_contacts;
         var _loc2_:int;
         m_contactCount = (_loc2_ = m_contactCount) + 1;
         _temp_2[_loc2_] = contact;
      }
      
      public function AddBody(body:b2Body) : void
      {
         body.m_islandIndex = m_bodyCount;
         var _temp_2:* = m_bodies;
         var _loc2_:int;
         m_bodyCount = (_loc2_ = m_bodyCount) + 1;
         _temp_2[_loc2_] = body;
      }
   }
}

