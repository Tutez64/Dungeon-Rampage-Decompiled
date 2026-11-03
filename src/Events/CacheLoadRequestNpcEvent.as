package Events
{
   import flash.events.Event;
   
   public class CacheLoadRequestNpcEvent extends Event
   {
      
      public static const CACHE_LOAD_REQUEST:String = "Busterncpccahche_event";
      
      public var cacheNpc:Vector.<uint>;
      
      public var cacheSwf:Vector.<String>;
      
      public var tileLibraryName:Vector.<String>;
      
      public function CacheLoadRequestNpcEvent(inCacheNpc:Vector.<uint>, inCacheSwf:Vector.<String>, inTileLibraryName:Vector.<String>, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         cacheSwf = inCacheSwf;
         cacheNpc = inCacheNpc;
         tileLibraryName = inTileLibraryName;
         super("Busterncpccahche_event",bubbles,cancelable);
      }
   }
}

