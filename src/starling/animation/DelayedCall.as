package starling.animation
{
   import starling.core.starling_internal;
   import starling.events.EventDispatcher;
   
   use namespace starling_internal;
   
   public class DelayedCall extends EventDispatcher implements IAnimatable
   {
      
      private static var sPool:Vector.<DelayedCall> = new Vector.<DelayedCall>(0);
      
      private var _currentTime:Number;
      
      private var _totalTime:Number;
      
      private var _callback:Function;
      
      private var _args:Array;
      
      private var _repeatCount:int;
      
      public function DelayedCall(callback:Function, delay:Number, args:Array = null)
      {
         super();
         reset(callback,delay,args);
      }
      
      starling_internal static function fromPool(call:Function, delay:Number, args:Array = null) : DelayedCall
      {
         if(sPool.length)
         {
            return sPool.pop().reset(call,delay,args);
         }
         return new DelayedCall(call,delay,args);
      }
      
      starling_internal static function toPool(delayedCall:DelayedCall) : void
      {
         delayedCall._callback = null;
         delayedCall._args = null;
         delayedCall.removeEventListeners();
         sPool.push(delayedCall);
      }
      
      public function reset(callback:Function, delay:Number, args:Array = null) : DelayedCall
      {
         _currentTime = 0;
         _totalTime = Math.max(delay,0.0001);
         _callback = callback;
         _args = args;
         _repeatCount = 1;
         return this;
      }
      
      public function advanceTime(time:Number) : void
      {
         var _loc2_:Function = null;
         var _loc3_:Array = null;
         var _loc4_:Number = _currentTime;
         _currentTime += time;
         if(_currentTime > _totalTime)
         {
            _currentTime = _totalTime;
         }
         if(_loc4_ < _totalTime && _currentTime >= _totalTime)
         {
            if(_repeatCount == 0 || _repeatCount > 1)
            {
               _callback.apply(null,_args);
               if(_repeatCount > 0)
               {
                  _repeatCount -= 1;
               }
               _currentTime = 0;
               advanceTime(_loc4_ + time - _totalTime);
            }
            else
            {
               _loc2_ = _callback;
               _loc3_ = _args;
               dispatchEventWith("removeFromJuggler");
               _loc2_.apply(null,_loc3_);
            }
         }
      }
      
      public function complete() : void
      {
         var _loc1_:Number = _totalTime - _currentTime;
         if(_loc1_ > 0)
         {
            advanceTime(_loc1_);
         }
      }
      
      public function get isComplete() : Boolean
      {
         return _repeatCount == 1 && _currentTime >= _totalTime;
      }
      
      public function get totalTime() : Number
      {
         return _totalTime;
      }
      
      public function get currentTime() : Number
      {
         return _currentTime;
      }
      
      public function get repeatCount() : int
      {
         return _repeatCount;
      }
      
      public function set repeatCount(value:int) : void
      {
         _repeatCount = value;
      }
      
      public function get callback() : Function
      {
         return _callback;
      }
      
      public function get arguments() : Array
      {
         return _args;
      }
   }
}

