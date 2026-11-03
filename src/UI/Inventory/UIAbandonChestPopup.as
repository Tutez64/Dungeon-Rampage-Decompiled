package UI.Inventory
{
   import Facade.DBFacade;
   import Facade.Locale;
   import UI.Popup.DBUITwoButtonPopup;
   
   public class UIAbandonChestPopup extends DBUITwoButtonPopup
   {
      
      private var mCancelCallback:Function;
      
      public function UIAbandonChestPopup(dbFacade:DBFacade, cancelCallback:Function, confirmCallback:Function)
      {
         super(dbFacade,"ABANDON_CHEST_POPUP",Locale.getString("ABANDON_CHEST_POPUP_TITLE"),Locale.getString("ABANDON_CHEST_POPUP_DESC"),Locale.getString("ABANDON_CHEST_POPUP_CANCEL"),cancelCallback,Locale.getString("ABANDON_CHEST_POPUP_CONFIRM"),confirmCallback,false,cancelCallback);
         mCancelCallback = cancelCallback;
      }
      
      override public function destroy() : void
      {
         mCancelCallback = null;
         super.destroy();
      }
      
      override protected function handleInputCalledClosed() : void
      {
         close(mCancelCallback);
      }
   }
}

