package UI.Popup
{
   import Brain.AssetRepository.SwfAsset;
   import Brain.UI.UIButton;
   import DBGlobals.DBGlobal;
   import Facade.DBFacade;
   import UI.*;
   
   public class DBUITwoButtonPopup extends DBUIPopup
   {
      
      protected var mLeftButton:UIButton;
      
      protected var mLeftCallback:Function;
      
      protected var mLeftText:String;
      
      protected var mRightButton:UIButton;
      
      protected var mRightCallback:Function;
      
      protected var mRightText:String;
      
      public function DBUITwoButtonPopup(dbFacade:DBFacade, titleText:String, content:*, leftText:String, leftCallback:Function, rightText:String, rightCallback:Function, allowClose:Boolean = true, closeCallback:Function = null, useOriginalPopup:Boolean = true, scalePopup:Boolean = true, UILayerName:String = "")
      {
         mLeftText = leftText;
         mLeftCallback = leftCallback;
         mRightText = rightText;
         mRightCallback = rightCallback;
         super(dbFacade,titleText,content,allowClose,useCurtain(),closeCallback,useOriginalPopup,scalePopup,UILayerName);
      }
      
      override public function destroy() : void
      {
         if(mLeftButton)
         {
            mLeftButton.destroy();
            mLeftButton = null;
         }
         if(mRightButton)
         {
            mRightButton.destroy();
            mRightButton = null;
         }
         mLeftCallback = null;
         mRightCallback = null;
         super.destroy();
      }
      
      override protected function setupUI(swfAsset:SwfAsset, titleText:String, content:*, allowClose:Boolean, closeCallback:Function) : void
      {
         super.setupUI(swfAsset,titleText,content,allowClose,closeCallback);
         if(mLeftText)
         {
            mPopup.left_button.visible = true;
            mLeftButton = new UIButton(mDBFacade,mPopup.left_button);
            mLeftButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
            mLeftButton.label.text = mLeftText;
            mLeftButton.releaseCallback = function():void
            {
               close(mLeftCallback);
            };
         }
         else
         {
            mPopup.left_button.visible = false;
         }
         if(mRightText)
         {
            mPopup.right_button.visible = true;
            mRightButton = new UIButton(mDBFacade,mPopup.right_button);
            mRightButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
            mRightButton.label.text = mRightText;
            mRightButton.releaseCallback = function():void
            {
               close(mRightCallback);
            };
         }
         else
         {
            mPopup.right_button.visible = false;
         }
         setupMenuNavigation();
      }
      
      override protected function getClassName() : String
      {
         return "popup";
      }
      
      override protected function setupMenuNavigation() : void
      {
         if(mLeftText && mRightText)
         {
            mRightButton.isToTheLeftOf(mLeftButton);
            if(mCloseButton)
            {
               mCloseButton.isAbove(mLeftButton);
            }
         }
         if(mUILayerName)
         {
            if(mCloseButton)
            {
               mDBFacade.menuNavigationController.pushNewLayer(mUILayerName,mCloseCallback,mCloseButton);
            }
            else
            {
               mDBFacade.menuNavigationController.pushNewLayer(mUILayerName,mCloseCallback,mLeftButton);
            }
         }
      }
      
      override protected function initializeMenuNavigationLayer() : void
      {
      }
   }
}

