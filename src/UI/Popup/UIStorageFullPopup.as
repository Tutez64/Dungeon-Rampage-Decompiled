package UI.Popup
{
   import Brain.AssetRepository.SwfAsset;
   import Facade.DBFacade;
   import Facade.Locale;
   
   public class UIStorageFullPopup extends DBUITwoButtonPopup
   {
      
      public static const STORAGE_POPUP_CLASS_NAME:String = "popup_add_storage";
      
      public function UIStorageFullPopup(dbFacade:DBFacade, uiLayerName:String, titleText:String, content:*, leftText:String, leftCallback:Function, rightText:String, rightCallback:Function, allowClose:Boolean = true, closeCallback:Function = null)
      {
         super(dbFacade,uiLayerName,titleText,content,leftText,leftCallback,rightText,rightCallback,allowClose,closeCallback);
      }
      
      override protected function setupUI(swfAsset:SwfAsset, titleText:String, content:*, allowClose:Boolean, closeCallback:Function) : void
      {
         super.setupUI(swfAsset,titleText,content,allowClose,closeCallback);
         Locale.setText(mPopup.title_label,"STORAGE_FULL_TITLE");
         Locale.setText(mPopup.message_label,"STORAGE_FULL_DESCRIPTION");
      }
      
      override protected function getClassName() : String
      {
         return "popup_add_storage";
      }
   }
}

