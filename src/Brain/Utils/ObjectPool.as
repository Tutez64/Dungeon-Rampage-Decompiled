package Brain.Utils
{
   import flash.utils.Dictionary;
   
   public class ObjectPool
   {
      
      protected var mPool:Dictionary = new Dictionary();
      
      private var mStats:Dictionary = new Dictionary();
      
      public function ObjectPool()
      {
         super();
         MemoryTracker.track(mPool,"Dictionary - pool storage in ObjectPool()","pool");
      }
      
      public function toString() : String
      {
         var _loc2_:Vector.<IPoolable> = undefined;
         var _loc1_:String = "";
         for(var _loc3_:String in mPool)
         {
            _loc2_ = mPool[_loc3_];
            _loc1_ += _loc2_.length.toString() + "\t: " + _loc3_ + "\n";
         }
         return _loc1_;
      }
      
      protected function construct(parameters:Array) : IPoolable
      {
         return null;
      }
      
      protected function reset(poolable:IPoolable, parameters:Array) : void
      {
      }
      
      protected function getPoolKey(parameters:Array) : String
      {
         return "";
      }
      
      private function getPool(key:String) : Vector.<IPoolable>
      {
         var _loc2_:Vector.<IPoolable> = undefined;
         if(key in mPool)
         {
            return mPool[key];
         }
         _loc2_ = new Vector.<IPoolable>();
         mPool[key] = _loc2_;
         MemoryTracker.track(_loc2_,"Vector.<IPoolable> - pool key \'" + key + "\' in ObjectPool.getPool()","pool");
         return _loc2_;
      }
      
      private function statsFor(key:String) : PoolStats
      {
         var _loc2_:PoolStats = mStats[key];
         if(!_loc2_)
         {
            _loc2_ = new PoolStats();
            mStats[key] = _loc2_;
         }
         return _loc2_;
      }
      
      public function checkout(... rest) : IPoolable
      {
         var _loc2_:IPoolable = null;
         var _loc3_:Boolean = false;
         var _loc6_:String = getPoolKey(rest);
         var _loc5_:Vector.<IPoolable> = getPool(_loc6_);
         var _loc4_:PoolStats = statsFor(_loc6_);
         _loc4_.checkouts++;
         if(_loc5_.length)
         {
            _loc2_ = _loc5_.pop();
            reset(_loc2_,rest);
            _loc3_ = false;
            _loc4_.reuses++;
         }
         else
         {
            _loc2_ = construct(rest);
            _loc3_ = true;
            _loc4_.constructed++;
         }
         _loc2_.postCheckout(_loc3_);
         return _loc2_;
      }
      
      public function checkin(object:IPoolable) : void
      {
         object.postCheckin();
         var _loc4_:String = object.getPoolKey();
         var _loc3_:Vector.<IPoolable> = getPool(_loc4_);
         var _loc2_:PoolStats = statsFor(_loc4_);
         _loc2_.checkins++;
         _loc3_.push(object);
      }
      
      public function stats() : Array
      {
         var _loc1_:PoolStats = null;
         var _loc2_:Vector.<IPoolable> = undefined;
         var _loc3_:Array = [];
         for(var _loc4_:String in mStats)
         {
            _loc1_ = mStats[_loc4_];
            _loc2_ = mPool[_loc4_];
            _loc3_.push({
               "key":_loc4_,
               "pooled":(_loc2_ ? _loc2_.length : 0),
               "constructed":_loc1_.constructed,
               "checkouts":_loc1_.checkouts,
               "reuses":_loc1_.reuses,
               "checkins":_loc1_.checkins,
               "out":_loc1_.checkouts - _loc1_.checkins,
               "dupes":_loc1_.dupes
            });
         }
         _loc3_.sortOn("key");
         return _loc3_;
      }
      
      public function clear() : void
      {
         for each(var _loc1_:Vector.<IPoolable> in mPool)
         {
            for each(var _loc2_:IPoolable in _loc1_)
            {
               _loc2_.destroy();
            }
         }
         mPool = new Dictionary();
         mStats = new Dictionary();
      }
      
      public function destroy() : void
      {
         this.clear();
         mPool = null;
         mStats = null;
      }
   }
}

class PoolStats
{
   
   public var constructed:int;
   
   public var checkouts:int;
   
   public var reuses:int;
   
   public var checkins:int;
   
   public var dupes:int;
   
   public function PoolStats()
   {
      super();
   }
}
