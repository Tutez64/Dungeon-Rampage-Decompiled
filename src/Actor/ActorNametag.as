package Actor
{
   import Account.PlayerSpecialStatus;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Clock.GameClock;
   import Brain.Event.EventComponent;
   import Brain.Facade.Facade;
   import Brain.GameObject.GameObject;
   import Brain.UI.UIProgressBar;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Brain.WorkLoop.Task;
   import DistributedObjects.PlayerGameObject;
   import Events.FacebookIdReceivedEvent;
   import Events.GameObjectEvent;
   import Facade.DBFacade;
   import Facade.Locale;
   import com.greensock.TimelineMax;
   import com.greensock.TweenMax;
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
      
      private static const FACEBOOK_PIC_VISIBLE_TIME:Number = 5;
      
      private static const FACEBOOK_PIC_ANIMATE_UP_FRAMES:Number = 0.25;
      
      private static const FACEBOOK_PIC_ANIMATE_DOWN_FRAMES:Number = 0.25;
      
      protected var mLogicalWorkComponent:LogicalWorkComponent;
      
      protected var mEventComponent:EventComponent;
      
      protected var mShowNametagTask:Task;
      
      protected var mHpProgressBar:UIProgressBar;
      
      protected var mHpBarBg:Sprite;
      
      protected var mHpProgressBarVisible:Boolean = true;
      
      protected var mTextField:TextField;
      
      protected var mAFKText:TextField;
      
      protected var mScreenName:String = Locale.getString("DEFAULT_NAMETAG");
      
      protected var mHealth:Number = 1;
      
      protected var mFacade:Facade;
      
      protected var mNametagTop:Sprite;
      
      protected var mNametagTopStartingYPosition:Number;
      
      protected var mChatBalloon:ChatBalloon;
      
      protected var mPlayerIsTypingNotification:MovieClip;
      
      protected var mChatDuration:Number = 5;
      
      protected var mAFK:Boolean = false;
      
      protected var mNametagFBPicSlot:MovieClip;
      
      protected var mFacebokPic:DisplayObject;
      
      protected var mHpBarHolder:MovieClip;
      
      public function ActorNametag(facade:Facade, assetLoader:AssetLoadingComponent, workComponent:LogicalWorkComponent, nametagY:Number)
      {
         super();
         mFacade = facade;
         mLogicalWorkComponent = workComponent;
         mEventComponent = new EventComponent(mFacade);
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
         assetLoader.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_nametag.swf"),setupNametagFromSwf);
      }
      
      private function setupNametagFromSwf(swfAsset:SwfAsset) : void
      {
         var _loc3_:Class = swfAsset.getClass("UI_nametag");
         var _loc5_:MovieClip = new _loc3_();
         mNametagFBPicSlot = _loc5_.avatar;
         mNametagFBPicSlot.visible = false;
         mHpBarHolder = _loc5_.hp;
         mHpProgressBar = new UIProgressBar(mFacade,_loc5_.hp.hpBar);
         mHpProgressBar.value = mHealth;
         mHpProgressBar.visible = mHpProgressBarVisible;
         mTextField = _loc5_.nameText;
         updateNameTagText();
         mAFKText = _loc5_.AFKText;
         mAFKText.text = "";
         mHpBarBg = _loc5_.hp.hpBarBg;
         mNametagTop.addChild(_loc5_);
         mNametagTopStartingYPosition = mNametagTop.y;
         var _loc4_:Class = swfAsset.getClass("UI_speechbubble");
         var _loc2_:MovieClip = new _loc4_();
         mChatBalloon.initializeChatBalloon(swfAsset);
         var _loc6_:Class = swfAsset.getClass("UI_speechbubble_typing");
         mPlayerIsTypingNotification = new _loc6_();
         this.addChild(mPlayerIsTypingNotification);
         showPlayerIsTypingNotification(false);
      }
      
      public function setChat(message:String) : void
      {
         if(mChatBalloon)
         {
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
            mTextField.text = mScreenName;
            mTextField.textColor = PlayerSpecialStatus.getSpecialTextColor(mScreenName,mTextField.textColor);
         }
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
         }
      }
      
      public function destroy() : void
      {
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
         mChatBalloon = null;
         mFacebokPic = null;
         mNametagFBPicSlot = null;
         mPlayerIsTypingNotification = null;
         mLogicalWorkComponent = null;
         if(this.parent)
         {
            this.parent.removeChild(this);
         }
         mFacade = null;
      }
      
      public function showFacebookPicture(playerId:uint) : void
      {
         var go:GameObject;
         var player:PlayerGameObject;
         if(!mFacebokPic)
         {
            go = mFacade.gameObjectManager.getReferenceFromId(playerId);
            player = go as PlayerGameObject;
            if(player)
            {
               if(player.facebookId && player.facebookId != "")
               {
                  saveFacebookPic(player.facebookId);
               }
               else
               {
                  mEventComponent.addListener(GameObjectEvent.uniqueEvent("FACEBOOK_ID_RECEIVED_EVENT",player.id),function(param1:FacebookIdReceivedEvent):void
                  {
                     saveFacebookPic(param1.facebookId);
                  });
               }
            }
         }
         else if(mNametagFBPicSlot && !mNametagFBPicSlot.visible)
         {
            startFacebookPicLerp();
         }
      }
      
      private function saveFacebookPic(fbId:String) : void
      {
         var lc:LoaderContext;
         var loader:Loader = new Loader();
         var picUrl:String = "https://graph.facebook.com/" + fbId + "/picture";
         var url:URLRequest = new URLRequest(picUrl);
         loader.contentLoaderInfo.addEventListener("ioError",function():void
         {
         });
         loader.contentLoaderInfo.addEventListener("securityError",function():void
         {
         });
         loader.contentLoaderInfo.addEventListener("complete",function(param1:Event):void
         {
            mFacebokPic = loader;
            mFacebokPic.x -= 25;
            mFacebokPic.y -= 25;
            if(mNametagFBPicSlot)
            {
               mNametagFBPicSlot.addChild(mFacebokPic);
               startFacebookPicLerp();
            }
         });
         lc = new LoaderContext(true);
         lc.checkPolicyFile = true;
         loader.load(url,lc);
      }
      
      private function startFacebookPicLerp() : void
      {
         var _loc1_:TimelineMax = new TimelineMax({
            "tweens":[TweenMax.to(mNametagTop,0.25,{"y":mNametagTopStartingYPosition - mNametagFBPicSlot.height}),TweenMax.to(mNametagFBPicSlot,0.041666666666666664,{"visible":true})],
            "align":"sequence"
         });
         mLogicalWorkComponent.doLater(5,finishFacebookLerp);
      }
      
      private function finishFacebookLerp(gameClock:GameClock) : void
      {
         var _loc2_:TimelineMax = new TimelineMax({
            "tweens":[TweenMax.to(mNametagFBPicSlot,0.041666666666666664,{"visible":false}),TweenMax.to(mNametagTop,0.25,{"y":mNametagTopStartingYPosition})],
            "align":"sequence"
         });
      }
      
      public function set AFK(value:Boolean) : void
      {
         mAFK = value;
         if(mAFKText)
         {
            if(mAFK)
            {
               mAFKText.text = Locale.getString("AFK");
            }
            else
            {
               mAFKText.text = "";
            }
         }
      }
   }
}

