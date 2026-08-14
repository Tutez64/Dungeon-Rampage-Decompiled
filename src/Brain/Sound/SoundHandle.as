package Brain.Sound
{
   import Brain.Clock.GameClock;
   import Brain.Event.EventComponent;
   import Brain.Facade.Facade;
   import Brain.Logger.Logger;
   import Brain.Utils.MemoryTracker;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Brain.WorkLoop.Task;
   import Brain.WorkLoop.WorkComponent;
   import flash.events.Event;
   import flash.media.Sound;
   import flash.media.SoundChannel;
   import flash.media.SoundTransform;
   
   public class SoundHandle
   {
      
      protected var mSoundManager:SoundManager;
      
      protected var mWorkComponent:WorkComponent;
      
      protected var mEventComponent:EventComponent;
      
      protected var mSoundCompleteTask:Task;
      
      protected var mSound:Sound;
      
      protected var mSoundChannel:SoundChannel;
      
      protected var mOwnerComponentDestroy:Function;
      
      protected var mVolume:Number;
      
      protected var mPanning:Number;
      
      protected var mCategory:String;
      
      protected var mLoopCount:int;
      
      protected var mSoundTransform:SoundTransform;
      
      protected var mPausePosition:Number;
      
      protected var mManaged:Boolean;
      
      protected var mRegistered:Boolean = false;
      
      public function SoundHandle(manager:SoundManager, facade:Facade, sound:Sound, category:String, destroyFunction:Function, managed:Boolean, volume:Number = 1, panning:Number = 0)
      {
         super();
         mSoundManager = manager;
         mWorkComponent = new LogicalWorkComponent(facade,"SoundHandle");
         MemoryTracker.track(mWorkComponent,"LogicalWorkComponent - created in SoundHandle, category: " + category,"brain");
         mSound = sound;
         mVolume = volume;
         mPanning = panning;
         mManaged = managed;
         mCategory = category;
         mEventComponent = new EventComponent(facade);
         MemoryTracker.track(mEventComponent,"EventComponent - created in SoundHandle, category: " + category,"brain");
         mEventComponent.addListener("SoundCategoryVoumeChangedEvent",handleVolumeCategoryChangedEvent);
         mOwnerComponentDestroy = destroyFunction;
         mSoundTransform = buildSoundTransform();
      }
      
      private function handleVolumeCategoryChangedEvent(e:Event) : void
      {
         applySoundTransform();
      }
      
      public function play(loopCount:Number = 1, startPosition:Number = 0) : Boolean
      {
         if(!mRegistered && mManaged)
         {
            registerPlaying();
         }
         mLoopCount = loopCount;
         mSoundTransform = buildSoundTransform();
         mSoundChannel = mSound.play(0,mLoopCount,mSoundTransform);
         if(mSoundChannel == null)
         {
            return false;
         }
         var _loc3_:Number = (mSound.length - startPosition) / 1000;
         if(_loc3_ <= 0)
         {
            Logger.warn("Bad sound length=" + mSound.length.toString() + " or startPosition=" + startPosition.toString() + " url=" + mSound.url);
            mLoopCount = 0;
            this.soundComplete();
         }
         else
         {
            mSoundCompleteTask = mWorkComponent.doLater(_loc3_,soundComplete);
         }
         return true;
      }
      
      public function pause() : void
      {
         if(mSoundChannel == null)
         {
            return;
         }
         mPausePosition = mSoundChannel.position;
         unregisterPlayingFromManager();
         mSoundChannel.stop();
      }
      
      public function resume() : void
      {
         play(mLoopCount,mPausePosition);
      }
      
      protected function soundComplete(gameClock:GameClock = null) : void
      {
         if(mLoopCount == 0)
         {
            if(!mManaged)
            {
               destroy();
               return;
            }
            if(mSoundCompleteTask)
            {
               mSoundCompleteTask.destroy();
            }
            mSoundCompleteTask = null;
         }
         else
         {
            mLoopCount = mLoopCount - 1;
            if(mSoundCompleteTask)
            {
               mSoundCompleteTask.destroy();
            }
            mSoundCompleteTask = null;
            if(mSoundChannel != null)
            {
               mSoundChannel.stop();
            }
            play(mLoopCount);
         }
      }
      
      public function stop() : void
      {
         if(mRegistered)
         {
            unregisterPlayingFromManager();
         }
         if(mSoundChannel == null)
         {
            return;
         }
         mSoundChannel.stop();
         mSoundChannel.removeEventListener("soundComplete",soundComplete);
         mPausePosition = 0;
         if(mSoundCompleteTask != null)
         {
            mSoundCompleteTask.destroy();
            mSoundCompleteTask = null;
         }
         mLoopCount = 0;
      }
      
      protected function registerPlaying() : void
      {
         mRegistered = true;
         mSoundManager.registerSoundPlaying(this);
      }
      
      protected function unregisterPlayingFromManager() : void
      {
         mRegistered = false;
         mSoundManager.unregisterSoundPlaying(this);
      }
      
      protected function buildSoundTransform() : SoundTransform
      {
         var _loc1_:Number = mSoundManager.getDampenedVolumeScaleForCategory(mCategory);
         return new SoundTransform(mVolume * _loc1_,mPanning);
      }
      
      protected function applySoundTransform() : void
      {
         mSoundTransform = buildSoundTransform();
         if(mSoundChannel == null)
         {
            return;
         }
         mSoundChannel.soundTransform = mSoundTransform;
      }
      
      public function get volume() : Number
      {
         return mVolume;
      }
      
      public function set volume(vol:Number) : void
      {
         mVolume = vol;
         applySoundTransform();
      }
      
      public function get panning() : Number
      {
         return mPanning;
      }
      
      public function set panning(panning:Number) : void
      {
         mPanning = panning;
         applySoundTransform();
      }
      
      public function get category() : String
      {
         return mCategory;
      }
      
      public function destroy() : void
      {
         stop();
         if(mOwnerComponentDestroy != null)
         {
            mOwnerComponentDestroy(this);
            mOwnerComponentDestroy = null;
         }
         mSoundManager = null;
         mSound = null;
         if(mSoundChannel)
         {
            mSoundChannel.stop();
            mSoundChannel = null;
         }
         mCategory = null;
         mSoundTransform = null;
         if(mWorkComponent)
         {
            mWorkComponent.destroy();
            mWorkComponent = null;
         }
         if(mEventComponent)
         {
            mEventComponent.destroy();
            mEventComponent = null;
         }
      }
   }
}

