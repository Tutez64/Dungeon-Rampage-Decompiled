package starling.text
{
   import flash.text.StyleSheet;
   import starling.core.Starling;
   import starling.events.EventDispatcher;
   
   public class TextOptions extends EventDispatcher
   {
      
      private var _wordWrap:Boolean;
      
      private var _autoScale:Boolean;
      
      private var _autoSize:String;
      
      private var _isHtmlText:Boolean;
      
      private var _textureScale:Number;
      
      private var _textureFormat:String;
      
      private var _styleSheet:StyleSheet;
      
      private var _padding:Number;
      
      public function TextOptions(wordWrap:Boolean = true, autoScale:Boolean = false)
      {
         super();
         _wordWrap = wordWrap;
         _autoScale = autoScale;
         _autoSize = "none";
         _textureScale = Starling.contentScaleFactor;
         _textureFormat = TextField.defaultTextureFormat;
         _isHtmlText = false;
         _padding = 0;
      }
      
      public function copyFrom(options:TextOptions) : void
      {
         _wordWrap = options._wordWrap;
         _autoScale = options._autoScale;
         _autoSize = options._autoSize;
         _isHtmlText = options._isHtmlText;
         _textureScale = options._textureScale;
         _textureFormat = options._textureFormat;
         _styleSheet = options._styleSheet;
         _padding = options._padding;
         dispatchEventWith("change");
      }
      
      public function clone() : TextOptions
      {
         var _loc2_:Class = Object(this).constructor as Class;
         var _loc1_:TextOptions = new _loc2_() as TextOptions;
         _loc1_.copyFrom(this);
         return _loc1_;
      }
      
      public function get wordWrap() : Boolean
      {
         return _wordWrap;
      }
      
      public function set wordWrap(value:Boolean) : void
      {
         if(_wordWrap != value)
         {
            _wordWrap = value;
            dispatchEventWith("change");
         }
      }
      
      public function get autoSize() : String
      {
         return _autoSize;
      }
      
      public function set autoSize(value:String) : void
      {
         if(_autoSize != value)
         {
            _autoSize = value;
            dispatchEventWith("change");
         }
      }
      
      public function get autoScale() : Boolean
      {
         return _autoScale;
      }
      
      public function set autoScale(value:Boolean) : void
      {
         if(_autoScale != value)
         {
            _autoScale = value;
            dispatchEventWith("change");
         }
      }
      
      public function get isHtmlText() : Boolean
      {
         return _isHtmlText;
      }
      
      public function set isHtmlText(value:Boolean) : void
      {
         if(_isHtmlText != value)
         {
            _isHtmlText = value;
            dispatchEventWith("change");
         }
      }
      
      public function get styleSheet() : StyleSheet
      {
         return _styleSheet;
      }
      
      public function set styleSheet(value:StyleSheet) : void
      {
         _styleSheet = value;
         dispatchEventWith("change");
      }
      
      public function get textureScale() : Number
      {
         return _textureScale;
      }
      
      public function set textureScale(value:Number) : void
      {
         _textureScale = value;
      }
      
      public function get textureFormat() : String
      {
         return _textureFormat;
      }
      
      public function set textureFormat(value:String) : void
      {
         if(_textureFormat != value)
         {
            _textureFormat = value;
            dispatchEventWith("change");
         }
      }
      
      public function get padding() : Number
      {
         return _padding;
      }
      
      public function set padding(value:Number) : void
      {
         if(value < 0)
         {
            value = 0;
         }
         if(_padding != value)
         {
            _padding = value;
            dispatchEventWith("change");
         }
      }
   }
}

