package starling.extensions.animate
{
   import flash.geom.Point;
   import starling.animation.IAnimatable;
   import starling.display.DisplayObjectContainer;
   
   public class Animation extends DisplayObjectContainer implements IAnimatable
   {
      
      private static const STEP_CLIPS:int = -1;
      
      private static const STEP_RESET_CLIPS:int = -2;
      
      private static const STEP_PLAY_ONCE:int = -3;
      
      private static const STEP_CLEAR_PLAY_ONCE:int = -4;
      
      private static const STEP_CLIPS_BY:int = -4;
      
      private static const MAX_SKIPPED_STEPS:int = 100000;
      
      private var _symbol:Symbol;
      
      private var _labels:LabelTable;
      
      private var _behavior:MovieBehavior;
      
      private var _atlas:AnimationAtlas;
      
      private var _cumulatedTime:Number = 0;
      
      private var _pendingComplete:Boolean = false;
      
      private var _deferredCompleteFrames:int = 0;
      
      private var _composing:Boolean = true;
      
      private var _skippedSteps:Vector.<int> = new Vector.<int>(0);
      
      private var _pendingCompleteDeadline:int = -1;
      
      private var _waitForNestedClips:Boolean = true;
      
      private var _labelStart:int = -1;
      
      private var _labelEnd:int = -1;
      
      private var _labelName:String;
      
      private var _labelLoop:Boolean = true;
      
      private var _labelCompleteDispatched:Boolean = false;
      
      private var _rootWrapFrame:int = 0;
      
      public function Animation(symbolName:String, atlas:AnimationAtlas)
      {
         super();
         _atlas = atlas;
         var _loc4_:Object = atlas.getSymbolData(symbolName);
         _labels = atlas.getLabelTable(_loc4_);
         _symbol = new Symbol(_loc4_,atlas);
         _symbol.update();
         addChild(_symbol);
         _behavior = new MovieBehavior(this,onFrameChanged,atlas.frameRate);
         _behavior.numFrames = _symbol.numFrames;
         _behavior.addEventListener("complete",onComplete);
         var _loc3_:int = _symbol.getFrame("loop");
         _rootWrapFrame = _loc3_ > 0 ? _loc3_ : 0;
         _behavior.wrapFrame = _rootWrapFrame;
         play();
      }
      
      private function onComplete() : void
      {
         if(_labelStart >= 0 && !_labelLoop && _labelCompleteDispatched)
         {
            return;
         }
         if(!hasEventListener("complete"))
         {
            return;
         }
         replaySkippedSteps();
         if(!_waitForNestedClips || _symbol.areMovieClipsAtFinal())
         {
            dispatchEventWith("complete");
         }
         else
         {
            _pendingComplete = true;
            _pendingCompleteDeadline = int(_cumulatedTime * _behavior.frameRate) + Math.max(0,_symbol.deepestFrameCount - _behavior.numFrames);
         }
      }
      
      private function onFrameChanged(frameIndex:int) : void
      {
         if(_labelStart >= 0 && (frameIndex < _labelStart || frameIndex > _labelEnd))
         {
            _behavior.currentFrame = _labelLoop ? _labelStart : _labelEnd;
            return;
         }
         if(_composing)
         {
            _symbol.currentFrame = frameIndex;
         }
         else
         {
            skipStep(frameIndex);
         }
         if(_labelStart >= 0 && !_labelLoop && frameIndex >= _labelEnd)
         {
            _behavior.pause();
            if(!_labelCompleteDispatched)
            {
               _labelCompleteDispatched = true;
               _deferredCompleteFrames = 2;
            }
         }
      }
      
      public function setColorMatrix(matrix:Vector.<Number>) : void
      {
         _symbol.setInheritedColor(matrix);
      }
      
      public function get pixelSnapping() : Boolean
      {
         return _symbol.pixelSnapping;
      }
      
      public function set pixelSnapping(value:Boolean) : void
      {
         _symbol.pixelSnapping = value;
      }
      
      public function setMovieClipsPlayOnce() : void
      {
         if(_composing)
         {
            _symbol.setMovieClipLoopMode("playonce");
         }
         else
         {
            skipStep(-3);
         }
      }
      
      public function resetMovieClips() : void
      {
         if(_composing)
         {
            _symbol.resetMovieClips();
         }
         else
         {
            skipStep(-2);
         }
      }
      
      public function clearMovieClipsPlayOnce() : void
      {
         if(_composing)
         {
            _symbol.clearMovieClipsPlayOnce();
         }
         else
         {
            skipStep(-4);
         }
      }
      
      public function play() : void
      {
         _pendingComplete = false;
         _deferredCompleteFrames = 0;
         _behavior.play();
      }
      
      public function pause() : void
      {
         _pendingComplete = false;
         _deferredCompleteFrames = 0;
         _behavior.pause();
      }
      
      public function stop() : void
      {
         _pendingComplete = false;
         _deferredCompleteFrames = 0;
         var _loc1_:int = _labelStart;
         clearLabel();
         _behavior.stop();
         if(_loc1_ > 0)
         {
            _behavior.currentFrame = _loc1_;
         }
      }
      
      public function gotoFrame(index:int) : void
      {
         _pendingComplete = false;
         _deferredCompleteFrames = 0;
         clearLabel();
         currentFrame = index;
      }
      
      public function gotoLabel(label:String, loop:Boolean = true, startFrame:int = -1) : Point
      {
         _pendingComplete = false;
         _deferredCompleteFrames = 0;
         var _loc4_:int = _labels.getFrame(label);
         if(_loc4_ < 0)
         {
            clearLabel();
            return new Point(-1,-1);
         }
         var _loc5_:int = _labels.getEnd(label);
         _labelName = label;
         _labelStart = _loc4_;
         _labelEnd = _loc5_;
         _labelLoop = loop;
         _labelCompleteDispatched = false;
         _behavior.wrapFrame = loop ? _loc4_ : _rootWrapFrame;
         var _loc6_:int = startFrame >= 0 ? startFrame : _loc4_;
         if(_loc6_ < _loc4_)
         {
            _loc6_ = _loc4_;
         }
         if(_loc6_ > _loc5_)
         {
            _loc6_ = _loc5_;
         }
         var _loc7_:Boolean = !loop && _loc6_ >= _loc5_;
         currentFrame = _loc6_;
         if(!_loc7_)
         {
            play();
         }
         else if(!_labelCompleteDispatched)
         {
            _behavior.pause();
            _labelCompleteDispatched = true;
            _deferredCompleteFrames = 2;
         }
         return new Point(_loc4_,_loc5_);
      }
      
      public function clearLabel() : void
      {
         _labelName = null;
         _labelStart = _labelEnd = -1;
         _labelLoop = true;
         _labelCompleteDispatched = false;
         _behavior.wrapFrame = _rootWrapFrame;
      }
      
      public function get heldLabel() : String
      {
         return _labelName;
      }
      
      public function addFrameAction(index:int, action:Function) : void
      {
         _behavior.addFrameAction(index,action);
      }
      
      public function removeFrameAction(index:int, action:Function) : void
      {
         _behavior.removeFrameAction(index,action);
      }
      
      public function removeFrameActions(index:int) : void
      {
         _behavior.removeFrameActions(index);
      }
      
      public function get composing() : Boolean
      {
         return _composing;
      }
      
      public function set composing(value:Boolean) : void
      {
         if(value == _composing)
         {
            return;
         }
         _composing = value;
         if(!value)
         {
            return;
         }
         replaySkippedSteps();
         _symbol.currentFrame = _behavior.currentFrame;
      }
      
      public function dropSkippedSteps() : void
      {
         _skippedSteps.length = 0;
      }
      
      private function skipStep(step:int) : void
      {
         if(_skippedSteps.length >= 100000)
         {
            replaySkippedSteps();
         }
         _skippedSteps.push(step);
      }
      
      private function replaySkippedSteps() : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         var _loc1_:int = int(_skippedSteps.length);
         _loc2_ = 0;
         while(_loc2_ < _loc1_)
         {
            _loc3_ = _skippedSteps[_loc2_];
            if(_loc3_ >= 0)
            {
               _symbol.currentFrame = _loc3_;
            }
            else if(_loc3_ == -1)
            {
               _symbol.nextFrame_MovieClips();
            }
            else if(_loc3_ < -4)
            {
               _symbol.nextFrame_MovieClips(-4 - _loc3_);
            }
            else if(_loc3_ == -2)
            {
               _symbol.resetMovieClips();
            }
            else if(_loc3_ == -3)
            {
               _symbol.setMovieClipLoopMode("playonce");
            }
            else
            {
               _symbol.clearMovieClipsPlayOnce();
            }
            _loc2_++;
         }
         _skippedSteps.length = 0;
      }
      
      public function advanceTime(time:Number) : void
      {
         var _loc2_:Number = _behavior.frameRate;
         var _loc3_:int = int((_cumulatedTime + time) * _loc2_) - int(_cumulatedTime * _loc2_);
         if(_loc3_ > 0)
         {
            if(_composing)
            {
               _symbol.nextFrame_MovieClips(_loc3_);
            }
            else
            {
               skipStep(_loc3_ == 1 ? -1 : -4 - _loc3_);
            }
         }
         _behavior.advanceTime(time);
         _cumulatedTime += time;
         if(_pendingComplete)
         {
            replaySkippedSteps();
            if(_symbol.areMovieClipsAtFinal() || int(_cumulatedTime * _loc2_) >= _pendingCompleteDeadline)
            {
               _pendingComplete = false;
               dispatchEventWith("complete");
            }
         }
         if(_deferredCompleteFrames > 0 && --_deferredCompleteFrames == 0)
         {
            dispatchEventWith("complete");
         }
      }
      
      public function getNextLabel(afterLabel:String = null) : String
      {
         return _labels.getNextLabel(afterLabel,_behavior.currentFrame);
      }
      
      public function getFrame(label:String) : int
      {
         return _labels.getFrame(label);
      }
      
      public function getKeyframe(label:String, keyIndex:int) : int
      {
         return _labels.getKeyframe(label,keyIndex);
      }
      
      public function getKeyframeIndex(label:String, frame:int) : int
      {
         return _labels.getKeyframeIndex(label,frame);
      }
      
      public function hasFrameLabelSuffix(suffix:String) : Boolean
      {
         return _symbol.hasFrameLabelSuffix(suffix);
      }
      
      public function hasFrameLabel(label:String) : Boolean
      {
         replaySkippedSteps();
         return _symbol.hasFrameLabel(label);
      }
      
      public function hasFrameLabelNoClamp(label:String) : Boolean
      {
         replaySkippedSteps();
         return _symbol.hasFrameLabelNoClamp(label);
      }
      
      public function advanceMovieClips() : void
      {
         _symbol.nextFrame_MovieClips();
      }
      
      public function get symbolName() : String
      {
         return _symbol.symbolName;
      }
      
      public function get currentLabel() : String
      {
         return _labels.labelAt(_behavior.currentFrame);
      }
      
      public function get currentFrame() : int
      {
         return _behavior.currentFrame;
      }
      
      public function set currentFrame(value:int) : void
      {
         _pendingComplete = false;
         _deferredCompleteFrames = 0;
         _behavior.currentFrame = value;
      }
      
      public function get currentTime() : Number
      {
         return _behavior.currentTime;
      }
      
      public function set currentTime(value:Number) : void
      {
         _pendingComplete = false;
         _deferredCompleteFrames = 0;
         _behavior.currentTime = value;
      }
      
      public function get frameRate() : Number
      {
         return _behavior.frameRate;
      }
      
      public function set frameRate(value:Number) : void
      {
         _behavior.frameRate = value;
      }
      
      public function get loop() : Boolean
      {
         return _behavior.loop;
      }
      
      public function set loop(value:Boolean) : void
      {
         _behavior.loop = value;
      }
      
      public function get numFrames() : int
      {
         return _behavior.numFrames;
      }
      
      public function get deepestFrames() : int
      {
         return _symbol.deepestFrameCount;
      }
      
      public function get isPlaying() : Boolean
      {
         return _behavior.isPlaying;
      }
      
      public function get isAnimating() : Boolean
      {
         return _behavior.isPlaying || _pendingComplete || _deferredCompleteFrames > 0;
      }
      
      public function get isFinished() : Boolean
      {
         return _behavior.finished;
      }
      
      public function get waitForNestedClips() : Boolean
      {
         return _waitForNestedClips;
      }
      
      public function set waitForNestedClips(value:Boolean) : void
      {
         _waitForNestedClips = value;
      }
      
      public function get totalTime() : Number
      {
         return _behavior.totalTime;
      }
      
      public function get sourceWidth() : Number
      {
         return _atlas ? _atlas.sourceWidth : 0;
      }
      
      public function get sourceHeight() : Number
      {
         return _atlas ? _atlas.sourceHeight : 0;
      }
   }
}

