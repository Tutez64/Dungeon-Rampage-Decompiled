package Effects
{
   import Brain.Utils.IPoolable;
   import Brain.Utils.MemoryTracker;
   import Brain.Utils.ObjectPool;
   import Facade.DBFacade;
   
   public class EffectPool extends ObjectPool
   {
      
      public function EffectPool()
      {
         super();
      }
      
      override protected function getPoolKey(parameters:Array) : String
      {
         var _loc3_:DBFacade = parameters[0];
         var _loc2_:String = parameters[1];
         var _loc4_:String = parameters[2];
         return _loc2_ + ":" + _loc4_;
      }
      
      override protected function reset(poolable:IPoolable, parameters:Array) : void
      {
         var _loc3_:EffectGameObject = poolable as EffectGameObject;
         _loc3_.setAssetLoadedCallback(parameters[3]);
      }
      
      override protected function construct(parameters:Array) : IPoolable
      {
         var _loc4_:DBFacade = parameters[0];
         var _loc3_:String = parameters[1];
         var _loc5_:String = parameters[2];
         var _loc6_:Function = parameters[3];
         var _loc2_:EffectGameObject = new EffectGameObject(_loc4_,_loc3_,_loc5_,1,0,_loc6_);
         MemoryTracker.track(_loc2_,"EffectGameObject \'" + _loc3_ + ":" + _loc5_ + "\' - created in EffectPool.construct()","pool");
         return _loc2_;
      }
   }
}

