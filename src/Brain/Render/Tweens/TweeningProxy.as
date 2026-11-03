package Brain.Render.Tweens
{
   import Brain.Event.EventListeners;
   import Brain.Facade.Facade;
   import Brain.Logger.Logger;
   import flash.display.DisplayObject;
   import flash.display.Shape;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.utils.Dictionary;
   import flash.utils.getTimer;
   import starling.animation.DelayedCall;
   import starling.animation.Juggler;
   import starling.animation.Tween;
   
   public class TweeningProxy
   {
      
      private static const DEFAULT_FRAME_RATE:Number = 60;
      
      private static var sJuggler:Juggler;
      
      private static var sTicker:Shape;
      
      private static var sLastTickTime:int;
      
      private static const RESERVED_KEYS:Object = {
         "ease":true,
         "delay":true,
         "repeat":true,
         "yoyo":true,
         "repeatDelay":true,
         "onStart":true,
         "onStartParams":true,
         "onUpdate":true,
         "onUpdateParams":true,
         "onComplete":true,
         "onCompleteParams":true,
         "onCompleteListener":true,
         "onCompleteListenerParams":true,
         "immediateRender":true,
         "overwrite":true,
         "useFrames":true,
         "paused":true
      };
      
      private static var sHandlesByTarget:Dictionary = new Dictionary(true);
      
      private static var sHandlesByCallback:Dictionary = new Dictionary(true);
      
      private var mFacade:Facade;
      
      public function TweeningProxy(facade:Facade)
      {
         super();
         mFacade = facade;
         ensureTicker(mFacade.stageRef);
      }
      
      public static function setGlobalTimeScale(value:Number) : void
      {
         ensureTicker();
         if(sJuggler)
         {
            sJuggler.timeScale = value;
         }
      }
      
      private static function createAdapterTween(adapter:Object, duration:Number, transition:Object) : Tween
      {
         var _loc4_:Tween = new Tween(adapter,duration,transition);
         _loc4_.animate("progress",1);
         return _loc4_;
      }
      
      private static function configureTiming(tween:Tween, vars:Object) : void
      {
         var _loc3_:int = 0;
         tween.delay = Number(vars.delay) || 0;
         if("repeat" in vars)
         {
            _loc3_ = int(vars.repeat);
            tween.repeatCount = _loc3_ < 0 ? 0 : _loc3_ + 1;
         }
         tween.repeatDelay = Number(vars.repeatDelay) || 0;
         tween.reverse = vars.yoyo == true;
      }
      
      private static function makeVisibleSetter(target:Object, visible:Boolean) : Function
      {
         return function():void
         {
            if(target != null && "visible" in target)
            {
               target.visible = visible;
            }
         };
      }
      
      private static function register(registry:Dictionary, key:Object, handle:TweenHandle) : void
      {
         var _loc4_:Vector.<TweenHandle> = registry[key];
         if(_loc4_ == null)
         {
            registry[key] = _loc4_ = new Vector.<TweenHandle>(0);
         }
         _loc4_.push(handle);
         handle.onFinished = unregister;
      }
      
      private static function unregister(handle:TweenHandle) : void
      {
         var _loc2_:Function = handle.delayedCallback;
         if(_loc2_ != null)
         {
            removeFromRegistry(sHandlesByCallback,_loc2_,handle);
         }
         else if(handle.target != null)
         {
            removeFromRegistry(sHandlesByTarget,handle.target,handle);
         }
      }
      
      private static function removeFromRegistry(registry:Dictionary, key:Object, handle:TweenHandle) : void
      {
         var _loc5_:Vector.<TweenHandle> = registry[key];
         if(_loc5_ == null)
         {
            return;
         }
         var _loc4_:int = _loc5_.indexOf(handle);
         if(_loc4_ != -1)
         {
            _loc5_.splice(_loc4_,1);
         }
         if(_loc5_.length == 0)
         {
            delete registry[key];
         }
      }
      
      private static function killRegistered(registry:Dictionary, key:Object) : void
      {
         if(key == null)
         {
            return;
         }
         var _loc5_:Vector.<TweenHandle> = registry[key];
         if(_loc5_ == null)
         {
            return;
         }
         var _loc3_:Vector.<TweenHandle> = _loc5_.concat();
         for each(var _loc4_:TweenHandle in _loc3_)
         {
            _loc4_.kill();
         }
      }
      
      private static function ensureTicker(stage:Stage = null) : void
      {
         if(sJuggler == null)
         {
            sJuggler = new Juggler();
            sTicker = new Shape();
            sLastTickTime = getTimer();
            EventListeners.add(sTicker,"enterFrame",onTick);
         }
         if(stage != null && sTicker != null && sTicker.stage == null)
         {
            stage.addChild(sTicker);
            sLastTickTime = getTimer();
         }
      }
      
      public static function shutdown() : void
      {
         if(sTicker)
         {
            EventListeners.remove(sTicker,"enterFrame",onTick);
            if(sTicker.parent)
            {
               sTicker.parent.removeChild(sTicker);
            }
            sTicker = null;
         }
         sJuggler = null;
         sLastTickTime = 0;
      }
      
      private static function onTick(event:Event) : void
      {
         if(sJuggler == null)
         {
            return;
         }
         var _loc3_:int = getTimer();
         var _loc2_:Number = (_loc3_ - sLastTickTime) * 0.001;
         sLastTickTime = _loc3_;
         if(_loc2_ > 0)
         {
            sJuggler.advanceTime(_loc2_);
         }
      }
      
      public function tweenMaxTo(target:Object, duration:Number, vars:Object) : TweenHandle
      {
         return createTween(target,duration,vars,null);
      }
      
      public function tweenLiteTo(target:Object, duration:Number, vars:Object) : TweenHandle
      {
         return createTween(target,duration,vars,null);
      }
      
      public function tweenFromTo(target:Object, duration:Number, fromVars:Object, toVars:Object) : TweenHandle
      {
         return createTween(target,duration,toVars,fromVars || {});
      }
      
      public function delayedCall(delay:Number, onComplete:Function, onCompleteParams:Array = null, useFrames:Boolean = false) : TweenHandle
      {
         if(onComplete == null)
         {
            Logger.warn("TweeningProxy.delayedCall: null callback ignored");
            return null;
         }
         if(useFrames)
         {
            delay /= frameRate;
         }
         var _loc5_:TweenHandle = new TweenHandle(new DelayedCall(onComplete,delay,onCompleteParams));
         _loc5_.refreshSpan();
         register(sHandlesByCallback,onComplete,_loc5_);
         if(delay <= 0)
         {
            _loc5_.complete();
         }
         else
         {
            _loc5_.attachToJuggler(sJuggler);
         }
         return _loc5_;
      }
      
      public function createTimeline(vars:Object = null) : TweenHandle
      {
         var _loc7_:String = null;
         var _loc5_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc8_:TweenHandle = null;
         var _loc3_:TweenTimeline = new TweenTimeline();
         var _loc4_:TweenHandle = new TweenHandle(_loc3_);
         if(vars)
         {
            _loc3_.onComplete = vars.onComplete as Function;
            _loc3_.onCompleteArgs = vars.onCompleteParams as Array;
            if(vars.tweens)
            {
               _loc7_ = vars.align ? String(vars.align) : "normal";
               _loc5_ = Number(Number(vars.stagger) || 0);
               _loc6_ = 0;
               for each(var _loc2_:Object in vars.tweens)
               {
                  _loc8_ = _loc2_ as TweenHandle;
                  if(_loc8_ == null)
                  {
                     Logger.warn("TweeningProxy.createTimeline: ignoring non-TweenHandle entry in \'tweens\'");
                  }
                  else
                  {
                     _loc3_.insert(_loc8_,_loc6_);
                     if(_loc7_ == "sequence")
                     {
                        _loc6_ += _loc8_.totalSpan;
                     }
                     _loc6_ += _loc5_;
                  }
               }
            }
            if(vars.paused == true)
            {
               _loc4_.pause();
            }
         }
         _loc4_.attachToJuggler(sJuggler);
         return _loc4_;
      }
      
      public function appendTween(timeline:TweenHandle, tween:TweenHandle) : TweenHandle
      {
         var _loc3_:TweenTimeline = requireTimeline(timeline,"appendTween");
         if(_loc3_ && tween)
         {
            _loc3_.append(tween);
         }
         return timeline;
      }
      
      public function insertTween(timeline:TweenHandle, tween:TweenHandle, position:Object = null) : TweenHandle
      {
         var _loc4_:TweenTimeline = requireTimeline(timeline,"insertTween");
         if(_loc4_ && tween)
         {
            _loc4_.insert(tween,position);
         }
         return timeline;
      }
      
      public function addLabel(timeline:TweenHandle, label:String, position:Object = null) : void
      {
         var _loc4_:TweenTimeline = requireTimeline(timeline,"addLabel");
         if(_loc4_)
         {
            _loc4_.addLabel(label,_loc4_.resolvePosition(position));
         }
      }
      
      public function killTweensOf(target:Object) : void
      {
         killRegistered(sHandlesByTarget,target);
      }
      
      public function killDelayedCallsTo(callback:Function) : void
      {
         killRegistered(sHandlesByCallback,callback);
      }
      
      public function killTween(tween:TweenHandle) : void
      {
         if(tween)
         {
            tween.kill();
         }
      }
      
      public function playTween(tween:TweenHandle) : void
      {
         if(tween)
         {
            tween.play();
         }
      }
      
      public function pauseTween(tween:TweenHandle) : void
      {
         if(tween)
         {
            tween.pause();
         }
      }
      
      public function resumeTween(tween:TweenHandle) : void
      {
         if(tween)
         {
            tween.resume();
         }
      }
      
      public function reverseTween(tween:TweenHandle) : void
      {
         if(tween)
         {
            tween.reverse();
         }
      }
      
      public function completeTween(tween:TweenHandle) : void
      {
         if(tween)
         {
            tween.complete();
         }
      }
      
      public function getCurrentProgress(tween:TweenHandle) : Number
      {
         return tween ? tween.progress : 1;
      }
      
      private function createTween(target:Object, duration:Number, vars:Object, fromVars:Object) : TweenHandle
      {
         var _loc14_:* = undefined;
         var _loc10_:TintAdapter = null;
         var _loc15_:GlowFilterAdapter = null;
         var _loc7_:ColorMatrixFilterAdapter = null;
         vars ||= {};
         if(target == null)
         {
            Logger.warn("TweeningProxy: tweening a null target; only callbacks will run");
         }
         var _loc11_:Object = vars.ease is Function ? vars.ease : Quad.easeOut;
         var _loc17_:Tween = new Tween(target,duration,_loc11_);
         var _loc9_:TweenHandle = new TweenHandle(_loc17_,target);
         var _loc12_:Vector.<Tween> = new Vector.<Tween>(0);
         var _loc13_:DisplayObject = target as DisplayObject;
         for(var _loc16_:String in vars)
         {
            if(!RESERVED_KEYS[_loc16_])
            {
               _loc14_ = vars[_loc16_];
               switch(_loc16_)
               {
                  case "tint":
                  case "removeTint":
                     if(!(_loc16_ == "removeTint" && _loc14_ != true))
                     {
                        if(requireFlashTarget(_loc13_,_loc16_))
                        {
                           _loc10_ = new TintAdapter(_loc13_,uint(_loc14_),_loc16_ == "removeTint");
                           _loc12_.push(createAdapterTween(_loc10_,duration,_loc11_));
                           _loc9_.addKillHook(_loc10_.revert);
                        }
                     }
                     break;
                  case "glowFilter":
                     if(requireFlashTarget(_loc13_,_loc16_))
                     {
                        _loc15_ = new GlowFilterAdapter(_loc13_,_loc14_);
                        _loc12_.push(createAdapterTween(_loc15_,duration,_loc11_));
                        _loc9_.addCompleteHook(_loc15_.finish);
                        _loc9_.addKillHook(_loc15_.revert);
                     }
                     break;
                  case "colorMatrixFilter":
                     if(requireFlashTarget(_loc13_,_loc16_))
                     {
                        _loc7_ = new ColorMatrixFilterAdapter(_loc13_,fromVars ? fromVars.colorMatrixFilter : null,_loc14_);
                        _loc12_.push(createAdapterTween(_loc7_,duration,_loc11_));
                        _loc9_.addCompleteHook(_loc7_.finish);
                        _loc9_.addKillHook(_loc7_.revert);
                     }
                     break;
                  case "visible":
                     _loc9_.addCompleteHook(makeVisibleSetter(target,_loc14_ == true));
                     break;
                  default:
                     if(_loc14_ is Number || _loc14_ is int || _loc14_ is uint)
                     {
                        if(target != null && fromVars && _loc16_ in fromVars)
                        {
                           target[_loc16_] = Number(fromVars[_loc16_]);
                        }
                        _loc17_.animate(_loc16_,Number(_loc14_));
                     }
                     else
                     {
                        Logger.warn("TweeningProxy: ignoring non-numeric tween var \'" + _loc16_ + "\'");
                     }
               }
            }
         }
         configureTiming(_loc17_,vars);
         for each(var _loc5_:Tween in _loc12_)
         {
            configureTiming(_loc5_,vars);
            _loc9_.addSideTween(_loc5_);
         }
         _loc9_.refreshSpan();
         var _loc8_:Function = vars.onComplete is Function ? vars.onComplete : null;
         var _loc6_:Array = vars.onCompleteParams is Array ? vars.onCompleteParams : null;
         if(_loc8_ == null && vars.onCompleteListener is Function)
         {
            _loc8_ = vars.onCompleteListener as Function;
            _loc6_ = vars.onCompleteListenerParams is Array ? vars.onCompleteListenerParams : null;
         }
         _loc9_.setCallbacks(vars.onStart as Function,vars.onStartParams as Array,vars.onUpdate as Function,vars.onUpdateParams as Array,_loc8_,_loc6_);
         if(target != null)
         {
            register(sHandlesByTarget,target,_loc9_);
         }
         if(duration <= 0 && _loc17_.delay <= 0)
         {
            _loc9_.complete();
         }
         else
         {
            _loc9_.attachToJuggler(sJuggler);
         }
         return _loc9_;
      }
      
      private function requireFlashTarget(flashTarget:DisplayObject, key:String) : Boolean
      {
         if(flashTarget == null)
         {
            Logger.warn("TweeningProxy: \'" + key + "\' needs a flash.display.DisplayObject target; ignored");
            return false;
         }
         return true;
      }
      
      private function requireTimeline(handle:TweenHandle, operation:String) : TweenTimeline
      {
         var _loc3_:TweenTimeline = handle ? handle.timeline : null;
         if(_loc3_ == null)
         {
            Logger.warn("TweeningProxy." + operation + ": handle is not a timeline");
         }
         return _loc3_;
      }
      
      private function get frameRate() : Number
      {
         return mFacade && mFacade.stageRef ? mFacade.stageRef.frameRate : 60;
      }
   }
}

