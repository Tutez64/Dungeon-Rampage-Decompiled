package Brain.Render
{
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Clock.GameClock;
   import Brain.Facade.Facade;
   import Brain.Logger.Logger;
   import Brain.Sound.SoundComponent;
   import Brain.UI.UIButton;
   import flash.display.MovieClip;
   import flash.geom.Vector3D;
   
   public class MovieClipCutsceneRenderer extends MovieClipRenderer
   {
      
      private static const PAUSE_LABEL:String = "pause";
      
      protected var mPauseFrames:Vector.<uint> = new Vector.<uint>();
      
      protected var mNextPauseFrame:uint;
      
      protected var mNextButton:UIButton;
      
      protected var mSkipButton:UIButton;
      
      protected var mSoundFrames:Vector.<uint> = new Vector.<uint>();
      
      protected var mSoundClasses:Vector.<String> = new Vector.<String>();
      
      protected var mSoundComponent:SoundComponent;
      
      protected var mAssetLoadingComponent:AssetLoadingComponent;
      
      protected var mFacade:Facade;
      
      public function MovieClipCutsceneRenderer(facade:Facade, clip:MovieClip, finishedCallback:Function = null, assetLabel:String = null)
      {
         mAssetLoadingComponent = new AssetLoadingComponent(facade);
         mSoundComponent = new SoundComponent(facade);
         super(facade,clip,finishedCallback,assetLabel);
         mFacade = facade;
         mFacade.camera.doLetterboxEffect(10000,120,new Vector3D(0,0,0),1);
         createButtons();
      }
      
      private function createButtons() : void
      {
         mAssetLoadingComponent.getSwfAsset(mClip.loaderInfo.url,buttonsSwfLoaded);
      }
      
      private function buttonsSwfLoaded(swfAsset:SwfAsset) : void
      {
         var _loc3_:Class = swfAsset.getClass("next_button");
         var _loc2_:Class = swfAsset.getClass("skip_button");
         mNextButton = new UIButton(mFacade,new _loc3_());
         mSkipButton = new UIButton(mFacade,new _loc2_());
         mFacade.sceneGraphManager.addChild(mNextButton.root,105);
         mFacade.sceneGraphManager.addChild(mSkipButton.root,105);
         mSkipButton.root.x = mFacade.viewWidth - (mSkipButton.root.width / 2 + 10);
         mSkipButton.root.y = mFacade.viewHeight - (mSkipButton.root.height / 2 + 10);
         mNextButton.root.x = mFacade.viewWidth - (mNextButton.root.width / 2 + 10);
         mNextButton.root.y = mFacade.viewHeight - (mSkipButton.root.height + 10) - (mNextButton.root.height / 2 + 4);
         mNextButton.releaseCallback = onNext;
         mSkipButton.releaseCallback = onSkip;
      }
      
      override public function destroy() : void
      {
         if(mAssetLoadingComponent)
         {
            mAssetLoadingComponent.destroy();
            mAssetLoadingComponent = null;
         }
         if(mSoundComponent)
         {
            mSoundComponent.destroy();
            mSoundComponent = null;
         }
         super.destroy();
         if(mNextButton)
         {
            mFacade.sceneGraphManager.removeChild(mNextButton.root);
            mNextButton.destroy();
            mNextButton = null;
         }
         if(mSkipButton)
         {
            mFacade.sceneGraphManager.removeChild(mSkipButton.root);
            mSkipButton.destroy();
            mSkipButton = null;
         }
      }
      
      protected function onNext() : void
      {
         clip.gotoAndStop(mNextPauseFrame);
         play();
         if(mPauseFrames.length)
         {
            mNextPauseFrame = mPauseFrames.shift();
         }
         else
         {
            mNextPauseFrame = clip.totalFrames - 1;
            mNextButton.destroy();
            mNextButton = null;
         }
      }
      
      protected function onSkip() : void
      {
         clip.gotoAndStop(mNextPauseFrame);
         if(mFinishedCallback != null)
         {
            mFinishedCallback();
         }
         mFacade.camera.killLetterboxEffect();
      }
      
      override public function onFrame(gameClock:GameClock) : void
      {
         if(!mClip)
         {
            return;
         }
         if(mClip.stage == null)
         {
            Logger.warn("Animating MovieClipRenderer that is not on stage");
         }
         if(!mIsPlaying)
         {
            return;
         }
         mPlayHead += mFrameRate * gameClock.tickLength * mPlayRate;
         if(mPlayHead > mNextPauseFrame)
         {
            mIsPlaying = false;
            mPlayHead = mNextPauseFrame;
            this.updateClip(mClip);
            if(mOnFrameTask != null)
            {
               mOnFrameTask.destroy();
               mOnFrameTask = null;
            }
            if(mNextPauseFrame == clip.totalFrames - 1)
            {
               mFacade.camera.killLetterboxEffect();
               if(mFinishedCallback != null)
               {
                  mFinishedCallback();
               }
            }
            return;
         }
         this.updateClip(mClip);
      }
      
      override protected function determineFrames(clip:MovieClip) : void
      {
         var _loc3_:Number = NaN;
         var _loc4_:* = 0;
         var _loc2_:String = null;
         if(clip.currentLabels)
         {
            _loc3_ = clip.soundTransform.volume;
            _loc4_ = 1;
            while(_loc4_ <= clip.totalFrames)
            {
               clip.gotoAndStop(_loc4_);
               clip.soundTransform.volume = 0;
               if(clip.currentFrameLabel == "pause")
               {
                  mPauseFrames.push(_loc4_);
               }
               else if(clip.currentFrameLabel && clip.currentFrameLabel.indexOf("play ") == 0)
               {
                  mSoundFrames.push(_loc4_);
                  _loc2_ = clip.currentFrameLabel.slice(5);
                  trace("Found sound: " + _loc2_ + " at frame: " + _loc4_.toString());
                  mSoundClasses.push(_loc2_);
               }
               _loc4_++;
            }
         }
         mNextPauseFrame = mPauseFrames.length ? mPauseFrames.shift() : 0;
      }
   }
}

