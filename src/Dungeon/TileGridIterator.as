package Dungeon
{
   public class TileGridIterator
   {
      
      private var mTiles:Vector.<Tile>;
      
      private var mIndex:uint = 0;
      
      private var mOnlyOnStage:Boolean;
      
      public function TileGridIterator(tiles:Vector.<Tile>, onlyOnStage:Boolean)
      {
         super();
         mTiles = tiles;
         mOnlyOnStage = onlyOnStage;
         reset();
      }
      
      public function hasNext() : Boolean
      {
         return mIndex < mTiles.length;
      }
      
      public function next() : Tile
      {
         var _loc1_:Tile = mTiles[mIndex++];
         seekNext();
         return _loc1_;
      }
      
      private function seekNext() : void
      {
         while(mIndex < mTiles.length && (mTiles[mIndex] == null || mOnlyOnStage && !mTiles[mIndex].isOnStage))
         {
            mIndex = mIndex + 1;
         }
      }
      
      public function reset() : void
      {
         mIndex = 0;
         seekNext();
      }
   }
}

