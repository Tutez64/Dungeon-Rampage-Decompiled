package Box2D.Dynamics.Contacts
{
   import Box2D.Collision.*;
   import Box2D.Collision.Shapes.*;
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   import Box2D.Dynamics.*;
   
   use namespace b2internal;
   
   public class b2Contact
   {
      
      b2internal static var e_sensorFlag:uint = 1;
      
      b2internal static var e_continuousFlag:uint = 2;
      
      b2internal static var e_islandFlag:uint = 4;
      
      b2internal static var e_toiFlag:uint = 8;
      
      b2internal static var e_touchingFlag:uint = 16;
      
      b2internal static var e_enabledFlag:uint = 32;
      
      b2internal static var e_filterFlag:uint = 64;
      
      private static var s_input:b2TOIInput = new b2TOIInput();
      
      b2internal var m_flags:uint;
      
      b2internal var m_prev:b2Contact;
      
      b2internal var m_next:b2Contact;
      
      b2internal var m_nodeA:b2ContactEdge = new b2ContactEdge();
      
      b2internal var m_nodeB:b2ContactEdge = new b2ContactEdge();
      
      b2internal var m_fixtureA:b2Fixture;
      
      b2internal var m_fixtureB:b2Fixture;
      
      b2internal var m_manifold:b2Manifold = new b2Manifold();
      
      b2internal var m_oldManifold:b2Manifold = new b2Manifold();
      
      b2internal var m_toi:Number;
      
      public function b2Contact()
      {
         super();
      }
      
      public function GetManifold() : b2Manifold
      {
         return this.m_manifold;
      }
      
      public function GetWorldManifold(worldManifold:b2WorldManifold) : void
      {
         var _loc2_:b2Body = this.m_fixtureA.GetBody();
         var _loc3_:b2Body = this.m_fixtureB.GetBody();
         var _loc4_:b2Shape = this.m_fixtureA.GetShape();
         var _loc5_:b2Shape = this.m_fixtureB.GetShape();
         worldManifold.Initialize(this.m_manifold,_loc2_.GetTransform(),_loc4_.m_radius,_loc3_.GetTransform(),_loc5_.m_radius);
      }
      
      public function IsTouching() : Boolean
      {
         return (this.m_flags & e_touchingFlag) == e_touchingFlag;
      }
      
      public function IsContinuous() : Boolean
      {
         return (this.m_flags & e_continuousFlag) == e_continuousFlag;
      }
      
      public function SetSensor(sensor:Boolean) : void
      {
         if(sensor)
         {
            this.m_flags |= e_sensorFlag;
         }
         else
         {
            this.m_flags &= ~e_sensorFlag;
         }
      }
      
      public function IsSensor() : Boolean
      {
         return (this.m_flags & e_sensorFlag) == e_sensorFlag;
      }
      
      public function SetEnabled(flag:Boolean) : void
      {
         if(flag)
         {
            this.m_flags |= e_enabledFlag;
         }
         else
         {
            this.m_flags &= ~e_enabledFlag;
         }
      }
      
      public function IsEnabled() : Boolean
      {
         return (this.m_flags & e_enabledFlag) == e_enabledFlag;
      }
      
      public function GetNext() : b2Contact
      {
         return this.m_next;
      }
      
      public function GetFixtureA() : b2Fixture
      {
         return this.m_fixtureA;
      }
      
      public function GetFixtureB() : b2Fixture
      {
         return this.m_fixtureB;
      }
      
      public function FlagForFiltering() : void
      {
         this.m_flags |= e_filterFlag;
      }
      
      b2internal function Reset(fixtureA:b2Fixture = null, fixtureB:b2Fixture = null) : void
      {
         this.m_flags = e_enabledFlag;
         if(!fixtureA || !fixtureB)
         {
            this.m_fixtureA = null;
            this.m_fixtureB = null;
            return;
         }
         if(fixtureA.IsSensor() || fixtureB.IsSensor())
         {
            this.m_flags |= e_sensorFlag;
         }
         var _loc3_:b2Body = fixtureA.GetBody();
         var _loc4_:b2Body = fixtureB.GetBody();
         if(_loc3_.GetType() != b2Body.b2_dynamicBody || _loc3_.IsBullet() || _loc4_.GetType() != b2Body.b2_dynamicBody || _loc4_.IsBullet())
         {
            this.m_flags |= e_continuousFlag;
         }
         this.m_fixtureA = fixtureA;
         this.m_fixtureB = fixtureB;
         this.m_manifold.m_pointCount = 0;
         this.m_prev = null;
         this.m_next = null;
         this.m_nodeA.contact = null;
         this.m_nodeA.prev = null;
         this.m_nodeA.next = null;
         this.m_nodeA.other = null;
         this.m_nodeB.contact = null;
         this.m_nodeB.prev = null;
         this.m_nodeB.next = null;
         this.m_nodeB.other = null;
      }
      
      b2internal function Update(listener:b2ContactListener) : void
      {
         var _loc8_:b2Shape = null;
         var _loc9_:b2Shape = null;
         var _loc10_:b2Transform = null;
         var _loc11_:b2Transform = null;
         var _loc12_:* = 0;
         var _loc13_:b2ManifoldPoint = null;
         var _loc14_:b2ContactID = null;
         var _loc15_:* = 0;
         var _loc16_:b2ManifoldPoint = null;
         var _loc2_:b2Manifold = this.m_oldManifold;
         this.m_oldManifold = this.m_manifold;
         this.m_manifold = _loc2_;
         this.m_flags |= e_enabledFlag;
         var _loc3_:Boolean = false;
         var _loc4_:Boolean = (this.m_flags & e_touchingFlag) == e_touchingFlag;
         var _loc5_:b2Body = this.m_fixtureA.m_body;
         var _loc6_:b2Body = this.m_fixtureB.m_body;
         var _loc7_:Boolean = this.m_fixtureA.m_aabb.TestOverlap(this.m_fixtureB.m_aabb);
         if(this.m_flags & e_sensorFlag)
         {
            if(_loc7_)
            {
               _loc8_ = this.m_fixtureA.GetShape();
               _loc9_ = this.m_fixtureB.GetShape();
               _loc10_ = _loc5_.GetTransform();
               _loc11_ = _loc6_.GetTransform();
               _loc3_ = b2Shape.TestOverlap(_loc8_,_loc10_,_loc9_,_loc11_);
            }
            this.m_manifold.m_pointCount = 0;
         }
         else
         {
            if(_loc5_.GetType() != b2Body.b2_dynamicBody || _loc5_.IsBullet() || _loc6_.GetType() != b2Body.b2_dynamicBody || _loc6_.IsBullet())
            {
               this.m_flags |= e_continuousFlag;
            }
            else
            {
               this.m_flags &= ~e_continuousFlag;
            }
            if(_loc7_)
            {
               this.Evaluate();
               _loc3_ = this.m_manifold.m_pointCount > 0;
               _loc12_ = 0;
               while(_loc12_ < this.m_manifold.m_pointCount)
               {
                  _loc13_ = this.m_manifold.m_points[_loc12_];
                  _loc13_.m_normalImpulse = 0;
                  _loc13_.m_tangentImpulse = 0;
                  _loc14_ = _loc13_.m_id;
                  _loc15_ = 0;
                  while(_loc15_ < this.m_oldManifold.m_pointCount)
                  {
                     _loc16_ = this.m_oldManifold.m_points[_loc15_];
                     if(_loc16_.m_id.key == _loc14_.key)
                     {
                        _loc13_.m_normalImpulse = _loc16_.m_normalImpulse;
                        _loc13_.m_tangentImpulse = _loc16_.m_tangentImpulse;
                        break;
                     }
                     _loc15_++;
                  }
                  _loc12_++;
               }
            }
            else
            {
               this.m_manifold.m_pointCount = 0;
            }
            if(_loc3_ != _loc4_)
            {
               _loc5_.SetAwake(true);
               _loc6_.SetAwake(true);
            }
         }
         if(_loc3_)
         {
            this.m_flags |= e_touchingFlag;
         }
         else
         {
            this.m_flags &= ~e_touchingFlag;
         }
         if(_loc4_ == false && _loc3_ == true)
         {
            listener.BeginContact(this);
         }
         if(_loc4_ == true && _loc3_ == false)
         {
            listener.EndContact(this);
         }
         if((this.m_flags & e_sensorFlag) == 0)
         {
            listener.PreSolve(this,this.m_oldManifold);
         }
      }
      
      b2internal function Evaluate() : void
      {
      }
      
      b2internal function ComputeTOI(sweepA:b2Sweep, sweepB:b2Sweep) : Number
      {
         s_input.proxyA.Set(this.m_fixtureA.GetShape());
         s_input.proxyB.Set(this.m_fixtureB.GetShape());
         s_input.sweepA = sweepA;
         s_input.sweepB = sweepB;
         s_input.tolerance = b2Settings.b2_linearSlop;
         return b2TimeOfImpact.TimeOfImpact(s_input);
      }
   }
}

