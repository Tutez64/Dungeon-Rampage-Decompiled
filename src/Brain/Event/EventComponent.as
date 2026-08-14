package Brain.Event
{
   import Brain.Component.Component;
   import Brain.Facade.Facade;
   import Brain.Logger.Logger;
   import Brain.Utils.MemoryTracker;
   import Brain.Utils.Receipt;
   import flash.events.Event;
   import org.as3commons.collections.Map;
   import org.as3commons.collections.framework.IMapIterator;
   
   public class EventComponent extends Component
   {
      
      protected var mRegisteredListeners:Map = new Map();
      
      public function EventComponent(facade:Facade)
      {
         super(facade);
         mFacade = facade;
      }
      
      public function addListener(eventName:String, callback:Function) : Receipt
      {
         var _loc4_:Receipt = null;
         var _loc3_:Boolean = mRegisteredListeners.add(eventName,callback);
         if(_loc3_)
         {
            mFacade.eventManager.addEventListener(eventName,callback);
            _loc4_ = new Receipt(removeListener);
            MemoryTracker.track(_loc4_,"Receipt - EventComponent listener: " + eventName,"brain");
            return _loc4_;
         }
         Logger.warn("Failed duplicate addListener for eventName: " + eventName);
         return null;
      }
      
      public function removeListener(eventName:String) : void
      {
         var _loc2_:Function = mRegisteredListeners.removeKey(eventName);
         if(_loc2_ == null)
         {
            return;
         }
         mFacade.eventManager.removeEventListener(eventName,_loc2_);
      }
      
      public function dispatchEvent(eventObj:Event) : void
      {
         mFacade.eventManager.dispatchEvent(eventObj);
      }
      
      override public function destroy() : void
      {
         removeAllListeners();
         mRegisteredListeners = null;
         super.destroy();
      }
      
      public function removeAllListeners() : void
      {
         var _loc2_:String = null;
         var _loc3_:Function = null;
         var _loc1_:IMapIterator = mRegisteredListeners.iterator() as IMapIterator;
         while(_loc1_.hasNext())
         {
            _loc3_ = _loc1_.next();
            _loc2_ = _loc1_.key;
            mFacade.eventManager.removeEventListener(_loc2_,_loc3_);
         }
         mRegisteredListeners.clear();
      }
   }
}

