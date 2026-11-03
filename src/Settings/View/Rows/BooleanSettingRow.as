package Settings.View.Rows
{
   import Brain.AssetRepository.SwfAsset;
   import Brain.UI.UIButton;
   import Facade.DBFacade;
   import Facade.Locale;
   import Settings.Model.SettingDefinition;
   import Settings.Model.SettingsModel;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class BooleanSettingRow extends SettingRow
   {
      
      public static const LINKAGE_NAME:String = "boolean_option";
      
      private static const BUTTON_INSTANCE_NAME:String = "boolean_button";
      
      private var mStateButton:UIButton;
      
      private var mButtonClip:MovieClip;
      
      public function BooleanSettingRow(dbFacade:DBFacade, swfAsset:SwfAsset, definition:SettingDefinition, model:SettingsModel, rowIndex:int)
      {
         super(dbFacade,swfAsset,"boolean_option",definition,model,rowIndex);
      }
      
      private static function swallowButtonClick(event:MouseEvent) : void
      {
         event.stopPropagation();
      }
      
      override protected function bindControls() : void
      {
         mButtonClip = clipNamed("boolean_button");
         if(mButtonClip == null)
         {
            return;
         }
         mStateButton = new UIButton(mDBFacade,mButtonClip);
         mStateButton.releaseCallback = toggle;
         mButtonClip.addEventListener("click",swallowButtonClick);
      }
      
      override public function refreshFromModel() : void
      {
         super.refreshFromModel();
         if(mValueLabel != null)
         {
            mValueLabel.text = stateWord();
         }
         if(mStateButton != null)
         {
            mStateButton.selected = mModel.getBoolean(mDefinition.id);
         }
      }
      
      override protected function updateDescription() : void
      {
         super.updateDescription();
         if(mDescriptionLabel == null || mValueLabel != null || mStateButton != null)
         {
            return;
         }
         var _loc1_:String = mDescriptionLabel.text;
         mDescriptionLabel.text = _loc1_.length > 0 ? stateWord() + "   " + _loc1_ : stateWord();
      }
      
      override protected function get isActivatable() : Boolean
      {
         return true;
      }
      
      override protected function onRowActivated() : void
      {
         toggle();
      }
      
      override public function nudgeDown() : void
      {
         mModel.setValue(mDefinition.id,false);
      }
      
      override public function nudgeUp() : void
      {
         mModel.setValue(mDefinition.id,true);
      }
      
      override public function destroy() : void
      {
         if(mButtonClip)
         {
            mButtonClip.removeEventListener("click",swallowButtonClick);
            mButtonClip = null;
         }
         if(mStateButton)
         {
            mStateButton.destroy();
            mStateButton = null;
         }
         super.destroy();
      }
      
      private function toggle() : void
      {
         mModel.setValue(mDefinition.id,!mModel.getBoolean(mDefinition.id));
      }
      
      private function stateWord() : String
      {
         return Locale.getString(mModel.getBoolean(mDefinition.id) ? "SETTINGS_ON" : "SETTINGS_OFF");
      }
   }
}

