package starling.animation
{
   import starling.core.starling_internal;
   import starling.events.Event;
   import starling.events.EventDispatcher;
   
   use namespace starling_internal;
   
   public class Juggler implements IAnimatable
   {
      
      private static var sCurrentObjectID:uint;
      
      private var _objects:Vector.<IAnimatable>;
      
      private var _objectIDs:Vector.<uint>;
      
      private var _elapsedTime:Number;
      
      private var _timeScale:Number;
      
      public function Juggler()
      {
         super();
         _elapsedTime = 0;
         _timeScale = 1;
         _objects = new Vector.<IAnimatable>(0);
         _objectIDs = new Vector.<uint>(0);
      }
      
      private static function getNextID() : uint
      {
         return ++sCurrentObjectID;
      }
      
      public function add(object:IAnimatable) : uint
      {
         return addWithID(object,getNextID());
      }
      
      private function addWithID(object:IAnimatable, objectID:uint) : uint
      {
         var _loc3_:EventDispatcher = null;
         if(object && !contains(object))
         {
            _loc3_ = object as EventDispatcher;
            if(_loc3_)
            {
               _loc3_.addEventListener("removeFromJuggler",onRemoveRequested);
            }
            _objects[_objects.length] = object;
            _objectIDs[_objectIDs.length] = objectID;
            return objectID;
         }
         return 0;
      }
      
      public function contains(object:IAnimatable) : Boolean
      {
         return _objects.indexOf(object) != -1;
      }
      
      public function get isEmpty() : Boolean
      {
         return _objects.length == 0;
      }
      
      public function remove(object:IAnimatable) : uint
      {
         var _loc2_:int = _objects.indexOf(object);
         if(_loc2_ != -1)
         {
            return removeByIndex(_loc2_);
         }
         return 0;
      }
      
      private function removeByIndex(index:int) : uint
      {
         var _loc4_:IAnimatable = _objects[index];
         var _loc3_:uint = _objectIDs[index];
         _objects[index] = null;
         _objectIDs[index] = 0;
         var _loc2_:EventDispatcher = _loc4_ as EventDispatcher;
         if(_loc2_)
         {
            _loc2_.removeEventListener("removeFromJuggler",onRemoveRequested);
            _loc2_.dispatchEventWith("removedFromJuggler");
         }
         return _loc3_;
      }
      
      public function removeByID(objectID:uint) : uint
      {
         var _loc2_:int = _objectIDs.indexOf(objectID);
         if(_loc2_ != -1)
         {
            return removeByIndex(_loc2_);
         }
         return 0;
      }
      
      public function removeTweens(target:Object) : void
      {
         var _loc3_:int = 0;
         var _loc2_:Tween = null;
         if(target == null)
         {
            return;
         }
         _loc3_ = _objects.length - 1;
         while(_loc3_ >= 0)
         {
            _loc2_ = _objects[_loc3_] as Tween;
            if(_loc2_ && _loc2_.target == target)
            {
               removeByIndex(_loc3_);
            }
            _loc3_--;
         }
      }
      
      public function removeDelayedCalls(callback:Function) : void
      {
         var _loc2_:int = 0;
         var _loc3_:DelayedCall = null;
         if(callback == null)
         {
            return;
         }
         _loc2_ = _objects.length - 1;
         while(_loc2_ >= 0)
         {
            _loc3_ = _objects[_loc2_] as DelayedCall;
            if(_loc3_ && _loc3_.callback == callback)
            {
               removeByIndex(_loc2_);
            }
            _loc2_--;
         }
      }
      
      public function containsTweens(target:Object) : Boolean
      {
         var _loc3_:int = 0;
         var _loc2_:Tween = null;
         if(target)
         {
            _loc3_ = _objects.length - 1;
            while(_loc3_ >= 0)
            {
               _loc2_ = _objects[_loc3_] as Tween;
               if(_loc2_ && _loc2_.target == target)
               {
                  return true;
               }
               _loc3_--;
            }
         }
         return false;
      }
      
      public function containsDelayedCalls(callback:Function) : Boolean
      {
         var _loc2_:int = 0;
         var _loc3_:DelayedCall = null;
         if(callback != null)
         {
            _loc2_ = _objects.length - 1;
            while(_loc2_ >= 0)
            {
               _loc3_ = _objects[_loc2_] as DelayedCall;
               if(_loc3_ && _loc3_.callback == callback)
               {
                  return true;
               }
               _loc2_--;
            }
         }
         return false;
      }
      
      public function purge() : void
      {
         var _loc1_:int = 0;
         _loc1_ = _objects.length - 1;
         while(_loc1_ >= 0)
         {
            removeByIndex(_loc1_);
            _loc1_--;
         }
      }
      
      public function delayCall(call:Function, delay:Number, ... rest) : uint
      {
         if(call == null)
         {
            throw new ArgumentError("call must not be null");
         }
         var _loc4_:DelayedCall = DelayedCall.fromPool(call,delay,rest);
         _loc4_.addEventListener("removedFromJuggler",onPooledDelayedCallRemovedFromJuggler);
         return add(_loc4_);
      }
      
      public function repeatCall(call:Function, interval:Number, repeatCount:int = 0, ... rest) : uint
      {
         if(call == null)
         {
            throw new ArgumentError("call must not be null");
         }
         var _loc5_:DelayedCall = DelayedCall.fromPool(call,interval,rest);
         _loc5_.repeatCount = repeatCount;
         _loc5_.addEventListener("removedFromJuggler",onPooledDelayedCallRemovedFromJuggler);
         return add(_loc5_);
      }
      
      private function onPooledDelayedCallRemovedFromJuggler(event:Event) : void
      {
         DelayedCall.toPool(event.target as DelayedCall);
      }
      
      public function tween(target:Object, time:Number, properties:Object) : uint
      {
         var _loc6_:Object = null;
         if(target == null)
         {
            throw new ArgumentError("target must not be null");
         }
         var _loc4_:Tween = Tween.fromPool(target,time);
         for(var _loc5_:String in properties)
         {
            _loc6_ = properties[_loc5_];
            if(_loc4_.hasOwnProperty(_loc5_))
            {
               _loc4_[_loc5_] = _loc6_;
            }
            else
            {
               if(!target.hasOwnProperty(Tween.getPropertyName(_loc5_)))
               {
                  throw new ArgumentError("Invalid property: " + _loc5_);
               }
               _loc4_.animate(_loc5_,_loc6_ as Number);
            }
         }
         _loc4_.addEventListener("removedFromJuggler",onPooledTweenRemovedFromJuggler);
         return add(_loc4_);
      }
      
      private function onPooledTweenRemovedFromJuggler(event:Event) : void
      {
         Tween.toPool(event.target as Tween);
      }
      
      public function advanceTime(time:Number) : void
      {
         var _loc2_:int = 0;
         var _loc5_:IAnimatable = null;
         var _loc4_:int = int(_objects.length);
         var _loc3_:int = 0;
         _elapsedTime += time;
         time *= _timeScale;
         if(_loc4_ == 0 || time == 0)
         {
            return;
         }
         _loc2_ = 0;
         while(_loc2_ < _loc4_)
         {
            _loc5_ = _objects[_loc2_];
            if(_loc5_)
            {
               if(_loc3_ != _loc2_)
               {
                  _objects[_loc3_] = _loc5_;
                  _objectIDs[_loc3_] = _objectIDs[_loc2_];
                  _objects[_loc2_] = null;
                  _objectIDs[_loc2_] = 0;
               }
               _loc5_.advanceTime(time);
               _loc3_++;
            }
            _loc2_++;
         }
         if(_loc3_ != _loc2_)
         {
            _loc4_ = int(_objects.length);
            while(_loc2_ < _loc4_)
            {
               _objects[_loc3_] = _objects[_loc2_];
               _objectIDs[_loc3_] = _objectIDs[_loc2_];
               _loc3_++;
               _loc2_++;
            }
            _objects.length = _loc3_;
            _objectIDs.length = _loc3_;
         }
      }
      
      private function onRemoveRequested(event:Event) : void
      {
         var _loc2_:Tween = null;
         var _loc3_:uint = remove(event.target as IAnimatable);
         if(_loc3_)
         {
            _loc2_ = event.target as Tween;
            if(_loc2_ && _loc2_.isComplete)
            {
               addWithID(_loc2_.nextTween,_loc3_);
            }
         }
      }
      
      public function get elapsedTime() : Number
      {
         return _elapsedTime;
      }
      
      public function get timeScale() : Number
      {
         return _timeScale;
      }
      
      public function set timeScale(value:Number) : void
      {
         _timeScale = value;
      }
      
      protected function get objects() : Vector.<IAnimatable>
      {
         return _objects;
      }
   }
}

