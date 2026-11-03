package starling.display
{
   import flash.errors.IllegalOperationError;
   import flash.media.Sound;
   import flash.media.SoundTransform;
   import starling.animation.IAnimatable;
   import starling.textures.Texture;
   
   public class MovieClip extends Image implements IAnimatable
   {
      
      private var _frames:Vector.<MovieClipFrame>;
      
      private var _defaultFrameDuration:Number;
      
      private var _currentTime:Number;
      
      private var _currentFrameID:int;
      
      private var _loop:Boolean;
      
      private var _playing:Boolean;
      
      private var _muted:Boolean;
      
      private var _wasStopped:Boolean;
      
      private var _soundTransform:SoundTransform;
      
      public function MovieClip(textures:Vector.<Texture>, fps:Number = 12)
      {
         if(textures.length > 0)
         {
            super(textures[0]);
            init(textures,fps);
            return;
         }
         throw new ArgumentError("Empty texture array");
      }
      
      private function init(textures:Vector.<Texture>, fps:Number) : void
      {
         var _loc4_:int = 0;
         if(fps <= 0)
         {
            throw new ArgumentError("Invalid fps: " + fps);
         }
         var _loc3_:int = int(textures.length);
         _defaultFrameDuration = 1 / fps;
         _loop = true;
         _playing = true;
         _currentTime = 0;
         _currentFrameID = 0;
         _wasStopped = true;
         _frames = new Vector.<MovieClipFrame>(0);
         _loc4_ = 0;
         while(_loc4_ < _loc3_)
         {
            _frames[_loc4_] = new MovieClipFrame(textures[_loc4_],_defaultFrameDuration,_defaultFrameDuration * _loc4_);
            _loc4_++;
         }
      }
      
      public function addFrame(texture:Texture, sound:Sound = null, duration:Number = -1) : void
      {
         addFrameAt(numFrames,texture,sound,duration);
      }
      
      public function addFrameAt(frameID:int, texture:Texture, sound:Sound = null, duration:Number = -1) : void
      {
         var _loc6_:Number = NaN;
         var _loc5_:Number = NaN;
         if(frameID < 0 || frameID > numFrames)
         {
            throw new ArgumentError("Invalid frame id");
         }
         if(duration < 0)
         {
            duration = _defaultFrameDuration;
         }
         var _loc7_:MovieClipFrame = new MovieClipFrame(texture,duration);
         _loc7_.sound = sound;
         _frames.insertAt(frameID,_loc7_);
         if(frameID == numFrames)
         {
            _loc6_ = Number(frameID > 0 ? _frames[frameID - 1].startTime : 0);
            _loc5_ = Number(frameID > 0 ? _frames[frameID - 1].duration : 0);
            _loc7_.startTime = _loc6_ + _loc5_;
         }
         else
         {
            updateStartTimes();
         }
      }
      
      public function removeFrameAt(frameID:int) : void
      {
         if(frameID < 0 || frameID >= numFrames)
         {
            throw new ArgumentError("Invalid frame id");
         }
         if(numFrames == 1)
         {
            throw new IllegalOperationError("Movie clip must not be empty");
         }
         _frames.removeAt(frameID);
         if(frameID != numFrames)
         {
            updateStartTimes();
         }
      }
      
      public function getFrameTexture(frameID:int) : Texture
      {
         if(frameID < 0 || frameID >= numFrames)
         {
            throw new ArgumentError("Invalid frame id");
         }
         return _frames[frameID].texture;
      }
      
      public function setFrameTexture(frameID:int, texture:Texture) : void
      {
         if(frameID < 0 || frameID >= numFrames)
         {
            throw new ArgumentError("Invalid frame id");
         }
         _frames[frameID].texture = texture;
      }
      
      public function getFrameSound(frameID:int) : Sound
      {
         if(frameID < 0 || frameID >= numFrames)
         {
            throw new ArgumentError("Invalid frame id");
         }
         return _frames[frameID].sound;
      }
      
      public function setFrameSound(frameID:int, sound:Sound) : void
      {
         if(frameID < 0 || frameID >= numFrames)
         {
            throw new ArgumentError("Invalid frame id");
         }
         _frames[frameID].sound = sound;
      }
      
      public function getFrameAction(frameID:int) : Function
      {
         if(frameID < 0 || frameID >= numFrames)
         {
            throw new ArgumentError("Invalid frame id");
         }
         return _frames[frameID].action;
      }
      
      public function setFrameAction(frameID:int, action:Function) : void
      {
         if(frameID < 0 || frameID >= numFrames)
         {
            throw new ArgumentError("Invalid frame id");
         }
         _frames[frameID].action = action;
      }
      
      public function getFrameDuration(frameID:int) : Number
      {
         if(frameID < 0 || frameID >= numFrames)
         {
            throw new ArgumentError("Invalid frame id");
         }
         return _frames[frameID].duration;
      }
      
      public function setFrameDuration(frameID:int, duration:Number) : void
      {
         if(frameID < 0 || frameID >= numFrames)
         {
            throw new ArgumentError("Invalid frame id");
         }
         _frames[frameID].duration = duration;
         updateStartTimes();
      }
      
      public function reverseFrames() : void
      {
         _frames.reverse();
         updateStartTimes();
         _currentTime = totalTime - _currentTime;
         _currentFrameID = numFrames - _currentFrameID - 1;
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
      
      private function updateStartTimes() : void
      {
         var _loc2_:int = 0;
         var _loc1_:int = this.numFrames;
         var _loc3_:MovieClipFrame = _frames[0];
         _loc3_.startTime = 0;
         _loc2_ = 1;
         while(_loc2_ < _loc1_)
         {
            _frames[_loc2_].startTime = _loc3_.startTime + _loc3_.duration;
            _loc3_ = _frames[_loc2_];
            _loc2_++;
         }
      }
      
      public function advanceTime(passedTime:Number) : void
      {
         var _loc4_:Number = NaN;
         var _loc2_:Boolean = false;
         if(!_playing)
         {
            return;
         }
         var _loc8_:MovieClipFrame = _frames[_currentFrameID];
         if(_wasStopped)
         {
            _wasStopped = false;
            _loc8_.playSound(_soundTransform);
            if(_loc8_.action != null)
            {
               _loc8_.executeAction(this,_currentFrameID);
               advanceTime(passedTime);
               return;
            }
         }
         if(_currentTime == totalTime)
         {
            if(!_loop)
            {
               return;
            }
            _currentTime = 0;
            _currentFrameID = 0;
            _loc8_ = _frames[0];
            _loc8_.playSound(_soundTransform);
            texture = _loc8_.texture;
            if(_loc8_.action != null)
            {
               _loc8_.executeAction(this,_currentFrameID);
               advanceTime(passedTime);
               return;
            }
         }
         var _loc3_:int = _frames.length - 1;
         var _loc5_:Boolean = false;
         var _loc6_:Function = null;
         var _loc7_:int = _currentFrameID;
         while(_currentTime + passedTime >= _loc8_.endTime)
         {
            _loc2_ = false;
            _loc4_ = _loc8_.duration - _currentTime + _loc8_.startTime;
            passedTime -= _loc4_;
            _currentTime = _loc8_.startTime + _loc8_.duration;
            if(_currentFrameID == _loc3_)
            {
               if(hasEventListener("complete"))
               {
                  _loc5_ = true;
               }
               else
               {
                  if(!_loop)
                  {
                     return;
                  }
                  _currentTime = 0;
                  _currentFrameID = 0;
                  _loc2_ = true;
               }
            }
            else
            {
               _currentFrameID += 1;
               _loc2_ = true;
            }
            _loc8_ = _frames[_currentFrameID];
            _loc6_ = _loc8_.action;
            if(_loc2_)
            {
               _loc8_.playSound(_soundTransform);
            }
            if(_loc5_)
            {
               texture = _loc8_.texture;
               dispatchEventWith("complete");
               advanceTime(passedTime);
               return;
            }
            if(_loc6_ != null)
            {
               texture = _loc8_.texture;
               _loc8_.executeAction(this,_currentFrameID);
               advanceTime(passedTime);
               return;
            }
         }
         if(_loc7_ != _currentFrameID)
         {
            texture = _frames[_currentFrameID].texture;
         }
         _currentTime += passedTime;
      }
      
      public function get numFrames() : int
      {
         return _frames.length;
      }
      
      public function get totalTime() : Number
      {
         var _loc1_:MovieClipFrame = _frames[_frames.length - 1];
         return _loc1_.startTime + _loc1_.duration;
      }
      
      public function get currentTime() : Number
      {
         return _currentTime;
      }
      
      public function set currentTime(value:Number) : void
      {
         if(value < 0 || value > totalTime)
         {
            throw new ArgumentError("Invalid time: " + value);
         }
         var _loc2_:int = _frames.length - 1;
         _currentTime = value;
         _currentFrameID = 0;
         while(_currentFrameID < _loc2_ && _frames[_currentFrameID + 1].startTime <= value)
         {
            _currentFrameID = _currentFrameID + 1;
         }
         var _loc3_:MovieClipFrame = _frames[_currentFrameID];
         texture = _loc3_.texture;
      }
      
      public function get loop() : Boolean
      {
         return _loop;
      }
      
      public function set loop(value:Boolean) : void
      {
         _loop = value;
      }
      
      public function get muted() : Boolean
      {
         return _muted;
      }
      
      public function set muted(value:Boolean) : void
      {
         _muted = value;
      }
      
      public function get soundTransform() : SoundTransform
      {
         return _soundTransform;
      }
      
      public function set soundTransform(value:SoundTransform) : void
      {
         _soundTransform = value;
      }
      
      public function get currentFrame() : int
      {
         return _currentFrameID;
      }
      
      public function set currentFrame(value:int) : void
      {
         if(value < 0 || value >= numFrames)
         {
            throw new ArgumentError("Invalid frame id");
         }
         currentTime = _frames[value].startTime;
      }
      
      public function get fps() : Number
      {
         return 1 / _defaultFrameDuration;
      }
      
      public function set fps(value:Number) : void
      {
         var _loc4_:int = 0;
         if(value <= 0)
         {
            throw new ArgumentError("Invalid fps: " + value);
         }
         var _loc2_:Number = 1 / value;
         var _loc3_:Number = _loc2_ / _defaultFrameDuration;
         _currentTime *= _loc3_;
         _defaultFrameDuration = _loc2_;
         _loc4_ = 0;
         while(_loc4_ < numFrames)
         {
            _frames[_loc4_].duration *= _loc3_;
            _loc4_++;
         }
         updateStartTimes();
      }
      
      public function get isPlaying() : Boolean
      {
         if(_playing)
         {
            return _loop || _currentTime < totalTime;
         }
         return false;
      }
      
      public function get isComplete() : Boolean
      {
         return !_loop && _currentTime >= totalTime;
      }
   }
}

import flash.media.Sound;
import flash.media.SoundTransform;
import starling.display.MovieClip;
import starling.textures.Texture;

class MovieClipFrame
{
   
   public var texture:Texture;
   
   public var sound:Sound;
   
   public var duration:Number;
   
   public var startTime:Number;
   
   public var action:Function;
   
   public function MovieClipFrame(texture:Texture, duration:Number = 0.1, startTime:Number = 0)
   {
      super();
      this.texture = texture;
      this.duration = duration;
      this.startTime = startTime;
   }
   
   public function playSound(transform:SoundTransform) : void
   {
      if(sound)
      {
         sound.play(0,0,transform);
      }
   }
   
   public function executeAction(movie:MovieClip, frameID:int) : void
   {
      var _loc3_:int = 0;
      if(action != null)
      {
         _loc3_ = int(action.length);
         if(_loc3_ == 0)
         {
            action();
         }
         else if(_loc3_ == 1)
         {
            action(movie);
         }
         else
         {
            if(_loc3_ != 2)
            {
               throw new Error("Frame actions support zero, one or two parameters: movie:MovieClip, frameID:int");
            }
            action(movie,frameID);
         }
      }
   }
   
   public function get endTime() : Number
   {
      return startTime + duration;
   }
}
