package UI.Hud.StarlingConverted
{
   import Account.PlayerSpecialStatus;
   import Actor.ActorGameObject;
   import Brain.Event.EventComponent;
   import Brain.Starling.SwfConverter.BakedCell;
   import Brain.Starling.SwfConverter.BakedImage;
   import Brain.Starling.SwfConverter.BakedPages;
   import Brain.Utils.TextUtil;
   import DistributedObjects.HeroGameObject;
   import Events.ChatEvent;
   import Events.GameObjectEvent;
   import Events.HpEvent;
   import Events.PlayerIsTypingEvent;
   import Facade.DBFacade;
   import Facade.Locale;
   import flash.display.MovieClip;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import starling.display.DisplayObject;
   import starling.display.DisplayObjectContainer;
   
   public class StarlingOffScreenClip
   {
      
      private var mFacade:DBFacade;
      
      private var mPlayer:ActorGameObject;
      
      private var mView:ArtView;
      
      private var mArrow:DisplayObject;
      
      private var mName:StarlingText;
      
      private var mNameX:Number;
      
      private var mAlert:StarlingText;
      
      private var mAlertX:Number;
      
      private var mHpView:ArtView;
      
      private var mHpRoot:DisplayObject;
      
      private var mHp:StarlingBar;
      
      private var mEvents:EventComponent;
      
      private var mTicker:HudTicker;
      
      private var mAvatar:StarlingHudIcon;
      
      private var mRedAvatar:StarlingHudIcon;
      
      private var mDeath:StarlingHudIcon;
      
      private var mTyping:ArtView;
      
      private var mBalloon:BakedImage;
      
      private var mBalloonCell:BakedCell;
      
      private var mBalloonSource:MovieClip;
      
      private var mBalloonRetry:Function;
      
      private var mBalloonKey:String;
      
      private var mBalloonScale:Number;
      
      private var mBalloonPixelScale:Number;
      
      private var mBalloonY:Number;
      
      private var mChatUntil:int;
      
      private var mRescue:Boolean;
      
      private var mDeathOnTop:Boolean = true;
      
      private var mNextSwap:int;
      
      private var mSteamCount:uint;
      
      private var mChanged:Function;
      
      private var mBounds:Rectangle = new Rectangle();
      
      private var mDisposed:Boolean;
      
      private var mFresh:Boolean = true;
      
      private var mBalloonPages:BakedPages;
      
      private var mPendingMessage:String;
      
      public function StarlingOffScreenClip(facade:DBFacade, ticker:HudTicker, parent:DisplayObjectContainer, player:ActorGameObject, changed:Function)
      {
         var _loc6_:String = null;
         var _loc8_:String = null;
         super();
         mFacade = facade;
         mTicker = ticker;
         mPlayer = player;
         mChanged = changed;
         mView = ArtView.build(HudArt.art("UI_widget"),ticker);
         ArtDisplay(mView.root).advanceHiddenTimelines(true);
         mArrow = mView.node("UI_arrow");
         mView.root.scaleX = mView.root.scaleY = 1.44;
         mView.root.visible = false;
         parent.addChild(mView.root);
         var _loc7_:StarlingText = mView.node("NametagText") as StarlingText;
         _loc7_.text = "";
         _loc7_.mode = "baked";
         _loc7_.color = PlayerSpecialStatus.getSpecialTextColor(player.screenName,_loc7_.color);
         _loc7_.setFittedText(player.screenName,1.82,1.27);
         mName = _loc7_;
         mNameX = _loc7_.x;
         mAlert = mView.node("AlertText") as StarlingText;
         mAlert.text = "";
         mAlertX = mAlert.x;
         mEvents = new EventComponent(facade);
         mEvents.addListener(GameObjectEvent.uniqueEvent("HpEvent_HP_UPDATE",player.id),hpChanged);
         mHpView = ArtView.build(HudArt.art("UI_nametag"),ticker);
         mHpRoot = mHpView.root;
         DisplayObjectContainer(mView.root).addChild(mHpRoot);
         mHpRoot.y = 25;
         mHp = new StarlingBar(mHpRoot,null,ticker);
         mHp.value = player.maxHitPoints > 0 ? player.hitPoints / player.maxHitPoints : 0;
         var _loc9_:HeroGameObject = player as HeroGameObject;
         if(_loc9_ != null)
         {
            _loc6_ = _loc9_.gmSkin.IconSwfFilepath;
            _loc8_ = _loc9_.gmSkin.IconName;
         }
         else
         {
            _loc6_ = player.actorData.gMActor.IconSwfFilepath;
            _loc8_ = player.actorData.gMActor.IconName;
         }
         var _loc10_:DisplayObjectContainer = mView.node("UI_avatar") as DisplayObjectContainer;
         mAvatar = new StarlingHudIcon(facade,ticker,_loc10_,avatarReady);
         mRedAvatar = new StarlingHudIcon(facade,ticker,_loc10_,avatarReady);
         mDeath = new StarlingHudIcon(facade,ticker,_loc10_,avatarReady);
         mAvatar.load(_loc6_,_loc8_,1,1,0,false,true);
         mRedAvatar.load(_loc6_,_loc8_,1,1,0,true,true);
         mDeath.load("Resources/Art2D/Icons/Avatars/db_icon_death.swf","death_icon",1,1,0,false,true);
         if(_loc9_ != null)
         {
            mTyping = ArtView.build(HudArt.art("UI_speechbubble_typing"),ticker);
            ArtDisplay(mTyping.root).advanceHiddenTimelines(true);
            mTyping.root.y = -40;
            mTyping.root.visible = false;
            DisplayObjectContainer(mView.root).addChild(mTyping.root);
            mEvents.addListener(GameObjectEvent.uniqueEvent("ChatEvent_INCOMING_CHAT_UPDATE",_loc9_.playerID),chatChanged);
            mEvents.addListener(GameObjectEvent.uniqueEvent("PLAYER_IS_TYPING",_loc9_.playerID),typingChanged);
            showSteamAvatar();
         }
         mBalloonRetry = bakeBalloon;
         if(_loc9_ != null && _loc9_.isInReviveState())
         {
            handlePicChange("REVIVE");
         }
         changed();
      }
      
      public function beginUpdate() : Boolean
      {
         if(!mFresh)
         {
            return true;
         }
         mFresh = false;
         return false;
      }
      
      public function get root() : DisplayObject
      {
         return mView.root;
      }
      
      public function get player() : ActorGameObject
      {
         return mPlayer;
      }
      
      public function get arrow() : DisplayObject
      {
         return mArrow;
      }
      
      private function hpChanged(event:HpEvent) : void
      {
         try
         {
            if(mPlayer.isDestroyed)
            {
               return;
            }
            mHp.value = event.maxHp > 0 ? event.hp / event.maxHp : 0;
            mChanged();
         }
         catch(error:Error)
         {
            StarlingHud.reportError(error);
         }
      }
      
      private function chatChanged(event:ChatEvent) : void
      {
         try
         {
            if(!mPlayer.isDestroyed)
            {
               setChat(event.message);
            }
         }
         catch(error:Error)
         {
            StarlingHud.reportError(error);
         }
      }
      
      private function typingChanged(event:PlayerIsTypingEvent) : void
      {
         try
         {
            if(mBalloon == null)
            {
               mTyping.root.visible = event.subtype == "CHAT_BOX_FOCUS_IN";
               mChanged();
            }
         }
         catch(error:Error)
         {
            StarlingHud.reportError(error);
         }
      }
      
      public function showSteamAvatar() : void
      {
         var _loc1_:HeroGameObject = mPlayer as HeroGameObject;
         if(_loc1_ == null || _loc1_.isDestroyed || mSteamCount >= 5)
         {
            return;
         }
         mSteamCount = mSteamCount + 1;
         _loc1_.heroView.nametag.showSteamAvatar(_loc1_.playerID);
      }
      
      private function avatarReady() : void
      {
         var _loc2_:BakedImage = null;
         var _loc1_:BakedImage = null;
         var _loc3_:BakedImage = null;
         var _loc4_:Boolean = false;
         try
         {
            _loc2_ = mAvatar.image;
            _loc1_ = mRedAvatar.image;
            _loc3_ = mDeath.image;
            _loc4_ = mRescue && !mDeath.absent;
            if(_loc2_ != null)
            {
               _loc2_.visible = !_loc4_;
            }
            if(_loc1_ != null)
            {
               _loc1_.visible = _loc4_;
            }
            if(_loc3_ != null)
            {
               _loc3_.visible = mRescue;
               if(mRescue && _loc1_ != null && _loc3_.parent == _loc1_.parent)
               {
                  _loc3_.parent.setChildIndex(mDeathOnTop ? _loc3_ : _loc1_,_loc3_.parent.numChildren - 1);
               }
            }
            mChanged();
         }
         catch(error:Error)
         {
            StarlingHud.reportError(error);
         }
      }
      
      public function handlePicChange(type:String) : void
      {
         mRescue = type == "REVIVE";
         mAlert.mode = "baked";
         if(mRescue)
         {
            mAlert.setFittedText(Locale.getString("NAMETAG_RESCUE"),1.36,1.27);
         }
         else
         {
            mAlert.text = "";
         }
         mDeathOnTop = true;
         mNextSwap = mTicker.gameTime + 250;
         avatarReady();
      }
      
      public function update() : void
      {
         var _loc1_:String = null;
         if(mChatUntil > 0 && mTicker.gameTime >= mChatUntil)
         {
            clearChat();
         }
         if(root.visible && mPendingMessage != null)
         {
            _loc1_ = mPendingMessage;
            mPendingMessage = null;
            buildChat(_loc1_);
         }
         while(mRescue && mTicker.gameTime >= mNextSwap)
         {
            mDeathOnTop = !mDeathOnTop;
            mNextSwap += 250;
            avatarReady();
         }
      }
      
      public function setChat(message:String) : void
      {
         clearChat();
         mChatUntil = mTicker.gameTime + 5000;
         if(!root.visible)
         {
            mPendingMessage = message;
            return;
         }
         buildChat(message);
      }
      
      private function buildChat(message:String) : void
      {
         var _loc6_:int = 0;
         var _loc2_:Class = null;
         var _loc5_:MovieClip = null;
         var _loc4_:TextField = null;
         var _loc3_:Vector.<String> = new <String>["UI_speechbubble","UI_speechbubble_02","UI_speechbubble_03","UI_speechbubble_04"];
         var _loc7_:Vector.<int> = new <int>[3,4,6];
         _loc6_ = 0;
         while(_loc6_ < _loc3_.length)
         {
            _loc2_ = HudArt.swfClass(_loc3_[_loc6_]);
            _loc5_ = new _loc2_() as MovieClip;
            _loc4_ = _loc5_.chatMessage;
            _loc4_.text = message;
            if(_loc6_ == 3 || _loc4_.numLines <= _loc7_[_loc6_])
            {
               break;
            }
            _loc6_++;
         }
         HudArtConverter.stopTree(_loc5_);
         mBalloonScale = TextUtil.scaleToFloor(Number(_loc4_.defaultTextFormat.size),1.82 * 1.05);
         mBalloonY = _loc5_.getBounds(_loc5_).bottom * (1 - mBalloonScale);
         mBalloonSource = _loc5_;
         mBalloonPixelScale = BakeScale.forDisplay(root) * mBalloonScale;
         mBalloonKey = "starlingOffScreenChat|" + _loc3_[_loc6_] + "|" + message + "|" + mBalloonPixelScale;
         if(!bakeBalloon())
         {
            mTicker.deferBake(mBalloonRetry);
         }
      }
      
      private function bakeBalloon() : Boolean
      {
         var _loc1_:ArtNode = null;
         if(mDisposed || mBalloonSource == null)
         {
            return true;
         }
         if(!root.visible)
         {
            return false;
         }
         mBalloonPages = HudArt.pages;
         mBalloonCell = HudArt.bakeContent(mBalloonKey,mBalloonSource,mBalloonPixelScale);
         if(mBalloonCell == null)
         {
            return false;
         }
         if(HudArt.content(mBalloonKey) == null)
         {
            _loc1_ = new ArtNode();
            _loc1_.cell = _loc1_.hold(mBalloonPages.acquire(mBalloonKey),mBalloonPages);
            HudArt.storeContent(mBalloonKey,_loc1_);
         }
         mBalloon = new BakedImage(mBalloonCell);
         mBalloon.scaleX = mBalloon.scaleY = mBalloonScale;
         mBalloon.y = -40 + mBalloonY;
         DisplayObjectContainer(root).addChild(mBalloon);
         mBalloonSource = null;
         mPendingMessage = null;
         mChanged();
         return true;
      }
      
      private function clearChat() : void
      {
         mPendingMessage = null;
         mTicker.cancelBake(mBalloonRetry);
         try
         {
            if(mBalloon != null)
            {
               mBalloon.removeFromParent(true);
            }
         }
         catch(error:Error)
         {
            StarlingHud.reportError(error);
         }
         try
         {
            if(mBalloonCell != null)
            {
               mBalloonPages.release(mBalloonCell);
            }
         }
         catch(cellError:Error)
         {
            StarlingHud.reportError(cellError);
         }
         mBalloonPages = null;
         mBalloonCell = null;
         mBalloon = null;
         mBalloonSource = null;
         mBalloonKey = null;
         mChatUntil = 0;
         mChanged();
      }
      
      public function keepChatOnScreen(width:Number, height:Number) : void
      {
         if(mBalloon == null)
         {
            return;
         }
         mBalloon.x = 0;
         mBalloon.y = -40 + mBalloonY;
         mBalloon.getBounds(root.parent,mBounds);
         var _loc3_:Number = mBounds.left < 0 ? -mBounds.left : (mBounds.right > width ? width - mBounds.right : 0);
         var _loc4_:Number = mBounds.top < 0 ? -mBounds.top : (mBounds.bottom > height ? height - mBounds.bottom : 0);
         mBalloon.x += _loc3_ / root.scaleX;
         mBalloon.y += _loc4_ / root.scaleY;
      }
      
      public function keepTextOnScreen(width:Number) : void
      {
         var _loc2_:Boolean = keepOnScreen(mName,mNameX,width);
         if(keepOnScreen(mAlert,mAlertX,width))
         {
            _loc2_ = true;
         }
         if(_loc2_)
         {
            mChanged();
         }
      }
      
      private function keepOnScreen(text:StarlingText, authoredX:Number, width:Number) : Boolean
      {
         var _loc4_:Number = text.x;
         text.x = authoredX;
         text.getBounds(root.parent,mBounds);
         if(mBounds.width > 0)
         {
            text.x += (mBounds.left < 0 ? -mBounds.left : (mBounds.right > width ? width - mBounds.right : 0)) / root.scaleX;
         }
         return text.x != _loc4_;
      }
      
      public function dispose() : void
      {
         if(mDisposed)
         {
            return;
         }
         mDisposed = true;
         try
         {
            clearChat();
         }
         catch(error:Error)
         {
            StarlingHud.reportError(error);
         }
         StarlingHud.disposeResource(mEvents,"destroy");
         StarlingHud.disposeResource(mAvatar);
         StarlingHud.disposeResource(mRedAvatar);
         StarlingHud.disposeResource(mDeath);
         StarlingHud.disposeResource(mHp);
         StarlingHud.disposeResource(mHpView);
         StarlingHud.disposeResource(mTyping);
         StarlingHud.disposeResource(mView);
         mChanged();
      }
   }
}

