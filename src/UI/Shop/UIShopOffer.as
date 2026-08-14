package UI.Shop
{
   import Account.StoreServices;
   import Account.StoreServicesController;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Clock.GameClock;
   import Brain.Logger.Logger;
   import Brain.Render.MovieClipRenderController;
   import Brain.SceneGraph.SceneGraphManager;
   import Brain.UI.UIButton;
   import Brain.UI.UIObject;
   import Brain.Utils.MemoryTracker;
   import DBGlobals.DBGlobal;
   import Facade.DBFacade;
   import Facade.GameMasterLocale;
   import Facade.Locale;
   import GameMasterDictionary.GMHero;
   import GameMasterDictionary.GMOffer;
   import GameMasterDictionary.GMRarity;
   import UI.Popup.DBUIOneButtonPopup;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.events.MouseEvent;
   import flash.filters.ColorMatrixFilter;
   import flash.text.TextField;
   
   public class UIShopOffer extends UIObject
   {
      
      protected static const DEFAULT_SHOP_OFFER_SCALE:Number = 1.8;
      
      protected static const SHOP_OFFER_SCALE:Number = 1;
      
      protected static const DEFAULT_ROLL_OVER_SCALE:Number = 1.98;
      
      protected static const ROLL_OVER_SCALE:Number = 1.1;
      
      protected static const DAY_THRESHOLD_TO_ENUMERATE_DAYS_LEFT:Number = 8;
      
      protected static const ONE_DAY_MS:Number = 86400000;
      
      protected static const ONE_HOUR_MS:Number = 3600000;
      
      protected var mWantNewRollOverScale:Boolean;
      
      protected var mDBFacade:DBFacade;
      
      protected var mAssetLoadingComponent:AssetLoadingComponent;
      
      protected var mTitle:TextField;
      
      protected var mTitleY:Number;
      
      protected var mRibbon:MovieClip;
      
      protected var mLevelStarLabel:TextField;
      
      protected var mOriginalPrice:TextField;
      
      protected var mStrikePrice:Sprite;
      
      protected var mCashIcon:MovieClip;
      
      protected var mCoinIcon:MovieClip;
      
      protected var mBuyButton:UIButton;
      
      protected var mBuyButtonCoin:UIButton;
      
      protected var mBuyButtonCash:UIButton;
      
      protected var mExclusiveOfferButton:UIButton;
      
      protected var mBuyButtonTimerBasedSale:UIButton;
      
      protected var mDLCBuyButton:UIButton;
      
      protected var mGiftIcon:MovieClip;
      
      protected var mIconParent:UIObject;
      
      protected var mIcon:MovieClip;
      
      protected var mBgIcon:MovieClip;
      
      protected var mBgIconBorder:MovieClip;
      
      protected var mBg:MovieClip;
      
      protected var mBgGrey:MovieClip;
      
      protected var mStar:MovieClip;
      
      protected var mRenderer:MovieClipRenderController;
      
      protected var mDescriptionLabel:TextField;
      
      protected var mLimitLabel:TextField;
      
      protected var mSaleLabel:TextField;
      
      protected var mRequiresLabel:TextField;
      
      protected var mAlreadyOwnedLabel:TextField;
      
      protected var mBuySuccessCallback:Function;
      
      protected var mHeroRequiredLabel:MovieClip;
      
      private var mGMOffer:GMOffer;
      
      private var mSaleOffer:GMOffer;
      
      private var mCoinOffer:GMOffer;
      
      private var mCoinSaleOffer:GMOffer;
      
      protected var mGMHero:GMHero;
      
      protected var mNumSold:uint;
      
      private var mUseIconScaling:Boolean;
      
      private var mStackCountTF:TextField;
      
      public function UIShopOffer(dbFacade:DBFacade, templateClass:Class, buySuccessCallback:Function = null, useIconScaling:Boolean = true, wantNewRollOverScale:Boolean = true)
      {
         mDBFacade = dbFacade;
         super(dbFacade,new templateClass());
         mWantNewRollOverScale = wantNewRollOverScale;
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mTitle = mRoot.offer_title;
         mTitleY = mTitle.y;
         mRibbon = mRoot.ribbon;
         mLevelStarLabel = mRoot.level_star_label;
         mOriginalPrice = mRoot.buy_button.original_price;
         mStrikePrice = mRoot.buy_button.strike;
         mCashIcon = mRoot.buy_button.icons_bundle.cash;
         mCoinIcon = mRoot.buy_button.icons_bundle.coin;
         mGiftIcon = mRoot.buy_button.icons_bundle.gift_icon;
         mStar = mRoot.star;
         mBg = mRoot.bg;
         mBgGrey = mRoot.bg_grey;
         mDescriptionLabel = mRoot.description_label;
         mLimitLabel = mRoot.limit_label;
         mSaleLabel = mRoot.sale_label;
         mRequiresLabel = mRoot.requires_title;
         mUseIconScaling = useIconScaling;
         mStackCountTF = mRoot.number_label;
         if(mStackCountTF)
         {
            mStackCountTF.visible = false;
         }
         mAlreadyOwnedLabel = mRoot.already_owned_label;
         mAlreadyOwnedLabel.visible = false;
         mHeroRequiredLabel = mRoot.shop_herorequired;
         mHeroRequiredLabel.hero_label.text = Locale.getString("PURCHASE_HERO_BEFORE_BUYING_SYTLE_TAVERN_LABEL");
         mHeroRequiredLabel.visible = false;
         if(mRoot.timer)
         {
            mRoot.timer.visible = false;
         }
         mBuyButtonCoin = new UIButton(mDBFacade,mRoot.buy_button_coins);
         mBuyButtonCoin.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mBuyButtonCoin.releaseCallback = this.buyButtonCoinCallback;
         mBuyButtonCoin.root.icons_bundle.cash.visible = false;
         mBuyButtonCoin.root.icons_bundle.gift_icon.visible = false;
         mBuyButtonCoin.root.original_price.visible = false;
         mBuyButtonCoin.root.strike.visible = false;
         mBuyButtonCash = new UIButton(mDBFacade,mRoot.buy_button_gems);
         mBuyButtonCash.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mBuyButtonCash.releaseCallback = this.buyButtonCallback;
         mBuyButtonCash.root.icons_bundle.coin.visible = false;
         mBuyButtonCash.root.icons_bundle.gift_icon.visible = false;
         mBuyButtonCash.root.original_price.visible = false;
         mBuyButtonCash.root.strike.visible = false;
         mBuyButtonTimerBasedSale = new UIButton(mDBFacade,mRoot.buy_button_sale);
         mBuyButtonTimerBasedSale.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mBuyButtonTimerBasedSale.releaseCallback = this.buyButtonCallback;
         mBuyButtonTimerBasedSale.root.icons_bundle.coin.visible = false;
         mBuyButtonTimerBasedSale.root.icons_bundle.gift_icon.visible = false;
         mBuyButtonTimerBasedSale.root.original_price.visible = false;
         mBuyButtonTimerBasedSale.root.strike.visible = false;
         mBuyButtonTimerBasedSale.root.original_price.mouseEnabled = false;
         mBuyButtonTimerBasedSale.root.strike.mouseEnabled = false;
         mBuyButton = new UIButton(mDBFacade,mRoot.buy_button);
         mBuyButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mBuySuccessCallback = buySuccessCallback;
         mBuyButton.releaseCallback = this.buyButtonCallback;
         mExclusiveOfferButton = new UIButton(mDBFacade,mRoot.exclusive_offer);
         mExclusiveOfferButton.releaseCallback = buyButtonCallback;
         mIconParent = new UIObject(mDBFacade,mRoot.icon);
         mBuyButtonTimerBasedSale.visible = false;
         if(!mDBFacade.dbConfigManager.getConfigBoolean("want_skins",true))
         {
            mRoot.required_text.visible = false;
            mRoot.shop_herorequired.visible = false;
         }
      }
      
      protected function buyButtonCallback() : void
      {
         return this.buyButtonInternal(this.offer);
      }
      
      protected function buyButtonCoinCallback() : void
      {
         return this.buyButtonInternal(this.coinOffer);
      }
      
      private function buyButtonInternal(buyOffer:GMOffer) : void
      {
         var popup:DBUIOneButtonPopup;
         var callback:Function = mBuySuccessCallback;
         if(!buyOffer)
         {
            return;
         }
         if(IsCashPageExclusiveOffer())
         {
            StoreServicesController.showCashPage(mDBFacade,"shopBuyButtonExclusiveOfferDragonKnight");
         }
         else if(this.canBuyOffer())
         {
            StoreServicesController.tryBuyOffer(mDBFacade,buyOffer,function(param1:*):void
            {
               if(mDBFacade && buyOffer.Tab != "KEY")
               {
                  showOffer(buyOffer,mGMHero);
               }
               if(callback != null)
               {
                  callback(buyOffer);
               }
            });
         }
         else if(this.canGiftOffer())
         {
            popup = new DBUIOneButtonPopup(mDBFacade,Locale.getString("SHOP_GIFT_CONFIRM_TITLE"),Locale.getString("SHOP_GIFT_CONFIRM_DESC"),Locale.getString("OK"),null);
            MemoryTracker.track(popup,"DBUIOneButtonPopup - created in UIShopOffer.buyOffer()");
            if(callback != null)
            {
               callback(buyOffer);
            }
         }
         else
         {
            Logger.warn("Offer that you cannot buy or gift: " + buyOffer.Id.toString());
         }
      }
      
      override public function destroy() : void
      {
         mDBFacade = null;
         mBuySuccessCallback = null;
         mAssetLoadingComponent.destroy();
         mAssetLoadingComponent = null;
         mBuyButton.destroy();
         mBuyButton = null;
         mExclusiveOfferButton.destroy();
         mExclusiveOfferButton = null;
         mBuyButtonCash.destroy();
         mBuyButtonCash = null;
         mBuyButtonCoin.destroy();
         mBuyButtonCoin = null;
         mBuyButtonTimerBasedSale.destroy();
         mBuyButtonTimerBasedSale = null;
         mIconParent.destroy();
         mIconParent = null;
         mBgIcon = null;
         mIcon = null;
         if(mRenderer)
         {
            mRenderer.destroy();
            mRenderer = null;
         }
         super.destroy();
      }
      
      override protected function onRollOver(event:MouseEvent) : void
      {
         super.onRollOver(event);
         if(mWantNewRollOverScale)
         {
            mRoot.scaleX = mRoot.scaleY = 1.98;
         }
         else
         {
            mRoot.scaleX = mRoot.scaleY = 1.1;
         }
      }
      
      override protected function onRollOut(event:MouseEvent) : void
      {
         super.onRollOut(event);
         if(mWantNewRollOverScale)
         {
            mRoot.scaleX = mRoot.scaleY = 1.8;
         }
         else
         {
            mRoot.scaleX = mRoot.scaleY = 1;
         }
      }
      
      protected function getQuantityString() : String
      {
         var _loc1_:int = 0;
         if(this.offer.LimitedQuantity > 0)
         {
            if(mNumSold >= this.offer.LimitedQuantity)
            {
               return Locale.getString("SHOP_SOLD_OUT");
            }
            _loc1_ = this.offer.LimitedQuantity - mNumSold;
            return _loc1_.toString() + Locale.getString("SHOP_REMAINING");
         }
         return "";
      }
      
      protected function getDateString() : String
      {
         var _loc6_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc1_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Date = getStartDate();
         var _loc3_:Date = getEndDate();
         var _loc4_:Date = getSoldOutDate();
         var _loc10_:Number = GameClock.getWebServerTime();
         if(_loc9_)
         {
            _loc6_ = _loc9_.getTime();
            if(_loc6_ > _loc10_)
            {
               return Locale.getString("SHOP_COMING_SOON");
            }
         }
         if(_loc4_)
         {
            _loc2_ = _loc4_.getTime();
            if(_loc2_ < _loc10_)
            {
               return Locale.getString("SHOP_SOLD_OUT");
            }
         }
         if(_loc3_)
         {
            _loc7_ = _loc3_.getTime();
            if(_loc7_ < _loc10_)
            {
               return Locale.getString("SHOP_SOLD_OUT");
            }
            _loc5_ = _loc7_ - _loc10_;
            _loc1_ = _loc5_ / 86400000;
            if(_loc1_ > 8)
            {
               return Locale.getString("LIMITED_TIME_OFFER");
            }
            if(_loc1_ > 2)
            {
               return Math.floor(_loc1_).toString() + Locale.getString("SHOP_DAYS_LEFT");
            }
            if(_loc1_ > 1)
            {
               return Math.floor(_loc1_).toString() + Locale.getString("SHOP_DAY_LEFT");
            }
            _loc8_ = _loc5_ / 3600000;
            if(_loc8_ > 2)
            {
               return Math.floor(_loc8_).toString() + Locale.getString("SHOP_HOURS_LEFT");
            }
            if(_loc8_ > 1)
            {
               return Math.floor(_loc8_).toString() + Locale.getString("SHOP_HOUR_LEFT");
            }
            return Locale.getString("SHOP_ALMOST_GONE");
         }
         return "";
      }
      
      protected function get offerDescription() : String
      {
         return "";
      }
      
      protected function get offerIconName() : String
      {
         return "";
      }
      
      protected function get offerSwfPath() : String
      {
         return "";
      }
      
      protected function getTextRarityColor() : uint
      {
         var _loc1_:GMRarity = mDBFacade.gameMaster.rarityByConstant.itemFor(offer.Rarity);
         return _loc1_ != null && _loc1_.TextColor ? _loc1_.TextColor : 15463921;
      }
      
      protected function get hasColoredBackground() : Boolean
      {
         var _loc1_:GMRarity = mDBFacade.gameMaster.rarityByConstant.itemFor(offer.Rarity);
         return _loc1_ != null ? _loc1_.HasColoredBackground : false;
      }
      
      protected function get backgroundIconName() : String
      {
         var _loc1_:GMRarity = mDBFacade.gameMaster.rarityByConstant.itemFor(offer.Rarity);
         return _loc1_ != null ? _loc1_.BackgroundIcon : "";
      }
      
      protected function get backgroundIconBorderName() : String
      {
         var _loc1_:GMRarity = mDBFacade.gameMaster.rarityByConstant.itemFor(offer.Rarity);
         return _loc1_ != null ? _loc1_.BackgroundIconBorder : "";
      }
      
      protected function get backgroundSwfPath() : String
      {
         var _loc1_:GMRarity = mDBFacade.gameMaster.rarityByConstant.itemFor(offer.Rarity);
         return _loc1_ != null ? _loc1_.BackgroundSwf : "";
      }
      
      protected function loadOfferIcon() : void
      {
         var bgColoredExists:Boolean;
         var bgSwfPath:String;
         var bgIconName:String;
         var bgIconBorderName:String;
         var swfPath:String;
         var iconName:String;
         if(mRenderer)
         {
            mRenderer.destroy();
            mRenderer = null;
         }
         if(mBgIcon && mBgIcon.parent)
         {
            mBgIcon.parent.removeChild(mBgIcon);
            mBgIcon = null;
         }
         if(mBgIconBorder && mBgIconBorder.parent)
         {
            mBgIconBorder.parent.removeChild(mBgIconBorder);
            mBgIconBorder = null;
         }
         if(mIcon && mIcon.parent)
         {
            mIcon.parent.removeChild(mIcon);
            mIcon = null;
         }
         bgColoredExists = this.hasColoredBackground;
         bgSwfPath = this.backgroundSwfPath;
         bgIconName = this.backgroundIconName;
         bgIconBorderName = this.backgroundIconBorderName;
         swfPath = this.offerSwfPath;
         iconName = this.offerIconName;
         if(swfPath && iconName)
         {
            if(bgColoredExists)
            {
               mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(bgSwfPath),function(param1:SwfAsset):void
               {
                  var _loc3_:Class = param1.getClass(bgIconBorderName);
                  if(_loc3_)
                  {
                     mBgIconBorder = new _loc3_();
                     mIconParent.root.addChild(mBgIconBorder);
                  }
                  var _loc2_:Class = param1.getClass(bgIconName);
                  if(_loc2_)
                  {
                     mBgIcon = new _loc2_();
                     mRenderer = new MovieClipRenderController(mDBFacade,mBgIcon);
                     mRenderer.play(0,true);
                     if(mBgIconBorder)
                     {
                        mBgIconBorder.addChild(mBgIcon);
                     }
                     else
                     {
                        mIconParent.root.addChild(mBgIcon);
                     }
                  }
               });
            }
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(swfPath),function(param1:SwfAsset):void
            {
               var _loc2_:Class = param1.getClass(iconName);
               if(_loc2_)
               {
                  mIcon = new _loc2_();
                  mRenderer = new MovieClipRenderController(mDBFacade,mIcon);
                  mRenderer.play(0,true);
                  if(mUseIconScaling)
                  {
                     mIcon.scaleX = mIcon.scaleY = 72 / nativeIconSize;
                  }
                  mIconParent.root.addChild(mIcon);
               }
            });
         }
      }
      
      protected function get nativeIconSize() : Number
      {
         return 100;
      }
      
      protected function hasRequirements() : Boolean
      {
         return false;
      }
      
      protected function get nodesToGrey() : Vector.<DisplayObject>
      {
         return new <DisplayObject>[mBg,mIconParent.root,mRibbon,mBuyButton.root,mBuyButtonCash.root,mBuyButtonCoin.root,mBuyButtonTimerBasedSale.root,mStar];
      }
      
      protected function greyOffer(value:Boolean) : void
      {
         var _loc2_:ColorMatrixFilter = null;
         if(value)
         {
            _loc2_ = SceneGraphManager.getGrayScaleSaturationFilter(5);
            for each(var _loc3_:DisplayObject in this.nodesToGrey)
            {
               if(_loc3_ != null)
               {
                  _loc3_.filters = [_loc2_];
               }
            }
            if(mBgGrey)
            {
               mBg.visible = false;
               mBgGrey.visible = true;
               mBgGrey.filters = [_loc2_];
            }
            mLevelStarLabel.textColor = mRequiresLabel.textColor = 15535124;
            if(mDescriptionLabel)
            {
               mDescriptionLabel.textColor = 15535124;
            }
            mTitle.textColor = 8947848;
            if(this.mGMOffer.CurrencyType == "DLC")
            {
               mDLCBuyButton.enabled = false;
            }
         }
      }
      
      protected function shouldGreyOffer(gmHero:GMHero) : Boolean
      {
         return false;
      }
      
      protected function get coinOffer() : GMOffer
      {
         return mCoinSaleOffer ? mCoinSaleOffer : mCoinOffer;
      }
      
      protected function get offer() : GMOffer
      {
         return mSaleOffer ? mSaleOffer : mGMOffer;
      }
      
      public function getVisibleDate() : Date
      {
         return mGMOffer.VisibleDate;
      }
      
      public function getStartDate() : Date
      {
         return mGMOffer.StartDate;
      }
      
      public function getEndDate() : Date
      {
         return mGMOffer.EndDate;
      }
      
      public function getSoldOutDate() : Date
      {
         return mGMOffer.SoldOutDate;
      }
      
      protected function set offer(value:GMOffer) : void
      {
         mGMOffer = value;
         mSaleOffer = mGMOffer.isOnSaleNow;
         mCoinOffer = mGMOffer.CoinOffer;
         mCoinSaleOffer = mCoinOffer ? mCoinOffer.isOnSaleNow : null;
      }
      
      public function showOffer(gmOffer:GMOffer, gmHero:GMHero) : void
      {
         var canBuy:Boolean;
         var canGift:Boolean;
         var gemVisible:Boolean;
         var coinVisible:Boolean;
         var levelReq:uint;
         var buyButtonEnabled:Boolean;
         this.offer = gmOffer;
         mGMHero = gmHero;
         if(gmOffer.Details[0].HeroId || gmOffer.Details[0].SkinId)
         {
            mTitle.text = GameMasterLocale.getGameMasterSubString("SKIN_NAME",this.offer.getOfferItemConstant(mDBFacade.gameMaster));
         }
         else if(gmOffer.Details[0].PetId)
         {
            mTitle.text = GameMasterLocale.getGameMasterSubString("PET_NAME",this.offer.getOfferItemConstant(mDBFacade.gameMaster));
         }
         else if(!gmOffer.Details[0].WeaponId)
         {
            if(gmOffer.Details[0].OfferId)
            {
               mTitle.text = GameMasterLocale.getGameMasterSubString("BUNDLE_OFFER_NAME",this.offer.Id.toString());
            }
            else
            {
               Logger.debug(gmOffer.Id.toString());
            }
         }
         mTitle.textColor = this.getTextRarityColor();
         if(mTitle.numLines == 1)
         {
            mTitle.y = mTitleY + mTitle.height * 0.2;
         }
         else
         {
            mTitle.y = mTitleY;
         }
         loadOfferIcon();
         if(gmOffer.Details.length > 0)
         {
            if(gmOffer.Details[0].StackableId)
            {
               mStackCountTF.visible = true;
               mStackCountTF.text = "x" + gmOffer.Details[0].StackableCount.toString();
            }
         }
         mRequiresLabel.text = Locale.getString("REQUIRES");
         mRequiresLabel.visible = this.hasRequirements();
         if(mDescriptionLabel)
         {
            mDescriptionLabel.text = this.offerDescription;
         }
         if(IsCashPageExclusiveOffer())
         {
            mBuyButton.visible = false;
            mExclusiveOfferButton.visible = true;
            mExclusiveOfferButton.label.text = Locale.getString("UI_SHOP_CASH_PAGE_EXCLUSIVE");
            mBuyButtonCoin.visible = false;
            mBuyButtonCash.visible = false;
            mRoot.label_or.visible = false;
         }
         else if(this.coinOffer)
         {
            mBuyButton.visible = false;
            mBuyButtonCoin.visible = true;
            mBuyButtonCash.visible = true;
            mRoot.label_or.visible = true;
            mExclusiveOfferButton.visible = false;
            mBuyButtonCash.label.text = this.offer.Price > 0 ? this.offer.Price.toString() : Locale.getString("SHOP_FREE");
            mBuyButtonCoin.label.text = this.coinOffer.Price > 0 ? this.coinOffer.Price.toString() : Locale.getString("SHOP_FREE");
         }
         else if(this.mGMOffer.CurrencyType == "DLC")
         {
            mBuyButton.visible = false;
            mBuyButtonCoin.visible = false;
            mBuyButtonCash.visible = false;
            mRoot.label_or.visible = false;
            mExclusiveOfferButton.visible = false;
            mDLCBuyButton = new UIButton(mDBFacade,mRoot.dlc_button);
            mDLCBuyButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
            mDLCBuyButton.releaseCallback = function():void
            {
               mDBFacade.overlaySteamBasedOnAppId(gmOffer.SteamAppId);
            };
         }
         else
         {
            mBuyButton.visible = true;
            mBuyButtonCoin.visible = false;
            mBuyButtonCash.visible = false;
            mRoot.label_or.visible = false;
            mExclusiveOfferButton.visible = false;
            mBuyButton.label.text = this.offer.Price > 0 ? this.offer.Price.toString() : Locale.getString("SHOP_FREE");
         }
         if(mSaleOffer)
         {
            mRoot.sale_ribbon_label.visible = true;
            mRoot.sale_ribbon.visible = true;
            mRoot.new_ribbon_label.visible = false;
            if(mSaleOffer.percentOff != 0)
            {
               mSaleLabel.visible = true;
               mSaleLabel.text = mSaleOffer.percentOff.toString() + Locale.getString("SHOP_PERCENT_OFF");
               mOriginalPrice.visible = true;
               mOriginalPrice.text = mGMOffer.Price.toString();
               mStrikePrice.visible = true;
               mStrikePrice.width = mOriginalPrice.textWidth + 4;
            }
            else
            {
               mStrikePrice.visible = false;
               mSaleLabel.visible = false;
               mOriginalPrice.visible = false;
            }
            mBuyButtonTimerBasedSale.root.original_price.visible = true;
            mBuyButtonTimerBasedSale.root.original_price.text = mGMOffer.Price.toString();
            mBuyButtonTimerBasedSale.root.strike.visible = true;
            mBuyButtonTimerBasedSale.root.strike.width = mBuyButtonTimerBasedSale.root.original_price.textWidth + 4;
            if(mCoinOffer && mCoinSaleOffer && mCoinOffer.Price != mCoinSaleOffer.Price)
            {
               mBuyButtonCoin.root.original_price.visible = true;
               mBuyButtonCoin.root.original_price.text = mCoinOffer.Price.toString();
               mBuyButtonCoin.root.strike.visible = true;
               mBuyButtonCoin.root.strike.width = mBuyButtonCoin.root.original_price.textWidth + 4;
            }
            mBuyButtonCash.root.original_price.visible = true;
            mBuyButtonCash.root.original_price.text = mGMOffer.Price.toString();
            mBuyButtonCash.root.strike.visible = true;
            mBuyButtonCash.root.strike.width = mBuyButtonCash.root.original_price.textWidth + 4;
         }
         else
         {
            if(mGMOffer.LimitedQuantity > 0)
            {
               mRoot.sale_ribbon.visible = true;
               mRoot.sale_ribbon_label.visible = false;
               mRoot.new_ribbon_label.text = Locale.getString("SHOP_RARE");
               mRoot.new_ribbon_label.visible = true;
            }
            else if(mGMOffer.isNew)
            {
               mRoot.sale_ribbon.visible = true;
               mRoot.sale_ribbon_label.visible = false;
               mRoot.new_ribbon_label.text = Locale.getString("SHOP_NEW");
               mRoot.new_ribbon_label.visible = true;
            }
            else
            {
               mRoot.sale_ribbon.visible = false;
               mRoot.sale_ribbon_label.visible = false;
               mRoot.new_ribbon_label.visible = false;
            }
            mOriginalPrice.visible = false;
            mStrikePrice.visible = false;
            mSaleLabel.visible = false;
         }
         if(this.offer.LimitedQuantity > 0)
         {
            mNumSold = StoreServices.getOfferQuantitySold(this.offer);
         }
         canBuy = this.canBuyOffer();
         canGift = this.canGiftOffer();
         if(canGift)
         {
            mGiftIcon.visible = true;
            mCashIcon.visible = false;
            mCoinIcon.visible = false;
         }
         else
         {
            mGiftIcon.visible = false;
            gemVisible = this.offer.Price > 0 && this.offer.CurrencyType == "PREMIUM";
            coinVisible = this.offer.Price > 0 && this.offer.CurrencyType == "BASIC";
            mCashIcon.visible = gemVisible;
            mCoinIcon.visible = coinVisible;
            mBuyButtonTimerBasedSale.root.icons_bundle.cash.visible = gemVisible;
            mBuyButtonTimerBasedSale.root.icons_bundle.coin.visible = coinVisible;
         }
         levelReq = StoreServicesController.getOfferLevelReq(mDBFacade,this.offer);
         mLevelStarLabel.text = levelReq.toString();
         mLevelStarLabel.visible = mStar.visible = false;
         if(getStartDate() || getEndDate())
         {
            if(mRoot.timer)
            {
               mRoot.timer.visible = true;
               mRoot.timer.text = getDateString();
            }
            mBuyButton.visible = false;
            if(this.coinOffer)
            {
               mBuyButtonCoin.visible = true;
               mBuyButtonCash.visible = true;
               mBuyButtonTimerBasedSale.visible = false;
            }
            else
            {
               mBuyButtonCoin.visible = false;
               mBuyButtonCash.visible = false;
               mBuyButtonTimerBasedSale.visible = true;
               mBuyButtonTimerBasedSale.label.text = this.offer.Price.toString();
            }
         }
         if(this.offer.LimitedQuantity > 0)
         {
            if(mLimitLabel)
            {
               mLimitLabel.visible = true;
               mLimitLabel.text = getQuantityString();
            }
         }
         else if(mLimitLabel)
         {
            mLimitLabel.visible = false;
         }
         mAlreadyOwnedLabel.visible = !this.requirementsMetForPurchase();
         buyButtonEnabled = canBuy || canGift;
         mBuyButton.enabled = buyButtonEnabled;
         mBuyButtonCoin.enabled = buyButtonEnabled;
         mBuyButtonCash.enabled = buyButtonEnabled;
         mBuyButtonTimerBasedSale.enabled = buyButtonEnabled;
         this.greyOffer(!canBuy && !canGift || this.shouldGreyOffer(mGMHero));
      }
      
      protected function requirementsMetForPurchase() : Boolean
      {
         return false;
      }
      
      protected function isAvailableTime() : Boolean
      {
         if(mGMOffer.SaleOffers && mGMOffer.SaleOffers.length > 0)
         {
            return mGMOffer.SaleOffers[0].isAvailableTime();
         }
         return this.offer.isAvailableTime();
      }
      
      protected function isAvailableQuantity() : Boolean
      {
         if(this.offer.LimitedQuantity && mNumSold >= this.offer.LimitedQuantity)
         {
            return false;
         }
         return true;
      }
      
      protected function canBuyOffer() : Boolean
      {
         if(this.offer.Gift)
         {
            return false;
         }
         if(!this.isAvailableTime())
         {
            return false;
         }
         if(!this.requirementsMetForPurchase())
         {
            return false;
         }
         if(!this.isAvailableQuantity())
         {
            return false;
         }
         return true;
      }
      
      protected function IsCashPageExclusiveOffer() : Boolean
      {
         return false;
      }
      
      protected function canGiftOffer() : Boolean
      {
         if(!this.offer.Gift)
         {
            return false;
         }
         if(!this.isAvailableTime())
         {
            return false;
         }
         if(!this.isAvailableQuantity())
         {
            return false;
         }
         return true;
      }
   }
}

