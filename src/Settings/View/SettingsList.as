package Settings.View
{
   import Brain.AssetRepository.SwfAsset;
   import Brain.Logger.Logger;
   import Brain.UI.UIButton;
   import Brain.UI.UIScrollPane;
   import Brain.UI.UISlider;
   import Facade.DBFacade;
   import Settings.Model.SettingDefinition;
   import Settings.Model.SettingsModel;
   import Settings.View.Rows.BooleanSettingRow;
   import Settings.View.Rows.ChoiceSettingRow;
   import Settings.View.Rows.KeyBindingSettingRow;
   import Settings.View.Rows.SettingRow;
   import Settings.View.Rows.SliderSettingRow;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class SettingsList
   {
      
      private static const SCROLL_STEP:Number = 50;
      
      private static const ROW_PADDING:Number = 4;
      
      private var mDBFacade:DBFacade;
      
      private var mSwfAsset:SwfAsset;
      
      private var mModel:SettingsModel;
      
      private var mPopupClip:MovieClip;
      
      private var mScrollPane:UIScrollPane;
      
      private var mScrollSlider:UISlider;
      
      private var mScrollUpButton:UIButton;
      
      private var mScrollDownButton:UIButton;
      
      private var mRows:Vector.<SettingRow>;
      
      private var mContentHeight:Number = 0;
      
      private var mViewportHeight:Number = 0;
      
      private var mScrollable:Boolean = false;
      
      public function SettingsList(dbFacade:DBFacade, popupClip:MovieClip, swfAsset:SwfAsset, model:SettingsModel)
      {
         super();
         mDBFacade = dbFacade;
         mPopupClip = popupClip;
         mSwfAsset = swfAsset;
         mModel = model;
         mRows = new Vector.<SettingRow>();
         buildScrollControls();
         mModel.addChangeListener(onSettingChanged);
      }
      
      public function get rows() : Vector.<SettingRow>
      {
         return mRows;
      }
      
      public function get firstRow() : SettingRow
      {
         return mRows.length > 0 ? mRows[0] : null;
      }
      
      public function get lastRow() : SettingRow
      {
         return mRows.length > 0 ? mRows[mRows.length - 1] : null;
      }
      
      public function showCategory(category:String) : void
      {
         var _loc2_:int = 0;
         var _loc3_:SettingRow = null;
         destroyRows();
         if(mScrollPane == null)
         {
            return;
         }
         var _loc4_:Vector.<SettingDefinition> = mModel.catalog.getDefinitionsForCategory(category);
         var _loc5_:Number = 0;
         _loc2_ = 0;
         while(_loc2_ < _loc4_.length)
         {
            _loc3_ = createRow(_loc4_[_loc2_],_loc2_);
            _loc3_.build();
            _loc3_.root.y = _loc5_;
            _loc3_.focusedCallback = scrollRowIntoView;
            mScrollPane.root.addChild(_loc3_.root);
            mRows.push(_loc3_);
            _loc5_ += _loc3_.height + 4;
            _loc2_++;
         }
         mContentHeight = _loc5_;
         linkRowNavigation();
         updateScrollRange();
      }
      
      public function scrollRowIntoView(row:SettingRow) : void
      {
         if(mScrollPane == null || row.root == null)
         {
            return;
         }
         var _loc2_:Number = mScrollPane.root.scrollRect.y;
         var _loc4_:Number = row.root.y;
         var _loc3_:Number = _loc4_ + row.height;
         var _loc5_:Number = _loc2_;
         if(_loc4_ < _loc2_)
         {
            _loc5_ = _loc4_;
         }
         else if(_loc3_ > _loc2_ + mViewportHeight)
         {
            _loc5_ = _loc3_ - mViewportHeight;
         }
         if(_loc5_ == _loc2_)
         {
            return;
         }
         if(mScrollable && mScrollSlider != null)
         {
            mScrollSlider.valueWithCallback = _loc5_;
         }
         else
         {
            mScrollPane.scrollToY(_loc5_);
         }
      }
      
      public function destroy() : void
      {
         mModel.removeChangeListener(onSettingChanged);
         destroyRows();
         if(mPopupClip != null)
         {
            mPopupClip.removeEventListener("mouseWheel",onMouseWheel);
         }
         if(mScrollUpButton)
         {
            mScrollUpButton.destroy();
            mScrollUpButton = null;
         }
         if(mScrollDownButton)
         {
            mScrollDownButton.destroy();
            mScrollDownButton = null;
         }
         if(mScrollSlider)
         {
            mScrollSlider.destroy();
            mScrollSlider = null;
         }
         if(mScrollPane)
         {
            mScrollPane.destroy();
            mScrollPane = null;
         }
         mRows = null;
         mModel = null;
         mSwfAsset = null;
         mPopupClip = null;
         mDBFacade = null;
      }
      
      private function buildScrollControls() : void
      {
         if(!mPopupClip.hasOwnProperty("panel_two_scroll_panel"))
         {
            Logger.warn("Settings popup art has no scroll panel");
            return;
         }
         mScrollPane = new UIScrollPane(mDBFacade,mPopupClip.panel_two_scroll_panel);
         mViewportHeight = mScrollPane.root.scrollRect.height;
         if(mPopupClip.hasOwnProperty("slider"))
         {
            mScrollSlider = new UISlider(mDBFacade,mPopupClip.slider,1);
            mScrollSlider.updateCallback = mScrollPane.scrollToY;
         }
         mPopupClip.addEventListener("mouseWheel",onMouseWheel);
         if(mPopupClip.hasOwnProperty("uparrow"))
         {
            mScrollUpButton = new UIButton(mDBFacade,mPopupClip.uparrow);
            mScrollUpButton.releaseCallback = scrollUp;
         }
         if(mPopupClip.hasOwnProperty("downarrow"))
         {
            mScrollDownButton = new UIButton(mDBFacade,mPopupClip.downarrow);
            mScrollDownButton.releaseCallback = scrollDown;
         }
      }
      
      private function onMouseWheel(event:MouseEvent) : void
      {
         if(!mScrollable || mScrollSlider == null)
         {
            return;
         }
         mScrollSlider.valueWithCallback = mScrollSlider.value - event.delta * 50;
      }
      
      private function scrollUp() : void
      {
         if(mScrollable && mScrollSlider)
         {
            mScrollSlider.valueWithCallback = mScrollSlider.value - 50;
         }
      }
      
      private function scrollDown() : void
      {
         if(mScrollable && mScrollSlider)
         {
            mScrollSlider.valueWithCallback = mScrollSlider.value + 50;
         }
      }
      
      private function updateScrollRange() : void
      {
         if(mScrollPane == null)
         {
            return;
         }
         var _loc1_:Number = Math.max(0,mContentHeight - mViewportHeight);
         mScrollable = _loc1_ > 0;
         setScrollControlsVisible(mScrollable);
         mScrollPane.scrollToY(0);
         if(!mScrollable || mScrollSlider == null)
         {
            return;
         }
         mScrollSlider.minimum = _loc1_;
         mScrollSlider.maximum = 0;
         mScrollSlider.value = 0;
      }
      
      private function setScrollControlsVisible(visible:Boolean) : void
      {
         if(mScrollSlider != null)
         {
            mScrollSlider.visible = visible;
         }
         if(mScrollUpButton != null)
         {
            mScrollUpButton.visible = visible;
         }
         if(mScrollDownButton != null)
         {
            mScrollDownButton.visible = visible;
         }
      }
      
      private function linkRowNavigation() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < mRows.length - 1)
         {
            mRows[_loc1_].isAbove(mRows[_loc1_ + 1]);
            _loc1_++;
         }
         for each(var _loc2_:SettingRow in mRows)
         {
            _loc2_.leftNavigationAdditionalInteraction = _loc2_.nudgeDown;
            _loc2_.rightNavigationAdditionalInteraction = _loc2_.nudgeUp;
         }
      }
      
      private function createRow(definition:SettingDefinition, index:int) : SettingRow
      {
         if(definition.isKeyBinding)
         {
            return new KeyBindingSettingRow(mDBFacade,mSwfAsset,definition,mModel,index);
         }
         if(definition.isChoice)
         {
            return new ChoiceSettingRow(mDBFacade,mSwfAsset,definition,mModel,index);
         }
         if(definition.isSlider)
         {
            return new SliderSettingRow(mDBFacade,mSwfAsset,definition,mModel,index);
         }
         return new BooleanSettingRow(mDBFacade,mSwfAsset,definition,mModel,index);
      }
      
      private function destroyRows() : void
      {
         for each(var _loc1_:SettingRow in mRows)
         {
            if(_loc1_.root != null && _loc1_.root.parent != null)
            {
               _loc1_.root.parent.removeChild(_loc1_.root);
            }
            _loc1_.destroy();
         }
         mRows.length = 0;
         mContentHeight = 0;
      }
      
      private function onSettingChanged(id:String) : void
      {
         for each(var _loc2_:SettingRow in mRows)
         {
            _loc2_.refreshFromModel();
         }
      }
   }
}

