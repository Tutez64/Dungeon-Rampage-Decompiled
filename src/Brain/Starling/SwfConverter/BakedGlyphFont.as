package Brain.Starling.SwfConverter
{
   import flash.display.BitmapData;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.Dictionary;
   import flash.utils.describeType;
   import flash.utils.getQualifiedClassName;
   import starling.textures.Texture;
   
   public class BakedGlyphFont
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
      
      private var mTable:GlyphTable;
      
      public function BakedGlyphFont()
      {
         super();
      }
      
      public static function build(pages:BakedPages, keyPrefix:String, model:TextField, pixelScale:Number, chars:String, layer:int) : BakedGlyphFont
      {
         pixelScale = Math.round(pixelScale * 1000) / 1000;
         var _loc16_:String = model.text;
         var _loc7_:uint = model.textColor;
         var _loc9_:Array = model.filters;
         var _loc11_:String = model.autoSize;
         var _loc8_:Boolean = model.wordWrap;
         var _loc14_:Number = model.x;
         var _loc15_:Number = model.y;
         var _loc13_:Number = model.width;
         var _loc17_:Number = model.height;
         var _loc10_:TextFormat = model.defaultTextFormat;
         var _loc12_:TextFormat = model.length > 0 ? model.getTextFormat(0,model.length) : null;
         try
         {
            if(_loc12_ != null)
            {
               model.defaultTextFormat = _loc12_;
            }
            model.wordWrap = false;
            model.autoSize = "left";
            return buildFrom(pages,keyPrefix,model,pixelScale,chars,layer);
         }
         finally
         {
            model.text = _loc16_;
            if(_loc12_ != null)
            {
               model.setTextFormat(_loc12_);
            }
            model.textColor = _loc7_;
            model.defaultTextFormat = _loc10_;
            model.filters = _loc9_;
            model.autoSize = _loc11_;
            model.wordWrap = _loc8_;
            model.x = _loc14_;
            model.y = _loc15_;
            model.width = _loc13_;
            model.height = _loc17_;
         }
         return null;
      }
      
      private static function buildFrom(pages:BakedPages, keyPrefix:String, field:TextField, pixelScale:Number, chars:String, layer:int) : BakedGlyphFont
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
         var _loc10_:BakedGlyphFont = new BakedGlyphFont();
         _loc10_.mPages = pages;
         _loc10_.mKey = _loc8_;
         var _loc9_:GlyphTable = _loc7_[_loc8_];
         if(_loc9_ != null && _loc9_.cell.alive && pages.acquire(_loc8_) == _loc9_.cell)
         {
            _loc10_.mTable = _loc9_;
            return _loc10_;
         }
         delete _loc7_[_loc8_];
         _loc9_ = bakeTable(pages,_loc8_,field,pixelScale,chars,layer == 1);
         if(_loc9_ == null)
         {
            return null;
         }
         _loc7_[_loc8_] = _loc9_;
         _loc10_.mTable = _loc9_;
         return _loc10_;
      }
      
      private static function bakeTable(pages:BakedPages, key:String, field:TextField, pixelScale:Number, chars:String, white:Boolean) : GlyphTable
      {
         var _loc20_:int = 0;
         var _loc9_:int = 0;
         var _loc21_:BakedPicture = null;
         var _loc22_:int = 0;
         var _loc17_:BakedPicture = null;
         var _loc15_:GlyphTable = new GlyphTable();
         _loc15_.pixelScale = pixelScale;
         var _loc18_:Vector.<BakedPicture> = new Vector.<BakedPicture>(0);
         var _loc8_:Vector.<int> = new Vector.<int>(0);
         var _loc25_:Vector.<int> = new Vector.<int>(0);
         var _loc14_:Vector.<int> = new Vector.<int>(0);
         var _loc13_:int = pages.pageWidth - 1;
         var _loc23_:int = 0;
         var _loc24_:int = 0;
         var _loc16_:int = 0;
         var _loc7_:int = 0;
         _loc20_ = 0;
         while(_loc20_ < chars.length)
         {
            _loc9_ = chars.charCodeAt(_loc20_);
            if(!(_loc9_ >= 128 || _loc8_.indexOf(_loc9_) >= 0))
            {
               field.text = chars.charAt(_loc20_);
               if(white)
               {
                  field.textColor = 16777215;
               }
               _loc21_ = FlashBaker.bake(field,pixelScale);
               if(_loc21_ == null || _loc21_.empty && _loc9_ != 32)
               {
                  for each(var _loc26_:BakedPicture in _loc18_)
                  {
                     _loc26_.dispose();
                  }
                  return null;
               }
               _loc22_ = _loc21_.bitmap.width;
               var _loc19_:int = _loc21_.bitmap.height;
               if(_loc23_ > 0 && _loc23_ + _loc22_ > _loc13_)
               {
                  _loc23_ = 0;
                  _loc24_ += _loc16_ + 1;
                  _loc16_ = 0;
               }
               _loc18_.push(_loc21_);
               _loc8_.push(_loc9_);
               _loc25_.push(_loc23_);
               _loc14_.push(_loc24_);
               _loc15_.advances[_loc9_] = Math.round(field.textWidth * pixelScale) / pixelScale;
               _loc23_ += _loc22_ + 1;
               _loc7_ = Math.max(_loc7_,_loc23_ - 1);
               _loc16_ = Math.max(_loc16_,_loc19_);
            }
            _loc20_++;
         }
         if(_loc18_.length == 0)
         {
            return null;
         }
         field.text = " ";
         _loc15_.spaceAdvance = Math.round(field.textWidth * pixelScale) / pixelScale;
         var _loc12_:BakedPicture = new BakedPicture();
         _loc12_.bitmap = new BitmapData(Math.max(1,_loc7_),Math.max(1,_loc24_ + _loc16_),true,0);
         _loc12_.pixelScale = pixelScale;
         _loc20_ = 0;
         while(_loc20_ < _loc18_.length)
         {
            sPoint.setTo(_loc25_[_loc20_],_loc14_[_loc20_]);
            _loc12_.bitmap.copyPixels(_loc18_[_loc20_].bitmap,_loc18_[_loc20_].bitmap.rect,sPoint);
            _loc20_++;
         }
         var _loc11_:BakedCell = pages.add(key,_loc12_,false);
         if(_loc11_ == null)
         {
            for each(var _loc10_:BakedPicture in _loc18_)
            {
               _loc10_.dispose();
            }
            return null;
         }
         _loc15_.cell = _loc11_;
         _loc20_ = 0;
         while(_loc20_ < _loc18_.length)
         {
            _loc17_ = _loc18_[_loc20_];
            _loc9_ = _loc8_[_loc20_];
            _loc15_.textures[_loc9_] = Texture.fromTexture(_loc11_.texture,new Rectangle(_loc25_[_loc20_] / pixelScale,_loc14_[_loc20_] / pixelScale,_loc17_.bitmap.width / pixelScale,_loc17_.bitmap.height / pixelScale));
            _loc15_.offsetsX[_loc9_] = -_loc17_.originX / pixelScale;
            _loc15_.offsetsY[_loc9_] = -_loc17_.originY / pixelScale;
            _loc17_.dispose();
            _loc20_++;
         }
         return _loc15_;
      }
      
      private static function signature(field:TextField) : String
      {
         var _loc6_:String = null;
         var _loc7_:* = undefined;
         var _loc3_:TextFormat = field.defaultTextFormat;
         var _loc5_:Array = [_loc3_.font,_loc3_.size,_loc3_.bold,_loc3_.italic,_loc3_.underline,_loc3_.letterSpacing,_loc3_.kerning,_loc3_.leading,_loc3_.leftMargin,_loc3_.indent,_loc3_.blockIndent,field.textColor,field.embedFonts,field.antiAliasType,field.gridFitType,field.sharpness,field.thickness];
         for each(var _loc2_:Object in field.filters)
         {
            _loc6_ = getQualifiedClassName(_loc2_);
            _loc5_.push(_loc6_);
            for each(var _loc4_:String in filterProps(_loc2_,_loc6_))
            {
               _loc7_ = _loc2_[_loc4_];
               if(_loc7_ is Array)
               {
                  _loc5_.push((_loc7_ as Array).join(","));
               }
               else if(_loc7_ != null && typeof _loc7_ == "object")
               {
                  _loc5_.push("#" + objectId(_loc7_));
               }
               else
               {
                  _loc5_.push(String(_loc7_));
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
         var _loc6_:Array = sFilterProps[type];
         if(_loc6_ != null)
         {
            return _loc6_;
         }
         _loc6_ = [];
         var _loc5_:XML = describeType(filter);
         for each(var _loc3_:XML in _loc5_.accessor)
         {
            if(_loc3_.@access != "writeonly")
            {
               _loc6_.push(String(_loc3_.@name));
            }
         }
         for each(var _loc4_:XML in _loc5_.variable)
         {
            _loc6_.push(String(_loc4_.@name));
         }
         _loc6_.sort();
         sFilterProps[type] = _loc6_;
         return _loc6_;
      }
      
      public function get alive() : Boolean
      {
         return mTable != null && mTable.cell.alive;
      }
      
      public function get cell() : BakedCell
      {
         return mTable != null ? mTable.cell : null;
      }
      
      public function hasGlyph(charCode:int) : Boolean
      {
         return mTable != null && charCode >= 0 && charCode < 128 && mTable.textures[charCode] != null;
      }
      
      public function advance(charCode:int) : Number
      {
         if(hasGlyph(charCode))
         {
            return mTable.advances[charCode];
         }
         return charCode == 32 && mTable != null ? mTable.spaceAdvance : 0;
      }
      
      public function get pixelScale() : Number
      {
         return mTable != null ? mTable.pixelScale : 1;
      }
      
      public function release() : void
      {
         var _loc1_:Object = null;
         if(mTable == null)
         {
            return;
         }
         var _loc2_:BakedCell = mTable.cell;
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
         return hasGlyph(charCode) ? mTable.textures[charCode] : null;
      }
      
      internal function glyphOffsetX(charCode:int) : Number
      {
         return mTable != null ? mTable.offsetsX[charCode] : 0;
      }
      
      internal function glyphOffsetY(charCode:int) : Number
      {
         return mTable != null ? mTable.offsetsY[charCode] : 0;
      }
   }
}

import Brain.Starling.SwfConverter.BakedCell;
import starling.textures.Texture;

class GlyphTable
{
   
   public var cell:BakedCell;
   
   public var pixelScale:Number = 1;
   
   public var spaceAdvance:Number = 0;
   
   public var textures:Vector.<Texture> = new Vector.<Texture>(128,true);
   
   public var advances:Vector.<Number> = new Vector.<Number>(128,true);
   
   public var offsetsX:Vector.<Number> = new Vector.<Number>(128,true);
   
   public var offsetsY:Vector.<Number> = new Vector.<Number>(128,true);
   
   public function GlyphTable()
   {
      super();
   }
}
