package starling.text
{
   import flash.geom.Matrix;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import starling.display.MeshBatch;
   import starling.display.Quad;
   import starling.styles.MeshStyle;
   import starling.textures.Texture;
   import starling.utils.MathUtil;
   import starling.utils.SystemUtil;
   
   public class TrueTypeCompositor implements ITextCompositor
   {
      
      private static var sHelperMatrix:Matrix = new Matrix();
      
      private static var sHelperQuad:Quad = new Quad(100,100);
      
      private static var sNativeTextField:flash.text.TextField = new flash.text.TextField();
      
      private static var sNativeFormat:flash.text.TextFormat = new flash.text.TextFormat();
      
      public function TrueTypeCompositor()
      {
         super();
      }
      
      private static function autoScaleNativeTextField(textField:flash.text.TextField, text:String, isHtmlText:Boolean) : void
      {
         var _loc7_:flash.text.TextFormat = textField.defaultTextFormat;
         var _loc5_:int = textField.width - 4;
         var _loc6_:int = textField.height - 4;
         var _loc4_:Number = Number(_loc7_.size);
         while(textField.textWidth > _loc5_ || textField.textHeight > _loc6_)
         {
            if(_loc4_ <= 4)
            {
               break;
            }
            _loc7_.size = _loc4_--;
            textField.defaultTextFormat = _loc7_;
            if(isHtmlText)
            {
               textField.htmlText = text;
            }
            else
            {
               textField.text = text;
            }
         }
      }
      
      private static function snapToPixels(coordinate:Number, scaleFactor:Number) : Number
      {
         var _loc3_:Number = NaN;
         if(coordinate == 0 || scaleFactor == 0)
         {
            return coordinate;
         }
         _loc3_ = 1 / scaleFactor;
         return Math.round(coordinate / _loc3_) * _loc3_;
      }
      
      public function dispose() : void
      {
      }
      
      public function fillMeshBatch(meshBatch:MeshBatch, width:Number, height:Number, text:String, format:starling.text.TextFormat, options:TextOptions = null) : void
      {
         var texture:Texture;
         var textureFormat:String;
         var bitmapData:BitmapDataEx;
         if(text == null || text == "")
         {
            return;
         }
         textureFormat = options.textureFormat;
         bitmapData = renderText(width,height,text,format,options);
         texture = Texture.fromBitmapData(bitmapData,false,false,bitmapData.scale,textureFormat);
         texture.root.onRestore = function():void
         {
            bitmapData = renderText(width,height,text,format,options);
            texture.root.uploadBitmapData(bitmapData);
            bitmapData.dispose();
            bitmapData = null;
         };
         bitmapData.dispose();
         bitmapData = null;
         sHelperQuad.texture = texture;
         sHelperQuad.readjustSize();
         if(format.horizontalAlign == "left")
         {
            sHelperQuad.x = 0;
         }
         else if(format.horizontalAlign == "center")
         {
            sHelperQuad.x = (width - texture.width) / 2;
         }
         else
         {
            sHelperQuad.x = width - texture.width;
         }
         if(format.verticalAlign == "top")
         {
            sHelperQuad.y = 0;
         }
         else if(format.verticalAlign == "center")
         {
            sHelperQuad.y = (height - texture.height) / 2;
         }
         else
         {
            sHelperQuad.y = height - texture.height;
         }
         sHelperQuad.x = snapToPixels(sHelperQuad.x,options.textureScale);
         sHelperQuad.y = snapToPixels(sHelperQuad.y,options.textureScale);
         meshBatch.addMesh(sHelperQuad);
         sHelperQuad.texture = null;
      }
      
      public function clearMeshBatch(meshBatch:MeshBatch) : void
      {
         meshBatch.clear();
         if(meshBatch.texture)
         {
            meshBatch.texture.dispose();
            meshBatch.texture = null;
         }
      }
      
      public function getDefaultMeshStyle(previousStyle:MeshStyle, format:starling.text.TextFormat, options:TextOptions) : MeshStyle
      {
         return null;
      }
      
      private function renderText(width:Number, height:Number, text:String, format:starling.text.TextFormat, options:TextOptions) : BitmapDataEx
      {
         var _loc14_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc19_:BitmapDataEx = null;
         var _loc7_:Number = options.textureScale;
         var _loc8_:Number = width * _loc7_;
         var _loc18_:Number = height * _loc7_;
         var _loc6_:String = format.horizontalAlign;
         format.toNativeFormat(sNativeFormat);
         sNativeFormat.size = Number(sNativeFormat.size) * _loc7_;
         sNativeTextField.embedFonts = SystemUtil.isEmbeddedFont(format.font,format.bold,format.italic);
         sNativeTextField.styleSheet = null;
         sNativeTextField.defaultTextFormat = sNativeFormat;
         sNativeTextField.styleSheet = options.styleSheet;
         sNativeTextField.width = _loc8_;
         sNativeTextField.height = _loc18_;
         sNativeTextField.antiAliasType = "advanced";
         sNativeTextField.selectable = false;
         sNativeTextField.multiline = true;
         sNativeTextField.wordWrap = options.wordWrap;
         if(options.isHtmlText)
         {
            sNativeTextField.htmlText = text;
         }
         else
         {
            sNativeTextField.text = text;
         }
         if(options.autoScale)
         {
            autoScaleNativeTextField(sNativeTextField,text,options.isHtmlText);
         }
         var _loc11_:int = 1;
         var _loc9_:int = Texture.getMaxSize(options.textureFormat);
         var _loc12_:Number = options.padding * _loc7_;
         var _loc20_:Number = options.padding * _loc7_;
         var _loc10_:Number = sNativeTextField.textWidth + 4;
         var _loc13_:Number = sNativeTextField.textHeight + 4;
         var _loc15_:int = Math.ceil(_loc10_) + 2 * _loc12_;
         var _loc17_:int = Math.ceil(_loc13_) + 2 * _loc20_;
         if(_loc15_ > _loc8_)
         {
            _loc12_ = MathUtil.max(0,(_loc8_ - _loc10_) / 2);
            _loc15_ = Math.ceil(_loc8_);
         }
         if(_loc17_ > _loc18_)
         {
            _loc20_ = MathUtil.max(0,(_loc18_ - _loc13_) / 2);
            _loc17_ = Math.ceil(_loc18_);
         }
         if(options.isHtmlText)
         {
            _loc10_ = _loc15_ = _loc8_;
         }
         if(_loc15_ < _loc11_)
         {
            _loc15_ = 1;
         }
         if(_loc17_ < _loc11_)
         {
            _loc17_ = 1;
         }
         if(_loc17_ > _loc9_ || _loc15_ > _loc9_)
         {
            options.textureScale *= _loc9_ / Math.max(_loc15_,_loc17_);
            return renderText(width,height,text,format,options);
         }
         _loc14_ = -_loc12_;
         _loc16_ = -_loc20_;
         if(!options.isHtmlText)
         {
            if(_loc6_ == "right")
            {
               _loc14_ = _loc8_ - _loc10_ - _loc12_;
            }
            else if(_loc6_ == "center")
            {
               _loc14_ = (_loc8_ - _loc10_) / 2 - _loc12_;
            }
         }
         _loc19_ = new BitmapDataEx(_loc15_,_loc17_);
         sHelperMatrix.setTo(1,0,0,1,-_loc14_,-_loc16_);
         _loc19_.draw(sNativeTextField,sHelperMatrix);
         _loc19_.scale = _loc7_;
         sNativeTextField.text = "";
         return _loc19_;
      }
   }
}

import flash.display.BitmapData;

class BitmapDataEx extends BitmapData
{
   
   private var _scale:Number = 1;
   
   public function BitmapDataEx(width:int, height:int, transparent:Boolean = true, fillColor:uint = 0)
   {
      super(width,height,transparent,fillColor);
   }
   
   public function get scale() : Number
   {
      return _scale;
   }
   
   public function set scale(value:Number) : void
   {
      _scale = value;
   }
}
