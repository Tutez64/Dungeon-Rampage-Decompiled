package GeneratedCode
{
   import Brain.GameObject.GameObject;
   
   public interface IDistributedDungionArea
   {
      
      function setNetworkComponentDistributedDungionArea(iface:DistributedDungionAreaNetworkComponent) : void;
      
      function postGenerate() : void;
      
      function getTrueObject() : GameObject;
      
      function destroy() : void;
      
      function tileLibrary(tileLibrary:Vector.<swrapper>) : void;
      
      function set cacheNpc(val:Vector.<uint>) : void;
      
      function set cacheSWC(val:Vector.<swrapper>) : void;
      
      function floorReward(mapReward:uint) : void;
      
      function floorEnding(timeUntilTransition:uint) : void;
      
      function dungeonEnding(timeUntilTransition:uint, victory:uint) : void;
      
      function floorfailing(timeUntilTransition:uint) : void;
      
      function tellClientInfiniteRewardData(avId:uint, avScore:uint, goldReward:uint, infiniteRewards:Vector.<InfiniteRewardData>) : void;
   }
}

