package Town
{
   import Account.AvatarInfo;
   import Account.StoreServicesController;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Clock.GameClock;
   import Brain.Event.EventComponent;
   import Brain.Logger.Logger;
   import Brain.Render.MovieClipRenderController;
   import Brain.UI.UIButton;
   import Brain.Utils.MemoryTracker;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Brain.WorkLoop.Task;
   import Brain.jsonRPC.JSONRPCService;
   import Events.DBAccountResponseEvent;
   import Events.XPBonusEvent;
   import Facade.DBFacade;
   import Facade.Locale;
   import Facade.TrickleCacheLoader;
   import FacebookAPI.DBFacebookLevelUpPostController;
   import GameMasterDictionary.GMOffer;
   import GameMasterDictionary.GMSkin;
   import UI.DailyRewards.UIDailyRewards;
   import UI.Gifting.UIGift;
   import UI.Leaderboard.UILeaderboard;
   import UI.Options.OptionsPanel;
   import UI.Popup.DBUIMoviePopup;
   import UI.Popup.DBUIOneButtonPopup;
   import UI.Popup.DBUIPopup;
   import UI.Popup.UIDragonKnightUpsellPopup;
   import UI.Popup.UIFBInvitePopup;
   import UI.Popup.UIFlaggedPopup;
   import UI.Popup.UIHeroUpsellPopup;
   import UI.Popup.UILevelUpShopPopup;
   import UI.Popup.UIWhatsNewPopup;
   import UI.UIPagingPanel;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.geom.Point;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import org.as3commons.collections.Set;
   import org.as3commons.collections.framework.IMapIterator;
   
   public class HomeState extends TownSubState
   {
      
      public static const NAME:String = "HomeState";
      
      public static const ACTIVE_AVATAR_CHANGED_EVENT:String = "ACTIVE_AVATAR_CHANGED_EVENT";
      
      private static const MIN_FRIENDS_TO_AVOID_INVITE_POPUP:uint = 4;
      
      private static const MAX_INVITE_POPUPS:uint = 2;
      
      private static const MAX_HERO_UPSELL_POPUPS:uint = 8;
      
      private static const POPUP_DELAY_TIME:Number = 0.5;
      
      private static const DELAY_AMOUNT_FOR_FRIEND_LEADERBOARD_NAVIGATION_LOAD:uint = 2;
      
      public static var mHasPonderedMOD:Boolean = false;
      
      protected var mBattleButton:UIButton;
      
      protected var mTavernButton:UIButton;
      
      protected var mInventoryButton:UIButton;
      
      protected var mSkillsButton:UIButton;
      
      protected var mTrainButton:UIButton;
      
      protected var mShopButton:UIButton;
      
      protected var mGiftButton:UIButton;
      
      protected var mRewardButton:UIButton;
      
      protected var mNewsButton:UIButton;
      
      protected var mCreditsButton:UIButton;
      
      protected var mOptionsButton:UIButton;
      
      protected var mOptionsPanel:OptionsPanel;
      
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
      
      protected var mUILeaderboard:UILeaderboard;
      
      private var mFriendLeaderboardDelayMenuNavigationLinkageTask:Task;
      
      private var mHeroTypesLazilyLoaded:Set;
      
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
         mOptionsPanel = new OptionsPanel(mDBFacade);
         MemoryTracker.track(mOptionsPanel,"OptionsPanel - created in HomeState.HomeState()");
         mHeroTypesLazilyLoaded = new Set();
         mNewsStories = new Vector.<MessageOfTheDay>();
      }
      
      override public function destroy() : void
      {
         mDBFacade.stageRef.removeEventListener("keyDown",openDaily);
         if(mDailyRewardsPopup != null)
         {
            mDailyRewardsPopup.destroy();
            mDailyRewardsPopup = null;
         }
         mRenderer.destroy();
         mBattleButton.destroy();
         mTavernButton.destroy();
         mInventoryButton.destroy();
         mTrainButton.destroy();
         mShopButton.destroy();
         mGiftButton.destroy();
         mCreditsButton.destroy();
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
         mOptionsPanel.destroy();
         mOptionsPanel = null;
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
         mRootMovieClip.townScreen_inventory_button_instance.up.label.text = Locale.getString("INVENTORY_BUILDING");
         mRootMovieClip.townScreen_inventory_button_instance.over.label.text = Locale.getString("INVENTORY_BUILDING");
         mInventoryAlertUp = mRootMovieClip.townScreen_inventory_button_instance.up.alert_icon;
         mInventoryAlertOver = mRootMovieClip.townScreen_inventory_button_instance.over.alert_icon;
         mInventoryAlertUp.visible = false;
         mInventoryAlertOver.visible = false;
         mTavernButton = new UIButton(mDBFacade,mRootMovieClip.townScreen_tavern_button_instance);
         mTavernButton.releaseCallback = mTownStateMachine.enterTavernState;
         mRootMovieClip.townScreen_tavern_button_instance.up.label.text = Locale.getString("TAVERN_BUILDING");
         mRootMovieClip.townScreen_tavern_button_instance.over.label.text = Locale.getString("TAVERN_BUILDING");
         mTavernAlertUp = mRootMovieClip.townScreen_tavern_button_instance.up.alert_icon;
         mTavernAlertOver = mRootMovieClip.townScreen_tavern_button_instance.over.alert_icon;
         mTavernAlertUp.visible = false;
         mTavernAlertOver.visible = false;
         mTrainButton = new UIButton(mDBFacade,mRootMovieClip.townScreen_train_button_instance);
         mTrainButton.releaseCallback = mTownStateMachine.enterTrainState;
         mRootMovieClip.townScreen_train_button_instance.up.label.text = Locale.getString("TRAINING_BUILDING");
         mRootMovieClip.townScreen_train_button_instance.over.label.text = Locale.getString("TRAINING_BUILDING");
         mTrainAlertUp = mRootMovieClip.townScreen_train_button_instance.up.alert_icon;
         mTrainAlertOver = mRootMovieClip.townScreen_train_button_instance.over.alert_icon;
         mTrainAlertUp.visible = false;
         mTrainAlertOver.visible = false;
         mCreditsButton = new UIButton(mDBFacade,mRootMovieClip.news);
         mCreditsButton.releaseCallback = mTownStateMachine.enterCreditState;
         mRootMovieClip.news.up.credit_mc.label.text = Locale.getString("CREDITS_BUILDING");
         mRootMovieClip.news.over.credit_mc.label.text = Locale.getString("CREDITS_BUILDING");
         mRootMovieClip.townScreen_shop_button_sale_instance.visible = false;
         mShopButton = new UIButton(mDBFacade,mRootMovieClip.townScreen_shop_button_instance);
         mShopButton.releaseCallback = mTownStateMachine.enterShopState;
         mRootMovieClip.townScreen_shop_button_instance.up.label.text = Locale.getString("SHOP_BUILDING");
         mRootMovieClip.townScreen_shop_button_instance.over.label.text = Locale.getString("SHOP_BUILDING");
         mShopAlertUp = mRootMovieClip.townScreen_shop_button_instance.up.alert_icon;
         mShopAlertOver = mRootMovieClip.townScreen_shop_button_instance.over.alert_icon;
         mShopAlertUp.visible = false;
         mShopAlertOver.visible = false;
         mShopNewUp = mRootMovieClip.townScreen_shop_button_instance.up.new_icon;
         mShopNewOver = mRootMovieClip.townScreen_shop_button_instance.over.new_icon;
         mGiftButton = new UIButton(mDBFacade,mRootMovieClip.gift);
         if(mDBFacade.dbConfigManager.getConfigBoolean("FUFB",false))
         {
            mGiftButton.releaseCallback = function():void
            {
               mDBFacade.errorPopup("GIFTING CURRENTLY DISABLED","Sorry for the inconvenience, we are looking into resolving the issue.");
            };
         }
         else
         {
            mGiftButton.releaseCallback = function():void
            {
               mGiftPopup = new UIGift(mDBFacade,mRootMovieClip,giftPopupCloseCallback,giftCallbackToFriendManager);
               mGiftButton.enabled = false;
            };
         }
         mDBFacade.stageRef.addEventListener("keyDown",openDaily);
         if(mDBFacade.mCheckedDailyReward == false)
         {
            mDBFacade.mCheckedDailyReward = true;
            mDailyRewardsPopup = new UIDailyRewards(mDBFacade,rewardPopupCloseCallback,false);
         }
         mRootMovieClip.gift.up.label.text = Locale.getString("GIFT_BUILDING");
         mRootMovieClip.gift.over.label.text = Locale.getString("GIFT_BUILDING");
         mGiftAlertUp = mRootMovieClip.gift.up.alert_icon;
         mGiftAlertOver = mRootMovieClip.gift.over.alert_icon;
         mGiftAlertUp.visible = false;
         mGiftAlertOver.visible = false;
         mOptionsButton = new UIButton(mDBFacade,mRootMovieClip.options_button);
         mOptionsButton.releaseCallback = mOptionsPanel.toggleVisible;
         mRenderer = new MovieClipRenderController(mDBFacade,mRootMovieClip);
         loadActiveAvatarIcon(new Event("ACTIVE_AVATAR_CHANGED_EVENT"));
         mEventComponent.addListener("ACTIVE_AVATAR_CHANGED_EVENT",loadActiveAvatarIcon);
         this.refreshAlerts();
         mTavernButton.isToTheLeftOf(mBattleButton);
         mTavernButton.isAbove(mGiftButton);
         mBattleButton.isToTheLeftOf(mInventoryButton);
         mBattleButton.isAbove(mShopButton);
         mInventoryButton.isAbove(mCreditsButton);
         mGiftButton.isToTheLeftOf(mTrainButton);
         mTrainButton.isToTheLeftOf(mShopButton);
         mShopButton.isToTheLeftOf(mCreditsButton);
         setupHeaderLinks();
         mDBFacade.menuNavigationController.pushNewLayer("TOWN_MENU",mTownStateMachine.townHeader.determineCallback,mBattleButton,mBattleButton);
         if(mFriendLeaderboardDelayMenuNavigationLinkageTask)
         {
            mFriendLeaderboardDelayMenuNavigationLinkageTask.destroy();
         }
         mFriendLeaderboardDelayMenuNavigationLinkageTask = mLogicalWorkComponent.doLater(2,setupFriendLinks);
      }
      
      public function setupFriendLinks(gameClock:GameClock = null) : void
      {
         mTrainButton.isAbove(mUILeaderboard.getManageFriendsButton);
         mShopButton.isAbove(mUILeaderboard.getInviteFriendsButton);
      }
      
      override protected function setupHeaderLinks() : void
      {
         super.resetHeaderLinks();
         super.setupHeaderLinks();
         mTownStateMachine.townHeader.addCoinButton.isAbove(mTavernButton);
         mTownStateMachine.townHeader.addGemButton.isAbove(mBattleButton);
         mTownStateMachine.townHeader.closeButton.isAbove(mInventoryButton);
      }
      
      private function refreshHeaderNavigationLinks() : void
      {
         super.resetHeaderLinks();
         super.setupHeaderLinks();
         mTownStateMachine.townHeader.addCoinButton.downNavigation = mTavernButton;
         mTownStateMachine.townHeader.addGemButton.downNavigation = mBattleButton;
         mTownStateMachine.townHeader.closeButton.downNavigation = mInventoryButton;
      }
      
      private function openDaily(event:KeyboardEvent) : void
      {
         if(event.keyCode == 36 && mDBFacade != null)
         {
            mDailyRewardsPopup = new UIDailyRewards(mDBFacade,rewardPopupCloseCallback,true);
            mDBFacade.stageRef.removeEventListener("keyDown",openDaily);
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
      
      private function refreshAlerts() : void
      {
         var _loc2_:Boolean = false;
         var _loc1_:Boolean = false;
         if(mRootMovieClip)
         {
            mTavernAlertUp.visible = mTavernAlertOver.visible = this.tavernNeedsAttention;
            mTrainAlertUp.visible = mTrainAlertOver.visible = this.trainingNeedsAttention;
            mShopAlertUp.visible = mShopAlertOver.visible = this.shopNeedsAttention;
            mInventoryAlertUp.visible = mInventoryAlertOver.visible = this.inventoryNeedsAttention;
            if(!mDBFacade.isKongregatePlayer)
            {
               checkGiftAlert();
            }
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
               var popup:DBUIOneButtonPopup = new DBUIOneButtonPopup(mDBFacade,Locale.getString("BETA_REWARDS_POPUP_TITLE"),Locale.getString("BETA_REWARDS_POPUP_MESSAGE"),Locale.getString("BETA_REWARDS_POPUP_BUTTON"),function():void
               {
               },true,null,"popup_beta_thanks");
               MemoryTracker.track(popup,"DBUIOneButtonPopup - created in HomeState.tryShowBetaRewardsPopup()");
            });
            mDBFacade.dbAccountInfo.dbAccountParams.setBetaRewardsParam();
            return true;
         }
         return false;
      }
      
      private function tryShowKeyMessagePopup() : Boolean
      {
         if(mDBFacade.dbAccountInfo.dbAccountParams.hasKeyIntroParam())
         {
            return false;
         }
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),function(param1:SwfAsset):void
         {
            var swfAsset:SwfAsset = param1;
            var popup:DBUIOneButtonPopup = new DBUIOneButtonPopup(mDBFacade,Locale.getString("BETA_KEYS_POPUP_TITLE"),Locale.getString("BETA_KEYS_POPUP_MESSAGE"),Locale.getString("BETA_KEYS_POPUP_BUTTON"),function():void
            {
            },true,null,"popup_beta_keys");
            MemoryTracker.track(popup,"DBUIOneButtonPopup - created in HomeState.tryShowKeyMessagePopup()");
         });
         mDBFacade.dbAccountInfo.dbAccountParams.setKeyIntroParam();
         return true;
      }
      
      private function tryShowHeroUpsellPopup() : Boolean
      {
         var _loc4_:* = 0;
         var _loc6_:GMOffer = null;
         if(!mDBFacade.getSplitTestBoolean("HeroUpsellPopups",false))
         {
            return false;
         }
         var _loc1_:uint = uint(mDBFacade.dbAccountInfo.getAttribute("HERO_UPSELL_POPUP"));
         if(_loc1_ >= 8)
         {
            return false;
         }
         if(mDBFacade.mainStateMachine.showedHeroUpsellPopup)
         {
            return false;
         }
         var _loc3_:Vector.<GMOffer> = new Vector.<GMOffer>();
         for each(var _loc5_:uint in StoreServicesController.HERO_OFFERS)
         {
            _loc6_ = mDBFacade.gameMaster.offerById.itemFor(_loc5_);
            _loc4_ = _loc6_.Details[0].HeroId;
            if(!mDBFacade.dbAccountInfo.inventoryInfo.ownsItem(_loc4_))
            {
               _loc3_.push(_loc6_);
            }
         }
         if(_loc3_.length == 0)
         {
            return false;
         }
         var _loc7_:uint = _loc1_ % _loc3_.length;
         var _loc8_:GMOffer = _loc3_[_loc7_];
         var _loc2_:UIHeroUpsellPopup = new UIHeroUpsellPopup(mTownStateMachine.townHeader,mDBFacade,_loc8_,null);
         MemoryTracker.track(_loc2_,"UIHeroUpsellPopup - created in HomeState.tryShowHeroUpsellPopup()");
         mDBFacade.mainStateMachine.showedHeroUpsellPopup = true;
         mDBFacade.dbAccountInfo.alterAttribute("HERO_UPSELL_POPUP",String(_loc1_ + 1));
         return true;
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
         if(mNewsStories[newsNum].type == 2)
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
            layoutClassName = mNewsStories[newsNum].type == 0 ? "whatsnew_popup" : "whatsnew_popup_landscape";
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
      
      private function tryShowLevelUpShopPopup() : Boolean
      {
         var gmOffers:Vector.<GMOffer>;
         var popup:UILevelUpShopPopup;
         var leveled:Boolean = mDBFacade.mainStateMachine.markHasHeroLeveledUp();
         if(!leveled)
         {
            return false;
         }
         gmOffers = UILevelUpShopPopup.getLevelUpWeaponUnlocks(mDBFacade,mDBFacade.dbAccountInfo.activeAvatarInfo);
         if(gmOffers.length == 0)
         {
            return false;
         }
         popup = new UILevelUpShopPopup(mDBFacade,function():void
         {
            mTownStateMachine.enterShopState(false,"WEAPON");
         },mDBFacade.dbAccountInfo.activeAvatarInfo,gmOffers);
         MemoryTracker.track(popup,"UILevelUpShopPopup - created in HomeState.tryShowLevelUpPopup()");
         return true;
      }
      
      private function shouldShowInvitePopup() : Boolean
      {
         if(!mDBFacade.isFacebookPlayer)
         {
            return false;
         }
         var _loc2_:Number = mDBFacade.getSplitTestNumber("MaxInvitePopups",2);
         if(_loc2_ == 0)
         {
            return false;
         }
         var _loc1_:uint = uint(mDBFacade.dbAccountInfo.getAttribute("INVITE_POPUP"));
         if(mDBFacade.mainStateMachine.showedInvitePopup)
         {
            return false;
         }
         if(_loc1_ == 0)
         {
            return true;
         }
         if(_loc1_ >= _loc2_)
         {
            return false;
         }
         if(mDBFacade.dbAccountInfo.friendInfos.size >= 4)
         {
            return false;
         }
         return true;
      }
      
      private function tryShowInvitePopup() : Boolean
      {
         var _loc2_:UIFBInvitePopup = null;
         var _loc1_:* = 0;
         if(this.shouldShowInvitePopup())
         {
            _loc2_ = new UIFBInvitePopup(mDBFacade,mDBFacade.facebookController.genericFriendRequests);
            MemoryTracker.track(_loc2_,"UIFBInvitePopup - created in HomeState.tryShowInvitePopup()");
            mDBFacade.mainStateMachine.showedInvitePopup = true;
            _loc1_ = uint(mDBFacade.dbAccountInfo.getAttribute("INVITE_POPUP"));
            mDBFacade.dbAccountInfo.alterAttribute("INVITE_POPUP",String(_loc1_ + 1));
            return true;
         }
         return false;
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
            rewardPopup.title_label.text = Locale.getString("REWARD_POPUP_TITLE");
            rewardPopup.header_label.text = Locale.getString("REWARD_POPUP_HEADER");
            rewardPopup.description_label.text = offer.getDisplayName(mDBFacade.gameMaster);
            centerCloseButton = new UIButton(mDBFacade,rewardPopup.close_button);
            topCloseButton = new UIButton(mDBFacade,rewardPopup.close);
            centerCloseButton.label.text = Locale.getString("REWARD_POPUP_BUTTON");
            centerCloseButton.releaseCallback = topCloseButton.releaseCallback = function():void
            {
               DBFacebookLevelUpPostController.removeCurtain(curtain,mSceneGraphComponent);
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
            curtain = DBFacebookLevelUpPostController.makeCurtain(mDBFacade,mSceneGraphComponent);
            mSceneGraphComponent.addChild(rewardPopup,105);
         });
      }
      
      private function tryShowRewardErrorPopup(rewardErrorCode:String) : void
      {
         var rewardErrorTitle:String;
         var rewardErrorClose:String;
         var rewardErrorHelp:String;
         var rewardErrorDescription:String;
         mDBFacade.mainStateMachine.showedRewardPopup = true;
         rewardErrorTitle = Locale.getString("REWARD_ERROR_POPUP_TITLE_" + rewardErrorCode);
         rewardErrorClose = Locale.getString("REWARD_ERROR_POPUP_CLOSE");
         rewardErrorHelp = Locale.getString("REWARD_ERROR_POPUP_HELP");
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
            errorPopup.title_label.text = rewardErrorTitle;
            errorPopup.message_label.text = rewardErrorDescription;
            errorPopup.question_label.text = rewardErrorHelp;
            closeButton = new UIButton(mDBFacade,errorPopup.button);
            closeButton2 = new UIButton(mDBFacade,errorPopup.close);
            closeButton.label.text = rewardErrorClose;
            closeButton2.releaseCallback = closeButton.releaseCallback = function():void
            {
               DBFacebookLevelUpPostController.removeCurtain(curtain,mSceneGraphComponent);
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
            curtain = DBFacebookLevelUpPostController.makeCurtain(mDBFacade,mSceneGraphComponent);
            mSceneGraphComponent.addChild(errorPopup,105);
         });
      }
      
      private function setUpHacksToRecalculateWeaponPowers() : void
      {
         mDBFacade.stageRef.addEventListener("keyDown",hackToHandleKeyPressToRecalculateWeaponPowers);
      }
      
      private function tearDownHacksToRecalculateWeaponPowers() : void
      {
         mDBFacade.stageRef.removeEventListener("keyDown",hackToHandleKeyPressToRecalculateWeaponPowers);
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
         lazyLoadActiveAvatar();
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
               var _loc2_:Boolean = false;
               if(!param1 && mDBFacade)
               {
                  _loc2_ = tryShowInvitePopup();
                  if(!_loc2_)
                  {
                     if(!tryShowHeroUpsellPopup())
                     {
                        tryShowBetaRewardsPopup();
                     }
                  }
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
         if(mFriendLeaderboardDelayMenuNavigationLinkageTask)
         {
            mFriendLeaderboardDelayMenuNavigationLinkageTask.destroy();
            mFriendLeaderboardDelayMenuNavigationLinkageTask = null;
         }
         mRenderer.stop();
         mEventComponent.removeListener("DB_ACCOUNT_INFO_RESPONSE");
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
         var _loc1_:AvatarInfo = null;
         var _loc2_:IMapIterator = mDBFacade.dbAccountInfo.inventoryInfo.avatars.iterator() as IMapIterator;
         while(_loc2_.hasNext())
         {
            _loc1_ = _loc2_.next();
            if(_loc1_.skillPointsAvailable > 0)
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
         mDBFacade.stageRef.addEventListener("keyDown",openDaily);
         checkRewardAlert();
         mDailyRewardsPopup = null;
      }
      
      private function giftCallbackToFriendManager() : void
      {
         mTownStateMachine.setFriendManagementTabCategory(1);
         mTownStateMachine.enterFriendManagementState();
         mGiftPopup.destroy();
         mGiftPopup = null;
      }
      
      private function lazyLoadActiveAvatar() : void
      {
         var _loc1_:uint = mDBFacade.dbAccountInfo.activeAvatarInfo.skinId;
         if(!mHeroTypesLazilyLoaded.has(_loc1_))
         {
            TrickleCacheLoader.loadHero(mDBFacade,_loc1_);
            mHeroTypesLazilyLoaded.add(_loc1_);
         }
      }
   }
}

