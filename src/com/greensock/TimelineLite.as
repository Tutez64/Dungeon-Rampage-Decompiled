package com.greensock
{
   import com.greensock.core.*;
   
   public class TimelineLite extends SimpleTimeline
   {
      
      public static const version:Number = 1.66;
      
      private static var _overwriteMode:int = OverwriteManager.enabled ? OverwriteManager.mode : OverwriteManager.init(2);
      
      protected var _endCaps:Array;
      
      protected var _labels:Object;
      
      public function TimelineLite(vars:Object = null)
      {
         super(vars);
         _endCaps = [null,null];
         _labels = {};
         this.autoRemoveChildren = Boolean(this.vars.autoRemoveChildren == true);
         _hasUpdate = Boolean(typeof this.vars.onUpdate == "function");
         if(this.vars.tweens is Array)
         {
            this.insertMultiple(this.vars.tweens,0,this.vars.align != null ? this.vars.align : "normal",this.vars.stagger ? Number(this.vars.stagger) : 0);
         }
      }
      
      public function set timeScale(n:Number) : void
      {
         if(n == 0)
         {
            n = 0.0001;
         }
         var _loc2_:Number = Boolean(this.cachedPauseTime) || this.cachedPauseTime == 0 ? this.cachedPauseTime : this.timeline.cachedTotalTime;
         this.cachedStartTime = _loc2_ - (_loc2_ - this.cachedStartTime) * this.cachedTimeScale / n;
         this.cachedTimeScale = n;
         setDirtyCache(false);
      }
      
      public function stop() : void
      {
         this.paused = true;
      }
      
      override public function renderTime(time:Number, suppressEvents:Boolean = false, force:Boolean = false) : void
      {
         var _loc8_:TweenCore = null;
         var _loc9_:Boolean = false;
         var _loc10_:Boolean = false;
         var _loc11_:TweenCore = null;
         var _loc12_:Number = NaN;
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
         var _loc6_:Number = this.cachedStartTime;
         var _loc7_:Number = this.cachedTimeScale;
         var _loc13_:Boolean = this.cachedPaused;
         if(time >= _loc4_)
         {
            if(_rawPrevTime <= _loc4_ && _rawPrevTime != time)
            {
               this.cachedTotalTime = this.cachedTime = _loc4_;
               forceChildrenToEnd(_loc4_,suppressEvents);
               _loc9_ = !this.hasPausedChild();
               _loc10_ = true;
               if(this.cachedDuration == 0 && _loc9_ && (time == 0 || _rawPrevTime < 0))
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
                  _loc9_ = true;
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
               _loc10_ = true;
               if(this.cachedReversed)
               {
                  _loc9_ = true;
               }
            }
         }
         else
         {
            this.cachedTotalTime = this.cachedTime = time;
         }
         _rawPrevTime = time;
         if(this.cachedTime == _loc5_ && !force)
         {
            return;
         }
         if(!this.initted)
         {
            this.initted = true;
         }
         if(Boolean(_loc5_ == 0 && this.vars.onStart) && Boolean(this.cachedTime != 0) && !suppressEvents)
         {
            this.vars.onStart.apply(null,this.vars.onStartParams);
         }
         if(!_loc10_)
         {
            if(this.cachedTime - _loc5_ > 0)
            {
               _loc8_ = _firstChild;
               while(_loc8_)
               {
                  _loc11_ = _loc8_.nextNode;
                  if(this.cachedPaused && !_loc13_)
                  {
                     break;
                  }
                  if(_loc8_.active || !_loc8_.cachedPaused && _loc8_.cachedStartTime <= this.cachedTime && !_loc8_.gc)
                  {
                     if(!_loc8_.cachedReversed)
                     {
                        _loc8_.renderTime((this.cachedTime - _loc8_.cachedStartTime) * _loc8_.cachedTimeScale,suppressEvents,false);
                     }
                     else
                     {
                        _loc12_ = _loc8_.cacheIsDirty ? _loc8_.totalDuration : _loc8_.cachedTotalDuration;
                        _loc8_.renderTime(_loc12_ - (this.cachedTime - _loc8_.cachedStartTime) * _loc8_.cachedTimeScale,suppressEvents,false);
                     }
                  }
                  _loc8_ = _loc11_;
               }
            }
            else
            {
               _loc8_ = _lastChild;
               while(_loc8_)
               {
                  _loc11_ = _loc8_.prevNode;
                  if(this.cachedPaused && !_loc13_)
                  {
                     break;
                  }
                  if(_loc8_.active || !_loc8_.cachedPaused && _loc8_.cachedStartTime <= _loc5_ && !_loc8_.gc)
                  {
                     if(!_loc8_.cachedReversed)
                     {
                        _loc8_.renderTime((this.cachedTime - _loc8_.cachedStartTime) * _loc8_.cachedTimeScale,suppressEvents,false);
                     }
                     else
                     {
                        _loc12_ = _loc8_.cacheIsDirty ? _loc8_.totalDuration : _loc8_.cachedTotalDuration;
                        _loc8_.renderTime(_loc12_ - (this.cachedTime - _loc8_.cachedStartTime) * _loc8_.cachedTimeScale,suppressEvents,false);
                     }
                  }
                  _loc8_ = _loc11_;
               }
            }
         }
         if(_hasUpdate && !suppressEvents)
         {
            this.vars.onUpdate.apply(null,this.vars.onUpdateParams);
         }
         if(_loc9_ && (_loc6_ == this.cachedStartTime || _loc7_ != this.cachedTimeScale) && (_loc4_ >= this.totalDuration || this.cachedTime == 0))
         {
            complete(true,suppressEvents);
         }
      }
      
      override public function remove(tween:TweenCore, skipDisable:Boolean = false) : void
      {
         if(tween.cachedOrphan)
         {
            return;
         }
         if(!skipDisable)
         {
            tween.setEnabled(false,true);
         }
         var _loc3_:TweenCore = this.gc ? _endCaps[0] : _firstChild;
         var _loc4_:TweenCore = this.gc ? _endCaps[1] : _lastChild;
         if(tween.nextNode)
         {
            tween.nextNode.prevNode = tween.prevNode;
         }
         else if(_loc4_ == tween)
         {
            _loc4_ = tween.prevNode;
         }
         if(tween.prevNode)
         {
            tween.prevNode.nextNode = tween.nextNode;
         }
         else if(_loc3_ == tween)
         {
            _loc3_ = tween.nextNode;
         }
         if(this.gc)
         {
            _endCaps[0] = _loc3_;
            _endCaps[1] = _loc4_;
         }
         else
         {
            _firstChild = _loc3_;
            _lastChild = _loc4_;
         }
         tween.cachedOrphan = true;
         setDirtyCache(true);
      }
      
      public function get currentProgress() : Number
      {
         return this.cachedTime / this.duration;
      }
      
      override public function get totalDuration() : Number
      {
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc3_:TweenCore = null;
         var _loc4_:Number = NaN;
         var _loc5_:TweenCore = null;
         if(this.cacheIsDirty)
         {
            _loc1_ = 0;
            _loc3_ = this.gc ? _endCaps[0] : _firstChild;
            _loc4_ = -Infinity;
            while(_loc3_)
            {
               _loc5_ = _loc3_.nextNode;
               if(_loc3_.cachedStartTime < _loc4_)
               {
                  this.insert(_loc3_,_loc3_.cachedStartTime - _loc3_.delay);
                  _loc4_ = _loc3_.prevNode.cachedStartTime;
               }
               else
               {
                  _loc4_ = _loc3_.cachedStartTime;
               }
               if(_loc3_.cachedStartTime < 0)
               {
                  _loc1_ -= _loc3_.cachedStartTime;
                  this.shiftChildren(-_loc3_.cachedStartTime,false,-9999999999);
               }
               _loc2_ = _loc3_.cachedStartTime + _loc3_.totalDuration / _loc3_.cachedTimeScale;
               if(_loc2_ > _loc1_)
               {
                  _loc1_ = _loc2_;
               }
               _loc3_ = _loc5_;
            }
            this.cachedDuration = this.cachedTotalDuration = _loc1_;
            this.cacheIsDirty = false;
         }
         return this.cachedTotalDuration;
      }
      
      public function gotoAndPlay(timeOrLabel:*, suppressEvents:Boolean = true) : void
      {
         setTotalTime(parseTimeOrLabel(timeOrLabel),suppressEvents);
         play();
      }
      
      public function appendMultiple(tweens:Array, offset:Number = 0, align:String = "normal", stagger:Number = 0) : Array
      {
         return insertMultiple(tweens,this.duration + offset,align,stagger);
      }
      
      public function set currentProgress(n:Number) : void
      {
         setTotalTime(this.duration * n,false);
      }
      
      public function clear(tweens:Array = null) : void
      {
         if(tweens == null)
         {
            tweens = getChildren(false,true,true);
         }
         var _loc2_:int = int(tweens.length);
         while(--_loc2_ > -1)
         {
            TweenCore(tweens[_loc2_]).setEnabled(false,false);
         }
      }
      
      public function prepend(tween:TweenCore, adjustLabels:Boolean = false) : TweenCore
      {
         shiftChildren(tween.totalDuration / tween.cachedTimeScale + tween.delay,adjustLabels,0);
         return insert(tween,0);
      }
      
      public function removeLabel(label:String) : Number
      {
         var _loc2_:Number = Number(_labels[label]);
         delete _labels[label];
         return _loc2_;
      }
      
      protected function parseTimeOrLabel(timeOrLabel:*) : Number
      {
         if(typeof timeOrLabel == "string")
         {
            if(!(timeOrLabel in _labels))
            {
               throw new Error("TimelineLite error: the " + timeOrLabel + " label was not found.");
            }
            return getLabelTime(String(timeOrLabel));
         }
         return Number(timeOrLabel);
      }
      
      public function addLabel(label:String, time:Number) : void
      {
         _labels[label] = time;
      }
      
      public function hasPausedChild() : Boolean
      {
         var _loc1_:TweenCore = this.gc ? _endCaps[0] : _firstChild;
         while(_loc1_)
         {
            if(_loc1_.cachedPaused || _loc1_ is TimelineLite && (_loc1_ as TimelineLite).hasPausedChild())
            {
               return true;
            }
            _loc1_ = _loc1_.nextNode;
         }
         return false;
      }
      
      public function getTweensOf(target:Object, nested:Boolean = true) : Array
      {
         var _loc5_:int = 0;
         var _loc3_:Array = getChildren(nested,true,false);
         var _loc4_:Array = [];
         var _loc6_:int = int(_loc3_.length);
         var _loc7_:* = 0;
         _loc5_ = 0;
         while(_loc5_ < _loc6_)
         {
            if(TweenLite(_loc3_[_loc5_]).target == target)
            {
               var _loc8_:Number;
               _loc4_[_loc8_ = _loc7_++] = _loc3_[_loc5_];
            }
            _loc5_ += 1;
         }
         return _loc4_;
      }
      
      public function gotoAndStop(timeOrLabel:*, suppressEvents:Boolean = true) : void
      {
         setTotalTime(parseTimeOrLabel(timeOrLabel),suppressEvents);
         this.paused = true;
      }
      
      public function append(tween:TweenCore, offset:Number = 0) : TweenCore
      {
         return insert(tween,this.duration + offset);
      }
      
      override public function get duration() : Number
      {
         var _loc1_:Number = NaN;
         if(this.cacheIsDirty)
         {
            _loc1_ = this.totalDuration;
         }
         return this.cachedDuration;
      }
      
      public function get useFrames() : Boolean
      {
         var _loc1_:SimpleTimeline = this.timeline;
         while(_loc1_.timeline)
         {
            _loc1_ = _loc1_.timeline;
         }
         return Boolean(_loc1_ == TweenLite.rootFramesTimeline);
      }
      
      public function shiftChildren(amount:Number, adjustLabels:Boolean = false, ignoreBeforeTime:Number = 0) : void
      {
         var _loc5_:String = null;
         var _loc4_:TweenCore = this.gc ? _endCaps[0] : _firstChild;
         while(_loc4_)
         {
            if(_loc4_.cachedStartTime >= ignoreBeforeTime)
            {
               _loc4_.cachedStartTime += amount;
            }
            _loc4_ = _loc4_.nextNode;
         }
         if(adjustLabels)
         {
            for(_loc5_ in _labels)
            {
               if(_labels[_loc5_] >= ignoreBeforeTime)
               {
                  _labels[_loc5_] += amount;
               }
            }
         }
         this.setDirtyCache(true);
      }
      
      public function seek(timeOrLabel:*, suppressEvents:Boolean = true) : void
      {
         setTotalTime(parseTimeOrLabel(timeOrLabel),suppressEvents);
      }
      
      public function killTweensOf(target:Object, nested:Boolean = true, vars:Object = null) : Boolean
      {
         var _loc6_:TweenLite = null;
         var _loc4_:Array = getTweensOf(target,nested);
         var _loc5_:int = int(_loc4_.length);
         while(--_loc5_ > -1)
         {
            _loc6_ = _loc4_[_loc5_];
            if(vars != null)
            {
               _loc6_.killVars(vars);
            }
            if(vars == null || _loc6_.cachedPT1 == null && _loc6_.initted)
            {
               _loc6_.setEnabled(false,false);
            }
         }
         return Boolean(_loc4_.length > 0);
      }
      
      override public function set duration(n:Number) : void
      {
         if(this.duration != 0 && n != 0)
         {
            this.timeScale = this.duration / n;
         }
      }
      
      public function insertMultiple(tweens:Array, timeOrLabel:* = 0, align:String = "normal", stagger:Number = 0) : Array
      {
         var _loc5_:int = 0;
         var _loc6_:TweenCore = null;
         var _loc7_:Number = Number(Number(timeOrLabel) || 0);
         var _loc8_:int = int(tweens.length);
         if(typeof timeOrLabel == "string")
         {
            if(!(timeOrLabel in _labels))
            {
               addLabel(timeOrLabel,this.duration);
            }
            _loc7_ = Number(_labels[timeOrLabel]);
         }
         _loc5_ = 0;
         while(_loc5_ < _loc8_)
         {
            _loc6_ = tweens[_loc5_] as TweenCore;
            insert(_loc6_,_loc7_);
            if(align == "sequence")
            {
               _loc7_ = _loc6_.cachedStartTime + _loc6_.totalDuration / _loc6_.cachedTimeScale;
            }
            else if(align == "start")
            {
               _loc6_.cachedStartTime -= _loc6_.delay;
            }
            _loc7_ += stagger;
            _loc5_ += 1;
         }
         return tweens;
      }
      
      public function getLabelTime(label:String) : Number
      {
         return label in _labels ? Number(_labels[label]) : -1;
      }
      
      override public function get rawTime() : Number
      {
         if(this.cachedTotalTime != 0 && this.cachedTotalTime != this.cachedTotalDuration)
         {
            return this.cachedTotalTime;
         }
         return (this.timeline.rawTime - this.cachedStartTime) * this.cachedTimeScale;
      }
      
      override public function set totalDuration(n:Number) : void
      {
         if(this.totalDuration != 0 && n != 0)
         {
            this.timeScale = this.totalDuration / n;
         }
      }
      
      public function getChildren(nested:Boolean = true, tweens:Boolean = true, timelines:Boolean = true, ignoreBeforeTime:Number = -9999999999) : Array
      {
         var _loc5_:Array = [];
         var _loc6_:* = 0;
         var _loc7_:TweenCore = this.gc ? _endCaps[0] : _firstChild;
         while(_loc7_)
         {
            if(_loc7_.cachedStartTime >= ignoreBeforeTime)
            {
               if(_loc7_ is TweenLite)
               {
                  if(tweens)
                  {
                     var _loc8_:Number;
                     _loc5_[_loc8_ = _loc6_++] = _loc7_;
                  }
               }
               else
               {
                  if(timelines)
                  {
                     _loc5_[_loc8_ = _loc6_++] = _loc7_;
                  }
                  if(nested)
                  {
                     _loc5_ = _loc5_.concat(TimelineLite(_loc7_).getChildren(true,tweens,timelines));
                     _loc6_ = int(_loc5_.length);
                  }
               }
            }
            _loc7_ = _loc7_.nextNode;
         }
         return _loc5_;
      }
      
      protected function forceChildrenToEnd(time:Number, suppressEvents:Boolean = false) : Number
      {
         var _loc4_:TweenCore = null;
         var _loc5_:Number = NaN;
         var _loc3_:TweenCore = _firstChild;
         var _loc6_:Boolean = this.cachedPaused;
         while(_loc3_)
         {
            _loc4_ = _loc3_.nextNode;
            if(this.cachedPaused && !_loc6_)
            {
               break;
            }
            if(_loc3_.active || !_loc3_.cachedPaused && !_loc3_.gc && (_loc3_.cachedTotalTime != _loc3_.cachedTotalDuration || _loc3_.cachedDuration == 0))
            {
               if(time == this.cachedDuration && (_loc3_.cachedDuration != 0 || _loc3_.cachedStartTime == this.cachedDuration))
               {
                  _loc3_.renderTime(_loc3_.cachedReversed ? 0 : _loc3_.cachedTotalDuration,suppressEvents,false);
               }
               else if(!_loc3_.cachedReversed)
               {
                  _loc3_.renderTime((time - _loc3_.cachedStartTime) * _loc3_.cachedTimeScale,suppressEvents,false);
               }
               else
               {
                  _loc5_ = _loc3_.cacheIsDirty ? _loc3_.totalDuration : _loc3_.cachedTotalDuration;
                  _loc3_.renderTime(_loc5_ - (time - _loc3_.cachedStartTime) * _loc3_.cachedTimeScale,suppressEvents,false);
               }
            }
            _loc3_ = _loc4_;
         }
         return time;
      }
      
      protected function forceChildrenToBeginning(time:Number, suppressEvents:Boolean = false) : Number
      {
         var _loc4_:TweenCore = null;
         var _loc5_:Number = NaN;
         var _loc3_:TweenCore = _lastChild;
         var _loc6_:Boolean = this.cachedPaused;
         while(_loc3_)
         {
            _loc4_ = _loc3_.prevNode;
            if(this.cachedPaused && !_loc6_)
            {
               break;
            }
            if(_loc3_.active || !_loc3_.cachedPaused && !_loc3_.gc && (_loc3_.cachedTotalTime != 0 || _loc3_.cachedDuration == 0))
            {
               if(time == 0 && (_loc3_.cachedDuration != 0 || _loc3_.cachedStartTime == 0))
               {
                  _loc3_.renderTime(_loc3_.cachedReversed ? _loc3_.cachedTotalDuration : 0,suppressEvents,false);
               }
               else if(!_loc3_.cachedReversed)
               {
                  _loc3_.renderTime((time - _loc3_.cachedStartTime) * _loc3_.cachedTimeScale,suppressEvents,false);
               }
               else
               {
                  _loc5_ = _loc3_.cacheIsDirty ? _loc3_.totalDuration : _loc3_.cachedTotalDuration;
                  _loc3_.renderTime(_loc5_ - (time - _loc3_.cachedStartTime) * _loc3_.cachedTimeScale,suppressEvents,false);
               }
            }
            _loc3_ = _loc4_;
         }
         return time;
      }
      
      override public function insert(tween:TweenCore, timeOrLabel:* = 0) : TweenCore
      {
         var _loc5_:TweenCore = null;
         var _loc6_:Number = NaN;
         var _loc7_:SimpleTimeline = null;
         if(typeof timeOrLabel == "string")
         {
            if(!(timeOrLabel in _labels))
            {
               addLabel(timeOrLabel,this.duration);
            }
            timeOrLabel = Number(_labels[timeOrLabel]);
         }
         if(!tween.cachedOrphan && Boolean(tween.timeline))
         {
            tween.timeline.remove(tween,true);
         }
         tween.timeline = this;
         tween.cachedStartTime = Number(timeOrLabel) + tween.delay;
         if(tween.cachedPaused)
         {
            tween.cachedPauseTime = tween.cachedStartTime + (this.rawTime - tween.cachedStartTime) / tween.cachedTimeScale;
         }
         if(tween.gc)
         {
            tween.setEnabled(true,true);
         }
         setDirtyCache(true);
         var _loc3_:TweenCore = this.gc ? _endCaps[0] : _firstChild;
         var _loc4_:TweenCore = this.gc ? _endCaps[1] : _lastChild;
         if(_loc4_ == null)
         {
            _loc3_ = _loc4_ = tween;
            tween.nextNode = tween.prevNode = null;
         }
         else
         {
            _loc5_ = _loc4_;
            _loc6_ = tween.cachedStartTime;
            while(_loc5_ != null && _loc6_ < _loc5_.cachedStartTime)
            {
               _loc5_ = _loc5_.prevNode;
            }
            if(_loc5_ == null)
            {
               _loc3_.prevNode = tween;
               tween.nextNode = _loc3_;
               tween.prevNode = null;
               _loc3_ = tween;
            }
            else
            {
               if(_loc5_.nextNode)
               {
                  _loc5_.nextNode.prevNode = tween;
               }
               else if(_loc5_ == _loc4_)
               {
                  _loc4_ = tween;
               }
               tween.prevNode = _loc5_;
               tween.nextNode = _loc5_.nextNode;
               _loc5_.nextNode = tween;
            }
         }
         tween.cachedOrphan = false;
         if(this.gc)
         {
            _endCaps[0] = _loc3_;
            _endCaps[1] = _loc4_;
         }
         else
         {
            _firstChild = _loc3_;
            _lastChild = _loc4_;
         }
         if(this.gc && !this.cachedPaused && this.cachedStartTime + (tween.cachedStartTime + tween.cachedTotalDuration / tween.cachedTimeScale) / this.cachedTimeScale > this.timeline.cachedTime)
         {
            if(this.timeline == TweenLite.rootTimeline || this.timeline == TweenLite.rootFramesTimeline)
            {
               this.setTotalTime(this.cachedTotalTime,true);
            }
            this.setEnabled(true,false);
            _loc7_ = this.timeline;
            while(_loc7_.gc && Boolean(_loc7_.timeline))
            {
               if(_loc7_.cachedStartTime + _loc7_.totalDuration / _loc7_.cachedTimeScale > _loc7_.timeline.cachedTime)
               {
                  _loc7_.setEnabled(true,false);
               }
               _loc7_ = _loc7_.timeline;
            }
         }
         return tween;
      }
      
      override public function invalidate() : void
      {
         var _loc1_:TweenCore = this.gc ? _endCaps[0] : _firstChild;
         while(_loc1_)
         {
            _loc1_.invalidate();
            _loc1_ = _loc1_.nextNode;
         }
      }
      
      public function get timeScale() : Number
      {
         return this.cachedTimeScale;
      }
      
      public function prependMultiple(tweens:Array, align:String = "normal", stagger:Number = 0, adjustLabels:Boolean = false) : Array
      {
         var _loc5_:TimelineLite = new TimelineLite({
            "tweens":tweens,
            "align":align,
            "stagger":stagger
         });
         shiftChildren(_loc5_.duration,adjustLabels,0);
         insertMultiple(tweens,0,align,stagger);
         _loc5_.kill();
         return tweens;
      }
      
      override public function setEnabled(enabled:Boolean, ignoreTimeline:Boolean = false) : Boolean
      {
         var _loc3_:TweenCore = null;
         if(enabled == this.gc)
         {
            if(enabled)
            {
               _firstChild = _loc3_ = _endCaps[0];
               _lastChild = _endCaps[1];
               _endCaps = [null,null];
            }
            else
            {
               _loc3_ = _firstChild;
               _endCaps = [_firstChild,_lastChild];
               _firstChild = _lastChild = null;
            }
            while(_loc3_)
            {
               _loc3_.setEnabled(enabled,true);
               _loc3_ = _loc3_.nextNode;
            }
         }
         return super.setEnabled(enabled,ignoreTimeline);
      }
   }
}

