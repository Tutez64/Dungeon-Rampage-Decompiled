package UI.Popup
{
   import Account.StoreServicesController;
   import Brain.AssetRepository.SwfAsset;
   import Facade.DBFacade;
   import Facade.Locale;
   
   public class UIGiftPage extends UIOfferPopup
   {
      
      public function UIGiftPage(dbFacade:DBFacade, buyCallback:Function, closeCallback:Function)
      {
         super(dbFacade,Locale.getString("SHOP_GIFT_PAGE_TITLE"),StoreServicesController.GIFT_OFFERS,buyCallback,closeCallback,false,false);
         if(mBuyCallback == null)
         {
            mBuyCallback = function():void
            {
               close(null);
            };
         }
      }
      
      override protected function setupUI(swfAsset:SwfAsset, titleText:String, content:*, allowClose:Boolean, closeCallback:Function) : void
      {
         super.setupUI(swfAsset,titleText,content,allowClose,closeCallback);
      }
   }
}

