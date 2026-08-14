package Actor.Buffs
{
   import Actor.ActorView;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Clock.GameClock;
   import Brain.Logger.Logger;
   import Brain.Render.MovieClipRenderController;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Facade.DBFacade;
   import Floor.FloorView;
   import com.greensock.TweenMax;
   import flash.display.MovieClip;
   
   public class BuffView extends FloorView
   {
      
      private var mAssetLoadingComponent:AssetLoadingComponent;
      
      private var mBuff:MovieClip;
      
      private var mParentGameObject:BuffGameObject;
      
      private var mParentView:ActorView;
      
      private var mTintColor:Number;
      
      private var mTintAmount:Number;
      
      protected var mTween:TweenMax;
      
      protected var mSortLayer:String;
      
      private var mNewScale:Number;
      
      private var mOriginalScale:Number;
      
      private var mScaleUpStartDelayTime:Number;
      
      private var mScaleUpIncrementTime:Number;
      
      private var mScaleUpIncrementScale:Number;
      
      private var mLogicalWorkComponent:LogicalWorkComponent;
      
      private var mHideTween:TweenMax;
      
      private var mShowTween:TweenMax;
      
      public function BuffView(facade:DBFacade, buffGameObject:BuffGameObject, parentView:ActorView, tintColor:Number, tintAmount:Number, scale:Number, scaleStartDelayTime:Number, scaleIncrementTime:Number, scaleIncrementScale:Number)
      {
         mParentView = parentView;
         mParentGameObject = buffGameObject;
         mTintColor = tintColor;
         mTintAmount = tintAmount;
         mSortLayer = buffGameObject.mSortLayer;
         mNewScale = scale;
         mScaleUpStartDelayTime = scaleStartDelayTime;
         mScaleUpIncrementTime = scaleIncrementTime;
         mScaleUpIncrementScale = scaleIncrementScale;
         mLogicalWorkComponent = new LogicalWorkComponent(facade,"BuffView");
         super(facade,buffGameObject);
         if(buffGameObject.className)
         {
            mAssetLoadingComponent = new AssetLoadingComponent(mFacade);
            mAssetLoadingComponent.getSwfAsset(buffGameObject.swfPath,assetLoaded);
         }
         else
         {
            checkForScaling();
         }
      }
      
      private function assetLoaded(swfAsset:SwfAsset) : void
      {
         var _loc2_:Class = swfAsset.getClass(mParentGameObject.className);
         if(mFacade == null)
         {
            return;
         }
         if(_loc2_)
         {
            mBuff = new _loc2_();
            mMovieClipRenderer = new MovieClipRenderController(mFacade,mBuff,finishedCallback);
            mMovieClipRenderer.play(0,true);
            mParentView.buildBuff(mBuff,mSortLayer);
            if(mTintColor != -1)
            {
               mTween = TweenMax.fromTo(mParentView.body,mMovieClipRenderer.durationInSeconds * 0.5,{"colorMatrixFilter":{}},{
                  "repeat":-1,
                  "yoyo":true,
                  "colorMatrixFilter":{
                     "colorize":mTintColor,
                     "amount":mTintAmount
                  }
               });
            }
            checkForScaling();
         }
         else
         {
            Logger.warn(mParentGameObject.className + " doesn\'t exist !");
         }
      }
      
      private function checkForScaling() : void
      {
         if(mNewScale)
         {
            mOriginalScale = mParentView.root.scaleX;
            if(mScaleUpIncrementScale == 0 || mScaleUpIncrementTime == 0)
            {
               mParentView.root.scaleX = mParentView.root.scaleY = mNewScale;
            }
            else
            {
               mLogicalWorkComponent.doLater(mScaleUpStartDelayTime,delayStartScaling);
            }
         }
      }
      
      private function delayStartScaling(gameClock:GameClock) : void
      {
         mLogicalWorkComponent.doEverySeconds(mScaleUpIncrementTime,scaleUpCall);
      }
      
      private function scaleUpCall(gameClock:GameClock) : void
      {
         if(mParentView.root.scaleX <= mNewScale - mScaleUpIncrementScale)
         {
            mParentView.root.scaleX += mScaleUpIncrementScale;
            mParentView.root.scaleY += mScaleUpIncrementScale;
            TweenMax.to(mParentView.body,mScaleUpIncrementTime / 2,{
               "tint":mTintColor,
               "onCompleteListener":function():void
               {
                  TweenMax.to(mParentView.body,0,{"removeTint":true});
               }
            });
         }
         else
         {
            mParentView.root.scaleX = mParentView.root.scaleY = mNewScale;
            mLogicalWorkComponent.clear();
         }
      }
      
      public function showInHUD() : void
      {
         mDBFacade.hud.showBuffDisplay(mParentGameObject);
      }
      
      override public function destroy() : void
      {
         if(mFacade == null)
         {
            return;
         }
         if(mNewScale)
         {
            TweenMax.to(mParentView.root,0.3,{
               "scaleX":mOriginalScale,
               "scaleY":mOriginalScale
            });
         }
         if(mAssetLoadingComponent != null)
         {
            mAssetLoadingComponent.destroy();
            mAssetLoadingComponent = null;
         }
         if(mMovieClipRenderer)
         {
            mMovieClipRenderer.destroy();
            mMovieClipRenderer = null;
         }
         if(mTween != null)
         {
            mTween.complete();
            mTween.kill();
            mTween = null;
         }
         if(mHideTween != null)
         {
            mHideTween.complete();
            mHideTween.kill();
            mHideTween = null;
         }
         if(mShowTween != null)
         {
            mShowTween.complete();
            mShowTween.kill();
            mShowTween = null;
         }
         if(mLogicalWorkComponent)
         {
            mLogicalWorkComponent.destroy();
            mLogicalWorkComponent = null;
         }
         if(mParentView != null)
         {
            mParentView.destroyBuff(mBuff);
         }
         super.destroy();
      }
      
      public function finishedCallback() : void
      {
      }
      
      public function hide(transitionTime:Number) : void
      {
         if(mBuff != null)
         {
            mHideTween = TweenMax.to(mBuff,transitionTime,{
               "alpha":0,
               "onCompleteListener":function():void
               {
                  mBuff.visible = false;
                  mBuff.alpha = 1;
               }
            });
         }
      }
      
      public function show(transitionTime:Number) : void
      {
         mBuff.alpha = 0;
         mBuff.visible = true;
         mShowTween = TweenMax.to(mBuff,transitionTime,{"alpha":1});
      }
   }
}

