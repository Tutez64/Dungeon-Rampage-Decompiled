package Brain.UI
{
   import Brain.Clock.GameClock;
   import Brain.Facade.Facade;
   import Brain.Utils.MemoryTracker;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Brain.WorkLoop.Task;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   public class UIProgressBar extends UIObject
   {
      
      private static const LERP_DELAY:Number = 2;
      
      private static const LERP_SPEED:Number = 0.125;
      
      private var mErrorMessage:MovieClip;
      
      private var mErrorMessageLabel:TextField;
      
      protected var mMaximum:Number = 1;
      
      protected var mMinimum:Number = 0;
      
      protected var mValue:Number = mMinimum;
      
      protected var mDeltaValue:Number = mMinimum;
      
      protected var mTrueValue:Number = mMinimum;
      
      public var bar:MovieClip;
      
      protected var mDeltaBar:MovieClip;
      
      private var mWorkComponent:LogicalWorkComponent;
      
      private var mLerpTask:Task;
      
      private var mTimerTask:Task;
      
      public function UIProgressBar(facade:Facade, root:MovieClip, delta:MovieClip = null)
      {
         super(facade,root);
         bar = root.bar ? root.bar : root;
         if(delta)
         {
            mDeltaBar = delta.bar ? delta.bar : delta;
            mDeltaBar.alpha = 0.3;
         }
         mWorkComponent = new LogicalWorkComponent(facade,"UIProgressBar");
         MemoryTracker.track(mWorkComponent,"LogicalWorkComponent - created in UIProgressBar()","brain");
         update();
      }
      
      protected function update() : void
      {
         bar.scaleX = (mValue - mMinimum) / (mMaximum - mMinimum);
         if(mDeltaBar)
         {
            mDeltaBar.scaleX = (mDeltaValue - mMinimum) / (mMaximum - mMinimum);
         }
      }
      
      public function set maximum(value:Number) : void
      {
         mMaximum = value;
         mValue = Math.min(mValue,mMaximum);
         update();
      }
      
      public function get maximum() : Number
      {
         return mMaximum;
      }
      
      public function set minimum(value:Number) : void
      {
         mMinimum = value;
         mValue = Math.max(mValue,mMinimum);
         update();
      }
      
      public function get mimimum() : Number
      {
         return mMinimum;
      }
      
      private function updateLerp(clock:GameClock) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Boolean = false;
         if(mTrueValue > mValue)
         {
            _loc2_ = 1 - (mTrueValue - mValue) * 0.125;
            mValue += 1 - _loc2_ * _loc2_;
            if(mTrueValue - mValue < 0.05)
            {
               _loc3_ = true;
            }
         }
         if(mTrueValue < mDeltaValue)
         {
            _loc2_ = 1 - (mTrueValue - mDeltaValue) * 0.125;
            mDeltaValue += 1 - _loc2_ * _loc2_;
            if(mDeltaValue - mTrueValue >= 0.05)
            {
               _loc3_ = false;
            }
         }
         if(_loc3_)
         {
            mDeltaValue = mValue = mTrueValue;
            mLerpTask.destroy();
            mLerpTask = null;
         }
         update();
      }
      
      private function startLerp(clock:GameClock) : void
      {
         if(!mLerpTask)
         {
            mLerpTask = mWorkComponent.doEveryFrame(updateLerp);
         }
         mTimerTask.destroy();
         mTimerTask = null;
      }
      
      public function set value(v:Number) : void
      {
         var _loc2_:Number = Math.max(mMinimum,Math.min(v,mMaximum));
         if(mDeltaBar)
         {
            mTrueValue = _loc2_;
            if(mTrueValue > mValue)
            {
               mDeltaValue = Math.max(mDeltaValue,mTrueValue);
            }
            else
            {
               mValue = mTrueValue;
            }
            if(mLerpTask == null)
            {
               if(!mTimerTask)
               {
                  mTimerTask = mWorkComponent.doLater(2,startLerp);
               }
            }
         }
         else
         {
            mValue = _loc2_;
         }
         update();
      }
      
      public function get value() : Number
      {
         return mValue;
      }
      
      override public function destroy() : void
      {
         if(mWorkComponent)
         {
            mWorkComponent.destroy();
            mWorkComponent = null;
         }
         super.destroy();
      }
      
      public function displayErrorMessage(message:String) : void
      {
         mErrorMessage = new MovieClip();
         MemoryTracker.track(mErrorMessage,"MovieClip - error message container created in UIProgressBar.displayErrorMessage()","brain");
         mFacade.sceneGraphManager.addChild(mErrorMessage,mTooltipLayer);
         mErrorMessageLabel = new TextField();
         MemoryTracker.track(mErrorMessageLabel,"TextField - error label created in UIProgressBar.displayErrorMessage()","brain");
         mErrorMessageLabel.x = 320;
         mErrorMessageLabel.y = 100;
         mErrorMessageLabel.text = message;
         mErrorMessageLabel.autoSize = "center";
         mErrorMessageLabel.background = true;
         mErrorMessageLabel.backgroundColor = 16711680;
         mErrorMessageLabel.textColor = 0;
         mErrorMessage.addChild(mErrorMessageLabel);
      }
   }
}

