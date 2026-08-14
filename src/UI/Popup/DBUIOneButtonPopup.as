package UI.Popup
{
   import Brain.AssetRepository.SwfAsset;
   import Brain.UI.UIButton;
   import DBGlobals.DBGlobal;
   import Facade.DBFacade;
   
   public class DBUIOneButtonPopup extends DBUIPopup
   {
      
      protected var mCenterButton:UIButton;
      
      protected var mCenterCallback:Function;
      
      protected var mCenterText:String;
      
      protected var mClassOverride:String;
      
      protected var mSwfOverride:String;
      
      public function DBUIOneButtonPopup(dbFacade:DBFacade, titleText:String, content:*, centerText:String, centerCallback:Function, allowClose:Boolean = true, closeCallback:Function = null, classOverride:String = null, swfOverride:String = null, scalePopup:Boolean = true, UILayerName:String = "")
      {
         mClassOverride = classOverride;
         mSwfOverride = swfOverride;
         mCenterText = centerText;
         mCenterCallback = centerCallback;
         super(dbFacade,titleText,content,allowClose,true,closeCallback,true,scalePopup,UILayerName);
      }
      
      override public function destroy() : void
      {
         if(mCenterButton)
         {
            mCenterButton.destroy();
            mCenterButton = null;
         }
         mCenterCallback = null;
         super.destroy();
      }
      
      override protected function setupUI(swfAsset:SwfAsset, titleText:String, content:*, allowClose:Boolean, closeCallback:Function) : void
      {
         super.setupUI(swfAsset,titleText,content,allowClose,closeCallback);
         if(mCenterText)
         {
            mPopup.center_button.visible = true;
            mCenterButton = new UIButton(mDBFacade,mPopup.center_button);
            mCenterButton.label.text = mCenterText;
            mCenterButton.releaseCallback = this.centerButtonCallback;
            mCenterButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
            setupMenuNavigation();
         }
         else if(mPopup.center_button)
         {
            mPopup.center_button.visible = false;
         }
      }
      
      protected function centerButtonCallback() : void
      {
         this.close(mCenterCallback);
      }
      
      override protected function getClassName() : String
      {
         if(mClassOverride)
         {
            return mClassOverride;
         }
         return "popup";
      }
      
      override protected function getSwfPath() : String
      {
         if(mSwfOverride)
         {
            return mSwfOverride;
         }
         return super.getSwfPath();
      }
      
      override protected function setupMenuNavigation() : void
      {
         if(mCloseButton)
         {
            mCloseButton.isAbove(mCenterButton);
            mCenterButton.isToTheLeftOf(mCloseButton);
         }
      }
   }
}

