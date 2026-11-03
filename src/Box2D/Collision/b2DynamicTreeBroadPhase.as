package Box2D.Collision
{
   import Box2D.Common.Math.b2Vec2;
   import flash.Boot;
   
   public class b2DynamicTreeBroadPhase implements IBroadPhase
   {
      
      public var m_tree:b2DynamicTree;
      
      public var m_queryProxy:b2DynamicTreeNode;
      
      public var m_proxyCount:int;
      
      public var m_pairCount:int;
      
      public var m_pairBuffer:Array;
      
      public var m_moveBuffer:Array;
      
      public function b2DynamicTreeBroadPhase()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         m_tree = new b2DynamicTree();
         m_moveBuffer = [];
         m_pairBuffer = [];
         m_pairCount = 0;
         m_proxyCount = 0;
      }
      
      public function validate() : void
      {
         Validate();
      }
      
      public function updatePairsQueryCallback(proxy:b2DynamicTreeNode) : Boolean
      {
         if(proxy == m_queryProxy)
         {
            return true;
         }
         if(m_pairCount == int(m_pairBuffer.length))
         {
            m_pairBuffer[m_pairCount] = new b2DynamicTreePair();
         }
         var _loc2_:b2DynamicTreePair = m_pairBuffer[m_pairCount];
         if(proxy.id < m_queryProxy.id)
         {
            _loc2_.proxyA = proxy;
            _loc2_.proxyB = m_queryProxy;
         }
         else
         {
            _loc2_.proxyA = m_queryProxy;
            _loc2_.proxyB = proxy;
         }
         ++m_pairCount;
         return true;
      }
      
      public function updatePairs(callbackMethod:*) : void
      {
         UpdatePairs(callbackMethod);
      }
      
      public function unBufferMove(proxy:b2DynamicTreeNode) : void
      {
         m_moveBuffer.remove(proxy);
      }
      
      public function testOverlap(proxyA:*, proxyB:*) : Boolean
      {
         return TestOverlap(proxyA,proxyB);
      }
      
      public function rebalance(iterations:int) : void
      {
         Rebalance(iterations);
      }
      
      public function rayCast(callbackMethod:Function, input:b2RayCastInput) : void
      {
         RayCast(callbackMethod,input);
      }
      
      public function query(callbackMethod:Function, aabb:b2AABB) : void
      {
         Query(callbackMethod,aabb);
      }
      
      public function moveProxy(proxy:*, aabb:b2AABB, displacement:b2Vec2) : void
      {
         MoveProxy(proxy,aabb,displacement);
      }
      
      public function getUserData(proxy:*) : *
      {
         return GetUserData(proxy);
      }
      
      public function getProxyCount() : int
      {
         return GetProxyCount();
      }
      
      public function getFatAABB(proxy:*) : b2AABB
      {
         return GetFatAABB(proxy);
      }
      
      public function endAbandonedQueries() : void
      {
         EndAbandonedQueries();
      }
      
      public function destroyProxy(proxy:*) : void
      {
         DestroyProxy(proxy);
      }
      
      public function createProxy(aabb:b2AABB, userData:*) : *
      {
         return CreateProxy(aabb,userData);
      }
      
      public function comparePairs(pair1:b2DynamicTreePair, pair2:b2DynamicTreePair) : int
      {
         return 0;
      }
      
      public function bufferMove(proxy:b2DynamicTreeNode) : void
      {
         m_moveBuffer[int(m_moveBuffer.length)] = proxy;
      }
      
      public function Validate() : void
      {
      }
      
      public function UpdatePairs(callbackMethod:*) : void
      {
         var _loc4_:* = null as b2DynamicTreeNode;
         var _loc5_:* = null as b2AABB;
         var _loc7_:* = null as b2DynamicTreePair;
         var _loc8_:* = null;
         var _loc9_:* = null;
         var _loc10_:* = null as b2DynamicTreePair;
         m_pairCount = 0;
         var _loc2_:int = 0;
         var _loc3_:Array = m_moveBuffer;
         while(_loc2_ < int(_loc3_.length))
         {
            _loc4_ = _loc3_[_loc2_];
            _loc2_++;
            m_queryProxy = _loc4_;
            _loc5_ = m_tree.getFatAABB(_loc4_);
            m_tree.query(updatePairsQueryCallback,_loc5_);
         }
         m_moveBuffer.length = 0;
         var _loc6_:Boolean = true;
         _loc2_ = 0;
         while(_loc6_)
         {
            if(_loc2_ >= m_pairCount)
            {
               _loc6_ = false;
            }
            else
            {
               _loc7_ = m_pairBuffer[_loc2_];
               _loc8_ = m_tree.getUserData(_loc7_.proxyA);
               _loc9_ = m_tree.getUserData(_loc7_.proxyB);
               callbackMethod(_loc8_,_loc9_);
               _loc2_++;
               while(_loc2_ < m_pairCount)
               {
                  _loc10_ = m_pairBuffer[_loc2_];
                  if(_loc10_.proxyA != _loc7_.proxyA || _loc10_.proxyB != _loc7_.proxyB)
                  {
                     break;
                  }
                  _loc2_++;
               }
            }
         }
      }
      
      public function TestOverlap(proxyA:*, proxyB:*) : Boolean
      {
         var _loc3_:b2AABB = m_tree.getFatAABB(proxyA);
         var _loc4_:b2AABB = m_tree.getFatAABB(proxyB);
         return _loc3_.testOverlap(_loc4_);
      }
      
      public function Rebalance(iterations:int) : void
      {
         m_tree.rebalance(iterations);
      }
      
      public function RayCast(callbackMethod:Function, input:b2RayCastInput) : void
      {
         m_tree.rayCast(callbackMethod,input);
      }
      
      public function Query(callbackMethod:Function, aabb:b2AABB) : void
      {
         m_tree.query(callbackMethod,aabb);
      }
      
      public function MoveProxy(proxy:*, aabb:b2AABB, displacement:b2Vec2) : void
      {
         var _loc4_:Boolean = m_tree.moveProxy(proxy,aabb,displacement);
         if(_loc4_)
         {
            bufferMove(proxy);
         }
      }
      
      public function GetUserData(proxy:*) : *
      {
         return m_tree.getUserData(proxy);
      }
      
      public function GetProxyCount() : int
      {
         return m_proxyCount;
      }
      
      public function GetFatAABB(proxy:*) : b2AABB
      {
         return m_tree.getFatAABB(proxy);
      }
      
      public function EndAbandonedQueries() : void
      {
         m_tree.endAbandonedQueries();
      }
      
      public function DestroyProxy(proxy:*) : void
      {
         unBufferMove(proxy);
         --m_proxyCount;
         m_tree.destroyProxy(proxy);
      }
      
      public function CreateProxy(aabb:b2AABB, userData:*) : *
      {
         var _loc3_:b2DynamicTreeNode = m_tree.createProxy(aabb,userData);
         ++m_proxyCount;
         bufferMove(_loc3_);
         return _loc3_;
      }
   }
}

