package Brain.Utils
{
   import flash.filters.ColorMatrixFilter;
   
   public class ColorMatrix
   {
      
      private static const LUMA_R:Number = 0.212671;
      
      private static const LUMA_G:Number = 0.71516;
      
      private static const LUMA_B:Number = 0.072169;
      
      private static const LUMA_R2:Number = 0.3086;
      
      private static const LUMA_G2:Number = 0.6094;
      
      private static const LUMA_B2:Number = 0.082;
      
      private static const ONETHIRD:Number = 0.3333333333333333;
      
      private static const RAD:Number = 0.017453292519943295;
      
      public static const COLOR_DEFICIENCY_TYPES:Array = ["Protanopia","Protanomaly","Deuteranopia","Deuteranomaly","Tritanopia","Tritanomaly","Achromatopsia","Achromatomaly"];
      
      private static const IDENTITY:Array = [1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0];
      
      public var matrix:Array;
      
      private var preHue:ColorMatrix;
      
      private var postHue:ColorMatrix;
      
      private var hueInitialized:Boolean;
      
      public function ColorMatrix(mat:Object = null)
      {
         super();
         if(mat is ColorMatrix)
         {
            matrix = mat.matrix.concat();
         }
         else if(mat is Array)
         {
            matrix = mat.concat();
         }
         else
         {
            reset();
         }
      }
      
      public function reset() : void
      {
         matrix = IDENTITY.concat();
      }
      
      public function clone() : ColorMatrix
      {
         return new ColorMatrix(matrix);
      }
      
      public function invert() : void
      {
         concat([-1,0,0,0,255,0,-1,0,0,255,0,0,-1,0,255,0,0,0,1,0]);
      }
      
      public function adjustSaturation(s:Number) : void
      {
         var _loc3_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         _loc3_ = 1 - s;
         _loc2_ = _loc3_ * 0.212671;
         _loc4_ = _loc3_ * 0.71516;
         _loc5_ = _loc3_ * 0.072169;
         concat([_loc2_ + s,_loc4_,_loc5_,0,0,_loc2_,_loc4_ + s,_loc5_,0,0,_loc2_,_loc4_,_loc5_ + s,0,0,0,0,0,1,0]);
      }
      
      public function adjustContrast(r:Number, g:Number = NaN, b:Number = NaN) : void
      {
         if(isNaN(g))
         {
            g = r;
         }
         if(isNaN(b))
         {
            b = r;
         }
         r += 1;
         g += 1;
         b += 1;
         concat([r,0,0,0,128 * (1 - r),0,g,0,0,128 * (1 - g),0,0,b,0,128 * (1 - b),0,0,0,1,0]);
      }
      
      public function adjustBrightness(r:Number, g:Number = NaN, b:Number = NaN) : void
      {
         if(isNaN(g))
         {
            g = r;
         }
         if(isNaN(b))
         {
            b = r;
         }
         concat([1,0,0,0,r,0,1,0,0,g,0,0,1,0,b,0,0,0,1,0]);
      }
      
      public function adjustHue(degrees:Number) : void
      {
         degrees *= 0.017453292519943295;
         var _loc2_:Number = Math.cos(degrees);
         var _loc3_:Number = Math.sin(degrees);
         concat([0.212671 + _loc2_ * (1 - 0.212671) + _loc3_ * -0.212671,0.71516 + _loc2_ * -0.71516 + _loc3_ * -0.71516,0.072169 + _loc2_ * -0.072169 + _loc3_ * (1 - 0.072169),0,0,0.212671 + _loc2_ * -0.212671 + _loc3_ * 0.143,0.71516 + _loc2_ * (1 - 0.71516) + _loc3_ * 0.14,0.072169 + _loc2_ * -0.072169 + _loc3_ * -0.283,0,0,0.212671 + _loc2_ * -0.212671 + _loc3_ * -0.787329,0.71516 + _loc2_ * -0.71516 + _loc3_ * 0.71516,0.072169 + _loc2_ * (1 - 0.072169) + _loc3_ * 0.072169,0,0,0,0,0,1,0]);
      }
      
      public function rotateHue(degrees:Number) : void
      {
         initHue();
         concat(preHue.matrix);
         rotateBlue(degrees);
         concat(postHue.matrix);
      }
      
      public function luminance2Alpha() : void
      {
         concat([0,0,0,0,255,0,0,0,0,255,0,0,0,0,255,0.212671,0.71516,0.072169,0,0]);
      }
      
      public function adjustAlphaContrast(amount:Number) : void
      {
         amount += 1;
         concat([1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,amount,128 * (1 - amount)]);
      }
      
      public function colorize(rgb:int, amount:Number = 1) : void
      {
         var _loc3_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc6_:Number = NaN;
         _loc3_ = (rgb >> 16 & 0xFF) / 255;
         _loc5_ = (rgb >> 8 & 0xFF) / 255;
         _loc4_ = (rgb & 0xFF) / 255;
         _loc6_ = 1 - amount;
         concat([_loc6_ + amount * _loc3_ * 0.212671,amount * _loc3_ * 0.71516,amount * _loc3_ * 0.072169,0,0,amount * _loc5_ * 0.212671,_loc6_ + amount * _loc5_ * 0.71516,amount * _loc5_ * 0.072169,0,0,amount * _loc4_ * 0.212671,amount * _loc4_ * 0.71516,_loc6_ + amount * _loc4_ * 0.072169,0,0,0,0,0,1,0]);
      }
      
      public function setChannels(r:int = 1, g:int = 2, b:int = 4, a:int = 8) : void
      {
         var _loc5_:Number = (((r & 1) == 1 ? 1 : (0 + ((r & 2) == 2) ? 1 : 0)) + ((r & 4) == 4) ? 1 : 0) + ((r & 8) == 8) ? 1 : 0;
         if(_loc5_ > 0)
         {
            _loc5_ = 1 / _loc5_;
         }
         var _loc8_:Number = (((g & 1) == 1 ? 1 : (0 + ((g & 2) == 2) ? 1 : 0)) + ((g & 4) == 4) ? 1 : 0) + ((g & 8) == 8) ? 1 : 0;
         if(_loc8_ > 0)
         {
            _loc8_ = 1 / _loc8_;
         }
         var _loc6_:Number = (((b & 1) == 1 ? 1 : (0 + ((b & 2) == 2) ? 1 : 0)) + ((b & 4) == 4) ? 1 : 0) + ((b & 8) == 8) ? 1 : 0;
         if(_loc6_ > 0)
         {
            _loc6_ = 1 / _loc6_;
         }
         var _loc7_:Number = (((a & 1) == 1 ? 1 : (0 + ((a & 2) == 2) ? 1 : 0)) + ((a & 4) == 4) ? 1 : 0) + ((a & 8) == 8) ? 1 : 0;
         if(_loc7_ > 0)
         {
            _loc7_ = 1 / _loc7_;
         }
         concat([(r & 1) == 1 ? _loc5_ : 0,(r & 2) == 2 ? _loc5_ : 0,(r & 4) == 4 ? _loc5_ : 0,(r & 8) == 8 ? _loc5_ : 0,0,(g & 1) == 1 ? _loc8_ : 0,(g & 2) == 2 ? _loc8_ : 0,(g & 4) == 4 ? _loc8_ : 0,(g & 8) == 8 ? _loc8_ : 0,0,(b & 1) == 1 ? _loc6_ : 0,(b & 2) == 2 ? _loc6_ : 0,(b & 4) == 4 ? _loc6_ : 0,(b & 8) == 8 ? _loc6_ : 0,0,(a & 1) == 1 ? _loc7_ : 0,(a & 2) == 2 ? _loc7_ : 0,(a & 4) == 4 ? _loc7_ : 0,(a & 8) == 8 ? _loc7_ : 0,0]);
      }
      
      public function blend(mat:ColorMatrix, amount:Number) : void
      {
         var _loc4_:Number = 1 - amount;
         var _loc3_:int = 0;
         while(_loc3_ < 20)
         {
            matrix[_loc3_] = _loc4_ * Number(matrix[_loc3_]) + amount * Number(mat.matrix[_loc3_]);
            _loc3_++;
         }
      }
      
      public function average(r:Number = 0.3333333333333333, g:Number = 0.3333333333333333, b:Number = 0.3333333333333333) : void
      {
         concat([r,g,b,0,0,r,g,b,0,0,r,g,b,0,0,0,0,0,1,0]);
      }
      
      public function threshold(threshold:Number, factor:Number = 256) : void
      {
         concat([0.212671 * factor,0.71516 * factor,0.072169 * factor,0,-factor * threshold,0.212671 * factor,0.71516 * factor,0.072169 * factor,0,-factor * threshold,0.212671 * factor,0.71516 * factor,0.072169 * factor,0,-factor * threshold,0,0,0,1,0]);
      }
      
      public function desaturate() : void
      {
         concat([0.212671,0.71516,0.072169,0,0,0.212671,0.71516,0.072169,0,0,0.212671,0.71516,0.072169,0,0,0,0,0,1,0]);
      }
      
      public function randomize(amount:Number = 1) : void
      {
         var _loc13_:Number = 1 - amount;
         var _loc14_:Number = _loc13_ + amount * (Math.random() - Math.random());
         var _loc7_:Number = amount * (Math.random() - Math.random());
         var _loc10_:Number = amount * (Math.random() - Math.random());
         var _loc4_:Number = amount * 255 * (Math.random() - Math.random());
         var _loc2_:Number = amount * (Math.random() - Math.random());
         var _loc8_:Number = _loc13_ + amount * (Math.random() - Math.random());
         var _loc11_:Number = amount * (Math.random() - Math.random());
         var _loc5_:Number = amount * 255 * (Math.random() - Math.random());
         var _loc3_:Number = amount * (Math.random() - Math.random());
         var _loc9_:Number = amount * (Math.random() - Math.random());
         var _loc12_:Number = _loc13_ + amount * (Math.random() - Math.random());
         var _loc6_:Number = amount * 255 * (Math.random() - Math.random());
         concat([_loc14_,_loc7_,_loc10_,0,_loc4_,_loc2_,_loc8_,_loc11_,0,_loc5_,_loc3_,_loc9_,_loc12_,0,_loc6_,0,0,0,1,0]);
      }
      
      public function setMultiplicators(red:Number = 1, green:Number = 1, blue:Number = 1, alpha:Number = 1) : void
      {
         var _loc5_:Array = new Array(red,0,0,0,0,0,green,0,0,0,0,0,blue,0,0,0,0,0,alpha,0);
         concat(_loc5_);
      }
      
      public function clearChannels(red:Boolean = false, green:Boolean = false, blue:Boolean = false, alpha:Boolean = false) : void
      {
         if(red)
         {
            matrix[0] = matrix[1] = matrix[2] = matrix[3] = matrix[4] = 0;
         }
         if(green)
         {
            matrix[5] = matrix[6] = matrix[7] = matrix[8] = matrix[9] = 0;
         }
         if(blue)
         {
            matrix[10] = matrix[11] = matrix[12] = matrix[13] = matrix[14] = 0;
         }
         if(alpha)
         {
            matrix[15] = matrix[16] = matrix[17] = matrix[18] = matrix[19] = 0;
         }
      }
      
      public function thresholdAlpha(threshold:Number, factor:Number = 256) : void
      {
         concat([1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,factor,-factor * threshold]);
      }
      
      public function averageRGB2Alpha() : void
      {
         concat([0,0,0,0,255,0,0,0,0,255,0,0,0,0,255,0.3333333333333333,0.3333333333333333,0.3333333333333333,0,0]);
      }
      
      public function invertAlpha() : void
      {
         concat([1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,-1,255]);
      }
      
      public function rgb2Alpha(r:Number, g:Number, b:Number) : void
      {
         concat([0,0,0,0,255,0,0,0,0,255,0,0,0,0,255,r,g,b,0,0]);
      }
      
      public function setAlpha(alpha:Number) : void
      {
         concat([1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,alpha,0]);
      }
      
      public function get filter() : ColorMatrixFilter
      {
         return new ColorMatrixFilter(matrix);
      }
      
      public function concat(mat:Array) : void
      {
         var _loc5_:int = 0;
         var _loc3_:int = 0;
         var _loc2_:Array = [];
         var _loc4_:int = 0;
         _loc5_ = 0;
         while(_loc5_ < 4)
         {
            _loc3_ = 0;
            while(_loc3_ < 5)
            {
               _loc2_[int(_loc4_ + _loc3_)] = Number(mat[_loc4_]) * Number(matrix[_loc3_]) + Number(mat[int(_loc4_ + 1)]) * Number(matrix[int(_loc3_ + 5)]) + Number(mat[int(_loc4_ + 2)]) * Number(matrix[int(_loc3_ + 10)]) + Number(mat[int(_loc4_ + 3)]) * Number(matrix[int(_loc3_ + 15)]) + (_loc3_ == 4 ? Number(mat[int(_loc4_ + 4)]) : 0);
               _loc3_++;
            }
            _loc4_ += 5;
            _loc5_++;
         }
         matrix = _loc2_;
      }
      
      public function rotateRed(degrees:Number) : void
      {
         rotateColor(degrees,2,1);
      }
      
      public function rotateGreen(degrees:Number) : void
      {
         rotateColor(degrees,0,2);
      }
      
      public function rotateBlue(degrees:Number) : void
      {
         rotateColor(degrees,1,0);
      }
      
      private function rotateColor(degrees:Number, x:int, y:int) : void
      {
         degrees *= 0.017453292519943295;
         var _loc4_:Array = IDENTITY.concat();
         _loc4_[x + x * 5] = _loc4_[y + y * 5] = Math.cos(degrees);
         _loc4_[y + x * 5] = Math.sin(degrees);
         _loc4_[x + y * 5] = -Math.sin(degrees);
         concat(_loc4_);
      }
      
      public function shearRed(green:Number, blue:Number) : void
      {
         shearColor(0,1,green,2,blue);
      }
      
      public function shearGreen(red:Number, blue:Number) : void
      {
         shearColor(1,0,red,2,blue);
      }
      
      public function shearBlue(red:Number, green:Number) : void
      {
         shearColor(2,0,red,1,green);
      }
      
      private function shearColor(x:int, y1:int, d1:Number, y2:int, d2:Number) : void
      {
         var _loc6_:Array = IDENTITY.concat();
         _loc6_[y1 + x * 5] = d1;
         _loc6_[y2 + x * 5] = d2;
         concat(_loc6_);
      }
      
      public function applyColorDeficiency(type:String) : void
      {
         switch(type)
         {
            case "Protanopia":
               concat([0.567,0.433,0,0,0,0.558,0.442,0,0,0,0,0.242,0.758,0,0,0,0,0,1,0]);
               break;
            case "Protanomaly":
               concat([0.817,0.183,0,0,0,0.333,0.667,0,0,0,0,0.125,0.875,0,0,0,0,0,1,0]);
               break;
            case "Deuteranopia":
               concat([0.625,0.375,0,0,0,0.7,0.3,0,0,0,0,0.3,0.7,0,0,0,0,0,1,0]);
               break;
            case "Deuteranomaly":
               concat([0.8,0.2,0,0,0,0.258,0.742,0,0,0,0,0.142,0.858,0,0,0,0,0,1,0]);
               break;
            case "Tritanopia":
               concat([0.95,0.05,0,0,0,0,0.433,0.567,0,0,0,0.475,0.525,0,0,0,0,0,1,0]);
               break;
            case "Tritanomaly":
               concat([0.967,0.033,0,0,0,0,0.733,0.267,0,0,0,0.183,0.817,0,0,0,0,0,1,0]);
               break;
            case "Achromatopsia":
               concat([0.299,0.587,0.114,0,0,0.299,0.587,0.114,0,0,0.299,0.587,0.114,0,0,0,0,0,1,0]);
               break;
            case "Achromatomaly":
               concat([0.618,0.32,0.062,0,0,0.163,0.775,0.062,0,0,0.163,0.32,0.516,0,0,0,0,0,1,0]);
         }
      }
      
      public function applyMatrix(rgba:uint) : uint
      {
         var _loc4_:Number = rgba >>> 24 & 0xFF;
         var _loc6_:Number = rgba >>> 16 & 0xFF;
         var _loc8_:Number = rgba >>> 8 & 0xFF;
         var _loc7_:Number = rgba & 0xFF;
         var _loc2_:int = 0.5 + _loc6_ * matrix[0] + _loc8_ * matrix[1] + _loc7_ * matrix[2] + _loc4_ * matrix[3] + matrix[4];
         var _loc9_:int = 0.5 + _loc6_ * matrix[5] + _loc8_ * matrix[6] + _loc7_ * matrix[7] + _loc4_ * matrix[8] + matrix[9];
         var _loc3_:int = 0.5 + _loc6_ * matrix[10] + _loc8_ * matrix[11] + _loc7_ * matrix[12] + _loc4_ * matrix[13] + matrix[14];
         var _loc5_:int = 0.5 + _loc6_ * matrix[15] + _loc8_ * matrix[16] + _loc7_ * matrix[17] + _loc4_ * matrix[18] + matrix[19];
         if(_loc5_ < 0)
         {
            _loc5_ = 0;
         }
         if(_loc5_ > 255)
         {
            _loc5_ = 255;
         }
         if(_loc2_ < 0)
         {
            _loc2_ = 0;
         }
         if(_loc2_ > 255)
         {
            _loc2_ = 255;
         }
         if(_loc9_ < 0)
         {
            _loc9_ = 0;
         }
         if(_loc9_ > 255)
         {
            _loc9_ = 255;
         }
         if(_loc3_ < 0)
         {
            _loc3_ = 0;
         }
         if(_loc3_ > 255)
         {
            _loc3_ = 255;
         }
         return _loc5_ << 24 | _loc2_ << 16 | _loc9_ << 8 | _loc3_;
      }
      
      public function transformVector(values:Array) : void
      {
         if(values.length != 4)
         {
            return;
         }
         var _loc3_:Number = values[0] * matrix[0] + values[1] * matrix[1] + values[2] * matrix[2] + values[3] * matrix[3] + matrix[4];
         var _loc5_:Number = values[0] * matrix[5] + values[1] * matrix[6] + values[2] * matrix[7] + values[3] * matrix[8] + matrix[9];
         var _loc4_:Number = values[0] * matrix[10] + values[1] * matrix[11] + values[2] * matrix[12] + values[3] * matrix[13] + matrix[14];
         var _loc2_:Number = values[0] * matrix[15] + values[1] * matrix[16] + values[2] * matrix[17] + values[3] * matrix[18] + matrix[19];
         values[0] = _loc3_;
         values[1] = _loc5_;
         values[2] = _loc4_;
         values[3] = _loc2_;
      }
      
      private function initHue() : void
      {
         var _loc4_:Array = null;
         var _loc1_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc2_:Number = 39.182655;
         if(!hueInitialized)
         {
            hueInitialized = true;
            preHue = new ColorMatrix();
            preHue.rotateRed(45);
            preHue.rotateGreen(-_loc2_);
            _loc4_ = [0.3086,0.6094,0.082,1];
            preHue.transformVector(_loc4_);
            _loc1_ = _loc4_[0] / _loc4_[2];
            _loc3_ = _loc4_[1] / _loc4_[2];
            preHue.shearBlue(_loc1_,_loc3_);
            postHue = new ColorMatrix();
            postHue.shearBlue(-_loc1_,-_loc3_);
            postHue.rotateGreen(_loc2_);
            postHue.rotateRed(-45);
         }
      }
   }
}

