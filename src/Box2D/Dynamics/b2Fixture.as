package Box2D.Dynamics
{
   import Box2D.Collision.IBroadPhase;
   import Box2D.Collision.Shapes.b2MassData;
   import Box2D.Collision.Shapes.b2Shape;
   import Box2D.Collision.b2AABB;
   import Box2D.Collision.b2RayCastInput;
   import Box2D.Collision.b2RayCastOutput;
   import Box2D.Common.Math.b2Transform;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Dynamics.Contacts.b2Contact;
   import Box2D.Dynamics.Contacts.b2ContactEdge;
   import box2dcompat.Scratch;
   import flash.Boot;
   
   public class b2Fixture
   {
      
      public var m_userData:*;
      
      public var m_shape:b2Shape;
      
      public var m_restitution:Number;
      
      public var m_proxy:*;
      
      public var m_next:b2Fixture;
      
      public var m_massData:b2MassData;
      
      public var m_isSensor:Boolean;
      
      public var m_friction:Number;
      
      public var m_filter:b2FilterData;
      
      public var m_density:Number;
      
      public var m_body:b2Body;
      
      public var m_aabb:b2AABB;
      
      public function b2Fixture()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         m_filter = new b2FilterData();
         m_aabb = new b2AABB();
         m_userData = null;
         m_body = null;
         m_next = null;
         m_shape = null;
         m_density = 0;
         m_friction = 0;
         m_restitution = 0;
      }
      
      public function testPoint(p:b2Vec2) : Boolean
      {
         return TestPoint(p);
      }
      
      public function synchronize(broadPhase:IBroadPhase, transform1:b2Transform, transform2:b2Transform) : void
      {
         Synchronize(broadPhase,transform1,transform2);
      }
      
      public function setUserData(data:*) : void
      {
         SetUserData(data);
      }
      
      public function setSensor(sensor:Boolean) : void
      {
         SetSensor(sensor);
      }
      
      public function setRestitution(restitution:Number) : void
      {
         SetRestitution(restitution);
      }
      
      public function setFriction(friction:Number) : void
      {
         SetFriction(friction);
      }
      
      public function setFilterData(filter:b2FilterData) : void
      {
         SetFilterData(filter);
      }
      
      public function setDensity(density:Number) : void
      {
         SetDensity(density);
      }
      
      public function rayCast(output:b2RayCastOutput, input:b2RayCastInput) : Boolean
      {
         return RayCast(output,input);
      }
      
      public function isSensor() : Boolean
      {
         return IsSensor();
      }
      
      public function getUserData() : *
      {
         return GetUserData();
      }
      
      public function getType() : int
      {
         return GetType();
      }
      
      public function getShape() : b2Shape
      {
         return GetShape();
      }
      
      public function getRestitution() : Number
      {
         return GetRestitution();
      }
      
      public function getNext() : b2Fixture
      {
         return GetNext();
      }
      
      public function getMassData(massData:b2MassData = undefined) : b2MassData
      {
         return GetMassData(massData);
      }
      
      public function getFriction() : Number
      {
         return GetFriction();
      }
      
      public function getFilterData() : b2FilterData
      {
         return GetFilterData();
      }
      
      public function getDensity() : Number
      {
         return GetDensity();
      }
      
      public function getBody() : b2Body
      {
         return GetBody();
      }
      
      public function getAABB() : b2AABB
      {
         return GetAABB();
      }
      
      public function destroyProxy(broadPhase:IBroadPhase) : void
      {
         DestroyProxy(broadPhase);
      }
      
      public function destroy() : void
      {
         Destroy();
      }
      
      public function createProxy(broadPhase:IBroadPhase, xf:b2Transform) : void
      {
         CreateProxy(broadPhase,xf);
      }
      
      public function create(body:b2Body, xf:b2Transform, def:b2FixtureDef) : void
      {
         Create(body,xf,def);
      }
      
      public function TestPoint(p:b2Vec2) : Boolean
      {
         return m_shape.testPoint(m_body.getTransform(),p);
      }
      
      public function Synchronize(broadPhase:IBroadPhase, transform1:b2Transform, transform2:b2Transform) : void
      {
         if(m_proxy == null)
         {
            return;
         }
         var _loc4_:b2AABB = Scratch.aabbs[0];
         var _loc5_:b2AABB = Scratch.aabbs[1];
         m_shape.computeAABB(_loc4_,transform1);
         m_shape.computeAABB(_loc5_,transform2);
         m_aabb.combine(_loc4_,_loc5_);
         var _loc6_:b2Vec2 = transform2.position;
         var _loc7_:b2Vec2 = transform1.position;
         Scratch.difference.x = _loc6_.x - _loc7_.x;
         Scratch.difference.y = _loc6_.y - _loc7_.y;
         var _loc8_:b2Vec2 = Scratch.difference;
         broadPhase.moveProxy(m_proxy,m_aabb,_loc8_);
      }
      
      public function SetUserData(data:*) : void
      {
         m_userData = data;
      }
      
      public function SetSensor(sensor:Boolean) : void
      {
         var _loc3_:* = null as b2Contact;
         var _loc4_:* = null as b2Fixture;
         var _loc5_:* = null as b2Fixture;
         if(m_isSensor == sensor)
         {
            return;
         }
         m_isSensor = sensor;
         if(m_body == null)
         {
            return;
         }
         var _loc2_:b2ContactEdge = m_body.getContactList();
         while(_loc2_ != null)
         {
            _loc3_ = _loc2_.contact;
            _loc4_ = _loc3_.getFixtureA();
            _loc5_ = _loc3_.getFixtureB();
            if(_loc4_ == this || _loc5_ == this)
            {
               _loc3_.setSensor(_loc4_.isSensor() || _loc5_.isSensor());
            }
            _loc2_ = _loc2_.next;
         }
      }
      
      public function SetRestitution(restitution:Number) : void
      {
         m_restitution = restitution;
      }
      
      public function SetFriction(friction:Number) : void
      {
         m_friction = friction;
      }
      
      public function SetFilterData(filter:b2FilterData) : void
      {
         var _loc3_:* = null as b2Contact;
         var _loc4_:* = null as b2Fixture;
         var _loc5_:* = null as b2Fixture;
         m_filter = filter.copy();
         if(m_body == null)
         {
            return;
         }
         var _loc2_:b2ContactEdge = m_body.getContactList();
         while(_loc2_ != null)
         {
            _loc3_ = _loc2_.contact;
            _loc4_ = _loc3_.getFixtureA();
            _loc5_ = _loc3_.getFixtureB();
            if(_loc4_ == this || _loc5_ == this)
            {
               _loc3_.flagForFiltering();
            }
            _loc2_ = _loc2_.next;
         }
      }
      
      public function SetDensity(density:Number) : void
      {
         m_density = density;
      }
      
      public function RayCast(output:b2RayCastOutput, input:b2RayCastInput) : Boolean
      {
         return m_shape.rayCast(output,input,m_body.getTransform());
      }
      
      public function IsSensor() : Boolean
      {
         return m_isSensor;
      }
      
      public function GetUserData() : *
      {
         return m_userData;
      }
      
      public function GetType() : int
      {
         return m_shape.getType();
      }
      
      public function GetShape() : b2Shape
      {
         return m_shape;
      }
      
      public function GetRestitution() : Number
      {
         return m_restitution;
      }
      
      public function GetNext() : b2Fixture
      {
         return m_next;
      }
      
      public function GetMassData(massData:b2MassData = undefined) : b2MassData
      {
         if(massData == null)
         {
            massData = new b2MassData();
         }
         m_shape.computeMass(massData,m_density);
         return massData;
      }
      
      public function GetFriction() : Number
      {
         return m_friction;
      }
      
      public function GetFilterData() : b2FilterData
      {
         return m_filter.copy();
      }
      
      public function GetDensity() : Number
      {
         return m_density;
      }
      
      public function GetBody() : b2Body
      {
         return m_body;
      }
      
      public function GetAABB() : b2AABB
      {
         return m_aabb;
      }
      
      public function DestroyProxy(broadPhase:IBroadPhase) : void
      {
         if(m_proxy == null)
         {
            return;
         }
         broadPhase.destroyProxy(m_proxy);
         m_proxy = null;
      }
      
      public function Destroy() : void
      {
         m_shape = null;
      }
      
      public function CreateProxy(broadPhase:IBroadPhase, xf:b2Transform) : void
      {
         m_shape.computeAABB(m_aabb,xf);
         m_proxy = broadPhase.createProxy(m_aabb,this);
      }
      
      public function Create(body:b2Body, xf:b2Transform, def:b2FixtureDef) : void
      {
         m_userData = def.userData;
         m_friction = def.friction;
         m_restitution = def.restitution;
         m_body = body;
         m_next = null;
         m_filter = def.filter.copy();
         m_isSensor = def.isSensor;
         m_shape = def.shape.copy();
         m_density = def.density;
      }
   }
}

