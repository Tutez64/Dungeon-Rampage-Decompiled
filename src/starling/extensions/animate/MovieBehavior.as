package starling.extensions.animate
{
   import starling.animation.IAnimatable;
   import starling.display.DisplayObject;
   import starling.events.EventDispatcher;
   import starling.utils.MathUtil;
   
   internal class MovieBehavior extends EventDispatcher implements IAnimatable
   {
      
      private static const E:Number = 0.00001;
      
      private var _frames:Vector.<MovieFrame>;
      
      private var _numFrames:int;
      
      private var _frameDuration:Number;
      
      private var _currentTime:Number;
      
      private var _currentFrame:int;
      
      private var _loop:Boolean;
      
      private var _wrapFrame:int = 0;
      
      private var _playing:Boolean;
      
      private var _wasStopped:Boolean;
      
      private var _target:DisplayObject;
      
      private var _onFrameChanged:Function;
      
      public function MovieBehavior(target:DisplayObject, onFrameChanged:Function, frameRate:Number = 24)
      {
         super();
         if(frameRate <= 0)
         {
            throw new ArgumentError("Invalid frame rate");
         }
         if(target == null)
         {
            throw new ArgumentError("Target cannot be null");
         }
         if(onFrameChanged == null)
         {
            throw new ArgumentError("Callback cannot be null");
         }
         _target = target;
         _onFrameChanged = onFrameChanged;
         _frameDuration = 1 / frameRate;
         _frames = new Vector.<MovieFrame>(0);
         _loop = true;
         _playing = true;
         _currentTime = 0;
         _currentFrame = 0;
         _wasStopped = true;
      }
      
      public function play() : void
      {
         _playing = true;
      }
      
      public function pause() : void
      {
         _playing = false;
      }
      
      public function stop() : void
      {
         _playing = false;
         _wasStopped = true;
         currentFrame = 0;
      }
      
      public function addFrameAction(index:int, action:Function) : void
      {
         var _loc3_:MovieFrame = findFrameAt(index);
         if(action == null)
         {
            throw new ArgumentError("action cannot be null");
         }
         if(_loc3_ == null)
         {
            if(index >= _frames.length)
            {
               _frames.length = index + 1;
            }
            _loc3_ = _frames[index] = new MovieFrame();
         }
         _loc3_.addAction(action);
      }
      
      public function removeFrameAction(index:int, action:Function) : void
      {
         var _loc3_:MovieFrame = findFrameAt(index);
         if(_loc3_)
         {
            _loc3_.removeAction(action);
         }
      }
      
      public function removeFrameActions(index:int) : void
      {
         var _loc2_:MovieFrame = findFrameAt(index);
         if(_loc2_)
         {
            _loc2_.removeActions();
         }
      }
      
      private function findFrameAt(index:int) : MovieFrame
      {
         if(index < 0 || index >= _numFrames)
         {
            throw new ArgumentError("Invalid frame index");
         }
         return index < _frames.length ? _frames[index] : null;
      }
      
      private function actionFrameAt(index:int) : MovieFrame
      {
         if(index < 0 || index >= _numFrames)
         {
            throw new RangeError("Error #1125: The index " + index + " is out of range " + _numFrames + ".",1125);
         }
         return index < _frames.length ? _frames[index] : null;
      }
      
      public function advanceTime(passedTime:Number) : void
      {
         var _loc3_:Number = NaN;
         var _loc5_:int = 0;
         if(!_playing)
         {
            return;
         }
         var _loc9_:MovieFrame = actionFrameAt(_currentFrame);
         var _loc2_:Number = this.totalTime;
         if(_wasStopped)
         {
            _wasStopped = false;
            if(_loc9_ && _loc9_.numActions)
            {
               _loc9_.executeActions(_target,_currentFrame);
               advanceTime(passedTime);
               return;
            }
         }
         if(_currentTime >= _loc2_)
         {
            if(!_loop)
            {
               return;
            }
            _currentTime = _wrapFrame * _frameDuration;
            _currentFrame = _wrapFrame;
            _onFrameChanged(_wrapFrame);
            _loc9_ = actionFrameAt(_wrapFrame);
            if(_loc9_ && _loc9_.numActions)
            {
               _loc9_.executeActions(_target,_currentFrame);
               advanceTime(passedTime);
               return;
            }
         }
         var _loc6_:int = _numFrames - 1;
         var _loc7_:Number = _currentFrame * _frameDuration;
         var _loc4_:Boolean = false;
         var _loc8_:int = _currentFrame;
         while(_currentTime + passedTime >= _loc7_ + _frameDuration)
         {
            _loc3_ = _frameDuration - _currentTime + _loc7_;
            passedTime -= _loc3_;
            _currentTime = _loc7_ + _frameDuration;
            if(_currentFrame == _loc6_)
            {
               _currentTime = _loc2_;
               if(hasEventListener("complete"))
               {
                  _loc4_ = true;
               }
               else
               {
                  if(!_loop)
                  {
                     return;
                  }
                  _currentTime = _wrapFrame * _frameDuration;
                  _currentFrame = _wrapFrame;
                  _loc7_ = _wrapFrame * _frameDuration;
               }
            }
            else
            {
               _currentFrame += 1;
               _loc7_ += _frameDuration;
            }
            _loc9_ = actionFrameAt(_currentFrame);
            _loc5_ = int(_loc9_ ? _loc9_.numActions : 0);
            if(_loc4_)
            {
               _onFrameChanged(_currentFrame);
               dispatchEventWith("complete");
               advanceTime(passedTime);
               return;
            }
            if(_loc5_)
            {
               _onFrameChanged(_currentFrame);
               _loc9_.executeActions(_target,_currentFrame);
               advanceTime(passedTime);
               return;
            }
         }
         if(_loc8_ != _currentFrame)
         {
            _onFrameChanged(_currentFrame);
         }
         _currentTime += passedTime;
      }
      
      public function get wrapFrame() : int
      {
         return _wrapFrame;
      }
      
      public function set wrapFrame(value:int) : void
      {
         _wrapFrame = MathUtil.clamp(value,0,numFrames - 1);
      }
      
      public function get numFrames() : int
      {
         return _numFrames;
      }
      
      public function set numFrames(value:int) : void
      {
         if(value < _frames.length)
         {
            _frames.length = value;
         }
         _numFrames = value;
      }
      
      public function get totalTime() : Number
      {
         return numFrames * _frameDuration;
      }
      
      public function get currentTime() : Number
      {
         return _currentTime;
      }
      
      public function set currentTime(value:Number) : void
      {
         value = MathUtil.clamp(value,0,totalTime);
         var _loc2_:int = _currentFrame;
         _currentFrame = value / _frameDuration;
         _currentTime = value;
         if(_loc2_ != _currentFrame)
         {
            _onFrameChanged(_currentFrame);
         }
      }
      
      public function get frameRate() : Number
      {
         return 1 / _frameDuration;
      }
      
      public function set frameRate(value:Number) : void
      {
         if(value <= 0)
         {
            throw new ArgumentError("Invalid frame rate");
         }
         var _loc2_:Number = 1 / value;
         var _loc3_:Number = _loc2_ / _frameDuration;
         _currentTime *= _loc3_;
         _frameDuration = _loc2_;
      }
      
      public function get loop() : Boolean
      {
         return _loop;
      }
      
      public function set loop(value:Boolean) : void
      {
         _loop = value;
      }
      
      public function get currentFrame() : int
      {
         return _currentFrame;
      }
      
      public function set currentFrame(value:int) : void
      {
         value = MathUtil.clamp(value,0,numFrames);
         var _loc2_:int = _currentFrame;
         _currentTime = _frameDuration * value;
         _currentFrame = value;
         if(_loc2_ != _currentFrame)
         {
            _onFrameChanged(_currentFrame);
         }
      }
      
      public function get isPlaying() : Boolean
      {
         if(_playing)
         {
            return _loop || _currentTime < totalTime;
         }
         return false;
      }
      
      public function get finished() : Boolean
      {
         return _playing && !isPlaying;
      }
      
      public function get isComplete() : Boolean
      {
         return !_loop && _currentTime >= totalTime;
      }
   }
}

import starling.display.DisplayObject;

class MovieFrame
{
   
   private var _actions:Vector.<Function>;
   
   public function MovieFrame()
   {
      super();
   }
   
   public function addAction(action:Function) : void
   {
      if(action == null)
      {
         throw new ArgumentError("action cannot be null");
      }
      if(_actions == null)
      {
         _actions = new Vector.<Function>(0);
      }
      if(_actions.indexOf(action) == -1)
      {
         _actions[_actions.length] = action;
      }
   }
   
   public function removeAction(action:Function) : void
   {
      var _loc2_:int = 0;
      if(_actions)
      {
         _loc2_ = int(_actions.indexOf(action));
         if(_loc2_ >= 0)
         {
            _actions.removeAt(_loc2_);
         }
      }
   }
   
   public function removeActions() : void
   {
      if(_actions)
      {
         _actions.length = 0;
      }
   }
   
   public function executeActions(target:DisplayObject, frameID:int) : void
   {
      var _loc5_:int = 0;
      var _loc4_:int = 0;
      var _loc6_:Function = null;
      var _loc3_:int = 0;
      if(_actions)
      {
         _loc5_ = 0;
         _loc4_ = int(_actions.length);
         while(_loc5_ < _loc4_)
         {
            _loc6_ = _actions[_loc5_];
            _loc3_ = _loc6_.length;
            if(_loc3_ == 0)
            {
               _loc6_();
            }
            else if(_loc3_ == 1)
            {
               _loc6_(target);
            }
            else
            {
               if(_loc3_ != 2)
               {
                  throw new Error("Frame actions support zero, one or two parameters: movie:MovieClip, frameID:int");
               }
               _loc6_(target,frameID);
            }
            _loc5_++;
         }
      }
   }
   
   public function get numActions() : int
   {
      return _actions ? _actions.length : 0;
   }
}
