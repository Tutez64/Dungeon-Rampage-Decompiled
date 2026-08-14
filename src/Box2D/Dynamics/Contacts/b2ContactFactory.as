package Box2D.Dynamics.Contacts
{
   import Box2D.Collision.*;
   import Box2D.Collision.Shapes.*;
   import Box2D.Common.*;
   import Box2D.Common.Math.*;
   import Box2D.Dynamics.*;
   
   use namespace b2internal;
   
   public class b2ContactFactory
   {
      
      private var m_registers:Vector.<Vector.<b2ContactRegister>>;
      
      private var m_allocator:*;
      
      public function b2ContactFactory(allocator:*)
      {
         super();
         this.m_allocator = allocator;
         this.InitializeRegisters();
      }
      
      b2internal function AddType(createFcn:Function, destroyFcn:Function, type1:int, type2:int) : void
      {
         this.m_registers[type1][type2].createFcn = createFcn;
         this.m_registers[type1][type2].destroyFcn = destroyFcn;
         this.m_registers[type1][type2].primary = true;
         if(type1 != type2)
         {
            this.m_registers[type2][type1].createFcn = createFcn;
            this.m_registers[type2][type1].destroyFcn = destroyFcn;
            this.m_registers[type2][type1].primary = false;
         }
      }
      
      b2internal function InitializeRegisters() : void
      {
         var _loc2_:* = 0;
         this.m_registers = new Vector.<Vector.<b2ContactRegister>>(b2Shape.e_shapeTypeCount);
         var _loc1_:* = 0;
         while(_loc1_ < b2Shape.e_shapeTypeCount)
         {
            this.m_registers[_loc1_] = new Vector.<b2ContactRegister>(b2Shape.e_shapeTypeCount);
            _loc2_ = 0;
            while(_loc2_ < b2Shape.e_shapeTypeCount)
            {
               this.m_registers[_loc1_][_loc2_] = new b2ContactRegister();
               _loc2_++;
            }
            _loc1_++;
         }
         this.AddType(b2CircleContact.Create,b2CircleContact.Destroy,b2Shape.e_circleShape,b2Shape.e_circleShape);
         this.AddType(b2PolyAndCircleContact.Create,b2PolyAndCircleContact.Destroy,b2Shape.e_polygonShape,b2Shape.e_circleShape);
         this.AddType(b2PolygonContact.Create,b2PolygonContact.Destroy,b2Shape.e_polygonShape,b2Shape.e_polygonShape);
         this.AddType(b2EdgeAndCircleContact.Create,b2EdgeAndCircleContact.Destroy,b2Shape.e_edgeShape,b2Shape.e_circleShape);
         this.AddType(b2PolyAndEdgeContact.Create,b2PolyAndEdgeContact.Destroy,b2Shape.e_polygonShape,b2Shape.e_edgeShape);
      }
      
      public function Create(fixtureA:b2Fixture, fixtureB:b2Fixture) : b2Contact
      {
         var _loc6_:b2Contact = null;
         var _loc3_:int = fixtureA.GetType();
         var _loc4_:int = fixtureB.GetType();
         var _loc5_:b2ContactRegister = this.m_registers[_loc3_][_loc4_];
         if(_loc5_.pool)
         {
            _loc6_ = _loc5_.pool;
            _loc5_.pool = _loc6_.m_next;
            --_loc5_.poolCount;
            _loc6_.Reset(fixtureA,fixtureB);
            return _loc6_;
         }
         var _loc7_:Function = _loc5_.createFcn;
         if(_loc7_ != null)
         {
            if(_loc5_.primary)
            {
               _loc6_ = _loc7_(this.m_allocator);
               _loc6_.Reset(fixtureA,fixtureB);
               return _loc6_;
            }
            _loc6_ = _loc7_(this.m_allocator);
            _loc6_.Reset(fixtureB,fixtureA);
            return _loc6_;
         }
         return null;
      }
      
      public function Destroy(contact:b2Contact) : void
      {
         if(contact.m_manifold.m_pointCount > 0)
         {
            contact.m_fixtureA.m_body.SetAwake(true);
            contact.m_fixtureB.m_body.SetAwake(true);
         }
         var _loc2_:int = contact.m_fixtureA.GetType();
         var _loc3_:int = contact.m_fixtureB.GetType();
         var _loc4_:b2ContactRegister = this.m_registers[_loc2_][_loc3_];
         ++_loc4_.poolCount;
         contact.m_next = _loc4_.pool;
         _loc4_.pool = contact;
         var _loc5_:Function = _loc4_.destroyFcn;
         _loc5_(contact,this.m_allocator);
      }
   }
}

