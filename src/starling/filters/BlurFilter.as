package starling.filters
{
   import starling.core.Starling;
   import starling.rendering.FilterEffect;
   import starling.rendering.Painter;
   import starling.textures.Texture;
   import starling.utils.MathUtil;
   
   public class BlurFilter extends FragmentFilter
   {
      
      private var _blurX:Number;
      
      private var _blurY:Number;
      
      private var _quality:Number;
      
      public function BlurFilter(blurX:Number = 1, blurY:Number = 1, resolution:Number = 1)
      {
         super();
         _blurX = Math.abs(blurX);
         _blurY = Math.abs(blurY);
         _quality = 1;
         this.resolution = resolution;
         this.maintainResolutionAcrossPasses = true;
      }
      
      private static function getNumPasses(blur:Number) : int
      {
         var _loc2_:int = 1;
         while(blur > 1)
         {
            _loc2_ += 1;
            blur /= 2;
         }
         return _loc2_;
      }
      
      override public function process(painter:Painter, helper:IFilterHelper, input0:Texture = null, input1:Texture = null, input2:Texture = null, input3:Texture = null) : Texture
      {
         var _loc11_:Texture = null;
         var _loc9_:BlurEffect = this.effect as BlurEffect;
         if(_blurX == 0 && _blurY == 0)
         {
            _loc9_.strength = 0;
            return super.process(painter,helper,input0);
         }
         var _loc7_:Texture = input0;
         var _loc8_:Number = totalBlurX;
         var _loc10_:Number = totalBlurY;
         _loc9_.quality = _quality;
         _loc9_.direction = "horizontal";
         while(_loc8_ > 0)
         {
            _loc9_.strength = _loc8_;
            _loc11_ = _loc7_;
            _loc7_ = super.process(painter,helper,_loc11_);
            if(_loc11_ != input0)
            {
               helper.putTexture(_loc11_);
            }
            if(_loc8_ <= 1)
            {
               break;
            }
            _loc8_ /= 2;
         }
         _loc9_.direction = "vertical";
         while(_loc10_ > 0)
         {
            _loc9_.strength = _loc10_;
            _loc11_ = _loc7_;
            _loc7_ = super.process(painter,helper,_loc11_);
            if(_loc11_ != input0)
            {
               helper.putTexture(_loc11_);
            }
            if(_loc10_ <= 1)
            {
               break;
            }
            _loc10_ /= 2;
         }
         return _loc7_;
      }
      
      override protected function createEffect() : FilterEffect
      {
         return new BlurEffect();
      }
      
      override public function set resolution(value:Number) : void
      {
         super.resolution = value;
         updatePadding();
      }
      
      private function updatePadding() : void
      {
         var _loc1_:Number = _blurX ? (totalBlurX * 3 + 2) / (resolution * _quality) : 0;
         var _loc2_:Number = _blurY ? (totalBlurY * 3 + 2) / (resolution * _quality) : 0;
         padding.setTo(_loc1_,_loc1_,_loc2_,_loc2_);
      }
      
      override public function get numPasses() : int
      {
         if(_blurX == 0 && _blurY == 0)
         {
            return 1;
         }
         return getNumPasses(totalBlurX) + getNumPasses(totalBlurY);
      }
      
      private function get totalBlurX() : Number
      {
         return _blurX * Starling.contentScaleFactor;
      }
      
      private function get totalBlurY() : Number
      {
         return _blurY * Starling.contentScaleFactor;
      }
      
      public function get blurX() : Number
      {
         return _blurX;
      }
      
      public function set blurX(value:Number) : void
      {
         if(_blurX != value)
         {
            _blurX = Math.abs(value);
            updatePadding();
         }
      }
      
      public function get blurY() : Number
      {
         return _blurY;
      }
      
      public function set blurY(value:Number) : void
      {
         if(_blurY != value)
         {
            _blurY = Math.abs(value);
            updatePadding();
         }
      }
      
      public function get quality() : Number
      {
         return _quality;
      }
      
      public function set quality(value:Number) : void
      {
         if(_quality != value)
         {
            _quality = MathUtil.clamp(value,0.1,1);
            updatePadding();
         }
      }
   }
}

import flash.display3D.Context3D;
import starling.rendering.FilterEffect;
import starling.rendering.Program;

class BlurEffect extends FilterEffect
{
   
   public static const HORIZONTAL:String = "horizontal";
   
   public static const VERTICAL:String = "vertical";
   
   private static const sTmpWeights:Vector.<Number> = new <Number>[0,0,0,0,0];
   
   private static const sWeights:Vector.<Number> = new <Number>[0,0,0,0];
   
   private static const sOffsets:Vector.<Number> = new <Number>[0,0,0,0];
   
   private var _strength:Number;
   
   private var _direction:String;
   
   private var _quality:Number;
   
   public function BlurEffect()
   {
      super();
      _strength = 0;
      _direction = "horizontal";
      _quality = 1;
   }
   
   override protected function createProgram() : Program
   {
      if(_strength == 0)
      {
         return super.createProgram();
      }
      var _loc1_:String = ["m44 op, va0, vc0      ","mov v0, va1           ","add v1,  va1, vc4.xyww","sub v2,  va1, vc4.xyww","add v3,  va1, vc4.zwxx","sub v4,  va1, vc4.zwxx"].join("\n");
      var _loc2_:String = [tex("ft0","v0",0,texture),"mul ft5, ft0, fc0.xxxx       ",tex("ft1","v1",0,texture),"mul ft1, ft1, fc0.yyyy       ","add ft5, ft5, ft1            ",tex("ft2","v2",0,texture),"mul ft2, ft2, fc0.yyyy       ","add ft5, ft5, ft2            ",tex("ft3","v3",0,texture),"mul ft3, ft3, fc0.zzzz       ","add ft5, ft5, ft3            ",tex("ft4","v4",0,texture),"mul ft4, ft4, fc0.zzzz       ","add  oc, ft5, ft4            "].join("\n");
      return Program.fromSource(_loc1_,_loc2_);
   }
   
   override protected function beforeDraw(context:Context3D) : void
   {
      super.beforeDraw(context);
      if(_strength)
      {
         updateParameters();
         context.setProgramConstantsFromVector("vertex",4,sOffsets);
         context.setProgramConstantsFromVector("fragment",0,sWeights);
      }
   }
   
   private function updateParameters() : void
   {
      var _loc6_:Number = NaN;
      var _loc7_:Number = NaN;
      var _loc1_:Number = NaN;
      var _loc9_:Number = NaN;
      var _loc3_:Number = NaN;
      var _loc5_:int = 0;
      var _loc2_:Number = NaN;
      var _loc4_:Number = NaN;
      var _loc8_:Number = 1 / (_direction == "horizontal" ? texture.root.nativeWidth : Number(texture.root.nativeHeight));
      if(_strength <= 1)
      {
         _loc1_ = _strength * 2;
         _loc9_ = 2 * _loc1_ * _loc1_;
         _loc3_ = 1 / Math.sqrt(_loc9_ * 3.141592653589793);
         _loc5_ = 0;
         while(_loc5_ < 5)
         {
            sTmpWeights[_loc5_] = _loc3_ * Math.exp(-_loc5_ * _loc5_ / _loc9_);
            _loc5_++;
         }
         sWeights[0] = sTmpWeights[0];
         sWeights[1] = sTmpWeights[1] + sTmpWeights[2];
         sWeights[2] = sTmpWeights[3] + sTmpWeights[4];
         _loc2_ = sWeights[0] + 2 * sWeights[1] + 2 * sWeights[2];
         _loc4_ = 1 / _loc2_;
         sWeights[0] *= _loc4_;
         sWeights[1] *= _loc4_;
         sWeights[2] *= _loc4_;
         _loc7_ = (sTmpWeights[1] + 2 * sTmpWeights[2]) / sWeights[1];
         _loc6_ = (3 * sTmpWeights[3] + 4 * sTmpWeights[4]) / sWeights[2];
      }
      else
      {
         sWeights[0] = 0.29412;
         sWeights[1] = 0.23529;
         sWeights[2] = 0.11765;
         _loc7_ = _strength * 1.3;
         _loc6_ = _strength * 2.3;
      }
      if(_direction == "horizontal")
      {
         sOffsets[0] = _loc7_ * _loc8_ / _quality;
         sOffsets[1] = 0;
         sOffsets[2] = _loc6_ * _loc8_ / _quality;
         sOffsets[3] = 0;
      }
      else
      {
         sOffsets[0] = 0;
         sOffsets[1] = _loc7_ * _loc8_ / _quality;
         sOffsets[2] = 0;
         sOffsets[3] = _loc6_ * _loc8_ / _quality;
      }
   }
   
   override protected function get programVariantName() : uint
   {
      return super.programVariantName | (_strength ? 16 : 0);
   }
   
   public function get direction() : String
   {
      return _direction;
   }
   
   public function set direction(value:String) : void
   {
      _direction = value;
   }
   
   public function get strength() : Number
   {
      return _strength;
   }
   
   public function set strength(value:Number) : void
   {
      _strength = value;
   }
   
   public function get quality() : Number
   {
      return _quality;
   }
   
   public function set quality(value:Number) : void
   {
      _quality = value;
   }
}
