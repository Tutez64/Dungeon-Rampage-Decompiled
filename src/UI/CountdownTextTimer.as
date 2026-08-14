package UI
{
   import Brain.Clock.GameClock;
   import flash.events.TimerEvent;
   import flash.text.TextField;
   import flash.utils.Timer;
   
   public class CountdownTextTimer
   {
      
      public static const millisecondsPerMinute:int = 60000;
      
      public static const millisecondsPerHour:int = 3600000;
      
      public static const millisecondsPerDay:int = 86400000;
      
      private var mCountdownText:TextField;
      
      private var mDateToFinish:Date;
      
      private var mGetDateFunction:Function;
      
      private var mOnFinishFunc:Function;
      
      private var mPostfixText:String;
      
      private var mPrefixText:String;
      
      private var mExpireText:String;
      
      private var mTimer:Timer;
      
      public function CountdownTextTimer(countdownText:TextField, dateToFinish:Date, getDateFunc:Function = null, onFinishFunc:Function = null, postfixText:String = "", prefixText:String = "", expireText:String = "")
      {
         super();
         mCountdownText = countdownText;
         mDateToFinish = dateToFinish;
         mGetDateFunction = getDateFunc;
         mOnFinishFunc = onFinishFunc;
         mPostfixText = postfixText;
         mPrefixText = prefixText;
         mExpireText = expireText;
         if(mGetDateFunction == null)
         {
            mGetDateFunction = getNow;
         }
      }
      
      public function destroy() : void
      {
         stop();
         mCountdownText = null;
         mDateToFinish = null;
         mGetDateFunction = null;
         mOnFinishFunc = null;
         mPostfixText = null;
         mPrefixText = null;
         mExpireText = null;
      }
      
      public function start() : void
      {
         mTimer = new Timer(1000);
         mTimer.addEventListener("timer",onTick);
         mTimer.start();
         onTick(null);
      }
      
      public function stop() : void
      {
         if(mTimer != null)
         {
            mTimer.removeEventListener("timer",onTick);
            mTimer.stop();
            mTimer = null;
         }
      }
      
      private function getNow() : Date
      {
         return GameClock.getWebServerDate();
      }
      
      private function getTimeLeft() : int
      {
         var _loc1_:Date = mGetDateFunction();
         return mDateToFinish.getTime() - _loc1_.getTime();
      }
      
      private function onTick(event:TimerEvent) : void
      {
         var _loc5_:int = 0;
         var _loc2_:int = 0;
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         if(getTimeLeft() <= 0)
         {
            mCountdownText.text = mExpireText;
            if(mOnFinishFunc != null)
            {
               mOnFinishFunc();
            }
         }
         else
         {
            _loc5_ = getTimeLeft();
            _loc2_ = _loc5_ / 3600000;
            _loc5_ -= _loc2_ * 3600000;
            _loc4_ = _loc5_ / 60000;
            _loc5_ -= _loc4_ * 60000;
            _loc3_ = _loc5_ / 1000;
            mCountdownText.text = mPrefixText + _loc2_.toString() + ":" + zeroPad(_loc4_,2) + ":" + zeroPad(_loc3_,2) + mPostfixText;
         }
      }
      
      public function zeroPad(number:int, width:int) : String
      {
         var _loc3_:String = "" + number;
         while(_loc3_.length < width)
         {
            _loc3_ = "0" + _loc3_;
         }
         return _loc3_;
      }
   }
}

