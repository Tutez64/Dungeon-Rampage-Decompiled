package starling.text
{
   import flash.text.TextFormat;
   import starling.events.EventDispatcher;
   import starling.utils.Align;
   
   public class TextFormat extends EventDispatcher
   {
      
      private var _font:String;
      
      private var _size:Number;
      
      private var _color:uint;
      
      private var _bold:Boolean;
      
      private var _italic:Boolean;
      
      private var _underline:Boolean;
      
      private var _horizontalAlign:String;
      
      private var _verticalAlign:String;
      
      private var _kerning:Boolean;
      
      private var _leading:Number;
      
      private var _letterSpacing:Number;
      
      public function TextFormat(font:String = "Verdana", size:Number = 12, color:uint = 0, horizontalAlign:String = "center", verticalAlign:String = "center")
      {
         super();
         _font = font;
         _size = size;
         _color = color;
         _horizontalAlign = horizontalAlign;
         _verticalAlign = verticalAlign;
         _kerning = true;
         _letterSpacing = _leading = 0;
      }
      
      public function copyFrom(format:starling.text.TextFormat) : void
      {
         _font = format._font;
         _size = format._size;
         _color = format._color;
         _bold = format._bold;
         _italic = format._italic;
         _underline = format._underline;
         _horizontalAlign = format._horizontalAlign;
         _verticalAlign = format._verticalAlign;
         _kerning = format._kerning;
         _leading = format._leading;
         _letterSpacing = format._letterSpacing;
         dispatchEventWith("change");
      }
      
      public function clone() : starling.text.TextFormat
      {
         var _loc2_:Class = Object(this).constructor as Class;
         var _loc1_:starling.text.TextFormat = new _loc2_() as starling.text.TextFormat;
         _loc1_.copyFrom(this);
         return _loc1_;
      }
      
      public function setTo(font:String = "Verdana", size:Number = 12, color:uint = 0, horizontalAlign:String = "center", verticalAlign:String = "center") : void
      {
         _font = font;
         _size = size;
         _color = color;
         _horizontalAlign = horizontalAlign;
         _verticalAlign = verticalAlign;
         dispatchEventWith("change");
      }
      
      public function toNativeFormat(out:flash.text.TextFormat = null) : flash.text.TextFormat
      {
         if(out == null)
         {
            out = new flash.text.TextFormat();
         }
         out.font = _font;
         out.size = _size;
         out.color = _color;
         out.bold = _bold;
         out.italic = _italic;
         out.underline = _underline;
         out.align = _horizontalAlign;
         out.kerning = _kerning;
         out.leading = _leading;
         out.letterSpacing = _letterSpacing;
         return out;
      }
      
      public function get font() : String
      {
         return _font;
      }
      
      public function set font(value:String) : void
      {
         if(value != _font)
         {
            _font = value;
            dispatchEventWith("change");
         }
      }
      
      public function get size() : Number
      {
         return _size;
      }
      
      public function set size(value:Number) : void
      {
         if(value != _size)
         {
            _size = value;
            dispatchEventWith("change");
         }
      }
      
      public function get color() : uint
      {
         return _color;
      }
      
      public function set color(value:uint) : void
      {
         if(value != _color)
         {
            _color = value;
            dispatchEventWith("change");
         }
      }
      
      public function get bold() : Boolean
      {
         return _bold;
      }
      
      public function set bold(value:Boolean) : void
      {
         if(value != _bold)
         {
            _bold = value;
            dispatchEventWith("change");
         }
      }
      
      public function get italic() : Boolean
      {
         return _italic;
      }
      
      public function set italic(value:Boolean) : void
      {
         if(value != _italic)
         {
            _italic = value;
            dispatchEventWith("change");
         }
      }
      
      public function get underline() : Boolean
      {
         return _underline;
      }
      
      public function set underline(value:Boolean) : void
      {
         if(value != _underline)
         {
            _underline = value;
            dispatchEventWith("change");
         }
      }
      
      public function get horizontalAlign() : String
      {
         return _horizontalAlign;
      }
      
      public function set horizontalAlign(value:String) : void
      {
         if(!Align.isValidHorizontal(value))
         {
            throw new ArgumentError("Invalid horizontal alignment");
         }
         if(value != _horizontalAlign)
         {
            _horizontalAlign = value;
            dispatchEventWith("change");
         }
      }
      
      public function get verticalAlign() : String
      {
         return _verticalAlign;
      }
      
      public function set verticalAlign(value:String) : void
      {
         if(!Align.isValidVertical(value))
         {
            throw new ArgumentError("Invalid vertical alignment");
         }
         if(value != _verticalAlign)
         {
            _verticalAlign = value;
            dispatchEventWith("change");
         }
      }
      
      public function get kerning() : Boolean
      {
         return _kerning;
      }
      
      public function set kerning(value:Boolean) : void
      {
         if(value != _kerning)
         {
            _kerning = value;
            dispatchEventWith("change");
         }
      }
      
      public function get leading() : Number
      {
         return _leading;
      }
      
      public function set leading(value:Number) : void
      {
         if(value != _leading)
         {
            _leading = value;
            dispatchEventWith("change");
         }
      }
      
      public function get letterSpacing() : Number
      {
         return _letterSpacing;
      }
      
      public function set letterSpacing(value:Number) : void
      {
         if(value != _letterSpacing)
         {
            _letterSpacing = value;
            dispatchEventWith("change");
         }
      }
   }
}

