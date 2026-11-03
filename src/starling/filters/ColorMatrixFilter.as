package starling.filters
{
   import starling.rendering.FilterEffect;
   import starling.utils.Color;
   
   public class ColorMatrixFilter extends FragmentFilter
   {
      
      private static const LUMA_R:Number = 0.299;
      
      private static const LUMA_G:Number = 0.587;
      
      private static const LUMA_B:Number = 0.114;
      
      private static var sMatrix:Vector.<Number> = new Vector.<Number>(0);
      
      public function ColorMatrixFilter(matrix:Vector.<Number> = null)
      {
         super();
         if(matrix)
         {
            colorEffect.matrix = matrix;
         }
      }
      
      override protected function createEffect() : FilterEffect
      {
         return new ColorMatrixEffect();
      }
      
      public function invert() : void
      {
         concatValues(-1,0,0,0,255,0,-1,0,0,255,0,0,-1,0,255,0,0,0,1,0);
      }
      
      public function adjustSaturation(sat:Number) : void
      {
         sat += 1;
         var _loc3_:Number = 1 - sat;
         var _loc4_:Number = _loc3_ * 0.299;
         var _loc2_:Number = _loc3_ * 0.587;
         var _loc5_:Number = _loc3_ * 0.114;
         concatValues(_loc4_ + sat,_loc2_,_loc5_,0,0,_loc4_,_loc2_ + sat,_loc5_,0,0,_loc4_,_loc2_,_loc5_ + sat,0,0,0,0,0,1,0);
      }
      
      public function adjustContrast(value:Number) : void
      {
         var _loc2_:Number = value + 1;
         var _loc3_:Number = 128 * (1 - _loc2_);
         concatValues(_loc2_,0,0,0,_loc3_,0,_loc2_,0,0,_loc3_,0,0,_loc2_,0,_loc3_,0,0,0,1,0);
      }
      
      public function adjustBrightness(value:Number) : void
      {
         value *= 255;
         concatValues(1,0,0,0,value,0,1,0,0,value,0,0,1,0,value,0,0,0,1,0);
      }
      
      public function adjustHue(value:Number) : void
      {
         value *= 3.141592653589793;
         var _loc2_:Number = Math.cos(value);
         var _loc3_:Number = Math.sin(value);
         concatValues(0.299 + _loc2_ * (1 - 0.299) + _loc3_ * -0.299,0.587 + _loc2_ * -0.587 + _loc3_ * -0.587,0.114 + _loc2_ * -0.114 + _loc3_ * (1 - 0.114),0,0,0.299 + _loc2_ * -0.299 + _loc3_ * 0.143,0.587 + _loc2_ * (1 - 0.587) + _loc3_ * 0.14,0.114 + _loc2_ * -0.114 + _loc3_ * -0.283,0,0,0.299 + _loc2_ * -0.299 + _loc3_ * -0.7010000000000001,0.587 + _loc2_ * -0.587 + _loc3_ * 0.587,0.114 + _loc2_ * (1 - 0.114) + _loc3_ * 0.114,0,0,0,0,0,1,0);
      }
      
      public function tint(color:uint, amount:Number = 1) : void
      {
         var _loc4_:Number = Color.getRed(color) / 255;
         var _loc6_:Number = Color.getGreen(color) / 255;
         var _loc5_:Number = Color.getBlue(color) / 255;
         var _loc3_:Number = 1 - amount;
         var _loc8_:Number = amount * _loc4_;
         var _loc7_:Number = amount * _loc6_;
         var _loc9_:Number = amount * _loc5_;
         concatValues(_loc3_ + _loc8_ * 0.299,_loc8_ * 0.587,_loc8_ * 0.114,0,0,_loc7_ * 0.299,_loc3_ + _loc7_ * 0.587,_loc7_ * 0.114,0,0,_loc9_ * 0.299,_loc9_ * 0.587,_loc3_ + _loc9_ * 0.114,0,0,0,0,0,1,0);
      }
      
      public function reset() : void
      {
         matrix = null;
      }
      
      public function concat(matrix:Vector.<Number>) : void
      {
         colorEffect.concat(matrix);
         setRequiresRedraw();
      }
      
      public function concatValues(m0:Number, m1:Number, m2:Number, m3:Number, m4:Number, m5:Number, m6:Number, m7:Number, m8:Number, m9:Number, m10:Number, m11:Number, m12:Number, m13:Number, m14:Number, m15:Number, m16:Number, m17:Number, m18:Number, m19:Number) : void
      {
         sMatrix.length = 0;
         sMatrix.push(m0,m1,m2,m3,m4,m5,m6,m7,m8,m9,m10,m11,m12,m13,m14,m15,m16,m17,m18,m19);
         concat(sMatrix);
      }
      
      public function get matrix() : Vector.<Number>
      {
         return colorEffect.matrix;
      }
      
      public function set matrix(value:Vector.<Number>) : void
      {
         colorEffect.matrix = value;
         setRequiresRedraw();
      }
      
      private function get colorEffect() : ColorMatrixEffect
      {
         return this.effect as ColorMatrixEffect;
      }
   }
}

import flash.display3D.Context3D;
import starling.rendering.FilterEffect;
import starling.rendering.Program;

class ColorMatrixEffect extends FilterEffect
{
   
   private static const MIN_COLOR:Vector.<Number> = new <Number>[0,0,0,0.0001];
   
   private static const IDENTITY:Array = [1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0];
   
   private static var sMatrix:Vector.<Number> = new Vector.<Number>(20,true);
   
   private var _userMatrix:Vector.<Number>;
   
   private var _shaderMatrix:Vector.<Number>;
   
   public function ColorMatrixEffect()
   {
      super();
      _userMatrix = new Vector.<Number>(0);
      _shaderMatrix = new Vector.<Number>(0);
      this.matrix = null;
   }
   
   override protected function createProgram() : Program
   {
      var _loc1_:String = "m44 op, va0, vc0 \nmov v0, va1";
      var _loc2_:String = [tex("ft0","v0",0,texture),"max ft0, ft0, fc5              ","div ft0.xyz, ft0.xyz, ft0.www  ","m44 ft0, ft0, fc0              ","add ft0, ft0, fc4              ","mul ft0.xyz, ft0.xyz, ft0.www  ","mov oc, ft0                    "].join("\n");
      return Program.fromSource(_loc1_,_loc2_);
   }
   
   override protected function beforeDraw(context:Context3D) : void
   {
      super.beforeDraw(context);
      context.setProgramConstantsFromVector("fragment",0,_shaderMatrix);
      context.setProgramConstantsFromVector("fragment",5,MIN_COLOR);
   }
   
   public function reset() : void
   {
      matrix = null;
   }
   
   public function concat(matrix:Vector.<Number>) : void
   {
      var _loc4_:int = 0;
      var _loc2_:int = 0;
      var _loc3_:int = 0;
      _loc4_ = 0;
      while(_loc4_ < 4)
      {
         _loc2_ = 0;
         while(_loc2_ < 5)
         {
            sMatrix[_loc3_ + _loc2_] = matrix[_loc3_] * _userMatrix[_loc2_] + matrix[_loc3_ + 1] * _userMatrix[_loc2_ + 5] + matrix[_loc3_ + 2] * _userMatrix[_loc2_ + 10] + matrix[_loc3_ + 3] * _userMatrix[_loc2_ + 15] + (_loc2_ == 4 ? matrix[_loc3_ + 4] : 0);
            _loc2_++;
         }
         _loc3_ += 5;
         _loc4_++;
      }
      copyMatrix(sMatrix,_userMatrix);
      updateShaderMatrix();
   }
   
   private function copyMatrix(from:Vector.<Number>, to:Vector.<Number>) : void
   {
      var _loc3_:int = 0;
      _loc3_ = 0;
      while(_loc3_ < 20)
      {
         to[_loc3_] = from[_loc3_];
         _loc3_++;
      }
   }
   
   private function updateShaderMatrix() : void
   {
      _shaderMatrix.length = 0;
      _shaderMatrix.push(_userMatrix[0],_userMatrix[1],_userMatrix[2],_userMatrix[3],_userMatrix[5],_userMatrix[6],_userMatrix[7],_userMatrix[8],_userMatrix[10],_userMatrix[11],_userMatrix[12],_userMatrix[13],_userMatrix[15],_userMatrix[16],_userMatrix[17],_userMatrix[18],_userMatrix[4] / 255,_userMatrix[9] / 255,_userMatrix[14] / 255,_userMatrix[19] / 255);
   }
   
   public function get matrix() : Vector.<Number>
   {
      return _userMatrix;
   }
   
   public function set matrix(value:Vector.<Number>) : void
   {
      if(value && value.length != 20)
      {
         throw new ArgumentError("Invalid matrix length: must be 20");
      }
      if(value == null)
      {
         _userMatrix.length = 0;
         _userMatrix.push.apply(_userMatrix,IDENTITY);
      }
      else
      {
         copyMatrix(value,_userMatrix);
      }
      updateShaderMatrix();
   }
}
