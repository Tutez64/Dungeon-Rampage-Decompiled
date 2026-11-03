package starling.text
{
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.StyleSheet;
   import flash.utils.Dictionary;
   import starling.core.Starling;
   import starling.display.DisplayObject;
   import starling.display.DisplayObjectContainer;
   import starling.display.MeshBatch;
   import starling.display.Quad;
   import starling.display.Sprite;
   import starling.rendering.Painter;
   import starling.styles.MeshStyle;
   import starling.utils.RectangleUtil;
   import starling.utils.SystemUtil;
   
   public class TextField extends DisplayObjectContainer
   {
      
      private static const COMPOSITOR_DATA_NAME:String = "starling.display.TextField.compositors";
      
      private static var sDefaultTextureFormat:String = "bgraPacked4444";
      
      private static var sMatrix:Matrix = new Matrix();
      
      private static var sDefaultCompositor:ITextCompositor = new TrueTypeCompositor();
      
      private static var sStringCache:Dictionary = new Dictionary();
      
      private var _text:String;
      
      private var _options:TextOptions;
      
      private var _format:TextFormat;
      
      private var _textBounds:Rectangle;
      
      private var _hitArea:Rectangle;
      
      private var _compositor:ITextCompositor;
      
      private var _requiresRecomposition:Boolean;
      
      private var _border:DisplayObjectContainer;
      
      private var _meshBatch:MeshBatch;
      
      private var _customStyle:MeshStyle;
      
      private var _defaultStyle:MeshStyle;
      
      private var _recomposing:Boolean;
      
      public function TextField(width:int, height:int, text:String = "", format:TextFormat = null, options:TextOptions = null)
      {
         super();
         _text = text ? text : "";
         _hitArea = new Rectangle(0,0,width,height);
         _requiresRecomposition = true;
         _compositor = sDefaultCompositor;
         _format = format ? format.clone() : new TextFormat();
         _format.addEventListener("change",setRequiresRecomposition);
         _options = options ? options.clone() : new TextOptions();
         _options.addEventListener("change",setRequiresRecomposition);
         _meshBatch = new MeshBatch();
         _meshBatch.touchable = false;
         _meshBatch.pixelSnapping = true;
         addChild(_meshBatch);
      }
      
      public static function get defaultTextureFormat() : String
      {
         return sDefaultTextureFormat;
      }
      
      public static function set defaultTextureFormat(value:String) : void
      {
         sDefaultTextureFormat = value;
      }
      
      public static function get defaultCompositor() : ITextCompositor
      {
         return sDefaultCompositor;
      }
      
      public static function set defaultCompositor(value:ITextCompositor) : void
      {
         sDefaultCompositor = value;
      }
      
      public static function updateEmbeddedFonts() : void
      {
         SystemUtil.updateEmbeddedFonts();
      }
      
      public static function registerCompositor(compositor:ITextCompositor, fontName:String) : void
      {
         if(fontName == null)
         {
            throw new ArgumentError("fontName must not be null");
         }
         compositors[convertToLowerCase(fontName)] = compositor;
      }
      
      public static function unregisterCompositor(fontName:String, dispose:Boolean = true) : void
      {
         fontName = convertToLowerCase(fontName);
         if(dispose && compositors[fontName] != undefined)
         {
            compositors[fontName].dispose();
         }
         delete compositors[fontName];
      }
      
      public static function getCompositor(fontName:String) : ITextCompositor
      {
         return compositors[convertToLowerCase(fontName)];
      }
      
      public static function registerBitmapFont(bitmapFont:BitmapFont, name:String = null) : String
      {
         if(name == null)
         {
            name = bitmapFont.name;
         }
         registerCompositor(bitmapFont,name);
         return name;
      }
      
      public static function unregisterBitmapFont(name:String, dispose:Boolean = true) : void
      {
         unregisterCompositor(name,dispose);
      }
      
      public static function getBitmapFont(name:String) : BitmapFont
      {
         return getCompositor(name) as BitmapFont;
      }
      
      private static function get compositors() : Dictionary
      {
         var _loc1_:Dictionary = Starling.painter.sharedData["starling.display.TextField.compositors"] as Dictionary;
         if(_loc1_ == null)
         {
            _loc1_ = new Dictionary();
            Starling.painter.sharedData["starling.display.TextField.compositors"] = _loc1_;
         }
         return _loc1_;
      }
      
      private static function convertToLowerCase(string:String) : String
      {
         var _loc2_:String = sStringCache[string];
         if(_loc2_ == null)
         {
            _loc2_ = string.toLowerCase();
            sStringCache[string] = _loc2_;
         }
         return _loc2_;
      }
      
      override public function dispose() : void
      {
         _format.removeEventListener("change",setRequiresRecomposition);
         _options.removeEventListener("change",setRequiresRecomposition);
         _compositor.clearMeshBatch(_meshBatch);
         super.dispose();
      }
      
      override public function render(painter:Painter) : void
      {
         if(_requiresRecomposition)
         {
            recompose();
         }
         super.render(painter);
      }
      
      private function recompose() : void
      {
         var _loc1_:String = null;
         var _loc2_:ITextCompositor = null;
         if(_requiresRecomposition)
         {
            _recomposing = true;
            _compositor.clearMeshBatch(_meshBatch);
            _loc1_ = _format.font;
            _loc2_ = getCompositor(_loc1_);
            if(_loc2_ == null && _loc1_ == "mini")
            {
               _loc2_ = new BitmapFont();
               registerCompositor(_loc2_,_loc1_);
            }
            _compositor = _loc2_ ? _loc2_ : sDefaultCompositor;
            updateText();
            updateBorder();
            _requiresRecomposition = false;
            _recomposing = false;
         }
      }
      
      private function updateText() : void
      {
         var _loc1_:Number = _hitArea.width;
         var _loc2_:Number = _hitArea.height;
         if(isHorizontalAutoSize && !_options.isHtmlText)
         {
            _loc1_ = 100000;
         }
         if(isVerticalAutoSize)
         {
            _loc2_ = 100000;
         }
         _meshBatch.x = _meshBatch.y = 0;
         _options.textureScale = Starling.contentScaleFactor;
         _compositor.fillMeshBatch(_meshBatch,_loc1_,_loc2_,_text,_format,_options);
         if(_customStyle)
         {
            _meshBatch.style = _customStyle;
         }
         else
         {
            _defaultStyle = _compositor.getDefaultMeshStyle(_defaultStyle,_format,_options);
            if(_defaultStyle)
            {
               _meshBatch.style = _defaultStyle;
            }
         }
         if(_options.autoSize != "none")
         {
            _textBounds = _meshBatch.getBounds(_meshBatch,_textBounds);
            if(isHorizontalAutoSize)
            {
               _meshBatch.x = _textBounds.x = -_textBounds.x;
               _hitArea.width = _textBounds.width;
               _textBounds.x = 0;
            }
            if(isVerticalAutoSize)
            {
               _meshBatch.y = _textBounds.y = -_textBounds.y;
               _hitArea.height = _textBounds.height;
               _textBounds.y = 0;
            }
         }
         else
         {
            _textBounds = null;
         }
      }
      
      private function updateBorder() : void
      {
         if(_border == null)
         {
            return;
         }
         var _loc4_:Number = _hitArea.width;
         var _loc6_:Number = _hitArea.height;
         var _loc1_:Quad = _border.getChildAt(0) as Quad;
         var _loc3_:Quad = _border.getChildAt(1) as Quad;
         var _loc5_:Quad = _border.getChildAt(2) as Quad;
         var _loc2_:Quad = _border.getChildAt(3) as Quad;
         _loc1_.width = _loc4_;
         _loc1_.height = 1;
         _loc5_.width = _loc4_;
         _loc5_.height = 1;
         _loc2_.width = 1;
         _loc2_.height = _loc6_;
         _loc3_.width = 1;
         _loc3_.height = _loc6_;
         _loc3_.x = _loc4_ - 1;
         _loc5_.y = _loc6_ - 1;
         _loc1_.color = _loc3_.color = _loc5_.color = _loc2_.color = _format.color;
      }
      
      public function setRequiresRecomposition() : void
      {
         if(!_recomposing)
         {
            _requiresRecomposition = true;
            setRequiresRedraw();
         }
      }
      
      private function get isHorizontalAutoSize() : Boolean
      {
         return _options.autoSize == "horizontal" || _options.autoSize == "bothDirections";
      }
      
      private function get isVerticalAutoSize() : Boolean
      {
         return _options.autoSize == "vertical" || _options.autoSize == "bothDirections";
      }
      
      public function get textBounds() : Rectangle
      {
         return getTextBounds(this);
      }
      
      override public function getBounds(targetSpace:DisplayObject, out:Rectangle = null) : Rectangle
      {
         if(_requiresRecomposition)
         {
            recompose();
         }
         getTransformationMatrix(targetSpace,sMatrix);
         return RectangleUtil.getBounds(_hitArea,sMatrix,out);
      }
      
      public function getTextBounds(targetSpace:DisplayObject, out:Rectangle = null) : Rectangle
      {
         if(_requiresRecomposition)
         {
            recompose();
         }
         if(_textBounds == null)
         {
            _textBounds = _meshBatch.getBounds(this);
         }
         getTransformationMatrix(targetSpace,sMatrix);
         return RectangleUtil.getBounds(_textBounds,sMatrix,out);
      }
      
      override public function hitTest(localPoint:Point) : DisplayObject
      {
         if(!visible || !touchable || !hitTestMask(localPoint))
         {
            return null;
         }
         if(_hitArea.containsPoint(localPoint))
         {
            return this;
         }
         return null;
      }
      
      override public function set width(value:Number) : void
      {
         _hitArea.width = value / (scaleX || 1);
         setRequiresRecomposition();
      }
      
      override public function set height(value:Number) : void
      {
         _hitArea.height = value / (scaleY || 1);
         setRequiresRecomposition();
      }
      
      public function get text() : String
      {
         return _text;
      }
      
      public function set text(value:String) : void
      {
         if(value == null)
         {
            value = "";
         }
         if(_text != value)
         {
            _text = value;
            setRequiresRecomposition();
         }
      }
      
      public function get format() : TextFormat
      {
         return _format;
      }
      
      public function set format(value:TextFormat) : void
      {
         if(value == null)
         {
            throw new ArgumentError("format cannot be null");
         }
         _format.copyFrom(value);
      }
      
      protected function get options() : TextOptions
      {
         return _options;
      }
      
      public function get border() : Boolean
      {
         return _border != null;
      }
      
      public function set border(value:Boolean) : void
      {
         var _loc2_:int = 0;
         if(value && _border == null)
         {
            _border = new Sprite();
            addChild(_border);
            _loc2_ = 0;
            while(_loc2_ < 4)
            {
               _border.addChild(new Quad(1,1));
               _loc2_++;
            }
            updateBorder();
         }
         else if(!value && _border != null)
         {
            _border.removeFromParent(true);
            _border = null;
         }
      }
      
      public function get autoScale() : Boolean
      {
         return _options.autoScale;
      }
      
      public function set autoScale(value:Boolean) : void
      {
         _options.autoScale = value;
      }
      
      public function get autoSize() : String
      {
         return _options.autoSize;
      }
      
      public function set autoSize(value:String) : void
      {
         _options.autoSize = value;
      }
      
      public function get wordWrap() : Boolean
      {
         return _options.wordWrap;
      }
      
      public function set wordWrap(value:Boolean) : void
      {
         _options.wordWrap = value;
      }
      
      public function get batchable() : Boolean
      {
         return _meshBatch.batchable;
      }
      
      public function set batchable(value:Boolean) : void
      {
         _meshBatch.batchable = value;
      }
      
      public function get isHtmlText() : Boolean
      {
         return _options.isHtmlText;
      }
      
      public function set isHtmlText(value:Boolean) : void
      {
         _options.isHtmlText = value;
      }
      
      public function get styleSheet() : StyleSheet
      {
         return _options.styleSheet;
      }
      
      public function set styleSheet(value:StyleSheet) : void
      {
         _options.styleSheet = value;
      }
      
      public function get padding() : Number
      {
         return _options.padding;
      }
      
      public function set padding(value:Number) : void
      {
         _options.padding = value;
      }
      
      public function get pixelSnapping() : Boolean
      {
         return _meshBatch.pixelSnapping;
      }
      
      public function set pixelSnapping(value:Boolean) : void
      {
         _meshBatch.pixelSnapping = value;
      }
      
      public function get style() : MeshStyle
      {
         if(_requiresRecomposition)
         {
            recompose();
         }
         return _meshBatch.style;
      }
      
      public function set style(value:MeshStyle) : void
      {
         _customStyle = value;
         setRequiresRecomposition();
      }
   }
}

