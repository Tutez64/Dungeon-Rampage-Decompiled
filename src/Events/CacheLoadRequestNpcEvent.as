package Events
{
   import flash.events.Event;
   
   public class CacheLoadRequestNpcEvent extends Event
   {
      
      public static const CACHE_LOAD_REQUEST:String = "Busterncpccahche_event";
      
      public var cacheNpc:Vector.<uint>;
      
      public var cacheSwf:Vector.<String>;
      
      public var tilelibraryname:Vector.<String>;
      
      public function CacheLoadRequestNpcEvent(cachenpc:Vector.<uint>, cacheswf:Vector.<String>, tilelibrary:Vector.<String>, bubbles:Boolean = false, cancelable:Boolean = false)
      {
         cacheSwf = cacheswf;
         cacheNpc = cachenpc;
         tilelibraryname = tilelibrary;
         super("Busterncpccahche_event",bubbles,cancelable);
      }
   }
}

