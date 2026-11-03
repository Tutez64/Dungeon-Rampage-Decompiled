package Box2D.Dynamics.Controllers
{
   import Box2D.Dynamics.b2Body;
   import Box2D.Dynamics.b2DebugDraw;
   import Box2D.Dynamics.b2TimeStep;
   import Box2D.Dynamics.b2World;
   import flash.Boot;
   
   public class b2Controller
   {
      
      public var m_world:b2World;
      
      public var m_prev:b2Controller;
      
      public var m_next:b2Controller;
      
      public var m_bodyList:b2ControllerEdge;
      
      public var m_bodyCount:int;
      
      public function b2Controller()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         m_bodyCount = 0;
      }
      
      public function step(step:b2TimeStep) : void
      {
         Step(step);
      }
      
      public function removeBody(body:b2Body) : void
      {
         RemoveBody(body);
      }
      
      public function getWorld() : b2World
      {
         return GetWorld();
      }
      
      public function getNext() : b2Controller
      {
         return GetNext();
      }
      
      public function getBodyList() : b2ControllerEdge
      {
         return GetBodyList();
      }
      
      public function draw(debugDraw:b2DebugDraw) : void
      {
         Draw(debugDraw);
      }
      
      public function clear() : void
      {
         Clear();
      }
      
      public function addBody(body:b2Body) : void
      {
         AddBody(body);
      }
      
      public function Step(step:b2TimeStep) : void
      {
      }
      
      public function RemoveBody(body:b2Body) : void
      {
         var _loc2_:b2ControllerEdge = body.m_controllerList;
         while(_loc2_ != null && _loc2_.controller != this)
         {
            _loc2_ = _loc2_.nextController;
         }
         if(_loc2_.prevBody != null)
         {
            _loc2_.prevBody.nextBody = _loc2_.nextBody;
         }
         if(_loc2_.nextBody != null)
         {
            _loc2_.nextBody.prevBody = _loc2_.prevBody;
         }
         if(_loc2_.nextController != null)
         {
            _loc2_.nextController.prevController = _loc2_.prevController;
         }
         if(_loc2_.prevController != null)
         {
            _loc2_.prevController.nextController = _loc2_.nextController;
         }
         if(m_bodyList == _loc2_)
         {
            m_bodyList = _loc2_.nextBody;
         }
         if(body.m_controllerList == _loc2_)
         {
            body.m_controllerList = _loc2_.nextController;
         }
         --body.m_controllerCount;
         --m_bodyCount;
      }
      
      public function GetWorld() : b2World
      {
         return m_world;
      }
      
      public function GetNext() : b2Controller
      {
         return m_next;
      }
      
      public function GetBodyList() : b2ControllerEdge
      {
         return m_bodyList;
      }
      
      public function Draw(debugDraw:b2DebugDraw) : void
      {
      }
      
      public function Clear() : void
      {
         while(m_bodyList != null)
         {
            removeBody(m_bodyList.body);
         }
      }
      
      public function AddBody(body:b2Body) : void
      {
         var _loc2_:b2ControllerEdge = new b2ControllerEdge();
         _loc2_.controller = this;
         _loc2_.body = body;
         _loc2_.nextBody = m_bodyList;
         _loc2_.prevBody = null;
         m_bodyList = _loc2_;
         if(_loc2_.nextBody != null)
         {
            _loc2_.nextBody.prevBody = _loc2_;
         }
         ++m_bodyCount;
         _loc2_.nextController = body.m_controllerList;
         _loc2_.prevController = null;
         body.m_controllerList = _loc2_;
         if(_loc2_.nextController != null)
         {
            _loc2_.nextController.prevController = _loc2_;
         }
         ++body.m_controllerCount;
      }
   }
}

