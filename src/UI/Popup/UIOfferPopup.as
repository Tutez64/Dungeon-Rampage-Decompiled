package UI.Popup
{
   import Brain.AssetRepository.SwfAsset;
   import Brain.UI.UIButton;
   import Brain.UI.UIObject;
   import Brain.Utils.TextUtil;
   import DBGlobals.DBGlobal;
   import Facade.DBFacade;
   import GameMasterDictionary.GMOffer;
   import UI.Shop.UIShopBundleOffer;
   import UI.Shop.UIShopOffer;
   import flash.display.MovieClip;
   
   public class UIOfferPopup extends DBUIPopup
   {
      
      private static const TEMPLATE_CLASSNAME:String = "shop_offer_template";
      
      private static const PREMIUM_TEMPLATE_CLASSNAME:String = "shop_offer_premium_template";
      
      private static const DLC_TEMPLATE_CLASSNAME:String = "shop_offer_dlc_template";
      
      private static const POPUP_CLASS_NAME:String = "coin_purchase_popup";
      
      protected var mOfferIds:Vector.<uint>;
      
      protected var mBuyCallback:Function;
      
      protected var mOfferTemplateClass:Class;
      
      protected var mPremiumOfferTemplateClass:Class;
      
      protected var mDLCOfferTemplateClass:Class;
      
      protected var mUIOffers:Vector.<UIShopOffer> = new Vector.<UIShopOffer>();
      
      protected var mEmptyOffers:Vector.<MovieClip> = new Vector.<MovieClip>();
      
      private var mUseIconScaling:Boolean;
      
      private var mWantNewRollOverScale:Boolean;
      
      public function UIOfferPopup(dbFacade:DBFacade, titleText:String, offerIds:Vector.<uint>, buyCallback:Function, closeCallback:Function, useIconScaling:Boolean = true, wantNewRollOverScale:Boolean = true, navigationLayerName:String = "POPUP_OFFER")
      {
         mOfferIds = offerIds;
         mBuyCallback = buyCallback;
         mUseIconScaling = useIconScaling;
         mWantNewRollOverScale = wantNewRollOverScale;
         super(dbFacade,navigationLayerName,titleText,null,true,true,closeCallback,false);
      }
      
      override public function destroy() : void
      {
         mBuyCallback = null;
         mUIOffers = null;
         mEmptyOffers = null;
         mOfferTemplateClass = null;
         super.destroy();
      }
      
      override protected function getClassName() : String
      {
         return "coin_purchase_popup";
      }
      
      override protected function setupUI(swfAsset:SwfAsset, titleText:String, content:*, allowClose:Boolean, closeCallback:Function) : void
      {
         var offerId:uint;
         var emptyOffer:MovieClip;
         var gmOffer:GMOffer;
         var uiShopOffer:UIShopBundleOffer;
         var offerClass:Class;
         var i:uint;
         var callback:*;
         var popupClass:Class = swfAsset.getClass(this.getClassName());
         mPopup = new popupClass();
         mRoot.addChild(mPopup);
         mPopup.scaleY = mPopup.scaleX = DBGlobal.UI_16_TO_9_PORT_OBJECT_SCALE;
         centerPopup();
         mTitle = mPopup.title_label;
         TextUtil.setText(mTitle,titleText);
         mEmptyOffers.push(mPopup.coin_shop_empty_slot_1);
         mEmptyOffers.push(mPopup.coin_shop_empty_slot_2);
         mEmptyOffers.push(mPopup.coin_shop_empty_slot_3);
         mOfferTemplateClass = swfAsset.getClass("shop_offer_template");
         mPremiumOfferTemplateClass = swfAsset.getClass("shop_offer_premium_template");
         mDLCOfferTemplateClass = swfAsset.getClass("shop_offer_dlc_template");
         i = 0;
         while(i < mOfferIds.length)
         {
            callback = function(param1:GMOffer):void
            {
               close(mBuyCallback,param1);
            };
            offerId = mOfferIds[i];
            gmOffer = mDBFacade.gameMaster.offerById.itemFor(offerId);
            offerClass = gmOffer.CurrencyType == GMOffer.PREMIUM_CURRENCY && gmOffer.Price ? mPremiumOfferTemplateClass : mOfferTemplateClass;
            uiShopOffer = new UIShopBundleOffer(mDBFacade,offerClass,callback,mUseIconScaling,mWantNewRollOverScale);
            emptyOffer = mEmptyOffers[i];
            emptyOffer.parent.addChild(uiShopOffer.root);
            uiShopOffer.root.x = emptyOffer.x;
            uiShopOffer.root.y = emptyOffer.y;
            mUIOffers[i] = uiShopOffer;
            uiShopOffer.showOffer(gmOffer,null);
            uiShopOffer.root.visible = true;
            mEmptyOffers[i].visible = false;
            i = i + 1;
         }
         mCloseButton = new UIButton(mDBFacade,mPopup.close);
         mCloseButton.releaseCallback = function():void
         {
            close(closeCallback);
         };
         animatedEntrance();
      }
      
      override protected function setupMenuNavigation() : void
      {
         var _loc2_:uint = 0;
         var _loc1_:Vector.<UIButton> = getNavigationButtons();
         for each(var _loc3_:UIButton in _loc1_)
         {
            _loc3_.clearNavigationAndInteractions();
         }
         mCloseButton.clearNavigationAndInteractions();
         _loc2_ = 0;
         while(_loc2_ < _loc1_.length)
         {
            _loc1_[_loc2_].upNavigation = mCloseButton;
            if(_loc2_ > 0)
            {
               _loc1_[_loc2_ - 1].isToTheLeftOf(_loc1_[_loc2_]);
            }
            _loc2_++;
         }
         if(_loc1_.length > 0)
         {
            mCloseButton.downNavigation = _loc1_[0];
         }
      }
      
      override protected function getInitialFocusedNavigationObject() : UIObject
      {
         var _loc1_:Vector.<UIButton> = getNavigationButtons();
         return _loc1_.length > 0 ? _loc1_[0] : mCloseButton;
      }
      
      private function getNavigationButtons() : Vector.<UIButton>
      {
         var _loc1_:Vector.<UIButton> = new Vector.<UIButton>();
         for each(var _loc2_:UIShopOffer in mUIOffers)
         {
            if(_loc2_.navigationButton != null)
            {
               _loc1_.push(_loc2_.navigationButton);
            }
         }
         return _loc1_;
      }
   }
}

