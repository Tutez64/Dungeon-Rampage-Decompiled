package Box2D.Collision
{
   import Box2D.Common.Math.b2Vec2;
   
   public interface IBroadPhase
   {
      
      function validate() : void;
      
      function updatePairs(callbackMethod:*) : void;
      
      function testOverlap(proxyA:*, proxyB:*) : Boolean;
      
      function rebalance(iterations:int) : void;
      
      function rayCast(callbackMethod:Function, input:b2RayCastInput) : void;
      
      function query(callbackMethod:Function, aabb:b2AABB) : void;
      
      function moveProxy(proxy:*, aabb:b2AABB, displacement:b2Vec2) : void;
      
      function getUserData(proxy:*) : *;
      
      function getProxyCount() : int;
      
      function getFatAABB(proxy:*) : b2AABB;
      
      function destroyProxy(proxy:*) : void;
      
      function createProxy(aabb:b2AABB, userData:*) : *;
      
      function Validate() : void;
      
      function UpdatePairs(callbackMethod:*) : void;
      
      function TestOverlap(proxyA:*, proxyB:*) : Boolean;
      
      function Rebalance(iterations:int) : void;
      
      function RayCast(callbackMethod:Function, input:b2RayCastInput) : void;
      
      function Query(callbackMethod:Function, aabb:b2AABB) : void;
      
      function MoveProxy(proxy:*, aabb:b2AABB, displacement:b2Vec2) : void;
      
      function GetUserData(proxy:*) : *;
      
      function GetProxyCount() : int;
      
      function GetFatAABB(proxy:*) : b2AABB;
      
      function DestroyProxy(proxy:*) : void;
      
      function CreateProxy(aabb:b2AABB, userData:*) : *;
   }
}

