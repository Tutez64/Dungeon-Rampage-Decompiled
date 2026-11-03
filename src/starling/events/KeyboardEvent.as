package starling.events
{
   public class KeyboardEvent extends Event
   {
      
      public static const KEY_UP:String = "keyUp";
      
      public static const KEY_DOWN:String = "keyDown";
      
      private var _charCode:uint;
      
      private var _keyCode:uint;
      
      private var _keyLocation:uint;
      
      private var _altKey:Boolean;
      
      private var _ctrlKey:Boolean;
      
      private var _shiftKey:Boolean;
      
      private var _isDefaultPrevented:Boolean;
      
      public function KeyboardEvent(type:String, charCode:uint = 0, keyCode:uint = 0, keyLocation:uint = 0, ctrlKey:Boolean = false, altKey:Boolean = false, shiftKey:Boolean = false)
      {
         super(type,false,keyCode);
         _charCode = charCode;
         _keyCode = keyCode;
         _keyLocation = keyLocation;
         _ctrlKey = ctrlKey;
         _altKey = altKey;
         _shiftKey = shiftKey;
      }
      
      public function preventDefault() : void
      {
         _isDefaultPrevented = true;
      }
      
      public function isDefaultPrevented() : Boolean
      {
         return _isDefaultPrevented;
      }
      
      public function get charCode() : uint
      {
         return _charCode;
      }
      
      public function get keyCode() : uint
      {
         return _keyCode;
      }
      
      public function get keyLocation() : uint
      {
         return _keyLocation;
      }
      
      public function get altKey() : Boolean
      {
         return _altKey;
      }
      
      public function get ctrlKey() : Boolean
      {
         return _ctrlKey;
      }
      
      public function get shiftKey() : Boolean
      {
         return _shiftKey;
      }
   }
}

