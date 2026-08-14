package Brain.jsonRPC
{
   import Brain.Utils.MemoryTracker;
   import flash.events.EventDispatcher;
   import flash.net.URLStream;
   import org.as3commons.collections.Map;
   import org.as3commons.collections.framework.IMapIterator;
   
   public class JSONRPCPendingInvokation extends EventDispatcher
   {
      
      protected var mRegisteredListeners:Map = new Map();
      
      protected var mURLStream:URLStream;
      
      protected var mDestroyCallback:Function;
      
      public function JSONRPCPendingInvokation(stream:URLStream)
      {
         mURLStream = stream;
         super(this);
         MemoryTracker.track(mRegisteredListeners,"Map - registered listeners in JSONRPCPendingInvokation()","brain");
      }
      
      public function handleError(e:Error) : void
      {
         if(mDestroyCallback != null)
         {
            mDestroyCallback(this);
         }
         mDestroyCallback = null;
         this.dispatchEvent(new FaultEvent(e));
         destory();
      }
      
      public function handleResult(r:*) : void
      {
         if(mDestroyCallback != null)
         {
            mDestroyCallback(this);
         }
         mDestroyCallback = null;
         this.dispatchEvent(new ResultEvent(r));
         destory();
      }
      
      public function addDestroyCallback(f:Function) : void
      {
         mDestroyCallback = f;
      }
      
      public function addListener(eventName:String, callback:Function) : void
      {
         mRegisteredListeners.add(eventName,callback);
         addEventListener(eventName,callback);
      }
      
      public function removeListener(eventName:String) : void
      {
         if(!mRegisteredListeners.has(eventName))
         {
            return;
         }
         var _loc2_:Function = mRegisteredListeners.itemFor(eventName);
         removeEventListener(eventName,_loc2_);
         mRegisteredListeners.remove(eventName);
      }
      
      public function destory() : void
      {
         removeAllListeners();
         mRegisteredListeners.clear();
         mRegisteredListeners = null;
         mURLStream.close();
         mURLStream = null;
         if(mDestroyCallback != null)
         {
            mDestroyCallback(this);
         }
         mDestroyCallback = null;
      }
      
      public function removeAllListeners() : void
      {
         var _loc2_:String = null;
         var _loc1_:IMapIterator = mRegisteredListeners.iterator() as IMapIterator;
         while(_loc1_.hasNext())
         {
            _loc1_.next();
            _loc2_ = _loc1_.current as String;
            removeListener(_loc2_);
         }
      }
   }
}

