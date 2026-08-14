package Brain.UI
{
   import Brain.Facade.Facade;
   import Brain.Utils.MemoryTracker;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   public class UIPopup extends UIObject
   {
      
      public static const YES:uint = 1;
      
      public static const NO:uint = 2;
      
      public static const OK:uint = 4;
      
      public static const CANCEL:uint = 8;
      
      protected var mButtonFlags:uint = 4;
      
      protected var mModal:Boolean = true;
      
      protected var mCurtainActive:Boolean = false;
      
      protected var mCloseCallback:Function;
      
      protected var mText:String = "";
      
      protected var mTextField:TextField;
      
      protected var mYesButton:UIButton;
      
      protected var mNoButton:UIButton;
      
      protected var mOkButton:UIButton;
      
      protected var mCancelButton:UIButton;
      
      public function UIPopup(facade:Facade)
      {
         var _loc2_:MovieClip = new MovieClip();
         MemoryTracker.track(_loc2_,"MovieClip - popup root created in UIPopup()","brain");
         super(facade,_loc2_);
         if(mModal)
         {
            makeCurtain();
         }
         mFacade.sceneGraphManager.addChild(mRoot,105);
      }
      
      public static function show(facade:Facade, text:String = "", flags:uint = 4, modal:Boolean = true, callback:Function = null) : UIPopup
      {
         var _loc6_:UIPopup = new UIPopup(facade);
         _loc6_.mText = text;
         _loc6_.mButtonFlags = flags;
         _loc6_.mModal = modal;
         _loc6_.mCloseCallback = callback;
         return _loc6_;
      }
      
      override public function destroy() : void
      {
         removeCurtain();
      }
      
      public function set callback(closeCallback:Function) : void
      {
         mCloseCallback = closeCallback;
      }
      
      protected function makeCurtain() : void
      {
         if(!mCurtainActive)
         {
            mFacade.sceneGraphManager.showPopupCurtain();
            mCurtainActive = true;
         }
      }
      
      protected function removeCurtain() : void
      {
         if(mCurtainActive)
         {
            mFacade.sceneGraphManager.removePopupCurtain();
            mCurtainActive = false;
         }
      }
      
      protected function setupUI(popupClass:Class) : void
      {
         var popup:MovieClip = new popupClass();
         MemoryTracker.track(popup,"MovieClip - popup content created in UIPopup.setupUI()","brain");
         mRoot.addChild(popup);
         mTextField = TextField(popup.popupText);
         mTextField.text = mText;
         mYesButton = new UIButton(mFacade,popup.yesButton);
         MemoryTracker.track(mYesButton,"UIButton - yes button created in UIPopup.setupUI()","brain");
         mNoButton = new UIButton(mFacade,popup.noButton);
         MemoryTracker.track(mNoButton,"UIButton - no button created in UIPopup.setupUI()","brain");
         mOkButton = new UIButton(mFacade,popup.okButton);
         MemoryTracker.track(mOkButton,"UIButton - ok button created in UIPopup.setupUI()","brain");
         mCancelButton = new UIButton(mFacade,popup.cancelButton);
         MemoryTracker.track(mCancelButton,"UIButton - cancel button created in UIPopup.setupUI()","brain");
         mYesButton.label.text = "Yes";
         mNoButton.label.text = "No";
         mOkButton.label.text = "OK";
         mCancelButton.label.text = "Cancel";
         mYesButton.releaseCallback = function():void
         {
            onClose(1);
         };
         mNoButton.releaseCallback = function():void
         {
            onClose(2);
         };
         mOkButton.releaseCallback = function():void
         {
            onClose(4);
         };
         mCancelButton.releaseCallback = function():void
         {
            onClose(8);
         };
         mYesButton.root.visible = (mButtonFlags & 1) != 0;
         mNoButton.root.visible = (mButtonFlags & 2) != 0;
         mOkButton.root.visible = (mButtonFlags & 4) != 0;
         mCancelButton.root.visible = (mButtonFlags & 8) != 0;
      }
      
      protected function onClose(buttonFlag:uint) : void
      {
         if(mCloseCallback != null)
         {
            mCloseCallback(buttonFlag);
         }
         this.destroy();
      }
   }
}

