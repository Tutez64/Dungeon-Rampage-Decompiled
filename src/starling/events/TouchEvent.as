package starling.events
{
   import starling.core.starling_internal;
   import starling.display.DisplayObject;
   
   use namespace starling_internal;
   
   public class TouchEvent extends Event
   {
      
      public static const TOUCH:String = "touch";
      
      private static var sTouches:Vector.<Touch> = new Vector.<Touch>(0);
      
      private var _shiftKey:Boolean;
      
      private var _ctrlKey:Boolean;
      
      private var _timestamp:Number;
      
      private var _visitedObjects:Vector.<EventDispatcher>;
      
      public function TouchEvent(type:String, touches:Vector.<Touch> = null, shiftKey:Boolean = false, ctrlKey:Boolean = false, bubbles:Boolean = true)
      {
         super(type,bubbles,touches);
         _shiftKey = shiftKey;
         _ctrlKey = ctrlKey;
         _visitedObjects = new Vector.<EventDispatcher>(0);
         updateTimestamp(touches);
      }
      
      internal function resetTo(type:String, touches:Vector.<Touch> = null, shiftKey:Boolean = false, ctrlKey:Boolean = false, bubbles:Boolean = true) : TouchEvent
      {
         super.starling_internal::reset(type,bubbles,touches);
         _shiftKey = shiftKey;
         _ctrlKey = ctrlKey;
         _visitedObjects.length = 0;
         updateTimestamp(touches);
         return this;
      }
      
      private function updateTimestamp(touches:Vector.<Touch>) : void
      {
         var _loc2_:int = 0;
         _timestamp = -1;
         var _loc3_:int = int(touches ? touches.length : 0);
         _loc2_ = 0;
         while(_loc2_ < _loc3_)
         {
            if(touches[_loc2_].timestamp > _timestamp)
            {
               _timestamp = touches[_loc2_].timestamp;
            }
            _loc2_++;
         }
      }
      
      public function getTouches(target:DisplayObject, phase:String = null, out:Vector.<Touch> = null) : Vector.<Touch>
      {
         var _loc6_:int = 0;
         var _loc7_:Touch = null;
         var _loc4_:Boolean = false;
         var _loc5_:Boolean = false;
         if(out == null)
         {
            out = new Vector.<Touch>(0);
         }
         var _loc8_:Vector.<Touch> = data as Vector.<Touch>;
         var _loc9_:int = int(_loc8_.length);
         _loc6_ = 0;
         while(_loc6_ < _loc9_)
         {
            _loc7_ = _loc8_[_loc6_];
            _loc4_ = _loc7_.isTouching(target);
            _loc5_ = phase == null || phase == _loc7_.phase;
            if(_loc4_ && _loc5_)
            {
               out[out.length] = _loc7_;
            }
            _loc6_++;
         }
         return out;
      }
      
      public function getTouch(target:DisplayObject, phase:String = null, id:int = -1) : Touch
      {
         var _loc4_:Touch = null;
         var _loc5_:int = 0;
         getTouches(target,phase,sTouches);
         var _loc6_:int = int(sTouches.length);
         if(_loc6_ > 0)
         {
            _loc4_ = null;
            if(id < 0)
            {
               _loc4_ = sTouches[0];
            }
            else
            {
               _loc5_ = 0;
               while(_loc5_ < _loc6_)
               {
                  if(sTouches[_loc5_].id == id)
                  {
                     _loc4_ = sTouches[_loc5_];
                     break;
                  }
                  _loc5_++;
               }
            }
            sTouches.length = 0;
            return _loc4_;
         }
         return null;
      }
      
      public function interactsWith(target:DisplayObject) : Boolean
      {
         var _loc3_:int = 0;
         var _loc2_:Boolean = false;
         getTouches(target,null,sTouches);
         _loc3_ = sTouches.length - 1;
         while(_loc3_ >= 0)
         {
            if(sTouches[_loc3_].phase != "ended")
            {
               _loc2_ = true;
               break;
            }
            _loc3_--;
         }
         sTouches.length = 0;
         return _loc2_;
      }
      
      internal function dispatch(chain:Vector.<EventDispatcher>) : void
      {
         var _loc2_:int = 0;
         var _loc6_:EventDispatcher = null;
         var _loc4_:int = 0;
         var _loc3_:EventDispatcher = null;
         var _loc5_:Boolean = false;
         if(chain && chain.length)
         {
            _loc2_ = int(bubbles ? chain.length : 1);
            _loc6_ = target;
            setTarget(chain[0] as EventDispatcher);
            _loc4_ = 0;
            while(_loc4_ < _loc2_)
            {
               _loc3_ = chain[_loc4_] as EventDispatcher;
               if(_visitedObjects.indexOf(_loc3_) == -1)
               {
                  _loc5_ = _loc3_.invokeEvent(this);
                  _visitedObjects[_visitedObjects.length] = _loc3_;
                  if(_loc5_)
                  {
                     break;
                  }
               }
               _loc4_++;
            }
            setTarget(_loc6_);
         }
      }
      
      public function get timestamp() : Number
      {
         return _timestamp;
      }
      
      public function get touches() : Vector.<Touch>
      {
         return (data as Vector.<Touch>).concat();
      }
      
      public function get shiftKey() : Boolean
      {
         return _shiftKey;
      }
      
      public function get ctrlKey() : Boolean
      {
         return _ctrlKey;
      }
   }
}

