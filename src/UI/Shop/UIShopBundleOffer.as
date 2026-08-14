package UI.Shop
{
   import Account.StoreServicesController;
   import Facade.DBFacade;
   import Facade.GameMasterLocale;
   
   public class UIShopBundleOffer extends UIShopOffer
   {
      
      public function UIShopBundleOffer(dbFacade:DBFacade, templateClass:Class, buyCallback:Function = null, useIconScaling:Boolean = true, wantNewRollOverScale:Boolean = true)
      {
         super(dbFacade,templateClass,buyCallback,useIconScaling,wantNewRollOverScale);
      }
      
      override protected function get offerDescription() : String
      {
         return GameMasterLocale.getGameMasterSubString("BUNDLE_OFFER_DESCRIPTION",this.offer.Id.toString());
      }
      
      override protected function get offerIconName() : String
      {
         return this.offer.BundleIcon;
      }
      
      override protected function get offerSwfPath() : String
      {
         return this.offer.BundleSwfFilepath;
      }
      
      override protected function hasRequirements() : Boolean
      {
         return false;
      }
      
      override protected function requirementsMetForPurchase() : Boolean
      {
         return !StoreServicesController.alreadyOwns(mDBFacade,this.offer);
      }
   }
}

