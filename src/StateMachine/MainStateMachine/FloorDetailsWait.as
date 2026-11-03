package StateMachine.MainStateMachine
{
   public class FloorDetailsWait
   {
      
      public static const TIMEOUT_SECONDS:Number = 15;
      
      private var mSchedule:Function;
      
      private var mCancel:Function;
      
      private var mOnDone:Function;
      
      private var mPending:Boolean;
      
      private var mTimeout:Object;
      
      public function FloorDetailsWait(schedule:Function, cancel:Function, onDone:Function)
      {
         super();
         mSchedule = schedule;
         mCancel = cancel;
         mOnDone = onDone;
      }
      
      public function get pending() : Boolean
      {
         return mPending;
      }
      
      public function begin() : void
      {
         cancelTimeout();
         mPending = true;
      }
      
      public function heroReady() : void
      {
         if(mPending && mTimeout == null)
         {
            mTimeout = mSchedule(15,timedOut);
         }
      }
      
      public function closureArrived() : void
      {
         finish(false);
      }
      
      public function stop() : void
      {
         cancelTimeout();
         mPending = false;
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
         finish(true);
      }
      
      private function finish(timedOut:Boolean) : void
      {
         cancelTimeout();
         if(mPending)
         {
            mPending = false;
            mOnDone(timedOut);
         }
      }
   }
}

