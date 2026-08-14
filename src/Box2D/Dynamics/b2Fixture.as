package Box2D.Dynamics
{
   import Box2D.Collision.IBroadPhase;
   import Box2D.Collision.Shapes.b2MassData;
   import Box2D.Collision.Shapes.b2Shape;
   import Box2D.Collision.b2AABB;
   import Box2D.Collision.b2RayCastInput;
   import Box2D.Collision.b2RayCastOutput;
   import Box2D.Common.Math.b2Math;
   import Box2D.Common.Math.b2Transform;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Common.b2internal;
   import Box2D.Dynamics.Contacts.b2Contact;
   import Box2D.Dynamics.Contacts.b2ContactEdge;
   
   use namespace b2internal;
   
   public class b2Fixture
   {
      
      private var m_massData:b2MassData;
      
      b2internal var m_aabb:b2AABB;
      
      b2internal var m_density:Number;
      
      b2internal var m_next:b2Fixture;
      
      b2internal var m_body:b2Body;
      
      b2internal var m_shape:b2Shape;
      
      b2internal var m_friction:Number;
      
      b2internal var m_restitution:Number;
      
      b2internal var m_proxy:*;
      
      b2internal var m_filter:b2FilterData = new b2FilterData();
      
      b2internal var m_isSensor:Boolean;
      
      b2internal var m_userData:*;
      
      public function b2Fixture()
      {
         super();
         this.m_aabb = new b2AABB();
         this.m_userData = null;
         this.m_body = null;
         this.m_next = null;
         this.m_shape = null;
         this.m_density = 0;
         this.m_friction = 0;
         this.m_restitution = 0;
      }
      
      public function GetType() : int
      {
         return this.m_shape.GetType();
      }
      
      public function GetShape() : b2Shape
      {
         return this.m_shape;
      }
      
      public function SetSensor(sensor:Boolean) : void
      {
         var _loc3_:b2Contact = null;
         var _loc4_:b2Fixture = null;
         var _loc5_:b2Fixture = null;
         if(this.m_isSensor == sensor)
         {
            return;
         }
         this.m_isSensor = sensor;
         if(this.m_body == null)
         {
            return;
         }
         var _loc2_:b2ContactEdge = this.m_body.GetContactList();
         while(_loc2_)
         {
            _loc3_ = _loc2_.contact;
            _loc4_ = _loc3_.GetFixtureA();
            _loc5_ = _loc3_.GetFixtureB();
            if(_loc4_ == this || _loc5_ == this)
            {
               _loc3_.SetSensor(_loc4_.IsSensor() || _loc5_.IsSensor());
            }
            _loc2_ = _loc2_.next;
         }
      }
      
      public function IsSensor() : Boolean
      {
         return this.m_isSensor;
      }
      
      public function SetFilterData(filter:b2FilterData) : void
      {
         var _loc3_:b2Contact = null;
         var _loc4_:b2Fixture = null;
         var _loc5_:b2Fixture = null;
         this.m_filter = filter.Copy();
         if(this.m_body)
         {
            return;
         }
         var _loc2_:b2ContactEdge = this.m_body.GetContactList();
         while(_loc2_)
         {
            _loc3_ = _loc2_.contact;
            _loc4_ = _loc3_.GetFixtureA();
            _loc5_ = _loc3_.GetFixtureB();
            if(_loc4_ == this || _loc5_ == this)
            {
               _loc3_.FlagForFiltering();
            }
            _loc2_ = _loc2_.next;
         }
      }
      
      public function GetFilterData() : b2FilterData
      {
         return this.m_filter.Copy();
      }
      
      public function GetBody() : b2Body
      {
         return this.m_body;
      }
      
      public function GetNext() : b2Fixture
      {
         return this.m_next;
      }
      
      public function GetUserData() : *
      {
         return this.m_userData;
      }
      
      public function SetUserData(data:*) : void
      {
         this.m_userData = data;
      }
      
      public function TestPoint(p:b2Vec2) : Boolean
      {
         return this.m_shape.TestPoint(this.m_body.GetTransform(),p);
      }
      
      public function RayCast(output:b2RayCastOutput, input:b2RayCastInput) : Boolean
      {
         return this.m_shape.RayCast(output,input,this.m_body.GetTransform());
      }
      
      public function GetMassData(massData:b2MassData = null) : b2MassData
      {
         if(massData == null)
         {
            massData = new b2MassData();
         }
         this.m_shape.ComputeMass(massData,this.m_density);
         return massData;
      }
      
      public function SetDensity(density:Number) : void
      {
         this.m_density = density;
      }
      
      public function GetDensity() : Number
      {
         return this.m_density;
      }
      
      public function GetFriction() : Number
      {
         return this.m_friction;
      }
      
      public function SetFriction(friction:Number) : void
      {
         this.m_friction = friction;
      }
      
      public function GetRestitution() : Number
      {
         return this.m_restitution;
      }
      
      public function SetRestitution(restitution:Number) : void
      {
         this.m_restitution = restitution;
      }
      
      public function GetAABB() : b2AABB
      {
         return this.m_aabb;
      }
      
      b2internal function Create(body:b2Body, xf:b2Transform, def:b2FixtureDef) : void
      {
         this.m_userData = def.userData;
         this.m_friction = def.friction;
         this.m_restitution = def.restitution;
         this.m_body = body;
         this.m_next = null;
         this.m_filter = def.filter.Copy();
         this.m_isSensor = def.isSensor;
         this.m_shape = def.shape.Copy();
         this.m_density = def.density;
      }
      
      b2internal function Destroy() : void
      {
         this.m_shape = null;
      }
      
      b2internal function CreateProxy(broadPhase:IBroadPhase, xf:b2Transform) : void
      {
         this.m_shape.ComputeAABB(this.m_aabb,xf);
         this.m_proxy = broadPhase.CreateProxy(this.m_aabb,this);
      }
      
      b2internal function DestroyProxy(broadPhase:IBroadPhase) : void
      {
         if(this.m_proxy == null)
         {
            return;
         }
         broadPhase.DestroyProxy(this.m_proxy);
         this.m_proxy = null;
      }
      
      b2internal function Synchronize(broadPhase:IBroadPhase, transform1:b2Transform, transform2:b2Transform) : void
      {
         if(!this.m_proxy)
         {
            return;
         }
         var _loc4_:b2AABB = new b2AABB();
         var _loc5_:b2AABB = new b2AABB();
         this.m_shape.ComputeAABB(_loc4_,transform1);
         this.m_shape.ComputeAABB(_loc5_,transform2);
         this.m_aabb.Combine(_loc4_,_loc5_);
         var _loc6_:b2Vec2 = b2Math.SubtractVV(transform2.position,transform1.position);
         broadPhase.MoveProxy(this.m_proxy,this.m_aabb,_loc6_);
      }
   }
}

