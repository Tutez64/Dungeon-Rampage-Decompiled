package Brain.Render
{
   import Brain.Clock.GameClock;
   import Brain.Facade.Facade;
   import Brain.Logger.Logger;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Brain.WorkLoop.Task;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.FrameLabel;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class MovieClipRenderer
   {
      
      private static const LOOP_LABEL:String = "loop";
      
      private static const NO_LOOP_LABEL:String = "noloop";
      
      protected var mFrameRate:Number = 24;
      
      protected var mPlayRate:Number = 1;
      
      protected var mLoop:Boolean = true;
      
      protected var mPlayHead:Number = 1;
      
      protected var mStartFrame:uint = 1;
      
      protected var mMaxFrames:uint;
      
      protected var mClip:MovieClip;
      
      protected var mOnFrameTask:Task;
      
      protected var mFinishedCallback:Function;
      
      protected var mIsPlaying:Boolean = false;
      
      private var mLogicalWorkComponent:LogicalWorkComponent;
      
      public function MovieClipRenderer(facade:Facade, clip:MovieClip, finishedCallback:Function = null, assetLabel:String = null)
      {
         super();
         this.clip = clip;
         mFinishedCallback = finishedCallback;
         if(mMaxFrames > 1)
         {
            mLogicalWorkComponent = new LogicalWorkComponent(facade,"MovieClipRenderer");
            if(mClip.stage)
            {
               onAdd();
            }
            mClip.addEventListener("addedToStage",onAdd);
            mClip.addEventListener("removedFromStage",onRemove);
         }
      }
      
      public function setFrame(frameNumber:uint) : void
      {
         mPlayHead = frameNumber;
         this.updateClip(mClip);
      }
      
      public function get currentFrame() : uint
      {
         return Math.round(mPlayHead % mMaxFrames) + 1;
      }
      
      public function play(startingFrame:uint = 0, loop:Boolean = false, finishedCallback:Function = null) : void
      {
         if(finishedCallback != null)
         {
            mFinishedCallback = finishedCallback;
         }
         if(mMaxFrames <= 1)
         {
            mClip.gotoAndStop(1);
         }
         else
         {
            mPlayHead = startingFrame;
            mLoop = loop;
            mIsPlaying = true;
            mMaxFrames = initialize(mClip);
            this.updateClip(mClip);
            if(mClip.stage)
            {
               onAdd();
            }
         }
      }
      
      public function set finishedCallback(value:Function) : void
      {
         mFinishedCallback = value;
      }
      
      public function stop() : void
      {
         mIsPlaying = false;
      }
      
      public function destroy() : void
      {
         if(mClip)
         {
            mClip.removeEventListener("addedToStage",onAdd);
            mClip.removeEventListener("removedFromStage",onRemove);
         }
         if(mOnFrameTask != null)
         {
            mOnFrameTask.destroy();
            mOnFrameTask = null;
         }
         if(mLogicalWorkComponent)
         {
            mLogicalWorkComponent.destroy();
            mLogicalWorkComponent = null;
         }
         mClip = null;
         mFinishedCallback = null;
      }
      
      private function onAdd(event:Event = null) : void
      {
         if(mOnFrameTask != null)
         {
            mOnFrameTask.destroy();
         }
         mOnFrameTask = mLogicalWorkComponent.doEveryFrame(onFrame);
      }
      
      private function onRemove(event:Event = null) : void
      {
         if(mOnFrameTask != null)
         {
            mOnFrameTask.destroy();
            mOnFrameTask = null;
         }
      }
      
      public function get playRate() : Number
      {
         return mPlayRate;
      }
      
      public function set playRate(value:Number) : void
      {
         mPlayRate = value;
      }
      
      public function get frameRate() : Number
      {
         return mFrameRate;
      }
      
      public function set frameRate(value:Number) : void
      {
         mFrameRate = frameRate;
      }
      
      public function set startFrame(value:uint) : void
      {
         mStartFrame = value;
      }
      
      public function get loop() : Boolean
      {
         return mLoop;
      }
      
      public function set loop(value:Boolean) : void
      {
         mLoop = value;
      }
      
      public function onFrame(gameClock:GameClock) : void
      {
         if(!mClip)
         {
            return;
         }
         if(mClip.stage == null)
         {
            Logger.warn("Animating MovieClipRenderer that is not on stage");
         }
         if(!mIsPlaying)
         {
            return;
         }
         mPlayHead += mFrameRate * gameClock.tickLength * mPlayRate;
         if(mPlayHead > mMaxFrames - 1 && !mLoop)
         {
            mIsPlaying = false;
            mPlayHead = mMaxFrames - 1;
            this.updateClip(mClip);
            if(mOnFrameTask != null)
            {
               mOnFrameTask.destroy();
               mOnFrameTask = null;
            }
            mIsPlaying = false;
            if(mFinishedCallback != null)
            {
               mFinishedCallback();
            }
            return;
         }
         this.updateClip(mClip);
      }
      
      public function set clip(value:MovieClip) : void
      {
         if(value == mClip)
         {
            return;
         }
         mClip = value;
         mPlayHead = mStartFrame;
         mMaxFrames = initialize(mClip);
         this.updateClip(mClip);
      }
      
      public function get clip() : MovieClip
      {
         return mClip;
      }
      
      public function get numFrames() : uint
      {
         if(mClip == null)
         {
            return 0;
         }
         return mMaxFrames;
      }
      
      protected function updateClip(parent:DisplayObjectContainer) : void
      {
         var _loc5_:MovieClip = null;
         var _loc4_:DisplayObject = null;
         var _loc7_:DisplayObjectContainer = null;
         var _loc2_:MovieClip = null;
         var _loc3_:* = 0;
         var _loc6_:* = 0;
         var _loc8_:int = 0;
         _loc5_ = parent as MovieClip;
         if(_loc5_ && _loc5_.totalFrames > 1)
         {
            if(_loc5_.MCR_firstLoopFrame > 0)
            {
               if(_loc5_.MCR_playedIntro)
               {
                  _loc3_ = uint(_loc5_.totalFrames - _loc5_.MCR_firstLoopFrame + 1);
                  _loc6_ = uint(Math.round((mPlayHead - _loc5_.MCR_firstLoopFrame - 1) % _loc3_) + _loc5_.MCR_firstLoopFrame);
               }
               else
               {
                  _loc6_ = uint(Math.round(mPlayHead % _loc5_.totalFrames) + 1);
                  if(mPlayHead >= _loc5_.totalFrames)
                  {
                     _loc5_.MCR_playedIntro = true;
                  }
               }
            }
            else
            {
               _loc6_ = uint(Math.round(mPlayHead % _loc5_.totalFrames) + 1);
            }
            _loc5_.gotoAndStop(_loc6_);
         }
         _loc8_ = 0;
         while(_loc8_ < parent.numChildren)
         {
            try
            {
               _loc4_ = parent.getChildAt(_loc8_);
               _loc7_ = _loc4_ as DisplayObjectContainer;
               if(_loc7_ && _loc7_.numChildren)
               {
                  updateClip(_loc7_);
               }
               else
               {
                  _loc2_ = _loc4_ as MovieClip;
                  if(_loc2_ && _loc2_.totalFrames > 1)
                  {
                     updateClip(_loc2_);
                  }
               }
            }
            catch(error:Error)
            {
            }
            _loc8_++;
         }
      }
      
      public function get duration() : Number
      {
         if(mClip == null)
         {
            return 0;
         }
         return mMaxFrames / this.frameRate / this.playRate;
      }
      
      public function get isPlaying() : Boolean
      {
         return mIsPlaying;
      }
      
      protected function initialize(parent:DisplayObjectContainer, currentMax:uint = 0, indent:String = "") : uint
      {
         var _loc7_:DisplayObject = null;
         var _loc4_:MovieClip = null;
         var _loc5_:DisplayObjectContainer = null;
         var _loc6_:int = 0;
         _loc4_ = parent as MovieClip;
         if(_loc4_)
         {
            currentMax = Math.max(currentMax,_loc4_.totalFrames);
            this.determineFrames(_loc4_);
         }
         _loc6_ = 0;
         while(_loc6_ < parent.numChildren)
         {
            try
            {
               _loc7_ = parent.getChildAt(_loc6_);
               _loc5_ = _loc7_ as DisplayObjectContainer;
               if(_loc5_ && _loc5_.numChildren)
               {
                  currentMax = Math.max(currentMax,initialize(_loc5_,currentMax,indent + "    "));
               }
               else if(_loc7_ is MovieClip)
               {
                  currentMax = Math.max(currentMax,MovieClip(_loc7_).totalFrames);
               }
            }
            catch(error:Error)
            {
            }
            _loc6_++;
         }
         return currentMax;
      }
      
      protected function determineFrames(mc:MovieClip) : void
      {
         var _loc2_:int = -1;
         for each(var _loc3_:FrameLabel in mc.currentLabels)
         {
            if(_loc3_.name == "loop")
            {
               _loc2_ = _loc3_.frame;
               mLoop = true;
               break;
            }
            if(_loc3_.name == "noloop")
            {
               mLoop = false;
               break;
            }
         }
         mc.MCR_firstLoopFrame = _loc2_;
         mc.MCR_playedIntro = false;
      }
   }
}

