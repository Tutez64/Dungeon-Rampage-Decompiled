package Box2D.Collision
{
   import Box2D.Common.Math.b2Vec2;
   
   public interface IBroadPhase
   {
      
      function CreateProxy(aabb:b2AABB, userData:*) : *;
      
      function DestroyProxy(proxy:*) : void;
      
      function MoveProxy(proxy:*, aabb:b2AABB, displacement:b2Vec2) : void;
      
      function TestOverlap(proxyA:*, proxyB:*) : Boolean;
      
      function GetUserData(proxy:*) : *;
      
      function GetFatAABB(proxy:*) : b2AABB;
      
      function GetProxyCount() : int;
      
      function UpdatePairs(callback:Function) : void;
      
      function Query(callback:Function, aabb:b2AABB) : void;
      
      function RayCast(callback:Function, input:b2RayCastInput) : void;
      
      function Validate() : void;
      
      function Rebalance(iterations:int) : void;
   }
}

