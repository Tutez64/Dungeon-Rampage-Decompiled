package Pathfinding
{
   import flash.geom.Vector3D;
   
   public class AstarGridNode
   {
      
      public static const ASTAR_GRID_WIDTH:uint = 50;
      
      public static const GRID_HALF_WIDTH:Number = 0.5;
      
      public static const GRID_HALF_HEIGHT:Number = 0.5;
      
      public static const ASTAR_TILE_GRID_SIZE:uint = 18;
      
      public static const ASTAR_GRID_SIZE:uint = 216;
      
      public var Id:uint;
      
      public var Center:Vector3D;
      
      public var Neighbors:Array = [];
      
      public var Parent:uint;
      
      public var f:Number;
      
      public var g:Number;
      
      public var h:Number;
      
      public var visited:int;
      
      public function AstarGridNode(id:int)
      {
         super();
         Id = id;
         f = 0;
         g = 1;
         h = 0;
         visited = -1;
         Parent = 0;
         findNeighbors();
         Center = new Vector3D();
         Center.x = uint(Id % 216) * 50 + 50 / 2;
         Center.y = uint(Id / 216) * 50 + 50 / 2;
      }
      
      public function destroy() : void
      {
         Neighbors.length = 0;
         Neighbors = null;
         Center = null;
      }
      
      public function findNeighbors() : void
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc1_:int = 0;
         var _loc2_:int = 0;
         var _loc7_:* = 0;
         var _loc3_:uint = Id / 216;
         var _loc4_:uint = Id % 216;
         _loc5_ = -1;
         while(_loc5_ < 2)
         {
            _loc6_ = -1;
            while(_loc6_ < 2)
            {
               _loc1_ = _loc3_ + _loc5_;
               _loc2_ = _loc4_ + _loc6_;
               if(_loc1_ >= 0 && _loc2_ >= 0 && _loc1_ < 216 && _loc2_ < 216)
               {
                  _loc7_ = uint(_loc1_ * 216 + _loc2_);
                  if(_loc7_ != Id)
                  {
                     Neighbors.push(_loc1_ * 216 + _loc2_);
                  }
               }
               _loc6_++;
            }
            _loc5_++;
         }
      }
      
      public function costToNeighbor(y:uint) : Number
      {
         var _loc2_:uint = Math.abs(Id - y);
         if(_loc2_ > 216 + 1)
         {
            return 999999;
         }
         if(_loc2_ == 1 || _loc2_ == 150)
         {
            return 60;
         }
         return 85;
      }
   }
}

