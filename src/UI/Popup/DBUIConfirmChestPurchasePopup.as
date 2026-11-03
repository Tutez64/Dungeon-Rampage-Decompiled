package UI.Popup
{
   import Brain.AssetRepository.SwfAsset;
   import Brain.Logger.Logger;
   import Brain.UI.UIButton;
   import Brain.UI.UIObject;
   import Brain.Utils.TextUtil;
   import Facade.DBFacade;
   import Facade.Locale;
   import GameMasterDictionary.GMOffer;
   import GameMasterDictionary.GMSkin;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   public class DBUIConfirmChestPurchasePopup extends DBUIPopup
   {
      
      private static const TOWN_PATH:String = "Resources/Art2D/UI/db_UI_town.swf";
      
      private static const POPUP_CLASS_NAME:String = "chest_shop_popup";
      
      private var mChestOffer:GMOffer;
      
      private var mSelectedHeroSkin:GMSkin;
      
      private var mCancelButton:UIButton;
      
      private var mBuyButton:UIButton;
      
      private var mTitleLabel:TextField;
      
      private var mHeroLabel:TextField;
      
      private var mTextContentLabel:TextField;
      
      private var mItemIcon:MovieClip;
      
      private var mAvatarIcon:MovieClip;
      
      private var mBuyCallback:Function;
      
      public function DBUIConfirmChestPurchasePopup(dbFacade:DBFacade, buyCallback:Function, cancelCallback:Function, chestOffer:GMOffer, forHeroSkin:uint, allowClose:Boolean = true, closeCallback:Function = null)
      {
         mChestOffer = chestOffer;
         mBuyCallback = buyCallback;
         mSelectedHeroSkin = dbFacade.gameMaster.skinsById.itemFor(forHeroSkin) as GMSkin;
         if(mSelectedHeroSkin == null)
         {
            Logger.error("Unable to find GMSkin for skin id: " + forHeroSkin);
         }
         super(dbFacade,"CONFIRM_CHEST_PURCHASE_POPUP","",null,allowClose,true,cancelCallback,false,false);
      }
      
      override protected function getSwfPath() : String
      {
         return "Resources/Art2D/UI/db_UI_town.swf";
      }
      
      override protected function getClassName() : String
      {
         return "chest_shop_popup";
      }
      
      override protected function setupUI(swfAsset:SwfAsset, titleText:String, content:*, allowClose:Boolean, closeCallback:Function) : void
      {
         mSwfAsset = swfAsset;
         var popupClass:Class = swfAsset.getClass("chest_shop_popup");
         mPopup = new popupClass() as MovieClip;
         mRoot.addChild(mPopup);
         mCloseButton = new UIButton(mFacade,mPopup.close);
         mCloseButton.releaseCallback = handleInputCalledClosed;
         mCancelButton = new UIButton(mFacade,mPopup.button_cancel);
         mCancelButton.releaseCallback = handleInputCalledClosed;
         Locale.setText(mCancelButton.label,"CANCEL");
         mBuyButton = new UIButton(mFacade,mPopup.buy_button_gems);
         mBuyButton.releaseCallback = mBuyCallback;
         TextUtil.setText(mBuyButton.label,mChestOffer.Price.toString());
         mBuyButton.root.original_price.visible = false;
         mBuyButton.root.icons_bundle.coin.visible = false;
         mBuyButton.root.icons_bundle.gift_icon.visible = false;
         mBuyButton.root.strike.visible = false;
         mTitleLabel = mPopup.label;
         Locale.setText(mTitleLabel,"CONFIRM_SHOP_CHEST_PURCHASE");
         mItemIcon = mPopup.icon_slot;
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(mChestOffer.BundleSwfFilepath),function(param1:SwfAsset):void
         {
            var _loc3_:Class = param1.getClass(mChestOffer.BundleIcon);
            var _loc2_:MovieClip = new _loc3_();
            mItemIcon.addChild(_loc2_);
         });
         mHeroLabel = mPopup.hero_label;
         Locale.setText(mHeroLabel,"OPENING_WITH");
         mTextContentLabel = mPopup.text;
         Locale.setText(mTextContentLabel,"PURCHASE_AND_OPEN_CHEST_TEXT_CONTENT");
         mAvatarIcon = mPopup.avatar;
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(mSelectedHeroSkin.IconSwfFilepath),function(param1:SwfAsset):void
         {
            var _loc2_:Class = param1.getClass(mSelectedHeroSkin.IconName);
            var _loc3_:MovieClip = new _loc2_();
            mAvatarIcon.addChild(_loc3_);
         });
         mPopup.x = mFacade.viewWidth * 0.5;
         mPopup.y = mFacade.viewHeight * 0.5 - 50;
      }
      
      override protected function setupMenuNavigation() : void
      {
         mBuyButton.isToTheLeftOf(mCancelButton);
         mCloseButton.isAbove(mBuyButton);
      }
      
      override protected function getDefaultNavigationObject() : UIObject
      {
         return mCloseButton;
      }
      
      override protected function getInitialFocusedNavigationObject() : UIObject
      {
         return mBuyButton;
      }
      
      override public function destroy() : void
      {
         if(mDBFacade == null)
         {
            return;
         }
         if(mCloseButton != null)
         {
            mCloseButton.destroy();
            mCloseButton = null;
         }
         if(mCancelButton != null)
         {
            mCancelButton.destroy();
            mCancelButton = null;
         }
         if(mBuyButton != null)
         {
            mBuyButton.destroy();
            mBuyButton = null;
         }
         super.destroy();
      }
   }
}

