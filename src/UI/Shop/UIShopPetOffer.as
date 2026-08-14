package UI.Shop
{
   import Facade.DBFacade;
   import Facade.GameMasterLocale;
   import GameMasterDictionary.GMHero;
   import GameMasterDictionary.GMNpc;
   import GameMasterDictionary.GMOffer;
   import GameMasterDictionary.GMOfferDetail;
   
   public class UIShopPetOffer extends UIShopOffer
   {
      
      protected var mGMOfferDetail:GMOfferDetail;
      
      protected var mGMOfferPet:GMNpc;
      
      public function UIShopPetOffer(dbFacade:DBFacade, templateClass:Class, buyCallback:Function = null)
      {
         super(dbFacade,templateClass,buyCallback);
      }
      
      override public function showOffer(gmOffer:GMOffer, gmHero:GMHero) : void
      {
         this.offer = gmOffer;
         mGMOfferDetail = this.offer.Details[0];
         mGMOfferPet = mDBFacade.gameMaster.npcById.itemFor(mGMOfferDetail.PetId);
         super.showOffer(gmOffer,gmHero);
      }
      
      override protected function get nativeIconSize() : Number
      {
         return 68;
      }
      
      override protected function get offerDescription() : String
      {
         return mGMOfferPet ? GameMasterLocale.getGameMasterSubString("PET_DESCRIPTION",mGMOfferPet.Constant) : "";
      }
      
      override protected function get offerIconName() : String
      {
         return mGMOfferPet ? mGMOfferPet.IconName : "";
      }
      
      override protected function get offerSwfPath() : String
      {
         return mGMOfferPet ? mGMOfferPet.IconSwfFilepath : "";
      }
      
      override protected function hasRequirements() : Boolean
      {
         return false;
      }
      
      override protected function requirementsMetForPurchase() : Boolean
      {
         return true;
      }
   }
}

