package UI.Shop
{
   import Account.AvatarInfo;
   import Account.StoreServicesController;
   import Brain.Logger.Logger;
   import Brain.Utils.MemoryTracker;
   import Facade.DBFacade;
   import GameMasterDictionary.GMChest;
   import UI.Inventory.Chests.ChestRevealPopUp;
   import UI.Popup.DBUIConfirmChestPurchasePopup;
   
   public class UIChestOffer extends UIShopBundleOffer
   {
      
      private var mConfirmPurchaseChestPopup:DBUIConfirmChestPurchasePopup;
      
      private var mGMChest:GMChest;
      
      private var mSelectedAvatarInfo:AvatarInfo;
      
      public function UIChestOffer(dbFacade:DBFacade, templateClass:Class, selectedAvatarInfo:AvatarInfo, buySuccessCallback:Function = null)
      {
         super(dbFacade,templateClass,buySuccessCallback);
         mSelectedAvatarInfo = selectedAvatarInfo;
      }
      
      override protected function buyButtonCallback() : void
      {
         mGMChest = mDBFacade.gameMaster.chestsById.itemFor(this.offer.Details[0].ChestId);
         if(mGMChest == null)
         {
            Logger.error("Unable to find GMChest for chestId: " + this.offer.Details[0].ChestId);
         }
         mConfirmPurchaseChestPopup = new DBUIConfirmChestPurchasePopup(mDBFacade,purchaseChest,close,offer,mSelectedAvatarInfo.skinId,true,null);
         MemoryTracker.track(mConfirmPurchaseChestPopup,"DBUIConfirmChestPurchasePopup - created in UIChestOffer.buyButtonCallback()");
      }
      
      private function purchaseChest() : void
      {
         StoreServicesController.tryBuyOffer(mDBFacade,this.offer,workAroundForOfferBeingDestroyed(mDBFacade,mGMChest),mSelectedAvatarInfo.id);
      }
      
      private function workAroundForOfferBeingDestroyed(dbFacade:DBFacade, gmChest:GMChest) : Function
      {
         return function(param1:*):void
         {
            var details:* = param1;
            var selfManagedPopup:ChestRevealPopUp = new ChestRevealPopUp(dbFacade,gmChest,function():void
            {
               selfManagedPopup.destroy();
            },null);
            selfManagedPopup.updateRevealLoot(details);
         };
      }
      
      private function close() : void
      {
         mConfirmPurchaseChestPopup.destroy();
      }
      
      override public function destroy() : void
      {
         if(mConfirmPurchaseChestPopup)
         {
            mConfirmPurchaseChestPopup.destroy();
         }
         super.destroy();
      }
   }
}

