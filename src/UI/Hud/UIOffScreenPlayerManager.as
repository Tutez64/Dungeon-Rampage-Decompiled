package UI.Hud
{
   import Account.PlayerSpecialStatus;
   import Actor.ActorGameObject;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Clock.GameClock;
   import Brain.Event.EventComponent;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Brain.WorkLoop.Task;
   import DistributedObjects.HeroGameObject;
   import DistributedObjects.HeroGameObjectOwner;
   import Events.ActorLifetimeEvent;
   import Facade.DBFacade;
   import flash.display.MovieClip;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import org.as3commons.collections.Map;
   import org.as3commons.collections.framework.IMapIterator;
   
   public class UIOffScreenPlayerManager
   {
      
      private static const EFFECT_RECT_X_OFFSET:Number = 50;
      
      private static const EFFECT_RECT_Y_OFFSET:Number = 100;
      
      private static const EFFECT_RECT_WIDTH_OFFSET:Number = 60;
      
      private static const EFFECT_RECT_HEIGHT_OFFSET:Number = 125;
      
      private static const OFFSCREEN_UI_SCALE:Number = 1.44;
      
      private var mDBFacade:DBFacade;
      
      private var mAssetLoadingComponent:AssetLoadingComponent;
      
      private var mLogicalWorkComponent:LogicalWorkComponent;
      
      private var mEventComponent:EventComponent;
      
      protected var mOffScreenPlayerMap:Map;
      
      private var mSpecialActorsMap:Map;
      
      protected var mUIRoot:MovieClip;
      
      protected var mHeroOwner:HeroGameObjectOwner;
      
      protected var mEffectRect:Rectangle;
      
      private var mPreviousFrameState:String;
      
      private var mNametagSwfAsset:SwfAsset;
      
      private var mUpdateTask:Task;
      
      public function UIOffScreenPlayerManager(facade:DBFacade, UIRoot:MovieClip, heroOwner:HeroGameObjectOwner)
      {
         var effectRectWidth:Number;
         var effectRectHeight:Number;
         super();
         mDBFacade = facade;
         mUIRoot = UIRoot;
         mHeroOwner = heroOwner;
         effectRectWidth = mDBFacade.viewWidth - 50 - 60;
         effectRectHeight = mDBFacade.viewHeight - 100 - 125;
         mEffectRect = new Rectangle(50,100,effectRectWidth,effectRectHeight);
         mOffScreenPlayerMap = new Map();
         mSpecialActorsMap = new Map();
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"UIOffScreenPlayerManager");
         mEventComponent = new EventComponent(mDBFacade);
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_nametag.swf"),function(param1:SwfAsset):void
         {
            mNametagSwfAsset = param1;
            mUpdateTask = mLogicalWorkComponent.doEveryFrame(update);
         });
         mEventComponent.addListener("ACTOR_CREATED",storeNewSpecialActor);
         mEventComponent.addListener("ACTOR_DESTROYED",removeSpecialActor);
      }
      
      public function destroy() : void
      {
         if(mUpdateTask)
         {
            mUpdateTask.destroy();
         }
         mUpdateTask = null;
         var _loc1_:Array = mOffScreenPlayerMap.keysToArray();
         for each(var _loc2_:uint in _loc1_)
         {
            removeClip(_loc2_);
         }
         mOffScreenPlayerMap.clear();
         mOffScreenPlayerMap = null;
         mSpecialActorsMap.clear();
         mSpecialActorsMap = null;
         mDBFacade = null;
         mUIRoot = null;
         mHeroOwner = null;
         mNametagSwfAsset = null;
         if(mAssetLoadingComponent)
         {
            mAssetLoadingComponent.destroy();
         }
         mAssetLoadingComponent = null;
         if(mLogicalWorkComponent)
         {
            mLogicalWorkComponent.destroy();
         }
         mLogicalWorkComponent = null;
         if(mEventComponent)
         {
            mEventComponent.destroy();
         }
         mEventComponent = null;
      }
      
      private function storeNewSpecialActor(event:ActorLifetimeEvent) : void
      {
         var _loc2_:ActorGameObject = null;
         if(mHeroOwner && mHeroOwner.distributedDungeonFloor)
         {
            _loc2_ = mHeroOwner.distributedDungeonFloor.getActor(event.actorId);
            if(_loc2_ && _loc2_.actorData.gMActor.HasOffscreenIndicator)
            {
               mSpecialActorsMap.add(event.actorId,_loc2_);
            }
         }
      }
      
      private function removeSpecialActor(event:ActorLifetimeEvent) : void
      {
         mSpecialActorsMap.remove(event.actorId);
      }
      
      public function update(gameClock:GameClock) : void
      {
         var _loc4_:Map = null;
         var _loc5_:Array = null;
         var _loc2_:IMapIterator = null;
         var _loc7_:HeroGameObject = null;
         var _loc3_:ActorGameObject = null;
         if(mHeroOwner && mHeroOwner.distributedDungeonFloor)
         {
            _loc4_ = mHeroOwner.distributedDungeonFloor.remoteHeroes;
            _loc5_ = mOffScreenPlayerMap.keysToArray();
            for each(var _loc6_:Number in _loc5_)
            {
               if(!_loc4_.hasKey(_loc6_) && !mSpecialActorsMap.hasKey(_loc6_))
               {
                  removeClip(_loc6_);
               }
            }
            _loc2_ = _loc4_.iterator() as IMapIterator;
            while(_loc2_.hasNext())
            {
               _loc7_ = _loc2_.next();
               updatePosition(_loc7_);
            }
            _loc2_ = mSpecialActorsMap.iterator() as IMapIterator;
            while(_loc2_.hasNext())
            {
               _loc3_ = _loc2_.next();
               if(_loc3_)
               {
                  updatePosition(_loc3_);
               }
            }
         }
      }
      
      private function updatePosition(player:ActorGameObject) : void
      {
         var _loc5_:Class = null;
         var _loc3_:MovieClip = null;
         var _loc12_:Number = NaN;
         var _loc6_:UIOffScreenClip = null;
         var _loc7_:UIOffScreenClip = null;
         var _loc14_:Number = NaN;
         if(!player || !player.view)
         {
            return;
         }
         var _loc4_:Number = mDBFacade.viewWidth / mDBFacade.camera.zoom;
         var _loc13_:Number = mDBFacade.viewHeight / mDBFacade.camera.zoom;
         var _loc10_:Vector3D = mHeroOwner.view.position;
         var _loc11_:Vector3D = player.view.worldCenter;
         var _loc2_:Rectangle = mDBFacade.camera.visibleRectangle;
         var _loc8_:Vector3D = new Vector3D(_loc10_.x - _loc11_.x,_loc10_.y - _loc11_.y,_loc10_.z - _loc11_.z);
         var _loc9_:Vector3D = new Vector3D(-1,0,0);
         if(!mOffScreenPlayerMap.hasKey(player.id))
         {
            _loc5_ = mNametagSwfAsset.getClass("UI_widget");
            _loc3_ = new _loc5_();
            _loc8_ = normalize(_loc8_);
            _loc12_ = Math.acos(_loc8_.dotProduct(_loc9_));
            _loc12_ = _loc12_ * 180 / 3.141592653589793;
            if(_loc11_.y > _loc10_.y)
            {
               _loc3_.UI_arrow.rotation = _loc12_ + 180;
            }
            else
            {
               _loc3_.UI_arrow.rotation = 180 - _loc12_;
            }
            _loc3_.x = calculateEffectXPosition(_loc12_);
            _loc3_.y = calculateEffectYPosition(_loc12_,_loc10_.y,_loc11_.y);
            mUIRoot.addChild(_loc3_);
            _loc3_.NametagText.text = player.screenName;
            _loc3_.NametagText.textColor = PlayerSpecialStatus.getSpecialTextColor(player.screenName,_loc3_.NametagText.textColor);
            _loc3_.AlertText.text = "";
            _loc3_.scaleX = _loc3_.scaleY = 1.44;
            _loc3_.visible = false;
            _loc6_ = new UIOffScreenClip(mDBFacade,_loc3_,player,mNametagSwfAsset);
            mOffScreenPlayerMap.add(player.id,_loc6_);
            _loc6_.setHp(player.hitPoints,player.maxHitPoints);
         }
         else
         {
            _loc7_ = mOffScreenPlayerMap.itemFor(player.id);
            if(_loc7_ && _loc7_.clip)
            {
               if(!_loc2_.contains(_loc11_.x,_loc11_.y))
               {
                  if(_loc7_.clip.visible == false)
                  {
                     _loc7_.clip.visible = true;
                  }
                  _loc8_ = normalize(_loc8_);
                  _loc14_ = Math.acos(_loc8_.dotProduct(_loc9_));
                  _loc14_ = _loc14_ * 180 / 3.141592653589793;
                  if(_loc11_.y > _loc10_.y)
                  {
                     _loc7_.clip.UI_arrow.rotation = _loc14_ + 180;
                  }
                  else
                  {
                     _loc7_.clip.UI_arrow.rotation = 180 - _loc14_;
                  }
                  _loc7_.clip.x = calculateEffectXPosition(_loc14_);
                  _loc7_.clip.y = calculateEffectYPosition(_loc14_,_loc10_.y,_loc11_.y);
               }
               else if(_loc7_.clip.visible == true)
               {
                  _loc7_.clip.visible = false;
                  _loc7_.showFacebookPicture();
               }
            }
         }
      }
      
      private function removeClip(id:Number) : void
      {
         var _loc2_:UIOffScreenClip = mOffScreenPlayerMap.itemFor(id);
         if(_loc2_)
         {
            if(mUIRoot.contains(_loc2_.clip))
            {
               mUIRoot.removeChild(_loc2_.clip);
            }
            _loc2_.destroy();
         }
         mOffScreenPlayerMap.removeKey(id);
      }
      
      private function calculateEffectXPosition(angle:Number) : Number
      {
         if(angle <= 45)
         {
            return mEffectRect.right;
         }
         if(angle >= 135)
         {
            return mEffectRect.left;
         }
         return mEffectRect.right - mEffectRect.width / 90 * (angle - 45);
      }
      
      private function calculateEffectYPosition(angle:Number, heroYPos:Number, remoteYPos:Number) : Number
      {
         if(remoteYPos > heroYPos)
         {
            if(angle > 45 && angle < 135)
            {
               return mEffectRect.bottom;
            }
            if(angle <= 45)
            {
               return mEffectRect.top + mEffectRect.height / 2 + mEffectRect.height / 90 * angle;
            }
            return mEffectRect.bottom - mEffectRect.height / 90 * (angle - 135);
         }
         if(angle > 45 && angle < 135)
         {
            return mEffectRect.top;
         }
         if(angle <= 45)
         {
            return mEffectRect.top + mEffectRect.height / 2 - mEffectRect.height / 90 * angle;
         }
         return mEffectRect.top + mEffectRect.height / 90 * (angle - 135);
      }
      
      private function normalize(vec:Vector3D) : Vector3D
      {
         var _loc2_:Number = vec.length;
         vec.x /= _loc2_;
         vec.y /= _loc2_;
         vec.z /= _loc2_;
         return vec;
      }
      
      public function handlePicChange(playerID:int, picType:String) : void
      {
         var _loc3_:UIOffScreenClip = null;
         if(mOffScreenPlayerMap.hasKey(playerID))
         {
            _loc3_ = mOffScreenPlayerMap.itemFor(playerID);
            if(!_loc3_)
            {
               return;
            }
            _loc3_.handlePicChange(picType);
         }
      }
   }
}

