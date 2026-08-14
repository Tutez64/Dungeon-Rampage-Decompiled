package UI.Shop
{
   import Account.AvatarInfo;
   import Brain.UI.UIButton;
   import Facade.DBFacade;
   import Facade.GameMasterLocale;
   import GameMasterDictionary.GMHero;
   import GameMasterDictionary.GMOffer;
   import GameMasterDictionary.GMOfferDetail;
   import GameMasterDictionary.GMSkin;
   
   public class UIShopSkinOffer extends UIShopOffer
   {
      
      protected var mGMOfferDetail:GMOfferDetail;
      
      protected var mGMOfferSkin:GMSkin;
      
      protected var mInfoButton:UIButton;
      
      public function UIShopSkinOffer(dbFacade:DBFacade, templateClass:Class, buyCallback:Function = null)
      {
         super(dbFacade,templateClass,buyCallback);
      }
      
      private function showInfo() : void
      {
      }
      
      override public function showOffer(gmOffer:GMOffer, gmHero:GMHero) : void
      {
         this.offer = gmOffer;
         mGMOfferDetail = this.offer.Details[0];
         mGMOfferSkin = mDBFacade.gameMaster.getSkinByType(mGMOfferDetail.SkinId);
         mHeroRequiredLabel.visible = !ownsRequiredHero();
         super.showOffer(gmOffer,gmHero);
      }
      
      override protected function get nativeIconSize() : Number
      {
         return 72;
      }
      
      override protected function get offerDescription() : String
      {
         return mGMOfferSkin ? GameMasterLocale.getGameMasterSubString("SKIN_STORE_DESCRIPTION",mGMOfferSkin.Constant) : "";
      }
      
      override protected function get offerIconName() : String
      {
         return mGMOfferSkin ? mGMOfferSkin.IconName : "";
      }
      
      override protected function get offerSwfPath() : String
      {
         var _loc1_:String = "";
         if(mGMOfferSkin != null)
         {
            _loc1_ = mGMOfferSkin.UISwfFilepath;
         }
         return _loc1_;
      }
      
      override protected function hasRequirements() : Boolean
      {
         return false;
      }
      
      override protected function requirementsMetForPurchase() : Boolean
      {
         if(!mDBFacade.dbAccountInfo.inventoryInfo.ownsItem(mGMOfferDetail.SkinId))
         {
            return ownsRequiredHero();
         }
         return false;
      }
      
      override protected function shouldGreyOffer(gmHero:GMHero) : Boolean
      {
         return !ownsRequiredHero();
      }
      
      private function ownsRequiredHero() : Boolean
      {
         var _loc2_:GMHero = mDBFacade.gameMaster.heroByConstant.itemFor(mGMOfferSkin.ForHero);
         var _loc1_:AvatarInfo = mDBFacade.dbAccountInfo.inventoryInfo.getAvatarInfoForHeroType(_loc2_.Id);
         return _loc1_ != null;
      }
      
      override public function destroy() : void
      {
         if(mInfoButton)
         {
            mInfoButton.destroy();
            mInfoButton = null;
         }
      }
   }
}

