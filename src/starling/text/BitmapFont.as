package starling.text
{
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   import starling.display.Image;
   import starling.display.MeshBatch;
   import starling.display.Sprite;
   import starling.styles.DistanceFieldStyle;
   import starling.styles.MeshStyle;
   import starling.textures.Texture;
   import starling.utils.StringUtil;
   
   public class BitmapFont implements ITextCompositor
   {
      
      public static const NATIVE_SIZE:int = -1;
      
      public static const MINI:String = "mini";
      
      private static const CHAR_MISSING:int = 0;
      
      private static const CHAR_TAB:int = 9;
      
      private static const CHAR_NEWLINE:int = 10;
      
      private static const CHAR_CARRIAGE_RETURN:int = 13;
      
      private static const CHAR_SPACE:int = 32;
      
      private static var sLines:Array = [];
      
      private static var sDefaultOptions:TextOptions = new TextOptions();
      
      private var _texture:Texture;
      
      private var _chars:Dictionary;
      
      private var _name:String;
      
      private var _size:Number;
      
      private var _lineHeight:Number;
      
      private var _baseline:Number;
      
      private var _offsetX:Number;
      
      private var _offsetY:Number;
      
      private var _padding:Number;
      
      private var _helperImage:Image;
      
      private var _type:String;
      
      private var _distanceFieldSpread:Number;
      
      public function BitmapFont(texture:Texture = null, fontData:* = null)
      {
         super();
         if(texture == null && fontData == null)
         {
            texture = MiniBitmapFont.texture;
            fontData = MiniBitmapFont.xml;
         }
         else if(texture == null || fontData == null)
         {
            throw new ArgumentError("Set both of the \'texture\' and \'fontData\' arguments to valid objects or leave both of them null.");
         }
         _name = "unknown";
         _lineHeight = _size = _baseline = 14;
         _offsetX = _offsetY = _padding = 0;
         _texture = texture;
         _chars = new Dictionary();
         _helperImage = new Image(texture);
         _type = "standard";
         _distanceFieldSpread = 0;
         addChar(0,new BitmapChar(0,null,0,0,0));
         parseFontData(fontData);
      }
      
      public function dispose() : void
      {
         if(_texture)
         {
            _texture.dispose();
         }
      }
      
      protected function parseFontData(data:*) : void
      {
         if(data is XML)
         {
            parseFontXml(data);
            return;
         }
         throw new ArgumentError("BitmapFont only supports XML data");
      }
      
      private function parseFontXml(fontXml:XML) : void
      {
         var _loc14_:int = 0;
         var _loc4_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc15_:Rectangle = null;
         var _loc5_:Texture = null;
         var _loc8_:BitmapChar = null;
         var _loc16_:int = 0;
         var _loc10_:int = 0;
         var _loc3_:Number = NaN;
         var _loc6_:Number = _texture.scale;
         var _loc17_:Rectangle = _texture.frame;
         var _loc7_:Number = _loc17_ ? _loc17_.x : 0;
         var _loc9_:Number = _loc17_ ? _loc17_.y : 0;
         _name = StringUtil.clean(fontXml.info.@face);
         _size = parseFloat(fontXml.info.@size) / _loc6_;
         _lineHeight = parseFloat(fontXml.common.@lineHeight) / _loc6_;
         _baseline = parseFloat(fontXml.common.@base) / _loc6_;
         if(fontXml.info.@smooth.toString() == "0")
         {
            smoothing = "none";
         }
         if(_size <= 0)
         {
            _size = _size == 0 ? 16 : _size * -1;
         }
         if(fontXml.distanceField.length())
         {
            _distanceFieldSpread = parseFloat(fontXml.distanceField.@distanceRange);
            _type = fontXml.distanceField.@fieldType == "msdf" ? "multiChannelDistanceField" : "distanceField";
         }
         else
         {
            _distanceFieldSpread = 0;
            _type = "standard";
         }
         for each(var _loc11_:XML in fontXml.chars.char)
         {
            _loc14_ = parseInt(_loc11_.@id);
            _loc4_ = parseFloat(_loc11_.@xoffset) / _loc6_;
            _loc2_ = parseFloat(_loc11_.@yoffset) / _loc6_;
            _loc13_ = parseFloat(_loc11_.@xadvance) / _loc6_;
            _loc15_ = new Rectangle();
            _loc15_.x = parseFloat(_loc11_.@x) / _loc6_ + _loc7_;
            _loc15_.y = parseFloat(_loc11_.@y) / _loc6_ + _loc9_;
            _loc15_.width = parseFloat(_loc11_.@width) / _loc6_;
            _loc15_.height = parseFloat(_loc11_.@height) / _loc6_;
            _loc5_ = Texture.fromTexture(_texture,_loc15_);
            _loc8_ = new BitmapChar(_loc14_,_loc5_,_loc4_,_loc2_,_loc13_);
            addChar(_loc14_,_loc8_);
         }
         for each(var _loc12_:XML in fontXml.kernings.kerning)
         {
            _loc16_ = parseInt(_loc12_.@first);
            _loc10_ = parseInt(_loc12_.@second);
            _loc3_ = parseFloat(_loc12_.@amount) / _loc6_;
            if(_loc10_ in _chars)
            {
               getChar(_loc10_).addKerning(_loc16_,_loc3_);
            }
         }
      }
      
      public function getChar(charID:int) : BitmapChar
      {
         return _chars[charID];
      }
      
      public function addChar(charID:int, bitmapChar:BitmapChar) : void
      {
         _chars[charID] = bitmapChar;
      }
      
      public function getCharIDs(out:Vector.<int> = null) : Vector.<int>
      {
         if(out == null)
         {
            out = new Vector.<int>(0);
         }
         for(var _loc2_ in _chars)
         {
            out[out.length] = _loc2_;
         }
         return out;
      }
      
      public function hasChars(text:String) : Boolean
      {
         var _loc2_:int = 0;
         var _loc3_:int = 0;
         if(text == null)
         {
            return true;
         }
         var _loc4_:int = text.length;
         _loc3_ = 0;
         while(_loc3_ < _loc4_)
         {
            _loc2_ = text.charCodeAt(_loc3_);
            if(_loc2_ != 32 && _loc2_ != 9 && _loc2_ != 10 && _loc2_ != 13 && getChar(_loc2_) == null)
            {
               return false;
            }
            _loc3_++;
         }
         return true;
      }
      
      public function createSprite(width:Number, height:Number, text:String, format:TextFormat, options:TextOptions = null) : Sprite
      {
         var _loc9_:int = 0;
         var _loc10_:BitmapCharLocation = null;
         var _loc8_:Image = null;
         var _loc6_:Vector.<BitmapCharLocation> = arrangeChars(width,height,text,format,options);
         var _loc12_:int = int(_loc6_.length);
         var _loc11_:String = this.smoothing;
         var _loc7_:Sprite = new Sprite();
         _loc9_ = 0;
         while(_loc9_ < _loc12_)
         {
            _loc10_ = _loc6_[_loc9_];
            _loc8_ = _loc10_.char.createImage();
            _loc8_.x = _loc10_.x;
            _loc8_.y = _loc10_.y;
            _loc8_.scale = _loc10_.scale;
            _loc8_.color = format.color;
            _loc8_.textureSmoothing = _loc11_;
            _loc7_.addChild(_loc8_);
            _loc9_++;
         }
         BitmapCharLocation.rechargePool();
         return _loc7_;
      }
      
      public function fillMeshBatch(meshBatch:MeshBatch, width:Number, height:Number, text:String, format:TextFormat, options:TextOptions = null) : void
      {
         var _loc8_:int = 0;
         var _loc9_:BitmapCharLocation = null;
         var _loc7_:Vector.<BitmapCharLocation> = arrangeChars(width,height,text,format,options);
         var _loc10_:int = int(_loc7_.length);
         _helperImage.color = format.color;
         _loc8_ = 0;
         while(_loc8_ < _loc10_)
         {
            _loc9_ = _loc7_[_loc8_];
            _helperImage.texture = _loc9_.char.texture;
            _helperImage.readjustSize();
            _helperImage.x = _loc9_.x;
            _helperImage.y = _loc9_.y;
            _helperImage.scale = _loc9_.scale;
            meshBatch.addMeshAt(_helperImage);
            _loc8_++;
         }
         BitmapCharLocation.rechargePool();
      }
      
      public function clearMeshBatch(meshBatch:MeshBatch) : void
      {
         meshBatch.clear();
      }
      
      public function getDefaultMeshStyle(previousStyle:MeshStyle, format:TextFormat, options:TextOptions) : MeshStyle
      {
         var _loc4_:DistanceFieldStyle = null;
         var _loc5_:Number = NaN;
         if(_type == "standard")
         {
            return null;
         }
         _loc5_ = format.size < 0 ? format.size * -_size : format.size;
         _loc4_ = previousStyle as DistanceFieldStyle || new DistanceFieldStyle();
         _loc4_.multiChannel = _type == "multiChannelDistanceField";
         _loc4_.softness = _size / (_loc5_ * _distanceFieldSpread);
         return _loc4_;
      }
      
      public function arrangeChars(width:Number, height:Number, text:String, format:TextFormat, options:TextOptions) : Vector.<BitmapCharLocation>
      {
         var _loc39_:BitmapCharLocation = null;
         var _loc32_:int = 0;
         var _loc18_:Number = NaN;
         var _loc35_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc30_:int = 0;
         var _loc28_:int = 0;
         var _loc24_:* = 0;
         var _loc37_:int = 0;
         var _loc36_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc20_:Vector.<BitmapCharLocation> = undefined;
         var _loc34_:Boolean = false;
         var _loc25_:int = 0;
         var _loc38_:BitmapChar = null;
         var _loc33_:int = 0;
         var _loc14_:int = 0;
         var _loc12_:Vector.<BitmapCharLocation> = undefined;
         var _loc22_:int = 0;
         var _loc27_:BitmapCharLocation = null;
         var _loc31_:Number = NaN;
         var _loc23_:int = 0;
         if(text == null || text.length == 0)
         {
            return BitmapCharLocation.vectorFromPool();
         }
         if(options == null)
         {
            options = sDefaultOptions;
         }
         var _loc6_:Boolean = format.kerning;
         var _loc10_:Number = format.leading;
         var _loc19_:Number = format.letterSpacing;
         var _loc8_:String = format.horizontalAlign;
         var _loc16_:String = format.verticalAlign;
         var _loc40_:Number = format.size;
         var _loc17_:Boolean = options.autoScale;
         var _loc11_:Boolean = options.wordWrap;
         var _loc29_:Boolean = false;
         if(_loc40_ < 0)
         {
            _loc40_ *= -_size;
         }
         while(!_loc29_)
         {
            sLines.length = 0;
            _loc13_ = _loc40_ / _size;
            _loc18_ = (width - 2 * _padding) / _loc13_;
            _loc35_ = (height - 2 * _padding) / _loc13_;
            if(_size <= _loc35_)
            {
               _loc24_ = -1;
               _loc37_ = -1;
               _loc36_ = 0;
               _loc15_ = 0;
               _loc20_ = BitmapCharLocation.vectorFromPool();
               _loc32_ = text.length;
               _loc28_ = 0;
               while(_loc28_ < _loc32_)
               {
                  _loc34_ = false;
                  _loc25_ = text.charCodeAt(_loc28_);
                  _loc38_ = getChar(_loc25_);
                  if(_loc25_ == 10 || _loc25_ == 13)
                  {
                     _loc34_ = true;
                  }
                  else
                  {
                     if(_loc38_ == null)
                     {
                        _loc25_ = 0;
                        _loc38_ = getChar(0);
                     }
                     if(_loc25_ == 32 || _loc25_ == 9)
                     {
                        _loc24_ = _loc28_;
                     }
                     if(_loc6_)
                     {
                        _loc36_ += _loc38_.getKerning(_loc37_);
                     }
                     _loc39_ = BitmapCharLocation.instanceFromPool(_loc38_);
                     _loc39_.index = _loc28_;
                     _loc39_.x = _loc36_ + _loc38_.xOffset;
                     _loc39_.y = _loc15_ + _loc38_.yOffset;
                     _loc20_[_loc20_.length] = _loc39_;
                     _loc36_ += _loc38_.xAdvance + _loc19_;
                     _loc37_ = _loc25_;
                     if(_loc39_.x + _loc38_.width > _loc18_)
                     {
                        if(_loc11_)
                        {
                           if(_loc17_ && _loc24_ == -1)
                           {
                              break;
                           }
                           _loc33_ = _loc24_ == -1 ? 1 : _loc28_ - _loc24_;
                           _loc30_ = 0;
                           while(_loc30_ < _loc33_)
                           {
                              _loc20_.pop();
                              _loc30_++;
                           }
                           if(_loc20_.length == 0)
                           {
                              break;
                           }
                           _loc28_ -= _loc33_;
                        }
                        else
                        {
                           if(_loc17_)
                           {
                              break;
                           }
                           _loc20_.pop();
                           while(_loc28_ < _loc32_ - 1 && text.charCodeAt(_loc28_) != 10)
                           {
                              _loc28_++;
                           }
                        }
                        _loc34_ = true;
                     }
                  }
                  if(_loc28_ == _loc32_ - 1)
                  {
                     sLines[sLines.length] = _loc20_;
                     _loc29_ = true;
                  }
                  else if(_loc34_)
                  {
                     sLines[sLines.length] = _loc20_;
                     if(_loc24_ == _loc28_)
                     {
                        _loc20_.pop();
                     }
                     if(_loc15_ + _lineHeight + _loc10_ + _size > _loc35_)
                     {
                        break;
                     }
                     _loc20_ = BitmapCharLocation.vectorFromPool();
                     _loc36_ = 0;
                     _loc15_ += _lineHeight + _loc10_;
                     _loc24_ = -1;
                     _loc37_ = -1;
                  }
                  _loc28_++;
               }
            }
            if(_loc17_ && !_loc29_ && _loc40_ > 3)
            {
               _loc40_ -= 1;
            }
            else
            {
               _loc29_ = true;
            }
         }
         var _loc21_:Vector.<BitmapCharLocation> = BitmapCharLocation.vectorFromPool();
         var _loc9_:int = int(sLines.length);
         var _loc26_:Number = _loc15_ + _lineHeight;
         var _loc7_:int = 0;
         if(_loc16_ == "bottom")
         {
            _loc7_ = _loc35_ - _loc26_;
         }
         else if(_loc16_ == "center")
         {
            _loc7_ = (_loc35_ - _loc26_) / 2;
         }
         if(_loc7_ < 0)
         {
            _loc7_ = 0;
         }
         _loc14_ = 0;
         while(_loc14_ < _loc9_)
         {
            _loc12_ = sLines[_loc14_];
            _loc32_ = int(_loc12_.length);
            if(_loc32_ != 0)
            {
               _loc22_ = 0;
               _loc27_ = _loc12_[_loc12_.length - 1];
               _loc31_ = _loc27_.x - _loc27_.char.xOffset + _loc27_.char.xAdvance;
               if(_loc8_ == "right")
               {
                  _loc22_ = _loc18_ - _loc31_;
               }
               else if(_loc8_ == "center")
               {
                  _loc22_ = (_loc18_ - _loc31_) / 2;
               }
               _loc23_ = 0;
               while(_loc23_ < _loc32_)
               {
                  _loc39_ = _loc12_[_loc23_];
                  _loc39_.x = _loc13_ * (_loc39_.x + _loc22_ + _offsetX) + _padding;
                  _loc39_.y = _loc13_ * (_loc39_.y + _loc7_ + _offsetY) + _padding;
                  _loc39_.scale = _loc13_;
                  if(_loc39_.char.width > 0 && _loc39_.char.height > 0)
                  {
                     _loc21_[_loc21_.length] = _loc39_;
                  }
                  _loc23_++;
               }
            }
            _loc14_++;
         }
         return _loc21_;
      }
      
      public function get name() : String
      {
         return _name;
      }
      
      public function set name(value:String) : void
      {
         _name = value;
      }
      
      public function get size() : Number
      {
         return _size;
      }
      
      public function set size(value:Number) : void
      {
         _size = value;
      }
      
      public function get type() : String
      {
         return _type;
      }
      
      public function set type(value:String) : void
      {
         _type = value;
      }
      
      public function get distanceFieldSpread() : Number
      {
         return _distanceFieldSpread;
      }
      
      public function set distanceFieldSpread(value:Number) : void
      {
         _distanceFieldSpread = value;
      }
      
      public function get lineHeight() : Number
      {
         return _lineHeight;
      }
      
      public function set lineHeight(value:Number) : void
      {
         _lineHeight = value;
      }
      
      public function get smoothing() : String
      {
         return _helperImage.textureSmoothing;
      }
      
      public function set smoothing(value:String) : void
      {
         _helperImage.textureSmoothing = value;
      }
      
      public function get baseline() : Number
      {
         return _baseline;
      }
      
      public function set baseline(value:Number) : void
      {
         _baseline = value;
      }
      
      public function get offsetX() : Number
      {
         return _offsetX;
      }
      
      public function set offsetX(value:Number) : void
      {
         _offsetX = value;
      }
      
      public function get offsetY() : Number
      {
         return _offsetY;
      }
      
      public function set offsetY(value:Number) : void
      {
         _offsetY = value;
      }
      
      public function get padding() : Number
      {
         return _padding;
      }
      
      public function set padding(value:Number) : void
      {
         _padding = value;
      }
      
      public function get texture() : Texture
      {
         return _texture;
      }
   }
}

