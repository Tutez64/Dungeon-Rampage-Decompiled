package Town
{
   import Account.AvatarInfo;
   import Account.StoreServicesController;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Clock.GameClock;
   import Brain.Event.EventComponent;
   import Brain.Event.EventListeners;
   import Brain.Logger.Logger;
   import Brain.Render.MovieClipRenderController;
   import Brain.UI.UIButton;
   import Brain.Utils.MemoryTracker;
   import Brain.Utils.TextUtil;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Brain.WorkLoop.Task;
   import Brain.jsonRPC.JSONRPCService;
   import Collections.Map;
   import DBGlobals.DBGlobal;
   import Events.DBAccountResponseEvent;
   import Events.XPBonusEvent;
   import Facade.DBFacade;
   import Facade.Locale;
   import Facade.TrickleCacheLoader;
   import GameMasterDictionary.GMOffer;
   import GameMasterDictionary.GMSkin;
   import Settings.Model.SettingsModel;
   import Settings.SettingsPopup;
   import SteamInput.OnSteamInputButtonReleasedEvent;
   import UI.DailyRewards.UIDailyRewards;
   import UI.Gifting.UIGift;
   import UI.Leaderboard.UILeaderboard;
   import UI.Popup.DBUIMoviePopup;
   import UI.Popup.DBUIOneButtonPopup;
   import UI.Popup.DBUIPopup;
   import UI.Popup.UIDragonKnightUpsellPopup;
   import UI.Popup.UIFlaggedPopup;
   import UI.Popup.UIWhatsNewPopup;
   import UI.UILevelUpPostController;
   import UI.UIPagingPanel;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.geom.Point;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   
   public class HomeState extends TownSubState
   {
      
      public static const NAME:String = "HomeState";
      
      public static const ACTIVE_AVATAR_CHANGED_EVENT:String = "ACTIVE_AVATAR_CHANGED_EVENT";
      
      private static const POPUP_DELAY_TIME:Number = 0.5;
      
      private static const COLISEUM_UNLOCK_LEVEL:uint = 100;
      
      public static var mHasPonderedMOD:Boolean = false;
      
      protected var mBattleButton:UIButton;
      
      protected var mTavernButton:UIButton;
      
      protected var mInventoryButton:UIButton;
      
      protected var mSkillsButton:UIButton;
      
      protected var mSkillsButtonLocked:UIButton;
      
      protected var mTrainButton:UIButton;
      
      protected var mShopButton:UIButton;
      
      protected var mGiftButton:UIButton;
      
      protected var mRewardButton:UIButton;
      
      protected var mNewsButton:UIButton;
      
      protected var mCreditsButton:UIButton;
      
      protected var mOptionsButton:UIButton;
      
      protected var mSettingsPopup:SettingsPopup;
      
      protected var mTavernAlertUp:MovieClip;
      
      protected var mTavernAlertOver:MovieClip;
      
      protected var mInventoryAlertUp:MovieClip;
      
      protected var mInventoryAlertOver:MovieClip;
      
      protected var mSkillsAlertUp:MovieClip;
      
      protected var mSkillsAlertOver:MovieClip;
      
      protected var mTrainAlertUp:MovieClip;
      
      protected var mTrainAlertOver:MovieClip;
      
      protected var mShopAlertUp:MovieClip;
      
      protected var mShopAlertOver:MovieClip;
      
      protected var mShopNewUp:MovieClip;
      
      protected var mShopNewOver:MovieClip;
      
      protected var mGiftAlertUp:MovieClip;
      
      protected var mGiftAlertOver:MovieClip;
      
      protected var mGiftPopup:UIGift;
      
      protected var mDailyRewardAlertUp:MovieClip;
      
      protected var mDailyRewardAlertOver:MovieClip;
      
      protected var mDailyRewardsPopup:UIDailyRewards;
      
      protected var mEventComponent:EventComponent;
      
      protected var mLogicalWorkComponent:LogicalWorkComponent;
      
      protected var mAssetLoadingComponent:AssetLoadingComponent;
      
      protected var mRenderer:MovieClipRenderController;
      
      private var mPopupDelayTask:Task;
      
      private var mOptionsKeyTask:Task;
      
      protected var mUILeaderboard:UILeaderboard;
      
      private var mNewsStories:Vector.<MessageOfTheDay>;
      
      private var mNewsPagination:UIPagingPanel;
      
      private var mNewsCurrentPage:uint;
      
      private var mNewsTotalPages:uint;
      
      private var mNewsPopUp:DBUIPopup;
      
      public function HomeState(dbFacade:DBFacade, townStateMachine:TownStateMachine)
      {
         super(dbFacade,townStateMachine,"HomeState");
         mEventComponent = new EventComponent(mDBFacade);
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"HomeState");
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         var _loc3_:SettingsModel = mDBFacade.settingsModel;
         mNewsStories = new Vector.<MessageOfTheDay>();
      }
      
      private function toggleSettingsPopup() : void
      {
         if(mSettingsPopup)
         {
            mSettingsPopup.destroy();
            mSettingsPopup = null;
            return;
         }
         mSettingsPopup = new SettingsPopup(mDBFacade,onSettingsPopupClosed);
         MemoryTracker.track(mSettingsPopup,"SettingsPopup - created in HomeState.toggleSettingsPopup()");
      }
      
      private function onSettingsPopupClosed() : void
      {
         mSettingsPopup = null;
      }
      
      private function checkOptionsKey(gameClock:GameClock) : void
      {
         if(mDBFacade.keyBindings.wasReleased("openOptionsMenu"))
         {
            toggleSettingsFromShortcut();
         }
      }
      
      private function onSteamInputButtonReleased(event:OnSteamInputButtonReleasedEvent) : void
      {
         if(event.actionName == "menu_options")
         {
            toggleSettingsFromShortcut();
         }
      }
      
      private function toggleSettingsFromShortcut() : void
      {
         var _loc1_:Boolean = mSettingsPopup ? SettingsPopup.isTopMenu(mDBFacade) : mDBFacade.menuNavigationController.getTopUILayer() == "TOWN_MENU";
         if(_loc1_)
         {
            toggleSettingsPopup();
         }
      }
      
      override public function destroy() : void
      {
         EventListeners.remove(mDBFacade.stageRef,"keyDown",openDaily);
         if(mDailyRewardsPopup != null)
         {
            mDailyRewardsPopup.destroy();
            mDailyRewardsPopup = null;
         }
         mRenderer.destroy();
         mBattleButton.destroy();
         mTavernButton.destroy();
         mInventoryButton.destroy();
         if(mSkillsButtonLocked)
         {
            mSkillsButtonLocked.destroy();
            mSkillsButtonLocked = null;
         }
         mTrainButton.destroy();
         mShopButton.destroy();
         mGiftButton.destroy();
         mCreditsButton.destroy();
         mOptionsButton.destroy();
         if(mEventComponent)
         {
            mEventComponent.destroy();
         }
         mEventComponent = null;
         if(mLogicalWorkComponent)
         {
            mLogicalWorkComponent.destroy();
         }
         mLogicalWorkComponent = null;
         if(mUILeaderboard)
         {
            mUILeaderboard = null;
         }
         if(mAssetLoadingComponent)
         {
            mAssetLoadingComponent.destroy();
         }
         mAssetLoadingComponent = null;
         if(mSettingsPopup)
         {
            mSettingsPopup.destroy();
            mSettingsPopup = null;
         }
         mDBFacade.menuNavigationController.popLayer("TOWN_MENU");
         super.destroy();
      }
      
      override protected function setupState() : void
      {
         super.setupState();
         mBattleButton = new UIButton(mDBFacade,mRootMovieClip.townScreen_button_battle_instance);
         mBattleButton.releaseCallback = mTownStateMachine.enterMapState;
         mInventoryButton = new UIButton(mDBFacade,mRootMovieClip.townScreen_inventory_button_instance);
         mInventoryButton.releaseCallback = mTownStateMachine.enterInventoryState;
         Locale.setText(mRootMovieClip.townScreen_inventory_button_instance.up.label,"INVENTORY_BUILDING");
         Locale.setText(mRootMovieClip.townScreen_inventory_button_instance.over.label,"INVENTORY_BUILDING");
         mInventoryAlertUp = mRootMovieClip.townScreen_inventory_button_instance.up.alert_icon;
         mInventoryAlertOver = mRootMovieClip.townScreen_inventory_button_instance.over.alert_icon;
         mInventoryAlertUp.visible = false;
         mInventoryAlertOver.visible = false;
         mTavernButton = new UIButton(mDBFacade,mRootMovieClip.townScreen_tavern_button_instance);
         mTavernButton.releaseCallback = mTownStateMachine.enterTavernState;
         Locale.setText(mRootMovieClip.townScreen_tavern_button_instance.up.label,"TAVERN_BUILDING");
         Locale.setText(mRootMovieClip.townScreen_tavern_button_instance.over.label,"TAVERN_BUILDING");
         mTavernAlertUp = mRootMovieClip.townScreen_tavern_button_instance.up.alert_icon;
         mTavernAlertOver = mRootMovieClip.townScreen_tavern_button_instance.over.alert_icon;
         mTavernAlertUp.visible = false;
         mTavernAlertOver.visible = false;
         mTrainButton = new UIButton(mDBFacade,mRootMovieClip.townScreen_train_button_instance);
         mTrainButton.releaseCallback = mTownStateMachine.enterTrainState;
         Locale.setText(mRootMovieClip.townScreen_train_button_instance.up.label,"TRAINING_BUILDING");
         Locale.setText(mRootMovieClip.townScreen_train_button_instance.over.label,"TRAINING_BUILDING");
         mTrainAlertUp = mRootMovieClip.townScreen_train_button_instance.up.alert_icon;
         mTrainAlertOver = mRootMovieClip.townScreen_train_button_instance.over.alert_icon;
         mTrainAlertUp.visible = false;
         mTrainAlertOver.visible = false;
         mCreditsButton = new UIButton(mDBFacade,mRootMovieClip.news);
         mCreditsButton.releaseCallback = mTownStateMachine.enterCreditState;
         Locale.setText(mRootMovieClip.news.up.credit_mc.label,"CREDITS_BUILDING");
         Locale.setText(mRootMovieClip.news.over.credit_mc.label,"CREDITS_BUILDING");
         mSkillsButton = new UIButton(mDBFacade,mRootMovieClip.townScreen_skills_button_instance);
         mSkillsButton.releaseCallback = mTownStateMachine.enterSkillsState;
         mSkillsAlertUp = mRootMovieClip.townScreen_skills_button_instance.up.alert_icon;
         mSkillsAlertOver = mRootMovieClip.townScreen_skills_button_instance.over.alert_icon;
         mSkillsAlertUp.visible = false;
         mSkillsAlertOver.visible = false;
         mSkillsButtonLocked = new UIButton(mDBFacade,mRootMovieClip.townScreen_coliseumClosed_button_instance);
         mSkillsButtonLocked.releaseCallback = showColiseumClosedPopup;
         mSkillsButtonLocked.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mRootMovieClip.townScreen_shop_button_sale_instance.visible = false;
         mShopButton = new UIButton(mDBFacade,mRootMovieClip.townScreen_shop_button_instance);
         mShopButton.releaseCallback = mTownStateMachine.enterShopState;
         Locale.setText(mRootMovieClip.townScreen_shop_button_instance.up.label,"SHOP_BUILDING");
         Locale.setText(mRootMovieClip.townScreen_shop_button_instance.over.label,"SHOP_BUILDING");
         mShopAlertUp = mRootMovieClip.townScreen_shop_button_instance.up.alert_icon;
         mShopAlertOver = mRootMovieClip.townScreen_shop_button_instance.over.alert_icon;
         mShopAlertUp.visible = false;
         mShopAlertOver.visible = false;
         mShopNewUp = mRootMovieClip.townScreen_shop_button_instance.up.new_icon;
         mShopNewOver = mRootMovieClip.townScreen_shop_button_instance.over.new_icon;
         mGiftButton = new UIButton(mDBFacade,mRootMovieClip.gift);
         mGiftButton.releaseCallback = function():void
         {
            mGiftPopup = new UIGift(mDBFacade,mRootMovieClip,giftPopupCloseCallback,giftCallbackToFriendManager);
            mGiftButton.enabled = false;
         };
         EventListeners.add(mDBFacade.stageRef,"keyDown",openDaily);
         if(!mDBFacade.mCheckedDailyReward)
         {
            mDBFacade.mCheckedDailyReward = true;
            mDailyRewardsPopup = new UIDailyRewards(mDBFacade,rewardPopupCloseCallback,false);
         }
         Locale.setText(mRootMovieClip.gift.up.label,"GIFT_BUILDING");
         Locale.setText(mRootMovieClip.gift.over.label,"GIFT_BUILDING");
         mGiftAlertUp = mRootMovieClip.gift.up.alert_icon;
         mGiftAlertOver = mRootMovieClip.gift.over.alert_icon;
         mGiftAlertUp.visible = false;
         mGiftAlertOver.visible = false;
         mOptionsButton = new UIButton(mDBFacade,mRootMovieClip.options_button);
         mOptionsButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mOptionsButton.releaseCallback = toggleSettingsPopup;
         mRenderer = new MovieClipRenderController(mDBFacade,mRootMovieClip);
         loadActiveAvatarIcon(new Event("ACTIVE_AVATAR_CHANGED_EVENT"));
         mEventComponent.addListener("ACTIVE_AVATAR_CHANGED_EVENT",loadActiveAvatarIcon);
         this.refreshAlerts();
         mTavernButton.isToTheLeftOf(mBattleButton);
         mTavernButton.isAbove(mGiftButton);
         mBattleButton.isToTheLeftOf(mInventoryButton);
         mBattleButton.isAbove(mShopButton);
         mInventoryButton.isAbove(mCreditsButton);
         mInventoryButton.rightNavigation = mOptionsButton;
         mOptionsButton.downNavigation = mCreditsButton;
         mCreditsButton.rightNavigation = mOptionsButton;
         mGiftButton.isToTheLeftOf(mTrainButton);
         mTrainButton.isToTheLeftOf(mShopButton);
         mTavernButton.leftNavigation = mGiftButton;
         mTrainButton.upNavigation = mTavernButton;
         mSkillsButton.upNavigation = mInventoryButton;
         mSkillsButtonLocked.upNavigation = mInventoryButton;
         refreshColiseumLock();
         setupHeaderLinks();
         mDBFacade.menuNavigationController.pushNewLayer("TOWN_MENU",mTownStateMachine.townHeader.determineCallback,mBattleButton,mBattleButton,focusPreviousLeaderboardFriend,focusNextLeaderboardFriend);
         mEventComponent.addListener("LEADERBOARD_INITIALIZED_EVENT",setupFriendLinks);
         setupFriendLinks();
      }
      
      public function setupFriendLinks(event:Event = null) : void
      {
         if(!mUILeaderboard)
         {
            mUILeaderboard = mTownStateMachine.leaderboard;
         }
         if(!mUILeaderboard)
         {
            return;
         }
         if(!mUILeaderboard.initialized)
         {
            return;
         }
         mEventComponent.removeListener("LEADERBOARD_INITIALIZED_EVENT");
         mUILeaderboard.setupNavigationlinks();
         linkTownButtonsToLeaderboard();
         mGiftButton.clearDownNavigation();
         mGiftButton.downNavigation = mUILeaderboard.getManageFriendsButton;
      }
      
      private function linkTownButtonsToLeaderboard() : void
      {
         if(!mUILeaderboard || !mUILeaderboard.initialized)
         {
            return;
         }
         mUILeaderboard.linkTownButtons([mTrainButton,mShopButton,coliseumButton]);
      }
      
      private function get coliseumButton() : UIButton
      {
         return mSkillsButton.enabled ? mSkillsButton : mSkillsButtonLocked;
      }
      
      private function focusPreviousLeaderboardFriend() : void
      {
         if(mUILeaderboard)
         {
            mUILeaderboard.focusPreviousFriendSlot();
         }
      }
      
      private function focusNextLeaderboardFriend() : void
      {
         if(mUILeaderboard)
         {
            mUILeaderboard.focusNextFriendSlot();
         }
      }
      
      override protected function setupHeaderLinks() : void
      {
         super.resetHeaderLinks();
         super.setupHeaderLinks();
         mTownStateMachine.townHeader.addCoinButton.isAbove(mTavernButton);
         mTownStateMachine.townHeader.addGemButton.isAbove(mBattleButton);
         mTownStateMachine.townHeader.closeButton.isAbove(mInventoryButton);
         mTownStateMachine.townHeader.closeButton.isToTheLeftOf(mOptionsButton);
      }
      
      private function refreshHeaderNavigationLinks() : void
      {
         super.resetHeaderLinks();
         super.setupHeaderLinks();
         mTownStateMachine.townHeader.addCoinButton.downNavigation = mTavernButton;
         mTownStateMachine.townHeader.addGemButton.downNavigation = mBattleButton;
         mTownStateMachine.townHeader.closeButton.downNavigation = mInventoryButton;
         mTownStateMachine.townHeader.closeButton.rightNavigation = mOptionsButton;
      }
      
      private function openDaily(event:KeyboardEvent) : void
      {
         if(event.keyCode == 36 && mDBFacade != null)
         {
            mDailyRewardsPopup = new UIDailyRewards(mDBFacade,rewardPopupCloseCallback,true);
            EventListeners.remove(mDBFacade.stageRef,"keyDown",openDaily);
         }
      }
      
      public function animateEntry() : void
      {
         if(mTownStateMachine.townHeader.rootMovieClip != null)
         {
            if(mDBFacade.featureFlags.getFlagValue("want-town-animations"))
            {
               mTownStateMachine.townHeader.rootMovieClip.visible = false;
               mLogicalWorkComponent.doLater(0.20833333333333334,function(param1:GameClock):void
               {
                  mTownStateMachine.townHeader.animateHeader();
               });
            }
         }
      }
      
      private function refreshColiseumLock() : void
      {
         if(!mSkillsButton || !mSkillsButtonLocked)
         {
            return;
         }
         var _loc1_:Boolean = tryUnlockColiseum();
         mSkillsButton.visible = _loc1_;
         mSkillsButton.enabled = _loc1_;
         mSkillsButtonLocked.visible = !_loc1_;
         mSkillsButtonLocked.enabled = !_loc1_;
         mShopButton.clearRightNavigation();
         mCreditsButton.clearLeftNavigation();
         mCreditsButton.clearDownNavigation();
         mShopButton.isToTheLeftOf(coliseumButton);
         coliseumButton.isToTheLeftOf(mCreditsButton);
         mCreditsButton.downNavigation = coliseumButton;
         linkTownButtonsToLeaderboard();
      }
      
      private function tryUnlockColiseum() : Boolean
      {
         if(mDBFacade.dbAccountInfo.hasAttribute("hasReachedLevel100"))
         {
            return true;
         }
         if(!hasHeroAtColiseumUnlockLevel())
         {
            return false;
         }
         mDBFacade.dbAccountInfo.alterAttribute("hasReachedLevel100","1");
         return true;
      }
      
      private function hasHeroAtColiseumUnlockLevel() : Boolean
      {
         var _loc2_:AvatarInfo = null;
         var _loc4_:Map = mDBFacade.dbAccountInfo.inventoryInfo.avatars;
         if(!_loc4_)
         {
            return false;
         }
         var _loc1_:Array = _loc4_.keysToArray();
         for each(var _loc3_ in _loc1_)
         {
            _loc2_ = _loc4_.itemFor(_loc3_) as AvatarInfo;
            if(_loc2_ && _loc2_.cloutLevel >= 100)
            {
               return true;
            }
         }
         return false;
      }
      
      private function showColiseumClosedPopup() : void
      {
         var _loc1_:DBUIOneButtonPopup = new DBUIOneButtonPopup(mDBFacade,"COLISEUM_CLOSED_POPUP",Locale.getString("COLISEUM_CLOSED_TITLE"),Locale.getString("COLISEUM_CLOSED_MESSAGE"),Locale.getString("OK"),null);
         MemoryTracker.track(_loc1_,"DBUIOneButtonPopup - created in HomeState.showColiseumClosedPopup()");
      }
      
      private function refreshAlerts() : void
      {
         var _loc2_:Boolean = false;
         var _loc1_:Boolean = false;
         if(mRootMovieClip)
         {
            mTavernAlertUp.visible = mTavernAlertOver.visible = this.tavernNeedsAttention;
            mTrainAlertUp.visible = mTrainAlertOver.visible = this.trainingNeedsAttention;
            mSkillsAlertUp.visible = mSkillsAlertOver.visible = this.skillsNeedsAttention;
            mShopAlertUp.visible = mShopAlertOver.visible = this.shopNeedsAttention;
            mInventoryAlertUp.visible = mInventoryAlertOver.visible = this.inventoryNeedsAttention;
            checkGiftAlert();
            _loc2_ = mDBFacade.gameMaster.storeHasSaleNow();
            if(_loc2_)
            {
               mRootMovieClip.townScreen_shop_button_sale_instance.visible = true;
               mRootMovieClip.townScreen_shop_button_instance.visible = false;
               mShopButton = new UIButton(mDBFacade,mRootMovieClip.townScreen_shop_button_sale_instance);
               mShopButton.releaseCallback = mTownStateMachine.enterShopState;
            }
            _loc1_ = mDBFacade.gameMaster.storeHasNewOffers();
            mShopNewUp.visible = _loc1_;
            mShopNewOver.visible = _loc1_;
         }
      }
      
      private function tryShowBetaRewardsPopup() : Boolean
      {
         if(mDBFacade.dbAccountInfo.dbAccountParams.hasBetaPlayerParam())
         {
            if(mDBFacade.dbAccountInfo.dbAccountParams.hasBetaRewardsParam())
            {
               return false;
            }
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),function(param1:SwfAsset):void
            {
               var swfAsset:SwfAsset = param1;
               var popup:DBUIOneButtonPopup = new DBUIOneButtonPopup(mDBFacade,"BETA_REWARDS_POPUP",Locale.getString("BETA_REWARDS_POPUP_TITLE"),Locale.getString("BETA_REWARDS_POPUP_MESSAGE"),Locale.getString("BETA_REWARDS_POPUP_BUTTON"),function():void
               {
               },true,null,"popup_beta_thanks");
               MemoryTracker.track(popup,"DBUIOneButtonPopup - created in HomeState.tryShowBetaRewardsPopup()");
            });
            mDBFacade.dbAccountInfo.dbAccountParams.setBetaRewardsParam();
            return true;
         }
         return false;
      }
      
      private function tryShowWhatsNewPopup(callback:Function) : void
      {
         this.getWhatsNewRPC(callback);
      }
      
      private function getWhatsNewCallback(gameAction:String) : Function
      {
         var callback:Function;
         switch(gameAction)
         {
            case "STORE":
            case "SHOP":
               callback = function():void
               {
                  mTownStateMachine.enterShopState();
               };
               break;
            case "BATTLE":
            case "MAP":
               callback = function():void
               {
                  mTownStateMachine.enterMapState();
               };
               break;
            case "INVENTORY":
               callback = function():void
               {
                  mTownStateMachine.enterInventoryState();
               };
               break;
            case "TRAINING":
               callback = function():void
               {
                  mTownStateMachine.enterTrainState();
               };
               break;
            case "GEMS":
               callback = function():void
               {
                  StoreServicesController.showCashPage(mDBFacade,"whatsNewPopup");
               };
               break;
            case "TAVERN":
               callback = function():void
               {
                  mTownStateMachine.enterTavernState();
               };
               break;
            case "CLOSE":
            case "":
               callback = null;
               break;
            default:
               Logger.warn("Ignoring MOD game_action: action not recognized: " + gameAction);
               callback = null;
         }
         return callback;
      }
      
      private function getWhatsNewRPC(callback:Function = null, skipPonder:Boolean = false) : void
      {
         var platformParameter:uint;
         var rpcFunc:Function;
         var parseResults:Function;
         var firstLoginConfig:Boolean = mDBFacade.dbConfigManager.getConfigBoolean("FirstLoginToday",true);
         if(!skipPonder)
         {
            if(mHasPonderedMOD || !firstLoginConfig)
            {
               return;
            }
         }
         mHasPonderedMOD = true;
         platformParameter = mDBFacade.dbConfigManager.networkId;
         rpcFunc = JSONRPCService.getFunction("getmod",mDBFacade.rpcRoot + "modrpc");
         parseResults = function(param1:*):void
         {
            var _loc4_:String = null;
            var _loc2_:String = null;
            var _loc3_:MessageOfTheDay = null;
            if(!mDBFacade)
            {
               return;
            }
            if(param1 is Array && param1.length > 0)
            {
               for each(var _loc5_:Object in param1)
               {
                  _loc4_ = String(_loc5_.game_action).toUpperCase();
                  _loc2_ = Locale.getString("WHATS_NEW_" + _loc4_);
                  _loc3_ = new MessageOfTheDay(_loc5_.layout_type,_loc5_.headline,_loc5_.body,_loc5_.image_url,_loc2_,getWhatsNewCallback(_loc4_),_loc5_.web_link_name,_loc5_.web_link_url);
                  mNewsStories.push(_loc3_);
               }
               if(mNewsStories.length > 0)
               {
                  displayNews(0);
               }
               if(callback != null)
               {
                  callback(true);
               }
            }
            else if(callback != null)
            {
               callback(false);
            }
            mNewsTotalPages = mNewsStories.length;
         };
         rpcFunc(platformParameter,parseResults);
      }
      
      private function createNewsUI() : void
      {
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),function(param1:SwfAsset):void
         {
            var _loc2_:Class = param1.getClass("pagination_fm");
            mNewsPagination = new UIPagingPanel(mDBFacade,mNewsTotalPages,new _loc2_() as MovieClip,param1.getClass("pagination_button"),setCurrentNewsPage);
            MemoryTracker.track(mNewsPagination,"UIPagingPanel - created in HomeState.showNewsStories()");
            if(mNewsStories.length > 0)
            {
               displayNews(0,true);
            }
         });
      }
      
      private function displayNews(newsNum:uint, showPagination:Boolean = false) : void
      {
         var paginationEmptyMC:MovieClip;
         var parentPos:Point;
         var layoutClassName:String;
         if(mNewsStories[newsNum].imageType == 2)
         {
            mNewsPopUp = new DBUIMoviePopup(mDBFacade,"whatsnew_popup_movie",mNewsStories[newsNum].title,mNewsStories[newsNum].message,mNewsStories[newsNum].imageURL + "?version=3&rel=0",mNewsStories[newsNum].mainText,function():void
            {
               if(mNewsStories[newsNum].mainCallback != null)
               {
                  mNewsStories[newsNum].mainCallback();
               }
               if(showPagination)
               {
                  mNewsPagination.destroy();
                  mNewsPagination = null;
               }
            },426,240,showPagination);
            MemoryTracker.track(mNewsPopUp,"DBUIMoviePopup - created in HomeState.displayNews()");
            if(showPagination)
            {
               paginationEmptyMC = mNewsPopUp.getPagination();
               paginationEmptyMC.addChild(mNewsPagination.root);
            }
         }
         else
         {
            layoutClassName = mNewsStories[newsNum].imageType == 0 ? "whatsnew_popup" : "whatsnew_popup_landscape";
            mNewsPopUp = new UIWhatsNewPopup(mDBFacade,layoutClassName,mNewsStories[newsNum].title,mNewsStories[newsNum].message,mNewsStories[newsNum].imageURL,mNewsStories[newsNum].mainText,function():void
            {
               if(mNewsStories[newsNum].mainCallback != null)
               {
                  mNewsStories[newsNum].mainCallback();
               }
               if(showPagination)
               {
                  mNewsPagination.destroy();
                  mNewsPagination = null;
               }
            },mNewsStories[newsNum].webText,mNewsStories[newsNum].webURL,showPagination);
            MemoryTracker.track(mNewsPopUp,"UIWhatsNewPopup - created in HomeState.displayNews()");
            if(showPagination)
            {
               paginationEmptyMC = mNewsPopUp.getPagination();
               paginationEmptyMC.addChild(mNewsPagination.root);
            }
         }
      }
      
      private function refreshPagination(page:uint) : void
      {
         mNewsPagination.currentPage = mNewsTotalPages ? Math.min(mNewsTotalPages - 1,page) : 0;
         mNewsPagination.numPages = mNewsTotalPages;
         mNewsPagination.visible = true;
      }
      
      private function setCurrentNewsPage(page:uint) : void
      {
         mNewsCurrentPage = page;
         refreshPagination(page);
         if(mNewsPopUp)
         {
            mNewsPopUp.destroy();
            mNewsPopUp = null;
         }
         displayNews(page,true);
      }
      
      private function tryShowRewardPopup(rewardOfferId:uint) : void
      {
         var offer:GMOffer;
         mDBFacade.mainStateMachine.showedRewardPopup = true;
         offer = mDBFacade.gameMaster.offerById.itemFor(rewardOfferId);
         if(!offer)
         {
            return;
         }
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),function(param1:SwfAsset):void
         {
            var centerCloseButton:UIButton;
            var topCloseButton:UIButton;
            var curtain:Sprite;
            var swfAsset:SwfAsset = param1;
            var rewardPopupClass:Class = swfAsset.getClass("rewards_popup");
            var rewardPopup:MovieClip = new rewardPopupClass();
            Locale.setText(rewardPopup.title_label,"REWARD_POPUP_TITLE");
            Locale.setText(rewardPopup.header_label,"REWARD_POPUP_HEADER");
            TextUtil.setText(rewardPopup.description_label,offer.getDisplayName(mDBFacade.gameMaster));
            centerCloseButton = new UIButton(mDBFacade,rewardPopup.close_button);
            topCloseButton = new UIButton(mDBFacade,rewardPopup.close);
            Locale.setText(centerCloseButton.label,"REWARD_POPUP_BUTTON");
            centerCloseButton.releaseCallback = topCloseButton.releaseCallback = function():void
            {
               UILevelUpPostController.removeCurtain(curtain,mSceneGraphComponent);
               mSceneGraphComponent.removeChild(rewardPopup);
               rewardPopup = null;
            };
            if(offer.BundleSwfFilepath && offer.BundleIcon)
            {
               mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(offer.BundleSwfFilepath),function(param1:SwfAsset):void
               {
                  var _loc3_:Class = param1.getClass(offer.BundleIcon);
                  var _loc2_:MovieClip = new _loc3_();
                  _loc2_.scaleX = _loc2_.scaleY = 0.66;
                  rewardPopup.icon.addChild(_loc2_);
               });
            }
            curtain = UILevelUpPostController.makeCurtain(mDBFacade,mSceneGraphComponent);
            mSceneGraphComponent.addChild(rewardPopup,105);
         });
      }
      
      private function tryShowRewardErrorPopup(rewardErrorCode:String) : void
      {
         var rewardErrorDescription:String;
         mDBFacade.mainStateMachine.showedRewardPopup = true;
         rewardErrorDescription = Locale.getError(int(rewardErrorCode));
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),function(param1:SwfAsset):void
         {
            var closeButton:UIButton;
            var closeButton2:UIButton;
            var curtain:Sprite;
            var helpURL:String;
            var helpButton:UIButton;
            var swfAsset:SwfAsset = param1;
            var errorPopupClass:Class = swfAsset.getClass("reward_errors_popup");
            var errorPopup:MovieClip = new errorPopupClass();
            Locale.setText(errorPopup.title_label,"REWARD_ERROR_POPUP_TITLE_" + rewardErrorCode);
            TextUtil.setText(errorPopup.message_label,rewardErrorDescription);
            Locale.setText(errorPopup.question_label,"REWARD_ERROR_POPUP_HELP");
            closeButton = new UIButton(mDBFacade,errorPopup.button);
            closeButton2 = new UIButton(mDBFacade,errorPopup.close);
            Locale.setText(closeButton.label,"REWARD_ERROR_POPUP_CLOSE");
            closeButton2.releaseCallback = closeButton.releaseCallback = function():void
            {
               UILevelUpPostController.removeCurtain(curtain,mSceneGraphComponent);
               mSceneGraphComponent.removeChild(errorPopup);
               errorPopup = null;
            };
            helpURL = "http://help.dungeonrampage.com/";
            helpButton = new UIButton(mDBFacade,errorPopup.help);
            helpButton.releaseCallback = function():void
            {
               var _loc1_:URLRequest = new URLRequest(helpURL);
               navigateToURL(_loc1_,"_blank");
            };
            curtain = UILevelUpPostController.makeCurtain(mDBFacade,mSceneGraphComponent);
            mSceneGraphComponent.addChild(errorPopup,105);
         });
      }
      
      private function setUpHacksToRecalculateWeaponPowers() : void
      {
         EventListeners.add(mDBFacade.stageRef,"keyDown",hackToHandleKeyPressToRecalculateWeaponPowers);
      }
      
      private function tearDownHacksToRecalculateWeaponPowers() : void
      {
         EventListeners.remove(mDBFacade.stageRef,"keyDown",hackToHandleKeyPressToRecalculateWeaponPowers);
      }
      
      private function hackToHandleKeyPressToRecalculateWeaponPowers(e:KeyboardEvent) : void
      {
      }
      
      private function TryShowDragonKnightPopup() : Boolean
      {
         return UIDragonKnightUpsellPopup.ShouldDisplayDragonKnightUpsell(mDBFacade);
      }
      
      override public function enterState() : void
      {
         super.enterState();
         if(mDBFacade.dbConfigManager.getConfigBoolean("ALLOW_HACKS_TO_RECALCULATE_WEAPON_POWERS",false))
         {
            setUpHacksToRecalculateWeaponPowers();
         }
         TrickleCacheLoader.queueCommonStarlingAtlases(mDBFacade);
         mRenderer.play(0,true);
         mUILeaderboard = mTownStateMachine.leaderboard;
         if(mUILeaderboard)
         {
            mUILeaderboard.setRootMovieClip(mRootMovieClip);
            mUILeaderboard.currentStateName = "HomeState";
            mUILeaderboard.hidePopup();
         }
         mTownStateMachine.townHeader.title = Locale.getString("TOWN_HEADER");
         mTownStateMachine.townHeader.inHomeState = true;
         mTownStateMachine.townHeader.showCloseButton(true);
         mEventComponent.addListener("DB_ACCOUNT_INFO_RESPONSE",function(param1:DBAccountResponseEvent):void
         {
            refreshAlerts();
         });
         this.refreshAlerts();
         this.refreshColiseumLock();
         mEventComponent.dispatchEvent(new XPBonusEvent("XP_BONUS_EVENT",false));
         animateEntry();
         if(mDBFacade && mDBFacade.hud && mDBFacade.hud.chatLog)
         {
            mDBFacade.hud.chatLog.hideChatLog();
         }
         if(mPopupDelayTask)
         {
            mPopupDelayTask.destroy();
         }
         mPopupDelayTask = mLogicalWorkComponent.doLater(0.5,showPopups);
         refreshHeaderNavigationLinks();
         if(mOptionsKeyTask)
         {
            mOptionsKeyTask.destroy();
         }
         mOptionsKeyTask = mLogicalWorkComponent.doEveryFrame(checkOptionsKey);
         mEventComponent.addListener("OnSteamInputButtonReleasedEvent",onSteamInputButtonReleased);
      }
      
      private function showPopups(gameClock:GameClock = null) : void
      {
         var flaggedPopupClass:UIFlaggedPopup;
         var dkPopupClass:UIDragonKnightUpsellPopup;
         var rewardOfferId:uint = uint(mDBFacade.dbConfigManager.getConfigString("RewardOfferId","0"));
         var rewardErrorCode:String = mDBFacade.dbConfigManager.getConfigString("RewardErrorMessage","");
         if(mDBFacade.mSteamIsFlagged && !mDBFacade.mSeenFlaggedPopup)
         {
            mDBFacade.mSeenFlaggedPopup = true;
            flaggedPopupClass = new UIFlaggedPopup(mDBFacade,mDBFacade.mSteamIsFlaggedDueToFamilySharingOwnerIsFlagged,mDBFacade.mSteamIsFlaggedDueToFamilySharingOwnerName,mDBFacade.mSteamFlaggedUntilAfterDateString);
            MemoryTracker.track(flaggedPopupClass,"UIFlaggedPopup - created in HomeState.showPopups()");
         }
         if(rewardOfferId != 0 && !mDBFacade.mainStateMachine.showedRewardPopup)
         {
            this.tryShowRewardPopup(rewardOfferId);
         }
         else if(rewardErrorCode != "" && !mDBFacade.mainStateMachine.showedRewardPopup)
         {
            this.tryShowRewardErrorPopup(rewardErrorCode);
         }
         else if(TryShowDragonKnightPopup())
         {
            dkPopupClass = new UIDragonKnightUpsellPopup(mDBFacade);
            MemoryTracker.track(dkPopupClass,"UIDragonKnightUpsellPopup - created in HomeState.showPopups()");
         }
         else
         {
            this.tryShowWhatsNewPopup(function(param1:Boolean):void
            {
               if(!param1 && mDBFacade)
               {
                  tryShowBetaRewardsPopup();
               }
            });
         }
      }
      
      public function loadActiveAvatarIcon(event:Event) : void
      {
         var gmSkin:GMSkin;
         var mActiveAvatar:AvatarInfo = mDBFacade.dbAccountInfo.activeAvatarInfo;
         if(!mActiveAvatar)
         {
            return;
         }
         gmSkin = mDBFacade.gameMaster.getSkinByType(mActiveAvatar.skinId);
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(gmSkin.UISwfFilepath),function(param1:SwfAsset):void
         {
            var _loc4_:Class = param1.getClass(gmSkin.IconName);
            var _loc5_:MovieClip = mRootMovieClip.townScreen_tavern_button_instance.up.avatar;
            var _loc2_:MovieClip = mRootMovieClip.townScreen_tavern_button_instance.over.avatar;
            var _loc3_:DisplayObject = _loc5_.getChildByName("avatarPic");
            if(_loc3_)
            {
               _loc5_.removeChild(_loc3_);
            }
            _loc3_ = _loc2_.getChildByName("avatarPic");
            if(_loc3_)
            {
               _loc2_.removeChild(_loc3_);
            }
            if(_loc4_)
            {
               _loc3_ = new _loc4_();
               _loc3_.name = "avatarPic";
               _loc5_.addChild(_loc3_);
               _loc3_ = new _loc4_();
               _loc3_.name = "avatarPic";
               _loc2_.addChild(_loc3_);
            }
         });
      }
      
      override public function exitState() : void
      {
         mTownStateMachine.townHeader.inHomeState = false;
         if(mDBFacade.dbConfigManager.getConfigBoolean("ALLOW_HACKS_TO_RECALCULATE_WEAPON_POWERS",false))
         {
            tearDownHacksToRecalculateWeaponPowers();
         }
         if(mPopupDelayTask)
         {
            mPopupDelayTask.destroy();
            mPopupDelayTask = null;
         }
         if(mOptionsKeyTask)
         {
            mOptionsKeyTask.destroy();
            mOptionsKeyTask = null;
         }
         mRenderer.stop();
         mEventComponent.removeListener("DB_ACCOUNT_INFO_RESPONSE");
         mEventComponent.removeListener("OnSteamInputButtonReleasedEvent");
         super.exitState();
      }
      
      public function get leaderboard() : UILeaderboard
      {
         return mUILeaderboard;
      }
      
      private function get tavernNeedsAttention() : Boolean
      {
         return false;
      }
      
      private function get trainingNeedsAttention() : Boolean
      {
         var _loc1_:AvatarInfo = mDBFacade.dbAccountInfo.activeAvatarInfo;
         return _loc1_ != null && _loc1_.skillPointsAvailable > 0;
      }
      
      private function get skillsNeedsAttention() : Boolean
      {
         var _loc2_:AvatarInfo = null;
         var _loc4_:Map = mDBFacade.dbAccountInfo.inventoryInfo.avatars;
         if(!_loc4_)
         {
            return false;
         }
         var _loc1_:Array = _loc4_.keysToArray();
         for each(var _loc3_ in _loc1_)
         {
            _loc2_ = _loc4_.itemFor(_loc3_) as AvatarInfo;
            if(_loc2_ && _loc2_.canAscend)
            {
               return true;
            }
         }
         return false;
      }
      
      private function get inventoryNeedsAttention() : Boolean
      {
         return mDBFacade.dbAccountInfo.inventoryInfo.hasNewEquippableItems;
      }
      
      private function get shopNeedsAttention() : Boolean
      {
         return false;
      }
      
      public function getGifts() : void
      {
         mDBFacade.dbAccountInfo.getGiftData(checkGiftAlert);
      }
      
      private function get giftNeedsAttention() : Boolean
      {
         if(mDBFacade.dbAccountInfo.gifts.size > 0)
         {
            return true;
         }
         return false;
      }
      
      private function checkGiftAlert() : void
      {
         if(!mDBFacade)
         {
            return;
         }
         mGiftAlertUp.visible = mGiftAlertOver.visible = this.giftNeedsAttention;
      }
      
      private function giftPopupCloseCallback() : void
      {
         mGiftButton.enabled = true;
         checkGiftAlert();
         mGiftPopup = null;
      }
      
      private function checkRewardAlert() : void
      {
         if(!mDBFacade)
         {
            return;
         }
      }
      
      private function rewardPopupCloseCallback() : void
      {
         if(mRewardButton != null)
         {
            mRewardButton.enabled = true;
         }
         EventListeners.add(mDBFacade.stageRef,"keyDown",openDaily);
         checkRewardAlert();
         mDailyRewardsPopup = null;
      }
      
      private function giftCallbackToFriendManager() : void
      {
         mGiftPopup.destroy();
         mGiftPopup = null;
         mTownStateMachine.setFriendManagementTabCategory(1);
         mTownStateMachine.enterFriendManagementState();
      }
   }
}

