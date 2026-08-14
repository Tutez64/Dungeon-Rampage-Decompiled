package Brain.UI
{
   import Brain.Facade.Facade;
   import Brain.Utils.MemoryTracker;
   import flash.display.MovieClip;
   
   public class UISlider extends UIObject
   {
      
      public static const HORIZONTAL:uint = 0;
      
      public static const VERTICAL:uint = 1;
      
      protected var mHandle:UISliderHandleButton;
      
      protected var mBack:UIButton;
      
      protected var mBackClick:Boolean = true;
      
      protected var mValue:Number = 0;
      
      protected var mMax:Number = 100;
      
      protected var mMin:Number = 0;
      
      protected var mOrientation:uint;
      
      protected var mTick:Number = 0.01;
      
      protected var mUpdateCallback:Function;
      
      public function UISlider(facade:Facade, root:MovieClip, orientation:uint = 0)
      {
         super(facade,root);
         mOrientation = orientation;
         mBack = new UIButton(facade,root.back);
         MemoryTracker.track(mBack,"UIButton - slider back created in UISlider()","brain");
         mBack.releaseCallback = this.backCallback;
         mHandle = new UISliderHandleButton(facade,root.handle,mOrientation,mBack.root.width,mBack.root.height);
         MemoryTracker.track(mHandle,"UISliderHandleButton - slider handle created in UISlider()","brain");
         mHandle.slideCallback = this.handleCallback;
      }
      
      override public function destroy() : void
      {
         mBack.destroy();
         mBack = null;
         mHandle.destroy();
         mHandle = null;
         mUpdateCallback = null;
      }
      
      public function set updateCallback(value:Function) : void
      {
         mUpdateCallback = value;
      }
      
      protected function handleCallback() : void
      {
         var _loc1_:Number = mValue;
         if(mOrientation == 0)
         {
            mValue = mHandle.root.x / mBack.root.width * (mMax - mMin) + mMin;
         }
         else
         {
            mValue = (mBack.root.height - mHandle.root.y) / mBack.root.height * (mMax - mMin) + mMin;
         }
         this.clampValue();
         if(_loc1_ != mValue && mUpdateCallback != null)
         {
            mUpdateCallback(this.value);
         }
      }
      
      protected function backCallback() : void
      {
         if(!mBackClick)
         {
            return;
         }
         var _loc1_:Number = mValue;
         if(mOrientation == 0)
         {
            mHandle.root.x = mBack.root.mouseX;
            mHandle.root.x = Math.max(mHandle.root.x,0);
            mHandle.root.x = Math.min(mHandle.root.x,mBack.root.width);
            mValue = mHandle.root.x / mBack.root.width * (mMax - mMin) + mMin;
         }
         else
         {
            mHandle.root.y = mBack.root.mouseY;
            mHandle.root.y = Math.max(mHandle.root.y,0);
            mHandle.root.y = Math.min(mHandle.root.y,mBack.root.height);
            mValue = (mBack.root.height - mHandle.root.y) / mBack.root.height * (mMax - mMin) + mMin;
         }
         this.clampValue();
         if(_loc1_ != mValue && mUpdateCallback != null)
         {
            mUpdateCallback(this.value);
         }
      }
      
      protected function clampValue() : void
      {
         if(mMax > mMin)
         {
            mValue = Math.min(mValue,mMax);
            mValue = Math.max(mValue,mMin);
         }
         else
         {
            mValue = Math.max(mValue,mMax);
            mValue = Math.min(mValue,mMin);
         }
      }
      
      protected function positionHandle() : void
      {
         var _loc1_:Number = NaN;
         if(mOrientation == 0)
         {
            _loc1_ = mBack.root.width;
            mHandle.root.x = (mValue - mMin) / (mMax - mMin) * _loc1_;
         }
         else
         {
            _loc1_ = mBack.root.height;
            mHandle.root.y = _loc1_ - (mValue - mMin) / (mMax - mMin) * _loc1_;
         }
      }
      
      public function set backClick(b:Boolean) : void
      {
         mBackClick = b;
      }
      
      public function get backClick() : Boolean
      {
         return mBackClick;
      }
      
      public function set value(v:Number) : void
      {
         mValue = v;
         this.clampValue();
         this.positionHandle();
      }
      
      public function set valueWithCallback(v:Number) : void
      {
         this.value = v;
         if(mUpdateCallback != null)
         {
            mUpdateCallback(this.value);
         }
      }
      
      public function get value() : Number
      {
         return Math.round(mValue / mTick) * mTick;
      }
      
      public function get rawValue() : Number
      {
         return mValue;
      }
      
      public function set maximum(m:Number) : void
      {
         mMax = m;
         this.clampValue();
         this.positionHandle();
      }
      
      public function get maximum() : Number
      {
         return mMax;
      }
      
      public function set minimum(m:Number) : void
      {
         mMin = m;
         this.clampValue();
         this.positionHandle();
      }
      
      public function get minimum() : Number
      {
         return mMin;
      }
      
      public function set tick(t:Number) : void
      {
         mTick = t;
      }
      
      public function get tick() : Number
      {
         return mTick;
      }
      
      public function get orientation() : uint
      {
         return mOrientation;
      }
   }
}

