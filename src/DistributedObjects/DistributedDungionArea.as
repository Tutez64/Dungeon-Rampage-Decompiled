package DistributedObjects
{
   import Actor.ActorGameObject;
   import Brain.Event.EventComponent;
   import Brain.Logger.Logger;
   import Brain.SceneGraph.SceneGraphComponent;
   import Events.CacheLoadRequestNpcEvent;
   import Facade.DBFacade;
   import GameMasterDictionary.GMAttack;
   import GeneratedCode.DistributedDungionAreaNetworkComponent;
   import GeneratedCode.IDistributedDungionArea;
   import GeneratedCode.InfiniteRewardData;
   import GeneratedCode.WeaponDetails;
   import GeneratedCode.swrapper;
   
   public class DistributedDungionArea extends Area implements IDistributedDungionArea
   {
      
      private var mNetworkComponent:DistributedDungionAreaNetworkComponent;
      
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
         var _loc2_:* = 0;
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
         var _loc2_:* = 0;
         mTileLibrary = new Vector.<String>();
         _loc2_ = 0;
         while(_loc2_ < val.length)
         {
            mTileLibrary.push(val[_loc2_].fileName);
            _loc2_++;
         }
      }
      
      public function calculateNetAttackDamage(attacker:ActorGameObject, target:ActorGameObject, attack:GMAttack, weapon:WeaponDetails) : Number
      {
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc5_:Number = 0;
         if(attack.StatOffsets != null)
         {
            _loc6_ = (weapon.power * mDBFacade.gameMaster.stat_BonusMultiplier.values[attack.StatOffsets.offence] + attacker.stats.values[attack.StatOffsets.offence]) * attacker.buffHandler.multiplier[attack.StatOffsets.offence];
            _loc6_ = _loc6_ * attack.DamageMod;
            _loc7_ = target.stats.values[attack.StatOffsets.defence] * target.buffHandler.multiplier[attack.StatOffsets.defence];
            _loc5_ = _loc6_ + _loc7_;
         }
         else
         {
            _loc5_ = weapon.power * attack.DamageMod;
         }
         return _loc5_;
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

