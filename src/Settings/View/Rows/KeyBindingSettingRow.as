package Settings.View.Rows
{
   import Brain.AssetRepository.SwfAsset;
   import Brain.UI.UIButton;
   import DBGlobals.DBGlobal;
   import Facade.DBFacade;
   import Facade.Locale;
   import Input.KeyBindings.KeyBindings;
   import Input.KeyBindings.KeyNames;
   import Settings.Model.KeyBindingValue;
   import Settings.Model.SettingDefinition;
   import Settings.Model.SettingsModel;
   import flash.display.MovieClip;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class KeyBindingSettingRow extends SettingRow
   {
      
      public static const LINKAGE_NAME:String = "multiple_input_option";
      
      private static const PRIMARY_BUTTON_INSTANCE_NAME:String = "primary_button";
      
      private static const ALTERNATE_BUTTON_INSTANCE_NAME:String = "alternative_button";
      
      private static const RESET_BUTTON_INSTANCE_NAME:String = "reset_button";
      
      private static const PRIMARY_CAPTION_INSTANCE_NAME:String = "Primary_Label";
      
      private static const ALTERNATE_CAPTION_INSTANCE_NAME:String = "Alternate_Label";
      
      private static const RESET_CAPTION_INSTANCE_NAME:String = "Reset_Label";
      
      private static const CAPTURE_PROMPT_INSTANCE_NAME:String = "key_label";
      
      private static const CAPTURE_LISTENER_PRIORITY:int = 1000;
      
      private var mPrimaryButton:UIButton;
      
      private var mAlternateButton:UIButton;
      
      private var mResetButton:UIButton;
      
      private var mResetCaption:TextField;
      
      private var mCapturePrompt:TextField;
      
      private var mButtonClips:Vector.<MovieClip>;
      
      private var mCapturingSlot:String;
      
      private var mInputsWereDisabled:Boolean;
      
      public function KeyBindingSettingRow(dbFacade:DBFacade, swfAsset:SwfAsset, definition:SettingDefinition, model:SettingsModel, rowIndex:int)
      {
         super(dbFacade,swfAsset,"multiple_input_option",definition,model,rowIndex);
      }
      
      private static function swallowButtonClick(event:MouseEvent) : void
      {
         event.stopPropagation();
      }
      
      override protected function bindControls() : void
      {
         mButtonClips = new Vector.<MovieClip>();
         mPrimaryButton = makeButton("primary_button",capturePrimary);
         mAlternateButton = makeButton("alternative_button",captureAlternate);
         mResetButton = makeButton("reset_button",resetToDefault);
         setCaption("Primary_Label","SETTINGS_KEY_PRIMARY");
         setCaption("Alternate_Label","SETTINGS_KEY_ALTERNATE");
         mResetCaption = setCaption("Reset_Label","SETTINGS_KEY_RESET");
         mCapturePrompt = setCaption("key_label","SETTINGS_KEY_PRESS_ANY");
      }
      
      override public function refreshFromModel() : void
      {
         super.refreshFromModel();
         var _loc2_:Object = mModel.getValue(mDefinition.id);
         setButtonText(mPrimaryButton,"primary",KeyBindingValue.primary(_loc2_));
         setButtonText(mAlternateButton,"alternate",KeyBindingValue.alternate(_loc2_));
         var _loc1_:Boolean = KeyBindingValue.equals(_loc2_,mDefinition.defaultValue);
         if(mResetButton != null)
         {
            mResetButton.visible = !_loc1_;
         }
         if(mResetCaption != null)
         {
            mResetCaption.visible = !_loc1_;
         }
         if(mCapturePrompt != null)
         {
            mCapturePrompt.visible = mCapturingSlot != null;
         }
      }
      
      override public function onSelected(fromController:Boolean = false) : void
      {
         capturePrimary();
      }
      
      override public function destroy() : void
      {
         endCapture();
         if(mButtonClips != null)
         {
            for each(var _loc1_:MovieClip in mButtonClips)
            {
               _loc1_.removeEventListener("click",swallowButtonClick);
            }
            mButtonClips = null;
         }
         if(mPrimaryButton)
         {
            mPrimaryButton.destroy();
            mPrimaryButton = null;
         }
         if(mAlternateButton)
         {
            mAlternateButton.destroy();
            mAlternateButton = null;
         }
         if(mResetButton)
         {
            mResetButton.destroy();
            mResetButton = null;
         }
         mResetCaption = null;
         mCapturePrompt = null;
         super.destroy();
      }
      
      private function makeButton(instanceName:String, onRelease:Function) : UIButton
      {
         var _loc4_:MovieClip = clipNamed(instanceName);
         if(_loc4_ == null)
         {
            return null;
         }
         var _loc3_:UIButton = new UIButton(mDBFacade,_loc4_);
         _loc3_.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
         _loc3_.selectedFilter = DBGlobal.UI_SELECTED_FILTER;
         _loc3_.releaseCallback = onRelease;
         _loc4_.addEventListener("click",swallowButtonClick);
         mButtonClips.push(_loc4_);
         return _loc3_;
      }
      
      private function setCaption(instanceName:String, localeKey:String) : TextField
      {
         var _loc3_:TextField = fieldNamed(instanceName);
         if(_loc3_ == null)
         {
            return null;
         }
         _loc3_.text = Locale.getString(localeKey);
         _loc3_.mouseEnabled = false;
         return _loc3_;
      }
      
      private function setButtonText(button:UIButton, slotName:String, keyCode:int) : void
      {
         if(button == null)
         {
            return;
         }
         var _loc4_:Boolean = mCapturingSlot == slotName;
         button.selected = _loc4_;
         if(button.label == null)
         {
            return;
         }
         if(_loc4_ && mCapturePrompt == null)
         {
            button.label.text = Locale.getString("SETTINGS_KEY_PRESS_ANY");
            return;
         }
         var _loc5_:String = KeyNames.displayName(keyCode);
         button.label.text = _loc5_.length > 0 ? _loc5_ : Locale.getString("SETTINGS_KEY_UNBOUND");
      }
      
      private function capturePrimary() : void
      {
         beginCapture("primary");
      }
      
      private function captureAlternate() : void
      {
         beginCapture("alternate");
      }
      
      private function resetToDefault() : void
      {
         endCapture();
         mModel.resetKeyBinding(mDefinition.id);
      }
      
      private function beginCapture(slotName:String) : void
      {
         if(mCapturingSlot != null)
         {
            return;
         }
         mCapturingSlot = slotName;
         mInputsWereDisabled = mDBFacade.inputManager.disableInputs;
         if(!mInputsWereDisabled)
         {
            mDBFacade.inputManager.disableControls();
         }
         mDBFacade.stageRef.addEventListener("keyDown",onCaptureKeyDown,false,1000);
         mDBFacade.stageRef.addEventListener("mouseDown",onCaptureMouseDown,true,1000);
         mDBFacade.stageRef.addEventListener("mouseDown",onCaptureMouseDown,false,1000);
         refreshFromModel();
      }
      
      private function endCapture() : void
      {
         if(mCapturingSlot == null)
         {
            return;
         }
         mCapturingSlot = null;
         if(mDBFacade != null)
         {
            mDBFacade.stageRef.removeEventListener("keyDown",onCaptureKeyDown);
            mDBFacade.stageRef.removeEventListener("mouseDown",onCaptureMouseDown,true);
            mDBFacade.stageRef.removeEventListener("mouseDown",onCaptureMouseDown);
            if(!mInputsWereDisabled)
            {
               mDBFacade.inputManager.enableControls();
            }
         }
         if(mModel != null && mRoot != null)
         {
            refreshFromModel();
         }
      }
      
      private function onCaptureKeyDown(event:KeyboardEvent) : void
      {
         event.stopImmediatePropagation();
         event.preventDefault();
         var _loc3_:int = int(event.keyCode);
         if(_loc3_ == 27)
         {
            endCapture();
            return;
         }
         if(!KeyBindings.isBindable(_loc3_))
         {
            return;
         }
         var _loc2_:String = mCapturingSlot;
         endCapture();
         mModel.assignKey(mDefinition.id,_loc2_,_loc3_);
      }
      
      private function onCaptureMouseDown(event:MouseEvent) : void
      {
         endCapture();
      }
   }
}

