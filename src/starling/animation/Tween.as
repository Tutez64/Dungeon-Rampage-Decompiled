package starling.animation
{
   import starling.core.starling_internal;
   import starling.events.EventDispatcher;
   import starling.utils.Color;
   
   use namespace starling_internal;
   
   public class Tween extends EventDispatcher implements IAnimatable
   {
      
      private static const HINT_MARKER:String = "#";
      
      private static var sTweenPool:Vector.<Tween> = new Vector.<Tween>(0);
      
      private var _target:Object;
      
      private var _transitionFunc:Function;
      
      private var _transitionName:String;
      
      private var _properties:Vector.<String>;
      
      private var _startValues:Vector.<Number>;
      
      private var _endValues:Vector.<Number>;
      
      private var _updateFuncs:Vector.<Function>;
      
      private var _onStart:Function;
      
      private var _onUpdate:Function;
      
      private var _onRepeat:Function;
      
      private var _onComplete:Function;
      
      private var _onRepeatStart:Function;
      
      private var _onRepeatFinish:Function;
      
      private var _onStartArgs:Array;
      
      private var _onUpdateArgs:Array;
      
      private var _onRepeatArgs:Array;
      
      private var _onCompleteArgs:Array;
      
      private var _onRepeatStartArgs:Array;
      
      private var _onRepeatFinishArgs:Array;
      
      private var _totalTime:Number;
      
      private var _currentTime:Number;
      
      private var _progress:Number;
      
      private var _delay:Number;
      
      private var _roundToInt:Boolean;
      
      private var _nextTween:Tween;
      
      private var _repeatCount:int;
      
      private var _repeatDelay:Number;
      
      private var _repeatReverseDelay:Number;
      
      private var _reverse:Boolean;
      
      private var _currentCycle:int;
      
      public function Tween(target:Object, time:Number, transition:Object = "linear")
      {
         super();
         reset(target,time,transition);
      }
      
      internal static function getPropertyHint(property:String) : String
      {
         if(property.indexOf("color") != -1 || property.indexOf("Color") != -1)
         {
            return "rgb";
         }
         var _loc2_:int = property.indexOf("#");
         if(_loc2_ != -1)
         {
            return property.substr(_loc2_ + 1);
         }
         return null;
      }
      
      internal static function getPropertyName(property:String) : String
      {
         var _loc2_:int = property.indexOf("#");
         if(_loc2_ != -1)
         {
            return property.substring(0,_loc2_);
         }
         return property;
      }
      
      starling_internal static function fromPool(target:Object, time:Number, transition:Object = "linear") : Tween
      {
         if(sTweenPool.length)
         {
            return sTweenPool.pop().reset(target,time,transition);
         }
         return new Tween(target,time,transition);
      }
      
      starling_internal static function toPool(tween:Tween) : void
      {
         tween._onStart = tween._onUpdate = tween._onRepeat = tween._onComplete = tween._onRepeatStart = tween._onRepeatFinish = null;
         tween._onStartArgs = tween._onUpdateArgs = tween._onRepeatArgs = tween._onCompleteArgs = tween._onRepeatStartArgs = tween._onRepeatFinishArgs = null;
         tween._target = null;
         tween._transitionFunc = null;
         tween.removeEventListeners();
         sTweenPool.push(tween);
      }
      
      public function reset(target:Object, time:Number, transition:Object = "linear") : Tween
      {
         _target = target;
         _currentTime = 0;
         _totalTime = Math.max(0.0001,time);
         _progress = 0;
         _delay = _repeatDelay = _repeatReverseDelay = 0;
         _onStart = _onUpdate = _onRepeat = _onComplete = _onRepeatStart = _onRepeatFinish = null;
         _onStartArgs = _onUpdateArgs = _onRepeatArgs = _onCompleteArgs = _onRepeatStartArgs = _onRepeatFinishArgs = null;
         _roundToInt = _reverse = false;
         _repeatCount = 1;
         _currentCycle = -1;
         _nextTween = null;
         if(transition is String)
         {
            this.transition = transition as String;
         }
         else
         {
            if(!(transition is Function))
            {
               throw new ArgumentError("Transition must be either a string or a function");
            }
            this.transitionFunc = transition as Function;
         }
         if(_properties)
         {
            _properties.length = 0;
         }
         else
         {
            _properties = new Vector.<String>(0);
         }
         if(_startValues)
         {
            _startValues.length = 0;
         }
         else
         {
            _startValues = new Vector.<Number>(0);
         }
         if(_endValues)
         {
            _endValues.length = 0;
         }
         else
         {
            _endValues = new Vector.<Number>(0);
         }
         if(_updateFuncs)
         {
            _updateFuncs.length = 0;
         }
         else
         {
            _updateFuncs = new Vector.<Function>(0);
         }
         return this;
      }
      
      public function animate(property:String, endValue:Number) : void
      {
         if(_target == null)
         {
            return;
         }
         var _loc3_:int = int(_properties.length);
         var _loc4_:Function = getUpdateFuncFromProperty(property);
         _properties[_loc3_] = getPropertyName(property);
         _startValues[_loc3_] = NaN;
         _endValues[_loc3_] = endValue;
         _updateFuncs[_loc3_] = _loc4_;
      }
      
      public function scaleTo(factor:Number) : void
      {
         animate("scaleX",factor);
         animate("scaleY",factor);
      }
      
      public function moveTo(x:Number, y:Number) : void
      {
         animate("x",x);
         animate("y",y);
      }
      
      public function fadeTo(alpha:Number) : void
      {
         animate("alpha",alpha);
      }
      
      public function rotateTo(angle:Number, type:String = "rad") : void
      {
         animate("rotation#" + type,angle);
      }
      
      public function advanceTime(time:Number) : void
      {
         var _loc6_:int = 0;
         var _loc7_:Function = null;
         var _loc5_:Function = null;
         var _loc8_:Array = null;
         if(time == 0 || _repeatCount == 1 && _currentTime == _totalTime)
         {
            return;
         }
         var _loc3_:Number = _currentTime;
         var _loc2_:Number = _totalTime - _currentTime;
         var _loc10_:Number = time > _loc2_ ? time - _loc2_ : 0;
         _currentTime += time;
         if(_currentTime <= 0)
         {
            return;
         }
         if(_currentTime > _totalTime)
         {
            _currentTime = _totalTime;
         }
         if(_currentCycle < 0 && _loc3_ <= 0 && _currentTime > 0)
         {
            _currentCycle = _currentCycle + 1;
            if(_onStart != null)
            {
               _onStart.apply(this,_onStartArgs);
            }
         }
         if(_loc3_ <= 0 && _currentTime > 0)
         {
            if(_onRepeatStart != null)
            {
               _onRepeatStart.apply(this,_onRepeatStartArgs);
            }
         }
         var _loc11_:Number = _currentTime / _totalTime;
         var _loc9_:Boolean = _reverse && _currentCycle % 2 == 1;
         var _loc4_:int = int(_startValues.length);
         _progress = _loc9_ ? _transitionFunc(1 - _loc11_) : _transitionFunc(_loc11_);
         _loc6_ = 0;
         while(_loc6_ < _loc4_)
         {
            if(_startValues[_loc6_] != _startValues[_loc6_])
            {
               _startValues[_loc6_] = _target[_properties[_loc6_]] as Number;
            }
            _loc7_ = _updateFuncs[_loc6_] as Function;
            _loc7_(_properties[_loc6_],_startValues[_loc6_],_endValues[_loc6_]);
            _loc6_++;
         }
         if(_onUpdate != null)
         {
            _onUpdate.apply(this,_onUpdateArgs);
         }
         if(_loc3_ < _totalTime && _currentTime >= _totalTime)
         {
            if(_repeatCount == 0 || _repeatCount > 1)
            {
               if(_loc9_)
               {
                  _currentTime = -_repeatReverseDelay;
               }
               else
               {
                  _currentTime = -_repeatDelay;
               }
               _currentCycle = _currentCycle + 1;
               if(_repeatCount > 1)
               {
                  _repeatCount = _repeatCount - 1;
               }
               if(_onRepeat != null)
               {
                  _onRepeat.apply(this,_onRepeatArgs);
               }
               if(_onRepeatFinish != null)
               {
                  _onRepeatFinish.apply(this,_onRepeatFinishArgs);
               }
            }
            else
            {
               _loc5_ = _onComplete;
               _loc8_ = _onCompleteArgs;
               dispatchEventWith("removeFromJuggler");
               if(_loc5_ != null)
               {
                  _loc5_.apply(this,_loc8_);
               }
               if(_onRepeatFinish != null)
               {
                  _onRepeatFinish.apply(this,_onRepeatFinishArgs);
               }
               if(_currentTime == 0)
               {
                  _loc10_ = 0;
               }
            }
         }
         if(_loc10_)
         {
            advanceTime(_loc10_);
         }
      }
      
      private function getUpdateFuncFromProperty(property:String) : Function
      {
         var _loc3_:Function = null;
         var _loc2_:String = getPropertyHint(property);
         switch(_loc2_)
         {
            case null:
               _loc3_ = updateStandard;
               break;
            case "rgb":
               _loc3_ = updateRgb;
               break;
            case "rad":
               _loc3_ = updateRad;
               break;
            case "deg":
               _loc3_ = updateDeg;
               break;
            default:
               _loc3_ = updateStandard;
         }
         return _loc3_;
      }
      
      private function updateStandard(property:String, startValue:Number, endValue:Number) : void
      {
         var _loc4_:Number = startValue + _progress * (endValue - startValue);
         if(_roundToInt)
         {
            _loc4_ = Math.round(_loc4_);
         }
         _target[property] = _loc4_;
      }
      
      private function updateRgb(property:String, startValue:Number, endValue:Number) : void
      {
         _target[property] = Color.interpolate(uint(startValue),uint(endValue),_progress);
      }
      
      private function updateRad(property:String, startValue:Number, endValue:Number) : void
      {
         updateAngle(3.141592653589793,property,startValue,endValue);
      }
      
      private function updateDeg(property:String, startValue:Number, endValue:Number) : void
      {
         updateAngle(180,property,startValue,endValue);
      }
      
      private function updateAngle(pi:Number, property:String, startValue:Number, endValue:Number) : void
      {
         while(Math.abs(endValue - startValue) > pi)
         {
            if(startValue < endValue)
            {
               endValue -= 2 * pi;
            }
            else
            {
               endValue += 2 * pi;
            }
         }
         updateStandard(property,startValue,endValue);
      }
      
      public function getEndValue(property:String) : Number
      {
         var _loc2_:int = _properties.indexOf(property);
         if(_loc2_ == -1)
         {
            throw new ArgumentError("The property \'" + property + "\' is not animated");
         }
         return _endValues[_loc2_] as Number;
      }
      
      public function animatesProperty(property:String) : Boolean
      {
         return _properties.indexOf(property) != -1;
      }
      
      public function get isComplete() : Boolean
      {
         return _currentTime >= _totalTime && _repeatCount == 1;
      }
      
      public function get target() : Object
      {
         return _target;
      }
      
      public function get transition() : String
      {
         return _transitionName;
      }
      
      public function set transition(value:String) : void
      {
         _transitionName = value;
         _transitionFunc = Transitions.getTransition(value);
         if(_transitionFunc == null)
         {
            throw new ArgumentError("Invalid transiton: " + value);
         }
      }
      
      public function get transitionFunc() : Function
      {
         return _transitionFunc;
      }
      
      public function set transitionFunc(value:Function) : void
      {
         _transitionName = "custom";
         _transitionFunc = value;
      }
      
      public function get totalTime() : Number
      {
         return _totalTime;
      }
      
      public function get currentTime() : Number
      {
         return _currentTime;
      }
      
      public function get progress() : Number
      {
         return _progress;
      }
      
      public function get delay() : Number
      {
         return _delay;
      }
      
      public function set delay(value:Number) : void
      {
         _currentTime = _currentTime + _delay - value;
         _delay = value;
      }
      
      public function get repeatCount() : int
      {
         return _repeatCount;
      }
      
      public function set repeatCount(value:int) : void
      {
         _repeatCount = value;
      }
      
      public function get repeatDelay() : Number
      {
         return _repeatDelay;
      }
      
      public function set repeatDelay(value:Number) : void
      {
         _repeatDelay = value;
      }
      
      public function get repeatReverseDelay() : Number
      {
         return _repeatReverseDelay;
      }
      
      public function set repeatReverseDelay(value:Number) : void
      {
         _repeatReverseDelay = value;
      }
      
      public function get reverse() : Boolean
      {
         return _reverse;
      }
      
      public function set reverse(value:Boolean) : void
      {
         _reverse = value;
      }
      
      public function get roundToInt() : Boolean
      {
         return _roundToInt;
      }
      
      public function set roundToInt(value:Boolean) : void
      {
         _roundToInt = value;
      }
      
      public function get onStart() : Function
      {
         return _onStart;
      }
      
      public function set onStart(value:Function) : void
      {
         _onStart = value;
      }
      
      public function get onUpdate() : Function
      {
         return _onUpdate;
      }
      
      public function set onUpdate(value:Function) : void
      {
         _onUpdate = value;
      }
      
      public function get onRepeat() : Function
      {
         return _onRepeat;
      }
      
      public function set onRepeat(value:Function) : void
      {
         _onRepeat = value;
      }
      
      public function get onRepeatStart() : Function
      {
         return _onRepeatStart;
      }
      
      public function set onRepeatStart(value:Function) : void
      {
         _onRepeatStart = value;
      }
      
      public function get onRepeatFinish() : Function
      {
         return _onRepeatFinish;
      }
      
      public function set onRepeatFinish(value:Function) : void
      {
         _onRepeatFinish = value;
      }
      
      public function get onComplete() : Function
      {
         return _onComplete;
      }
      
      public function set onComplete(value:Function) : void
      {
         _onComplete = value;
      }
      
      public function get onStartArgs() : Array
      {
         return _onStartArgs;
      }
      
      public function set onStartArgs(value:Array) : void
      {
         _onStartArgs = value;
      }
      
      public function get onUpdateArgs() : Array
      {
         return _onUpdateArgs;
      }
      
      public function set onUpdateArgs(value:Array) : void
      {
         _onUpdateArgs = value;
      }
      
      public function get onRepeatArgs() : Array
      {
         return _onRepeatArgs;
      }
      
      public function set onRepeatArgs(value:Array) : void
      {
         _onRepeatArgs = value;
      }
      
      public function get onRepeatStartArgs() : Array
      {
         return _onRepeatStartArgs;
      }
      
      public function set onRepeatStartArgs(value:Array) : void
      {
         _onRepeatStartArgs = value;
      }
      
      public function get onRepeatFinishArgs() : Array
      {
         return _onRepeatFinishArgs;
      }
      
      public function set onRepeatFinishArgs(value:Array) : void
      {
         _onRepeatFinishArgs = value;
      }
      
      public function get onCompleteArgs() : Array
      {
         return _onCompleteArgs;
      }
      
      public function set onCompleteArgs(value:Array) : void
      {
         _onCompleteArgs = value;
      }
      
      public function get nextTween() : Tween
      {
         return _nextTween;
      }
      
      public function set nextTween(value:Tween) : void
      {
         _nextTween = value;
      }
   }
}

