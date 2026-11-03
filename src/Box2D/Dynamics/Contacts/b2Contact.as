package Box2D.Dynamics.Contacts
{
   import Box2D.Collision.Shapes.b2Shape;
   import Box2D.Collision.b2ContactID;
   import Box2D.Collision.b2Manifold;
   import Box2D.Collision.b2ManifoldPoint;
   import Box2D.Collision.b2TOIInput;
   import Box2D.Collision.b2TimeOfImpact;
   import Box2D.Collision.b2WorldManifold;
   import Box2D.Common.Math.b2Sweep;
   import Box2D.Common.Math.b2Transform;
   import Box2D.Common.b2Settings;
   import Box2D.Dynamics.b2Body;
   import Box2D.Dynamics.b2ContactListener;
   import Box2D.Dynamics.b2Fixture;
   import flash.Boot;
   
   public class b2Contact
   {
      
      public static var e_sensorFlag:int = 1;
      
      public static var e_continuousFlag:int = 2;
      
      public static var e_islandFlag:int = 4;
      
      public static var e_toiFlag:int = 8;
      
      public static var e_touchingFlag:int = 16;
      
      public static var e_enabledFlag:int = 32;
      
      public static var e_filterFlag:int = 64;
      
      public static var s_input:b2TOIInput = new b2TOIInput();
      
      public var m_toi:Number;
      
      public var m_prev:b2Contact;
      
      public var m_oldManifold:b2Manifold;
      
      public var m_nodeB:b2ContactEdge;
      
      public var m_nodeA:b2ContactEdge;
      
      public var m_next:b2Contact;
      
      public var m_manifold:b2Manifold;
      
      public var m_flags:int;
      
      public var m_fixtureB:b2Fixture;
      
      public var m_fixtureA:b2Fixture;
      
      public function b2Contact()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         m_toi = 0;
         m_flags = 0;
         m_nodeA = new b2ContactEdge();
         m_nodeB = new b2ContactEdge();
         m_manifold = new b2Manifold();
         m_oldManifold = new b2Manifold();
      }
      
      public function update(listener:b2ContactListener) : void
      {
         Update(listener);
      }
      
      public function setSensor(sensor:Boolean) : void
      {
         SetSensor(sensor);
      }
      
      public function setEnabled(flag:Boolean) : void
      {
         SetEnabled(flag);
      }
      
      public function reset(fixtureA:b2Fixture = undefined, fixtureB:b2Fixture = undefined) : void
      {
         Reset(fixtureA,fixtureB);
      }
      
      public function isTouching() : Boolean
      {
         return IsTouching();
      }
      
      public function isSensor() : Boolean
      {
         return IsSensor();
      }
      
      public function isEnabled() : Boolean
      {
         return IsEnabled();
      }
      
      public function isContinuous() : Boolean
      {
         return IsContinuous();
      }
      
      public function getWorldManifold(worldManifold:b2WorldManifold) : void
      {
         GetWorldManifold(worldManifold);
      }
      
      public function getNext() : b2Contact
      {
         return GetNext();
      }
      
      public function getManifold() : b2Manifold
      {
         return GetManifold();
      }
      
      public function getFixtureB() : b2Fixture
      {
         return GetFixtureB();
      }
      
      public function getFixtureA() : b2Fixture
      {
         return GetFixtureA();
      }
      
      public function flagForFiltering() : void
      {
         FlagForFiltering();
      }
      
      public function evaluate() : void
      {
         Evaluate();
      }
      
      public function computeTOI(sweepA:b2Sweep, sweepB:b2Sweep) : Number
      {
         return ComputeTOI(sweepA,sweepB);
      }
      
      public function Update(listener:b2ContactListener) : void
      {
         var _loc8_:* = null as b2Shape;
         var _loc9_:* = null as b2Shape;
         var _loc10_:* = null as b2Transform;
         var _loc11_:* = null as b2Transform;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:* = null as b2ManifoldPoint;
         var _loc16_:* = null as b2ContactID;
         var _loc17_:int = 0;
         var _loc18_:int = 0;
         var _loc19_:int = 0;
         var _loc20_:* = null as b2ManifoldPoint;
         var _loc2_:b2Manifold = m_oldManifold;
         m_oldManifold = m_manifold;
         m_manifold = _loc2_;
         m_flags |= b2Contact.e_enabledFlag;
         var _loc3_:Boolean = false;
         var _loc4_:Boolean = (m_flags & b2Contact.e_touchingFlag) == b2Contact.e_touchingFlag;
         var _loc5_:b2Body = m_fixtureA.m_body;
         var _loc6_:b2Body = m_fixtureB.m_body;
         var _loc7_:Boolean = m_fixtureA.m_aabb.testOverlap(m_fixtureB.m_aabb);
         if((m_flags & b2Contact.e_sensorFlag) != 0)
         {
            if(_loc7_)
            {
               _loc8_ = m_fixtureA.getShape();
               _loc9_ = m_fixtureB.getShape();
               _loc10_ = _loc5_.getTransform();
               _loc11_ = _loc6_.getTransform();
               _loc3_ = b2Shape.testOverlap(_loc8_,_loc10_,_loc9_,_loc11_);
            }
            m_manifold.m_pointCount = 0;
         }
         else
         {
            if(_loc5_.m_type != b2Body.b2_dynamicBody || (_loc5_.m_flags & b2Body.e_bulletFlag) == b2Body.e_bulletFlag || _loc6_.m_type != b2Body.b2_dynamicBody || (_loc6_.m_flags & b2Body.e_bulletFlag) == b2Body.e_bulletFlag)
            {
               m_flags |= b2Contact.e_continuousFlag;
            }
            else
            {
               m_flags &= ~b2Contact.e_continuousFlag;
            }
            if(_loc7_)
            {
               evaluate();
               _loc3_ = m_manifold.m_pointCount > 0;
               _loc12_ = 0;
               _loc13_ = m_manifold.m_pointCount;
               while(_loc12_ < _loc13_)
               {
                  _loc14_ = _loc12_++;
                  _loc15_ = m_manifold.m_points[_loc14_];
                  _loc15_.m_normalImpulse = 0;
                  _loc15_.m_tangentImpulse = 0;
                  _loc16_ = _loc15_.m_id;
                  _loc17_ = 0;
                  _loc18_ = m_oldManifold.m_pointCount;
                  while(_loc17_ < _loc18_)
                  {
                     _loc19_ = _loc17_++;
                     _loc20_ = m_oldManifold.m_points[_loc19_];
                     if(_loc20_.m_id.get_key() == _loc16_.get_key())
                     {
                        _loc15_.m_normalImpulse = _loc20_.m_normalImpulse;
                        _loc15_.m_tangentImpulse = _loc20_.m_tangentImpulse;
                        break;
                     }
                  }
               }
            }
            else
            {
               m_manifold.m_pointCount = 0;
            }
            if(_loc3_ != _loc4_)
            {
               _loc5_.setAwake(true);
               _loc6_.setAwake(true);
            }
         }
         if(_loc3_)
         {
            m_flags |= b2Contact.e_touchingFlag;
         }
         else
         {
            m_flags &= ~b2Contact.e_touchingFlag;
         }
         if(_loc4_ == false && _loc3_ == true)
         {
            listener.beginContact(this);
         }
         if(_loc4_ == true && _loc3_ == false)
         {
            listener.endContact(this);
         }
         if((m_flags & b2Contact.e_sensorFlag) == 0)
         {
            listener.preSolve(this,m_oldManifold);
         }
      }
      
      public function SetSensor(sensor:Boolean) : void
      {
         if(sensor)
         {
            m_flags |= b2Contact.e_sensorFlag;
         }
         else
         {
            m_flags &= ~b2Contact.e_sensorFlag;
         }
      }
      
      public function SetEnabled(flag:Boolean) : void
      {
         if(flag)
         {
            m_flags |= b2Contact.e_enabledFlag;
         }
         else
         {
            m_flags &= ~b2Contact.e_enabledFlag;
         }
      }
      
      public function Reset(fixtureA:b2Fixture = undefined, fixtureB:b2Fixture = undefined) : void
      {
         m_flags = b2Contact.e_enabledFlag;
         if(fixtureA == null || fixtureB == null)
         {
            m_fixtureA = null;
            m_fixtureB = null;
            return;
         }
         if(fixtureA.isSensor() || fixtureB.isSensor())
         {
            m_flags |= b2Contact.e_sensorFlag;
         }
         var _loc3_:b2Body = fixtureA.getBody();
         var _loc4_:b2Body = fixtureB.getBody();
         if(_loc3_.m_type != 2 || (_loc3_.m_flags & b2Body.e_bulletFlag) == b2Body.e_bulletFlag || _loc4_.m_type != 2 || (_loc4_.m_flags & b2Body.e_bulletFlag) == b2Body.e_bulletFlag)
         {
            m_flags |= b2Contact.e_continuousFlag;
         }
         m_fixtureA = fixtureA;
         m_fixtureB = fixtureB;
         m_manifold.m_pointCount = 0;
         m_prev = null;
         m_next = null;
         m_nodeA.contact = null;
         m_nodeA.prev = null;
         m_nodeA.next = null;
         m_nodeA.other = null;
         m_nodeB.contact = null;
         m_nodeB.prev = null;
         m_nodeB.next = null;
         m_nodeB.other = null;
      }
      
      public function IsTouching() : Boolean
      {
         return (m_flags & b2Contact.e_touchingFlag) == b2Contact.e_touchingFlag;
      }
      
      public function IsSensor() : Boolean
      {
         return (m_flags & b2Contact.e_sensorFlag) == b2Contact.e_sensorFlag;
      }
      
      public function IsEnabled() : Boolean
      {
         return (m_flags & b2Contact.e_enabledFlag) == b2Contact.e_enabledFlag;
      }
      
      public function IsContinuous() : Boolean
      {
         return (m_flags & b2Contact.e_continuousFlag) == b2Contact.e_continuousFlag;
      }
      
      public function GetWorldManifold(worldManifold:b2WorldManifold) : void
      {
         var _loc2_:b2Body = m_fixtureA.getBody();
         var _loc3_:b2Body = m_fixtureB.getBody();
         var _loc4_:b2Shape = m_fixtureA.getShape();
         var _loc5_:b2Shape = m_fixtureB.getShape();
         worldManifold.initialize(m_manifold,_loc2_.getTransform(),_loc4_.m_radius,_loc3_.getTransform(),_loc5_.m_radius);
      }
      
      public function GetNext() : b2Contact
      {
         return m_next;
      }
      
      public function GetManifold() : b2Manifold
      {
         return m_manifold;
      }
      
      public function GetFixtureB() : b2Fixture
      {
         return m_fixtureB;
      }
      
      public function GetFixtureA() : b2Fixture
      {
         return m_fixtureA;
      }
      
      public function FlagForFiltering() : void
      {
         m_flags |= b2Contact.e_filterFlag;
      }
      
      public function Evaluate() : void
      {
      }
      
      public function ComputeTOI(sweepA:b2Sweep, sweepB:b2Sweep) : Number
      {
         b2Contact.s_input.proxyA.set(m_fixtureA.getShape());
         b2Contact.s_input.proxyB.set(m_fixtureB.getShape());
         b2Contact.s_input.sweepA = sweepA;
         b2Contact.s_input.sweepB = sweepB;
         b2Contact.s_input.tolerance = b2Settings.b2_linearSlop;
         return b2TimeOfImpact.timeOfImpact(b2Contact.s_input);
      }
   }
}

