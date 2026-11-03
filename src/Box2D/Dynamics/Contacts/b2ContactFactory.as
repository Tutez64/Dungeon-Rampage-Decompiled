package Box2D.Dynamics.Contacts
{
   import Box2D.Dynamics.b2Fixture;
   import flash.Boot;
   
   public class b2ContactFactory
   {
      
      public var m_registers:Array;
      
      public var m_allocator:*;
      
      public function b2ContactFactory(allocator:* = undefined)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         m_allocator = allocator;
         initializeRegisters();
      }
      
      public function initializeRegisters() : void
      {
         InitializeRegisters();
      }
      
      public function destroy(contact:b2Contact) : void
      {
         Destroy(contact);
      }
      
      public function create(fixtureA:b2Fixture, fixtureB:b2Fixture) : b2Contact
      {
         return Create(fixtureA,fixtureB);
      }
      
      public function addType(createFcn:*, destroyFcn:*, type1:int, type2:int) : void
      {
         AddType(createFcn,destroyFcn,type1,type2);
      }
      
      public function InitializeRegisters() : void
      {
         m_registers = [];
         m_registers[0] = [];
         m_registers[0][0] = new b2ContactRegister();
         m_registers[0][1] = new b2ContactRegister();
         m_registers[0][2] = new b2ContactRegister();
         m_registers[0][3] = new b2ContactRegister();
         m_registers[1] = [];
         m_registers[1][0] = new b2ContactRegister();
         m_registers[1][1] = new b2ContactRegister();
         m_registers[1][2] = new b2ContactRegister();
         m_registers[1][3] = new b2ContactRegister();
         m_registers[2] = [];
         m_registers[2][0] = new b2ContactRegister();
         m_registers[2][1] = new b2ContactRegister();
         m_registers[2][2] = new b2ContactRegister();
         m_registers[2][3] = new b2ContactRegister();
         m_registers[3] = [];
         m_registers[3][0] = new b2ContactRegister();
         m_registers[3][1] = new b2ContactRegister();
         m_registers[3][2] = new b2ContactRegister();
         m_registers[3][3] = new b2ContactRegister();
         addType(b2CircleContact.create,b2CircleContact.destroy,1,1);
         addType(b2PolyAndCircleContact.create,b2PolyAndCircleContact.destroy,2,1);
         addType(b2PolygonContact.create,b2PolygonContact.destroy,2,2);
         addType(b2EdgeAndCircleContact.create,b2EdgeAndCircleContact.destroy,3,1);
         addType(b2PolyAndEdgeContact.create,b2PolyAndEdgeContact.destroy,2,3);
      }
      
      public function Destroy(contact:b2Contact) : void
      {
         if(contact.m_manifold.m_pointCount > 0)
         {
            contact.m_fixtureA.m_body.setAwake(true);
            contact.m_fixtureB.m_body.setAwake(true);
         }
         var _loc2_:int = contact.m_fixtureA.getType();
         var _loc3_:int = contact.m_fixtureB.getType();
         var _loc4_:b2ContactRegister = m_registers[_loc2_][_loc3_];
         ++_loc4_.poolCount;
         contact.m_next = _loc4_.pool;
         _loc4_.pool = contact;
         contact.reset();
         var _loc5_:* = _loc4_.destroyFcn;
         _loc5_(contact,m_allocator);
      }
      
      public function Create(fixtureA:b2Fixture, fixtureB:b2Fixture) : b2Contact
      {
         var _loc6_:* = null as b2Fixture;
         var _loc7_:* = null as b2Contact;
         var _loc3_:int = fixtureA.getType();
         var _loc4_:int = fixtureB.getType();
         var _loc5_:b2ContactRegister = m_registers[_loc3_][_loc4_];
         if(!_loc5_.primary)
         {
            _loc5_ = m_registers[_loc4_][_loc3_];
            _loc6_ = fixtureB;
            fixtureB = fixtureA;
            fixtureA = _loc6_;
         }
         if(_loc5_.pool != null)
         {
            _loc7_ = _loc5_.pool;
            _loc5_.pool = _loc7_.m_next;
            --_loc5_.poolCount;
            _loc7_.reset(fixtureA,fixtureB);
            return _loc7_;
         }
         var _loc8_:* = _loc5_.createFcn;
         if(_loc8_ != null)
         {
            _loc7_ = _loc8_(m_allocator);
            _loc7_.reset(fixtureA,fixtureB);
            return _loc7_;
         }
         return null;
      }
      
      public function AddType(createFcn:*, destroyFcn:*, type1:int, type2:int) : void
      {
         m_registers[type1][type2].createFcn = createFcn;
         m_registers[type1][type2].destroyFcn = destroyFcn;
         m_registers[type1][type2].primary = true;
         if(type1 != type2)
         {
            m_registers[type2][type1].createFcn = createFcn;
            m_registers[type2][type1].destroyFcn = destroyFcn;
            m_registers[type2][type1].primary = false;
         }
      }
   }
}

