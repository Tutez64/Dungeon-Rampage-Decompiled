package Brain.Camera
{
   import Brain.Clock.GameClock;
   import Brain.Facade.Facade;
   import Brain.Logger.Logger;
   import Brain.Utils.MemoryTracker;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Brain.WorkLoop.Task;
   import flash.display.Sprite;
   import flash.geom.Vector3D;
   
   public class BackgroundFader
   {
      
      public static const TYPE:String = "fadebackground";
      
      private var mFacade:Facade;
      
      private var mExcludes:Array;
      
      private var mRectSprite:Sprite;
      
      private var mDuration:uint;
      
      private var mTransitionDuration:Number;
      
      private var mColor:Vector3D;
      
      private var mOffset:Number;
      
      private var mAlpha:Number;
      
      private var mWorkComponent:LogicalWorkComponent;
      
      private var mFadeTask:Task;
      
      private var mFramesElapsed:uint;
      
      private var mStartTop:Number;
      
      private var mStartLeft:Number;
      
      private const mPadding:Number = 1300;
      
      public function BackgroundFader(facade:Facade)
      {
         super();
         mFramesElapsed = 0;
         mFacade = facade;
         mWorkComponent = new LogicalWorkComponent(facade,"BackgroundFader");
         MemoryTracker.track(mWorkComponent,"LogicalWorkComponent - created in BackgroundFader()","brain");
      }
      
      public function doFade(excludes:Array, duration:uint, transitionDur:Number, color:Vector3D, alpha:Number) : void
      {
         var _loc6_:int = 0;
         if(!mRectSprite)
         {
            mDuration = duration;
            mTransitionDuration = transitionDur;
            mColor = new Vector3D(color.x,color.y,color.z);
            mAlpha = alpha;
            mOffset = alpha / transitionDur;
            mExcludes = excludes;
            execute();
         }
         else
         {
            _loc6_ = mDuration - mFramesElapsed;
            mDuration = _loc6_ > duration ? _loc6_ : duration;
            mTransitionDuration = transitionDur;
            mFramesElapsed = 0;
            mAlpha = mAlpha > alpha ? mAlpha : alpha;
            mOffset = mAlpha / mTransitionDuration;
         }
      }
      
      private function execute() : void
      {
         if(mFramesElapsed != 0)
         {
            ResetFade();
         }
         mFramesElapsed = 0;
         mRectSprite = new Sprite();
         MemoryTracker.track(mRectSprite,"Sprite - fade rect created in BackgroundFader.execute()","brain");
         mRectSprite.graphics.beginFill(mColor.x << 16 | mColor.y << 8 | mColor.z,1);
         mStartTop = mFacade.camera.visibleRectangle.top - 1300 * 0.5;
         mStartLeft = mFacade.camera.visibleRectangle.left - 1300 * 0.5;
         mRectSprite.graphics.drawRect(mStartLeft,mStartTop,mFacade.stageRef.fullScreenWidth + 1300,mFacade.stageRef.fullScreenHeight + 1300);
         mRectSprite.graphics.endFill();
         mRectSprite.cacheAsBitmap = true;
         mRectSprite.alpha = 0;
         mFacade.sceneGraphManager.addChild(mRectSprite,42);
         for each(var _loc1_:Sprite in mExcludes)
         {
            mFacade.sceneGraphManager.addChild(_loc1_,46);
         }
         mFadeTask = mWorkComponent.doEveryFrame(UpdateBackgroundFade);
      }
      
      public function UpdateBackgroundFade(clock:GameClock) : void
      {
         if(!mRectSprite)
         {
            Logger.error("BackgroundFader with null RectSprite");
            return;
         }
         mRectSprite.x = mFacade.camera.visibleRectangle.left - mStartLeft - 1300 * 0.5;
         mRectSprite.y = mFacade.camera.visibleRectangle.top - mStartTop - 1300 * 0.5;
         mFramesElapsed = mFramesElapsed + 1;
         if(mFramesElapsed <= mTransitionDuration)
         {
            mRectSprite.alpha += mOffset;
            mRectSprite.alpha = Math.min(mRectSprite.alpha,mAlpha);
         }
         else if(mFramesElapsed >= mDuration - mTransitionDuration)
         {
            mRectSprite.alpha -= mOffset;
            mRectSprite.alpha = Math.max(mRectSprite.alpha,0);
         }
         if(mFramesElapsed > mDuration)
         {
            ResetFade();
            return;
         }
      }
      
      private function ResetFade() : void
      {
         mFramesElapsed = 0;
         mFacade.sceneGraphManager.removeChild(mRectSprite);
         for each(var _loc1_:Sprite in mExcludes)
         {
            mFacade.sceneGraphManager.addChild(_loc1_,20);
         }
         mExcludes = null;
         mRectSprite = null;
         mFadeTask.destroy();
         mFadeTask = null;
      }
      
      public function forceStop() : void
      {
         if(mFadeTask && mRectSprite)
         {
            ResetFade();
         }
      }
      
      public function destroy() : void
      {
         if(mFadeTask)
         {
            mFadeTask.destroy();
            mFadeTask = null;
         }
         if(mWorkComponent)
         {
            mWorkComponent.destroy();
            mWorkComponent = null;
         }
      }
   }
}

