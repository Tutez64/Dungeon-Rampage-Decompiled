package Pathfinding
{
   public dynamic class PriorityQueue extends Array
   {
      
      public function PriorityQueue()
      {
         super();
      }
      
      override AS3 function push(... rest) : uint
      {
         var _loc2_:uint = super.push(rest[0]);
         this.sort(compare);
         return _loc2_;
      }
      
      public function front() : AstarGridNode
      {
         return this[0];
      }
      
      override AS3 function pop() : *
      {
         return splice(0,1);
      }
      
      public function contains(node:AstarGridNode) : Boolean
      {
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ != length)
         {
            if(this[_loc2_] == node)
            {
               return true;
            }
            _loc2_++;
         }
         return false;
      }
      
      private function compare(nodeA:AstarGridNode, nodeB:AstarGridNode) : int
      {
         if(nodeA.f < nodeB.f)
         {
            return -1;
         }
         if(nodeA.f > nodeB.f)
         {
            return 1;
         }
         return 0;
      }
   }
}

