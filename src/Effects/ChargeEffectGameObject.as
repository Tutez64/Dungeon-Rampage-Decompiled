package Effects
{
   import Actor.ActorView;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Render.MovieClipRenderController;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Facade.DBFacade;
   import com.greensock.TweenMax;
   import flash.display.MovieClip;
   import flash.filters.GlowFilter;
   
   public class ChargeEffectGameObject extends EffectGameObject
   {
      
      private static const FINAL_CHARGE_SCALE_X:Number = 1.3286423841059603;
      
      private static const FINAL_CHARGE_SCALE_Y:Number = 1.3283450704225352;
      
      private static const CHARGE_DELAY:Number = 0;
      
      private static const RADIUS:uint = 50;
      
      protected static var mChargeGlow:GlowFilter = new GlowFilter(16763904,1,128,128,1.8);
      
      protected var mReady:Boolean;
      
      protected var mLogicalWorkComponent:LogicalWorkComponent;
      
      protected var mAssetLoadingComponent:AssetLoadingComponent;
      
      protected var mActorView:ActorView;
      
      protected var mChargeLoopClip:MovieClip;
      
      protected var mChargeLoopRenderer:MovieClipRenderController;
      
      public function ChargeEffectGameObject(facade:DBFacade, swfPath:String, className:String, actorView:ActorView)
      {
         super(facade,swfPath,className,1);
         mReady = false;
         mLogicalWorkComponent = new LogicalWorkComponent(facade,"ChargeEffectGameObject");
         mAssetLoadingComponent = new AssetLoadingComponent(facade);
         mActorView = actorView;
         view.root.visible = false;
         mActorView.root.addChildAt(view.root,0);
      }
      
      public function get ready() : Boolean
      {
         return mReady;
      }
      
      public function startCharge(duration:Number) : void
      {
         view.root.visible = true;
         view.movieClipRenderer.playRate = view.movieClipRenderer.clip.totalFrames / (duration * 24);
         TweenMax.to(view.root,duration,{"onComplete":function():void
         {
            view.root.filters = [mChargeGlow];
            mReady = true;
            playLoopingEffect();
         }});
         EffectView(view).play(true,null);
      }
      
      private function playLoopingEffect() : void
      {
         mAssetLoadingComponent.getSwfAsset(swfPath,function(param1:SwfAsset):void
         {
            var _loc2_:Class = param1.getClass("db_fx_chargeReadyLoop");
            if(!_loc2_)
            {
               return;
            }
            mChargeLoopClip = new _loc2_();
            if(mActorView.root.contains(view.root))
            {
               mActorView.root.removeChild(view.root);
            }
            mActorView.root.addChildAt(mChargeLoopClip,0);
            mChargeLoopRenderer = new MovieClipRenderController(mDBFacade,mChargeLoopClip);
            mChargeLoopRenderer.play();
         });
      }
      
      override public function destroy() : void
      {
         if(this.view)
         {
            TweenMax.killTweensOf(this.view.root);
         }
         if(mChargeLoopClip && mActorView.root.contains(mChargeLoopClip))
         {
            mActorView.root.removeChild(mChargeLoopClip);
         }
         mActorView = null;
         mChargeLoopClip = null;
         if(mAssetLoadingComponent)
         {
            mAssetLoadingComponent.destroy();
         }
         mAssetLoadingComponent = null;
         if(mChargeLoopRenderer)
         {
            mChargeLoopRenderer.destroy();
         }
         mChargeLoopRenderer = null;
         if(this.mLogicalWorkComponent)
         {
            mLogicalWorkComponent.destroy();
         }
         mLogicalWorkComponent = null;
         super.destroy();
      }
   }
}

