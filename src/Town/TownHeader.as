package Town
{
   import Account.BoosterInfo;
   import Account.CurrencyUpdatedAccountEvent;
   import Account.DBAccountInfo;
   import Account.DBInventoryInfo;
   import Account.StoreServicesController;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Clock.GameClock;
   import Brain.Event.EventComponent;
   import Brain.SceneGraph.SceneGraphComponent;
   import Brain.UI.UIButton;
   import Brain.UI.UIObject;
   import Brain.Utils.MemoryTracker;
   import Brain.WorkLoop.LogicalWorkComponent;
   import DBGlobals.DBGlobal;
   import Events.BoostersParsedEvent;
   import Events.TrophiesUpdatedAccountEvent;
   import Facade.DBFacade;
   import Facade.GameMasterLocale;
   import Facade.Locale;
   import UI.CountdownTextTimer;
   import UI.Popup.UIExitPopup;
   import UI.Shop.UIShop;
   import UI.UITownTweens;
   import flash.display.MovieClip;
   import flash.filters.DropShadowFilter;
   import flash.text.TextField;
   
   public class TownHeader
   {
      
      private static const TOWN_HEADER_CLASS_NAME:String = "UI_header";
      
      protected var mDBFacade:DBFacade;
      
      protected var mRoot:MovieClip;
      
      protected var mSceneGraphComponent:SceneGraphComponent;
      
      protected var mEventComponent:EventComponent;
      
      protected var mLogicalWorkComponent:LogicalWorkComponent;
      
      protected var mAssetLoadingComponent:AssetLoadingComponent;
      
      protected var mDefaultCloseCallback:Function;
      
      protected var mMapStateCallback:Function;
      
      private var mTitle:String;
      
      private var mCashUI:UIObject;
      
      private var mCoinUI:UIObject;
      
      private var mTrophiesUI:UIObject;
      
      private var mTeamBonusUI:UIObject;
      
      private var mCoinBoosterUI:UIObject;
      
      private var mXPBoosterUI:UIObject;
      
      private var mGemIcon:MovieClip;
      
      private var mAddCashSaleButton:UIButton;
      
      private var mSaleEfx:MovieClip;
      
      private var mSaleLabel:TextField;
      
      private var mAddCoinButton:UIButton;
      
      private var mAddCashButton:UIButton;
      
      private var mCloseButton:UIButton;
      
      private var mCashLabel:TextField;
      
      private var mCoinLabel:TextField;
      
      private var mTrophyLabel:TextField;
      
      private var mShowCloseButton:Boolean = true;
      
      private var mJumpToMapState:Boolean = false;
      
      private var mInHomeState:Boolean = false;
      
      private var mKeyPanelButton:UIButton;
      
      private var mKeyPanel:KeyPanel;
      
      private var mShopUI:UIShop;
      
      private var mTownSwf:SwfAsset;
      
      private var mInTownFromKeyPanel:Boolean;
      
      private var mPreviousTitleBeforeKeyPanel:String;
      
      private var mBoosterXP:BoosterInfo;
      
      private var mBoosterGold:BoosterInfo;
      
      private var mCountDownTextXP:CountdownTextTimer;
      
      private var mCountDownTextGold:CountdownTextTimer;
      
      public function TownHeader(dbFacade:DBFacade, defaultCloseCallback:Function, mapStateCallback:Function = null)
      {
         super();
         mDBFacade = dbFacade;
         mDefaultCloseCallback = defaultCloseCallback;
         mMapStateCallback = mapStateCallback;
         mTitle = Locale.getString("TOWN_HEADER");
         mInTownFromKeyPanel = false;
         mEventComponent = new EventComponent(mDBFacade);
         mEventComponent.addListener("CurrencyUpdatedAccountEvent",this.currencyUpdated);
         mEventComponent.addListener("TrophiesUpdatedAccountEvent",this.trophiesUpdated);
         mLogicalWorkComponent = new LogicalWorkComponent(mDBFacade,"TownHeader");
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade,"TownHeader");
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_town.swf"),swfLoaded);
      }
      
      public function destroy() : void
      {
         if(mCountDownTextXP != null)
         {
            mCountDownTextXP.destroy();
         }
         if(mCountDownTextGold != null)
         {
            mCountDownTextGold.destroy();
         }
         mTeamBonusUI.destroy();
         if(mKeyPanel != null)
         {
            mKeyPanel.destroy();
         }
         mKeyPanel = null;
         mCashUI.destroy();
         mCoinUI.destroy();
         mTeamBonusUI.destroy();
         mAddCoinButton.destroy();
         mAddCashButton.destroy();
         mCloseButton.destroy();
         mGemIcon = null;
         mSaleLabel = null;
         mSaleEfx = null;
         mAddCashSaleButton.destroy();
         mEventComponent.destroy();
         mLogicalWorkComponent.destroy();
         mSceneGraphComponent.destroy();
         mAssetLoadingComponent.destroy();
         mDBFacade = null;
         mDefaultCloseCallback = null;
         mMapStateCallback = null;
      }
      
      private function swfLoaded(swfAsset:SwfAsset) : void
      {
         mTownSwf = swfAsset;
         var _loc2_:Class = mTownSwf.getClass("UI_header");
         mRoot = new _loc2_() as MovieClip;
         mRoot.filters = [new DropShadowFilter(6,90,0,0.5,6,6,1)];
         setupUI();
         show();
      }
      
      public function get rootMovieClip() : MovieClip
      {
         return mRoot;
      }
      
      private function setupUI() : void
      {
         var acctInfo:DBAccountInfo;
         mRoot.x = mDBFacade.viewWidth * 0.5;
         mRoot.y = 0;
         mRoot.currency.cash;
         mCashUI = new UIObject(mDBFacade,mRoot.currency.cash);
         mCashUI.tooltip.title_label.text = Locale.getString("CASH_TOOLTIP_TITLE");
         mCashUI.tooltip.description_label.text = Locale.getString("CASH_TOOLTIP_DESCRIPTION");
         mCoinUI = new UIObject(mDBFacade,mRoot.currency.coin);
         mCoinUI.tooltip.title_label.text = Locale.getString("COIN_TOOLTIP_TITLE");
         mCoinUI.tooltip.description_label.text = Locale.getString("COIN_TOOLTIP_DESCRIPTION");
         mTeamBonusUI = new UIObject(mDBFacade,mRoot.currency.crewbonus);
         mTeamBonusUI.tooltip.title_label.text = Locale.getString("TEAM_BONUS_TOOLTIP_TITLE");
         mTeamBonusUI.tooltip.description_label.text = Locale.getString("TEAM_BONUS_TOOLTIP_DESCRIPTION");
         mTeamBonusUI.root.header_crew_bonus_txt1.text = Locale.getString("TEAM_BONUS_TITLE_CREW");
         mTeamBonusUI.root.header_crew_bonus_txt2.text = Locale.getString("TEAM_BONUS_TITLE_BONUS");
         mTeamBonusUI.root.header_crew_bonus_number.text = mDBFacade.dbAccountInfo.inventoryInfo.getTotalHeroesOwned() - 1;
         mTeamBonusUI.root.header_crew_bonus_anim.stop();
         mCoinBoosterUI = new UIObject(mDBFacade,mRoot.currency.boosterCoin);
         mXPBoosterUI = new UIObject(mDBFacade,mRoot.currency.boosterXP);
         mAddCashButton = new UIButton(mDBFacade,mCashUI.root.add_cash);
         mAddCashButton.label.text = Locale.getString("HOW");
         mGemIcon = mCashUI.root.gem_icon;
         mSaleEfx = mCashUI.root.lable_sale_efx;
         mSaleEfx.visible = false;
         mAddCashSaleButton = new UIButton(mDBFacade,mCashUI.root.add_cash_sale);
         mAddCashSaleButton.visible = false;
         mAddCashSaleButton.label.text = Locale.getString("HOW");
         mSaleLabel = mCashUI.root.label_sale;
         mSaleLabel.visible = false;
         mAddCashSaleButton.rolloverFilter = mAddCashButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mAddCashSaleButton.releaseCallback = mAddCashButton.releaseCallback = function():void
         {
            mDBFacade.metrics.log("TownHeaderAddCash");
            StoreServicesController.showCashPage(mDBFacade,"TownHeaderAddCash");
         };
         mGemIcon.filters = [];
         mAddCoinButton = new UIButton(mDBFacade,mCoinUI.root.add_coin);
         mAddCoinButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mAddCoinButton.releaseCallback = function():void
         {
            StoreServicesController.showCoinPage(mDBFacade);
         };
         mAddCoinButton.label.text = Locale.getString("HOW");
         mCoinLabel = mCoinUI.root.coin as TextField;
         mCoinLabel.mouseEnabled = false;
         mCashLabel = mCashUI.root.cash as TextField;
         mCashLabel.mouseEnabled = false;
         mCloseButton = new UIButton(mDBFacade,mRoot.UI_town_home_button_instance);
         mCloseButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mCloseButton.releaseCallback = determineCallback;
         title = mTitle;
         showCloseButton(mShowCloseButton);
         acctInfo = mDBFacade.dbAccountInfo;
         setCurrency(acctInfo.basicCurrency,acctInfo.premiumCurrency);
         setTrophies(acctInfo.trophies);
         setBoosters();
         mEventComponent.addListener("BoostersParsedEvent_BOOSTERS_PARSED_UPDATE",this.handleBoostersParsedEvent);
      }
      
      public function updateTeamBonusUI() : void
      {
         mTeamBonusUI.root.header_crew_bonus_number.text = mDBFacade.dbAccountInfo.inventoryInfo.getTotalHeroesOwned() - 1;
      }
      
      private function createKeyPanel() : void
      {
         if(mKeyPanel != null)
         {
            closeKeyPanel();
         }
         else
         {
            mSceneGraphComponent.fadeOut(0.5,0.75);
            mKeyPanel = new KeyPanel(mDBFacade,mAssetLoadingComponent,buyKeysPressed,closeKeyPanel,mDBFacade.mainStateMachine.currentStateName);
            MemoryTracker.track(mKeyPanel,"KeyPanel - created in TownHeader.createKeyPanel()");
         }
      }
      
      public function refreshKeyPanel() : void
      {
         if(mKeyPanel)
         {
            mKeyPanel.refresh();
         }
      }
      
      private function buyKeysPressed() : void
      {
         closeKeyPanel();
         if(mShopUI != null)
         {
            return;
         }
         var _loc1_:Class = mTownSwf.getClass("DR_UI_town_shop");
         mShopUI = new UIShop(mDBFacade,mTownSwf,new _loc1_() as MovieClip,this);
         mShopUI.refresh("KEY");
         mShopUI.animateEntry();
         mSceneGraphComponent.addChild(mShopUI.root,50);
         showCloseButton(true);
         mInTownFromKeyPanel = true;
         mPreviousTitleBeforeKeyPanel = mTitle;
         title = Locale.getString("SHOP");
      }
      
      private function closeShopPanel() : void
      {
         mSceneGraphComponent.removeChild(mShopUI.root);
         mShopUI.destroy();
         mShopUI = null;
         mInTownFromKeyPanel = false;
         title = mPreviousTitleBeforeKeyPanel;
      }
      
      private function closeKeyPanel() : void
      {
         mSceneGraphComponent.fadeIn(0.5);
         mKeyPanelButton.enabled = true;
         mKeyPanel.destroy();
         mKeyPanel = null;
      }
      
      public function animateHeader() : void
      {
         UITownTweens.headerTweenSequence(mRoot,mDBFacade);
      }
      
      public function show() : void
      {
         if(mRoot != null && !mSceneGraphComponent.contains(mRoot,105))
         {
            mSceneGraphComponent.addChild(mRoot,75);
         }
      }
      
      public function hide() : void
      {
         if(mRoot)
         {
            mSceneGraphComponent.removeChild(mRoot);
         }
      }
      
      public function showCloseButton(value:Boolean) : void
      {
         mShowCloseButton = value;
         if(mCloseButton)
         {
            mCloseButton.visible = mShowCloseButton;
         }
      }
      
      public function set jumpToMapState(value:Boolean) : void
      {
         mJumpToMapState = value;
      }
      
      public function set inHomeState(value:Boolean) : void
      {
         mInHomeState = value;
      }
      
      private function showExitPopup() : void
      {
         var _loc1_:UIExitPopup = new UIExitPopup(mDBFacade);
         MemoryTracker.track(_loc1_,"UIExitPopup - created in TownHeader.showExitPopup()");
      }
      
      public function determineCallback() : void
      {
         if(mInHomeState)
         {
            showExitPopup();
            return;
         }
         if(mInTownFromKeyPanel)
         {
            closeShopPanel();
            return;
         }
         if(mJumpToMapState && mMapStateCallback != null)
         {
            mMapStateCallback();
         }
         else
         {
            mDefaultCloseCallback();
         }
         mJumpToMapState = false;
      }
      
      private function setCurrency(basicCurrency:uint, premiumCurrency:uint) : void
      {
         if(mRoot != null)
         {
            mCoinLabel.text = basicCurrency.toString();
            mCashLabel.text = premiumCurrency.toString();
         }
      }
      
      private function currencyUpdated(event:CurrencyUpdatedAccountEvent) : void
      {
         this.setCurrency(event.basicCurrency,event.premiumCurrency);
      }
      
      private function setTrophies(trophies:uint) : void
      {
         if(mRoot != null)
         {
         }
      }
      
      private function handleBoostersParsedEvent(event:BoostersParsedEvent) : void
      {
         resetBoosters();
      }
      
      private function resetBoosters() : void
      {
         setBoosters();
      }
      
      private function setBoosters() : void
      {
         var _loc1_:DBInventoryInfo = mDBFacade.dbAccountInfo.inventoryInfo;
         mXPBoosterUI.visible = false;
         mCoinBoosterUI.visible = false;
         mBoosterXP = _loc1_.findHighestBoosterXP();
         mBoosterGold = _loc1_.findHighestBoosterGold();
         if(mCountDownTextXP != null)
         {
            mCountDownTextXP.destroy();
         }
         if(mCountDownTextGold != null)
         {
            mCountDownTextGold.destroy();
         }
         if(mBoosterXP)
         {
            mRoot.currency.boosterXP.label.text = mBoosterXP.BuffInfo.Exp + "X";
            mXPBoosterUI.tooltip.title_label.text = mBoosterXP.StackInfo.Name;
            mXPBoosterUI.visible = true;
            mCountDownTextXP = new CountdownTextTimer(mXPBoosterUI.tooltip.time_label,mBoosterXP.getEndDate(),GameClock.getWebServerDate,setBoosters,Locale.getString("BOOSTER_REMAINING"),"",Locale.getString("EXPIRED"));
            mCountDownTextXP.start();
         }
         if(mBoosterGold)
         {
            mRoot.currency.boosterCoin.label.text = mBoosterGold.BuffInfo.Gold + "X";
            mCoinBoosterUI.tooltip.title_label.text = GameMasterLocale.getGameMasterSubString("STACKABLE_NAME",mBoosterGold.StackInfo.Constant);
            mCoinBoosterUI.visible = true;
            mCountDownTextGold = new CountdownTextTimer(mCoinBoosterUI.tooltip.time_label,mBoosterGold.getEndDate(),GameClock.getWebServerDate,setBoosters,Locale.getString("BOOSTER_REMAINING"),"",Locale.getString("EXPIRED"));
            mCountDownTextGold.start();
         }
      }
      
      private function trophiesUpdated(event:TrophiesUpdatedAccountEvent) : void
      {
         this.setTrophies(event.trophyCount);
      }
      
      public function set title(value:String) : void
      {
         mTitle = value;
         if(mRoot != null)
         {
            mRoot.page_title.text = mTitle;
            mRoot.page_title.mouseEnabled = false;
         }
      }
      
      public function get addCoinButton() : UIButton
      {
         return mAddCoinButton;
      }
      
      public function get addGemButton() : UIButton
      {
         return mAddCashButton;
      }
      
      public function get closeButton() : UIButton
      {
         return mCloseButton;
      }
      
      public function setupButtonLinks() : void
      {
         mAddCoinButton.downNavigation = null;
         mAddCashButton.downNavigation = null;
         mAddCoinButton.isToTheLeftOf(mAddCashButton);
         if(mShowCloseButton)
         {
            mAddCashButton.isToTheLeftOf(mCloseButton);
         }
         else
         {
            mAddCashButton.rightNavigation = null;
         }
      }
      
      public function resetButtonLinks() : void
      {
         mAddCoinButton.clearNavigationAndInteractions();
         mAddCashButton.clearNavigationAndInteractions();
         mCloseButton.clearNavigationAndInteractions();
         mAddCoinButton.setFocused(false);
         mAddCashButton.setFocused(false);
         mCloseButton.setFocused(false);
      }
   }
}

