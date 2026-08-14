package Brain.UI
{
   import Brain.Facade.Facade;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
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
      
      public function UIInputText(facade:Facade, root:MovieClip)
      {
         mTextField = root.textField;
         super(facade,root);
         mTextField.addEventListener("mouseDown",onPress);
         mTextField.addEventListener("change",onChange);
         mTextField.addEventListener("keyDown",onKeyDown);
         mTextField.addEventListener("keyUp",onKeyUp);
         mTextField.addEventListener("focusIn",onFocusIn);
         mTextField.addEventListener("focusOut",onFocusOut);
      }
      
      protected function onPress(event:MouseEvent) : void
      {
         event.stopImmediatePropagation();
         mTextField.addEventListener("mouseUp",onRelease);
      }
      
      protected function onRelease(event:MouseEvent) : void
      {
         event.stopImmediatePropagation();
         mTextField.removeEventListener("mouseUp",onRelease);
      }
      
      public function set defaultTextColor(value:uint) : void
      {
         mDefaultTextColor = value;
         if(mShowingDefaultText)
         {
            mTextField.textColor = mDefaultTextColor;
         }
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
      }
      
      protected function onFocusOut(event:FocusEvent) : void
      {
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
         else if(!(event.ctrlKey && (event.keyCode == 86 || event.keyCode == 67 || event.keyCode == 88)))
         {
            event.stopPropagation();
         }
      }
      
      protected function onKeyUp(event:KeyboardEvent) : void
      {
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
      
      override public function set enabled(value:Boolean) : void
      {
         super.enabled = value;
         mTextField.tabEnabled = value;
      }
      
      override public function destroy() : void
      {
         super.destroy();
         mTextField.removeEventListener("mouseDown",onPress);
         mTextField.removeEventListener("mouseUp",onRelease);
         mTextField.removeEventListener("change",onChange);
         mTextField.removeEventListener("keyDown",onKeyDown);
         mTextField.removeEventListener("keyUp",onKeyUp);
         mTextField.removeEventListener("focusIn",onFocusIn);
         mTextField.removeEventListener("focusOut",onFocusOut);
         mTextField = null;
         mChangeCallback = null;
         mEnterCallback = null;
         mCancelCallback = null;
      }
   }
}

