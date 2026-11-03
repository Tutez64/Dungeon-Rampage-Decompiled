package Box2D.Collision
{
   import Box2D.Common.Math.b2Math;
   import Box2D.Common.Math.b2Vec2;
   import Box2D.Common.b2Settings;
   import box2dcompat.Scratch;
   import flash.Boot;
   
   public class b2DynamicTree
   {
      
      public var m_root:b2DynamicTreeNode;
      
      public var m_queryStack:Array;
      
      public var m_queryDepth:int;
      
      public var m_path:int;
      
      public var m_insertionCount:int;
      
      public var m_freeList:b2DynamicTreeNode;
      
      public function b2DynamicTree()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         m_queryDepth = 0;
         m_queryStack = [];
         m_root = null;
         m_freeList = null;
         m_path = 0;
         m_insertionCount = 0;
      }
      
      public function removeLeaf(leaf:b2DynamicTreeNode) : void
      {
         var _loc4_:* = null as b2DynamicTreeNode;
         var _loc5_:* = null as b2AABB;
         var _loc6_:* = null as b2AABB;
         if(leaf == m_root)
         {
            m_root = null;
            return;
         }
         var _loc2_:b2DynamicTreeNode = leaf.parent;
         var _loc3_:b2DynamicTreeNode = _loc2_.parent;
         if(_loc2_.child1 == leaf)
         {
            _loc4_ = _loc2_.child2;
         }
         else
         {
            _loc4_ = _loc2_.child1;
         }
         if(_loc3_ != null)
         {
            if(_loc3_.child1 == _loc2_)
            {
               _loc3_.child1 = _loc4_;
            }
            else
            {
               _loc3_.child2 = _loc4_;
            }
            _loc4_.parent = _loc3_;
            freeNode(_loc2_);
            while(_loc3_ != null)
            {
               _loc5_ = _loc3_.aabb;
               _loc6_ = Scratch.spare;
               Scratch.spare = _loc5_;
               _loc3_.aabb = _loc6_;
               _loc3_.aabb.combine(_loc3_.child1.aabb,_loc3_.child2.aabb);
               if(_loc5_.contains(_loc3_.aabb))
               {
                  break;
               }
               _loc3_ = _loc3_.parent;
            }
         }
         else
         {
            m_root = _loc4_;
            _loc4_.parent = null;
            freeNode(_loc2_);
         }
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
      
      public function moveProxy(proxy:b2DynamicTreeNode, aabb:b2AABB, displacement:b2Vec2) : Boolean
      {
         return MoveProxy(proxy,aabb,displacement);
      }
      
      public function insertLeaf(leaf:b2DynamicTreeNode) : void
      {
         var _loc5_:* = null as b2DynamicTreeNode;
         var _loc6_:* = null as b2DynamicTreeNode;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         ++m_insertionCount;
         if(m_root == null)
         {
            m_root = leaf;
            m_root.parent = null;
            return;
         }
         var _loc2_:b2AABB = leaf.aabb;
         Scratch.centre.x = (_loc2_.lowerBound.x + _loc2_.upperBound.x) / 2;
         Scratch.centre.y = (_loc2_.lowerBound.y + _loc2_.upperBound.y) / 2;
         var _loc3_:b2Vec2 = Scratch.centre;
         var _loc4_:b2DynamicTreeNode = m_root;
         if(_loc4_.isLeaf() == false)
         {
            do
            {
               _loc5_ = _loc4_.child1;
               _loc6_ = _loc4_.child2;
               _loc7_ = Math.abs((_loc5_.aabb.lowerBound.x + _loc5_.aabb.upperBound.x) / 2 - _loc3_.x) + Math.abs((_loc5_.aabb.lowerBound.y + _loc5_.aabb.upperBound.y) / 2 - _loc3_.y);
               _loc8_ = Math.abs((_loc6_.aabb.lowerBound.x + _loc6_.aabb.upperBound.x) / 2 - _loc3_.x) + Math.abs((_loc6_.aabb.lowerBound.y + _loc6_.aabb.upperBound.y) / 2 - _loc3_.y);
               if(_loc7_ < _loc8_)
               {
                  _loc4_ = _loc5_;
               }
               else
               {
                  _loc4_ = _loc6_;
               }
            }
            while(_loc4_.isLeaf() == false);
         }
         _loc5_ = _loc4_.parent;
         _loc6_ = allocateNode();
         _loc6_.parent = _loc5_;
         _loc6_.userData = null;
         _loc6_.aabb.combine(leaf.aabb,_loc4_.aabb);
         if(_loc5_ != null)
         {
            if(_loc4_.parent.child1 == _loc4_)
            {
               _loc5_.child1 = _loc6_;
            }
            else
            {
               _loc5_.child2 = _loc6_;
            }
            _loc6_.child1 = _loc4_;
            _loc6_.child2 = leaf;
            _loc4_.parent = _loc6_;
            leaf.parent = _loc6_;
            while(!_loc5_.aabb.contains(_loc6_.aabb))
            {
               _loc5_.aabb.combine(_loc5_.child1.aabb,_loc5_.child2.aabb);
               _loc6_ = _loc5_;
               _loc5_ = _loc5_.parent;
               if(_loc5_ == null)
               {
                  break;
               }
            }
         }
         else
         {
            _loc6_.child1 = _loc4_;
            _loc6_.child2 = leaf;
            _loc4_.parent = _loc6_;
            leaf.parent = _loc6_;
            m_root = _loc6_;
         }
      }
      
      public function getUserData(proxy:b2DynamicTreeNode) : *
      {
         return GetUserData(proxy);
      }
      
      public function getFatAABB(proxy:b2DynamicTreeNode) : b2AABB
      {
         return GetFatAABB(proxy);
      }
      
      public function freeNode(node:b2DynamicTreeNode) : void
      {
         node.parent = m_freeList;
         m_freeList = node;
      }
      
      public function endAbandonedQueries() : void
      {
         EndAbandonedQueries();
      }
      
      public function destroyProxy(proxy:b2DynamicTreeNode) : void
      {
         DestroyProxy(proxy);
      }
      
      public function createProxy(aabb:b2AABB, userData:*) : b2DynamicTreeNode
      {
         return CreateProxy(aabb,userData);
      }
      
      public function allocateNode() : b2DynamicTreeNode
      {
         var _loc1_:* = null as b2DynamicTreeNode;
         if(m_freeList != null)
         {
            _loc1_ = m_freeList;
            m_freeList = _loc1_.parent;
            _loc1_.parent = null;
            _loc1_.child1 = null;
            _loc1_.child2 = null;
            return _loc1_;
         }
         return new b2DynamicTreeNode();
      }
      
      public function Rebalance(iterations:int) : void
      {
         var _loc4_:int = 0;
         var _loc5_:* = null as b2DynamicTreeNode;
         var _loc6_:int = 0;
         if(m_root == null)
         {
            return;
         }
         var _loc2_:int = 0;
         var _loc3_:int = iterations;
         while(_loc2_ < _loc3_)
         {
            _loc4_ = _loc2_++;
            _loc5_ = m_root;
            _loc6_ = 0;
            while(_loc5_.isLeaf() == false)
            {
               _loc5_ = (m_path >> _loc6_ & 1) != 0 ? _loc5_.child2 : _loc5_.child1;
               _loc6_ = _loc6_ + 1 & 0x1F;
            }
            ++m_path;
            removeLeaf(_loc5_);
            insertLeaf(_loc5_);
         }
      }
      
      public function RayCast(callbackMethod:Function, input:b2RayCastInput) : void
      {
         var _loc14_:* = null as b2DynamicTreeNode;
         var _loc15_:* = null as b2Vec2;
         var _loc16_:* = null as b2Vec2;
         var _loc17_:Number = NaN;
         var _loc18_:* = null as b2RayCastInput;
         if(m_root == null)
         {
            return;
         }
         var _loc3_:b2Vec2 = input.p1;
         var _loc4_:b2Vec2 = input.p2;
         var _loc5_:b2Vec2 = b2Math.subtractVV(_loc3_,_loc4_);
         _loc5_.normalize();
         var _loc6_:b2Vec2 = b2Math.crossFV(1,_loc5_);
         var _loc7_:b2Vec2 = b2Math.absV(_loc6_);
         var _loc8_:Number = input.maxFraction;
         var _loc9_:b2AABB = new b2AABB();
         var _loc10_:Number = _loc3_.x + _loc8_ * (_loc4_.x - _loc3_.x);
         var _loc11_:Number = _loc3_.y + _loc8_ * (_loc4_.y - _loc3_.y);
         _loc9_.lowerBound.x = Math.min(_loc3_.x,_loc10_);
         _loc9_.lowerBound.y = Math.min(_loc3_.y,_loc11_);
         _loc9_.upperBound.x = Math.max(_loc3_.x,_loc10_);
         _loc9_.upperBound.y = Math.max(_loc3_.y,_loc11_);
         var _loc12_:Array = [];
         var _loc13_:int = 0;
         _loc12_[_loc13_++] = m_root;
         while(_loc13_ > 0)
         {
            _loc14_ = _loc12_[--_loc13_];
            if(_loc14_.aabb.testOverlap(_loc9_) != false)
            {
               _loc15_ = _loc14_.aabb.getCenter();
               _loc16_ = _loc14_.aabb.getExtents();
               _loc17_ = Math.abs(_loc6_.x * (_loc3_.x - _loc15_.x) + _loc6_.y * (_loc3_.y - _loc15_.y)) - _loc7_.x * _loc16_.x - _loc7_.y * _loc16_.y;
               if(_loc17_ <= 0)
               {
                  if(_loc14_.isLeaf())
                  {
                     _loc18_ = new b2RayCastInput();
                     _loc18_.p1 = input.p1;
                     _loc18_.p2 = input.p2;
                     _loc18_.maxFraction = input.maxFraction;
                     _loc8_ = callbackMethod(_loc18_,_loc14_);
                     if(_loc8_ == 0)
                     {
                        return;
                     }
                     _loc10_ = _loc3_.x + _loc8_ * (_loc4_.x - _loc3_.x);
                     _loc11_ = _loc3_.y + _loc8_ * (_loc4_.y - _loc3_.y);
                     _loc9_.lowerBound.x = Math.min(_loc3_.x,_loc10_);
                     _loc9_.lowerBound.y = Math.min(_loc3_.y,_loc11_);
                     _loc9_.upperBound.x = Math.max(_loc3_.x,_loc10_);
                     _loc9_.upperBound.y = Math.max(_loc3_.y,_loc11_);
                  }
                  else
                  {
                     _loc12_[_loc13_++] = _loc14_.child1;
                     _loc12_[_loc13_++] = _loc14_.child2;
                  }
               }
            }
         }
      }
      
      public function Query(callbackMethod:Function, aabb:b2AABB) : void
      {
         var _loc6_:* = null as b2DynamicTreeNode;
         if(m_root == null)
         {
            return;
         }
         var _loc3_:int = m_queryDepth;
         var _loc4_:Array = _loc3_ == 0 ? m_queryStack : [];
         m_queryDepth = _loc3_ + 1;
         var _loc5_:int = 0;
         _loc4_[_loc5_++] = m_root;
         while(_loc5_ > 0)
         {
            _loc6_ = _loc4_[--_loc5_];
            if(_loc6_.aabb.testOverlap(aabb))
            {
               if(_loc6_.isLeaf())
               {
                  if(!Boolean(callbackMethod(_loc6_)))
                  {
                     break;
                  }
               }
               else
               {
                  _loc4_[_loc5_++] = _loc6_.child1;
                  _loc4_[_loc5_++] = _loc6_.child2;
               }
            }
         }
         _loc4_.length = 0;
         m_queryDepth = _loc3_;
      }
      
      public function MoveProxy(proxy:b2DynamicTreeNode, aabb:b2AABB, displacement:b2Vec2) : Boolean
      {
         b2Settings.b2Assert(proxy.isLeaf());
         if(proxy.aabb.contains(aabb))
         {
            return false;
         }
         removeLeaf(proxy);
         var _loc4_:Number = b2Settings.b2_aabbExtension + b2Settings.b2_aabbMultiplier * (displacement.x > 0 ? displacement.x : -displacement.x);
         var _loc5_:Number = b2Settings.b2_aabbExtension + b2Settings.b2_aabbMultiplier * (displacement.y > 0 ? displacement.y : -displacement.y);
         proxy.aabb.lowerBound.x = aabb.lowerBound.x - _loc4_;
         proxy.aabb.lowerBound.y = aabb.lowerBound.y - _loc5_;
         proxy.aabb.upperBound.x = aabb.upperBound.x + _loc4_;
         proxy.aabb.upperBound.y = aabb.upperBound.y + _loc5_;
         insertLeaf(proxy);
         return true;
      }
      
      public function GetUserData(proxy:b2DynamicTreeNode) : *
      {
         return proxy.userData;
      }
      
      public function GetFatAABB(proxy:b2DynamicTreeNode) : b2AABB
      {
         return proxy.aabb;
      }
      
      public function EndAbandonedQueries() : void
      {
         if(m_queryDepth == 0 && int(m_queryStack.length) == 0)
         {
            return;
         }
         m_queryDepth = 0;
         m_queryStack = [];
      }
      
      public function DestroyProxy(proxy:b2DynamicTreeNode) : void
      {
         removeLeaf(proxy);
         freeNode(proxy);
      }
      
      public function CreateProxy(aabb:b2AABB, userData:*) : b2DynamicTreeNode
      {
         var _loc3_:b2DynamicTreeNode = allocateNode();
         var _loc4_:Number = b2Settings.b2_aabbExtension;
         var _loc5_:Number = b2Settings.b2_aabbExtension;
         _loc3_.aabb.lowerBound.x = aabb.lowerBound.x - _loc4_;
         _loc3_.aabb.lowerBound.y = aabb.lowerBound.y - _loc5_;
         _loc3_.aabb.upperBound.x = aabb.upperBound.x + _loc4_;
         _loc3_.aabb.upperBound.y = aabb.upperBound.y + _loc5_;
         _loc3_.userData = userData;
         insertLeaf(_loc3_);
         return _loc3_;
      }
   }
}

