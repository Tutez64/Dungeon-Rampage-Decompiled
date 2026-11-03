package Brain.Utils
{
   import Brain.Logger.Logger;
   import flash.display.DisplayObject;
   import flash.geom.Matrix;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class TextUtil
   {
      
      private static const GUTTER:int = 4;
      
      public static const DEFAULT_MIN_FONT_SIZE:int = 11;
      
      private static var sMinFontSize:int = 11;
      
      private static var sFeatureFlags:FeatureFlags;
      
      private static const CAP_RATIO:Number = 0.667;
      
      private static const DEFAULT_LOWERCASE_RATIO:Number = 0.47;
      
      private static const OVERHANG_SPACE:String = " ";
      
      private static const LOWERCASE_RATIOS:Object = {
         "Futura Bold":0.458,
         "Futura":0.458
      };
      
      public function TextUtil()
      {
         super();
      }
      
      public static function set featureFlags(value:FeatureFlags) : void
      {
         sFeatureFlags = value;
      }
      
      public static function get enabled() : Boolean
      {
         return sFeatureFlags == null || sFeatureFlags.getFlagValue("auto-size-text");
      }
      
      public static function get minFontSize() : int
      {
         return sMinFontSize;
      }
      
      public static function set minFontSize(value:int) : void
      {
         sMinFontSize = value;
      }
      
      public static function fitToField(textField:TextField, sizeModifier:Number = 1) : void
      {
         requirePositive(sizeModifier);
         if(!enabled || textField == null || textField.text == "")
         {
            return;
         }
         var _loc6_:int = floorFor(sizeModifier);
         var _loc3_:TextFormat = textField.getTextFormat();
         if(_loc3_ == null || _loc3_.size == null)
         {
            return;
         }
         var _loc7_:int = int(_loc3_.size);
         var _loc4_:Number = Math.abs(textField.scaleX);
         if(_loc4_ == 0)
         {
            return;
         }
         var _loc8_:Number = textField.width / _loc4_ - 4;
         if(_loc7_ < _loc6_)
         {
            _loc7_ = _loc6_;
            _loc3_.size = _loc7_;
            textField.setTextFormat(_loc3_);
         }
         var _loc5_:Boolean = !textField.wordWrap;
         while(_loc7_ > _loc6_ && (_loc5_ && textField.textWidth > _loc8_ || textField.bottomScrollV < textField.numLines))
         {
            _loc7_--;
            _loc3_.size = _loc7_;
            textField.setTextFormat(_loc3_);
         }
      }
      
      public static function scaleToFloor(authoredSize:Number, sizeModifier:Number = 1) : Number
      {
         requirePositive(sizeModifier);
         if(!enabled || authoredSize <= 0)
         {
            return 1;
         }
         return Math.max(1,floorFor(sizeModifier) / authoredSize);
      }
      
      public static function modifierForSize(pointSize:Number) : Number
      {
         return pointSize / sMinFontSize;
      }
      
      private static function floorFor(sizeModifier:Number) : int
      {
         return Math.max(1,Math.round(sMinFontSize * sizeModifier));
      }
      
      private static function requirePositive(sizeModifier:Number) : void
      {
         if(sizeModifier <= 0)
         {
            throw new ArgumentError("sizeModifier must be a positive number, got " + sizeModifier);
         }
      }
      
      public static function traceScaleChain(textField:TextField, tag:String) : void
      {
         var _loc3_:DisplayObject = null;
         if(textField == null)
         {
            return;
         }
         var _loc4_:String = "";
         _loc3_ = textField;
         while(_loc3_ != null)
         {
            _loc4_ = _loc3_.name + "(" + _loc3_.scaleX.toFixed(3) + ")" + (_loc4_ == "" ? "" : " > ") + _loc4_;
            _loc3_ = _loc3_.parent;
         }
         var _loc5_:Number = textField.transform.concatenatedMatrix.a;
         var _loc7_:TextFormat = textField.getTextFormat();
         var _loc6_:Number = _loc7_ != null && _loc7_.size != null ? Number(_loc7_.size) : NaN;
         Logger.debugch("font",tag + ": " + _loc4_ + " | concatenated " + _loc5_.toFixed(3) + " | " + _loc6_ + "pt = " + (_loc6_ * _loc5_).toFixed(1) + "px em" + " | onStage " + (textField.stage != null));
      }
      
      public static function glyphHeightPx(textField:TextField, useLowercase:Boolean = false) : Number
      {
         if(textField == null || textField.stage == null)
         {
            return NaN;
         }
         var _loc4_:TextFormat = textField.getTextFormat();
         if(_loc4_ == null)
         {
            return NaN;
         }
         var _loc3_:Object = _loc4_.size ?? textField.defaultTextFormat.size;
         if(_loc3_ == null)
         {
            return NaN;
         }
         var _loc7_:Matrix = textField.transform.concatenatedMatrix;
         var _loc5_:Number = Math.sqrt(_loc7_.c * _loc7_.c + _loc7_.d * _loc7_.d);
         var _loc6_:String = textField.text;
         var _loc8_:Number = 0.667;
         if(useLowercase && _loc6_ != _loc6_.toUpperCase())
         {
            if(_loc4_.font != null && LOWERCASE_RATIOS.hasOwnProperty(_loc4_.font))
            {
               _loc8_ = Number(LOWERCASE_RATIOS[_loc4_.font]);
            }
            else
            {
               _loc8_ = 0.47;
            }
         }
         return Number(_loc3_) * _loc5_ * _loc8_;
      }
      
      public static function setText(textField:TextField, text:String, sizeModifier:Number = 1) : void
      {
         textField.text = text;
         fitToField(textField,sizeModifier);
      }
      
      public static function addOverhangSlack(textField:TextField) : void
      {
         var _loc3_:TextFormat = null;
         if(textField == null || textField.embedFonts)
         {
            return;
         }
         var _loc4_:int = textField.length;
         if(_loc4_ == 0 || textField.text.charAt(_loc4_ - 1) == " ")
         {
            return;
         }
         var _loc2_:Number = textField.textWidth;
         textField.replaceText(_loc4_,_loc4_," ");
         if(textField.autoSize == "center" || textField.getTextFormat(0,1).align == "center")
         {
            _loc3_ = new TextFormat();
            _loc3_.indent = Number(textField.defaultTextFormat.indent) + textField.textWidth - _loc2_;
            textField.setTextFormat(_loc3_,0,textField.length);
         }
      }
   }
}

