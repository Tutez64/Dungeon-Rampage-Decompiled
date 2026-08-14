package Dungeon
{
   import Brain.Utils.MemoryTracker;
   import DistributedObjects.DistributedDungeonFloor;
   import Facade.DBFacade;
   import Floor.FloorObject;
   import GeneratedCode.DungeonTileUsage;
   import flash.geom.Vector3D;
   import org.as3commons.collections.Set;
   import org.as3commons.collections.framework.IIterator;
   
   public class DungeonFloorFactory
   {
      
      protected var mTileNetworkComponents:Vector.<DungeonTileUsage>;
      
      protected var mTilesBuiltCallback:Function;
      
      protected var mNumTilesCreated:uint = 0;
      
      protected var mTileGrid:TileGrid;
      
      protected var mTileFactory:TileFactory;
      
      protected var mDBFacade:DBFacade;
      
      protected var mDistributedDungeonFloor:DistributedDungeonFloor;
      
      public function DungeonFloorFactory(distributedDungeonFloor:DistributedDungeonFloor, initGridCallback:Function, facade:DBFacade, tileLibraryPath:String)
      {
         super();
         mDBFacade = facade;
         mDistributedDungeonFloor = distributedDungeonFloor;
         mTileFactory = new TileFactory(mDBFacade,mDBFacade.libraryJson,mDBFacade.getTileLibraryJson(tileLibraryPath));
         MemoryTracker.track(mTileFactory,"TileFactory - created in DungeonFloorFactory.constructor()");
         mTileGrid = new TileGrid();
         MemoryTracker.track(mTileGrid,"TileGrid - created in DungeonFloorFactory.constructor()");
         initGridCallback(mTileGrid);
      }
      
      public function destroy() : void
      {
         mTileNetworkComponents = null;
         mTilesBuiltCallback = null;
         mTileGrid.destroy();
         mTileGrid = null;
         mTileFactory.destroy();
         mTileFactory = null;
         mDistributedDungeonFloor = null;
         mDBFacade = null;
      }
      
      public function get tileFactory() : TileFactory
      {
         return mTileFactory;
      }
      
      public function buildDungeonFloor(tileNetworkComponents:Vector.<DungeonTileUsage>, tilesBuiltCallback:Function) : void
      {
         mTileNetworkComponents = tileNetworkComponents;
         mTilesBuiltCallback = tilesBuiltCallback;
         buildGrid(tileNetworkComponents);
         AddFillerTiles();
      }
      
      private function AddFillerTilesHelper(pos:Vector3D, x:Number, y:Number) : void
      {
         var _loc4_:DungeonTileUsage = null;
         pos.x += x * 900;
         pos.y += y * 900;
         if(mTileGrid.isPositionOpenForATile(pos))
         {
            _loc4_ = new DungeonTileUsage();
            _loc4_.tileId = mTileFactory.mFillerTiles[0].id;
            _loc4_.x = pos.x;
            _loc4_.y = pos.y;
            mTileFactory.buildTile(_loc4_,addToGrid,tileInitialized,mDistributedDungeonFloor);
         }
      }
      
      private function AddFillerTiles() : void
      {
         var _loc1_:* = undefined;
         if(mTileFactory.mFillerTiles.length > 0)
         {
            _loc1_ = mTileGrid.getNonFillTilePositions();
            for each(var _loc2_:Vector3D in _loc1_)
            {
               AddFillerTilesHelper(_loc2_.clone(),1,0);
               AddFillerTilesHelper(_loc2_.clone(),1,1);
               AddFillerTilesHelper(_loc2_.clone(),1,-1);
               AddFillerTilesHelper(_loc2_.clone(),0,1);
               AddFillerTilesHelper(_loc2_.clone(),0,-1);
               AddFillerTilesHelper(_loc2_.clone(),-1,1);
               AddFillerTilesHelper(_loc2_.clone(),-1,0);
               AddFillerTilesHelper(_loc2_.clone(),-1,-1);
            }
         }
      }
      
      protected function buildGrid(tileNetworkComponents:Vector.<DungeonTileUsage>) : void
      {
         var _loc2_:* = 0;
         _loc2_ = 0;
         while(_loc2_ < tileNetworkComponents.length)
         {
            mTileFactory.buildTile(tileNetworkComponents[_loc2_],addToGrid,tileInitialized,mDistributedDungeonFloor);
            _loc2_++;
         }
      }
      
      protected function addToGrid(tile:Tile) : void
      {
         var _loc5_:Set = null;
         var _loc2_:IIterator = null;
         var _loc4_:FloorObject = null;
         var _loc3_:Tile = mTileGrid.getTileAtPosition(tile.position);
         if(_loc3_ != null)
         {
            _loc5_ = _loc3_.floorObjects;
            _loc2_ = _loc5_.iterator();
            while(_loc2_.hasNext())
            {
               _loc4_ = _loc2_.next();
               if(!_loc3_.hasOwnedFloorObject(_loc4_))
               {
                  _loc4_.tile = tile;
               }
            }
            mTileGrid.removeTileAtPosition(tile.position);
         }
         mTileGrid.setTileAtPosition(tile.position,tile);
      }
      
      protected function tileInitialized(tile:Tile) : void
      {
         mTileGrid.setTileAtPosition(tile.position,tile);
         mDistributedDungeonFloor.astarGrids.InitTileAstarGrids(tile.position.x / 900 + 1,tile.position.y / 900 + 1);
         mNumTilesCreated = mNumTilesCreated + 1;
         if(mNumTilesCreated == mTileNetworkComponents.length)
         {
            mTilesBuiltCallback(mTileGrid);
         }
      }
   }
}

