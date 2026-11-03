package Metrics
{
   import Facade.DBFacade;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class FPSReadout
   {
      
      protected var mDBFacade:DBFacade;
      
      private var mFpsTextField:TextField;
      
      private var averageLogicalFPS:Number = 24;
      
      private var averageRenderFPS:Number = 60;
      
      private var mWantVisible:Boolean = false;
      
      private var mSuppressed:Boolean = false;
      
      public function FPSReadout(dbFacade:DBFacade)
      {
         super();
         mDBFacade = dbFacade;
         mFpsTextField = new TextField();
         mFpsTextField.text = "L:0 R:0 F:0 T:0";
         mFpsTextField.selectable = false;
         mFpsTextField.mouseEnabled = false;
         mFpsTextField.autoSize = "left";
         mFpsTextField.y = 20;
         var _loc2_:TextFormat = new TextFormat();
         _loc2_.bold = true;
         _loc2_.font = "Verdana";
         _loc2_.color = 65280;
         _loc2_.size = 14;
         mFpsTextField.setTextFormat(_loc2_);
         mFpsTextField.defaultTextFormat = _loc2_;
         mFpsTextField.alpha = 1;
         mFpsTextField.background = true;
         mFpsTextField.backgroundColor = 0;
         mFpsTextField.cacheAsBitmap = true;
         mFpsTextField.name = "FpsDebugTextField";
         mDBFacade.addRootDisplayObject(mFpsTextField,1002);
         mFpsTextField.visible = false;
      }
      
      public function update(mTickCounter:int, mWallClockTimeElapsed:Number, mFrameAccumulator:int, mRenderTickCounter:int, mTickAccumulator:int) : void
      {
         var _loc7_:Number = NaN;
         var _loc6_:Number = NaN;
         if(mFpsTextField)
         {
            _loc7_ = mWallClockTimeElapsed == 0 ? averageLogicalFPS : mTickCounter * 1000 / mWallClockTimeElapsed;
            _loc6_ = mWallClockTimeElapsed == 0 ? averageRenderFPS : mRenderTickCounter * 1000 / mWallClockTimeElapsed;
            averageLogicalFPS = (averageLogicalFPS + _loc7_) / 2;
            averageRenderFPS = (averageRenderFPS + _loc6_) / 2;
            if(!mFpsTextField.visible)
            {
               return;
            }
            mFpsTextField.text = "L:" + _loc7_.toFixed(1) + " R:" + _loc6_.toFixed(1) + " F:" + mFrameAccumulator + " T:" + mTickAccumulator;
         }
      }
      
      public function toggleVisibility() : void
      {
         mWantVisible = !mWantVisible;
         applyVisibility();
      }
      
      public function set suppressed(value:Boolean) : void
      {
         mSuppressed = value;
         applyVisibility();
      }
      
      private function applyVisibility() : void
      {
         if(mFpsTextField)
         {
            mFpsTextField.visible = mWantVisible && !mSuppressed;
         }
      }
   }
}

