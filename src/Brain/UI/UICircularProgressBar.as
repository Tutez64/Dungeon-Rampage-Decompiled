package Brain.UI
{
   import Brain.Clock.GameClock;
   import Brain.Facade.Facade;
   import Brain.Utils.MemoryTracker;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Brain.WorkLoop.Task;
   import flash.display.Graphics;
   import flash.display.MovieClip;
   
   public class UICircularProgressBar extends UIObject
   {
      
      protected var mDuration:Number;
      
      protected var mDeltaAngle:Number;
      
      protected var mCurrentAngle:Number;
      
      protected var mCurrentX:Number;
      
      protected var mCurrentY:Number;
      
      protected var mColor:uint;
      
      protected var mRadius:Number;
      
      protected var mStartAngle:Number;
      
      protected var mLogicalWorkComponent:LogicalWorkComponent;
      
      protected var mGraphics:Graphics;
      
      protected var mEmptyClip:MovieClip;
      
      protected var mStartTime:Number;
      
      protected var mDrawTask:Task;
      
      public function UICircularProgressBar(facade:Facade, root:MovieClip, radius:Number, color:uint, duration:Number, dAngle:Number = 1, startAngle:Number = 180)
      {
         super(facade,root);
         mLogicalWorkComponent = new LogicalWorkComponent(facade,"UICircularProgressBar");
         MemoryTracker.track(mLogicalWorkComponent,"LogicalWorkComponent - created in UICircularProgressBar()","brain");
         mEmptyClip = new MovieClip();
         MemoryTracker.track(mEmptyClip,"MovieClip - drawing clip created in UICircularProgressBar()","brain");
         mGraphics = mEmptyClip.graphics;
         root.addChildAt(mEmptyClip,root.numChildren);
         mStartAngle = startAngle;
         mDuration = duration;
         mDeltaAngle = dAngle;
         mRadius = radius;
         mColor = color;
         mCurrentAngle = startAngle;
         calculateStep();
      }
      
      private function killDrawTask(gameClock:GameClock) : void
      {
         mGraphics.clear();
         mDrawTask.destroy();
      }
      
      private function calculateStep() : void
      {
         var _loc1_:Number = mCurrentAngle * 3.141592653589793 / 180;
         mCurrentX = mRadius * Math.sin(_loc1_);
         mCurrentY = mRadius * Math.cos(_loc1_);
      }
      
      public function get clip() : MovieClip
      {
         return mEmptyClip;
      }
      
      public function set clip(value:MovieClip) : void
      {
         mEmptyClip = value;
      }
      
      public function get angle() : Number
      {
         return mCurrentAngle;
      }
      
      public function set angle(value:Number) : void
      {
         var _loc4_:int = 0;
         var _loc2_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:int = Math.round(value / mDeltaAngle);
         var _loc3_:Number = mCurrentAngle * 3.141592653589793 / 180;
         _loc4_ = 0;
         while(_loc4_ < _loc6_)
         {
            _loc2_ = mRadius * Math.sin(_loc3_);
            _loc5_ = mRadius * Math.cos(_loc3_);
            mGraphics.moveTo(mCurrentX,mCurrentY);
            mGraphics.lineStyle(5,mColor);
            mGraphics.lineTo(_loc2_,_loc5_);
            mGraphics.endFill();
            mCurrentX = _loc2_;
            mCurrentY = _loc5_;
            mCurrentAngle -= mDeltaAngle;
            _loc4_++;
         }
      }
      
      public function set updateTask(value:Task) : void
      {
         mDrawTask = value;
      }
      
      override public function destroy() : void
      {
         if(mDrawTask)
         {
            mDrawTask.destroy();
            mDrawTask = null;
         }
         if(mLogicalWorkComponent)
         {
            mLogicalWorkComponent.destroy();
            mLogicalWorkComponent = null;
         }
         super.destroy();
      }
   }
}

