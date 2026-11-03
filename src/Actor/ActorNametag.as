package Actor
{
   import Account.PlayerSpecialStatus;
   import Actor.StarlingConvertedOverlay.StarlingNametag;
   import Actor.StarlingConvertedOverlay.StarlingOverlays;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Clock.GameClock;
   import Brain.Event.EventComponent;
   import Brain.Event.EventListeners;
   import Brain.GameObject.GameObject;
   import Brain.Render.Tweens.TweenHandle;
   import Brain.UI.UIProgressBar;
   import Brain.Utils.TextUtil;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Brain.WorkLoop.Task;
   import DistributedObjects.PlayerGameObject;
   import Events.GameObjectEvent;
   import Events.SteamAvatarUrlReceivedEvent;
   import Facade.DBFacade;
   import Facade.Locale;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.net.URLRequest;
   import flash.system.LoaderContext;
   import flash.text.TextField;
   
   public class ActorNametag extends Sprite
   {
      
      public static const NAMETAG_SWF_ROOT:String = "Resources/Art2D/UI/db_UI_nametag.swf";
      
      private static const STEAM_AVATAR_VISIBLE_TIME:Number = 5;
      
      private static const STEAM_AVATAR_ANIMATE_UP_FRAMES:Number = 0.25;
      
      private static const STEAM_AVATAR_ANIMATE_DOWN_FRAMES:Number = 0.25;
      
      private static const AFK_TEXT_GAP:Number = 2;
      
      private static const AFK_TEXT_SIZE_MODIFIER:Number = 1.45;
      
      private static const TYPING_TEXT_SIZE:Number = 16;
      
      private static const TYPING_FLOOR_SCALE:Number = 0.7;
      
      protected var mLogicalWorkComponent:LogicalWorkComponent;
      
      protected var mEventComponent:EventComponent;
      
      protected var mShowNametagTask:Task;
      
      protected var mHpProgressBar:UIProgressBar;
      
      protected var mHpBarBg:Sprite;
      
      protected var mHpProgressBarVisible:Boolean = true;
      
      protected var mTextField:TextField;
      
      protected var mTextFieldBottom:Number;
      
      protected var mAFKText:TextField;
      
      protected var mAFKTextBottom:Number;
      
      protected var mScreenName:String = Locale.getString("DEFAULT_NAMETAG");
      
      protected var mHealth:Number = 1;
      
      protected var mDBFacade:DBFacade;
      
      protected var mNametagTop:Sprite;
      
      protected var mNametagTopStartingYPosition:Number;
      
      protected var mChatBalloon:ChatBalloon;
      
      protected var mPlayerIsTypingNotification:MovieClip;
      
      private var mTypingTopY:Number = 0;
      
      protected var mChatDuration:Number = 5;
      
      protected var mAFK:Boolean = false;
      
      protected var mNametagFBPicSlot:MovieClip;
      
      protected var mSteamAvatar:DisplayObject;
      
      protected var mHpBarHolder:MovieClip;
      
      protected var mStarlingNametag:StarlingNametag;
      
      private var mWantVisible:Boolean = true;
      
      public function ActorNametag(dbfacade:DBFacade, assetLoader:AssetLoadingComponent, workComponent:LogicalWorkComponent, nametagY:Number)
      {
         super();
         mDBFacade = dbfacade;
         mLogicalWorkComponent = workComponent;
         mEventComponent = new EventComponent(mDBFacade);
         this.name = "ActorNametag";
         this.mouseChildren = false;
         this.mouseEnabled = false;
         mNametagTop = new Sprite();
         mNametagTop.name = "ActorNametag.mNametagTop";
         this.addChild(mNametagTop);
         this.y = -nametagY;
         this.x = 0;
         showNametag();
         mChatBalloon = new ChatBalloon();
         mChatBalloon.visible = false;
         this.addChild(mChatBalloon);
         ChatBalloonOverlay.register(mChatBalloon);
         mEventComponent.addListener("UI_HIDE_TOGGLE_CHANGED",applyVisible);
         applyVisible();
         assetLoader.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_nametag.swf"),setupNametagFromSwf);
      }
      
      override public function set visible(value:Boolean) : void
      {
         mWantVisible = value;
         applyVisible();
      }
      
      override public function get visible() : Boolean
      {
         return mWantVisible;
      }
      
      public function get shownOnScreen() : Boolean
      {
         return super.visible;
      }
      
      private function applyVisible(event:Event = null) : void
      {
         var _loc2_:Boolean = mDBFacade != null && mDBFacade.uiHideToggle != null && mDBFacade.uiHideToggle.hidden;
         super.visible = mWantVisible && !_loc2_;
      }
      
      private function setupNametagFromSwf(swfAsset:SwfAsset) : void
      {
         var _loc3_:Class = swfAsset.getClass("UI_nametag");
         var _loc5_:MovieClip = new _loc3_();
         mNametagFBPicSlot = _loc5_.avatar;
         mNametagFBPicSlot.visible = false;
         mHpBarHolder = _loc5_.hp;
         mHpProgressBar = new UIProgressBar(mDBFacade,_loc5_.hp.hpBar);
         mHpProgressBar.value = mHealth;
         mHpProgressBar.visible = mHpProgressBarVisible;
         mTextField = _loc5_.nameText;
         mTextFieldBottom = mTextField.y + mTextField.height;
         if(TextUtil.enabled)
         {
            mTextField.autoSize = "center";
         }
         updateNameTagText();
         mAFKText = _loc5_.AFKText;
         mAFKTextBottom = mAFKText.y + mAFKText.height;
         if(TextUtil.enabled)
         {
            mAFKText.autoSize = "center";
         }
         mAFKText.text = "";
         mHpBarBg = _loc5_.hp.hpBarBg;
         mNametagTop.addChild(_loc5_);
         mNametagTopStartingYPosition = mNametagTop.y;
         var _loc4_:Class = swfAsset.getClass("UI_speechbubble");
         var _loc2_:MovieClip = new _loc4_();
         mChatBalloon.initializeChatBalloon(swfAsset,null,chatSizeModifier);
         var _loc6_:Class = swfAsset.getClass("UI_speechbubble_typing");
         mPlayerIsTypingNotification = new _loc6_();
         this.addChild(mPlayerIsTypingNotification);
         mPlayerIsTypingNotification.visible = false;
         mPlayerIsTypingNotification.stop();
         mTypingTopY = mPlayerIsTypingNotification.getBounds(mPlayerIsTypingNotification).top;
         if(StarlingOverlays.wanted(mDBFacade))
         {
            mStarlingNametag = StarlingOverlays.get(mDBFacade).addTag(this,mNametagTop,_loc5_,mTextField,mAFKText,mHpBarHolder,mHpProgressBar.bar);
         }
      }
      
      public function setChat(message:String) : void
      {
         if(mChatBalloon)
         {
            mChatBalloon.sizeModifier = chatSizeModifier;
            mChatBalloon.text = message;
         }
         showChat();
         if(mShowNametagTask)
         {
            mShowNametagTask.destroy();
         }
         mShowNametagTask = mLogicalWorkComponent.doLater(mChatDuration,showNametag);
      }
      
      public function get chatBalloon() : ChatBalloon
      {
         return mChatBalloon;
      }
      
      private function get chatSizeModifier() : Number
      {
         return Math.max(1.82,Locale.nametagSizeModifier);
      }
      
      public function setHp(hp:uint, maxHp:uint) : void
      {
         mHealth = hp / maxHp;
         if(mHpProgressBar)
         {
            mHpProgressBar.value = mHealth;
         }
      }
      
      public function set hpBarVisible(value:Boolean) : void
      {
         mHpProgressBarVisible = value;
         if(mHpProgressBar)
         {
            mHpProgressBar.visible = mHpProgressBarVisible;
         }
         if(mHpBarBg)
         {
            mHpBarBg.visible = mHpProgressBarVisible;
         }
      }
      
      public function get hpBar() : MovieClip
      {
         return mHpBarHolder;
      }
      
      public function get hpBarVisible() : Boolean
      {
         return mHpProgressBarVisible;
      }
      
      public function set screenName(value:String) : void
      {
         mScreenName = value;
         updateNameTagText();
      }
      
      private function updateNameTagText() : void
      {
         if(mTextField)
         {
            TextUtil.setText(mTextField,mScreenName,Locale.nametagSizeModifier);
            TextUtil.addOverhangSlack(mTextField);
            mTextField.y = mTextFieldBottom - mTextField.height;
            mTextField.textColor = PlayerSpecialStatus.getSpecialTextColor(mScreenName,mTextField.textColor);
            layoutAFKText();
         }
         if(mStarlingNametag)
         {
            mStarlingNametag.contentChanged();
         }
      }
      
      private function layoutAFKText() : void
      {
         if(mAFKText == null)
         {
            return;
         }
         var _loc1_:Number = mAFKTextBottom;
         if(mTextField != null && mTextField.text != "")
         {
            _loc1_ = Math.min(_loc1_,mTextField.y - 2);
         }
         mAFKText.y = _loc1_ - mAFKText.height;
      }
      
      protected function showChat(gameClock:GameClock = null) : void
      {
         if(mChatBalloon)
         {
            mChatBalloon.visible = true;
         }
         mNametagTop.visible = false;
      }
      
      protected function showNametag(gameClock:GameClock = null) : void
      {
         if(mChatBalloon)
         {
            mChatBalloon.visible = false;
         }
         mNametagTop.visible = true;
      }
      
      public function showPlayerIsTypingNotification(value:Boolean) : void
      {
         if(mPlayerIsTypingNotification && !mChatBalloon.visible)
         {
            mPlayerIsTypingNotification.visible = value;
            if(value)
            {
               scaleTypingToFloor();
               mPlayerIsTypingNotification.play();
            }
            else
            {
               mPlayerIsTypingNotification.stop();
            }
         }
      }
      
      private function scaleTypingToFloor() : void
      {
         var _loc1_:Number = TextUtil.scaleToFloor(16,Locale.nametagSizeModifier * 0.7);
         mPlayerIsTypingNotification.scaleX = mPlayerIsTypingNotification.scaleY = _loc1_;
         mPlayerIsTypingNotification.y = mTypingTopY * (1 - _loc1_);
      }
      
      public function destroy() : void
      {
         if(mStarlingNametag)
         {
            mStarlingNametag.destroy();
         }
         mStarlingNametag = null;
         if(mShowNametagTask)
         {
            mShowNametagTask.destroy();
         }
         if(mHpProgressBar)
         {
            mHpProgressBar.destroy();
         }
         if(mEventComponent)
         {
            mEventComponent.destroy();
         }
         mEventComponent = null;
         mHpBarHolder = null;
         if(mChatBalloon != null)
         {
            ChatBalloonOverlay.unregister(mChatBalloon);
         }
         mChatBalloon = null;
         mSteamAvatar = null;
         mNametagFBPicSlot = null;
         if(mPlayerIsTypingNotification)
         {
            mPlayerIsTypingNotification.stop();
         }
         mPlayerIsTypingNotification = null;
         mLogicalWorkComponent = null;
         if(this.parent)
         {
            this.parent.removeChild(this);
         }
         mDBFacade = null;
      }
      
      public function showSteamAvatar(playerId:uint) : void
      {
         var go:GameObject;
         var player:PlayerGameObject;
         if(!mSteamAvatar)
         {
            go = mDBFacade.gameObjectManager.getReferenceFromId(playerId);
            player = go as PlayerGameObject;
            if(player)
            {
               if(player.steamAvatarUrl && player.steamAvatarUrl != "")
               {
                  saveSteamAvatar(player.steamAvatarUrl);
               }
               else
               {
                  mEventComponent.addListener(GameObjectEvent.uniqueEvent("STEAM_AVATAR_URL_RECEIVED_EVENT",player.id),function(param1:SteamAvatarUrlReceivedEvent):void
                  {
                     saveSteamAvatar(param1.steamAvatarUrl);
                  });
               }
            }
         }
         else if(mNametagFBPicSlot && !mNametagFBPicSlot.visible)
         {
            startSteamAvatarPicLerp();
         }
      }
      
      private function saveSteamAvatar(steamAvatarUrl:String) : void
      {
         var lc:LoaderContext;
         var loader:Loader = new Loader();
         var picUrl:String = steamAvatarUrl;
         var url:URLRequest = new URLRequest(picUrl);
         EventListeners.add(loader.contentLoaderInfo,"ioError",function():void
         {
         });
         EventListeners.add(loader.contentLoaderInfo,"securityError",function():void
         {
         });
         EventListeners.add(loader.contentLoaderInfo,"complete",function(param1:Event):void
         {
            mSteamAvatar = loader;
            mSteamAvatar.x -= 25;
            mSteamAvatar.y -= 25;
            mSteamAvatar.width = mSteamAvatar.height = 50;
            if(mNametagFBPicSlot)
            {
               mNametagFBPicSlot.addChild(mSteamAvatar);
               startSteamAvatarPicLerp();
            }
         });
         lc = new LoaderContext(true);
         lc.checkPolicyFile = true;
         loader.load(url,lc);
      }
      
      private function startSteamAvatarPicLerp() : void
      {
         var _loc1_:TweenHandle = mDBFacade.mTween.createTimeline({
            "tweens":[mDBFacade.mTween.tweenMaxTo(mNametagTop,0.25,{"y":mNametagTopStartingYPosition - mNametagFBPicSlot.height}),mDBFacade.mTween.tweenMaxTo(mNametagFBPicSlot,0.041666666666666664,{"visible":true})],
            "align":"sequence"
         });
         mLogicalWorkComponent.doLater(5,finishSteamAvatarLerp);
      }
      
      private function finishSteamAvatarLerp(gameClock:GameClock) : void
      {
         var _loc2_:TweenHandle = mDBFacade.mTween.createTimeline({
            "tweens":[mDBFacade.mTween.tweenMaxTo(mNametagFBPicSlot,0.041666666666666664,{"visible":false}),mDBFacade.mTween.tweenMaxTo(mNametagTop,0.25,{"y":mNametagTopStartingYPosition})],
            "align":"sequence"
         });
      }
      
      public function set AFK(value:Boolean) : void
      {
         mAFK = value;
         if(mAFKText)
         {
            Locale.setText(mAFKText,mAFK ? "AFK" : null,null,1.82 * 1.45);
            layoutAFKText();
         }
         if(mStarlingNametag)
         {
            mStarlingNametag.contentChanged();
         }
      }
   }
}

