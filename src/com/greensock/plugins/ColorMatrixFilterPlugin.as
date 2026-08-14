package com.greensock.plugins
{
   import com.greensock.*;
   import flash.filters.ColorMatrixFilter;
   
   public class ColorMatrixFilterPlugin extends FilterPlugin
   {
      
      public static const API:Number = 1;
      
      private static var _propNames:Array = [];
      
      protected static var _idMatrix:Array = [1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0];
      
      protected static var _lumR:Number = 0.212671;
      
      protected static var _lumG:Number = 0.71516;
      
      protected static var _lumB:Number = 0.072169;
      
      protected var _matrix:Array;
      
      protected var _matrixTween:EndArrayPlugin;
      
      public function ColorMatrixFilterPlugin()
      {
         super();
         this.propName = "colorMatrixFilter";
         this.overwriteProps = ["colorMatrixFilter"];
      }
      
      public static function setSaturation(m:Array, n:Number) : Array
      {
         if(isNaN(n))
         {
            return m;
         }
         var _loc3_:Number = 1 - n;
         var _loc4_:Number = _loc3_ * _lumR;
         var _loc5_:Number = _loc3_ * _lumG;
         var _loc6_:Number = _loc3_ * _lumB;
         var _loc7_:Array = [_loc4_ + n,_loc5_,_loc6_,0,0,_loc4_,_loc5_ + n,_loc6_,0,0,_loc4_,_loc5_,_loc6_ + n,0,0,0,0,0,1,0];
         return applyMatrix(_loc7_,m);
      }
      
      public static function setHue(m:Array, n:Number) : Array
      {
         if(isNaN(n))
         {
            return m;
         }
         n *= Math.PI / 180;
         var _loc3_:Number = Math.cos(n);
         var _loc4_:Number = Math.sin(n);
         var _loc5_:Array = [_lumR + _loc3_ * (1 - _lumR) + _loc4_ * -_lumR,_lumG + _loc3_ * -_lumG + _loc4_ * -_lumG,_lumB + _loc3_ * -_lumB + _loc4_ * (1 - _lumB),0,0,_lumR + _loc3_ * -_lumR + _loc4_ * 0.143,_lumG + _loc3_ * (1 - _lumG) + _loc4_ * 0.14,_lumB + _loc3_ * -_lumB + _loc4_ * -0.283,0,0,_lumR + _loc3_ * -_lumR + _loc4_ * -(1 - _lumR),_lumG + _loc3_ * -_lumG + _loc4_ * _lumG,_lumB + _loc3_ * (1 - _lumB) + _loc4_ * _lumB,0,0,0,0,0,1,0,0,0,0,0,1];
         return applyMatrix(_loc5_,m);
      }
      
      public static function setContrast(m:Array, n:Number) : Array
      {
         if(isNaN(n))
         {
            return m;
         }
         n += 0.01;
         var _loc3_:Array = [n,0,0,0,128 * (1 - n),0,n,0,0,128 * (1 - n),0,0,n,0,128 * (1 - n),0,0,0,1,0];
         return applyMatrix(_loc3_,m);
      }
      
      public static function applyMatrix(m:Array, m2:Array) : Array
      {
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         if(!(m is Array) || !(m2 is Array))
         {
            return m2;
         }
         var _loc3_:Array = [];
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         _loc6_ = 0;
         while(_loc6_ < 4)
         {
            _loc7_ = 0;
            while(_loc7_ < 5)
            {
               if(_loc7_ == 4)
               {
                  _loc5_ = int(m[_loc4_ + 4]);
               }
               else
               {
                  _loc5_ = 0;
               }
               _loc3_[_loc4_ + _loc7_] = m[_loc4_] * m2[_loc7_] + m[_loc4_ + 1] * m2[_loc7_ + 5] + m[_loc4_ + 2] * m2[_loc7_ + 10] + m[_loc4_ + 3] * m2[_loc7_ + 15] + _loc5_;
               _loc7_ += 1;
            }
            _loc4_ += 5;
            _loc6_ += 1;
         }
         return _loc3_;
      }
      
      public static function setThreshold(m:Array, n:Number) : Array
      {
         if(isNaN(n))
         {
            return m;
         }
         var _loc3_:Array = [_lumR * 256,_lumG * 256,_lumB * 256,0,-256 * n,_lumR * 256,_lumG * 256,_lumB * 256,0,-256 * n,_lumR * 256,_lumG * 256,_lumB * 256,0,-256 * n,0,0,0,1,0];
         return applyMatrix(_loc3_,m);
      }
      
      public static function colorize(m:Array, color:Number, amount:Number = 1) : Array
      {
         if(isNaN(color))
         {
            return m;
         }
         if(isNaN(amount))
         {
            amount = 1;
         }
         var _loc4_:Number = (color >> 16 & 0xFF) / 255;
         var _loc5_:Number = (color >> 8 & 0xFF) / 255;
         var _loc6_:Number = (color & 0xFF) / 255;
         var _loc7_:Number = 1 - amount;
         var _loc8_:Array = [_loc7_ + amount * _loc4_ * _lumR,amount * _loc4_ * _lumG,amount * _loc4_ * _lumB,0,0,amount * _loc5_ * _lumR,_loc7_ + amount * _loc5_ * _lumG,amount * _loc5_ * _lumB,0,0,amount * _loc6_ * _lumR,amount * _loc6_ * _lumG,_loc7_ + amount * _loc6_ * _lumB,0,0,0,0,0,1,0];
         return applyMatrix(_loc8_,m);
      }
      
      public static function setBrightness(m:Array, n:Number) : Array
      {
         if(isNaN(n))
         {
            return m;
         }
         n = n * 100 - 100;
         return applyMatrix([1,0,0,0,n,0,1,0,0,n,0,0,1,0,n,0,0,0,1,0,0,0,0,0,1],m);
      }
      
      override public function onInitTween(target:Object, value:*, tween:TweenLite) : Boolean
      {
         _target = target;
         _type = ColorMatrixFilter;
         var _loc4_:Object = value;
         initFilter({
            "remove":value.remove,
            "index":value.index,
            "addFilter":value.addFilter
         },new ColorMatrixFilter(_idMatrix.slice()),_propNames);
         _matrix = ColorMatrixFilter(_filter).matrix;
         var _loc5_:Array = [];
         if(_loc4_.matrix != null && _loc4_.matrix is Array)
         {
            _loc5_ = _loc4_.matrix;
         }
         else
         {
            if(_loc4_.relative == true)
            {
               _loc5_ = _matrix.slice();
            }
            else
            {
               _loc5_ = _idMatrix.slice();
            }
            _loc5_ = setBrightness(_loc5_,_loc4_.brightness);
            _loc5_ = setContrast(_loc5_,_loc4_.contrast);
            _loc5_ = setHue(_loc5_,_loc4_.hue);
            _loc5_ = setSaturation(_loc5_,_loc4_.saturation);
            _loc5_ = setThreshold(_loc5_,_loc4_.threshold);
            if(!isNaN(_loc4_.colorize))
            {
               _loc5_ = colorize(_loc5_,_loc4_.colorize,_loc4_.amount);
            }
         }
         _matrixTween = new EndArrayPlugin();
         _matrixTween.init(_matrix,_loc5_);
         return true;
      }
      
      override public function set changeFactor(n:Number) : void
      {
         _matrixTween.changeFactor = n;
         ColorMatrixFilter(_filter).matrix = _matrix;
         super.changeFactor = n;
      }
   }
}

