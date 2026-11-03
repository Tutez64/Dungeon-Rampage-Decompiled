package starling.utils
{
   import starling.errors.AbstractClassError;
   
   public class Color
   {
      
      public static const WHITE:uint = 16777215;
      
      public static const SILVER:uint = 12632256;
      
      public static const GRAY:uint = 8421504;
      
      public static const BLACK:uint = 0;
      
      public static const RED:uint = 16711680;
      
      public static const MAROON:uint = 8388608;
      
      public static const YELLOW:uint = 16776960;
      
      public static const OLIVE:uint = 8421376;
      
      public static const LIME:uint = 65280;
      
      public static const GREEN:uint = 32768;
      
      public static const AQUA:uint = 65535;
      
      public static const TEAL:uint = 32896;
      
      public static const BLUE:uint = 255;
      
      public static const NAVY:uint = 128;
      
      public static const FUCHSIA:uint = 16711935;
      
      public static const PURPLE:uint = 8388736;
      
      public function Color()
      {
         super();
         throw new AbstractClassError();
      }
      
      public static function getAlpha(color:uint) : int
      {
         return color >> 24 & 0xFF;
      }
      
      public static function getRed(color:uint) : int
      {
         return color >> 16 & 0xFF;
      }
      
      public static function getGreen(color:uint) : int
      {
         return color >> 8 & 0xFF;
      }
      
      public static function getBlue(color:uint) : int
      {
         return color & 0xFF;
      }
      
      public static function setAlpha(color:uint, alpha:int) : uint
      {
         return color & 0xFFFFFF | (alpha & 0xFF) << 24;
      }
      
      public static function setRed(color:uint, red:int) : uint
      {
         return color & 0xFF00FFFF | (red & 0xFF) << 16;
      }
      
      public static function setGreen(color:uint, green:int) : uint
      {
         return color & 0xFFFF00FF | (green & 0xFF) << 8;
      }
      
      public static function setBlue(color:uint, blue:int) : uint
      {
         return color & 0xFFFFFF00 | blue & 0xFF;
      }
      
      public static function rgb(red:int, green:int, blue:int) : uint
      {
         return red << 16 | green << 8 | blue;
      }
      
      public static function argb(alpha:int, red:int, green:int, blue:int) : uint
      {
         return alpha << 24 | red << 16 | green << 8 | blue;
      }
      
      public static function hsv(hue:Number, saturation:Number, value:Number) : uint
      {
         var _loc10_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc11_:Number = Math.floor(hue * 6);
         var _loc9_:Number = hue * 6 - _loc11_;
         var _loc4_:Number = value * (1 - saturation);
         var _loc5_:Number = value * (1 - _loc9_ * saturation);
         var _loc8_:Number = value * (1 - (1 - _loc9_) * saturation);
         switch(int(_loc11_ % 6))
         {
            case 0:
               _loc7_ = value;
               _loc10_ = _loc8_;
               _loc6_ = _loc4_;
               break;
            case 1:
               _loc7_ = _loc5_;
               _loc10_ = value;
               _loc6_ = _loc4_;
               break;
            case 2:
               _loc7_ = _loc4_;
               _loc10_ = value;
               _loc6_ = _loc8_;
               break;
            case 3:
               _loc7_ = _loc4_;
               _loc10_ = _loc5_;
               _loc6_ = value;
               break;
            case 4:
               _loc7_ = _loc8_;
               _loc10_ = _loc4_;
               _loc6_ = value;
               break;
            case 5:
               _loc7_ = value;
               _loc10_ = _loc4_;
               _loc6_ = _loc5_;
         }
         return rgb(Math.ceil(_loc7_ * 255),Math.ceil(_loc10_ * 255),Math.ceil(_loc6_ * 255));
      }
      
      public static function hsl(hue:Number, saturation:Number, lightness:Number) : uint
      {
         var _loc7_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc6_:Number = (1 - Math.abs(2 * lightness - 1)) * saturation;
         var _loc9_:Number = hue * 6;
         var _loc8_:Number = _loc6_ * (1 - Math.abs(_loc9_ % 2 - 1));
         var _loc10_:Number = lightness - _loc6_ / 2;
         switch(int(_loc9_ % 6))
         {
            case 0:
               _loc5_ = _loc6_ + _loc10_;
               _loc7_ = _loc8_ + _loc10_;
               _loc4_ = _loc10_;
               break;
            case 1:
               _loc5_ = _loc8_ + _loc10_;
               _loc7_ = _loc6_ + _loc10_;
               _loc4_ = _loc10_;
               break;
            case 2:
               _loc5_ = _loc10_;
               _loc7_ = _loc6_ + _loc10_;
               _loc4_ = _loc8_ + _loc10_;
               break;
            case 3:
               _loc5_ = _loc10_;
               _loc7_ = _loc8_ + _loc10_;
               _loc4_ = _loc6_ + _loc10_;
               break;
            case 4:
               _loc5_ = _loc8_ + _loc10_;
               _loc7_ = _loc10_;
               _loc4_ = _loc6_ + _loc10_;
               break;
            case 5:
               _loc5_ = _loc6_ + _loc10_;
               _loc7_ = _loc10_;
               _loc4_ = _loc8_ + _loc10_;
         }
         return rgb(Math.ceil(_loc5_ * 255),Math.ceil(_loc7_ * 255),Math.ceil(_loc4_ * 255));
      }
      
      public static function rgbToHsv(rgb:uint, hsv:Vector.<Number> = null) : Vector.<Number>
      {
         if(hsv == null)
         {
            hsv = new Vector.<Number>(3,true);
         }
         var _loc4_:Number = Color.getRed(rgb) / 255;
         var _loc6_:Number = Color.getGreen(rgb) / 255;
         var _loc5_:Number = Color.getBlue(rgb) / 255;
         var _loc8_:Number = Math.max(_loc4_,_loc6_,_loc5_);
         var _loc3_:Number = Math.min(_loc4_,_loc6_,_loc5_);
         var _loc7_:Number = _loc8_ - _loc3_;
         if(_loc7_ == 0)
         {
            hsv[0] = 0;
         }
         else if(_loc8_ == _loc4_)
         {
            hsv[0] = (_loc6_ - _loc5_) / _loc7_ % 6 / 6;
         }
         else if(_loc8_ == _loc6_)
         {
            hsv[0] = ((_loc5_ - _loc4_) / _loc7_ + 2) / 6;
         }
         else if(_loc8_ == _loc5_)
         {
            hsv[0] = ((_loc4_ - _loc6_) / _loc7_ + 4) / 6;
         }
         while(hsv[0] < 0)
         {
            var _loc9_:* = 0;
            var _loc10_:* = hsv[_loc9_] + 1;
            hsv[_loc9_] = _loc10_;
         }
         while(hsv[0] >= 1)
         {
            _loc10_ = 0;
            _loc9_ = hsv[_loc10_] - 1;
            hsv[_loc10_] = _loc9_;
         }
         hsv[2] = _loc8_;
         hsv[1] = _loc8_ == 0 ? 0 : _loc7_ / _loc8_;
         return hsv;
      }
      
      public static function rgbToHsl(rgb:uint, hsl:Vector.<Number> = null) : Vector.<Number>
      {
         if(hsl == null)
         {
            hsl = new Vector.<Number>(3,true);
         }
         var _loc4_:Number = Color.getRed(rgb) / 255;
         var _loc6_:Number = Color.getGreen(rgb) / 255;
         var _loc5_:Number = Color.getBlue(rgb) / 255;
         var _loc8_:Number = Math.max(_loc4_,_loc6_,_loc5_);
         var _loc3_:Number = Math.min(_loc4_,_loc6_,_loc5_);
         var _loc7_:Number = _loc8_ - _loc3_;
         if(_loc7_ == 0)
         {
            hsl[0] = 0;
         }
         else if(_loc8_ == _loc4_)
         {
            hsl[0] = (_loc6_ - _loc5_) / _loc7_ % 6 / 6;
         }
         else if(_loc8_ == _loc6_)
         {
            hsl[0] = ((_loc5_ - _loc4_) / _loc7_ + 2) / 6;
         }
         else if(_loc8_ == _loc5_)
         {
            hsl[0] = ((_loc4_ - _loc6_) / _loc7_ + 4) / 6;
         }
         while(hsl[0] < 0)
         {
            var _loc9_:* = 0;
            var _loc10_:* = hsl[_loc9_] + 1;
            hsl[_loc9_] = _loc10_;
         }
         while(hsl[0] >= 1)
         {
            _loc10_ = 0;
            _loc9_ = hsl[_loc10_] - 1;
            hsl[_loc10_] = _loc9_;
         }
         hsl[2] = (_loc8_ + _loc3_) * 0.5;
         hsl[1] = _loc7_ == 0 ? 0 : _loc7_ / (1 - Math.abs(2 * hsl[2] - 1));
         return hsl;
      }
      
      public static function toVector(color:uint, out:Vector.<Number> = null) : Vector.<Number>
      {
         if(out == null)
         {
            out = new Vector.<Number>(4,true);
         }
         out[0] = (color >> 16 & 0xFF) / 255;
         out[1] = (color >> 8 & 0xFF) / 255;
         out[2] = (color & 0xFF) / 255;
         out[3] = (color >> 24 & 0xFF) / 255;
         return out;
      }
      
      public static function multiply(color:uint, factor:Number) : uint
      {
         if(factor == 0)
         {
            return 0;
         }
         var _loc6_:uint = (color >> 24 & 0xFF) * factor;
         var _loc3_:uint = (color >> 16 & 0xFF) * factor;
         var _loc4_:uint = (color >> 8 & 0xFF) * factor;
         var _loc5_:uint = (color & 0xFF) * factor;
         if(_loc6_ > 255)
         {
            _loc6_ = 255;
         }
         if(_loc3_ > 255)
         {
            _loc3_ = 255;
         }
         if(_loc4_ > 255)
         {
            _loc4_ = 255;
         }
         if(_loc5_ > 255)
         {
            _loc5_ = 255;
         }
         return argb(_loc6_,_loc3_,_loc4_,_loc5_);
      }
      
      public static function interpolate(startColor:uint, endColor:uint, ratio:Number) : uint
      {
         var _loc11_:uint = uint(startColor >> 24 & 0xFF);
         var _loc15_:uint = uint(startColor >> 16 & 0xFF);
         var _loc6_:uint = uint(startColor >> 8 & 0xFF);
         var _loc9_:uint = uint(startColor & 0xFF);
         var _loc8_:uint = uint(endColor >> 24 & 0xFF);
         var _loc14_:uint = uint(endColor >> 16 & 0xFF);
         var _loc5_:uint = uint(endColor >> 8 & 0xFF);
         var _loc7_:uint = uint(endColor & 0xFF);
         var _loc12_:uint = _loc11_ + (_loc8_ - _loc11_) * ratio;
         var _loc4_:uint = _loc15_ + (_loc14_ - _loc15_) * ratio;
         var _loc13_:uint = _loc6_ + (_loc5_ - _loc6_) * ratio;
         var _loc10_:uint = _loc9_ + (_loc7_ - _loc9_) * ratio;
         return _loc12_ << 24 | _loc4_ << 16 | _loc13_ << 8 | _loc10_;
      }
   }
}

