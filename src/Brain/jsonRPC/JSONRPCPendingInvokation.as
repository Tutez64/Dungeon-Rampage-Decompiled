package Brain.jsonRPC
{
   import Brain.Event.EventListeners;
   import Brain.Utils.MemoryTracker;
   import Collections.IMapIterator;
   import Collections.Map;
   import flash.events.EventDispatcher;
   import flash.net.URLStream;
   
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
         destroy();
      }
      
      public function handleResult(r:*) : void
      {
         if(mDestroyCallback != null)
         {
            mDestroyCallback(this);
         }
         mDestroyCallback = null;
         this.dispatchEvent(new ResultEvent(r));
         destroy();
      }
      
      public function addDestroyCallback(f:Function) : void
      {
         mDestroyCallback = f;
      }
      
      public function addListener(eventName:String, callback:Function) : void
      {
         mRegisteredListeners.add(eventName,callback);
         EventListeners.add(this,eventName,callback);
      }
      
      public function destroy() : void
      {
         removeAllListeners();
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
         var _loc2_:Function = null;
         var _loc1_:IMapIterator = mRegisteredListeners.iterator() as IMapIterator;
         while(_loc1_.hasNext())
         {
            _loc2_ = _loc1_.next();
            EventListeners.remove(this,_loc1_.key,_loc2_);
         }
         mRegisteredListeners.clear();
      }
   }
}

