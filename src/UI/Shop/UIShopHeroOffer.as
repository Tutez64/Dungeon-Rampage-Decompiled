package UI.Shop
{
   import Brain.UI.UIButton;
   import Brain.Utils.MemoryTracker;
   import Facade.DBFacade;
   import Facade.GameMasterLocale;
   import GameMasterDictionary.GMHero;
   import GameMasterDictionary.GMOffer;
   import GameMasterDictionary.GMOfferDetail;
   import GameMasterDictionary.GMSkin;
   import Town.TownHeader;
   import UI.*;
   import UI.Popup.UIHeroUpsellPopup;
   
   public class UIShopHeroOffer extends UIShopOffer
   {
      
      protected var mGMOfferDetail:GMOfferDetail;
      
      protected var mGMOfferHero:GMHero;
      
      protected var mInfoButton:UIButton;
      
      private var mTownHeader:TownHeader;
      
      public function UIShopHeroOffer(townHeader:TownHeader, dbFacade:DBFacade, templateClass:Class, buyCallback:Function = null)
      {
         super(dbFacade,templateClass,buyCallback);
         mInfoButton = new UIButton(mDBFacade,mRoot.icon);
         mInfoButton.releaseCallback = this.showInfo;
         mTownHeader = townHeader;
      }
      
      private function showInfo() : void
      {
         var _loc1_:UIHeroUpsellPopup = null;
         if(this.requirementsMetForPurchase())
         {
            _loc1_ = new UIHeroUpsellPopup(mTownHeader,mDBFacade,this.offer,null);
            MemoryTracker.track(_loc1_,"UIHeroUpsellPopup - created in UIShopHeroOffer.showInfo()");
         }
      }
      
      override public function destroy() : void
      {
         if(mInfoButton)
         {
            mInfoButton.destroy();
            mInfoButton = null;
         }
      }
      
      override public function showOffer(gmOffer:GMOffer, gmHero:GMHero) : void
      {
         this.offer = gmOffer;
         mGMOfferDetail = this.offer.Details[0];
         mGMOfferHero = mDBFacade.gameMaster.heroById.itemFor(mGMOfferDetail.HeroId);
         super.showOffer(gmOffer,gmHero);
      }
      
      override protected function IsCashPageExclusiveOffer() : Boolean
      {
         return mGMOfferHero.IsExclusive;
      }
      
      override protected function get nativeIconSize() : Number
      {
         return 72;
      }
      
      override protected function get offerDescription() : String
      {
         return mGMOfferHero ? GameMasterLocale.getGameMasterSubString("SKIN_STORE_DESCRIPTION",mGMOfferHero.Constant) : "";
      }
      
      override protected function get offerIconName() : String
      {
         return mGMOfferHero ? mGMOfferHero.IconName : "";
      }
      
      override protected function get offerSwfPath() : String
      {
         var _loc2_:GMSkin = null;
         var _loc1_:String = "";
         if(mGMOfferHero != null)
         {
            _loc2_ = mDBFacade.gameMaster.getSkinByConstant(mGMOfferHero.DefaultSkin);
            _loc1_ = _loc2_.UISwfFilepath;
         }
         return _loc1_;
      }
      
      override protected function hasRequirements() : Boolean
      {
         return false;
      }
      
      override protected function requirementsMetForPurchase() : Boolean
      {
         return !mDBFacade.dbAccountInfo.inventoryInfo.ownsItem(mGMOfferDetail.HeroId);
      }
   }
}

