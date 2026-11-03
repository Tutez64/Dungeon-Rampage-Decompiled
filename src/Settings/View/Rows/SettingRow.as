package Settings.View.Rows
{
   import Brain.AssetRepository.SwfAsset;
   import Brain.Logger.Logger;
   import Brain.UI.UIObject;
   import DBGlobals.DBGlobal;
   import Facade.DBFacade;
   import Facade.Locale;
   import Settings.Model.SettingDefinition;
   import Settings.Model.SettingsModel;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class SettingRow extends UIObject
   {
      
      private static const MISSING_STRING_PREFIX:String = "mia:";
      
      protected var mDBFacade:DBFacade;
      
      protected var mDefinition:SettingDefinition;
      
      protected var mModel:SettingsModel;
      
      protected var mRowIndex:int;
      
      protected var mNameLabel:TextField;
      
      protected var mDescriptionLabel:TextField;
      
      protected var mValueLabel:TextField;
      
      public var focusedCallback:Function;
      
      private var mFiltersBeforeHighlight:Array;
      
      public function SettingRow(dbFacade:DBFacade, swfAsset:SwfAsset, linkageName:String, definition:SettingDefinition, model:SettingsModel, rowIndex:int)
      {
         super(dbFacade,instantiate(swfAsset,linkageName));
         mDBFacade = dbFacade;
         mDefinition = definition;
         mModel = model;
         mRowIndex = rowIndex;
      }
      
      protected static function localised(key:String) : String
      {
         var _loc2_:String = Locale.getString(key);
         if(_loc2_ == null || _loc2_.indexOf("mia:") == 0)
         {
            return "";
         }
         return _loc2_;
      }
      
      private static function instantiate(swfAsset:SwfAsset, linkageName:String) : MovieClip
      {
         var _loc3_:Class = swfAsset.getClass(linkageName);
         if(_loc3_ == null)
         {
            Logger.warn("Settings row art missing from swf: " + linkageName);
            return new MovieClip();
         }
         return new _loc3_() as MovieClip;
      }
      
      public function get definition() : SettingDefinition
      {
         return mDefinition;
      }
      
      public function get height() : Number
      {
         return mRoot != null ? mRoot.height : 0;
      }
      
      public function build() : void
      {
         mNameLabel = fieldNamed("Name_Label");
         mDescriptionLabel = fieldNamed("Description_Label");
         mValueLabel = fieldNamed("Value_Label");
         if(mNameLabel != null)
         {
            mNameLabel.text = nameText();
         }
         mRoot.buttonMode = isActivatable;
         applyZebraShading();
         bindControls();
         refreshFromModel();
      }
      
      protected function bindControls() : void
      {
      }
      
      public function refreshFromModel() : void
      {
         updateDescription();
      }
      
      protected function onRowActivated() : void
      {
      }
      
      public function nudgeDown() : void
      {
      }
      
      public function nudgeUp() : void
      {
      }
      
      protected function updateDescription() : void
      {
         if(mDescriptionLabel == null)
         {
            return;
         }
         var _loc1_:Array = [];
         var _loc2_:String = mDefinition.descriptionKeyProvider != null ? mDefinition.descriptionKeyProvider() : mDefinition.descriptionKey;
         var _loc3_:String = mDefinition.descriptionText ?? localised(_loc2_);
         if(_loc3_.length > 0)
         {
            _loc1_.push(_loc3_);
         }
         if(mDefinition.requiresRestart)
         {
            _loc1_.push(Locale.getString("SETTINGS_REQUIRES_RESTART"));
         }
         mDescriptionLabel.text = _loc1_.join("   ");
      }
      
      protected function nameText() : String
      {
         return mDefinition.labelText ?? Locale.getString(mDefinition.labelKey);
      }
      
      private function applyZebraShading() : void
      {
         if(mRoot.hasOwnProperty("dark_row_1") && mRoot.hasOwnProperty("dark_row_2"))
         {
            mRoot.dark_row_1.visible = mRowIndex % 2 == 0;
            mRoot.dark_row_2.visible = mRowIndex % 2 != 0;
         }
      }
      
      protected function fieldNamed(name:String) : TextField
      {
         if(mRoot != null && mRoot.hasOwnProperty(name))
         {
            return mRoot[name] as TextField;
         }
         return null;
      }
      
      protected function clipNamed(name:String) : MovieClip
      {
         if(mRoot != null && mRoot.hasOwnProperty(name))
         {
            return mRoot[name] as MovieClip;
         }
         return null;
      }
      
      override protected function addListeners() : void
      {
         super.addListeners();
         mRoot.addEventListener("click",onRootClicked);
      }
      
      override protected function removeListeners() : void
      {
         super.removeListeners();
         mRoot.removeEventListener("click",onRootClicked);
      }
      
      protected function get isActivatable() : Boolean
      {
         return false;
      }
      
      private function onRootClicked(event:MouseEvent) : void
      {
         onRowActivated();
      }
      
      override public function onSelected(fromController:Boolean = false) : void
      {
         onRowActivated();
      }
      
      override protected function onRollOver(event:MouseEvent) : void
      {
         super.onRollOver(event);
         if(mRoot == null)
         {
            return;
         }
         mFiltersBeforeHighlight = mRoot.filters;
         mRoot.filters = [DBGlobal.UI_ROLLOVER_FILTER];
         if(focusedCallback != null)
         {
            focusedCallback(this);
         }
      }
      
      override protected function onRollOut(event:MouseEvent) : void
      {
         super.onRollOut(event);
         if(mRoot == null)
         {
            return;
         }
         mRoot.filters = mFiltersBeforeHighlight ?? [];
         mFiltersBeforeHighlight = null;
      }
      
      override public function destroy() : void
      {
         focusedCallback = null;
         mFiltersBeforeHighlight = null;
         mDefinition = null;
         mModel = null;
         mDBFacade = null;
         mNameLabel = null;
         mDescriptionLabel = null;
         mValueLabel = null;
         super.destroy();
      }
   }
}

