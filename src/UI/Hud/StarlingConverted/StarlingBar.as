package UI.Hud.StarlingConverted
{
   import starling.display.DisplayObject;
   import starling.display.DisplayObjectContainer;
   
   public class StarlingBar implements IHudTick
   {
      
      private static const LERP_DELAY:Number = 2;
      
      private static const LERP_SPEED:Number = 0.125;
      
      private var mBar:DisplayObject;
      
      private var mDelta:DisplayObject;
      
      private var mTicker:HudTicker;
      
      private var mValue:Number = 0;
      
      private var mDeltaValue:Number = 0;
      
      private var mTrueValue:Number = 0;
      
      private var mDeadline:int = 0;
      
      private var mLerping:Boolean = false;
      
      private var mWaiting:Boolean = false;
      
      private var mCut:Boolean;
      
      private var mDeltaCut:Boolean;
      
      private var mWidth:Number;
      
      private var mDeltaWidth:Number;
      
      public function StarlingBar(root:DisplayObject, delta:DisplayObject, ticker:HudTicker)
      {
         super();
         mBar = barChild(root);
         mDelta = delta != null ? barChild(delta) : null;
         mTicker = ticker;
         mCut = mBar is ArtDisplay && Boolean(ArtDisplay(mBar).art.masked);
         mDeltaCut = mDelta is ArtDisplay && Boolean(ArtDisplay(mDelta).art.masked);
         mWidth = mBar is ArtDisplay ? ArtDisplay(mBar).art.registrationWidth : (mBar != null ? mBar.width : 0);
         mDeltaWidth = mDelta is ArtDisplay ? ArtDisplay(mDelta).art.registrationWidth : (mDelta != null ? mDelta.width : 0);
         if(mDelta != null)
         {
            mDelta.alpha = 0.3;
         }
         update();
      }
      
      private static function barChild(root:DisplayObject) : DisplayObject
      {
         var _loc2_:DisplayObjectContainer = root as DisplayObjectContainer;
         var _loc3_:DisplayObject = _loc2_ != null ? _loc2_.getChildByName("bar") : null;
         return _loc3_ ?? root;
      }
      
      private static function cut(display:DisplayObject, right:Number) : void
      {
         var _loc4_:int = 0;
         if(display is StarlingBarImage)
         {
            StarlingBarImage(display).setCut(0,right);
         }
         var _loc3_:DisplayObjectContainer = display as DisplayObjectContainer;
         if(_loc3_ != null)
         {
            _loc4_ = 0;
            while(_loc4_ < _loc3_.numChildren)
            {
               cut(_loc3_.getChildAt(_loc4_),right);
               _loc4_++;
            }
         }
      }
      
      private function update() : void
      {
         if(mCut)
         {
            mBar.scaleX = 1;
            cut(mBar,mWidth * mValue);
         }
         else if(mBar != null)
         {
            mBar.scaleX = mValue;
         }
         if(mDelta != null)
         {
            if(mDeltaCut)
            {
               mDelta.scaleX = 1;
               cut(mDelta,mDeltaWidth * mDeltaValue);
            }
            else
            {
               mDelta.scaleX = mDeltaValue;
            }
         }
      }
      
      public function get value() : Number
      {
         return mValue;
      }
      
      public function set value(value:Number) : void
      {
         var _loc2_:Number = Math.max(0,Math.min(1,value));
         mTrueValue = _loc2_;
         if(mDelta == null)
         {
            mValue = _loc2_;
         }
         else
         {
            if(mTrueValue > mValue)
            {
               mDeltaValue = Math.max(mDeltaValue,mTrueValue);
            }
            else
            {
               mValue = mTrueValue;
            }
            if(!mLerping && !mWaiting)
            {
               mWaiting = true;
               mDeadline = mTicker.gameTime + 2000;
               mTicker.register(this);
            }
         }
         update();
      }
      
      public function tick(tickLength:Number, stageFrame:Boolean) : void
      {
         var _loc3_:Number = NaN;
         if(mWaiting)
         {
            if(mTicker.gameTime < mDeadline)
            {
               return;
            }
            mWaiting = false;
            mLerping = true;
            return;
         }
         if(!mLerping)
         {
            return;
         }
         var _loc4_:Boolean = mTrueValue <= mValue;
         if(mTrueValue > mValue)
         {
            _loc3_ = 1 - (mTrueValue - mValue) * 0.125;
            mValue += 1 - _loc3_ * _loc3_;
            if(mTrueValue - mValue < 0.05)
            {
               _loc4_ = true;
            }
         }
         if(mTrueValue < mDeltaValue)
         {
            _loc3_ = 1 - (mTrueValue - mDeltaValue) * 0.125;
            mDeltaValue += 1 - _loc3_ * _loc3_;
            if(mDeltaValue - mTrueValue >= 0.05)
            {
               _loc4_ = false;
            }
         }
         if(_loc4_)
         {
            mValue = mDeltaValue = mTrueValue;
            mLerping = false;
            mTicker.unregister(this);
         }
         update();
      }
      
      public function dispose() : void
      {
         mTicker.unregister(this);
      }
   }
}

