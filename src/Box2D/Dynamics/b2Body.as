package Box2D.Dynamics
{
   import Box2D.Collision.IBroadPhase;
   import Box2D.Collision.Shapes.b2EdgeShape;
   import Box2D.Collision.Shapes.b2MassData;
   import Box2D.Collision.Shapes.b2Shape;
   import Box2D.Common.Math.b2Mat22;
   import Box2D.Common.Math.b2Math;
   import Box2D.Common.Math.b2Sweep;
   import Box2D.Common.Math.b2Transform;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Common.b2Settings;
   import Box2D.Dynamics.Contacts.b2Contact;
   import Box2D.Dynamics.Contacts.b2ContactEdge;
   import Box2D.Dynamics.Controllers.b2ControllerEdge;
   import Box2D.Dynamics.Joints.b2JointEdge;
   import flash.Boot;
   
   public class b2Body
   {
      
      public static var e_islandFlag:int = 1;
      
      public static var e_awakeFlag:int = 2;
      
      public static var e_allowSleepFlag:int = 4;
      
      public static var e_bulletFlag:int = 8;
      
      public static var e_fixedRotationFlag:int = 16;
      
      public static var e_activeFlag:int = 32;
      
      public static var b2_staticBody:int = 0;
      
      public static var b2_kinematicBody:int = 1;
      
      public static var b2_dynamicBody:int = 2;
      
      public static var s_xf1:b2Transform = new b2Transform();
      
      public var m_xf:b2Transform;
      
      public var m_world:b2World;
      
      public var m_userData:*;
      
      public var m_type:int;
      
      public var m_torque:Number;
      
      public var m_sweep:b2Sweep;
      
      public var m_sleepTime:Number;
      
      public var m_prev:b2Body;
      
      public var m_next:b2Body;
      
      public var m_mass:Number;
      
      public var m_linearVelocity:b2Vec2;
      
      public var m_linearDamping:Number;
      
      public var m_jointList:b2JointEdge;
      
      public var m_islandIndex:int;
      
      public var m_invMass:Number;
      
      public var m_invI:Number;
      
      public var m_inertiaScale:Number;
      
      public var m_gravityScale:Number;
      
      public var m_force:b2Vec2;
      
      public var m_flags:int;
      
      public var m_fixtureList:b2Fixture;
      
      public var m_fixtureCount:int;
      
      public var m_controllerList:b2ControllerEdge;
      
      public var m_controllerCount:int;
      
      public var m_contactList:b2ContactEdge;
      
      public var m_angularVelocity:Number;
      
      public var m_angularDamping:Number;
      
      public var m_I:Number;
      
      public function b2Body(bd:b2BodyDef = undefined, world:b2World = undefined)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         m_xf = new b2Transform();
         m_sweep = new b2Sweep();
         m_linearVelocity = new b2Vec2();
         m_force = new b2Vec2();
         m_flags = 0;
         if(bd.bullet)
         {
            m_flags |= b2Body.e_bulletFlag;
         }
         if(bd.fixedRotation)
         {
            m_flags |= b2Body.e_fixedRotationFlag;
         }
         if(bd.allowSleep)
         {
            m_flags |= b2Body.e_allowSleepFlag;
         }
         if(bd.awake)
         {
            m_flags |= b2Body.e_awakeFlag;
         }
         if(bd.active)
         {
            m_flags |= b2Body.e_activeFlag;
         }
         m_world = world;
         m_xf.position.setV(bd.position);
         m_xf.R.set(bd.angle);
         m_sweep.localCenter.setZero();
         m_sweep.t0 = 1;
         m_sweep.a0 = m_sweep.a = bd.angle;
         var _loc4_:b2Mat22 = m_xf.R;
         var _loc5_:b2Vec2 = m_sweep.localCenter;
         m_sweep.c.x = _loc4_.col1.x * _loc5_.x + _loc4_.col2.x * _loc5_.y;
         m_sweep.c.y = _loc4_.col1.y * _loc5_.x + _loc4_.col2.y * _loc5_.y;
         m_sweep.c.x += m_xf.position.x;
         m_sweep.c.y += m_xf.position.y;
         m_sweep.c0.setV(m_sweep.c);
         m_jointList = null;
         m_controllerList = null;
         m_contactList = null;
         m_controllerCount = 0;
         m_prev = null;
         m_next = null;
         m_linearVelocity.setV(bd.linearVelocity);
         m_angularVelocity = bd.angularVelocity;
         m_linearDamping = bd.linearDamping;
         m_angularDamping = bd.angularDamping;
         m_gravityScale = bd.gravityScale;
         m_force.set(0,0);
         m_torque = 0;
         m_sleepTime = 0;
         m_type = bd.type;
         if(m_type == 2)
         {
            m_mass = 1;
            m_invMass = 1;
         }
         else
         {
            m_mass = 0;
            m_invMass = 0;
         }
         m_I = 0;
         m_invI = 0;
         m_inertiaScale = bd.inertiaScale;
         m_userData = bd.userData;
         m_fixtureList = null;
         m_fixtureCount = 0;
      }
      
      public function synchronizeTransform() : void
      {
         SynchronizeTransform();
      }
      
      public function synchronizeFixtures() : void
      {
         SynchronizeFixtures();
      }
      
      public function split(callbackMethod:Function) : b2Body
      {
         return Split(callbackMethod);
      }
      
      public function shouldCollide(other:b2Body) : Boolean
      {
         return ShouldCollide(other);
      }
      
      public function setUserData(data:*) : void
      {
         SetUserData(data);
      }
      
      public function setType(type:int) : void
      {
         SetType(type);
      }
      
      public function setTransform(xf:b2Transform) : void
      {
         SetTransform(xf);
      }
      
      public function setSleepingAllowed(flag:Boolean) : void
      {
         SetSleepingAllowed(flag);
      }
      
      public function setPositionAndAngle(position:b2Vec2, angle:Number) : void
      {
         SetPositionAndAngle(position,angle);
      }
      
      public function setPosition(position:b2Vec2) : void
      {
         SetPosition(position);
      }
      
      public function setMassData(massData:b2MassData) : void
      {
         SetMassData(massData);
      }
      
      public function setLinearVelocity(v:b2Vec2) : void
      {
         SetLinearVelocity(v);
      }
      
      public function setLinearDamping(linearDamping:Number) : void
      {
         SetLinearDamping(linearDamping);
      }
      
      public function setGravityScale(scale:Number) : void
      {
         SetGravityScale(scale);
      }
      
      public function setFixedRotation(fixed:Boolean) : void
      {
         SetFixedRotation(fixed);
      }
      
      public function setBullet(flag:Boolean) : void
      {
         SetBullet(flag);
      }
      
      public function setAwake(flag:Boolean) : void
      {
         SetAwake(flag);
      }
      
      public function setAngularVelocity(omega:Number) : void
      {
         SetAngularVelocity(omega);
      }
      
      public function setAngularDamping(angularDamping:Number) : void
      {
         SetAngularDamping(angularDamping);
      }
      
      public function setAngle(angle:Number) : void
      {
         SetAngle(angle);
      }
      
      public function setActive(flag:Boolean) : void
      {
         SetActive(flag);
      }
      
      public function resetMassData() : void
      {
         ResetMassData();
      }
      
      public function merge(other:b2Body) : void
      {
         Merge(other);
      }
      
      public function isSleepingAllowed() : Boolean
      {
         return IsSleepingAllowed();
      }
      
      public function isFixedRotation() : Boolean
      {
         return IsFixedRotation();
      }
      
      public function isBullet() : Boolean
      {
         return (m_flags & b2Body.e_bulletFlag) == b2Body.e_bulletFlag;
      }
      
      public function isAwake() : Boolean
      {
         return (m_flags & b2Body.e_awakeFlag) == b2Body.e_awakeFlag;
      }
      
      public function isActive() : Boolean
      {
         return (m_flags & b2Body.e_activeFlag) == b2Body.e_activeFlag;
      }
      
      public function getWorldVector(localVector:b2Vec2) : b2Vec2
      {
         return GetWorldVector(localVector);
      }
      
      public function getWorldPoint(localPoint:b2Vec2) : b2Vec2
      {
         return GetWorldPoint(localPoint);
      }
      
      public function getWorldCenter() : b2Vec2
      {
         return GetWorldCenter();
      }
      
      public function getWorld() : b2World
      {
         return GetWorld();
      }
      
      public function getUserData() : *
      {
         return GetUserData();
      }
      
      public function getType() : int
      {
         return m_type;
      }
      
      public function getTransform() : b2Transform
      {
         return GetTransform();
      }
      
      public function getPosition() : b2Vec2
      {
         return GetPosition();
      }
      
      public function getNext() : b2Body
      {
         return GetNext();
      }
      
      public function getMassData(data:b2MassData) : void
      {
         GetMassData(data);
      }
      
      public function getMass() : Number
      {
         return GetMass();
      }
      
      public function getLocalVector(worldVector:b2Vec2) : b2Vec2
      {
         return GetLocalVector(worldVector);
      }
      
      public function getLocalPoint(worldPoint:b2Vec2) : b2Vec2
      {
         return GetLocalPoint(worldPoint);
      }
      
      public function getLocalCenter() : b2Vec2
      {
         return GetLocalCenter();
      }
      
      public function getLinearVelocityFromWorldPoint(worldPoint:b2Vec2) : b2Vec2
      {
         return GetLinearVelocityFromWorldPoint(worldPoint);
      }
      
      public function getLinearVelocityFromLocalPoint(localPoint:b2Vec2) : b2Vec2
      {
         return GetLinearVelocityFromLocalPoint(localPoint);
      }
      
      public function getLinearVelocity() : b2Vec2
      {
         return GetLinearVelocity();
      }
      
      public function getLinearDamping() : Number
      {
         return GetLinearDamping();
      }
      
      public function getJointList() : b2JointEdge
      {
         return GetJointList();
      }
      
      public function getInertia() : Number
      {
         return GetInertia();
      }
      
      public function getGravityScale() : Number
      {
         return GetGravityScale();
      }
      
      public function getFixtureList() : b2Fixture
      {
         return GetFixtureList();
      }
      
      public function getDefinition() : b2BodyDef
      {
         return GetDefinition();
      }
      
      public function getControllerList() : b2ControllerEdge
      {
         return GetControllerList();
      }
      
      public function getContactList() : b2ContactEdge
      {
         return GetContactList();
      }
      
      public function getAngularVelocity() : Number
      {
         return GetAngularVelocity();
      }
      
      public function getAngularDamping() : Number
      {
         return GetAngularDamping();
      }
      
      public function getAngle() : Number
      {
         return GetAngle();
      }
      
      public function createFixture2(shape:b2Shape, density:Number = 0) : b2Fixture
      {
         return CreateFixture2(shape,density);
      }
      
      public function createFixture(def:b2FixtureDef) : b2Fixture
      {
         return CreateFixture(def);
      }
      
      public function connectEdges(s1:b2EdgeShape, s2:b2EdgeShape, angle1:Number) : Number
      {
         var _loc4_:Number = Math.atan2(s2.getDirectionVector().y,s2.getDirectionVector().x);
         var _loc5_:Number = Math.tan((_loc4_ - angle1) * 0.5);
         var _loc6_:b2Vec2 = b2Math.mulFV(_loc5_,s2.getDirectionVector());
         _loc6_ = b2Math.subtractVV(_loc6_,s2.getNormalVector());
         _loc6_ = b2Math.mulFV(b2Settings.b2_toiSlop,_loc6_);
         _loc6_ = b2Math.addVV(_loc6_,s2.getVertex1());
         var _loc7_:b2Vec2 = b2Math.addVV(s1.getDirectionVector(),s2.getDirectionVector());
         _loc7_.normalize();
         var _loc8_:Boolean = b2Math.dot(s1.getDirectionVector(),s2.getNormalVector()) > 0;
         s1.setNextEdge(s2,_loc6_,_loc7_,_loc8_);
         s2.setPrevEdge(s1,_loc6_,_loc7_,_loc8_);
         return _loc4_;
      }
      
      public function applyTorque(torque:Number) : void
      {
         ApplyTorque(torque);
      }
      
      public function applyImpulse(impulse:b2Vec2, point:b2Vec2) : void
      {
         ApplyImpulse(impulse,point);
      }
      
      public function applyForce(force:b2Vec2, point:b2Vec2) : void
      {
         ApplyForce(force,point);
      }
      
      public function advance(t:Number) : void
      {
         Advance(t);
      }
      
      public function SynchronizeTransform() : void
      {
         m_xf.R.set(m_sweep.a);
         var _loc1_:b2Mat22 = m_xf.R;
         var _loc2_:b2Vec2 = m_sweep.localCenter;
         m_xf.position.x = m_sweep.c.x - (_loc1_.col1.x * _loc2_.x + _loc1_.col2.x * _loc2_.y);
         m_xf.position.y = m_sweep.c.y - (_loc1_.col1.y * _loc2_.x + _loc1_.col2.y * _loc2_.y);
      }
      
      public function SynchronizeFixtures() : void
      {
         var _loc1_:b2Transform = b2Body.s_xf1;
         _loc1_.R.set(m_sweep.a0);
         var _loc2_:b2Mat22 = _loc1_.R;
         var _loc3_:b2Vec2 = m_sweep.localCenter;
         _loc1_.position.x = m_sweep.c0.x - (_loc2_.col1.x * _loc3_.x + _loc2_.col2.x * _loc3_.y);
         _loc1_.position.y = m_sweep.c0.y - (_loc2_.col1.y * _loc3_.x + _loc2_.col2.y * _loc3_.y);
         var _loc4_:IBroadPhase = m_world.m_contactManager.m_broadPhase;
         var _loc5_:b2Fixture = m_fixtureList;
         while(_loc5_ != null)
         {
            _loc5_.synchronize(_loc4_,_loc1_,m_xf);
            _loc5_ = _loc5_.m_next;
         }
      }
      
      public function Split(callbackMethod:Function) : b2Body
      {
         var _loc9_:* = null as b2Fixture;
         var _loc2_:b2Vec2 = getLinearVelocity().copy();
         var _loc3_:Number = getAngularVelocity();
         var _loc4_:b2Vec2 = getWorldCenter();
         var _loc5_:b2Body = this;
         var _loc6_:b2Body = m_world.createBody(getDefinition());
         var _loc7_:b2Fixture = null;
         var _loc8_:b2Fixture = _loc5_.m_fixtureList;
         while(_loc8_ != null)
         {
            if(callbackMethod(_loc8_))
            {
               _loc9_ = _loc8_.m_next;
               if(_loc7_ != null)
               {
                  _loc7_.m_next = _loc9_;
               }
               else
               {
                  _loc5_.m_fixtureList = _loc9_;
               }
               --_loc5_.m_fixtureCount;
               _loc8_.m_next = _loc6_.m_fixtureList;
               _loc6_.m_fixtureList = _loc8_;
               ++_loc6_.m_fixtureCount;
               _loc8_.m_body = _loc6_;
               _loc8_ = _loc9_;
            }
            else
            {
               _loc7_ = _loc8_;
               _loc8_ = _loc8_.m_next;
            }
         }
         _loc5_.resetMassData();
         _loc6_.resetMassData();
         var _loc10_:b2Vec2 = _loc5_.getWorldCenter();
         var _loc11_:b2Vec2 = _loc6_.getWorldCenter();
         var _loc12_:b2Vec2 = b2Math.addVV(_loc2_,b2Math.crossFV(_loc3_,b2Math.subtractVV(_loc10_,_loc4_)));
         var _loc13_:b2Vec2 = b2Math.addVV(_loc2_,b2Math.crossFV(_loc3_,b2Math.subtractVV(_loc11_,_loc4_)));
         _loc5_.setLinearVelocity(_loc12_);
         _loc6_.setLinearVelocity(_loc13_);
         _loc5_.setAngularVelocity(_loc3_);
         _loc6_.setAngularVelocity(_loc3_);
         _loc5_.synchronizeFixtures();
         _loc6_.synchronizeFixtures();
         return _loc6_;
      }
      
      public function ShouldCollide(other:b2Body) : Boolean
      {
         if(m_type != 2 && other.m_type != 2)
         {
            return false;
         }
         var _loc2_:b2JointEdge = m_jointList;
         while(_loc2_ != null)
         {
            if(_loc2_.other == other)
            {
               if(_loc2_.joint.m_collideConnected == false)
               {
                  return false;
               }
            }
            _loc2_ = _loc2_.next;
         }
         return true;
      }
      
      public function SetUserData(data:*) : void
      {
         m_userData = data;
      }
      
      public function SetType(type:int) : void
      {
         if(m_type == type)
         {
            return;
         }
         m_type = type;
         resetMassData();
         if(m_type == 0)
         {
            m_linearVelocity.setZero();
            m_angularVelocity = 0;
         }
         setAwake(true);
         m_force.setZero();
         m_torque = 0;
         var _loc2_:b2ContactEdge = m_contactList;
         while(_loc2_ != null)
         {
            _loc2_.contact.flagForFiltering();
            _loc2_ = _loc2_.next;
         }
      }
      
      public function SetTransform(xf:b2Transform) : void
      {
         setPositionAndAngle(xf.position,xf.getAngle());
      }
      
      public function SetSleepingAllowed(flag:Boolean) : void
      {
         if(flag)
         {
            m_flags |= b2Body.e_allowSleepFlag;
         }
         else
         {
            m_flags &= ~b2Body.e_allowSleepFlag;
            setAwake(true);
         }
      }
      
      public function SetPositionAndAngle(position:b2Vec2, angle:Number) : void
      {
         if(m_world.isLocked() == true)
         {
            return;
         }
         m_xf.R.set(angle);
         m_xf.position.setV(position);
         var _loc3_:b2Mat22 = m_xf.R;
         var _loc4_:b2Vec2 = m_sweep.localCenter;
         m_sweep.c.x = _loc3_.col1.x * _loc4_.x + _loc3_.col2.x * _loc4_.y;
         m_sweep.c.y = _loc3_.col1.y * _loc4_.x + _loc3_.col2.y * _loc4_.y;
         m_sweep.c.x += m_xf.position.x;
         m_sweep.c.y += m_xf.position.y;
         m_sweep.c0.setV(m_sweep.c);
         m_sweep.a0 = m_sweep.a = angle;
         var _loc6_:IBroadPhase = m_world.m_contactManager.m_broadPhase;
         var _loc7_:b2Fixture = m_fixtureList;
         while(_loc7_ != null)
         {
            _loc7_.synchronize(_loc6_,m_xf,m_xf);
            _loc7_ = _loc7_.m_next;
         }
         m_world.m_contactManager.findNewContacts();
      }
      
      public function SetPosition(position:b2Vec2) : void
      {
         setPositionAndAngle(position,getAngle());
      }
      
      public function SetMassData(massData:b2MassData) : void
      {
         b2Settings.b2Assert(m_world.isLocked() == false);
         if(m_world.isLocked() == true)
         {
            return;
         }
         if(m_type != 2)
         {
            return;
         }
         m_invMass = 0;
         m_I = 0;
         m_invI = 0;
         m_mass = massData.mass;
         if(m_mass <= 0)
         {
            m_mass = 1;
         }
         m_invMass = 1 / m_mass;
         if(massData.I > 0 && (m_flags & b2Body.e_fixedRotationFlag) == 0)
         {
            m_I = massData.I - m_mass * (massData.center.x * massData.center.x + massData.center.y * massData.center.y);
            m_invI = 1 / m_I;
         }
         var _loc2_:b2Vec2 = m_sweep.c.copy();
         m_sweep.localCenter.setV(massData.center);
         m_sweep.c0.setV(b2Math.mulX(m_xf,m_sweep.localCenter));
         m_sweep.c.setV(m_sweep.c0);
         m_linearVelocity.x += m_angularVelocity * -(m_sweep.c.y - _loc2_.y);
         m_linearVelocity.y += m_angularVelocity * (m_sweep.c.x - _loc2_.x);
      }
      
      public function SetLinearVelocity(v:b2Vec2) : void
      {
         if(m_type == 0)
         {
            return;
         }
         m_linearVelocity.setV(v);
      }
      
      public function SetLinearDamping(linearDamping:Number) : void
      {
         m_linearDamping = linearDamping;
      }
      
      public function SetGravityScale(scale:Number) : void
      {
         m_gravityScale = scale;
      }
      
      public function SetFixedRotation(fixed:Boolean) : void
      {
         if(fixed)
         {
            m_flags |= b2Body.e_fixedRotationFlag;
         }
         else
         {
            m_flags &= ~b2Body.e_fixedRotationFlag;
         }
         resetMassData();
      }
      
      public function SetBullet(flag:Boolean) : void
      {
         if(flag)
         {
            m_flags |= b2Body.e_bulletFlag;
         }
         else
         {
            m_flags &= ~b2Body.e_bulletFlag;
         }
      }
      
      public function SetAwake(flag:Boolean) : void
      {
         if(flag)
         {
            m_flags |= b2Body.e_awakeFlag;
            m_sleepTime = 0;
         }
         else
         {
            m_flags &= ~b2Body.e_awakeFlag;
            m_sleepTime = 0;
            m_linearVelocity.setZero();
            m_angularVelocity = 0;
            m_force.setZero();
            m_torque = 0;
         }
      }
      
      public function SetAngularVelocity(omega:Number) : void
      {
         if(m_type == 0)
         {
            return;
         }
         m_angularVelocity = omega;
      }
      
      public function SetAngularDamping(angularDamping:Number) : void
      {
         m_angularDamping = angularDamping;
      }
      
      public function SetAngle(angle:Number) : void
      {
         setPositionAndAngle(getPosition(),angle);
      }
      
      public function SetActive(flag:Boolean) : void
      {
         var _loc2_:* = null as IBroadPhase;
         var _loc3_:* = null as b2Fixture;
         var _loc4_:* = null as b2ContactEdge;
         var _loc5_:* = null as b2ContactEdge;
         if(flag == ((m_flags & b2Body.e_activeFlag) == b2Body.e_activeFlag))
         {
            return;
         }
         if(flag)
         {
            m_flags |= b2Body.e_activeFlag;
            _loc2_ = m_world.m_contactManager.m_broadPhase;
            _loc3_ = m_fixtureList;
            while(_loc3_ != null)
            {
               _loc3_.createProxy(_loc2_,m_xf);
               _loc3_ = _loc3_.m_next;
            }
         }
         else
         {
            m_flags &= ~b2Body.e_activeFlag;
            _loc2_ = m_world.m_contactManager.m_broadPhase;
            _loc3_ = m_fixtureList;
            while(_loc3_ != null)
            {
               _loc3_.destroyProxy(_loc2_);
               _loc3_ = _loc3_.m_next;
            }
            _loc4_ = m_contactList;
            while(_loc4_ != null)
            {
               _loc5_ = _loc4_;
               _loc4_ = _loc4_.next;
               m_world.m_contactManager.destroy(_loc5_.contact);
            }
            m_contactList = null;
         }
      }
      
      public function ResetMassData() : void
      {
         var _loc3_:* = null as b2MassData;
         m_mass = 0;
         m_invMass = 0;
         m_I = 0;
         m_invI = 0;
         m_sweep.localCenter.setZero();
         if(m_type == 0 || m_type == 1)
         {
            return;
         }
         var _loc1_:b2Vec2 = b2Vec2.make(0,0);
         var _loc2_:b2Fixture = m_fixtureList;
         while(_loc2_ != null)
         {
            if(_loc2_.m_density == 0)
            {
               _loc2_ = _loc2_.m_next;
            }
            else
            {
               _loc3_ = _loc2_.getMassData();
               m_mass += _loc3_.mass;
               _loc1_.x += _loc3_.center.x * _loc3_.mass;
               _loc1_.y += _loc3_.center.y * _loc3_.mass;
               m_I += _loc3_.I;
               _loc2_ = _loc2_.m_next;
            }
         }
         if(m_mass > 0)
         {
            m_invMass = 1 / m_mass;
            _loc1_.x *= m_invMass;
            _loc1_.y *= m_invMass;
         }
         else
         {
            m_mass = 1;
            m_invMass = 1;
         }
         if(m_I > 0 && (m_flags & b2Body.e_fixedRotationFlag) == 0)
         {
            m_I -= m_mass * (_loc1_.x * _loc1_.x + _loc1_.y * _loc1_.y);
            m_I *= m_inertiaScale;
            b2Settings.b2Assert(m_I > 0);
            m_invI = 1 / m_I;
         }
         else
         {
            m_I = 0;
            m_invI = 0;
         }
         var _loc4_:b2Vec2 = m_sweep.c.copy();
         m_sweep.localCenter.setV(_loc1_);
         m_sweep.c0.setV(b2Math.mulX(m_xf,m_sweep.localCenter));
         m_sweep.c.setV(m_sweep.c0);
         m_linearVelocity.x += m_angularVelocity * -(m_sweep.c.y - _loc4_.y);
         m_linearVelocity.y += m_angularVelocity * (m_sweep.c.x - _loc4_.x);
      }
      
      public function Merge(other:b2Body) : void
      {
         var _loc5_:* = null as b2Fixture;
         var _loc2_:b2Fixture = other.m_fixtureList;
         var _loc3_:b2Body = this;
         var _loc4_:b2Body = other;
         while(_loc2_ != null)
         {
            _loc5_ = _loc2_.m_next;
            --other.m_fixtureCount;
            _loc2_.m_next = m_fixtureList;
            m_fixtureList = _loc2_;
            ++m_fixtureCount;
            _loc2_.m_body = _loc4_;
            _loc2_ = _loc5_;
         }
         _loc3_.m_fixtureCount = 0;
         var _loc6_:b2Vec2 = _loc3_.getWorldCenter();
         var _loc7_:b2Vec2 = _loc4_.getWorldCenter();
         var _loc8_:b2Vec2 = _loc3_.getLinearVelocity().copy();
         var _loc9_:b2Vec2 = _loc4_.getLinearVelocity().copy();
         var _loc10_:Number = _loc3_.getAngularVelocity();
         var _loc11_:Number = _loc4_.getAngularVelocity();
         _loc3_.resetMassData();
         synchronizeFixtures();
      }
      
      public function IsSleepingAllowed() : Boolean
      {
         return (m_flags & b2Body.e_allowSleepFlag) == b2Body.e_allowSleepFlag;
      }
      
      public function IsFixedRotation() : Boolean
      {
         return (m_flags & b2Body.e_fixedRotationFlag) == b2Body.e_fixedRotationFlag;
      }
      
      public function IsBullet() : Boolean
      {
         return (m_flags & b2Body.e_bulletFlag) == b2Body.e_bulletFlag;
      }
      
      public function IsAwake() : Boolean
      {
         return (m_flags & b2Body.e_awakeFlag) == b2Body.e_awakeFlag;
      }
      
      public function IsActive() : Boolean
      {
         return (m_flags & b2Body.e_activeFlag) == b2Body.e_activeFlag;
      }
      
      public function GetWorldVector(localVector:b2Vec2) : b2Vec2
      {
         return b2Math.mulMV(m_xf.R,localVector);
      }
      
      public function GetWorldPoint(localPoint:b2Vec2) : b2Vec2
      {
         var _loc2_:b2Mat22 = m_xf.R;
         var _loc3_:b2Vec2 = new b2Vec2(_loc2_.col1.x * localPoint.x + _loc2_.col2.x * localPoint.y,_loc2_.col1.y * localPoint.x + _loc2_.col2.y * localPoint.y);
         _loc3_.x += m_xf.position.x;
         _loc3_.y += m_xf.position.y;
         return _loc3_;
      }
      
      public function GetWorldCenter() : b2Vec2
      {
         return m_sweep.c;
      }
      
      public function GetWorld() : b2World
      {
         return m_world;
      }
      
      public function GetUserData() : *
      {
         return m_userData;
      }
      
      public function GetType() : int
      {
         return m_type;
      }
      
      public function GetTransform() : b2Transform
      {
         return m_xf;
      }
      
      public function GetPosition() : b2Vec2
      {
         return m_xf.position;
      }
      
      public function GetNext() : b2Body
      {
         return m_next;
      }
      
      public function GetMassData(data:b2MassData) : void
      {
         data.mass = m_mass;
         data.I = m_I;
         data.center.setV(m_sweep.localCenter);
      }
      
      public function GetMass() : Number
      {
         return m_mass;
      }
      
      public function GetLocalVector(worldVector:b2Vec2) : b2Vec2
      {
         return b2Math.mulTMV(m_xf.R,worldVector);
      }
      
      public function GetLocalPoint(worldPoint:b2Vec2) : b2Vec2
      {
         return b2Math.mulXT(m_xf,worldPoint);
      }
      
      public function GetLocalCenter() : b2Vec2
      {
         return m_sweep.localCenter;
      }
      
      public function GetLinearVelocityFromWorldPoint(worldPoint:b2Vec2) : b2Vec2
      {
         return new b2Vec2(m_linearVelocity.x - m_angularVelocity * (worldPoint.y - m_sweep.c.y),m_linearVelocity.y + m_angularVelocity * (worldPoint.x - m_sweep.c.x));
      }
      
      public function GetLinearVelocityFromLocalPoint(localPoint:b2Vec2) : b2Vec2
      {
         var _loc2_:b2Mat22 = m_xf.R;
         var _loc3_:b2Vec2 = new b2Vec2(_loc2_.col1.x * localPoint.x + _loc2_.col2.x * localPoint.y,_loc2_.col1.y * localPoint.x + _loc2_.col2.y * localPoint.y);
         _loc3_.x += m_xf.position.x;
         _loc3_.y += m_xf.position.y;
         return new b2Vec2(m_linearVelocity.x - m_angularVelocity * (_loc3_.y - m_sweep.c.y),m_linearVelocity.y + m_angularVelocity * (_loc3_.x - m_sweep.c.x));
      }
      
      public function GetLinearVelocity() : b2Vec2
      {
         return m_linearVelocity;
      }
      
      public function GetLinearDamping() : Number
      {
         return m_linearDamping;
      }
      
      public function GetJointList() : b2JointEdge
      {
         return m_jointList;
      }
      
      public function GetInertia() : Number
      {
         return m_I;
      }
      
      public function GetGravityScale() : Number
      {
         return m_gravityScale;
      }
      
      public function GetFixtureList() : b2Fixture
      {
         return m_fixtureList;
      }
      
      public function GetDefinition() : b2BodyDef
      {
         var _loc1_:b2BodyDef = new b2BodyDef();
         _loc1_.type = m_type;
         _loc1_.allowSleep = (m_flags & b2Body.e_allowSleepFlag) == b2Body.e_allowSleepFlag;
         _loc1_.angle = getAngle();
         _loc1_.angularDamping = m_angularDamping;
         _loc1_.gravityScale = getGravityScale();
         _loc1_.angularVelocity = m_angularVelocity;
         _loc1_.fixedRotation = (m_flags & b2Body.e_fixedRotationFlag) == b2Body.e_fixedRotationFlag;
         _loc1_.bullet = (m_flags & b2Body.e_bulletFlag) == b2Body.e_bulletFlag;
         _loc1_.awake = (m_flags & b2Body.e_awakeFlag) == b2Body.e_awakeFlag;
         _loc1_.linearDamping = m_linearDamping;
         _loc1_.linearVelocity.setV(getLinearVelocity());
         _loc1_.position = getPosition();
         _loc1_.userData = getUserData();
         return _loc1_;
      }
      
      public function GetControllerList() : b2ControllerEdge
      {
         return m_controllerList;
      }
      
      public function GetContactList() : b2ContactEdge
      {
         return m_contactList;
      }
      
      public function GetAngularVelocity() : Number
      {
         return m_angularVelocity;
      }
      
      public function GetAngularDamping() : Number
      {
         return m_angularDamping;
      }
      
      public function GetAngle() : Number
      {
         return m_sweep.a;
      }
      
      public function DestroyFixture(fixture:b2Fixture) : void
      {
         var _loc6_:* = null as b2Contact;
         var _loc7_:* = null as b2Fixture;
         var _loc8_:* = null as b2Fixture;
         var _loc9_:* = null as IBroadPhase;
         if(m_world.isLocked() == true)
         {
            return;
         }
         var _loc2_:b2Fixture = m_fixtureList;
         var _loc3_:b2Fixture = null;
         var _loc4_:Boolean = false;
         while(_loc2_ != null)
         {
            if(_loc2_ == fixture)
            {
               if(_loc3_ != null)
               {
                  _loc3_.m_next = fixture.m_next;
               }
               else
               {
                  m_fixtureList = fixture.m_next;
               }
               _loc4_ = true;
               break;
            }
            _loc3_ = _loc2_;
            _loc2_ = _loc2_.m_next;
         }
         var _loc5_:b2ContactEdge = m_contactList;
         while(_loc5_ != null)
         {
            _loc6_ = _loc5_.contact;
            _loc5_ = _loc5_.next;
            _loc7_ = _loc6_.getFixtureA();
            _loc8_ = _loc6_.getFixtureB();
            if(fixture == _loc7_ || fixture == _loc8_)
            {
               m_world.m_contactManager.destroy(_loc6_);
            }
         }
         if((m_flags & b2Body.e_activeFlag) != 0)
         {
            _loc9_ = m_world.m_contactManager.m_broadPhase;
            fixture.destroyProxy(_loc9_);
         }
         fixture.destroy();
         fixture.m_body = null;
         fixture.m_next = null;
         --m_fixtureCount;
         resetMassData();
      }
      
      public function CreateFixture2(shape:b2Shape, density:Number = 0) : b2Fixture
      {
         var _loc3_:b2FixtureDef = new b2FixtureDef();
         _loc3_.shape = shape;
         _loc3_.density = density;
         return createFixture(_loc3_);
      }
      
      public function CreateFixture(def:b2FixtureDef) : b2Fixture
      {
         var _loc3_:* = null as IBroadPhase;
         if(m_world.isLocked() == true)
         {
            return null;
         }
         var _loc2_:b2Fixture = new b2Fixture();
         _loc2_.create(this,m_xf,def);
         if((m_flags & b2Body.e_activeFlag) != 0)
         {
            _loc3_ = m_world.m_contactManager.m_broadPhase;
            _loc2_.createProxy(_loc3_,m_xf);
         }
         _loc2_.m_next = m_fixtureList;
         m_fixtureList = _loc2_;
         ++m_fixtureCount;
         _loc2_.m_body = this;
         if(_loc2_.m_density > 0)
         {
            resetMassData();
         }
         m_world.m_flags |= b2World.e_newFixture;
         return _loc2_;
      }
      
      public function ApplyTorque(torque:Number) : void
      {
         if(m_type != 2)
         {
            return;
         }
         if((m_flags & b2Body.e_awakeFlag) == b2Body.e_awakeFlag == false)
         {
            setAwake(true);
         }
         m_torque += torque;
      }
      
      public function ApplyImpulse(impulse:b2Vec2, point:b2Vec2) : void
      {
         if(m_type != 2)
         {
            return;
         }
         if((m_flags & b2Body.e_awakeFlag) == b2Body.e_awakeFlag == false)
         {
            setAwake(true);
         }
         m_linearVelocity.x += m_invMass * impulse.x;
         m_linearVelocity.y += m_invMass * impulse.y;
         m_angularVelocity += m_invI * ((point.x - m_sweep.c.x) * impulse.y - (point.y - m_sweep.c.y) * impulse.x);
      }
      
      public function ApplyForce(force:b2Vec2, point:b2Vec2) : void
      {
         if(m_type != 2)
         {
            return;
         }
         if((m_flags & b2Body.e_awakeFlag) == b2Body.e_awakeFlag == false)
         {
            setAwake(true);
         }
         m_force.x += force.x;
         m_force.y += force.y;
         m_torque += (point.x - m_sweep.c.x) * force.y - (point.y - m_sweep.c.y) * force.x;
      }
      
      public function Advance(t:Number) : void
      {
         m_sweep.advance(t);
         m_sweep.c.setV(m_sweep.c0);
         m_sweep.a = m_sweep.a0;
         synchronizeTransform();
      }
   }
}

