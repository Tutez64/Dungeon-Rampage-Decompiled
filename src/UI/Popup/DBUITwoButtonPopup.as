package UI.Popup
{
   import Brain.AssetRepository.SwfAsset;
   import Brain.Logger.Logger;
   import Brain.UI.UIButton;
   import Brain.UI.UIObject;
   import Brain.Utils.TextUtil;
   import DBGlobals.DBGlobal;
   import Facade.DBFacade;
   
   public class DBUITwoButtonPopup extends DBUIPopup
   {
      
      protected var mLeftButton:UIButton;
      
      protected var mLeftCallback:Function;
      
      protected var mLeftText:String;
      
      protected var mRightButton:UIButton;
      
      protected var mRightCallback:Function;
      
      protected var mRightText:String;
      
      public function DBUITwoButtonPopup(dbFacade:DBFacade, uiLayerName:String, titleText:String, content:*, leftText:String, leftCallback:Function, rightText:String, rightCallback:Function, allowClose:Boolean = true, closeCallback:Function = null, useOriginalPopup:Boolean = true, scalePopup:Boolean = true)
      {
         mLeftText = leftText;
         mLeftCallback = leftCallback;
         mRightText = rightText;
         mRightCallback = rightCallback;
         super(dbFacade,uiLayerName,titleText,content,allowClose,useCurtain(),closeCallback,useOriginalPopup,scalePopup);
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
            TextUtil.setText(mLeftButton.label,mLeftText);
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
            TextUtil.setText(mRightButton.label,mRightText);
            mRightButton.releaseCallback = function():void
            {
               close(mRightCallback);
            };
         }
         else
         {
            mPopup.right_button.visible = false;
         }
      }
      
      override protected function getClassName() : String
      {
         return "popup";
      }
      
      override protected function setupMenuNavigation() : void
      {
         var _loc1_:Boolean = Boolean(mLeftText) && mLeftButton != null;
         var _loc2_:Boolean = Boolean(mRightText) && mRightButton != null;
         if(_loc1_ && _loc2_)
         {
            mRightButton.isToTheLeftOf(mLeftButton);
         }
         if(mCloseButton)
         {
            if(_loc2_)
            {
               mCloseButton.isAbove(mRightButton);
            }
            if(_loc1_)
            {
               mLeftButton.upNavigation = mCloseButton;
            }
         }
         if(chooseFocusTarget(_loc1_,_loc2_) == null)
         {
            Logger.debugch("UI","DBUITwoButtonPopup: setupMenuNavigation: No buttons found to set focused on");
         }
      }
      
      private function chooseFocusTarget(hasLeft:Boolean, hasRight:Boolean) : UIButton
      {
         if(hasRight)
         {
            return mRightButton;
         }
         if(hasLeft)
         {
            return mLeftButton;
         }
         Logger.debugch("UI","DBUITwoButtonPopup: setupMenuNavigation: No left or right buttons found to setup navigation for");
         return mCloseButton;
      }
      
      override protected function getDefaultNavigationObject() : UIObject
      {
         return chooseFocusTarget(Boolean(mLeftText) && mLeftButton != null,Boolean(mRightText) && mRightButton != null);
      }
   }
}

