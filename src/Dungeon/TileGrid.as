package Dungeon
{
   import Brain.Logger.Logger;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   
   public class TileGrid
   {
      
      public static const DEFAULT_GRID_WIDTH:uint = 12;
      
      public static const DEFAULT_GRID_HEIGHT:uint = 12;
      
      private static const MAX_VISIBLE_TILES:uint = 16;
      
      private var mGridWidth:uint;
      
      private var mGridHeight:uint;
      
      private var mTiles:Vector.<Tile>;
      
      private var mEmptyTileColiders:Vector.<RectangleNavCollider>;
      
      public function TileGrid(gridWidth:uint = 12, gridHeight:uint = 12)
      {
         var _loc4_:* = 0;
         var _loc3_:* = 0;
         super();
         mGridWidth = gridWidth;
         mGridHeight = gridHeight;
         mTiles = new Vector.<Tile>();
         mEmptyTileColiders = new Vector.<RectangleNavCollider>();
         _loc4_ = 0;
         while(_loc4_ < mGridHeight)
         {
            _loc3_ = 0;
            while(_loc3_ < mGridWidth)
            {
               mTiles.push(null);
               mEmptyTileColiders.push(null);
               _loc3_++;
            }
            _loc4_++;
         }
      }
      
      public function getNonFillTilePositions() : Vector.<Vector3D>
      {
         var _loc1_:Vector.<Vector3D> = new Vector.<Vector3D>();
         for each(var _loc2_:Tile in mTiles)
         {
            if(_loc2_ && !_loc2_.isFiller())
            {
               _loc1_.push(_loc2_.position.clone());
            }
         }
         return _loc1_;
      }
      
      public function isPositionOpenForATile(pos:Vector3D) : Boolean
      {
         if(getTileIndexAtPosition(pos) >= 0)
         {
            return getTileAtPosition(pos) == null;
         }
         return false;
      }
      
      private function setTileAtIndex(i:uint, j:uint, tile:Tile) : void
      {
         if(i >= mGridWidth || j >= mGridHeight)
         {
            throw new Error("index out of range");
         }
         mTiles[i + j * mGridWidth] = tile;
         var _loc4_:RectangleNavCollider = mEmptyTileColiders[i + j * mGridWidth];
         if(_loc4_ != null)
         {
            _loc4_.destroy();
            mEmptyTileColiders[i + j * mGridWidth] = null;
         }
      }
      
      public function SetEmptyColliderAtIndex(i:uint, j:uint, col:RectangleNavCollider) : void
      {
         if(i >= mGridWidth || j >= mGridHeight)
         {
            throw new Error("index out of range");
         }
         mEmptyTileColiders[i + j * mGridWidth] = col;
      }
      
      public function getEmptyColliderAtIndex(i:uint, j:uint) : RectangleNavCollider
      {
         if(i >= mGridWidth || j >= mGridHeight)
         {
            return null;
         }
         return mEmptyTileColiders[i + j * mGridWidth];
      }
      
      public function setTileAtPosition(pos:Vector3D, tile:Tile) : void
      {
         if(pos.x < -900 || pos.y < -900)
         {
            Logger.error("setTileAtPosition: position must be positive: " + pos.toString());
            return;
         }
         var _loc3_:uint = (pos.x + 900) / 900;
         var _loc4_:uint = (pos.y + 900) / 900;
         setTileAtIndex(_loc3_,_loc4_,tile);
      }
      
      public function getTileAtIndex(i:uint, j:uint) : Tile
      {
         if(i >= mGridWidth || j >= mGridHeight)
         {
            return null;
         }
         return mTiles[i + j * mGridWidth];
      }
      
      public function getTileAtPosition(pos:Vector3D) : Tile
      {
         if(pos.x < -900 || pos.y < -900)
         {
            return null;
         }
         var _loc2_:uint = (pos.x + 900) / 900;
         var _loc3_:uint = (pos.y + 900) / 900;
         return getTileAtIndex(_loc2_,_loc3_);
      }
      
      public function getTileIndexAtPosition(pos:Vector3D) : int
      {
         if(pos.x < -900 || pos.y < -900)
         {
            return -1;
         }
         var _loc2_:uint = (pos.x + 900) / 900;
         var _loc3_:uint = (pos.y + 900) / 900;
         if(_loc2_ >= mGridWidth || _loc3_ >= mGridHeight)
         {
            return -1;
         }
         return _loc2_ + _loc3_ * mGridWidth;
      }
      
      public function getVisibleTiles(rect:Rectangle) : Vector.<Tile>
      {
         var _loc3_:Tile = null;
         var _loc4_:int = 0;
         var _loc2_:int = 0;
         var _loc5_:Vector.<Tile> = new Vector.<Tile>();
         _loc4_ = 0;
         _loc2_ = int(mTiles.length);
         while(_loc4_ < _loc2_)
         {
            _loc3_ = mTiles[_loc4_];
            if(_loc3_ && _loc3_.bounds.intersects(rect))
            {
               _loc5_.push(_loc3_);
            }
            _loc4_++;
         }
         if(_loc5_.length > 16)
         {
            Logger.warn("getVisibleTiles: found " + _loc5_.length + " visible. Something wrong?");
         }
         return _loc5_;
      }
      
      public function iterator(onlyOnStage:Boolean = false) : TileGridIterator
      {
         return new TileGridIterator(mTiles,onlyOnStage);
      }
      
      public function removeAllFromWorld() : void
      {
         for each(var _loc1_:Tile in mTiles)
         {
            if(_loc1_)
            {
               _loc1_.destroy();
            }
         }
      }
      
      public function removeTileAtPosition(pos:Vector3D) : void
      {
         var _loc2_:Number = getTileIndexAtPosition(pos);
         if(_loc2_ >= 0)
         {
            if(mTiles[_loc2_] != null)
            {
               mTiles[_loc2_].removeFromStage();
               mTiles[_loc2_].destroy();
            }
            mTiles[_loc2_] = null;
         }
      }
      
      public function destroy() : void
      {
         var _loc2_:* = 0;
         var _loc1_:RectangleNavCollider = null;
         removeAllFromWorld();
         if(mEmptyTileColiders)
         {
            _loc2_ = 0;
            while(_loc2_ < mEmptyTileColiders.length)
            {
               _loc1_ = mEmptyTileColiders[_loc2_];
               if(_loc1_)
               {
                  _loc1_.destroy();
                  _loc1_ = null;
               }
               _loc2_++;
            }
            mEmptyTileColiders.length = 0;
            mEmptyTileColiders = null;
         }
         mTiles = null;
      }
   }
}

