package Settings.View
{
   import Brain.Logger.Logger;
   import Brain.UI.UIRadioButton;
   import DBGlobals.DBGlobal;
   import Facade.DBFacade;
   import Facade.Locale;
   import Settings.Model.SettingCategory;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.text.TextField;
   
   public class SettingsCategoryTabs
   {
      
      private static const RADIO_GROUP:String = "SETTINGS_CATEGORY_TABS";
      
      private static const PANEL_LABEL_NAME:String = "panel_label_one";
      
      private static const PANEL_NAME_PATTERN:RegExp = /^panel_\d+$/;
      
      private static const STATE_PROPERTY_NAMES:Vector.<String> = new <String>["up","over","selected"];
      
      private var mDBFacade:DBFacade;
      
      private var mButtons:Vector.<UIRadioButton>;
      
      private var mCategories:Vector.<String>;
      
      private var mSelectedCategory:String;
      
      private var mSelectionCallback:Function;
      
      public function SettingsCategoryTabs(dbFacade:DBFacade, popupClip:MovieClip, selectionCallback:Function)
      {
         super();
         mDBFacade = dbFacade;
         mSelectionCallback = selectionCallback;
         mButtons = new Vector.<UIRadioButton>();
         mCategories = new Vector.<String>();
         buildButtons(popupClip);
      }
      
      private static function findPanels(popupClip:MovieClip) : Vector.<MovieClip>
      {
         var _loc3_:int = 0;
         var _loc4_:MovieClip = null;
         var _loc2_:Vector.<MovieClip> = new Vector.<MovieClip>();
         _loc3_ = 0;
         while(_loc3_ < popupClip.numChildren)
         {
            _loc4_ = popupClip.getChildAt(_loc3_) as MovieClip;
            if(_loc4_ != null && PANEL_NAME_PATTERN.test(_loc4_.name))
            {
               _loc2_.push(_loc4_);
            }
            _loc3_++;
         }
         _loc2_.sort(compareTopToBottom);
         return _loc2_;
      }
      
      private static function compareTopToBottom(a:DisplayObject, b:DisplayObject) : Number
      {
         return a.y - b.y;
      }
      
      private static function exposeStates(panel:MovieClip) : Boolean
      {
         var _loc3_:int = 0;
         var _loc7_:DisplayObject = null;
         var _loc4_:MovieClip = null;
         var _loc6_:Vector.<MovieClip> = new Vector.<MovieClip>();
         var _loc5_:Vector.<DisplayObject> = new Vector.<DisplayObject>();
         _loc3_ = 0;
         while(_loc3_ < panel.numChildren)
         {
            _loc7_ = panel.getChildAt(_loc3_);
            _loc4_ = _loc7_ as MovieClip;
            if(_loc4_ != null && _loc4_.getChildByName("panel_label_one") != null)
            {
               _loc6_.push(_loc4_);
            }
            else
            {
               _loc5_.push(_loc7_);
            }
            _loc3_++;
         }
         if(_loc6_.length != STATE_PROPERTY_NAMES.length)
         {
            return false;
         }
         _loc3_ = 0;
         while(_loc3_ < _loc6_.length)
         {
            panel[STATE_PROPERTY_NAMES[_loc3_]] = _loc6_[_loc3_];
            _loc3_++;
         }
         for each(var _loc2_:DisplayObject in _loc5_)
         {
            _loc2_.visible = false;
         }
         return true;
      }
      
      private static function labelPanel(panel:MovieClip, text:String) : void
      {
         var _loc3_:int = 0;
         var _loc4_:DisplayObjectContainer = null;
         var _loc5_:Boolean = setLabel(panel,text);
         _loc3_ = 0;
         while(_loc3_ < panel.numChildren)
         {
            _loc4_ = panel.getChildAt(_loc3_) as DisplayObjectContainer;
            if(_loc4_ != null && setLabel(_loc4_,text))
            {
               _loc5_ = true;
            }
            _loc3_++;
         }
         if(!_loc5_)
         {
            Logger.warn("Settings category panel has no label: " + panel.name);
         }
      }
      
      private static function setLabel(container:DisplayObjectContainer, text:String) : Boolean
      {
         var _loc3_:TextField = container.getChildByName("panel_label_one") as TextField;
         if(_loc3_ == null)
         {
            return false;
         }
         _loc3_.mouseEnabled = false;
         _loc3_.text = text;
         return true;
      }
      
      public function get selectedCategory() : String
      {
         return mSelectedCategory;
      }
      
      public function get buttons() : Vector.<UIRadioButton>
      {
         return mButtons;
      }
      
      public function get selectedButton() : UIRadioButton
      {
         var _loc1_:int = mCategories.indexOf(mSelectedCategory);
         return _loc1_ != -1 ? mButtons[_loc1_] : (mButtons.length > 0 ? mButtons[0] : null);
      }
      
      public function select(category:String) : void
      {
         var _loc2_:int = mCategories.indexOf(category);
         if(_loc2_ == -1)
         {
            return;
         }
         mSelectedCategory = category;
         mButtons[_loc2_].selected = true;
         if(mSelectionCallback != null)
         {
            mSelectionCallback(category);
         }
      }
      
      public function selectFirst() : void
      {
         if(mCategories.length > 0)
         {
            select(mCategories[0]);
         }
      }
      
      public function selectNext() : void
      {
         selectByOffset(1);
      }
      
      public function selectPrevious() : void
      {
         selectByOffset(-1);
      }
      
      private function selectByOffset(offset:int) : void
      {
         var _loc3_:int = int(mCategories.length);
         if(_loc3_ == 0)
         {
            return;
         }
         var _loc4_:int = mCategories.indexOf(mSelectedCategory);
         if(_loc4_ == -1)
         {
            select(mCategories[0]);
            return;
         }
         var _loc2_:int = (_loc4_ + offset) % _loc3_;
         if(_loc2_ < 0)
         {
            _loc2_ += _loc3_;
         }
         select(mCategories[_loc2_]);
      }
      
      public function destroy() : void
      {
         for each(var _loc1_:UIRadioButton in mButtons)
         {
            _loc1_.destroy();
         }
         mButtons = null;
         mCategories = null;
         mSelectionCallback = null;
         mDBFacade = null;
      }
      
      private function buildButtons(popupClip:MovieClip) : void
      {
         var _loc4_:int = 0;
         var _loc5_:MovieClip = null;
         var _loc6_:String = null;
         var _loc2_:UIRadioButton = null;
         var _loc3_:Vector.<MovieClip> = findPanels(popupClip);
         if(_loc3_.length < SettingCategory.ORDERED.length)
         {
            Logger.warn("Settings popup art has " + _loc3_.length + " category panels for " + SettingCategory.ORDERED.length + " categories");
         }
         _loc4_ = 0;
         while(_loc4_ < _loc3_.length)
         {
            _loc5_ = _loc3_[_loc4_];
            if(_loc4_ >= SettingCategory.ORDERED.length)
            {
               _loc5_.visible = false;
            }
            else
            {
               if(!exposeStates(_loc5_))
               {
                  Logger.warn("Settings category panel has no up/hover/selected states: " + _loc5_.name);
               }
               _loc6_ = SettingCategory.ORDERED[_loc4_];
               _loc2_ = new UIRadioButton(mDBFacade,_loc5_,"SETTINGS_CATEGORY_TABS");
               _loc2_.rolloverFilter = DBGlobal.UI_ROLLOVER_FILTER;
               _loc2_.releaseCallback = makeSelectionHandler(_loc6_);
               labelPanel(_loc5_,Locale.getString(SettingCategory.getLabelKey(_loc6_)));
               mButtons.push(_loc2_);
               mCategories.push(_loc6_);
            }
            _loc4_++;
         }
      }
      
      private function makeSelectionHandler(category:String) : Function
      {
         return function():void
         {
            select(category);
         };
      }
   }
}

