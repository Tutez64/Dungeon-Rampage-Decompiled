package UI.Popup
{
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Logger.Logger;
   import Brain.SceneGraph.SceneGraphComponent;
   import Brain.UI.UIButton;
   import Brain.UI.UIObject;
   import Facade.DBFacade;
   import Facade.Locale;
   import GameMasterDictionary.GMOffer;
   import GameMasterDictionary.GMSkin;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   public class DBUIConfirmChestPurchasePopup extends UIObject
   {
      
      private var mAssetLoadingComponent:AssetLoadingComponent;
      
      private var mSceneGraphComponent:SceneGraphComponent;
      
      private var mChestOffer:GMOffer;
      
      private var mSelectedHeroSkin:GMSkin;
      
      private var mCloseButton:UIButton;
      
      private var mCancelButton:UIButton;
      
      private var mBuyButton:UIButton;
      
      private var mTitleLabel:TextField;
      
      private var mHeroLabel:TextField;
      
      private var mTextContentLabel:TextField;
      
      private var mItemIcon:MovieClip;
      
      private var mAvatarIcon:MovieClip;
      
      private var mBuyCallback:Function;
      
      private var mCloseCallback:Function;
      
      public function DBUIConfirmChestPurchasePopup(dbFacade:DBFacade, root:MovieClip, buyCallback:Function, cancelCallback:Function, chestOffer:GMOffer, forHeroSkin:uint, allowClose:Boolean = true, closeCallback:Function = null)
      {
         super(dbFacade,root);
         mAssetLoadingComponent = new AssetLoadingComponent(mFacade);
         mSceneGraphComponent = new SceneGraphComponent(mFacade,"DBUIConfirmChestPurchasePopup");
         mChestOffer = chestOffer;
         mCloseCallback = cancelCallback;
         mBuyCallback = buyCallback;
         mSelectedHeroSkin = dbFacade.gameMaster.skinsById.itemFor(forHeroSkin) as GMSkin;
         if(mSelectedHeroSkin == null)
         {
            Logger.error("Unable to find GMSkin for skin id: " + forHeroSkin);
         }
         setupGui();
      }
      
      private function setupGui() : void
      {
         mCloseButton = new UIButton(mFacade,mRoot.close);
         mCloseButton.releaseCallback = mCloseCallback;
         mCancelButton = new UIButton(mFacade,mRoot.button_cancel);
         mCancelButton.releaseCallback = mCloseCallback;
         mCancelButton.label.text = Locale.getString("CANCEL");
         mBuyButton = new UIButton(mFacade,mRoot.buy_button_gems);
         mBuyButton.releaseCallback = mBuyCallback;
         mBuyButton.label.text = mChestOffer.Price.toString();
         mBuyButton.root.original_price.visible = false;
         mBuyButton.root.icons_bundle.coin.visible = false;
         mBuyButton.root.icons_bundle.gift_icon.visible = false;
         mBuyButton.root.strike.visible = false;
         mTitleLabel = mRoot.label;
         mTitleLabel.text = Locale.getString("CONFIRM_SHOP_CHEST_PURCHASE");
         mItemIcon = mRoot.icon_slot;
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(mChestOffer.BundleSwfFilepath),function(param1:SwfAsset):void
         {
            var _loc3_:Class = param1.getClass(mChestOffer.BundleIcon);
            var _loc2_:MovieClip = new _loc3_();
            mItemIcon.addChild(_loc2_);
         });
         mHeroLabel = mRoot.hero_label;
         mHeroLabel.text = Locale.getString("OPENING_WITH");
         mTextContentLabel = mRoot.text;
         mTextContentLabel.text = Locale.getString("PURCHASE_AND_OPEN_CHEST_TEXT_CONTENT");
         mAvatarIcon = mRoot.avatar;
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(mSelectedHeroSkin.IconSwfFilepath),function(param1:SwfAsset):void
         {
            var _loc2_:Class = param1.getClass(mSelectedHeroSkin.IconName);
            var _loc3_:MovieClip = new _loc2_();
            mAvatarIcon.addChild(_loc3_);
         });
         mSceneGraphComponent.addChild(mRoot,105);
         mSceneGraphComponent.showPopupCurtain();
         mRoot.x = mFacade.viewWidth * 0.5;
         mRoot.y = mFacade.viewHeight * 0.5 - 50;
      }
      
      private function close() : void
      {
         this.destroy();
      }
      
      override public function destroy() : void
      {
         super.destroy();
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
         if(mAssetLoadingComponent != null)
         {
            mAssetLoadingComponent.destroy();
            mAssetLoadingComponent = null;
         }
         if(mSceneGraphComponent != null)
         {
            mSceneGraphComponent.removePopupCurtain();
            mSceneGraphComponent.removeChild(mRoot);
            mSceneGraphComponent.destroy();
            mSceneGraphComponent = null;
         }
      }
   }
}

