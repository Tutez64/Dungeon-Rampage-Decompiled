package Settings
{
   import Brain.AssetRepository.SwfAsset;
   import Brain.Logger.Logger;
   import Brain.UI.UIButton;
   import Brain.UI.UIObject;
   import Brain.UI.UIRadioButton;
   import DBGlobals.DBGlobal;
   import Facade.DBFacade;
   import Facade.Locale;
   import Settings.Model.SettingsModel;
   import Settings.View.Rows.SettingRow;
   import Settings.View.SettingsCategoryTabs;
   import Settings.View.SettingsList;
   import UI.Popup.DBUIPopup;
   import UI.Popup.DBUITwoButtonPopup;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   public class SettingsPopup extends DBUIPopup
   {
      
      public static const SETTINGS_SWF_PATH:String = "Resources/Art2D/UI/db_UI_settings.swf";
      
      public static const POPUP_LINKAGE_NAME:String = "settings_popup";
      
      private static const RESET_BUTTON_NAME:String = "reset_button";
      
      private static const RESET_LABEL_NAME:String = "reset_label";
      
      private var mModel:SettingsModel;
      
      private var mTabs:SettingsCategoryTabs;
      
      private var mList:SettingsList;
      
      private var mResetButton:UIButton;
      
      private var mConfirmResetPopup:DBUITwoButtonPopup;
      
      private var mNavigationReady:Boolean;
      
      public function SettingsPopup(dbFacade:DBFacade, closeCallback:Function = null)
      {
         mModel = dbFacade.settingsModel;
         super(dbFacade,"SETTINGS_MENU",Locale.getString("SETTINGS_TITLE"),null,true,true,closeCallback,false,false);
      }
      
      public static function isTopMenu(dbFacade:DBFacade) : Boolean
      {
         return dbFacade.menuNavigationController.getTopUILayer() == "SETTINGS_MENU";
      }
      
      override protected function getSwfPath() : String
      {
         return "Resources/Art2D/UI/db_UI_settings.swf";
      }
      
      override protected function getClassName() : String
      {
         return "settings_popup";
      }
      
      override protected function setupUI(swfAsset:SwfAsset, titleText:String, content:*, allowClose:Boolean, closeCallback:Function) : void
      {
         super.setupUI(swfAsset,titleText,content,allowClose,closeCallback);
         centerPopup();
         mDBFacade.displayTimingSettings.refreshMonitors();
         mTabs = new SettingsCategoryTabs(mDBFacade,mPopup,onCategorySelected);
         mList = new SettingsList(mDBFacade,mPopup,swfAsset,mModel);
         setupResetButton();
         mTabs.selectFirst();
      }
      
      override protected function setupMenuNavigation() : void
      {
         rebuildNavigation();
      }
      
      override protected function initializeMenuNavigationLayer() : void
      {
         mDBFacade.menuNavigationController.pushNewLayer(mUILayerName,getNavigationExitCallback(),getDefaultNavigationObject(),getInitialFocusedNavigationObject(),mTabs != null ? mTabs.selectPrevious : null,mTabs != null ? mTabs.selectNext : null);
      }
      
      override protected function getInitialFocusedNavigationObject() : UIObject
      {
         if(mList != null && mList.firstRow != null)
         {
            return mList.firstRow;
         }
         if(mTabs != null)
         {
            return mTabs.selectedButton;
         }
         return null;
      }
      
      override protected function completeMenuNavigationSetup() : void
      {
         super.completeMenuNavigationSetup();
         mNavigationReady = mUILayerName != null && mUILayerName.length > 0;
      }
      
      override public function destroy() : void
      {
         if(mDBFacade == null)
         {
            return;
         }
         if(mConfirmResetPopup)
         {
            mConfirmResetPopup.destroy();
            mConfirmResetPopup = null;
         }
         if(mModel)
         {
            mModel.apply();
         }
         mModel = null;
         if(mList)
         {
            mList.destroy();
            mList = null;
         }
         if(mTabs)
         {
            mTabs.destroy();
            mTabs = null;
         }
         if(mResetButton)
         {
            mResetButton.destroy();
            mResetButton = null;
         }
         super.destroy();
      }
      
      private function setupResetButton() : void
      {
         var _loc1_:MovieClip = findResetButtonClip();
         if(_loc1_ == null)
         {
            Logger.warn("Settings popup art has no reset button");
            return;
         }
         mResetButton = new UIButton(mDBFacade,_loc1_);
         mResetButton.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         mResetButton.releaseCallback = confirmResetAll;
         labelResetButton(_loc1_,Locale.getString("SETTINGS_RESET_ALL"));
      }
      
      private function findResetButtonClip() : MovieClip
      {
         var _loc1_:int = 0;
         var _loc2_:MovieClip = null;
         if(mPopup.hasOwnProperty("reset_button"))
         {
            return mPopup["reset_button"] as MovieClip;
         }
         _loc1_ = 0;
         while(_loc1_ < mPopup.numChildren)
         {
            _loc2_ = mPopup.getChildAt(_loc1_) as MovieClip;
            if(_loc2_ != null && _loc2_.getChildByName("reset_label") is TextField)
            {
               return _loc2_;
            }
            _loc1_++;
         }
         return null;
      }
      
      private function labelResetButton(clip:MovieClip, text:String) : void
      {
         var _loc3_:TextField = mResetButton.label;
         if(_loc3_ == null)
         {
            _loc3_ = clip.getChildByName("reset_label") as TextField;
         }
         if(_loc3_ == null)
         {
            _loc3_ = mPopup.getChildByName("reset_label") as TextField;
         }
         if(_loc3_ == null)
         {
            return;
         }
         _loc3_.text = text;
         _loc3_.mouseEnabled = false;
      }
      
      private function onCategorySelected(category:String) : void
      {
         mList.showCategory(category);
         rebuildNavigation();
         if(!mNavigationReady)
         {
            return;
         }
         if(isRailObject(mDBFacade.menuNavigationController.focusedUiObject))
         {
            return;
         }
         var _loc2_:UIObject = getInitialFocusedNavigationObject();
         if(_loc2_ != null)
         {
            mDBFacade.menuNavigationController.setFocusedUiObject(_loc2_);
         }
      }
      
      private function rebuildNavigation() : void
      {
         var _loc4_:int = 0;
         if(mTabs == null || mTabs.buttons.length == 0)
         {
            return;
         }
         var _loc3_:Vector.<UIRadioButton> = mTabs.buttons;
         var _loc1_:SettingRow = mList != null ? mList.firstRow : null;
         var _loc2_:SettingRow = mList != null ? mList.lastRow : null;
         _loc4_ = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc3_[_loc4_].clearNavigationAndInteractions();
            _loc4_++;
         }
         if(mResetButton != null)
         {
            mResetButton.clearNavigationAndInteractions();
         }
         if(mCloseButton != null)
         {
            mCloseButton.clearDownNavigation();
         }
         if(mCloseButton != null)
         {
            mCloseButton.isAbove(_loc3_[0]);
         }
         _loc4_ = 0;
         while(_loc4_ < _loc3_.length - 1)
         {
            _loc3_[_loc4_].isAbove(_loc3_[_loc4_ + 1]);
            _loc4_++;
         }
         if(mResetButton != null)
         {
            _loc3_[_loc3_.length - 1].isAbove(mResetButton);
         }
         if(_loc1_ != null)
         {
            _loc4_ = 0;
            while(_loc4_ < _loc3_.length)
            {
               _loc3_[_loc4_].rightNavigation = _loc1_;
               _loc4_++;
            }
            if(mResetButton != null)
            {
               mResetButton.rightNavigation = _loc1_;
            }
            _loc1_.upNavigation = mTabs.selectedButton;
         }
         if(_loc2_ != null && mResetButton != null)
         {
            _loc2_.downNavigation = mResetButton;
         }
      }
      
      private function isRailObject(uiObject:UIObject) : Boolean
      {
         if(uiObject == null)
         {
            return false;
         }
         if(uiObject == mCloseButton || uiObject == mResetButton)
         {
            return true;
         }
         for each(var _loc2_:UIRadioButton in mTabs.buttons)
         {
            if(_loc2_ == uiObject)
            {
               return true;
            }
         }
         return false;
      }
      
      private function confirmResetAll() : void
      {
         if(mConfirmResetPopup != null)
         {
            return;
         }
         mConfirmResetPopup = new DBUITwoButtonPopup(mDBFacade,"SETTINGS_RESET_CONFIRM_POPUP",Locale.getString("SETTINGS_RESET_ALL"),Locale.getString("SETTINGS_RESET_ALL_CONFIRM"),Locale.getString("SETTINGS_RESET_CONFIRM_YES"),onResetConfirmed,Locale.getString("SETTINGS_RESET_CONFIRM_NO"),onResetDismissed,true,onResetDismissed);
      }
      
      private function onResetConfirmed() : void
      {
         mConfirmResetPopup = null;
         mModel.resetAll();
      }
      
      private function onResetDismissed() : void
      {
         mConfirmResetPopup = null;
      }
   }
}

