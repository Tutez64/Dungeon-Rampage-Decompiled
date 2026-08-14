package UI.Popup
{
   import Brain.AssetRepository.SwfAsset;
   import Facade.DBFacade;
   import Facade.Locale;
   
   public class UIRetrainPopup extends DBUITwoButtonPopup
   {
      
      protected static const SWF_PATH:String = "Resources/Art2D/UI/db_UI_town.swf";
      
      protected static const POPUP_CLASS_NAME:String = "popup_retrain";
      
      private var mPrice:uint;
      
      public function UIRetrainPopup(dbFacade:DBFacade, leftCallback:Function, price:uint)
      {
         mPrice = price;
         super(dbFacade,Locale.getString("RETRAIN_POPUP_TITLE"),Locale.getString("RETRAIN_POPUP_MESSAGE"),Locale.getString("RETRAIN_BUY"),leftCallback,Locale.getString("CANCEL"),null,true,null,true,true,"RETRAIN_POPUP");
      }
      
      override protected function setupUI(swfAsset:SwfAsset, titleText:String, content:*, allowClose:Boolean, closeCallback:Function) : void
      {
         super.setupUI(swfAsset,titleText,content,allowClose,closeCallback);
         mLeftButton.label.text = mPrice.toString();
      }
      
      override protected function getSwfPath() : String
      {
         return "Resources/Art2D/UI/db_UI_town.swf";
      }
      
      override protected function getClassName() : String
      {
         return "popup_retrain";
      }
      
      override protected function setupMenuNavigation() : void
      {
         mCloseButton.clearNavigationAndInteractions();
         mLeftButton.clearNavigationAndInteractions();
         mRightButton.clearNavigationAndInteractions();
         mRightButton.isToTheLeftOf(mLeftButton);
         mCloseButton.isAbove(mRightButton);
         mLeftButton.upNavigation = mCloseButton;
         mDBFacade.menuNavigationController.pushNewLayer(mUILayerName,mCloseCallback,mCloseButton);
      }
   }
}

