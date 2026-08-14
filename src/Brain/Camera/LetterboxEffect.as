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
   
   public class LetterboxEffect
   {
      
      private var mFacade:Facade;
      
      private var mRectSprite:Sprite;
      
      private var mDuration:uint;
      
      private var mTransitionDuration:Number;
      
      private var mColor:Vector3D;
      
      private var mOffset:Number;
      
      private var mAlpha:Number;
      
      private var mWorkComponent:LogicalWorkComponent;
      
      private var mFadeTask:Task;
      
      private var mFramesElapsed:uint;
      
      private const mPadding:Number = 512;
      
      public function LetterboxEffect(facade:Facade)
      {
         super();
         mFramesElapsed = 0;
         mFacade = facade;
         mWorkComponent = new LogicalWorkComponent(facade,"LetterboxEffect");
         MemoryTracker.track(mWorkComponent,"LogicalWorkComponent - created in LetterboxEffect()","brain");
      }
      
      public function doFade(duration:uint, transitionDur:Number, color:Vector3D, alpha:Number) : void
      {
         var _loc5_:int = 0;
         if(!mRectSprite)
         {
            mDuration = duration;
            mTransitionDuration = transitionDur;
            mColor = new Vector3D(color.x,color.y,color.z);
            mAlpha = alpha;
            mOffset = alpha / transitionDur;
            execute();
         }
         else
         {
            _loc5_ = mDuration - mFramesElapsed;
            mDuration = _loc5_ > duration ? _loc5_ : duration;
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
         MemoryTracker.track(mRectSprite,"Sprite - letterbox rect created in LetterboxEffect.execute()","brain");
         mRectSprite.graphics.beginFill(mColor.x << 16 | mColor.y << 8 | mColor.z,1);
         mRectSprite.graphics.drawRect(0,0,mFacade.stageRef.fullScreenWidth + 512,75);
         mRectSprite.graphics.drawRect(0,mFacade.stageRef.fullScreenHeight - 550,mFacade.stageRef.fullScreenWidth + 512,375);
         mRectSprite.graphics.endFill();
         mRectSprite.cacheAsBitmap = true;
         mRectSprite.alpha = 0;
         mFacade.sceneGraphManager.addChild(mRectSprite,100);
         mFadeTask = mWorkComponent.doEveryFrame(UpdateBackgroundFade);
      }
      
      public function UpdateBackgroundFade(clock:GameClock) : void
      {
         if(!mRectSprite)
         {
            Logger.warn("LetterboxEffect with null RectSprite");
            return;
         }
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
         else if(mFramesElapsed > mTransitionDuration)
         {
            mRectSprite.alpha = mAlpha;
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

