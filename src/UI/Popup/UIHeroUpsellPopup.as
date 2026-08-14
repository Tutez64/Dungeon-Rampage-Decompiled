package UI.Popup
{
   import Account.StoreServicesController;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Logger.Logger;
   import Brain.Render.MovieClipRenderController;
   import Brain.UI.UIButton;
   import DBGlobals.DBGlobal;
   import Facade.DBFacade;
   import Facade.GameMasterLocale;
   import Facade.Locale;
   import FacebookAPI.DBFacebookBragFeedPost;
   import GameMasterDictionary.GMHero;
   import GameMasterDictionary.GMOffer;
   import Town.TownHeader;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.utils.Dictionary;
   
   public class UIHeroUpsellPopup extends DBUIPopup
   {
      
      private static const SWF_PATH:String = "Resources/Art2D/UI/db_UI_screens.swf";
      
      private static const POPUP_CLASS_NAME:String = "hero_upsell_popup";
      
      private static var SCREENSHOTS:Dictionary = new Dictionary();
      
      SCREENSHOTS["RANGER"] = ["image_ranger01","image_ranger02"];
      SCREENSHOTS["SORCERER"] = ["image_sorcerer01","image_sorcerer02"];
      SCREENSHOTS["BATTLE_CHEF"] = ["image_chef01","image_chef02"];
      SCREENSHOTS["VAMPIRE_HUNTER"] = ["image_vampireHunter01","image_vampireHunter02"];
      SCREENSHOTS["GHOST_SAMURAI"] = ["image_ghostSamurai01","image_ghostSamurai02"];
      SCREENSHOTS["PYROMANCER"] = ["image_pyro01","image_pyro02"];
      SCREENSHOTS["DRAGON_KNIGHT"] = ["image_dragonKnight01","image_dragonKnight02"];
      
      private var mBuyButton:UIButton;
      
      private var mBuyButtonCoin:UIButton;
      
      private var mBuyButtonCash:UIButton;
      
      private var mGMOffer:GMOffer;
      
      private var mSaleOffer:GMOffer;
      
      private var mCoinOffer:GMOffer;
      
      private var mCoinSaleOffer:GMOffer;
      
      private var mGMHero:GMHero;
      
      private var mAttackStars:Vector.<MovieClip> = new Vector.<MovieClip>();
      
      private var mDefenseStars:Vector.<MovieClip> = new Vector.<MovieClip>();
      
      private var mSpeedStars:Vector.<MovieClip> = new Vector.<MovieClip>();
      
      private var mTownHeader:TownHeader;
      
      public function UIHeroUpsellPopup(townHeader:TownHeader, dbFacade:DBFacade, gmOffer:GMOffer, closeCallback:Function = null)
      {
         mTownHeader = townHeader;
         mGMOffer = gmOffer;
         mSaleOffer = mGMOffer.isOnSaleNow;
         mCoinOffer = mGMOffer.CoinOffer;
         mCoinSaleOffer = mCoinOffer ? mCoinOffer.isOnSaleNow : null;
         var _loc5_:uint = mGMOffer.Details[0].HeroId;
         mGMHero = dbFacade.gameMaster.heroById.itemFor(_loc5_);
         if(!_loc5_ || !mGMHero)
         {
            Logger.error("Invalid GMOffer: " + gmOffer.Id);
         }
         dbFacade.metrics.log("HeroUpsellPopupPresented",{"heroId":_loc5_.toString()});
         super(dbFacade,"",null,true,true,closeCallback);
      }
      
      override public function destroy() : void
      {
         mBuyButton.destroy();
         mBuyButtonCash.destroy();
         mBuyButtonCoin.destroy();
         super.destroy();
      }
      
      override protected function getSwfPath() : String
      {
         return "Resources/Art2D/UI/db_UI_screens.swf";
      }
      
      override protected function getClassName() : String
      {
         return "hero_upsell_popup";
      }
      
      protected function get coinOffer() : GMOffer
      {
         return mCoinSaleOffer ? mCoinSaleOffer : mCoinOffer;
      }
      
      private function get offer() : GMOffer
      {
         return mSaleOffer ? mSaleOffer : mGMOffer;
      }
      
      override protected function setupUI(swfAsset:SwfAsset, titleText:String, content:*, allowClose:Boolean, closeCallback:Function) : void
      {
         var i:uint;
         var character:String;
         var screenshot:String;
         var onSale:Boolean;
         super.setupUI(swfAsset,titleText,content,allowClose,closeCallback);
         mTitle.text = Locale.getSubString("HERO_UPSELL_TITLE",mGMHero.Constant);
         mPopup.caption_1_label.text = Locale.getSubString("HERO_UPSELL_CAPTION_1",mGMHero.Constant);
         mPopup.buster_title_label.text = Locale.getSubString("HERO_UPSELL_BUSTER_TITLE",mGMHero.Constant);
         mPopup.buster_message_label.text = Locale.getSubString("HERO_UPSELL_BUSTER_MESSAGE",mGMHero.Constant);
         mAttackStars.push(mPopup.attack_star_0,mPopup.attack_star_1,mPopup.attack_star_2,mPopup.attack_star_3,mPopup.attack_star_4);
         mDefenseStars.push(mPopup.defense_star_0,mPopup.defense_star_1,mPopup.defense_star_2,mPopup.defense_star_3,mPopup.defense_star_4);
         mSpeedStars.push(mPopup.speed_star_0,mPopup.speed_star_1,mPopup.speed_star_2,mPopup.speed_star_3,mPopup.speed_star_4);
         i = 0;
         while(i < mAttackStars.length)
         {
            mAttackStars[i].visible = mGMHero.AttackRating - 1 >= i;
            mDefenseStars[i].visible = mGMHero.DefenseRating - 1 >= i;
            mSpeedStars[i].visible = mGMHero.SpeedRating - 1 >= i;
            i = i + 1;
         }
         mPopup.buy_button_coins.visible = false;
         mPopup.buy_button_gems.visible = false;
         mPopup.label_or.visible = false;
         mPopup.purchase_label.text = Locale.getString("HERO_UPSELL_PURCHASE");
         mPopup.hero_name_label.text = GameMasterLocale.getGameMasterSubString("SKIN_NAME",mGMHero.Constant).toUpperCase();
         mBuyButton = new UIButton(mDBFacade,mPopup.buy_button);
         mBuyButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mBuyButton.releaseCallback = this.buyButtonCallback;
         mBuyButtonCoin = new UIButton(mDBFacade,mPopup.buy_button_coins);
         mBuyButtonCoin.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mBuyButtonCoin.releaseCallback = this.buyButtonCoinCallback;
         mBuyButtonCoin.root.icons_bundle.cash.visible = false;
         mBuyButtonCoin.root.icons_bundle.gift_icon.visible = false;
         mBuyButtonCoin.root.original_price.visible = false;
         mBuyButtonCoin.root.strike.visible = false;
         mBuyButtonCash = new UIButton(mDBFacade,mPopup.buy_button_gems);
         mBuyButtonCash.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mBuyButtonCash.releaseCallback = this.buyButtonCallback;
         mBuyButtonCash.root.icons_bundle.coin.visible = false;
         mBuyButtonCash.root.icons_bundle.gift_icon.visible = false;
         mBuyButtonCash.root.original_price.visible = false;
         mBuyButtonCash.root.strike.visible = false;
         if(offerIsCashPageExclusive())
         {
            mBuyButton.visible = true;
            mBuyButton.label.text = Locale.getString("HERO_UPSELL_EXCLUSIVE_OFFER");
            mBuyButtonCoin.visible = false;
            mBuyButtonCash.visible = false;
            mPopup.label_or.visible = false;
         }
         else if(this.coinOffer)
         {
            mBuyButton.visible = false;
            mBuyButtonCoin.visible = this.coinOffer.Price > 0;
            mBuyButtonCash.visible = this.offer.Price > 0;
            mPopup.label_or.visible = true;
            mBuyButtonCash.label.text = this.offer.Price > 0 ? this.offer.Price.toString() : Locale.getString("SHOP_FREE");
            mBuyButtonCoin.label.text = this.coinOffer.Price > 0 ? this.coinOffer.Price.toString() : Locale.getString("SHOP_FREE");
         }
         else
         {
            mBuyButton.visible = true;
            mBuyButtonCoin.visible = false;
            mBuyButtonCash.visible = false;
            mPopup.label_or.visible = false;
            mBuyButton.label.text = this.offer.Price > 0 ? this.offer.Price.toString() : Locale.getString("SHOP_FREE");
         }
         mPopup.attack_label.text = Locale.getString("HERO_UPSELL_ATTACK");
         mPopup.defense_label.text = Locale.getString("HERO_UPSELL_DEFENSE");
         mPopup.speed_label.text = Locale.getString("HERO_UPSELL_SPEED");
         for(character in SCREENSHOTS)
         {
            for each(screenshot in SCREENSHOTS[character])
            {
               mPopup[screenshot].visible = character == mGMHero.Constant;
            }
         }
         onSale = mSaleOffer != null;
         mPopup.buy_button.original_price.visible = onSale;
         mPopup.buy_button.strike.visible = onSale;
         mPopup.sale_ribbon.visible = onSale;
         mPopup.sale_ribbon_label.visible = onSale;
         mPopup.sale_label.visible = onSale;
         if(onSale)
         {
            mPopup.buy_button.original_price.text = mGMOffer.Price.toString();
            mPopup.sale_label.text = mSaleOffer.percentOff.toString() + Locale.getString("SHOP_PERCENT_OFF");
            mPopup.buy_button.strike.width = mBuyButton.label.textWidth + 4;
         }
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(mGMHero.PortraitName),function(param1:SwfAsset):void
         {
            var _loc3_:Class = param1.getClass(mGMHero.IconName);
            var _loc4_:MovieClip = new _loc3_();
            _loc4_.scaleX = _loc4_.scaleY = 0.82;
            var _loc2_:MovieClipRenderController = new MovieClipRenderController(mDBFacade,_loc4_);
            _loc2_.play();
            var _loc5_:DisplayObjectContainer = mPopup.hero_origin;
            if(_loc5_.numChildren > 0)
            {
               _loc5_.removeChildAt(0);
            }
            _loc5_.addChildAt(_loc4_,0);
         });
      }
      
      private function offerIsCashPageExclusive() : Boolean
      {
         return this.offer.Details[0].HeroId == 108;
      }
      
      private function buyButtonCallback() : void
      {
         return this.buyButtonInternal(this.offer);
      }
      
      private function buyButtonCoinCallback() : void
      {
         return this.buyButtonInternal(this.coinOffer);
      }
      
      private function buyButtonInternal(buyOffer:GMOffer) : void
      {
         if(offerIsCashPageExclusive())
         {
            StoreServicesController.showCashPage(mDBFacade,"heroUpsellPopup");
            return;
         }
         mDBFacade.metrics.log("HeroUpsellPopupPurchaseTry",{"heroId":StoreServicesController.getOfferMetrics(mDBFacade,buyOffer)});
         StoreServicesController.tryBuyOffer(mDBFacade,buyOffer,function(param1:*):void
         {
            mDBFacade.metrics.log("HeroUpsellPopupPurchase",{"heroId":StoreServicesController.getOfferMetrics(mDBFacade,buyOffer)});
            var _loc2_:GMHero = mDBFacade.gameMaster.heroById.itemFor(buyOffer.Details[0].HeroId);
            if(!_loc2_)
            {
               return;
            }
            DBFacebookBragFeedPost.buyHeroSuccess(mTownHeader,_loc2_,mDBFacade,mAssetLoadingComponent);
            close(mCloseCallback);
         });
      }
   }
}

