package Effects
{
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Logger.Logger;
   import Brain.Render.MovieClipRenderController;
   import Facade.DBFacade;
   import Floor.FloorView;
   import flash.display.MovieClip;
   
   public class EffectView extends FloorView
   {
      
      private var mAssetLoadingComponent:AssetLoadingComponent;
      
      private var mEffect:MovieClip;
      
      private var mEffectClassName:String;
      
      protected var mLoop:Boolean;
      
      private var mShouldBePlaying:ShouldBePlaying;
      
      protected var mAssetLoadedCallback:Function;
      
      public function EffectView(facade:DBFacade, effectGameObject:EffectGameObject, assetLoadedCallback:Function = null)
      {
         super(facade,effectGameObject);
         mAssetLoadingComponent = new AssetLoadingComponent(mFacade);
         mEffectClassName = effectGameObject.className;
         mAssetLoadedCallback = assetLoadedCallback;
         mAssetLoadingComponent.getSwfAsset(effectGameObject.swfPath,assetLoaded);
      }
      
      public function setPlayRate(val:Number) : void
      {
         if(mMovieClipRenderer)
         {
            mMovieClipRenderer.playRate = val;
         }
      }
      
      public function play(loop:Boolean, finishedCallback:Function) : void
      {
         if(mMovieClipRenderer)
         {
            mMovieClipRenderer.play(0,loop,finishedCallback);
         }
         else
         {
            mShouldBePlaying = new ShouldBePlaying(loop,finishedCallback);
         }
      }
      
      public function stop() : void
      {
         mShouldBePlaying = null;
         if(mMovieClipRenderer)
         {
            mMovieClipRenderer.stop();
            mMovieClipRenderer.finishedCallback = null;
         }
         this.removeFromStage();
         if(mRoot.parent)
         {
            mRoot.parent.removeChild(mRoot);
         }
      }
      
      private function assetLoaded(swfAsset:SwfAsset) : void
      {
         var _loc2_:Class = swfAsset.getClass(mEffectClassName);
         if(_loc2_ == null)
         {
            Logger.error("Unable to find class: " + mEffectClassName);
            return;
         }
         mEffect = new _loc2_();
         mMovieClipRenderer = new MovieClipRenderController(mFacade,mEffect);
         if(mShouldBePlaying)
         {
            mMovieClipRenderer.play(0,mShouldBePlaying.loop,mShouldBePlaying.finishedCallback);
         }
         mRoot.mouseChildren = false;
         mRoot.mouseEnabled = false;
         mRoot.addChild(mEffect);
         if(mAssetLoadedCallback != null)
         {
            mAssetLoadedCallback(mEffect);
         }
      }
      
      override public function destroy() : void
      {
         mEffect = null;
         if(mAssetLoadingComponent)
         {
            mAssetLoadingComponent.destroy();
            mAssetLoadingComponent = null;
         }
         super.destroy();
      }
   }
}

class ShouldBePlaying
{
   
   public var loop:Boolean;
   
   public var finishedCallback:Function;
   
   public function ShouldBePlaying(l:Boolean, f:Function)
   {
      super();
      loop = l;
      finishedCallback = f;
   }
}
