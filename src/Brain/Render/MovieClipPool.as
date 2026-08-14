package Brain.Render
{
   import Brain.AssetRepository.SwfAsset;
   import Brain.Facade.Facade;
   import Brain.Utils.IPoolable;
   import Brain.Utils.MemoryTracker;
   import Brain.Utils.ObjectPool;
   
   public class MovieClipPool extends ObjectPool
   {
      
      public function MovieClipPool()
      {
         super();
      }
      
      override protected function getPoolKey(parameters:Array) : String
      {
         var _loc3_:Facade = parameters[0];
         var _loc2_:String = SwfAsset(parameters[1]).swfPath;
         var _loc4_:String = parameters[2];
         return _loc2_ + ":" + _loc4_;
      }
      
      override protected function construct(parameters:Array) : IPoolable
      {
         var _loc3_:Facade = parameters[0];
         var _loc4_:SwfAsset = parameters[1];
         var _loc2_:String = _loc4_.swfPath;
         var _loc5_:String = parameters[2];
         var _loc6_:Class = _loc4_.getClass(_loc5_);
         var _loc7_:MovieClipRenderController = new MovieClipRenderController(_loc3_,new _loc6_(),null,_loc2_ + ":" + _loc5_);
         _loc7_.swfPath = _loc2_;
         _loc7_.className = _loc5_;
         MemoryTracker.track(_loc7_,"MovieClipRenderController swf=" + _loc2_ + " class=" + _loc5_ + " - created in MovieClipPool.construct()","pool");
         return _loc7_;
      }
   }
}

