package starling.extensions.animate.styles
{
   import starling.display.DisplayObject;
   import starling.display.DisplayObjectContainer;
   import starling.display.Mesh;
   import starling.extensions.animate.Animation;
   import starling.rendering.MeshEffect;
   import starling.rendering.VertexDataFormat;
   import starling.styles.MeshStyle;
   import starling.utils.Color;
   
   public class ColorTransformStyle extends MeshStyle
   {
      
      private static const LUMA_R:Number = 0.299;
      
      private static const LUMA_G:Number = 0.587;
      
      private static const LUMA_B:Number = 0.114;
      
      public static const VERTEX_FORMAT:VertexDataFormat = MeshStyle.VERTEX_FORMAT.extend("colorMul0:float4, colorMul1:float4, colorMul2:float4, colorMul3:float4, colorOffset:float4");
      
      private var _matrix:Vector.<Number>;
      
      protected var maskDiscard:Boolean;
      
      public function ColorTransformStyle(matrix:Vector.<Number> = null)
      {
         super();
         _matrix = new Vector.<Number>(20,true);
         writeMatrix(matrix,_matrix);
      }
      
      public static function setColorTransform(mesh:Mesh, matrix:Vector.<Number>) : void
      {
         var _loc3_:Boolean = false;
         if(mesh == null)
         {
            return;
         }
         var _loc4_:ColorTransformStyle = mesh.style as ColorTransformStyle;
         if(isIdentity(matrix))
         {
            if(_loc4_ != null)
            {
               if(_loc4_ is MaskColorTransformStyle)
               {
                  mesh.style = new MaskStyle();
               }
               else
               {
                  mesh.setStyle();
               }
            }
         }
         else
         {
            if(_loc4_ == null)
            {
               _loc3_ = mesh.style is MaskStyle;
               if(!_loc3_ && mesh.style != null && mesh.style.type != MeshStyle)
               {
                  return;
               }
               _loc4_ = _loc3_ ? new MaskColorTransformStyle() : new ColorTransformStyle();
               mesh.style = _loc4_;
            }
            _loc4_.colorMatrix = matrix;
         }
      }
      
      public static function applyTo(target:DisplayObject, matrix:Vector.<Number>) : void
      {
         var _loc3_:DisplayObjectContainer = null;
         var _loc4_:int = 0;
         if(target is Animation)
         {
            (target as Animation).setColorMatrix(matrix);
         }
         else if(target is Mesh)
         {
            setColorTransform(target as Mesh,matrix);
         }
         else if(target is DisplayObjectContainer)
         {
            _loc3_ = target as DisplayObjectContainer;
            _loc4_ = 0;
            while(_loc4_ < _loc3_.numChildren)
            {
               applyTo(_loc3_.getChildAt(_loc4_),matrix);
               _loc4_++;
            }
         }
      }
      
      public static function isIdentity(matrix:Vector.<Number>) : Boolean
      {
         var _loc2_:int = 0;
         if(matrix == null)
         {
            return true;
         }
         if(matrix.length != 20)
         {
            return false;
         }
         _loc2_ = 0;
         while(_loc2_ < 20)
         {
            if(matrix[_loc2_] != (_loc2_ % 6 == 0 ? 1 : 0))
            {
               return false;
            }
            _loc2_++;
         }
         return true;
      }
      
      public static function matricesEqual(a:Vector.<Number>, b:Vector.<Number>) : Boolean
      {
         var _loc3_:int = 0;
         if(a === b)
         {
            return true;
         }
         if(a == null)
         {
            return isIdentity(b);
         }
         if(b == null)
         {
            return isIdentity(a);
         }
         if(a.length != 20 || b.length != 20)
         {
            return false;
         }
         _loc3_ = 0;
         while(_loc3_ < 20)
         {
            if(a[_loc3_] != b[_loc3_])
            {
               return false;
            }
            _loc3_++;
         }
         return true;
      }
      
      public static function copyMatrix(from:Vector.<Number>, out:Vector.<Number> = null) : Vector.<Number>
      {
         if(out == null)
         {
            out = new Vector.<Number>(20,true);
         }
         writeMatrix(from,out);
         return out;
      }
      
      public static function concat(first:Vector.<Number>, second:Vector.<Number>, out:Vector.<Number> = null) : Vector.<Number>
      {
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         if(out == null)
         {
            out = new Vector.<Number>(20,true);
         }
         if(first == null)
         {
            writeMatrix(second,out);
            return out;
         }
         if(second == null)
         {
            writeMatrix(first,out);
            return out;
         }
         _loc5_ = 0;
         while(_loc5_ < 20)
         {
            _loc4_ = 0;
            while(_loc4_ < 5)
            {
               out[_loc5_ + _loc4_] = second[_loc5_] * first[_loc4_] + second[_loc5_ + 1] * first[_loc4_ + 5] + second[_loc5_ + 2] * first[_loc4_ + 10] + second[_loc5_ + 3] * first[_loc4_ + 15] + (_loc4_ == 4 ? second[_loc5_ + 4] : 0);
               _loc4_++;
            }
            _loc5_ += 5;
         }
         return out;
      }
      
      public static function tintMatrix(color:uint, amount:Number, out:Vector.<Number> = null) : Vector.<Number>
      {
         out = copyMatrix(null,out);
         var _loc5_:Number = Color.getRed(color) / 255;
         var _loc7_:Number = Color.getGreen(color) / 255;
         var _loc6_:Number = Color.getBlue(color) / 255;
         var _loc4_:Number = 1 - amount;
         var _loc9_:Number = amount * _loc5_;
         var _loc8_:Number = amount * _loc7_;
         var _loc10_:Number = amount * _loc6_;
         out[0] = _loc4_ + _loc9_ * 0.299;
         out[1] = _loc9_ * 0.587;
         out[2] = _loc9_ * 0.114;
         out[5] = _loc8_ * 0.299;
         out[6] = _loc4_ + _loc8_ * 0.587;
         out[7] = _loc8_ * 0.114;
         out[10] = _loc10_ * 0.299;
         out[11] = _loc10_ * 0.587;
         out[12] = _loc4_ + _loc10_ * 0.114;
         return out;
      }
      
      public static function animateTintMatrix(color:uint, amount:Number, out:Vector.<Number> = null) : Vector.<Number>
      {
         out = copyMatrix(null,out);
         var _loc4_:Number = 1 - amount;
         out[0] = out[6] = out[12] = _loc4_;
         out[4] = Math.round(Color.getRed(color) * amount);
         out[9] = Math.round(Color.getGreen(color) * amount);
         out[14] = Math.round(Color.getBlue(color) * amount);
         return out;
      }
      
      public static function animateBrightnessMatrix(brightness:Number, out:Vector.<Number> = null) : Vector.<Number>
      {
         out = copyMatrix(null,out);
         if(brightness > 1)
         {
            brightness = 1;
         }
         else if(brightness < -1)
         {
            brightness = -1;
         }
         var _loc3_:Number = brightness > 0 ? brightness * 255 : 0;
         out[0] = out[6] = out[12] = 1 - Math.abs(brightness);
         out[4] = out[9] = out[14] = _loc3_;
         return out;
      }
      
      private static function writeMatrix(from:Vector.<Number>, to:Vector.<Number>) : void
      {
         var _loc3_:int = 0;
         if(from == null)
         {
            _loc3_ = 0;
            while(_loc3_ < 20)
            {
               to[_loc3_] = _loc3_ % 6 == 0 ? 1 : 0;
               _loc3_++;
            }
         }
         else
         {
            _loc3_ = 0;
            while(_loc3_ < 20)
            {
               to[_loc3_] = from[_loc3_];
               _loc3_++;
            }
         }
      }
      
      override public function copyFrom(meshStyle:MeshStyle) : void
      {
         var _loc2_:ColorTransformStyle = meshStyle as ColorTransformStyle;
         if(_loc2_)
         {
            writeMatrix(_loc2_._matrix,_matrix);
         }
         super.copyFrom(meshStyle);
      }
      
      override public function createEffect() : MeshEffect
      {
         return new ColorTransformEffect(maskDiscard);
      }
      
      override public function get vertexFormat() : VertexDataFormat
      {
         return VERTEX_FORMAT;
      }
      
      override protected function onTargetAssigned(target:Mesh) : void
      {
         updateVertices();
      }
      
      private function updateVertices() : void
      {
         var _loc2_:int = 0;
         if(vertexData == null)
         {
            return;
         }
         var _loc3_:Vector.<Number> = _matrix;
         var _loc1_:int = vertexData.numVertices;
         _loc2_ = 0;
         while(_loc2_ < _loc1_)
         {
            vertexData.setPoint4D(_loc2_,"colorMul0",_loc3_[0],_loc3_[1],_loc3_[2],_loc3_[3]);
            vertexData.setPoint4D(_loc2_,"colorMul1",_loc3_[5],_loc3_[6],_loc3_[7],_loc3_[8]);
            vertexData.setPoint4D(_loc2_,"colorMul2",_loc3_[10],_loc3_[11],_loc3_[12],_loc3_[13]);
            vertexData.setPoint4D(_loc2_,"colorMul3",_loc3_[15],_loc3_[16],_loc3_[17],_loc3_[18]);
            vertexData.setPoint4D(_loc2_,"colorOffset",_loc3_[4] / 255,_loc3_[9] / 255,_loc3_[14] / 255,_loc3_[19] / 255);
            _loc2_++;
         }
         setVertexDataChanged();
      }
      
      public function get colorMatrix() : Vector.<Number>
      {
         return _matrix;
      }
      
      public function set colorMatrix(value:Vector.<Number>) : void
      {
         if(matricesEqual(value,_matrix))
         {
            return;
         }
         writeMatrix(value,_matrix);
         updateVertices();
      }
   }
}

import flash.display3D.Context3D;
import starling.extensions.animate.styles.ColorTransformStyle;
import starling.rendering.MeshEffect;
import starling.rendering.Program;
import starling.rendering.VertexDataFormat;

class ColorTransformEffect extends MeshEffect
{
   
   public static const VERTEX_FORMAT:VertexDataFormat = ColorTransformStyle.VERTEX_FORMAT;
   
   private static const MIN_COLOR:Vector.<Number> = new <Number>[0,0,0,0.0001];
   
   private static const MASK_THRESHOLD:Vector.<Number> = new <Number>[0.5,0.5,0.5,0.5];
   
   private var _maskDiscard:Boolean;
   
   public function ColorTransformEffect(maskDiscard:Boolean = false)
   {
      super();
      _maskDiscard = maskDiscard;
   }
   
   override protected function get programVariantName() : uint
   {
      return super.programVariantName | (uint(texture == null)) << 4 | uint(_maskDiscard) << 5;
   }
   
   override protected function createProgram() : Program
   {
      var _loc3_:String = null;
      var _loc1_:Array = null;
      var _loc2_:String = ["m44 op, va0, vc0","mul v1, va2, vc4","mov v2, va3","mov v3, va4","mov v4, va5","mov v5, va6","mov v6, va7"].join("\n");
      if(texture)
      {
         _loc2_ = "mov v0, va1\n" + _loc2_;
         _loc1_ = [tex("ft0","v0",0,texture)];
         if(_maskDiscard)
         {
            _loc1_.push("sub ft1, ft0.wwww, fc1","kil ft1.x");
         }
         _loc1_.push("mul ft0, ft0, v1               ","max ft0, ft0, fc0              ","div ft0.xyz, ft0.xyz, ft0.www  ","m44 ft0, ft0, v2               ","add ft0, ft0, v6               ","sat ft0, ft0                   ","mul ft0.xyz, ft0.xyz, ft0.www  ","mov oc, ft0                    ");
         _loc3_ = _loc1_.join("\n");
      }
      else
      {
         _loc3_ = ["max ft0, v1, fc0               ","div ft0.xyz, ft0.xyz, ft0.www  ","m44 ft0, ft0, v2               ","add ft0, ft0, v6               ","sat ft0, ft0                   ","mul ft0.xyz, ft0.xyz, ft0.www  ","mov oc, ft0                    "].join("\n");
      }
      return Program.fromSource(_loc2_,_loc3_);
   }
   
   override protected function beforeDraw(context:Context3D) : void
   {
      super.beforeDraw(context);
      vertexFormat.setVertexBufferAt(3,vertexBuffer,"colorMul0");
      vertexFormat.setVertexBufferAt(4,vertexBuffer,"colorMul1");
      vertexFormat.setVertexBufferAt(5,vertexBuffer,"colorMul2");
      vertexFormat.setVertexBufferAt(6,vertexBuffer,"colorMul3");
      vertexFormat.setVertexBufferAt(7,vertexBuffer,"colorOffset");
      context.setProgramConstantsFromVector("fragment",0,MIN_COLOR);
      if(_maskDiscard)
      {
         context.setProgramConstantsFromVector("fragment",1,MASK_THRESHOLD);
      }
   }
   
   override protected function afterDraw(context:Context3D) : void
   {
      context.setVertexBufferAt(3,null);
      context.setVertexBufferAt(4,null);
      context.setVertexBufferAt(5,null);
      context.setVertexBufferAt(6,null);
      context.setVertexBufferAt(7,null);
      super.afterDraw(context);
   }
   
   override public function get vertexFormat() : VertexDataFormat
   {
      return VERTEX_FORMAT;
   }
}
