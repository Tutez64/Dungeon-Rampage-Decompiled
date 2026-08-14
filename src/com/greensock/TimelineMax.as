package com.greensock
{
   import com.greensock.core.*;
   import com.greensock.events.TweenEvent;
   import flash.events.*;
   
   public class TimelineMax extends TimelineLite implements IEventDispatcher
   {
      
      public static const version:Number = 1.67;
      
      protected var _cyclesComplete:int;
      
      protected var _dispatcher:EventDispatcher;
      
      protected var _hasUpdateListener:Boolean;
      
      public var yoyo:Boolean;
      
      protected var _repeatDelay:Number;
      
      protected var _repeat:int;
      
      public function TimelineMax(vars:Object = null)
      {
         super(vars);
         _repeat = this.vars.repeat ? int(Number(this.vars.repeat)) : 0;
         _repeatDelay = this.vars.repeatDelay ? Number(this.vars.repeatDelay) : 0;
         _cyclesComplete = 0;
         this.yoyo = Boolean(this.vars.yoyo == true);
         this.cacheIsDirty = true;
         if(this.vars.onCompleteListener != null || this.vars.onUpdateListener != null || this.vars.onStartListener != null || this.vars.onRepeatListener != null || this.vars.onReverseCompleteListener != null)
         {
            initDispatcher();
         }
      }
      
      private static function easeNone(t:Number, b:Number, c:Number, d:Number) : Number
      {
         return t / d;
      }
      
      private static function onInitTweenTo(tween:TweenLite, timeline:TimelineMax, fromTime:Number) : void
      {
         timeline.paused = true;
         if(!isNaN(fromTime))
         {
            timeline.currentTime = fromTime;
         }
         if(tween.vars.currentTime != timeline.currentTime)
         {
            tween.duration = Math.abs(Number(tween.vars.currentTime) - timeline.currentTime) / timeline.cachedTimeScale;
         }
      }
      
      public function dispatchEvent(e:Event) : Boolean
      {
         return _dispatcher == null ? false : _dispatcher.dispatchEvent(e);
      }
      
      public function get currentLabel() : String
      {
         return getLabelBefore(this.cachedTime + 1e-8);
      }
      
      override public function renderTime(time:Number, suppressEvents:Boolean = false, force:Boolean = false) : void
      {
         var _loc9_:TweenCore = null;
         var _loc10_:Boolean = false;
         var _loc11_:Boolean = false;
         var _loc12_:Boolean = false;
         var _loc13_:TweenCore = null;
         var _loc14_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc17_:int = 0;
         var _loc18_:Boolean = false;
         var _loc19_:Boolean = false;
         var _loc20_:Boolean = false;
         if(this.gc)
         {
            this.setEnabled(true,false);
         }
         else if(!this.active && !this.cachedPaused)
         {
            this.active = true;
         }
         var _loc4_:Number = this.cacheIsDirty ? this.totalDuration : this.cachedTotalDuration;
         var _loc5_:Number = this.cachedTime;
         var _loc6_:Number = this.cachedTotalTime;
         var _loc7_:Number = this.cachedStartTime;
         var _loc8_:Number = this.cachedTimeScale;
         var _loc15_:Boolean = this.cachedPaused;
         if(time >= _loc4_)
         {
            if(_rawPrevTime <= _loc4_ && _rawPrevTime != time)
            {
               this.cachedTotalTime = _loc4_;
               if(!this.cachedReversed && this.yoyo && _repeat % 2 != 0)
               {
                  this.cachedTime = 0;
                  forceChildrenToBeginning(0,suppressEvents);
               }
               else
               {
                  this.cachedTime = this.cachedDuration;
                  forceChildrenToEnd(this.cachedDuration,suppressEvents);
               }
               _loc10_ = !this.hasPausedChild();
               _loc11_ = true;
               if(this.cachedDuration == 0 && _loc10_ && (time == 0 || _rawPrevTime < 0))
               {
                  force = true;
               }
            }
         }
         else if(time <= 0)
         {
            if(time < 0)
            {
               this.active = false;
               if(this.cachedDuration == 0 && _rawPrevTime >= 0)
               {
                  force = true;
                  _loc10_ = true;
               }
            }
            else if(time == 0 && !this.initted)
            {
               force = true;
            }
            if(_rawPrevTime >= 0 && _rawPrevTime != time)
            {
               this.cachedTotalTime = 0;
               this.cachedTime = 0;
               forceChildrenToBeginning(0,suppressEvents);
               _loc11_ = true;
               if(this.cachedReversed)
               {
                  _loc10_ = true;
               }
            }
         }
         else
         {
            this.cachedTotalTime = this.cachedTime = time;
         }
         _rawPrevTime = time;
         if(_repeat != 0)
         {
            _loc16_ = this.cachedDuration + _repeatDelay;
            _loc17_ = _cyclesComplete;
            _cyclesComplete = this.cachedTotalTime / _loc16_ >> 0;
            if(_cyclesComplete == this.cachedTotalTime / _loc16_)
            {
               --_cyclesComplete;
            }
            if(_loc17_ != _cyclesComplete)
            {
               _loc12_ = true;
            }
            if(_loc10_)
            {
               if(this.yoyo && Boolean(_repeat % 2))
               {
                  this.cachedTime = 0;
               }
            }
            else if(time > 0)
            {
               this.cachedTime = (this.cachedTotalTime / _loc16_ - _cyclesComplete) * _loc16_;
               if(this.yoyo && Boolean(_cyclesComplete % 2))
               {
                  this.cachedTime = this.cachedDuration - this.cachedTime;
               }
               else if(this.cachedTime >= this.cachedDuration)
               {
                  this.cachedTime = this.cachedDuration;
               }
               if(this.cachedTime < 0)
               {
                  this.cachedTime = 0;
               }
            }
            else
            {
               _cyclesComplete = 0;
            }
            if(_loc12_ && !_loc10_ && (this.cachedTime != _loc5_ || force))
            {
               _loc18_ = Boolean(!this.yoyo || _cyclesComplete % 2 == 0);
               _loc19_ = Boolean(!this.yoyo || _loc17_ % 2 == 0);
               _loc20_ = Boolean(_loc18_ == _loc19_);
               if(_loc17_ > _cyclesComplete)
               {
                  _loc19_ = !_loc19_;
               }
               if(_loc19_)
               {
                  _loc5_ = forceChildrenToEnd(this.cachedDuration,suppressEvents);
                  if(_loc20_)
                  {
                     _loc5_ = forceChildrenToBeginning(0,true);
                  }
               }
               else
               {
                  _loc5_ = forceChildrenToBeginning(0,suppressEvents);
                  if(_loc20_)
                  {
                     _loc5_ = forceChildrenToEnd(this.cachedDuration,true);
                  }
               }
               _loc11_ = false;
            }
         }
         if(this.cachedTotalTime == _loc6_ && !force)
         {
            return;
         }
         if(!this.initted)
         {
            this.initted = true;
         }
         if(_loc6_ == 0 && this.cachedTotalTime != 0 && !suppressEvents)
         {
            if(this.vars.onStart)
            {
               this.vars.onStart.apply(null,this.vars.onStartParams);
            }
            if(_dispatcher)
            {
               _dispatcher.dispatchEvent(new TweenEvent(TweenEvent.START));
            }
         }
         if(!_loc11_)
         {
            if(this.cachedTime - _loc5_ > 0)
            {
               _loc9_ = _firstChild;
               while(_loc9_)
               {
                  _loc13_ = _loc9_.nextNode;
                  if(this.cachedPaused && !_loc15_)
                  {
                     break;
                  }
                  if(_loc9_.active || !_loc9_.cachedPaused && _loc9_.cachedStartTime <= this.cachedTime && !_loc9_.gc)
                  {
                     if(!_loc9_.cachedReversed)
                     {
                        _loc9_.renderTime((this.cachedTime - _loc9_.cachedStartTime) * _loc9_.cachedTimeScale,suppressEvents,false);
                     }
                     else
                     {
                        _loc14_ = _loc9_.cacheIsDirty ? _loc9_.totalDuration : _loc9_.cachedTotalDuration;
                        _loc9_.renderTime(_loc14_ - (this.cachedTime - _loc9_.cachedStartTime) * _loc9_.cachedTimeScale,suppressEvents,false);
                     }
                  }
                  _loc9_ = _loc13_;
               }
            }
            else
            {
               _loc9_ = _lastChild;
               while(_loc9_)
               {
                  _loc13_ = _loc9_.prevNode;
                  if(this.cachedPaused && !_loc15_)
                  {
                     break;
                  }
                  if(_loc9_.active || !_loc9_.cachedPaused && _loc9_.cachedStartTime <= _loc5_ && !_loc9_.gc)
                  {
                     if(!_loc9_.cachedReversed)
                     {
                        _loc9_.renderTime((this.cachedTime - _loc9_.cachedStartTime) * _loc9_.cachedTimeScale,suppressEvents,false);
                     }
                     else
                     {
                        _loc14_ = _loc9_.cacheIsDirty ? _loc9_.totalDuration : _loc9_.cachedTotalDuration;
                        _loc9_.renderTime(_loc14_ - (this.cachedTime - _loc9_.cachedStartTime) * _loc9_.cachedTimeScale,suppressEvents,false);
                     }
                  }
                  _loc9_ = _loc13_;
               }
            }
         }
         if(_hasUpdate && !suppressEvents)
         {
            this.vars.onUpdate.apply(null,this.vars.onUpdateParams);
         }
         if(_hasUpdateListener && !suppressEvents)
         {
            _dispatcher.dispatchEvent(new TweenEvent(TweenEvent.UPDATE));
         }
         if(_loc12_ && !suppressEvents)
         {
            if(this.vars.onRepeat)
            {
               this.vars.onRepeat.apply(null,this.vars.onRepeatParams);
            }
            if(_dispatcher)
            {
               _dispatcher.dispatchEvent(new TweenEvent(TweenEvent.REPEAT));
            }
         }
         if(_loc10_ && (_loc7_ == this.cachedStartTime || _loc8_ != this.cachedTimeScale) && (_loc4_ >= this.totalDuration || this.cachedTime == 0))
         {
            complete(true,suppressEvents);
         }
      }
      
      public function addCallback(callback:Function, timeOrLabel:*, params:Array = null) : TweenLite
      {
         var _loc4_:TweenLite = new TweenLite(callback,0,{
            "onComplete":callback,
            "onCompleteParams":params,
            "overwrite":0,
            "immediateRender":false
         });
         insert(_loc4_,timeOrLabel);
         return _loc4_;
      }
      
      public function tweenFromTo(fromTimeOrLabel:*, toTimeOrLabel:*, vars:Object = null) : TweenLite
      {
         var _loc4_:TweenLite = tweenTo(toTimeOrLabel,vars);
         _loc4_.vars.onInitParams[2] = parseTimeOrLabel(fromTimeOrLabel);
         _loc4_.duration = Math.abs(Number(_loc4_.vars.currentTime) - _loc4_.vars.onInitParams[2]) / this.cachedTimeScale;
         return _loc4_;
      }
      
      public function removeEventListener(type:String, listener:Function, useCapture:Boolean = false) : void
      {
         if(_dispatcher != null)
         {
            _dispatcher.removeEventListener(type,listener,useCapture);
         }
      }
      
      override public function set currentTime(n:Number) : void
      {
         if(_cyclesComplete == 0)
         {
            setTotalTime(n,false);
         }
         else if(this.yoyo && _cyclesComplete % 2 == 1)
         {
            setTotalTime(this.duration - n + _cyclesComplete * (this.cachedDuration + _repeatDelay),false);
         }
         else
         {
            setTotalTime(n + _cyclesComplete * (this.duration + _repeatDelay),false);
         }
      }
      
      public function addEventListener(type:String, listener:Function, useCapture:Boolean = false, priority:int = 0, useWeakReference:Boolean = false) : void
      {
         if(_dispatcher == null)
         {
            initDispatcher();
         }
         if(type == TweenEvent.UPDATE)
         {
            _hasUpdateListener = true;
         }
         _dispatcher.addEventListener(type,listener,useCapture,priority,useWeakReference);
      }
      
      public function tweenTo(timeOrLabel:*, vars:Object = null) : TweenLite
      {
         var _loc4_:String = null;
         var _loc5_:TweenLite = null;
         var _loc3_:Object = {
            "ease":easeNone,
            "overwrite":2,
            "useFrames":this.useFrames,
            "immediateRender":false
         };
         for(_loc4_ in vars)
         {
            _loc3_[_loc4_] = vars[_loc4_];
         }
         _loc3_.onInit = onInitTweenTo;
         _loc3_.onInitParams = [null,this,NaN];
         _loc3_.currentTime = parseTimeOrLabel(timeOrLabel);
         _loc5_ = new TweenLite(this,Math.abs(Number(_loc3_.currentTime) - this.cachedTime) / this.cachedTimeScale || 0.001,_loc3_);
         _loc5_.vars.onInitParams[0] = _loc5_;
         return _loc5_;
      }
      
      public function hasEventListener(type:String) : Boolean
      {
         return _dispatcher == null ? false : _dispatcher.hasEventListener(type);
      }
      
      protected function initDispatcher() : void
      {
         if(_dispatcher == null)
         {
            _dispatcher = new EventDispatcher(this);
         }
         if(this.vars.onStartListener is Function)
         {
            _dispatcher.addEventListener(TweenEvent.START,this.vars.onStartListener,false,0,true);
         }
         if(this.vars.onUpdateListener is Function)
         {
            _dispatcher.addEventListener(TweenEvent.UPDATE,this.vars.onUpdateListener,false,0,true);
            _hasUpdateListener = true;
         }
         if(this.vars.onCompleteListener is Function)
         {
            _dispatcher.addEventListener(TweenEvent.COMPLETE,this.vars.onCompleteListener,false,0,true);
         }
         if(this.vars.onRepeatListener is Function)
         {
            _dispatcher.addEventListener(TweenEvent.REPEAT,this.vars.onRepeatListener,false,0,true);
         }
         if(this.vars.onReverseCompleteListener is Function)
         {
            _dispatcher.addEventListener(TweenEvent.REVERSE_COMPLETE,this.vars.onReverseCompleteListener,false,0,true);
         }
      }
      
      public function get repeat() : int
      {
         return _repeat;
      }
      
      public function getLabelBefore(time:Number = NaN) : String
      {
         if(!time && time != 0)
         {
            time = this.cachedTime;
         }
         var _loc2_:Array = getLabelsArray();
         var _loc3_:int = int(_loc2_.length);
         while(--_loc3_ > -1)
         {
            if(_loc2_[_loc3_].time < time)
            {
               return _loc2_[_loc3_].name;
            }
         }
         return null;
      }
      
      public function willTrigger(type:String) : Boolean
      {
         return _dispatcher == null ? false : _dispatcher.willTrigger(type);
      }
      
      public function get totalProgress() : Number
      {
         return this.cachedTotalTime / this.totalDuration;
      }
      
      public function set totalProgress(n:Number) : void
      {
         setTotalTime(this.totalDuration * n,false);
      }
      
      protected function getLabelsArray() : Array
      {
         var _loc2_:String = null;
         var _loc1_:Array = [];
         for(_loc2_ in _labels)
         {
            _loc1_[_loc1_.length] = {
               "time":_labels[_loc2_],
               "name":_loc2_
            };
         }
         _loc1_.sortOn("time",Array.NUMERIC);
         return _loc1_;
      }
      
      public function removeCallback(callback:Function, timeOrLabel:* = null) : Boolean
      {
         var _loc3_:Array = null;
         var _loc4_:Boolean = false;
         var _loc5_:int = 0;
         if(timeOrLabel == null)
         {
            return killTweensOf(callback,false);
         }
         if(typeof timeOrLabel == "string")
         {
            if(!(timeOrLabel in _labels))
            {
               return false;
            }
            timeOrLabel = _labels[timeOrLabel];
         }
         _loc3_ = getTweensOf(callback,false);
         _loc5_ = int(_loc3_.length);
         while(--_loc5_ > -1)
         {
            if(_loc3_[_loc5_].cachedStartTime == timeOrLabel)
            {
               remove(_loc3_[_loc5_] as TweenCore);
               _loc4_ = true;
            }
         }
         return _loc4_;
      }
      
      public function get repeatDelay() : Number
      {
         return _repeatDelay;
      }
      
      public function set repeatDelay(n:Number) : void
      {
         _repeatDelay = n;
         setDirtyCache(true);
      }
      
      public function set repeat(n:int) : void
      {
         _repeat = n;
         setDirtyCache(true);
      }
      
      override public function get totalDuration() : Number
      {
         var _loc1_:Number = NaN;
         if(this.cacheIsDirty)
         {
            _loc1_ = super.totalDuration;
            this.cachedTotalDuration = _repeat == -1 ? 999999999999 : this.cachedDuration * (_repeat + 1) + _repeatDelay * _repeat;
         }
         return this.cachedTotalDuration;
      }
      
      override public function complete(skipRender:Boolean = false, suppressEvents:Boolean = false) : void
      {
         super.complete(skipRender,suppressEvents);
         if(Boolean(_dispatcher) && !suppressEvents)
         {
            if(this.cachedReversed && this.cachedTotalTime == 0 && this.cachedDuration != 0)
            {
               _dispatcher.dispatchEvent(new TweenEvent(TweenEvent.REVERSE_COMPLETE));
            }
            else
            {
               _dispatcher.dispatchEvent(new TweenEvent(TweenEvent.COMPLETE));
            }
         }
      }
      
      override public function invalidate() : void
      {
         _repeat = this.vars.repeat ? int(Number(this.vars.repeat)) : 0;
         _repeatDelay = this.vars.repeatDelay ? Number(this.vars.repeatDelay) : 0;
         this.yoyo = Boolean(this.vars.yoyo == true);
         if(this.vars.onCompleteListener != null || this.vars.onUpdateListener != null || this.vars.onStartListener != null || this.vars.onRepeatListener != null || this.vars.onReverseCompleteListener != null)
         {
            initDispatcher();
         }
         setDirtyCache(true);
         super.invalidate();
      }
      
      public function getActive(nested:Boolean = true, tweens:Boolean = true, timelines:Boolean = false) : Array
      {
         var _loc6_:int = 0;
         var _loc7_:TweenCore = null;
         var _loc4_:Array = [];
         var _loc5_:Array = getChildren(nested,tweens,timelines);
         var _loc8_:int = int(_loc5_.length);
         var _loc9_:* = 0;
         _loc6_ = 0;
         while(_loc6_ < _loc8_)
         {
            _loc7_ = _loc5_[_loc6_];
            if(!_loc7_.cachedPaused && _loc7_.timeline.cachedTotalTime >= _loc7_.cachedStartTime && _loc7_.timeline.cachedTotalTime < _loc7_.cachedStartTime + _loc7_.cachedTotalDuration / _loc7_.cachedTimeScale && !OverwriteManager.getGlobalPaused(_loc7_.timeline))
            {
               var _loc10_:Number;
               _loc4_[_loc10_ = _loc9_++] = _loc5_[_loc6_];
            }
            _loc6_ += 1;
         }
         return _loc4_;
      }
      
      public function getLabelAfter(time:Number = NaN) : String
      {
         if(!time && time != 0)
         {
            time = this.cachedTime;
         }
         var _loc2_:Array = getLabelsArray();
         var _loc3_:int = int(_loc2_.length);
         var _loc4_:int = 0;
         while(_loc4_ < _loc3_)
         {
            if(_loc2_[_loc4_].time > time)
            {
               return _loc2_[_loc4_].name;
            }
            _loc4_ += 1;
         }
         return null;
      }
   }
}

