package DistributedObjects
{
   import Brain.Event.EventComponent;
   import Brain.Logger.Logger;
   import Brain.SceneGraph.SceneGraphComponent;
   import Events.CacheLoadRequestNpcEvent;
   import Facade.DBFacade;
   import GeneratedCode.DistributedDungionAreaNetworkComponent;
   import GeneratedCode.IDistributedDungionArea;
   import GeneratedCode.InfiniteRewardData;
   import GeneratedCode.swrapper;
   
   public class DistributedDungionArea extends Area implements IDistributedDungionArea
   {
      
      private var mNetworkComponent:DistributedDungionAreaNetworkComponent;
      
      private var mTeammateRevivesThisDungeon:int = 0;
      
      private var mTileLibrary:Vector.<String>;
      
      protected var mSceneGraphComponent:SceneGraphComponent;
      
      protected var mEventComponent:EventComponent;
      
      public var mCacheNpc:Vector.<uint>;
      
      public var mCacheSfc:Vector.<String>;
      
      public function DistributedDungionArea(facade:DBFacade, remoteId:uint = 0)
      {
         Logger.debug("New  DistributedDungionArea******************************");
         super(facade,remoteId);
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade,"DistributedDungionArea");
         mCacheNpc = new Vector.<uint>();
         mCacheSfc = new Vector.<String>();
         mEventComponent = new EventComponent(facade);
      }
      
      public function set cacheNpc(val:Vector.<uint>) : void
      {
         mCacheNpc = val;
      }
      
      public function set cacheSWC(val:Vector.<swrapper>) : void
      {
         var _loc2_:uint = 0;
         mCacheSfc = new Vector.<String>();
         _loc2_ = 0;
         while(_loc2_ < val.length)
         {
            mCacheSfc.push(DBFacade.buildFullDownloadPath(val[_loc2_].fileName));
            _loc2_++;
         }
      }
      
      public function setNetworkComponentDistributedDungionArea(iface:DistributedDungionAreaNetworkComponent) : void
      {
         mNetworkComponent = iface;
      }
      
      public function postGenerate() : void
      {
         mEventComponent.dispatchEvent(new CacheLoadRequestNpcEvent(mCacheNpc,mCacheSfc,mTileLibrary));
      }
      
      public function tileLibrary(val:Vector.<swrapper>) : void
      {
         var _loc2_:uint = 0;
         mTileLibrary = new Vector.<String>();
         _loc2_ = 0;
         while(_loc2_ < val.length)
         {
            mTileLibrary.push(val[_loc2_].fileName);
            _loc2_++;
         }
      }
      
      public function countTeammateRevive() : int
      {
         return ++mTeammateRevivesThisDungeon;
      }
      
      public function floorReward(mapReward:uint) : void
      {
      }
      
      public function floorEnding(timeUntilTransition:uint) : void
      {
         if(mActiveFloor == null)
         {
            return;
         }
         mActiveFloor.floorEnding(timeUntilTransition);
      }
      
      public function floorfailing(timeUntilTransition:uint) : void
      {
         if(mActiveFloor == null)
         {
            return;
         }
         mActiveFloor.floorFailing(timeUntilTransition);
      }
      
      public function tellClientInfiniteRewardData(avId:uint, avScore:uint, goldReward:uint, infiniteRewards:Vector.<InfiniteRewardData>) : void
      {
         if(mDBFacade.dbAccountInfo.activeAvatarId != avId)
         {
            return;
         }
         mInfiniteStartScore = avScore;
         mInfiniteFloorGold = goldReward;
         mInfiniteRewardData = infiniteRewards;
         for each(var _loc5_:InfiniteRewardData in infiniteRewards)
         {
         }
      }
      
      public function dungeonEnding(timeUntilTransition:uint, victory:uint) : void
      {
         if(mActiveFloor == null)
         {
            return;
         }
         if(victory)
         {
            mActiveFloor.victory();
         }
         else
         {
            mActiveFloor.defeat();
         }
      }
      
      override public function destroy() : void
      {
         mEventComponent.destroy();
         mEventComponent = null;
         mCacheNpc = null;
         super.destroy();
      }
   }
}

