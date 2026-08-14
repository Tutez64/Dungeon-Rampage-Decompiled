package UI.Inventory
{
   import Brain.AssetRepository.SwfAsset;
   import Brain.Logger.Logger;
   import Facade.DBFacade;
   import Facade.GameMasterLocale;
   import Facade.Locale;
   import GameMasterDictionary.GMHero;
   import GameMasterDictionary.GMNpc;
   import GameMasterDictionary.GMOffer;
   import GameMasterDictionary.GMOfferDetail;
   import GameMasterDictionary.GMSkin;
   import GameMasterDictionary.GMWeaponAesthetic;
   import GameMasterDictionary.GMWeaponItem;
   import UI.Popup.DBUITwoButtonPopup;
   import flash.display.MovieClip;
   
   public class UIPurchaseOfferPopup extends DBUITwoButtonPopup
   {
      
      private var mPopupClassName:String;
      
      private var mGMOffer:GMOffer;
      
      public function UIPurchaseOfferPopup(dbFacade:DBFacade, popupClassName:String, titleText:String, offer:GMOffer, leftText:String, leftCallback:Function, rightText:String, rightCallback:Function, allowClose:Boolean = true, closeCallback:Function = null)
      {
         mGMOffer = offer;
         mPopupClassName = popupClassName;
         super(dbFacade,titleText,null,leftText,leftCallback,rightText,rightCallback,allowClose,closeCallback);
      }
      
      override public function destroy() : void
      {
         super.destroy();
      }
      
      override protected function getClassName() : String
      {
         return mPopupClassName;
      }
      
      override protected function setupUI(swfAsset:SwfAsset, titleText:String, content:*, allowClose:Boolean, closeCallback:Function) : void
      {
         var swfPath:String;
         var iconName:String;
         var offerName:String;
         var offerDetail:GMOfferDetail;
         var weaponItem:GMWeaponItem;
         var weaponAesthetic:GMWeaponAesthetic;
         var hero:GMHero;
         var defaultSkin:GMSkin;
         var pet:GMNpc;
         var skin:GMSkin;
         super.setupUI(swfAsset,titleText,content,allowClose,closeCallback);
         offerName = "";
         mPopup.power.visible = false;
         if(mGMOffer.IsBundle)
         {
            offerName = mGMOffer.BundleName;
            swfPath = mGMOffer.BundleSwfFilepath;
            iconName = mGMOffer.BundleIcon;
         }
         else
         {
            offerDetail = mGMOffer.Details[0];
            if(offerDetail.WeaponId)
            {
               weaponItem = mDBFacade.gameMaster.weaponItemById.itemFor(offerDetail.WeaponId);
               weaponAesthetic = weaponItem.getWeaponAesthetic(offerDetail.Level);
               offerName = GameMasterLocale.getGameMasterSubString("WEAPON_AESTHETIC_NAME",weaponAesthetic.Constant);
               swfPath = weaponAesthetic.IconSwf;
               iconName = weaponAesthetic.IconName;
               mPopup.power.visible = true;
               mPopup.power.label.text = offerDetail.WeaponPower;
               mPopup.power.attack_label.text = Locale.getString("POWER");
            }
            else if(offerDetail.HeroId)
            {
               hero = mDBFacade.gameMaster.heroById.itemFor(offerDetail.HeroId);
               defaultSkin = mDBFacade.gameMaster.getSkinByConstant(hero.DefaultSkin);
               if(defaultSkin)
               {
                  offerName = GameMasterLocale.getGameMasterSubString("SKIN_NAME",defaultSkin.Constant);
                  swfPath = defaultSkin.UISwfFilepath;
                  iconName = defaultSkin.IconName;
               }
            }
            else if(offerDetail.PetId)
            {
               pet = mDBFacade.gameMaster.npcById.itemFor(offerDetail.PetId);
               offerName = GameMasterLocale.getGameMasterSubString("PET_NAME",pet.Constant);
               swfPath = pet.IconSwfFilepath;
               iconName = pet.IconName;
            }
            else if(offerDetail.SkinId)
            {
               skin = mDBFacade.gameMaster.getSkinByType(offerDetail.SkinId);
               offerName = GameMasterLocale.getGameMasterSubString("SKIN_NAME",skin.Constant);
               swfPath = skin.UISwfFilepath;
               iconName = skin.IconName;
            }
         }
         if(swfPath && iconName)
         {
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(swfPath),function(param1:SwfAsset):void
            {
               var _loc3_:Class = param1.getClass(iconName);
               if(_loc3_ == null)
               {
                  Logger.error("Unable to get iconClass for iconName: " + iconName);
                  return;
               }
               var _loc2_:MovieClip = new _loc3_();
               _loc2_.scaleX = _loc2_.scaleY = 70 / 100;
               mPopup.item_icon.addChild(_loc2_);
            });
         }
         if(mPopup.message_label != null)
         {
            mPopup.message_label.text = offerName;
         }
         mPopup.cash.visible = mGMOffer.Price > 0 && mGMOffer.CurrencyType == "PREMIUM";
         mPopup.coin.visible = mGMOffer.Price > 0 && mGMOffer.CurrencyType == "BASIC";
         mPopup.price.text = mGMOffer.Price > 0 ? mGMOffer.Price.toString() : Locale.getString("SHOP_FREE");
      }
   }
}

