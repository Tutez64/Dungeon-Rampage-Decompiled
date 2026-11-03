package Starling
{
   import Brain.Facade.Facade;
   import Brain.Starling.StarlingScenerySprite;
   import Brain.Utils.MemoryTracker;
   import starling.display.Image;
   import starling.extensions.animate.Animation;
   
   public class StarlingView extends StarlingScenerySprite
   {
      
      private static const FALLBACK_STAGE_REACH:Number = 1360;
      
      protected var mFacade:Facade;
      
      protected var mImage:Image;
      
      protected var mAnimation:Animation;
      
      protected var mImageKey:String;
      
      public function StarlingView(inFacade:Facade, inCacheKey:String)
      {
         super();
         mFacade = inFacade;
         mImageKey = inCacheKey;
         touchable = false;
         name = "StarlingView_" + inCacheKey;
         MemoryTracker.track(this,"StarlingView - view: " + inCacheKey,"starling");
      }
      
      public function set image(inImage:Image) : void
      {
         if(mImage)
         {
            removeChild(mImage);
            mImage.dispose();
         }
         mImage = inImage;
         MemoryTracker.track(mImage,"StarlingView - Image: " + mImageKey,"starling");
         addChild(mImage);
         mImage.touchable = false;
      }
      
      public function set animation(inAnimation:Animation) : void
      {
         if(mAnimation)
         {
            mFacade.starlingLayerManager.juggler.remove(mAnimation);
            removeChild(mAnimation);
            mAnimation.dispose();
         }
         mAnimation = inAnimation;
         mAnimation.play();
         mFacade.starlingLayerManager.juggler.add(mAnimation);
         addChild(mAnimation);
      }
      
      override protected function get cullReach() : Number
      {
         if(mAnimation == null)
         {
            return 0;
         }
         var _loc1_:Number = mAnimation.sourceWidth + mAnimation.sourceHeight;
         return _loc1_ > 0 ? _loc1_ : 1360;
      }
      
      public function addToStage() : void
      {
         if(mImage && !mAnimation)
         {
            mImage.visible = true;
         }
         else if(mAnimation)
         {
            mAnimation.visible = true;
            mFacade.starlingLayerManager.juggler.add(mAnimation);
         }
      }
      
      public function removeFromStage() : void
      {
         if(mImage && !mAnimation)
         {
            mImage.visible = false;
         }
         else if(mAnimation)
         {
            mAnimation.visible = false;
            mFacade.starlingLayerManager.juggler.remove(mAnimation);
         }
      }
      
      override public function dispose() : void
      {
         if(mImage)
         {
            mImage.removeFromParent(true);
         }
         if(mAnimation)
         {
            mFacade.starlingLayerManager.juggler.remove(mAnimation);
            mAnimation.removeFromParent(true);
         }
         if(mFacade.starlingLayerManager != null && mImageKey != null)
         {
            mFacade.starlingLayerManager.sourceCache.releaseRef(mImageKey);
         }
         mImage = null;
         mImageKey = null;
         super.dispose();
      }
   }
}

