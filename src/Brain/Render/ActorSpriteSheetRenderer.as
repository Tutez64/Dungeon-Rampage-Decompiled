package Brain.Render
{
   import Brain.AssetRepository.SpriteSheetAsset;
   import Brain.Clock.GameClock;
   import Brain.Logger.Logger;
   import Brain.Utils.MemoryTracker;
   import Brain.WorkLoop.WorkComponent;
   
   public class ActorSpriteSheetRenderer extends SpriteSheetRenderer implements IRenderer
   {
      
      public static var SPRITE_SHEET_RENDERER_TYPE:String = "SpriteSheetRenderer";
      
      protected var mFrameRate:Number = 24;
      
      protected var mPlayRate:Number = 1;
      
      protected var mDuration:Number = 0;
      
      protected var mFrameTimes:Vector.<Number>;
      
      protected var mLoop:Boolean = true;
      
      private var mIsPlaying:Boolean = false;
      
      private var mAnimationFrame:uint = 0;
      
      private var mPlayHead:Number = 0;
      
      protected var mHeading:Number = 0;
      
      public function ActorSpriteSheetRenderer(workComponent:WorkComponent, sheet:SpriteSheetAsset, bitmapNameValue:String)
      {
         super(workComponent,sheet);
         mBitmap.name = "ActorSpriteSheetRenderer_" + bitmapNameValue;
         mFrameTimes = sheet.timingVector;
         if(mFrameTimes.length != sheet.numFramesX)
         {
            throw new Error("Warning: frameTimes vector length and sheet numFramesX must match");
         }
         mDuration = 0;
         for each(var _loc4_:int in mFrameTimes)
         {
            mDuration += _loc4_ / 1000;
         }
         MemoryTracker.track(this,"ActorSpriteSheetRenderer name=" + bitmapNameValue + " - created in ActorSpriteSheetRenderer()","brain");
      }
      
      public function get playRate() : Number
      {
         return mPlayRate;
      }
      
      public function get rendererType() : String
      {
         return SPRITE_SHEET_RENDERER_TYPE;
      }
      
      public function set playRate(value:Number) : void
      {
         mPlayRate = value;
      }
      
      override public function destroy() : void
      {
         super.destroy();
      }
      
      public function get durationInSeconds() : Number
      {
         return mDuration / mPlayRate;
      }
      
      public function get frameCount() : Number
      {
         return mFrameTimes.length;
      }
      
      override public function get loop() : Boolean
      {
         return mLoop;
      }
      
      public function get frameRate() : uint
      {
         return mFrameRate;
      }
      
      private function getFrameFromTime(time:Number) : uint
      {
         var _loc3_:uint = 0;
         var _loc4_:Number = 0;
         for each(var _loc2_:Number in mFrameTimes)
         {
            _loc4_ += _loc2_ / 1000 / mPlayRate;
            if(_loc4_ > time)
            {
               break;
            }
            _loc3_++;
         }
         return _loc3_;
      }
      
      private function getTimeFromFrame(frame:uint) : Number
      {
         var _loc3_:int = 0;
         var _loc2_:uint = frame;
         if(frame >= mFrameTimes.length)
         {
            Logger.warn("Trying to set animation to frame: " + frame + ", but mFrameTimes only has length of: " + mFrameTimes.length);
            _loc2_ = mFrameTimes.length;
         }
         var _loc4_:Number = 0;
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            _loc4_ += mFrameTimes[_loc3_] / 1000 / mPlayRate;
            _loc3_++;
         }
         return _loc4_;
      }
      
      private function getAnimationIndexFromClock(gameClock:GameClock) : uint
      {
         mPlayHead += gameClock.tickLength;
         if(!mLoop && mPlayHead >= this.durationInSeconds)
         {
            stop();
            return this.mSpriteSheet.numFramesX - 1;
         }
         mPlayHead %= this.durationInSeconds;
         mAnimationFrame = this.getFrameFromTime(mPlayHead);
         return mAnimationFrame;
      }
      
      public function get isPlaying() : Boolean
      {
         return mIsPlaying;
      }
      
      override public function play(startingFrame:uint = 0, loop:Boolean = true, finishedCallback:Function = null) : void
      {
         mIsPlaying = true;
         mAnimationFrame = startingFrame;
         mPlayHead = this.getTimeFromFrame(startingFrame);
         mLoop = loop;
         super.play(startingFrame,loop,finishedCallback);
         if(mIsPlaying && mBitmap.stage != null && mOnFrameTask == null)
         {
            this.onAdd();
         }
      }
      
      override public function stop() : void
      {
         super.stop();
         if(mOnFrameTask)
         {
            mOnFrameTask.destroy();
            mOnFrameTask = null;
         }
         mIsPlaying = false;
      }
      
      override protected function onFrame(gameClock:GameClock) : void
      {
         var _loc3_:* = 0;
         var _loc5_:* = 0;
         var _loc4_:* = 0;
         var _loc2_:* = 0;
         if(mIsPlaying && mBitmap.stage != null)
         {
            _loc3_ = getAnimationIndexFromClock(gameClock);
            _loc5_ = getDirectionIndexFromHeading(mHeading);
            _loc4_ = mXIndex;
            _loc2_ = mYIndex;
            setFrameIndexes(_loc3_,_loc5_);
            if(mXIndex != _loc4_ || mYIndex != _loc2_)
            {
               super.onFrame(gameClock);
            }
         }
      }
      
      override public function set heading(value:Number) : void
      {
         while(value < -180)
         {
            value += 360;
         }
         while(value > 180)
         {
            value -= 360;
         }
         mHeading = value;
      }
      
      public function get heading() : Number
      {
         return mHeading;
      }
      
      public function getDirectionIndexFromHeading(heading:Number) : uint
      {
         if(heading > 90)
         {
            heading = -heading + 180;
         }
         else if(heading < -90)
         {
            heading = -heading - 180;
         }
         switch(int(mSpriteSheet.numFramesY) - 1)
         {
            case 0:
               return 0;
            case 1:
               if(180 >= heading && heading >= 0)
               {
                  return 1;
               }
               if(0 >= heading && heading >= -180)
               {
                  return 0;
               }
               throw new Error("unknown heading:",heading);
               break;
            case 2:
               if(90 >= heading && heading >= 60)
               {
                  return 0;
               }
               if(60 >= heading && heading >= 0)
               {
                  return 2;
               }
               if(0 >= heading && heading >= -90)
               {
                  return 1;
               }
               throw new Error("unknown heading:",heading);
               break;
            case 4:
               if(120 >= heading && heading >= 60)
               {
                  return 4;
               }
               if(60 >= heading && heading >= 30)
               {
                  return 3;
               }
               if(30 >= heading && heading >= -30)
               {
                  return 2;
               }
               if(-30 >= heading && heading >= -60)
               {
                  return 1;
               }
               if(-60 >= heading && heading >= -120)
               {
                  return 0;
               }
               throw new Error("unknown heading:",heading);
               break;
            default:
               throw new Error("unsupported numFramesY: " + mSpriteSheet.numFramesY.toString());
         }
      }
      
      override public function setFrame(frameNumber:uint) : void
      {
         var _loc2_:int = int(getDirectionIndexFromHeading(this.heading));
         setFrameIndexes(frameNumber,_loc2_);
         updateToCurrentFrame();
      }
   }
}

