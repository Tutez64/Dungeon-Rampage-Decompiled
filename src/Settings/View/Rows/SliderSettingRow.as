package Settings.View.Rows
{
   import Brain.AssetRepository.SwfAsset;
   import Brain.UI.UIButton;
   import Brain.UI.UISlider;
   import Facade.DBFacade;
   import Settings.Model.SettingDefinition;
   import Settings.Model.SettingsModel;
   import flash.display.MovieClip;
   
   public class SliderSettingRow extends SettingRow
   {
      
      public static const LINKAGE_NAME:String = "slider_option";
      
      private static const STEP_PRECISION_DIGITS:int = 6;
      
      private var mSlider:UISlider;
      
      private var mLeftButton:UIButton;
      
      private var mRightButton:UIButton;
      
      public function SliderSettingRow(dbFacade:DBFacade, swfAsset:SwfAsset, definition:SettingDefinition, model:SettingsModel, rowIndex:int)
      {
         super(dbFacade,swfAsset,"slider_option",definition,model,rowIndex);
      }
      
      override protected function bindControls() : void
      {
         var _loc2_:MovieClip = clipNamed("slider");
         if(_loc2_ != null)
         {
            mSlider = new UISlider(mDBFacade,_loc2_,0);
            mSlider.minimum = mDefinition.minimum;
            mSlider.maximum = mDefinition.maximum;
            mSlider.tick = mDefinition.step;
            mSlider.value = mModel.getNumber(mDefinition.id);
            mSlider.updateCallback = onSliderMoved;
         }
         var _loc1_:MovieClip = clipNamed("leftarrow");
         if(_loc1_ != null)
         {
            mLeftButton = new UIButton(mDBFacade,_loc1_);
            mLeftButton.releaseCallback = nudgeDown;
         }
         var _loc3_:MovieClip = clipNamed("rightarrow");
         if(_loc3_ != null)
         {
            mRightButton = new UIButton(mDBFacade,_loc3_);
            mRightButton.releaseCallback = nudgeUp;
         }
      }
      
      override public function refreshFromModel() : void
      {
         super.refreshFromModel();
         var _loc1_:Number = mModel.getNumber(mDefinition.id);
         if(mSlider != null)
         {
            mSlider.value = _loc1_;
         }
         if(mValueLabel != null)
         {
            mValueLabel.text = formatValue(_loc1_);
         }
      }
      
      override public function nudgeDown() : void
      {
         step(-mDefinition.step);
      }
      
      override public function nudgeUp() : void
      {
         step(mDefinition.step);
      }
      
      override public function destroy() : void
      {
         if(mSlider)
         {
            mSlider.destroy();
            mSlider = null;
         }
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
         super.destroy();
      }
      
      private function step(delta:Number) : void
      {
         var _loc2_:Number = mModel.getNumber(mDefinition.id) + delta;
         _loc2_ = Math.max(mDefinition.minimum,Math.min(mDefinition.maximum,_loc2_));
         mModel.setValue(mDefinition.id,roundToStep(_loc2_));
      }
      
      private function onSliderMoved(value:Number) : void
      {
         mModel.setValue(mDefinition.id,roundToStep(value));
      }
      
      private function roundToStep(value:Number) : Number
      {
         if(mDefinition.step <= 0)
         {
            return value;
         }
         var _loc2_:Number = Math.round(value / mDefinition.step) * mDefinition.step;
         return Number(_loc2_.toFixed(6));
      }
      
      private function formatValue(value:Number) : String
      {
         var _loc2_:Number = value * mDefinition.displayScale;
         if(mDefinition.decimals > 0)
         {
            return _loc2_.toFixed(mDefinition.decimals);
         }
         return String(Math.round(_loc2_));
      }
   }
}

