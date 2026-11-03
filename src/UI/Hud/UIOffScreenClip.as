package UI.Hud
{
   import Actor.ActorGameObject;
   import Actor.ChatBalloon;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Clock.GameClock;
   import Brain.Event.EventComponent;
   import Brain.UI.UIProgressBar;
   import Brain.Utils.TextUtil;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Brain.WorkLoop.Task;
   import DistributedObjects.HeroGameObject;
   import Events.ChatEvent;
   import Events.GameObjectEvent;
   import Events.HpEvent;
   import Events.PlayerIsTypingEvent;
   import Facade.DBFacade;
   import Facade.Locale;
   import flash.display.MovieClip;
   import flash.filters.ColorMatrixFilter;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   
   public class UIOffScreenClip
   {
      
      public static const HPBAR_OFFSET:Number = 25;
      
      public static const CHAT_DURATION:Number = 5;
      
      public static const CHAT_BALLOON_Y_OFFSET:Number = -40;
      
      public static const REVIVE_PIC_CHANGE_TYPE:String = "REVIVE";
      
      public static const REVIVE_PIC_TOGGLE_TIME:Number = 0.25;
      
      public static const MAX_STEAM_AVATAR_SHOW_COUNT:uint = 5;
      
      private static const DEATH_ICON_SWF_PATH:String = "Resources/Art2D/Icons/Avatars/db_icon_death.swf";
      
      private static const TEXT_GUTTER:Number = 4;
      
      protected var mOffScreenPlayerClip:MovieClip;
      
      protected var mAvatarPic:MovieClip;
      
      protected var mDeathPic:MovieClip;
      
      protected var mPlayerIsTypingNotification:MovieClip;
      
      protected var mHpBar:UIProgressBar;
      
      protected var mChatBalloon:ChatBalloon;
      
      protected var mPlayer:ActorGameObject;
      
      private var mNametagSwfAsset:SwfAsset;
      
      private var mAvatarSwfAsset:SwfAsset;
      
      private var mDBFacade:DBFacade;
      
      private var mEventComponent:EventComponent;
      
      private var mLogicalWorkComponent:LogicalWorkComponent;
      
      private var mAssetLoadingComponent:AssetLoadingComponent;
      
      private var mChatBalloonVanishTask:Task;
      
      private var mFlashTask:Task;
      
      private var mSteamAvatarShowCount:uint = 0;
      
      private var mIsAHero:Boolean = false;
      
      private var mNameX:Number;
      
      private var mAlertX:Number;
      
      public function UIOffScreenClip(dbFacade:DBFacade, clip:MovieClip, player:ActorGameObject, nametagAsset:SwfAsset)
      {
         var _loc6_:String = null;
         var _loc5_:HeroGameObject = null;
         super();
         mDBFacade = dbFacade;
         mOffScreenPlayerClip = clip;
         mPlayer = player;
         mNameX = clip.NametagText.x;
         mAlertX = clip.AlertText.x;
         if(mPlayer is HeroGameObject)
         {
            mIsAHero = true;
            _loc5_ = mPlayer as HeroGameObject;
            _loc6_ = _loc5_.gmSkin.IconSwfFilepath;
         }
         else
         {
            _loc6_ = mPlayer.actorData.gMActor.IconSwfFilepath;
         }
         mNametagSwfAsset = nametagAsset;
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"UIOffScreenClip");
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mEventComponent = new EventComponent(mDBFacade);
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(_loc6_),setupAvatarPic);
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Icons/Avatars/db_icon_death.swf"),setupDeathPic);
         setupUI();
      }
      
      private function setupUI() : void
      {
         var balloonClass:Class;
         var balloon:MovieClip;
         var hero:HeroGameObject;
         var chatIsTypingClass:Class;
         var nametagClass:Class = mNametagSwfAsset.getClass("UI_nametag");
         var nametag:MovieClip = new nametagClass();
         mHpBar = new UIProgressBar(mDBFacade,nametag.hp.hpBar);
         mHpBar.value = 100;
         mEventComponent.addListener(GameObjectEvent.uniqueEvent("HpEvent_HP_UPDATE",mPlayer.id),function(param1:HpEvent):void
         {
            if(!mPlayer.isDestroyed)
            {
               setHp(param1.hp,param1.maxHp);
            }
         });
         mOffScreenPlayerClip.addChild(mHpBar.root);
         mHpBar.root.y = 25;
         balloonClass = mNametagSwfAsset.getClass("UI_speechbubble");
         mChatBalloon = new ChatBalloon();
         mChatBalloon.visible = false;
         balloon = new balloonClass();
         mChatBalloon.initializeChatBalloon(mNametagSwfAsset,null,1.82);
         mChatBalloon.y = -40;
         mOffScreenPlayerClip.addChild(mChatBalloon);
         if(mIsAHero)
         {
            hero = mPlayer as HeroGameObject;
            mEventComponent.addListener(GameObjectEvent.uniqueEvent("ChatEvent_INCOMING_CHAT_UPDATE",hero.playerID),function(param1:ChatEvent):void
            {
               if(hero && !hero.isDestroyed)
               {
                  setChat(param1.message);
               }
            });
            chatIsTypingClass = mNametagSwfAsset.getClass("UI_speechbubble_typing");
            mPlayerIsTypingNotification = new chatIsTypingClass();
            mPlayerIsTypingNotification.y = -40;
            mOffScreenPlayerClip.addChild(mPlayerIsTypingNotification);
            showPlayerIsTypingNotification(false);
            mEventComponent.addListener(GameObjectEvent.uniqueEvent("PLAYER_IS_TYPING",hero.playerID),function(param1:PlayerIsTypingEvent):void
            {
               if(param1.subtype == "CHAT_BOX_FOCUS_IN")
               {
                  showPlayerIsTypingNotification(true);
               }
               else
               {
                  showPlayerIsTypingNotification(false);
               }
            });
            showSteamAvatar();
         }
      }
      
      private function setupAvatarPic(avatarsSwfAsset:SwfAsset) : void
      {
         var _loc2_:String = null;
         var _loc4_:HeroGameObject = null;
         if(mPlayer is HeroGameObject)
         {
            _loc4_ = mPlayer as HeroGameObject;
            _loc2_ = _loc4_.gmSkin.IconName;
         }
         else
         {
            _loc2_ = mPlayer.actorData.gMActor.IconName;
         }
         mAvatarSwfAsset = avatarsSwfAsset;
         var _loc3_:String = _loc2_;
         if(!_loc3_ || _loc3_ == "")
         {
            return;
         }
         var _loc5_:Class = mAvatarSwfAsset.getClass(_loc3_);
         mAvatarPic = new _loc5_();
         mOffScreenPlayerClip.UI_avatar.addChild(mAvatarPic);
      }
      
      private function setupDeathPic(iconsSwfAsset:SwfAsset) : void
      {
         var _loc2_:Class = iconsSwfAsset.getClass("death_icon");
         if(_loc2_)
         {
            mDeathPic = new _loc2_();
         }
      }
      
      public function showSteamAvatar() : void
      {
         var _loc1_:HeroGameObject = null;
         if(mIsAHero)
         {
            _loc1_ = mPlayer as HeroGameObject;
            if(mSteamAvatarShowCount >= 5 || !_loc1_ || _loc1_.isDestroyed)
            {
               return;
            }
            mSteamAvatarShowCount = mSteamAvatarShowCount + 1;
            _loc1_.heroView.nametag.showSteamAvatar(_loc1_.playerID);
         }
      }
      
      public function get clip() : MovieClip
      {
         return mOffScreenPlayerClip;
      }
      
      public function showPlayerIsTypingNotification(value:Boolean) : void
      {
         if(mPlayerIsTypingNotification && !mChatBalloon.visible)
         {
            mPlayerIsTypingNotification.visible = value;
         }
      }
      
      public function setHp(current:uint, max:uint) : void
      {
         if(mHpBar)
         {
            mHpBar.value = current / max;
         }
      }
      
      public function setChat(message:String) : void
      {
         if(!mChatBalloon)
         {
            return;
         }
         mChatBalloon.text = message;
         mChatBalloon.visible = true;
         if(mChatBalloonVanishTask)
         {
            mChatBalloonVanishTask.destroy();
         }
         mChatBalloonVanishTask = mLogicalWorkComponent.doLater(5,function():void
         {
            mChatBalloon.visible = false;
         });
      }
      
      public function keepChatOnScreen(viewWidth:Number, viewHeight:Number) : void
      {
         if(!mChatBalloon || !mChatBalloon.visible || !mOffScreenPlayerClip.parent)
         {
            return;
         }
         mChatBalloon.x = 0;
         mChatBalloon.y = -40;
         var _loc5_:Rectangle = mChatBalloon.getBounds(mOffScreenPlayerClip.parent);
         var _loc3_:Number = 0;
         var _loc4_:Number = 0;
         if(_loc5_.left < 0)
         {
            _loc3_ = -_loc5_.left;
         }
         else if(_loc5_.right > viewWidth)
         {
            _loc3_ = viewWidth - _loc5_.right;
         }
         if(_loc5_.top < 0)
         {
            _loc4_ = -_loc5_.top;
         }
         else if(_loc5_.bottom > viewHeight)
         {
            _loc4_ = viewHeight - _loc5_.bottom;
         }
         mChatBalloon.x += _loc3_ / mOffScreenPlayerClip.scaleX;
         mChatBalloon.y += _loc4_ / mOffScreenPlayerClip.scaleY;
      }
      
      public function keepTextOnScreen(viewWidth:Number) : void
      {
         if(!mOffScreenPlayerClip.parent)
         {
            return;
         }
         keepFieldOnScreen(mOffScreenPlayerClip.NametagText,mNameX,viewWidth);
         keepFieldOnScreen(mOffScreenPlayerClip.AlertText,mAlertX,viewWidth);
      }
      
      private function keepFieldOnScreen(field:TextField, authoredX:Number, viewWidth:Number) : void
      {
         field.x = authoredX;
         var _loc7_:Rectangle = field.getBounds(mOffScreenPlayerClip.parent);
         var _loc4_:Number = Math.min(_loc7_.width,(field.textWidth + 4) * mOffScreenPlayerClip.scaleX) / 2;
         var _loc6_:Number = _loc7_.x + _loc7_.width / 2 - _loc4_;
         var _loc8_:Number = _loc6_ + _loc4_ * 2;
         var _loc5_:Number = 0;
         if(_loc6_ < 0)
         {
            _loc5_ = -_loc6_;
         }
         else if(_loc8_ > viewWidth)
         {
            _loc5_ = viewWidth - _loc8_;
         }
         field.x += _loc5_ / mOffScreenPlayerClip.scaleX;
      }
      
      public function handlePicChange(picType:String) : void
      {
         var cmf:ColorMatrixFilter;
         if(picType == "REVIVE")
         {
            Locale.setText(mOffScreenPlayerClip.AlertText,"NAMETAG_RESCUE",null,1.36);
            TextUtil.fitToField(mOffScreenPlayerClip.AlertText,1.27);
            if(mDeathPic && mAvatarPic)
            {
               mOffScreenPlayerClip.UI_avatar.addChild(mDeathPic);
               cmf = new ColorMatrixFilter([2.5,0,0,0,0,0,0.25,0,0,0,0,0,0.25,0,0,0,0,0,1,0]);
               mAvatarPic.filters = [cmf];
               mFlashTask = mLogicalWorkComponent.doEverySeconds(0.25,function(param1:GameClock):void
               {
                  mOffScreenPlayerClip.UI_avatar.swapChildren(mAvatarPic,mDeathPic);
               });
            }
         }
         else
         {
            mOffScreenPlayerClip.AlertText.text = "";
            if(mFlashTask)
            {
               mFlashTask.destroy();
            }
            mFlashTask = null;
            mAvatarPic.filters = [];
            if(mDeathPic && mOffScreenPlayerClip.UI_avatar.contains(mDeathPic))
            {
               mOffScreenPlayerClip.UI_avatar.removeChild(mDeathPic);
            }
         }
      }
      
      public function destroy() : void
      {
         if(mChatBalloonVanishTask)
         {
            mChatBalloonVanishTask.destroy();
         }
         mChatBalloonVanishTask = null;
         if(mFlashTask)
         {
            mFlashTask.destroy();
         }
         mFlashTask = null;
         mChatBalloon = null;
         if(mHpBar)
         {
            mHpBar.destroy();
         }
         mHpBar = null;
         if(mLogicalWorkComponent)
         {
            mLogicalWorkComponent.destroy();
         }
         mLogicalWorkComponent = null;
         if(mAssetLoadingComponent)
         {
            mAssetLoadingComponent.destroy();
         }
         mAssetLoadingComponent = null;
         mEventComponent.removeAllListeners();
         if(mEventComponent)
         {
            mEventComponent.destroy();
         }
         mEventComponent = null;
         mPlayerIsTypingNotification = null;
         mAvatarPic = null;
         mDeathPic = null;
         mPlayer = null;
         mAvatarSwfAsset = null;
         mNametagSwfAsset = null;
         mOffScreenPlayerClip = null;
         mDBFacade = null;
      }
   }
}

