package DistributedObjects
{
   public class FloorViewHold
   {
      
      public static const TIMEOUT_SECONDS:Number = 15;
      
      private var mSchedule:Function;
      
      private var mCancel:Function;
      
      private var mOnRelease:Function;
      
      private var mHolding:Boolean;
      
      private var mHeroReady:Boolean;
      
      private var mClosureArrived:Boolean;
      
      private var mIntroPlaying:Boolean;
      
      private var mTimeout:Object;
      
      public function FloorViewHold(schedule:Function, cancel:Function, onRelease:Function)
      {
         super();
         mSchedule = schedule;
         mCancel = cancel;
         mOnRelease = onRelease;
      }
      
      public function get holding() : Boolean
      {
         return mHolding;
      }
      
      public function get heroIsReady() : Boolean
      {
         return mHeroReady;
      }
      
      public function get closureHasArrived() : Boolean
      {
         return mClosureArrived;
      }
      
      public function begin() : void
      {
         cancelTimeout();
         mHolding = true;
         mHeroReady = false;
         mClosureArrived = false;
         mIntroPlaying = false;
         mTimeout = mSchedule(15,timedOut);
      }
      
      public function introStarted() : void
      {
         mIntroPlaying = true;
      }
      
      public function introEnded() : void
      {
         mIntroPlaying = false;
         if(mHolding)
         {
            cancelTimeout();
            mTimeout = mSchedule(15,timedOut);
         }
      }
      
      public function heroReady() : void
      {
         mHeroReady = true;
         releaseIfReady();
      }
      
      public function closureArrived() : void
      {
         mClosureArrived = true;
         releaseIfReady();
      }
      
      public function stop() : void
      {
         cancelTimeout();
         mHolding = false;
      }
      
      private function releaseIfReady() : void
      {
         if(mHeroReady && mClosureArrived)
         {
            finish(false);
         }
      }
      
      private function cancelTimeout() : void
      {
         if(mTimeout != null)
         {
            mCancel(mTimeout);
            mTimeout = null;
         }
      }
      
      private function timedOut(... rest) : void
      {
         mTimeout = null;
         if(mIntroPlaying && mHolding)
         {
            mTimeout = mSchedule(15,timedOut);
            return;
         }
         finish(true);
      }
      
      private function finish(timedOut:Boolean) : void
      {
         cancelTimeout();
         if(mHolding)
         {
            mHolding = false;
            mOnRelease(timedOut);
         }
      }
   }
}

