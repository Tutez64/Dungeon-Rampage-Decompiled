package UI.Hud.StarlingConverted
{
   import Brain.Starling.SwfConverter.BakedCell;
   import Brain.Starling.SwfConverter.BakedPages;
   import Brain.Starling.SwfConverter.BakedPicture;
   import flash.display.BitmapData;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.Dictionary;
   import flash.utils.describeType;
   import flash.utils.getQualifiedClassName;
   import starling.textures.Texture;
   
   internal class StarlingGlyphFont
   {
      
      public static const LAYER_FULL:int = 0;
      
      public static const LAYER_FILL:int = 1;
      
      public static const GUTTER:Number = 2;
      
      private static const GAP:int = 1;
      
      private static var sNextObjectId:int = 0;
      
      private static const sPoint:Point = new Point();
      
      private static const sTables:Dictionary = new Dictionary(true);
      
      private static const sFilterProps:Dictionary = new Dictionary();
      
      private static const sObjectIds:Dictionary = new Dictionary(true);
      
      private var mPages:BakedPages;
      
      private var mKey:String;
      
      private var mTable:HudGlyphTable;
      
      public function StarlingGlyphFont()
      {
         super();
      }
      
      internal static function acquire(pages:BakedPages, key:String) : StarlingGlyphFont
      {
         var _loc3_:Object = sTables[pages];
         var _loc4_:HudGlyphTable = _loc3_ != null ? _loc3_[key] as HudGlyphTable : null;
         if(_loc4_ == null || !_loc4_.mCell.alive || pages.acquire(key) != _loc4_.mCell)
         {
            return null;
         }
         var _loc5_:StarlingGlyphFont = new StarlingGlyphFont();
         _loc5_.mPages = pages;
         _loc5_.mKey = key;
         _loc5_.mTable = _loc4_;
         return _loc5_;
      }
      
      public static function build(pages:BakedPages, keyPrefix:String, model:TextField, pixelScale:Number, chars:String, layer:int) : StarlingGlyphFont
      {
         pixelScale = Math.round(pixelScale * 1000) / 1000;
         var _loc15_:String = model.htmlText;
         var _loc7_:uint = model.textColor;
         var _loc10_:Array = model.filters;
         var _loc13_:String = model.autoSize;
         var _loc8_:Boolean = model.wordWrap;
         var _loc11_:Matrix = model.transform.matrix;
         var _loc9_:Rectangle = model.getBounds(model);
         var _loc12_:TextFormat = model.defaultTextFormat;
         var _loc14_:TextFormat = model.length > 0 ? model.getTextFormat(0,model.length) : model.defaultTextFormat;
         try
         {
            _loc14_.align = "left";
            model.defaultTextFormat = _loc14_;
            model.transform.matrix = new Matrix();
            model.wordWrap = false;
            model.autoSize = "left";
            return buildFrom(pages,keyPrefix,model,pixelScale,chars,layer);
         }
         finally
         {
            model.defaultTextFormat = _loc12_;
            model.filters = _loc10_;
            model.autoSize = _loc13_;
            model.wordWrap = _loc8_;
            model.htmlText = _loc15_;
            model.textColor = _loc7_;
            model.transform.matrix = new Matrix();
            model.width = _loc9_.width;
            model.height = _loc9_.height;
            model.transform.matrix = _loc11_;
         }
         return null;
      }
      
      private static function buildFrom(pages:BakedPages, keyPrefix:String, field:TextField, pixelScale:Number, chars:String, layer:int) : StarlingGlyphFont
      {
         field.text = " ";
         if(layer == 1)
         {
            field.textColor = 16777215;
            field.filters = [];
         }
         var _loc8_:String = keyPrefix + "|glyphs|" + signature(field) + "|" + layer + "|" + chars + "|" + BakedPages.scaleKey(pixelScale);
         var _loc7_:Object = sTables[pages];
         if(_loc7_ == null)
         {
            sTables[pages] = _loc7_ = {};
         }
         var _loc10_:StarlingGlyphFont = new StarlingGlyphFont();
         _loc10_.mPages = pages;
         _loc10_.mKey = _loc8_;
         var _loc9_:HudGlyphTable = _loc7_[_loc8_] as HudGlyphTable;
         if(_loc9_ != null && _loc9_.mCell.alive && pages.acquire(_loc8_) == _loc9_.mCell)
         {
            _loc10_.mTable = _loc9_;
            return _loc10_;
         }
         _loc7_[_loc8_] = false;
         try
         {
            _loc9_ = bakeTable(pages,_loc8_,field,pixelScale,chars,layer == 1);
         }
         catch(error:Error)
         {
            delete _loc7_[_loc8_];
            if(!HudArt.ready)
            {
               throw error;
            }
            StarlingHud.reportError(error);
            return null;
         }
         if(_loc9_ == null)
         {
            delete _loc7_[_loc8_];
            return null;
         }
         _loc7_[_loc8_] = _loc9_;
         _loc10_.mTable = _loc9_;
         return _loc10_;
      }
      
      private static function bakeTable(pages:BakedPages, key:String, field:TextField, pixelScale:Number, chars:String, white:Boolean) : HudGlyphTable
      {
         var _loc21_:int = 0;
         var _loc9_:int = 0;
         var _loc22_:int = 0;
         var _loc19_:int = 0;
         var _loc23_:BakedPicture = null;
         var _loc17_:BakedPicture = null;
         var _loc11_:BakedCell = null;
         var _loc12_:BakedPicture = null;
         var _loc18_:Texture = null;
         var _loc27_:BakedPicture = null;
         var _loc10_:Rectangle = null;
         var _loc15_:HudGlyphTable = new HudGlyphTable();
         _loc15_.mPixelScale = pixelScale;
         var _loc20_:Vector.<BakedPicture> = new Vector.<BakedPicture>(0);
         var _loc8_:Vector.<int> = new Vector.<int>(0);
         var _loc26_:Vector.<int> = new Vector.<int>(0);
         var _loc14_:Vector.<int> = new Vector.<int>(0);
         var _loc13_:int = pages.pageWidth - 1;
         var _loc24_:int = 0;
         var _loc25_:int = 0;
         var _loc16_:int = 0;
         var _loc7_:int = 0;
         try
         {
            _loc21_ = 0;
            while(true)
            {
               if(_loc21_ >= chars.length)
               {
                  if(_loc20_.length == 0)
                  {
                     return null;
                  }
                  field.text = " ";
                  _loc15_.mSpaceAdvance = Math.round(field.textWidth * pixelScale) / pixelScale;
                  _loc12_ = new BakedPicture();
                  _loc12_.bitmap = new BitmapData(Math.max(1,_loc7_),Math.max(1,_loc25_ + _loc16_),true,0);
                  _loc12_.pixelScale = pixelScale;
                  _loc21_ = 0;
                  while(_loc21_ < _loc20_.length)
                  {
                     sPoint.setTo(_loc26_[_loc21_],_loc14_[_loc21_]);
                     _loc12_.bitmap.copyPixels(_loc20_[_loc21_].bitmap,_loc20_[_loc21_].bitmap.rect,sPoint);
                     _loc21_++;
                  }
                  _loc11_ = pages.add(key,_loc12_,true);
                  if(_loc11_ == null)
                  {
                     return null;
                  }
                  _loc15_.mCell = _loc11_;
                  _loc21_ = 0;
                  while(_loc21_ < _loc20_.length)
                  {
                     _loc17_ = _loc20_[_loc21_];
                     _loc9_ = _loc8_[_loc21_];
                     _loc15_.mTextures[_loc9_] = Texture.fromTexture(_loc11_.texture,new Rectangle(_loc26_[_loc21_] / pixelScale,_loc14_[_loc21_] / pixelScale,_loc17_.bitmap.width / pixelScale,_loc17_.bitmap.height / pixelScale));
                     _loc15_.mOffsetsX[_loc9_] = -_loc17_.originX / pixelScale - _loc15_.mOriginsX[_loc9_];
                     _loc15_.mOffsetsY[_loc9_] = -_loc17_.originY / pixelScale - _loc15_.mOriginsY[_loc9_];
                     _loc21_++;
                  }
                  return _loc15_;
               }
               _loc9_ = chars.charCodeAt(_loc21_);
               if(!(_loc9_ >= 128 || _loc8_.indexOf(_loc9_) >= 0))
               {
                  field.text = chars.charAt(_loc21_);
                  field.setTextFormat(field.defaultTextFormat);
                  if(white)
                  {
                     field.textColor = 16777215;
                  }
                  _loc10_ = field.getBounds(field);
                  _loc23_ = StarlingRaster.bake(field,pixelScale);
                  if(_loc23_ == null)
                  {
                     return null;
                  }
                  if(_loc23_.empty && _loc9_ != 32)
                  {
                     _loc23_.dispose();
                     if(_loc9_ >= 48 && _loc9_ <= 57)
                     {
                        return null;
                     }
                  }
                  else
                  {
                     _loc22_ = _loc23_.bitmap.width;
                     _loc19_ = _loc23_.bitmap.height;
                     if(_loc24_ > 0 && _loc24_ + _loc22_ > _loc13_)
                     {
                        _loc24_ = 0;
                        _loc25_ += _loc16_ + 1;
                        _loc16_ = 0;
                     }
                     _loc20_.push(_loc23_);
                     _loc8_.push(_loc9_);
                     _loc26_.push(_loc24_);
                     _loc14_.push(_loc25_);
                     _loc15_.mOriginsX[_loc9_] = _loc10_.x;
                     _loc15_.mOriginsY[_loc9_] = _loc10_.y;
                     _loc15_.mAdvances[_loc9_] = Math.round(field.textWidth * pixelScale) / pixelScale;
                     _loc24_ += _loc22_ + 1;
                     _loc7_ = Math.max(_loc7_,_loc24_ - 1);
                     _loc16_ = Math.max(_loc16_,_loc19_);
                  }
               }
               _loc21_++;
            }
         }
         catch(error:Error)
         {
            for each(_loc18_ in _loc15_.mTextures)
            {
               if(_loc18_ != null)
               {
                  _loc18_.dispose();
               }
            }
            if(_loc15_.mCell != null)
            {
               pages.release(_loc15_.mCell);
            }
            if(!HudArt.ready)
            {
               throw error;
            }
            StarlingHud.reportError(error);
            return null;
         }
         finally
         {
            for each(_loc27_ in _loc20_)
            {
               _loc27_.dispose();
            }
            if(_loc12_ != null)
            {
               _loc12_.dispose();
            }
         }
         return null;
      }
      
      private static function signature(field:TextField) : String
      {
         var _loc2_:Object = null;
         var _loc4_:String = null;
         var _loc7_:String = null;
         var _loc8_:* = undefined;
         var _loc3_:TextFormat = field.defaultTextFormat;
         var _loc6_:Rectangle = field.getBounds(field);
         var _loc5_:Array = [_loc3_.font,_loc3_.size,_loc3_.bold,_loc3_.italic,_loc3_.underline,_loc3_.letterSpacing,_loc3_.kerning,_loc3_.leading,_loc3_.leftMargin,_loc3_.rightMargin,_loc3_.indent,_loc3_.blockIndent,_loc3_.align,_loc6_.x,_loc6_.y,field.textColor,field.embedFonts,field.antiAliasType,field.gridFitType,field.sharpness,field.thickness];
         for each(_loc2_ in field.filters)
         {
            _loc7_ = getQualifiedClassName(_loc2_);
            _loc5_.push(_loc7_);
            for each(_loc4_ in filterProps(_loc2_,_loc7_))
            {
               _loc8_ = _loc2_[_loc4_];
               if(_loc8_ is Array)
               {
                  _loc5_.push((_loc8_ as Array).join(","));
               }
               else if(_loc8_ != null && typeof _loc8_ == "object")
               {
                  _loc5_.push("#" + objectId(_loc8_));
               }
               else
               {
                  _loc5_.push(String(_loc8_));
               }
            }
         }
         return _loc5_.join(";");
      }
      
      private static function objectId(value:Object) : int
      {
         if(!(value in sObjectIds))
         {
            sObjectIds[value] = ++sNextObjectId;
         }
         return sObjectIds[value];
      }
      
      private static function filterProps(filter:Object, type:String) : Array
      {
         var _loc3_:XML = null;
         var _loc4_:XML = null;
         var _loc6_:Array = sFilterProps[type];
         if(_loc6_ != null)
         {
            return _loc6_;
         }
         _loc6_ = [];
         var _loc5_:XML = describeType(filter);
         for each(_loc3_ in _loc5_.accessor)
         {
            if(_loc3_.@access != "writeonly")
            {
               _loc6_.push(String(_loc3_.@name));
            }
         }
         for each(_loc4_ in _loc5_.variable)
         {
            _loc6_.push(String(_loc4_.@name));
         }
         _loc6_.sort();
         sFilterProps[type] = _loc6_;
         return _loc6_;
      }
      
      public function get alive() : Boolean
      {
         return mTable != null && mTable.mCell.alive;
      }
      
      public function get cell() : BakedCell
      {
         return mTable != null ? mTable.mCell : null;
      }
      
      public function hasGlyph(charCode:int) : Boolean
      {
         return mTable != null && charCode >= 0 && charCode < 128 && mTable.mTextures[charCode] != null;
      }
      
      public function advance(charCode:int) : Number
      {
         if(hasGlyph(charCode))
         {
            return mTable.mAdvances[charCode];
         }
         return charCode == 32 && mTable != null ? mTable.mSpaceAdvance : 0;
      }
      
      public function get pixelScale() : Number
      {
         return mTable != null ? mTable.mPixelScale : 1;
      }
      
      public function release() : void
      {
         var _loc1_:Object = null;
         if(mTable == null)
         {
            return;
         }
         var _loc2_:BakedCell = mTable.mCell;
         mPages.release(_loc2_);
         if(!_loc2_.alive)
         {
            _loc1_ = sTables[mPages];
            if(_loc1_ != null && _loc1_[mKey] == mTable)
            {
               delete _loc1_[mKey];
            }
         }
         mTable = null;
      }
      
      internal function glyphTexture(charCode:int) : Texture
      {
         return hasGlyph(charCode) ? mTable.mTextures[charCode] : null;
      }
      
      internal function glyphOffsetX(charCode:int) : Number
      {
         return mTable != null ? mTable.mOffsetsX[charCode] : 0;
      }
      
      internal function glyphOffsetY(charCode:int) : Number
      {
         return mTable != null ? mTable.mOffsetsY[charCode] : 0;
      }
   }
}

import Brain.Starling.SwfConverter.BakedCell;
import starling.textures.Texture;

class HudGlyphTable
{
   
   public var mCell:BakedCell;
   
   public var mPixelScale:Number = 1;
   
   public var mSpaceAdvance:Number = 0;
   
   public var mTextures:Vector.<Texture> = new Vector.<Texture>(128,true);
   
   public var mAdvances:Vector.<Number> = new Vector.<Number>(128,true);
   
   public var mOffsetsX:Vector.<Number> = new Vector.<Number>(128,true);
   
   public var mOffsetsY:Vector.<Number> = new Vector.<Number>(128,true);
   
   public var mOriginsX:Vector.<Number> = new Vector.<Number>(128,true);
   
   public var mOriginsY:Vector.<Number> = new Vector.<Number>(128,true);
   
   public function HudGlyphTable()
   {
      super();
   }
}
