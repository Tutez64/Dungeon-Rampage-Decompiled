package starling.events
{
   import flash.utils.Dictionary;
   import starling.core.starling_internal;
   import starling.display.DisplayObject;
   
   use namespace starling_internal;
   
   public class EventDispatcher
   {
      
      private static var sBubbleChains:Array = [];
      
      private var _eventListeners:Dictionary;
      
      private var _eventStack:Vector.<String> = new Vector.<String>(0);
      
      public function EventDispatcher()
      {
         super();
      }
      
      public function addEventListener(type:String, listener:Function) : void
      {
         if(_eventListeners == null)
         {
            _eventListeners = new Dictionary();
         }
         var _loc3_:Array = _eventListeners[type] as Array;
         if(_loc3_ == null)
         {
            _eventListeners[type] = [listener];
         }
         else if(_loc3_.indexOf(listener) == -1)
         {
            _loc3_[_loc3_.length] = listener;
         }
      }
      
      public function removeEventListener(type:String, listener:Function) : void
      {
         var _loc3_:Array = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc7_:Array = null;
         var _loc6_:int = 0;
         if(_eventListeners)
         {
            _loc3_ = _eventListeners[type] as Array;
            _loc4_ = int(_loc3_ ? _loc3_.length : 0);
            if(_loc4_ > 0)
            {
               _loc5_ = _loc3_.indexOf(listener);
               if(_loc5_ != -1)
               {
                  if(_eventStack.indexOf(type) == -1)
                  {
                     _loc3_.removeAt(_loc5_);
                  }
                  else
                  {
                     _loc7_ = _loc3_.slice(0,_loc5_);
                     _loc6_ = _loc5_ + 1;
                     while(_loc6_ < _loc4_)
                     {
                        _loc7_[_loc6_ - 1] = _loc3_[_loc6_];
                        _loc6_++;
                     }
                     _eventListeners[type] = _loc7_;
                  }
               }
            }
         }
      }
      
      public function removeEventListeners(type:String = null) : void
      {
         if(type && _eventListeners)
         {
            delete _eventListeners[type];
         }
         else
         {
            _eventListeners = null;
         }
      }
      
      public function dispatchEvent(event:Event) : void
      {
         var _loc2_:Boolean = event.bubbles;
         if(!_loc2_ && (_eventListeners == null || !(event.type in _eventListeners)))
         {
            return;
         }
         var _loc3_:EventDispatcher = event.target;
         event.setTarget(this);
         if(_loc2_ && this is DisplayObject)
         {
            bubbleEvent(event);
         }
         else
         {
            invokeEvent(event);
         }
         if(_loc3_)
         {
            event.setTarget(_loc3_);
         }
      }
      
      internal function invokeEvent(event:Event) : Boolean
      {
         var _loc6_:int = 0;
         var _loc5_:Function = null;
         var _loc2_:int = 0;
         var _loc3_:Array = _eventListeners ? _eventListeners[event.type] as Array : null;
         var _loc4_:int = int(_loc3_?.length);
         if(_loc4_)
         {
            event.setCurrentTarget(this);
            _eventStack[_eventStack.length] = event.type;
            _loc6_ = 0;
            while(_loc6_ < _loc4_)
            {
               _loc5_ = _loc3_[_loc6_] as Function;
               _loc2_ = _loc5_.length;
               if(_loc2_ == 0)
               {
                  _loc5_();
               }
               else if(_loc2_ == 1)
               {
                  _loc5_(event);
               }
               else
               {
                  _loc5_(event,event.data);
               }
               if(event.stopsImmediatePropagation)
               {
                  _eventStack.pop();
                  return true;
               }
               _loc6_++;
            }
            _eventStack.pop();
            return event.stopsPropagation;
         }
         return false;
      }
      
      internal function bubbleEvent(event:Event) : void
      {
         var _loc2_:Vector.<EventDispatcher> = undefined;
         var _loc4_:int = 0;
         var _loc5_:Boolean = false;
         var _loc6_:DisplayObject = this as DisplayObject;
         var _loc3_:int = 1;
         if(sBubbleChains.length > 0)
         {
            _loc2_ = sBubbleChains.pop();
            _loc2_[0] = _loc6_;
         }
         else
         {
            _loc2_ = new <EventDispatcher>[_loc6_];
         }
         while(true)
         {
            _loc6_ = _loc6_.parent;
            if(_loc6_ == null)
            {
               break;
            }
            _loc2_[_loc3_++] = _loc6_;
         }
         _loc4_ = 0;
         while(_loc4_ < _loc3_)
         {
            _loc5_ = _loc2_[_loc4_].invokeEvent(event);
            if(_loc5_)
            {
               break;
            }
            _loc4_++;
         }
         _loc2_.length = 0;
         sBubbleChains[sBubbleChains.length] = _loc2_;
      }
      
      public function dispatchEventWith(type:String, bubbles:Boolean = false, data:Object = null) : void
      {
         var _loc4_:Event = null;
         if(bubbles || hasEventListener(type))
         {
            _loc4_ = Event.fromPool(type,bubbles,data);
            dispatchEvent(_loc4_);
            Event.toPool(_loc4_);
         }
      }
      
      public function hasEventListener(type:String, listener:Function = null) : Boolean
      {
         var _loc3_:Array = _eventListeners ? _eventListeners[type] as Array : null;
         if(_loc3_ == null)
         {
            return false;
         }
         if(listener != null)
         {
            return _loc3_.indexOf(listener) != -1;
         }
         return _loc3_.length != 0;
      }
   }
}

