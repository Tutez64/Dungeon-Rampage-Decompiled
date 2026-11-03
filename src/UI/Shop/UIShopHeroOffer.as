package UI.Shop
{
   import DBGlobals.DBGlobal;
   import Facade.DBFacade;
   import Facade.GameMasterLocale;
   import GameMasterDictionary.GMHero;
   import GameMasterDictionary.GMOffer;
   import GameMasterDictionary.GMOfferDetail;
   import GameMasterDictionary.GMSkin;
   
   public class UIShopHeroOffer extends UIShopOffer
   {
      
      protected var mGMOfferDetail:GMOfferDetail;
      
      protected var mGMOfferHero:GMHero;
      
      public function UIShopHeroOffer(dbFacade:DBFacade, templateClass:Class, buyCallback:Function = null)
      {
         super(dbFacade,templateClass,buyCallback);
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
         return DBGlobal.HERO_ICON_NATIVE_SIZE;
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

