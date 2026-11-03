package Brain.UI
{
   import Brain.Event.EventListeners;
   import Brain.Facade.Facade;
   import Brain.Utils.TextUtil;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.text.TextField;
   
   public class UIInputText extends UIObject
   {
      
      protected var mTextField:TextField;
      
      private var mDefaultText:String;
      
      private var mDefaultTextColor:uint = 8947848;
      
      private var mNormalTextColor:uint = 0;
      
      private var mShowingDefaultText:Boolean = false;
      
      protected var mChangeCallback:Function;
      
      protected var mEnterCallback:Function;
      
      protected var mCancelCallback:Function;
      
      protected var mMenuNavigationKeysEnabled:Boolean = false;
      
      protected var mRolloverFilter:GlowFilter;
      
      protected var mFiltersBeforeRollover:Array;
      
      protected var mFiltersCaptured:Boolean = false;
      
      protected var mFocusInCallback:Function;
      
      protected var mSelectedCallback:Function;
      
      protected var mFocusOutCallback:Function;
      
      public function UIInputText(facade:Facade, root:MovieClip)
      {
         mTextField = root.textField;
         super(facade,root);
         EventListeners.add(mTextField,"mouseDown",onPress);
         EventListeners.add(mTextField,"change",onChange);
         EventListeners.add(mTextField,"keyDown",onKeyDown);
         EventListeners.add(mTextField,"keyUp",onKeyUp);
         EventListeners.add(mTextField,"focusIn",onFocusIn);
         EventListeners.add(mTextField,"focusOut",onFocusOut);
      }
      
      protected function onPress(event:MouseEvent) : void
      {
         event.stopImmediatePropagation();
         EventListeners.add(mTextField,"mouseUp",onRelease);
      }
      
      protected function onRelease(event:MouseEvent) : void
      {
         event.stopImmediatePropagation();
         EventListeners.remove(mTextField,"mouseUp",onRelease);
      }
      
      override public function onSelected(fromController:Boolean = false) : void
      {
         if(mFacade != null && mFacade.stageRef != null && mTextField != null)
         {
            mFacade.stageRef.focus = mTextField;
         }
         if(mSelectedCallback != null)
         {
            mSelectedCallback(fromController);
         }
      }
      
      public function releaseKeyboardFocus() : void
      {
         if(mFacade == null || mFacade.stageRef == null || mTextField == null)
         {
            return;
         }
         if(mFacade.stageRef.focus == mTextField)
         {
            mFacade.stageRef.focus = null;
         }
      }
      
      override protected function onRollOver(event:MouseEvent) : void
      {
         super.onRollOver(event);
         if(!mRolloverFilter || mFiltersCaptured || !mRoot)
         {
            return;
         }
         mFiltersBeforeRollover = mRoot.filters.slice();
         mFiltersCaptured = true;
         mRoot.filters = [mRolloverFilter];
      }
      
      override protected function onRollOut(event:MouseEvent) : void
      {
         super.onRollOut(event);
         if(!mFiltersCaptured)
         {
            return;
         }
         if(mRoot)
         {
            mRoot.filters = mFiltersBeforeRollover;
         }
         mFiltersBeforeRollover = null;
         mFiltersCaptured = false;
      }
      
      public function set menuNavigationKeysEnabled(value:Boolean) : void
      {
         mMenuNavigationKeysEnabled = value;
      }
      
      public function get menuNavigationKeysEnabled() : Boolean
      {
         return mMenuNavigationKeysEnabled;
      }
      
      public function set rolloverFilter(value:GlowFilter) : void
      {
         mRolloverFilter = value;
      }
      
      public function get rolloverFilter() : GlowFilter
      {
         return mRolloverFilter;
      }
      
      public function set defaultTextColor(value:uint) : void
      {
         mDefaultTextColor = value;
         if(mShowingDefaultText)
         {
            mTextField.textColor = mDefaultTextColor;
         }
      }
      
      public function get defaultTextColor() : uint
      {
         return mDefaultTextColor;
      }
      
      public function get showingDefaultText() : Boolean
      {
         return mShowingDefaultText;
      }
      
      public function set normalTextColor(value:uint) : void
      {
         mNormalTextColor = value;
         if(!mShowingDefaultText)
         {
            mTextField.textColor = mNormalTextColor;
         }
      }
      
      public function set defaultText(value:String) : void
      {
         mDefaultText = value;
         mTextField.text = mDefaultText;
         TextUtil.addOverhangSlack(mTextField);
         mTextField.textColor = mDefaultTextColor;
         mShowingDefaultText = true;
      }
      
      public function get text() : String
      {
         if(mShowingDefaultText)
         {
            return "";
         }
         return mTextField.text;
      }
      
      public function set text(value:String) : void
      {
         mTextField.text = value;
      }
      
      protected function onFocusIn(event:FocusEvent) : void
      {
         if(mShowingDefaultText)
         {
            this.clear();
            mShowingDefaultText = false;
            mTextField.textColor = mNormalTextColor;
         }
         if(mFocusInCallback != null)
         {
            mFocusInCallback();
         }
      }
      
      protected function onFocusOut(event:FocusEvent) : void
      {
         if(mFocusOutCallback != null)
         {
            mFocusOutCallback();
         }
      }
      
      public function get textField() : TextField
      {
         return mTextField;
      }
      
      protected function onKeyDown(event:KeyboardEvent) : void
      {
         if(event.keyCode == 13 && mEnterCallback != null && !mShowingDefaultText)
         {
            if(mTextField)
            {
               mEnterCallback(mTextField.text);
            }
            event.stopPropagation();
         }
         else if(event.keyCode == 27 && mCancelCallback != null)
         {
            mCancelCallback();
            event.stopPropagation();
         }
         else if(!(mMenuNavigationKeysEnabled && (event.keyCode == 38 || event.keyCode == 40)))
         {
            if(!(event.ctrlKey && (event.keyCode == 86 || event.keyCode == 67 || event.keyCode == 88)))
            {
               event.stopPropagation();
            }
         }
      }
      
      protected function onKeyUp(event:KeyboardEvent) : void
      {
         if(mFacade != null && mFacade.inputManager != null)
         {
            mFacade.inputManager.releaseKey(event.keyCode);
         }
         if(!(event.ctrlKey && (event.keyCode == 86 || event.keyCode == 67 || event.keyCode == 88)))
         {
            event.stopPropagation();
         }
      }
      
      protected function onChange(event:Event) : void
      {
         if(mChangeCallback != null)
         {
            mChangeCallback(mTextField.text);
         }
      }
      
      public function clear() : void
      {
         mTextField.text = "";
         if(mChangeCallback != null)
         {
            mChangeCallback("");
         }
      }
      
      public function set changeCallback(value:Function) : void
      {
         mChangeCallback = value;
      }
      
      public function set enterCallback(value:Function) : void
      {
         mEnterCallback = value;
      }
      
      public function set cancelCallback(value:Function) : void
      {
         mCancelCallback = value;
      }
      
      public function set focusInCallback(value:Function) : void
      {
         mFocusInCallback = value;
      }
      
      public function set selectedCallback(value:Function) : void
      {
         mSelectedCallback = value;
      }
      
      public function set focusOutCallback(value:Function) : void
      {
         mFocusOutCallback = value;
      }
      
      override public function set enabled(value:Boolean) : void
      {
         super.enabled = value;
         mTextField.tabEnabled = value;
      }
      
      override public function destroy() : void
      {
         releaseKeyboardFocus();
         super.destroy();
         EventListeners.remove(mTextField,"mouseDown",onPress);
         EventListeners.remove(mTextField,"mouseUp",onRelease);
         EventListeners.remove(mTextField,"change",onChange);
         EventListeners.remove(mTextField,"keyDown",onKeyDown);
         EventListeners.remove(mTextField,"keyUp",onKeyUp);
         EventListeners.remove(mTextField,"focusIn",onFocusIn);
         EventListeners.remove(mTextField,"focusOut",onFocusOut);
         mTextField = null;
         mRolloverFilter = null;
         mFiltersBeforeRollover = null;
         mChangeCallback = null;
         mEnterCallback = null;
         mCancelCallback = null;
         mFocusInCallback = null;
         mFocusOutCallback = null;
         mSelectedCallback = null;
      }
   }
}

