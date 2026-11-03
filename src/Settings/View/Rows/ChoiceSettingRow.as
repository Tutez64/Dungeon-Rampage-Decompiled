package Settings.View.Rows
{
   import Brain.AssetRepository.SwfAsset;
   import Brain.UI.UIButton;
   import Facade.DBFacade;
   import Facade.Locale;
   import Settings.Model.SettingChoice;
   import Settings.Model.SettingDefinition;
   import Settings.Model.SettingsModel;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class ChoiceSettingRow extends SettingRow
   {
      
      public static const LINKAGE_NAME:String = "preset_option";
      
      private static const NAME_LABEL_INSTANCE_NAME:String = "Name_Label";
      
      private static const DOWN_ARROW_INSTANCE_NAME:String = "downarrow";
      
      private static const UP_ARROW_INSTANCE_NAME:String = "uparrow";
      
      private static const DEAD_ARROW_ALPHA:Number = 0.35;
      
      private var mDownArrowClip:MovieClip;
      
      private var mUpArrowClip:MovieClip;
      
      private var mDownButton:UIButton;
      
      private var mUpButton:UIButton;
      
      private var mSelectableChoices:Vector.<SettingChoice>;
      
      public function ChoiceSettingRow(dbFacade:DBFacade, swfAsset:SwfAsset, definition:SettingDefinition, model:SettingsModel, rowIndex:int)
      {
         super(dbFacade,swfAsset,"preset_option",definition,model,rowIndex);
      }
      
      private static function compareTopToBottom(a:TextField, b:TextField) : Number
      {
         return a.y - b.y;
      }
      
      private static function setArrowLive(arrow:UIButton, live:Boolean) : void
      {
         if(arrow == null || arrow.root == null)
         {
            return;
         }
         arrow.enabled = live;
         arrow.root.alpha = live ? 1 : 0.35;
      }
      
      private static function swallowArrowClick(event:MouseEvent) : void
      {
         event.stopPropagation();
      }
      
      override protected function bindControls() : void
      {
         splitNameFromValue();
         mDownArrowClip = clipNamed("downarrow");
         if(mDownArrowClip != null)
         {
            mDownButton = new UIButton(mDBFacade,mDownArrowClip);
            mDownButton.releaseCallback = nudgeDown;
            mDownArrowClip.addEventListener("click",swallowArrowClick);
         }
         mUpArrowClip = clipNamed("uparrow");
         if(mUpArrowClip != null)
         {
            mUpButton = new UIButton(mDBFacade,mUpArrowClip);
            mUpButton.releaseCallback = nudgeUp;
            mUpArrowClip.addEventListener("click",swallowArrowClick);
         }
      }
      
      override public function refreshFromModel() : void
      {
         super.refreshFromModel();
         var _loc1_:SettingChoice = mDefinition.findChoice(mModel.getValue(mDefinition.id));
         var _loc2_:TextField = mValueLabel ?? mNameLabel;
         if(_loc2_ != null && _loc1_ != null)
         {
            _loc2_.text = _loc1_.labelKey != null ? Locale.getString(_loc1_.labelKey) : String(_loc1_.value);
         }
         updateArrowStates();
      }
      
      override protected function get isActivatable() : Boolean
      {
         return true;
      }
      
      override protected function onRowActivated() : void
      {
         nudgeUp();
      }
      
      override public function nudgeDown() : void
      {
         cycle(-1);
      }
      
      override public function nudgeUp() : void
      {
         cycle(1);
      }
      
      override public function destroy() : void
      {
         if(mDownArrowClip)
         {
            mDownArrowClip.removeEventListener("click",swallowArrowClick);
            mDownArrowClip = null;
         }
         if(mUpArrowClip)
         {
            mUpArrowClip.removeEventListener("click",swallowArrowClick);
            mUpArrowClip = null;
         }
         if(mDownButton)
         {
            mDownButton.destroy();
            mDownButton = null;
         }
         if(mUpButton)
         {
            mUpButton.destroy();
            mUpButton = null;
         }
         mSelectableChoices = null;
         super.destroy();
      }
      
      private function cycle(direction:int) : void
      {
         var _loc3_:Vector.<SettingChoice> = selectableChoices;
         if(_loc3_.length == 0)
         {
            return;
         }
         var _loc2_:int = indexOfCurrentChoice();
         var _loc4_:int = _loc2_ < 0 ? (direction > 0 ? 0 : _loc3_.length - 1) : _loc2_ + direction;
         if(_loc4_ < 0 || _loc4_ >= _loc3_.length)
         {
            return;
         }
         mModel.setValue(mDefinition.id,_loc3_[_loc4_].value);
      }
      
      private function splitNameFromValue() : void
      {
         var _loc2_:int = 0;
         var _loc1_:TextField = null;
         if(mValueLabel != null)
         {
            return;
         }
         var _loc3_:Vector.<TextField> = new Vector.<TextField>();
         _loc2_ = 0;
         while(_loc2_ < mRoot.numChildren)
         {
            _loc1_ = mRoot.getChildAt(_loc2_) as TextField;
            if(_loc1_ != null && _loc1_.name == "Name_Label")
            {
               _loc3_.push(_loc1_);
            }
            _loc2_++;
         }
         if(_loc3_.length < 2)
         {
            return;
         }
         _loc3_.sort(compareTopToBottom);
         mNameLabel = _loc3_[0];
         mValueLabel = _loc3_[_loc3_.length - 1];
         mNameLabel.text = nameText();
      }
      
      private function updateArrowStates() : void
      {
         var _loc4_:Vector.<SettingChoice> = selectableChoices;
         var _loc1_:int = indexOfCurrentChoice();
         var _loc3_:Boolean = _loc4_.length == 0 || _loc1_ == 0;
         var _loc2_:Boolean = _loc4_.length == 0 || _loc1_ == _loc4_.length - 1;
         setArrowLive(mDownButton,!_loc3_);
         setArrowLive(mUpButton,!_loc2_);
      }
      
      private function get selectableChoices() : Vector.<SettingChoice>
      {
         mSelectableChoices = new Vector.<SettingChoice>();
         var _loc1_:Vector.<SettingChoice> = mDefinition.choices;
         if(_loc1_ != null)
         {
            for each(var _loc2_:SettingChoice in _loc1_)
            {
               if(!_loc2_.derived)
               {
                  mSelectableChoices.push(_loc2_);
               }
            }
         }
         return mSelectableChoices;
      }
      
      private function indexOfCurrentChoice() : int
      {
         var _loc2_:int = 0;
         var _loc1_:* = mModel.getValue(mDefinition.id);
         var _loc3_:Vector.<SettingChoice> = selectableChoices;
         _loc2_ = 0;
         while(_loc2_ < _loc3_.length)
         {
            if(_loc3_[_loc2_].value == _loc1_)
            {
               return _loc2_;
            }
            _loc2_++;
         }
         return -1;
      }
   }
}

