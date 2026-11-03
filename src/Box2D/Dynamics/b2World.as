package Box2D.Dynamics
{
   import Box2D.Collision.IBroadPhase;
   import Box2D.Collision.Shapes.b2CircleShape;
   import Box2D.Collision.Shapes.b2EdgeShape;
   import Box2D.Collision.Shapes.b2PolygonShape;
   import Box2D.Collision.Shapes.b2Shape;
   import Box2D.Collision.b2AABB;
   import Box2D.Collision.b2DynamicTreeBroadPhase;
   import Box2D.Collision.b2RayCastInput;
   import Box2D.Collision.b2RayCastOutput;
   import Box2D.Common.Math.b2Math;
   import Box2D.Common.Math.b2Sweep;
   import Box2D.Common.Math.b2Transform;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Common.b2Color;
   import Box2D.Common.b2Settings;
   import Box2D.Dynamics.Contacts.b2Contact;
   import Box2D.Dynamics.Contacts.b2ContactEdge;
   import Box2D.Dynamics.Contacts.b2ContactSolver;
   import Box2D.Dynamics.Controllers.b2Controller;
   import Box2D.Dynamics.Controllers.b2ControllerEdge;
   import Box2D.Dynamics.Joints.b2Joint;
   import Box2D.Dynamics.Joints.b2JointDef;
   import Box2D.Dynamics.Joints.b2JointEdge;
   import Box2D.Dynamics.Joints.b2PulleyJoint;
   import flash.Boot;
   import haxe.Exception;
   
   public class b2World
   {
      
      public static var m_warmStarting:Boolean;
      
      public static var m_continuousPhysics:Boolean;
      
      public static var e_newFixture:int = 1;
      
      public static var e_locked:int = 2;
      
      public static var s_timestep2:b2TimeStep = new b2TimeStep();
      
      public static var s_xf:b2Transform = new b2Transform();
      
      public static var s_backupA:b2Sweep = new b2Sweep();
      
      public static var s_backupB:b2Sweep = new b2Sweep();
      
      public static var s_timestep:b2TimeStep = new b2TimeStep();
      
      public static var s_queue:Array = [];
      
      public static var s_jointColor:b2Color = new b2Color(0.5,0.8,0.8);
      
      public var s_stack:Array;
      
      public var m_jointList:b2Joint;
      
      public var m_jointCount:int;
      
      public var m_island:b2Island;
      
      public var m_inv_dt0:Number;
      
      public var m_groundBody:b2Body;
      
      public var m_gravity:b2Vec2;
      
      public var m_flags:int;
      
      public var m_destructionListener:b2DestructionListener;
      
      public var m_debugDraw:b2DebugDraw;
      
      public var m_controllerList:b2Controller;
      
      public var m_controllerCount:int;
      
      public var m_contactSolver:b2ContactSolver;
      
      public var m_contactManager:b2ContactManager;
      
      public var m_contactList:b2Contact;
      
      public var m_bodyList:b2Body;
      
      public var m_bodyCount:int;
      
      public var m_allowSleep:Boolean;
      
      public function b2World(gravity:b2Vec2 = undefined, doSleep:Boolean = false)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         s_stack = [];
         m_contactManager = new b2ContactManager();
         m_contactSolver = new b2ContactSolver();
         m_island = new b2Island();
         m_destructionListener = null;
         m_debugDraw = null;
         m_bodyList = null;
         m_contactList = null;
         m_jointList = null;
         m_controllerList = null;
         m_bodyCount = 0;
         m_jointCount = 0;
         m_controllerCount = 0;
         b2World.m_warmStarting = true;
         b2World.m_continuousPhysics = true;
         m_allowSleep = doSleep;
         m_gravity = gravity;
         m_inv_dt0 = 0;
         m_flags = 0;
         m_contactManager.m_world = this;
         var _loc3_:b2BodyDef = new b2BodyDef();
         m_groundBody = createBody(_loc3_);
      }
      
      public function validate() : void
      {
         Validate();
      }
      
      public function step(dt:Number, velocityIterations:int, positionIterations:int) : void
      {
         Step(dt,velocityIterations,positionIterations);
      }
      
      public function solveTOI(step:b2TimeStep) : void
      {
         SolveTOI(step);
      }
      
      public function solve(step:b2TimeStep) : void
      {
         Solve(step);
      }
      
      public function setWarmStarting(flag:Boolean) : void
      {
         SetWarmStarting(flag);
      }
      
      public function setGravity(gravity:b2Vec2) : void
      {
         SetGravity(gravity);
      }
      
      public function setDestructionListener(listener:b2DestructionListener) : void
      {
         SetDestructionListener(listener);
      }
      
      public function setDebugDraw(debugDraw:b2DebugDraw) : void
      {
         SetDebugDraw(debugDraw);
      }
      
      public function setContinuousPhysics(flag:Boolean) : void
      {
         SetContinuousPhysics(flag);
      }
      
      public function setContactListener(listener:b2ContactListener) : void
      {
         SetContactListener(listener);
      }
      
      public function setContactFilter(filter:b2ContactFilter) : void
      {
         SetContactFilter(filter);
      }
      
      public function setBroadPhase(broadPhase:IBroadPhase) : void
      {
         SetBroadPhase(broadPhase);
      }
      
      public function removeController(c:b2Controller) : void
      {
         RemoveController(c);
      }
      
      public function rayCastOne(point1:b2Vec2, point2:b2Vec2) : b2Fixture
      {
         return RayCastOne(point1,point2);
      }
      
      public function rayCastAll(point1:b2Vec2, point2:b2Vec2) : Array
      {
         return RayCastAll(point1,point2);
      }
      
      public function rayCast(callbackMethod:Function, point1:b2Vec2, point2:b2Vec2) : void
      {
         RayCast(callbackMethod,point1,point2);
      }
      
      public function queryShape(callbackMethod:Function, shape:b2Shape, transform:b2Transform = undefined) : void
      {
         QueryShape(callbackMethod,shape,transform);
      }
      
      public function queryPoint(callbackMethod:Function, p:b2Vec2) : void
      {
         QueryPoint(callbackMethod,p);
      }
      
      public function queryAABB(callbackMethod:Function, aabb:b2AABB) : void
      {
         QueryAABB(callbackMethod,aabb);
      }
      
      public function isLocked() : Boolean
      {
         return IsLocked();
      }
      
      public function getProxyCount() : int
      {
         return GetProxyCount();
      }
      
      public function getJointList() : b2Joint
      {
         return GetJointList();
      }
      
      public function getJointCount() : int
      {
         return GetJointCount();
      }
      
      public function getGroundBody() : b2Body
      {
         return GetGroundBody();
      }
      
      public function getGravity() : b2Vec2
      {
         return GetGravity();
      }
      
      public function getContactList() : b2Contact
      {
         return GetContactList();
      }
      
      public function getContactCount() : int
      {
         return GetContactCount();
      }
      
      public function getBodyList() : b2Body
      {
         return GetBodyList();
      }
      
      public function getBodyCount() : int
      {
         return GetBodyCount();
      }
      
      public function drawShape(shape:b2Shape, xf:b2Transform, color:b2Color) : void
      {
         DrawShape(shape,xf,color);
      }
      
      public function drawJoint(joint:b2Joint) : void
      {
         DrawJoint(joint);
      }
      
      public function drawDebugData() : void
      {
         DrawDebugData();
      }
      
      public function destroyJoint(j:b2Joint) : void
      {
         DestroyJoint(j);
      }
      
      public function destroyController(controller:b2Controller) : void
      {
         DestroyController(controller);
      }
      
      public function destroyBody(b:b2Body) : void
      {
         DestroyBody(b);
      }
      
      public function createJoint(def:b2JointDef) : b2Joint
      {
         return CreateJoint(def);
      }
      
      public function createController(controller:b2Controller) : b2Controller
      {
         return CreateController(controller);
      }
      
      public function createBody(def:b2BodyDef) : b2Body
      {
         return CreateBody(def);
      }
      
      public function clearForces() : void
      {
         ClearForces();
      }
      
      public function addController(c:b2Controller) : b2Controller
      {
         return AddController(c);
      }
      
      public function Validate() : void
      {
         m_contactManager.m_broadPhase.validate();
      }
      
      public function Step(dt:Number, velocityIterations:int, positionIterations:int) : void
      {
         var _loc4_:IBroadPhase = m_contactManager.m_broadPhase;
         var _loc5_:b2DynamicTreeBroadPhase = (_loc4_) as b2DynamicTreeBroadPhase;
         if(_loc5_ != null)
         {
            _loc5_.endAbandonedQueries();
         }
         if((m_flags & b2World.e_newFixture) != 0)
         {
            m_contactManager.findNewContacts();
            m_flags &= ~b2World.e_newFixture;
         }
         m_flags |= b2World.e_locked;
         var _loc6_:b2TimeStep = b2World.s_timestep2;
         _loc6_.dt = dt;
         _loc6_.velocityIterations = velocityIterations;
         _loc6_.positionIterations = positionIterations;
         if(dt > 0)
         {
            _loc6_.inv_dt = 1 / dt;
         }
         else
         {
            _loc6_.inv_dt = 0;
         }
         _loc6_.dtRatio = m_inv_dt0 * dt;
         _loc6_.warmStarting = b2World.m_warmStarting;
         m_contactManager.collide();
         if(_loc6_.dt > 0)
         {
            solve(_loc6_);
         }
         if(b2World.m_continuousPhysics && _loc6_.dt > 0)
         {
            solveTOI(_loc6_);
         }
         if(_loc6_.dt > 0)
         {
            m_inv_dt0 = _loc6_.inv_dt;
         }
         m_flags &= ~b2World.e_locked;
      }
      
      public function SolveTOI(step:b2TimeStep) : void
      {
         var _loc2_:* = null as b2Fixture;
         var _loc3_:* = null as b2Fixture;
         var _loc4_:* = null as b2Body;
         var _loc5_:* = null as b2Body;
         var _loc6_:* = null as b2ContactEdge;
         var _loc12_:* = null as b2Contact;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:* = null as b2Body;
         var _loc17_:int = 0;
         var _loc18_:int = 0;
         var _loc19_:* = null as b2Body;
         var _loc20_:* = null as b2JointEdge;
         var _loc21_:* = null as b2TimeStep;
         var _loc23_:int = 0;
         var _loc24_:int = 0;
         var _loc25_:int = 0;
         var _loc7_:b2Island = m_island;
         _loc7_.initialize(m_bodyCount,b2Settings.b2_maxTOIContactsPerIsland,b2Settings.b2_maxTOIJointsPerIsland,null,m_contactManager.m_contactListener,m_contactSolver);
         var _loc8_:Array = b2World.s_queue;
         var _loc9_:b2Body = m_bodyList;
         while(_loc9_ != null)
         {
            _loc9_.m_flags &= ~b2Body.e_islandFlag;
            _loc9_.m_sweep.t0 = 0;
            _loc9_ = _loc9_.m_next;
         }
         var _loc10_:b2Contact = m_contactList;
         while(_loc10_ != null)
         {
            _loc10_.m_flags &= ~(b2Contact.e_toiFlag | b2Contact.e_islandFlag);
            _loc10_ = _loc10_.m_next;
         }
         var _loc11_:b2Joint = m_jointList;
         while(_loc11_ != null)
         {
            _loc11_.m_islandFlag = false;
            _loc11_ = _loc11_.m_next;
         }
         while(true)
         {
            _loc12_ = null;
            _loc13_ = 1;
            _loc10_ = m_contactList;
            while(_loc10_ != null)
            {
               if(_loc10_.isSensor() == true || _loc10_.isEnabled() == false || _loc10_.isContinuous() == false)
               {
                  _loc10_ = _loc10_.m_next;
               }
               else
               {
                  _loc14_ = 1;
                  if((_loc10_.m_flags & b2Contact.e_toiFlag) != 0)
                  {
                     _loc14_ = _loc10_.m_toi;
                  }
                  else
                  {
                     _loc2_ = _loc10_.m_fixtureA;
                     _loc3_ = _loc10_.m_fixtureB;
                     _loc4_ = _loc2_.m_body;
                     _loc5_ = _loc3_.m_body;
                     if((_loc4_.m_type != 2 || (_loc4_.m_flags & b2Body.e_awakeFlag) == b2Body.e_awakeFlag == false) && (_loc5_.m_type != 2 || (_loc5_.m_flags & b2Body.e_awakeFlag) == b2Body.e_awakeFlag == false))
                     {
                        _loc10_ = _loc10_.m_next;
                        continue;
                     }
                     _loc15_ = _loc4_.m_sweep.t0;
                     if(_loc4_.m_sweep.t0 < _loc5_.m_sweep.t0)
                     {
                        _loc15_ = _loc5_.m_sweep.t0;
                        _loc4_.m_sweep.advance(_loc15_);
                     }
                     else if(_loc5_.m_sweep.t0 < _loc4_.m_sweep.t0)
                     {
                        _loc15_ = _loc4_.m_sweep.t0;
                        _loc5_.m_sweep.advance(_loc15_);
                     }
                     _loc14_ = _loc10_.computeTOI(_loc4_.m_sweep,_loc5_.m_sweep);
                     b2Settings.b2Assert(0 <= _loc14_ && _loc14_ <= 1);
                     if(_loc14_ > 0 && _loc14_ < 1)
                     {
                        _loc14_ = (1 - _loc14_) * _loc15_ + _loc14_;
                        if(_loc14_ > 1)
                        {
                           _loc14_ = 1;
                        }
                     }
                     _loc10_.m_toi = _loc14_;
                     _loc10_.m_flags |= b2Contact.e_toiFlag;
                  }
                  if(Number(Number.MIN_VALUE) < _loc14_ && _loc14_ < _loc13_)
                  {
                     _loc12_ = _loc10_;
                     _loc13_ = _loc14_;
                  }
                  _loc10_ = _loc10_.m_next;
               }
            }
            if(_loc12_ == null || 1 - 100 * Number(Number.MIN_VALUE) < _loc13_)
            {
               break;
            }
            _loc2_ = _loc12_.m_fixtureA;
            _loc3_ = _loc12_.m_fixtureB;
            _loc4_ = _loc2_.m_body;
            _loc5_ = _loc3_.m_body;
            b2World.s_backupA.set(_loc4_.m_sweep);
            b2World.s_backupB.set(_loc5_.m_sweep);
            _loc4_.advance(_loc13_);
            _loc5_.advance(_loc13_);
            _loc12_.update(m_contactManager.m_contactListener);
            _loc12_.m_flags &= ~b2Contact.e_toiFlag;
            if(_loc12_.isSensor() == true || _loc12_.isEnabled() == false)
            {
               _loc4_.m_sweep.set(b2World.s_backupA);
               _loc5_.m_sweep.set(b2World.s_backupB);
               _loc4_.synchronizeTransform();
               _loc5_.synchronizeTransform();
            }
            else if(_loc12_.isTouching() != false)
            {
               _loc16_ = _loc4_;
               if(_loc16_.m_type != 2)
               {
                  _loc16_ = _loc5_;
               }
               _loc7_.clear();
               _loc17_ = 0;
               _loc18_ = 0;
               _loc8_[_loc17_ + _loc18_++] = _loc16_;
               _loc16_.m_flags |= b2Body.e_islandFlag;
               while(_loc18_ > 0)
               {
                  _loc9_ = _loc8_[_loc17_++];
                  _loc18_--;
                  _loc7_.addBody(_loc9_);
                  if((_loc9_.m_flags & b2Body.e_awakeFlag) == b2Body.e_awakeFlag == false)
                  {
                     _loc9_.setAwake(true);
                  }
                  if(_loc9_.m_type == 2)
                  {
                     _loc6_ = _loc9_.m_contactList;
                     while(_loc6_ != null)
                     {
                        if(_loc7_.m_contactCount == _loc7_.m_contactCapacity)
                        {
                           _loc6_ = _loc6_.next;
                           break;
                        }
                        if((_loc6_.contact.m_flags & b2Contact.e_islandFlag) != 0)
                        {
                           _loc6_ = _loc6_.next;
                        }
                        else if(_loc6_.contact.isSensor() == true || _loc6_.contact.isEnabled() == false || _loc6_.contact.isTouching() == false)
                        {
                           _loc6_ = _loc6_.next;
                        }
                        else
                        {
                           _loc7_.addContact(_loc6_.contact);
                           _loc6_.contact.m_flags |= b2Contact.e_islandFlag;
                           _loc19_ = _loc6_.other;
                           if((_loc19_.m_flags & b2Body.e_islandFlag) != 0)
                           {
                              _loc6_ = _loc6_.next;
                           }
                           else
                           {
                              if(_loc19_.m_type != 0)
                              {
                                 _loc19_.advance(_loc13_);
                                 _loc19_.setAwake(true);
                              }
                              _loc8_[_loc17_ + _loc18_] = _loc19_;
                              _loc18_++;
                              _loc19_.m_flags |= b2Body.e_islandFlag;
                              _loc6_ = _loc6_.next;
                           }
                        }
                     }
                     _loc20_ = _loc9_.m_jointList;
                     while(_loc20_ != null)
                     {
                        if(_loc7_.m_jointCount == _loc7_.m_jointCapacity)
                        {
                           _loc20_ = _loc20_.next;
                        }
                        else if(_loc20_.joint.m_islandFlag == true)
                        {
                           _loc20_ = _loc20_.next;
                        }
                        else
                        {
                           _loc19_ = _loc20_.other;
                           if((_loc19_.m_flags & b2Body.e_activeFlag) == b2Body.e_activeFlag == false)
                           {
                              _loc20_ = _loc20_.next;
                           }
                           else
                           {
                              _loc7_.addJoint(_loc20_.joint);
                              _loc20_.joint.m_islandFlag = true;
                              if((_loc19_.m_flags & b2Body.e_islandFlag) != 0)
                              {
                                 _loc20_ = _loc20_.next;
                              }
                              else
                              {
                                 if(_loc19_.m_type != 0)
                                 {
                                    _loc19_.advance(_loc13_);
                                    _loc19_.setAwake(true);
                                 }
                                 _loc8_[_loc17_ + _loc18_] = _loc19_;
                                 _loc18_++;
                                 _loc19_.m_flags |= b2Body.e_islandFlag;
                                 _loc20_ = _loc20_.next;
                              }
                           }
                        }
                     }
                  }
               }
               _loc21_ = b2World.s_timestep;
               _loc21_.warmStarting = false;
               _loc21_.dt = (1 - _loc13_) * step.dt;
               _loc21_.inv_dt = 1 / _loc21_.dt;
               _loc21_.dtRatio = 0;
               _loc21_.velocityIterations = step.velocityIterations;
               _loc21_.positionIterations = step.positionIterations;
               _loc7_.solveTOI(_loc21_);
               _loc23_ = 0;
               _loc24_ = _loc7_.m_bodyCount;
               while(_loc23_ < _loc24_)
               {
                  _loc25_ = _loc23_++;
                  _loc9_ = _loc7_.m_bodies[_loc25_];
                  _loc9_.m_flags &= ~b2Body.e_islandFlag;
                  if((_loc9_.m_flags & b2Body.e_awakeFlag) == b2Body.e_awakeFlag != false)
                  {
                     if(_loc9_.m_type == 2)
                     {
                        _loc9_.synchronizeFixtures();
                        _loc6_ = _loc9_.m_contactList;
                        while(_loc6_ != null)
                        {
                           _loc6_.contact.m_flags &= ~b2Contact.e_toiFlag;
                           _loc6_ = _loc6_.next;
                        }
                     }
                  }
               }
               _loc23_ = 0;
               _loc24_ = _loc7_.m_contactCount;
               while(_loc23_ < _loc24_)
               {
                  _loc25_ = _loc23_++;
                  _loc10_ = _loc7_.m_contacts[_loc25_];
                  _loc10_.m_flags &= ~(b2Contact.e_toiFlag | b2Contact.e_islandFlag);
               }
               _loc23_ = 0;
               _loc24_ = _loc7_.m_jointCount;
               while(_loc23_ < _loc24_)
               {
                  _loc25_ = _loc23_++;
                  _loc11_ = _loc7_.m_joints[_loc25_];
                  _loc11_.m_islandFlag = false;
               }
               m_contactManager.findNewContacts();
            }
         }
      }
      
      public function Solve(step:b2TimeStep) : void
      {
         var _loc10_:int = 0;
         var _loc11_:* = null as b2Body;
         var _loc12_:* = null as b2ContactEdge;
         var _loc13_:* = null as b2JointEdge;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc2_:b2Controller = m_controllerList;
         while(_loc2_ != null)
         {
            _loc2_.step(step);
            _loc2_ = _loc2_.m_next;
         }
         var _loc3_:b2Island = m_island;
         _loc3_.initialize(m_bodyCount,m_contactManager.m_contactCount,m_jointCount,null,m_contactManager.m_contactListener,m_contactSolver);
         var _loc4_:b2Body = m_bodyList;
         while(_loc4_ != null)
         {
            _loc4_.m_flags &= ~b2Body.e_islandFlag;
            _loc4_ = _loc4_.m_next;
         }
         var _loc5_:b2Contact = m_contactList;
         while(_loc5_ != null)
         {
            _loc5_.m_flags &= ~b2Contact.e_islandFlag;
            _loc5_ = _loc5_.m_next;
         }
         var _loc6_:b2Joint = m_jointList;
         while(_loc6_ != null)
         {
            _loc6_.m_islandFlag = false;
            _loc6_ = _loc6_.m_next;
         }
         var _loc7_:int = m_bodyCount;
         var _loc8_:Array = s_stack;
         var _loc9_:b2Body = m_bodyList;
         while(_loc9_ != null)
         {
            if((_loc9_.m_flags & b2Body.e_islandFlag) != 0)
            {
               _loc9_ = _loc9_.m_next;
            }
            else if((_loc9_.m_flags & b2Body.e_awakeFlag) == b2Body.e_awakeFlag == false || (_loc9_.m_flags & b2Body.e_activeFlag) == b2Body.e_activeFlag == false)
            {
               _loc9_ = _loc9_.m_next;
            }
            else if(_loc9_.m_type == 0)
            {
               _loc9_ = _loc9_.m_next;
            }
            else
            {
               _loc3_.clear();
               _loc10_ = 0;
               _loc8_[_loc10_++] = _loc9_;
               _loc9_.m_flags |= b2Body.e_islandFlag;
               while(_loc10_ > 0)
               {
                  _loc4_ = _loc8_[--_loc10_];
                  _loc3_.addBody(_loc4_);
                  if((_loc4_.m_flags & b2Body.e_awakeFlag) == b2Body.e_awakeFlag == false)
                  {
                     _loc4_.setAwake(true);
                  }
                  if(_loc4_.m_type != 0)
                  {
                     _loc12_ = _loc4_.m_contactList;
                     while(_loc12_ != null)
                     {
                        if((_loc12_.contact.m_flags & b2Contact.e_islandFlag) != 0)
                        {
                           _loc12_ = _loc12_.next;
                        }
                        else if(_loc12_.contact.isSensor() == true || _loc12_.contact.isEnabled() == false || _loc12_.contact.isTouching() == false)
                        {
                           _loc12_ = _loc12_.next;
                        }
                        else
                        {
                           _loc3_.addContact(_loc12_.contact);
                           _loc12_.contact.m_flags |= b2Contact.e_islandFlag;
                           _loc11_ = _loc12_.other;
                           if((_loc11_.m_flags & b2Body.e_islandFlag) != 0)
                           {
                              _loc12_ = _loc12_.next;
                           }
                           else
                           {
                              _loc8_[_loc10_++] = _loc11_;
                              _loc11_.m_flags |= b2Body.e_islandFlag;
                              _loc12_ = _loc12_.next;
                           }
                        }
                     }
                     _loc13_ = _loc4_.m_jointList;
                     while(_loc13_ != null)
                     {
                        if(_loc13_.joint.m_islandFlag == true)
                        {
                           _loc13_ = _loc13_.next;
                        }
                        else
                        {
                           _loc11_ = _loc13_.other;
                           if((_loc11_.m_flags & b2Body.e_activeFlag) == b2Body.e_activeFlag == false)
                           {
                              _loc13_ = _loc13_.next;
                           }
                           else
                           {
                              _loc3_.addJoint(_loc13_.joint);
                              _loc13_.joint.m_islandFlag = true;
                              if((_loc11_.m_flags & b2Body.e_islandFlag) != 0)
                              {
                                 _loc13_ = _loc13_.next;
                              }
                              else
                              {
                                 _loc8_[_loc10_++] = _loc11_;
                                 _loc11_.m_flags |= b2Body.e_islandFlag;
                                 _loc13_ = _loc13_.next;
                              }
                           }
                        }
                     }
                  }
               }
               _loc3_.solve(step,m_gravity,m_allowSleep);
               _loc14_ = 0;
               _loc15_ = _loc3_.m_bodyCount;
               while(_loc14_ < _loc15_)
               {
                  _loc16_ = _loc14_++;
                  _loc4_ = _loc3_.m_bodies[_loc16_];
                  if(_loc4_.m_type == 0)
                  {
                     _loc4_.m_flags &= ~b2Body.e_islandFlag;
                  }
               }
               _loc9_ = _loc9_.m_next;
            }
         }
         _loc10_ = 0;
         _loc14_ = int(_loc8_.length);
         while(_loc10_ < _loc14_)
         {
            _loc15_ = _loc10_++;
            if(_loc8_[_loc15_] == null)
            {
               break;
            }
            _loc8_[_loc15_] = null;
         }
         _loc4_ = m_bodyList;
         while(_loc4_ != null)
         {
            if((_loc4_.m_flags & b2Body.e_awakeFlag) == b2Body.e_awakeFlag == false || (_loc4_.m_flags & b2Body.e_activeFlag) == b2Body.e_activeFlag == false)
            {
               _loc4_ = _loc4_.m_next;
            }
            else if(_loc4_.m_type == 0)
            {
               _loc4_ = _loc4_.m_next;
            }
            else
            {
               _loc4_.synchronizeFixtures();
               _loc4_ = _loc4_.m_next;
            }
         }
         m_contactManager.findNewContacts();
      }
      
      public function SetWarmStarting(flag:Boolean) : void
      {
         b2World.m_warmStarting = flag;
      }
      
      public function SetGravity(gravity:b2Vec2) : void
      {
         m_gravity = gravity;
      }
      
      public function SetDestructionListener(listener:b2DestructionListener) : void
      {
         m_destructionListener = listener;
      }
      
      public function SetDebugDraw(debugDraw:b2DebugDraw) : void
      {
         m_debugDraw = debugDraw;
      }
      
      public function SetContinuousPhysics(flag:Boolean) : void
      {
         b2World.m_continuousPhysics = flag;
      }
      
      public function SetContactListener(listener:b2ContactListener) : void
      {
         m_contactManager.m_contactListener = listener;
      }
      
      public function SetContactFilter(filter:b2ContactFilter) : void
      {
         m_contactManager.m_contactFilter = filter;
      }
      
      public function SetBroadPhase(broadPhase:IBroadPhase) : void
      {
         var _loc4_:* = null as b2Fixture;
         var _loc2_:IBroadPhase = m_contactManager.m_broadPhase;
         m_contactManager.m_broadPhase = broadPhase;
         var _loc3_:b2Body = m_bodyList;
         while(_loc3_ != null)
         {
            _loc4_ = _loc3_.m_fixtureList;
            while(_loc4_ != null)
            {
               _loc4_.m_proxy = broadPhase.createProxy(_loc2_.getFatAABB(_loc4_.m_proxy),_loc4_);
               _loc4_ = _loc4_.m_next;
            }
            _loc3_ = _loc3_.m_next;
         }
      }
      
      public function RemoveController(c:b2Controller) : void
      {
         if(c.m_prev != null)
         {
            c.m_prev.m_next = c.m_next;
         }
         if(c.m_next != null)
         {
            c.m_next.m_prev = c.m_prev;
         }
         if(m_controllerList == c)
         {
            m_controllerList = c.m_next;
         }
         --m_controllerCount;
      }
      
      public function RayCastOne(point1:b2Vec2, point2:b2Vec2) : b2Fixture
      {
         var result:b2Fixture;
         var rayCastOneWrapper:Function = function(fixture:b2Fixture, point:b2Vec2, normal:b2Vec2, fraction:Number):Number
         {
            result = fixture;
            return fraction;
         };
         rayCast(rayCastOneWrapper,point1,point2);
         return result;
      }
      
      public function RayCastAll(point1:b2Vec2, point2:b2Vec2) : Array
      {
         var result:Array = [];
         var rayCastAllWrapper:Function = function(fixture:b2Fixture, point:b2Vec2, normal:b2Vec2, fraction:Number):Number
         {
            result[int(result.length)] = fixture;
            return 1;
         };
         rayCast(rayCastAllWrapper,point1,point2);
         return result;
      }
      
      public function RayCast(callbackMethod:Function, point1:b2Vec2, point2:b2Vec2) : void
      {
         var broadPhase:IBroadPhase = m_contactManager.m_broadPhase;
         var output:b2RayCastOutput = new b2RayCastOutput();
         var rayCastWrapper:Function = function(input:b2RayCastInput, proxy:*):Number
         {
            var _loc6_:Number = NaN;
            var _loc7_:* = null as b2Vec2;
            var _loc3_:* = broadPhase.getUserData(proxy);
            var _loc4_:b2Fixture = _loc3_;
            var _loc5_:Boolean = _loc4_.rayCast(output,input);
            if(_loc5_)
            {
               _loc6_ = output.fraction;
               _loc7_ = new b2Vec2((1 - _loc6_) * point1.x + _loc6_ * point2.x,(1 - _loc6_) * point1.y + _loc6_ * point2.y);
               return callbackMethod(_loc4_,_loc7_,output.normal,_loc6_);
            }
            return input.maxFraction;
         };
         var _loc4_:b2RayCastInput = new b2RayCastInput(point1,point2);
         broadPhase.rayCast(rayCastWrapper,_loc4_);
      }
      
      public function QueryShape(callbackMethod:Function, shape:b2Shape, transform:b2Transform = undefined) : void
      {
         var worldQueryWrapper:Function;
         var broadPhase:IBroadPhase;
         if(transform == null)
         {
            transform = new b2Transform();
            transform.setIdentity();
         }
         broadPhase = m_contactManager.m_broadPhase;
         worldQueryWrapper = function(proxy:*):Boolean
         {
            var _loc2_:b2Fixture = broadPhase.getUserData(proxy);
            if(b2Shape.testOverlap(shape,transform,_loc2_.getShape(),_loc2_.getBody().getTransform()))
            {
               return callbackMethod(_loc2_);
            }
            return true;
         };
         var _loc4_:b2AABB = new b2AABB();
         shape.computeAABB(_loc4_,transform);
         broadPhase.query(worldQueryWrapper,_loc4_);
      }
      
      public function QueryPoint(callbackMethod:Function, p:b2Vec2) : void
      {
         var broadPhase:IBroadPhase = m_contactManager.m_broadPhase;
         var worldQueryWrapper:Function = function(proxy:*):Boolean
         {
            var _loc2_:b2Fixture = broadPhase.getUserData(proxy);
            if(_loc2_.testPoint(p))
            {
               return callbackMethod(_loc2_);
            }
            return true;
         };
         var _loc3_:b2AABB = new b2AABB();
         _loc3_.lowerBound.set(p.x - b2Settings.b2_linearSlop,p.y - b2Settings.b2_linearSlop);
         _loc3_.upperBound.set(p.x + b2Settings.b2_linearSlop,p.y + b2Settings.b2_linearSlop);
         broadPhase.query(worldQueryWrapper,_loc3_);
      }
      
      public function QueryAABB(callbackMethod:Function, aabb:b2AABB) : void
      {
         var broadPhase:IBroadPhase = m_contactManager.m_broadPhase;
         var worldQueryWrapper:Function = function(proxy:*):Boolean
         {
            return callbackMethod(broadPhase.getUserData(proxy));
         };
         broadPhase.query(worldQueryWrapper,aabb);
      }
      
      public function IsLocked() : Boolean
      {
         return (m_flags & b2World.e_locked) > 0;
      }
      
      public function GetProxyCount() : int
      {
         return m_contactManager.m_broadPhase.getProxyCount();
      }
      
      public function GetJointList() : b2Joint
      {
         return m_jointList;
      }
      
      public function GetJointCount() : int
      {
         return m_jointCount;
      }
      
      public function GetGroundBody() : b2Body
      {
         return m_groundBody;
      }
      
      public function GetGravity() : b2Vec2
      {
         return m_gravity;
      }
      
      public function GetContactList() : b2Contact
      {
         return m_contactList;
      }
      
      public function GetContactCount() : int
      {
         return m_contactManager.m_contactCount;
      }
      
      public function GetBodyList() : b2Body
      {
         return m_bodyList;
      }
      
      public function GetBodyCount() : int
      {
         return m_bodyCount;
      }
      
      public function DrawShape(shape:b2Shape, xf:b2Transform, color:b2Color) : void
      {
         var _loc4_:* = null as b2CircleShape;
         var _loc5_:* = null as b2Vec2;
         var _loc6_:Number = NaN;
         var _loc7_:* = null as b2Vec2;
         var _loc9_:* = null as b2PolygonShape;
         var _loc10_:int = 0;
         var _loc11_:* = null as Array;
         var _loc12_:* = null as Array;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         var _loc16_:* = null as b2EdgeShape;
         switch(shape.m_type)
         {
            case 1:
               _loc4_ = b2CircleShape(shape);
               _loc5_ = b2Math.mulX(xf,_loc4_.m_p);
               _loc6_ = _loc4_.m_radius;
               _loc7_ = xf.R.col1;
               m_debugDraw.drawSolidCircle(_loc5_,_loc6_,_loc7_,color);
               break;
            case 2:
               _loc9_ = b2PolygonShape(shape);
               _loc10_ = _loc9_.getVertexCount();
               _loc11_ = _loc9_.getVertices();
               _loc12_ = [];
               _loc13_ = 0;
               _loc14_ = _loc10_;
               while(_loc13_ < _loc14_)
               {
                  _loc15_ = _loc13_++;
                  _loc12_[_loc15_] = b2Math.mulX(xf,_loc11_[_loc15_]);
               }
               m_debugDraw.drawSolidPolygon(_loc12_,_loc10_,color);
               break;
            case 3:
               _loc16_ = b2EdgeShape(shape);
               m_debugDraw.drawSegment(b2Math.mulX(xf,_loc16_.getVertex1()),b2Math.mulX(xf,_loc16_.getVertex2()),color);
         }
      }
      
      public function DrawJoint(joint:b2Joint) : void
      {
         var _loc11_:* = null as b2PulleyJoint;
         var _loc12_:* = null as b2Vec2;
         var _loc13_:* = null as b2Vec2;
         var _loc2_:b2Body = joint.getBodyA();
         var _loc3_:b2Body = joint.getBodyB();
         var _loc4_:b2Transform = _loc2_.m_xf;
         var _loc5_:b2Transform = _loc3_.m_xf;
         var _loc6_:b2Vec2 = _loc4_.position;
         var _loc7_:b2Vec2 = _loc5_.position;
         var _loc8_:b2Vec2 = joint.getAnchorA();
         var _loc9_:b2Vec2 = joint.getAnchorB();
         var _loc10_:b2Color = b2World.s_jointColor;
         switch(joint.m_type)
         {
            case 3:
               m_debugDraw.drawSegment(_loc8_,_loc9_,_loc10_);
               break;
            case 4:
               _loc11_ = b2PulleyJoint(joint);
               _loc12_ = _loc11_.getGroundAnchorA();
               _loc13_ = _loc11_.getGroundAnchorB();
               m_debugDraw.drawSegment(_loc12_,_loc8_,_loc10_);
               m_debugDraw.drawSegment(_loc13_,_loc9_,_loc10_);
               m_debugDraw.drawSegment(_loc12_,_loc13_,_loc10_);
               break;
            case 5:
               m_debugDraw.drawSegment(_loc8_,_loc9_,_loc10_);
               break;
            default:
               if(_loc2_ != m_groundBody)
               {
                  m_debugDraw.drawSegment(_loc6_,_loc8_,_loc10_);
               }
               m_debugDraw.drawSegment(_loc8_,_loc9_,_loc10_);
               if(_loc3_ != m_groundBody)
               {
                  m_debugDraw.drawSegment(_loc7_,_loc9_,_loc10_);
               }
         }
      }
      
      public function DrawDebugData() : void
      {
         var _loc3_:* = null as b2Body;
         var _loc4_:* = null as b2Fixture;
         var _loc5_:* = null as b2Shape;
         var _loc6_:* = null as b2Joint;
         var _loc7_:* = null as IBroadPhase;
         var _loc11_:* = null as b2Transform;
         var _loc16_:* = null as b2Controller;
         var _loc17_:* = null as b2Contact;
         var _loc18_:* = null as b2Fixture;
         var _loc19_:* = null as b2Fixture;
         var _loc20_:* = null as b2Vec2;
         var _loc21_:* = null as b2Vec2;
         var _loc22_:* = null as b2AABB;
         if(m_debugDraw == null)
         {
            return;
         }
         m_debugDraw.clear();
         var _loc1_:int = m_debugDraw.getFlags();
         var _loc8_:b2Vec2 = new b2Vec2();
         var _loc9_:b2Vec2 = new b2Vec2();
         var _loc10_:b2Vec2 = new b2Vec2();
         var _loc12_:b2AABB = new b2AABB();
         var _loc13_:b2AABB = new b2AABB();
         var _loc14_:Array = [new b2Vec2(),new b2Vec2(),new b2Vec2(),new b2Vec2()];
         var _loc15_:b2Color = new b2Color(0,0,0);
         if((_loc1_ & b2DebugDraw.e_shapeBit) != 0)
         {
            _loc3_ = m_bodyList;
            while(_loc3_ != null)
            {
               _loc11_ = _loc3_.m_xf;
               _loc4_ = _loc3_.getFixtureList();
               while(_loc4_ != null)
               {
                  _loc5_ = _loc4_.getShape();
                  if((_loc3_.m_flags & b2Body.e_activeFlag) == b2Body.e_activeFlag == false)
                  {
                     _loc15_.set(0.5,0.5,0.3);
                     drawShape(_loc5_,_loc11_,_loc15_);
                  }
                  else if(_loc3_.m_type == 0)
                  {
                     _loc15_.set(0.5,0.9,0.5);
                     drawShape(_loc5_,_loc11_,_loc15_);
                  }
                  else if(_loc3_.m_type == 1)
                  {
                     _loc15_.set(0.5,0.5,0.9);
                     drawShape(_loc5_,_loc11_,_loc15_);
                  }
                  else if((_loc3_.m_flags & b2Body.e_awakeFlag) == b2Body.e_awakeFlag == false)
                  {
                     _loc15_.set(0.6,0.6,0.6);
                     drawShape(_loc5_,_loc11_,_loc15_);
                  }
                  else
                  {
                     _loc15_.set(0.9,0.7,0.7);
                     drawShape(_loc5_,_loc11_,_loc15_);
                  }
                  _loc4_ = _loc4_.m_next;
               }
               _loc3_ = _loc3_.m_next;
            }
         }
         if((_loc1_ & b2DebugDraw.e_jointBit) != 0)
         {
            _loc6_ = m_jointList;
            while(_loc6_ != null)
            {
               drawJoint(_loc6_);
               _loc6_ = _loc6_.m_next;
            }
         }
         if((_loc1_ & b2DebugDraw.e_controllerBit) != 0)
         {
            _loc16_ = m_controllerList;
            while(_loc16_ != null)
            {
               _loc16_.draw(m_debugDraw);
               _loc16_ = _loc16_.m_next;
            }
         }
         if((_loc1_ & b2DebugDraw.e_pairBit) != 0)
         {
            _loc15_.set(0.3,0.9,0.9);
            _loc17_ = m_contactManager.m_contactList;
            while(_loc17_ != null)
            {
               _loc18_ = _loc17_.getFixtureA();
               _loc19_ = _loc17_.getFixtureB();
               _loc20_ = _loc18_.getAABB().getCenter();
               _loc21_ = _loc19_.getAABB().getCenter();
               m_debugDraw.drawSegment(_loc20_,_loc21_,_loc15_);
               _loc17_ = _loc17_.getNext();
            }
         }
         if((_loc1_ & b2DebugDraw.e_aabbBit) != 0)
         {
            _loc7_ = m_contactManager.m_broadPhase;
            _loc14_ = [new b2Vec2(),new b2Vec2(),new b2Vec2(),new b2Vec2()];
            _loc3_ = m_bodyList;
            while(_loc3_ != null)
            {
               if((_loc3_.m_flags & b2Body.e_activeFlag) == b2Body.e_activeFlag == false)
               {
                  _loc3_ = _loc3_.getNext();
               }
               else
               {
                  _loc4_ = _loc3_.getFixtureList();
                  while(_loc4_ != null)
                  {
                     _loc22_ = _loc7_.getFatAABB(_loc4_.m_proxy);
                     _loc14_[0].set(_loc22_.lowerBound.x,_loc22_.lowerBound.y);
                     _loc14_[1].set(_loc22_.upperBound.x,_loc22_.lowerBound.y);
                     _loc14_[2].set(_loc22_.upperBound.x,_loc22_.upperBound.y);
                     _loc14_[3].set(_loc22_.lowerBound.x,_loc22_.upperBound.y);
                     m_debugDraw.drawPolygon(_loc14_,4,_loc15_);
                     _loc4_ = _loc4_.getNext();
                  }
                  _loc3_ = _loc3_.getNext();
               }
            }
         }
         if((_loc1_ & b2DebugDraw.e_centerOfMassBit) != 0)
         {
            _loc3_ = m_bodyList;
            while(_loc3_ != null)
            {
               _loc11_ = b2World.s_xf;
               _loc11_.R = _loc3_.m_xf.R;
               _loc11_.position = _loc3_.getWorldCenter();
               m_debugDraw.drawTransform(_loc11_);
               _loc3_ = _loc3_.m_next;
            }
         }
      }
      
      public function DestroyJoint(j:b2Joint) : void
      {
         var _loc5_:* = null as b2ContactEdge;
         var _loc2_:Boolean = j.m_collideConnected;
         if(j.m_prev != null)
         {
            j.m_prev.m_next = j.m_next;
         }
         if(j.m_next != null)
         {
            j.m_next.m_prev = j.m_prev;
         }
         if(j == m_jointList)
         {
            m_jointList = j.m_next;
         }
         var _loc3_:b2Body = j.m_bodyA;
         var _loc4_:b2Body = j.m_bodyB;
         _loc3_.setAwake(true);
         _loc4_.setAwake(true);
         if(j.m_edgeA.prev != null)
         {
            j.m_edgeA.prev.next = j.m_edgeA.next;
         }
         if(j.m_edgeA.next != null)
         {
            j.m_edgeA.next.prev = j.m_edgeA.prev;
         }
         if(j.m_edgeA == _loc3_.m_jointList)
         {
            _loc3_.m_jointList = j.m_edgeA.next;
         }
         j.m_edgeA.prev = null;
         j.m_edgeA.next = null;
         if(j.m_edgeB.prev != null)
         {
            j.m_edgeB.prev.next = j.m_edgeB.next;
         }
         if(j.m_edgeB.next != null)
         {
            j.m_edgeB.next.prev = j.m_edgeB.prev;
         }
         if(j.m_edgeB == _loc4_.m_jointList)
         {
            _loc4_.m_jointList = j.m_edgeB.next;
         }
         j.m_edgeB.prev = null;
         j.m_edgeB.next = null;
         b2Joint.destroy(j,null);
         --m_jointCount;
         if(_loc2_ == false)
         {
            _loc5_ = _loc4_.getContactList();
            while(_loc5_ != null)
            {
               if(_loc5_.other == _loc3_)
               {
                  _loc5_.contact.flagForFiltering();
               }
               _loc5_ = _loc5_.next;
            }
         }
      }
      
      public function DestroyController(controller:b2Controller) : void
      {
         controller.clear();
         if(controller.m_next != null)
         {
            controller.m_next.m_prev = controller.m_prev;
         }
         if(controller.m_prev != null)
         {
            controller.m_prev.m_next = controller.m_next;
         }
         if(controller == m_controllerList)
         {
            m_controllerList = controller.m_next;
         }
         --m_controllerCount;
      }
      
      public function DestroyBody(b:b2Body) : void
      {
         var _loc3_:* = null as b2JointEdge;
         var _loc5_:* = null as b2ControllerEdge;
         var _loc7_:* = null as b2ContactEdge;
         var _loc9_:* = null as b2Fixture;
         if(isLocked() == true)
         {
            return;
         }
         var _loc2_:b2JointEdge = b.m_jointList;
         while(_loc2_ != null)
         {
            _loc3_ = _loc2_;
            _loc2_ = _loc2_.next;
            if(m_destructionListener != null)
            {
               m_destructionListener.sayGoodbyeJoint(_loc3_.joint);
            }
            destroyJoint(_loc3_.joint);
         }
         var _loc4_:b2ControllerEdge = b.m_controllerList;
         while(_loc4_ != null)
         {
            _loc5_ = _loc4_;
            _loc4_ = _loc4_.nextController;
            _loc5_.controller.removeBody(b);
         }
         var _loc6_:b2ContactEdge = b.m_contactList;
         while(_loc6_ != null)
         {
            _loc7_ = _loc6_;
            _loc6_ = _loc6_.next;
            m_contactManager.destroy(_loc7_.contact);
         }
         b.m_contactList = null;
         var _loc8_:b2Fixture = b.m_fixtureList;
         while(_loc8_ != null)
         {
            _loc9_ = _loc8_;
            _loc8_ = _loc8_.m_next;
            if(m_destructionListener != null)
            {
               m_destructionListener.sayGoodbyeFixture(_loc9_);
            }
            _loc9_.destroyProxy(m_contactManager.m_broadPhase);
            _loc9_.destroy();
         }
         b.m_fixtureList = null;
         b.m_fixtureCount = 0;
         if(b.m_prev != null)
         {
            b.m_prev.m_next = b.m_next;
         }
         if(b.m_next != null)
         {
            b.m_next.m_prev = b.m_prev;
         }
         if(b == m_bodyList)
         {
            m_bodyList = b.m_next;
         }
         --m_bodyCount;
      }
      
      public function CreateJoint(def:b2JointDef) : b2Joint
      {
         var _loc5_:* = null as b2ContactEdge;
         var _loc2_:b2Joint = b2Joint.create(def,null);
         _loc2_.m_prev = null;
         _loc2_.m_next = m_jointList;
         if(m_jointList != null)
         {
            m_jointList.m_prev = _loc2_;
         }
         m_jointList = _loc2_;
         ++m_jointCount;
         _loc2_.m_edgeA.joint = _loc2_;
         _loc2_.m_edgeA.other = _loc2_.m_bodyB;
         _loc2_.m_edgeA.prev = null;
         _loc2_.m_edgeA.next = _loc2_.m_bodyA.m_jointList;
         if(_loc2_.m_bodyA.m_jointList != null)
         {
            _loc2_.m_bodyA.m_jointList.prev = _loc2_.m_edgeA;
         }
         _loc2_.m_bodyA.m_jointList = _loc2_.m_edgeA;
         _loc2_.m_edgeB.joint = _loc2_;
         _loc2_.m_edgeB.other = _loc2_.m_bodyA;
         _loc2_.m_edgeB.prev = null;
         _loc2_.m_edgeB.next = _loc2_.m_bodyB.m_jointList;
         if(_loc2_.m_bodyB.m_jointList != null)
         {
            _loc2_.m_bodyB.m_jointList.prev = _loc2_.m_edgeB;
         }
         _loc2_.m_bodyB.m_jointList = _loc2_.m_edgeB;
         var _loc3_:b2Body = def.bodyA;
         var _loc4_:b2Body = def.bodyB;
         if(def.collideConnected == false)
         {
            _loc5_ = _loc4_.getContactList();
            while(_loc5_ != null)
            {
               if(_loc5_.other == _loc3_)
               {
                  _loc5_.contact.flagForFiltering();
               }
               _loc5_ = _loc5_.next;
            }
         }
         return _loc2_;
      }
      
      public function CreateController(controller:b2Controller) : b2Controller
      {
         if(controller.m_world != this)
         {
            throw Exception.thrown("Controller can only be a member of one world");
         }
         controller.m_next = m_controllerList;
         controller.m_prev = null;
         if(m_controllerList != null)
         {
            m_controllerList.m_prev = controller;
         }
         m_controllerList = controller;
         ++m_controllerCount;
         controller.m_world = this;
         return controller;
      }
      
      public function CreateBody(def:b2BodyDef) : b2Body
      {
         if(isLocked() == true)
         {
            return null;
         }
         var _loc2_:b2Body = new b2Body(def,this);
         _loc2_.m_prev = null;
         _loc2_.m_next = m_bodyList;
         if(m_bodyList != null)
         {
            m_bodyList.m_prev = _loc2_;
         }
         m_bodyList = _loc2_;
         ++m_bodyCount;
         return _loc2_;
      }
      
      public function ClearForces() : void
      {
         var _loc1_:b2Body = m_bodyList;
         while(_loc1_ != null)
         {
            _loc1_.m_force.setZero();
            _loc1_.m_torque = 0;
            _loc1_ = _loc1_.m_next;
         }
      }
      
      public function AddController(c:b2Controller) : b2Controller
      {
         c.m_next = m_controllerList;
         c.m_prev = null;
         m_controllerList = c;
         c.m_world = this;
         ++m_controllerCount;
         return c;
      }
   }
}

