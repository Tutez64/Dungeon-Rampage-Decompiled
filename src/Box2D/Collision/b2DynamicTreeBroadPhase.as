package Box2D.Collision
{
   import Box2D.Common.Math.*;
   
   public class b2DynamicTreeBroadPhase implements IBroadPhase
   {
      
      private var m_tree:b2DynamicTree = new b2DynamicTree();
      
      private var m_proxyCount:int;
      
      private var m_moveBuffer:Vector.<b2DynamicTreeNode> = new Vector.<b2DynamicTreeNode>();
      
      private var m_pairBuffer:Vector.<b2DynamicTreePair> = new Vector.<b2DynamicTreePair>();
      
      private var m_pairCount:int = 0;
      
      public function b2DynamicTreeBroadPhase()
      {
         super();
      }
      
      public function CreateProxy(aabb:b2AABB, userData:*) : *
      {
         var _loc3_:b2DynamicTreeNode = this.m_tree.CreateProxy(aabb,userData);
         ++this.m_proxyCount;
         this.BufferMove(_loc3_);
         return _loc3_;
      }
      
      public function DestroyProxy(proxy:*) : void
      {
         this.UnBufferMove(proxy);
         --this.m_proxyCount;
         this.m_tree.DestroyProxy(proxy);
      }
      
      public function MoveProxy(proxy:*, aabb:b2AABB, displacement:b2Vec2) : void
      {
         var _loc4_:Boolean = this.m_tree.MoveProxy(proxy,aabb,displacement);
         if(_loc4_)
         {
            this.BufferMove(proxy);
         }
      }
      
      public function TestOverlap(proxyA:*, proxyB:*) : Boolean
      {
         var _loc3_:b2AABB = this.m_tree.GetFatAABB(proxyA);
         var _loc4_:b2AABB = this.m_tree.GetFatAABB(proxyB);
         return _loc3_.TestOverlap(_loc4_);
      }
      
      public function GetUserData(proxy:*) : *
      {
         return this.m_tree.GetUserData(proxy);
      }
      
      public function GetFatAABB(proxy:*) : b2AABB
      {
         return this.m_tree.GetFatAABB(proxy);
      }
      
      public function GetProxyCount() : int
      {
         return this.m_proxyCount;
      }
      
      public function UpdatePairs(callback:Function) : void
      {
         var QueryCallback:Function;
         var queryProxy:b2DynamicTreeNode = null;
         var i:int = 0;
         var fatAABB:b2AABB = null;
         var primaryPair:b2DynamicTreePair = null;
         var userDataA:* = undefined;
         var userDataB:* = undefined;
         var pair:b2DynamicTreePair = null;
         this.m_pairCount = 0;
         for each(queryProxy in this.m_moveBuffer)
         {
            QueryCallback = function(proxy:b2DynamicTreeNode):Boolean
            {
               if(proxy == queryProxy)
               {
                  return true;
               }
               if(m_pairCount == m_pairBuffer.length)
               {
                  m_pairBuffer[m_pairCount] = new b2DynamicTreePair();
               }
               var _loc2_:b2DynamicTreePair = m_pairBuffer[m_pairCount];
               _loc2_.proxyA = proxy < queryProxy ? proxy : queryProxy;
               _loc2_.proxyB = proxy >= queryProxy ? proxy : queryProxy;
               ++m_pairCount;
               return true;
            };
            fatAABB = this.m_tree.GetFatAABB(queryProxy);
            this.m_tree.Query(QueryCallback,fatAABB);
         }
         this.m_moveBuffer.length = 0;
         i = 0;
         while(i < this.m_pairCount)
         {
            primaryPair = this.m_pairBuffer[i];
            userDataA = this.m_tree.GetUserData(primaryPair.proxyA);
            userDataB = this.m_tree.GetUserData(primaryPair.proxyB);
            callback(userDataA,userDataB);
            i++;
            while(i < this.m_pairCount)
            {
               pair = this.m_pairBuffer[i];
               if(pair.proxyA != primaryPair.proxyA || pair.proxyB != primaryPair.proxyB)
               {
                  break;
               }
               i++;
            }
         }
      }
      
      public function Query(callback:Function, aabb:b2AABB) : void
      {
         this.m_tree.Query(callback,aabb);
      }
      
      public function RayCast(callback:Function, input:b2RayCastInput) : void
      {
         this.m_tree.RayCast(callback,input);
      }
      
      public function Validate() : void
      {
      }
      
      public function Rebalance(iterations:int) : void
      {
         this.m_tree.Rebalance(iterations);
      }
      
      private function BufferMove(proxy:b2DynamicTreeNode) : void
      {
         this.m_moveBuffer[this.m_moveBuffer.length] = proxy;
      }
      
      private function UnBufferMove(proxy:b2DynamicTreeNode) : void
      {
         var _loc2_:int = this.m_moveBuffer.indexOf(proxy);
         this.m_moveBuffer.splice(_loc2_,1);
      }
      
      private function ComparePairs(pair1:b2DynamicTreePair, pair2:b2DynamicTreePair) : int
      {
         return 0;
      }
   }
}

