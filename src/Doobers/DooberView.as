package Doobers
{
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Render.MovieClipRenderController;
   import Brain.Sound.SoundAsset;
   import DistributedObjects.HeroGameObject;
   import Facade.DBFacade;
   import Floor.FloorView;
   import Sound.DBSoundComponent;
   import com.greensock.*;
   import com.greensock.easing.*;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.geom.Point;
   import flash.geom.Vector3D;
   import org.as3commons.collections.Map;
   
   public class DooberView extends FloorView
   {
      
      private static const LOOP_HEIGHT:int = 270;
      
      private static const LOOP_DURATION:Number = 0.9;
      
      private static const LOOP_DURATION_RAND:Number = 0.3;
      
      private static const LOOP1_TIME:int = 60;
      
      private static const LOOP2_TIME:int = 40;
      
      private static const LOOP1_HEIGHT:int = 75;
      
      private static const LOOP2_HEIGHT:int = 25;
      
      private static const TWEEN_TO_UI_TIME:Number = 0.5;
      
      private var mAssetLoadingComponent:AssetLoadingComponent;
      
      private var mDoober:MovieClip;
      
      private var mBody:Sprite;
      
      private var mDooberGameObject:DooberGameObject;
      
      private var mBounceTimeline:TimelineMax;
      
      private var mMoveToUITween:TweenMax;
      
      private var mEndPos:Vector3D;
      
      private var mSoundComponent:DBSoundComponent;
      
      private var mPickupSound:SoundAsset;
      
      private var mDooberRenderer:MovieClipRenderController;
      
      private var mDooberSwfAsset:SwfAsset;
      
      public function DooberView(facade:DBFacade, dooberGameObject:DooberGameObject)
      {
         super(facade,dooberGameObject);
         mDooberGameObject = dooberGameObject;
         mAssetLoadingComponent = new AssetLoadingComponent(mFacade);
         mSoundComponent = new DBSoundComponent(facade);
         mRoot.name = "DooberView_" + mDooberGameObject.id;
         mBody = new Sprite();
         mBody.name = "mBody";
         mRoot.addChild(mBody);
      }
      
      override public function init() : void
      {
         super.init();
         mBody.scaleX = mBody.scaleY = mDooberGameObject.mDooberData.ScaleVisual;
         mAssetLoadingComponent.getSwfAsset(mDooberGameObject.swfPath,assetLoaded);
         mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath("Resources/Audio/soundEffects.swf"),mDooberGameObject.mDooberData.PickupSound,soundLoaded);
         mRoot.mouseEnabled = false;
         mRoot.mouseChildren = false;
      }
      
      private function soundLoaded(soundAsset:SoundAsset) : void
      {
         mPickupSound = soundAsset;
      }
      
      private function assetLoaded(swfAsset:SwfAsset) : void
      {
         mDooberRenderer = mDBFacade.movieClipPool.checkout(mDBFacade,swfAsset,mDooberGameObject.className) as MovieClipRenderController;
         mDoober = mDooberRenderer.clip;
         if(mDoober.doober_shadow)
         {
            mDoober.doober_shadow.visible = true;
         }
         mBody.addChild(mDoober);
         mDooberRenderer.play(0,true);
         this.layer = mDooberGameObject.layer;
      }
      
      private function checkinDoober() : void
      {
         mDBFacade.movieClipPool.checkin(mDooberRenderer);
         mDooberRenderer = null;
         mDoober = null;
      }
      
      public function collectedEffect(isHeroOwner:Boolean, playerId:uint, animationComplete:Function) : void
      {
         var localPoint:Point;
         var globalPoint:Point;
         var dooberType:String;
         var dooberId:uint;
         var callback:Function = function():void
         {
            checkinDoober();
            animationComplete();
         };
         if(mBounceTimeline)
         {
            mBounceTimeline.kill();
            mBounceTimeline = null;
         }
         if(mPickupSound)
         {
            mSoundComponent.playSfxOneShot(mPickupSound,worldCenter,0,mDooberGameObject ? mDooberGameObject.mDooberData.PickupVolume : 1);
         }
         localPoint = new Point(0,0);
         globalPoint = mRoot.localToGlobal(localPoint);
         this.removeFromStage();
         mDooberGameObject.layer = 50;
         this.addToStage();
         mRoot.x = globalPoint.x;
         mRoot.y = globalPoint.y;
         mBody.x = mBody.y = 0;
         if(mDooberRenderer)
         {
            mDooberRenderer.stop();
            mDooberRenderer.setFrame(0);
         }
         if(mDoober && mDoober.doober_shadow)
         {
            mDoober.doober_shadow.visible = false;
         }
         dooberType = mDooberGameObject.mDooberData.DooberType;
         dooberId = mDooberGameObject.mDooberData.ChestId;
         if(mDooberGameObject.mDooberData.InstantReward != "1")
         {
            mMoveToUITween = moveToTeamUI(callback,dooberId);
         }
         else if(isHeroOwner)
         {
            mMoveToUITween = moveToUI(dooberType,callback);
         }
         else if(mDooberGameObject.mDooberData.SharedReward == "1" && checkPlayerOnScreen(playerId))
         {
            mMoveToUITween = moveToUI(dooberType,callback);
         }
         else
         {
            callback();
         }
      }
      
      public function animateDooberBounce(startPos:Vector3D, endPos:Vector3D) : void
      {
         if(mDoober == null)
         {
            return;
         }
         if(mDoober && mDoober.doober_shadow)
         {
            mDoober.doober_shadow.visible = false;
         }
         mEndPos = endPos;
         this.mRoot.x = startPos.x;
         this.mRoot.y = startPos.y;
         mBounceTimeline = new TimelineMax();
         var _loc6_:Number = 0.9 + Math.random() * 0.3;
         var _loc3_:Number = _loc6_ * 60 / (60 + 40);
         var _loc4_:Number = _loc6_ * 40 / (60 + 40);
         var _loc8_:Number = Vector3D.distance(startPos,endPos);
         var _loc11_:Number = Math.atan2(endPos.y - startPos.y,endPos.x - startPos.x);
         var _loc5_:Number = _loc8_ * 60 / (60 + 40);
         var _loc10_:Vector3D = new Vector3D(startPos.x + _loc5_ * Math.cos(_loc11_),startPos.y + _loc5_ * Math.sin(_loc11_));
         var _loc9_:Vector3D = new Vector3D((startPos.x + _loc10_.x) / 2,startPos.y - 270 * 75 / (75 + 25));
         var _loc7_:Vector3D = new Vector3D((_loc10_.x + endPos.x) / 2,_loc10_.y - 270 * 25 / (75 + 25));
         mBounceTimeline.addLabel("start",0);
         mBounceTimeline.addLabel("loop1",_loc3_ / 2);
         mBounceTimeline.addLabel("mid",_loc3_);
         mBounceTimeline.addLabel("loop2",_loc3_ + _loc4_ / 2);
         mBounceTimeline.addLabel("end",_loc3_ + _loc4_);
         var _loc12_:Number = _loc3_ + _loc4_;
         mBounceTimeline.append(new TweenMax(this.mRoot,_loc12_,{"x":endPos.x}));
         mBounceTimeline.insert(new TweenMax(this.mBody,_loc3_ / 2,{
            "y":_loc9_.y - startPos.y,
            "ease":Quad.easeOut
         }),"start");
         mBounceTimeline.insert(new TweenMax(this.mBody,_loc3_ / 2,{
            "y":_loc10_.y - startPos.y,
            "ease":Quad.easeIn
         }),"loop1");
         mBounceTimeline.insert(new TweenMax(this.mBody,_loc4_ / 2,{
            "y":_loc7_.y - startPos.y,
            "ease":Quad.easeOut
         }),"mid");
         mBounceTimeline.insert(new TweenMax(this.mBody,_loc4_ / 2,{
            "y":endPos.y - startPos.y,
            "ease":Quad.easeIn,
            "onComplete":timelineComplete
         }),"loop2");
         mBounceTimeline.play();
      }
      
      private function timelineComplete() : void
      {
         mRoot.x = mEndPos.x;
         mRoot.y = mEndPos.y;
         mBody.x = mBody.y = 0;
         if(mDooberRenderer)
         {
            mDooberRenderer.play(0,true);
         }
         if(mDoober && mDoober.doober_shadow)
         {
            mDoober.doober_shadow.visible = true;
         }
      }
      
      private function moveToUI(dooberType:String, animationComplete:Function) : TweenMax
      {
         var _loc3_:* = null;
         var _loc4_:Vector3D = null;
         switch(dooberType)
         {
            case "GOLD":
            case "COIN":
            case "TREASURE":
               _loc4_ = mDBFacade.hud.coinsDestination;
               break;
            case "EXP":
               _loc4_ = mDBFacade.hud.expDestination;
               break;
            case "CROWD":
            case "FAME":
               _loc4_ = mDBFacade.hud.crowdDestination;
               break;
            default:
               _loc4_ = mDBFacade.hud.profileDestination;
         }
         return TweenMax.to(this.mRoot,0.5,{
            "x":_loc4_.x,
            "y":_loc4_.y,
            "onComplete":animationComplete
         });
      }
      
      private function moveToTeamUI(animationComplete:Function, chestId:uint) : TweenMax
      {
         var _loc3_:Vector3D = new Vector3D();
         if(this.mDBFacade.hud)
         {
            _loc3_ = mDBFacade.hud.teamLootDestination;
            this.mDBFacade.hud.openTeamLoot(chestId);
         }
         if(chestId == 60001)
         {
            return TweenMax.to(this.mRoot,0.5,{
               "x":_loc3_.x,
               "y":_loc3_.y,
               "scaleX":0.8,
               "scaleY":0.8,
               "alpha":0.2,
               "onComplete":animationComplete
            });
         }
         if(chestId == 60004)
         {
            return TweenMax.to(this.mRoot,0.5,{
               "x":_loc3_.x,
               "y":_loc3_.y,
               "scaleX":0.5,
               "scaleY":0.5,
               "alpha":0.2,
               "onComplete":animationComplete
            });
         }
         return TweenMax.to(this.mRoot,0.5,{
            "x":_loc3_.x,
            "y":_loc3_.y,
            "scaleX":0.6,
            "scaleY":0.6,
            "alpha":0.2,
            "onComplete":animationComplete
         });
      }
      
      private function checkPlayerOnScreen(collectedPlayerId:uint) : Boolean
      {
         var _loc2_:Map = null;
         var _loc3_:HeroGameObject = null;
         if(mDooberGameObject && mDooberGameObject.distributedDungeonFloor && mDooberGameObject.distributedDungeonFloor.remoteHeroes.size > 0)
         {
            _loc2_ = mDooberGameObject.distributedDungeonFloor.remoteHeroes;
            _loc3_ = _loc2_.itemFor(collectedPlayerId) as HeroGameObject;
            if(_loc3_)
            {
               return mFacade.camera.isPointOnScreen(_loc3_.view.position);
            }
         }
         return false;
      }
      
      override public function destroy() : void
      {
         if(mDooberRenderer)
         {
            this.checkinDoober();
         }
         if(mBounceTimeline)
         {
            mBounceTimeline.kill();
            mBounceTimeline = null;
         }
         if(mMoveToUITween)
         {
            mMoveToUITween.kill();
            mMoveToUITween = null;
         }
         TweenMax.killTweensOf(this.mRoot);
         TweenMax.killTweensOf(this.mBody);
         mAssetLoadingComponent.destroy();
         mAssetLoadingComponent = null;
         mSoundComponent.destroy();
         mSoundComponent = null;
         mPickupSound = null;
         mDoober = null;
         mDooberRenderer = null;
         mBody = null;
         mDooberGameObject = null;
         super.destroy();
      }
   }
}

