package Actor.Buffs
{
   import Actor.ActorGameObject;
   import Actor.ActorView;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Clock.GameClock;
   import Brain.Logger.Logger;
   import Brain.Render.MovieClipRenderController;
   import Brain.Render.Tweens.TweenHandle;
   import Brain.WorkLoop.LogicalWorkComponent;
   import DistributedObjects.DistributedDungeonFloor;
   import Effects.EffectManager;
   import Effects.EffectView;
   import Facade.DBFacade;
   import Floor.FloorView;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class BuffView extends FloorView
   {
      
      private var mAssetLoadingComponent:AssetLoadingComponent;
      
      private var mBuff:MovieClip;
      
      private var mParentGameObject:BuffGameObject;
      
      private var mParentView:ActorView;
      
      private var mTintColor:Number;
      
      private var mTintAmount:Number;
      
      protected var mTween:TweenHandle;
      
      private var mStarlingTintTween:TweenHandle;
      
      private var mStarlingTintProxy:Object;
      
      protected var mSortLayer:String;
      
      private var mNewScale:Number;
      
      private var mOriginalScale:Number;
      
      private var mScaleUpStartDelayTime:Number;
      
      private var mScaleUpIncrementTime:Number;
      
      private var mScaleUpIncrementScale:Number;
      
      private var mLogicalWorkComponent:LogicalWorkComponent;
      
      private var mHideTween:TweenHandle;
      
      private var mShowTween:TweenHandle;
      
      private var mEffectManager:EffectManager;
      
      private var mManagedEffectId:uint;
      
      private var mEffectView:EffectView;
      
      private var mTintStarted:Boolean;
      
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
            if(!startManagedBuffEffect())
            {
               mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
               mAssetLoadingComponent.getSwfAsset(buffGameObject.swfPath,assetLoaded);
            }
         }
         else
         {
            checkForScaling();
         }
      }
      
      private function startManagedBuffEffect() : Boolean
      {
         var _loc2_:ActorGameObject = mParentGameObject.actorGameObject;
         var _loc3_:DistributedDungeonFloor = _loc2_ != null ? _loc2_.distributedDungeonFloor : null;
         var _loc1_:EffectManager = _loc3_ != null ? _loc3_.effectManager : null;
         if(_loc1_ == null)
         {
            return false;
         }
         mEffectManager = _loc1_;
         mManagedEffectId = _loc1_.playEffect(mParentGameObject.swfPath,mParentGameObject.className,mParentGameObject.position,_loc2_,mSortLayer != "foreground",1,0,0,0,0,true,"sorted",true,1,null,null,"BUFF");
         mEffectView = _loc1_.managedEffectView(mManagedEffectId);
         if(mEffectView != null)
         {
            mEffectView.artResolvedCallback = onBuffArtResolved;
            if(mEffectView.isArtLoaded)
            {
               onBuffArtResolved();
            }
         }
         checkForScaling();
         return true;
      }
      
      private function onBuffArtResolved() : void
      {
         if(mDBFacade == null || mTintStarted || mTintColor == -1)
         {
            return;
         }
         mTintStarted = true;
         var _loc1_:Number = mEffectView.artDurationInSeconds * 0.5;
         startTintTweens(_loc1_);
      }
      
      private function startTintTweens(halfDuration:Number) : void
      {
         mTween = mDBFacade.mTween.tweenFromTo(mParentView.body,halfDuration,{"colorMatrixFilter":{}},{
            "repeat":-1,
            "yoyo":true,
            "colorMatrixFilter":{
               "colorize":mTintColor,
               "amount":mTintAmount
            }
         });
         mStarlingTintProxy = {"amount":0};
         var tintColor:uint = mTintColor;
         var parentView:ActorView = mParentView;
         var proxy:Object = mStarlingTintProxy;
         mStarlingTintTween = mDBFacade.mTween.tweenFromTo(mStarlingTintProxy,halfDuration,{"amount":0},{
            "repeat":-1,
            "yoyo":true,
            "amount":mTintAmount,
            "onUpdate":function():void
            {
               parentView.applyStatusTint(tintColor,proxy.amount);
            }
         });
      }
      
      private function assetLoaded(swfAsset:SwfAsset) : void
      {
         var _loc2_:Class = swfAsset.getClass(mParentGameObject.className);
         if(mDBFacade == null)
         {
            return;
         }
         if(_loc2_)
         {
            mBuff = new _loc2_();
            mMovieClipRenderer = new MovieClipRenderController(mDBFacade,mBuff,finishedCallback);
            mMovieClipRenderer.play(0,true);
            mParentView.buildBuff(mBuff,mSortLayer);
            if(mTintColor != -1)
            {
               mTintStarted = true;
               startTintTweens(mMovieClipRenderer.durationInSeconds * 0.5);
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
            mDBFacade.mTween.tweenMaxTo(mParentView.body,mScaleUpIncrementTime / 2,{
               "tint":mTintColor,
               "onCompleteListener":function():void
               {
                  mDBFacade.mTween.tweenMaxTo(mParentView.body,0,{"removeTint":true});
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
         if(mDBFacade == null)
         {
            return;
         }
         if(mNewScale)
         {
            mDBFacade.mTween.tweenMaxTo(mParentView.root,0.3,{
               "scaleX":mOriginalScale,
               "scaleY":mOriginalScale
            });
         }
         if(mEffectView != null)
         {
            mEffectView.artResolvedCallback = null;
            mEffectView = null;
         }
         if(mEffectManager != null)
         {
            mEffectManager.endManagedEffect(mManagedEffectId);
            mEffectManager = null;
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
            mDBFacade.mTween.completeTween(mTween);
            mDBFacade.mTween.killTween(mTween);
            mTween = null;
         }
         if(mStarlingTintTween != null)
         {
            mDBFacade.mTween.completeTween(mStarlingTintTween);
            mDBFacade.mTween.killTween(mStarlingTintTween);
            mStarlingTintTween = null;
            mStarlingTintProxy = null;
            if(mParentView != null)
            {
               mParentView.clearStatusTint();
            }
         }
         if(mHideTween != null)
         {
            mDBFacade.mTween.completeTween(mHideTween);
            mDBFacade.mTween.killTween(mHideTween);
            mHideTween = null;
         }
         if(mShowTween != null)
         {
            mDBFacade.mTween.completeTween(mShowTween);
            mDBFacade.mTween.killTween(mShowTween);
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
      
      private function get fadeTarget() : DisplayObject
      {
         if(mBuff != null)
         {
            return mBuff;
         }
         return mEffectView != null ? mEffectView.root : null;
      }
      
      public function hide(transitionTime:Number) : void
      {
         var target:DisplayObject;
         if(mShowTween != null)
         {
            mDBFacade.mTween.killTween(mShowTween);
            mShowTween = null;
         }
         target = fadeTarget;
         if(target != null)
         {
            mHideTween = mDBFacade.mTween.tweenMaxTo(target,transitionTime,{
               "alpha":0,
               "onCompleteListener":function():void
               {
                  target.visible = false;
                  target.alpha = 1;
               }
            });
         }
      }
      
      public function show(transitionTime:Number) : void
      {
         if(mHideTween != null)
         {
            mDBFacade.mTween.killTween(mHideTween);
            mHideTween = null;
         }
         var _loc2_:DisplayObject = fadeTarget;
         if(_loc2_ == null)
         {
            return;
         }
         _loc2_.alpha = 0;
         _loc2_.visible = true;
         mShowTween = mDBFacade.mTween.tweenMaxTo(_loc2_,transitionTime,{"alpha":1});
      }
   }
}

