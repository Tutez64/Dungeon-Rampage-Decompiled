package starling.styles
{
   import flash.geom.Matrix;
   import starling.core.Starling;
   import starling.display.Mesh;
   import starling.rendering.MeshEffect;
   import starling.rendering.RenderState;
   import starling.rendering.VertexData;
   import starling.rendering.VertexDataFormat;
   import starling.utils.Color;
   import starling.utils.MathUtil;
   
   public class DistanceFieldStyle extends MeshStyle
   {
      
      public static const MODE_BASIC:String = "basic";
      
      public static const MODE_OUTLINE:String = "outline";
      
      public static const MODE_GLOW:String = "glow";
      
      public static const MODE_SHADOW:String = "shadow";
      
      public static const VERTEX_FORMAT:VertexDataFormat = MeshStyle.VERTEX_FORMAT.extend("basic:bytes4, extended:bytes4, outerColor:bytes4");
      
      private var _mode:String;
      
      private var _multiChannel:Boolean;
      
      private var _threshold:Number;
      
      private var _alpha:Number;
      
      private var _softness:Number;
      
      private var _outerThreshold:Number;
      
      private var _outerAlphaEnd:Number;
      
      private var _shadowOffsetX:Number;
      
      private var _shadowOffsetY:Number;
      
      private var _outerColor:uint;
      
      private var _outerAlphaStart:Number;
      
      public function DistanceFieldStyle(softness:Number = 0.125, threshold:Number = 0.5)
      {
         super();
         _mode = "basic";
         _threshold = threshold;
         _softness = softness;
         _alpha = 1;
         _outerThreshold = _outerAlphaEnd = 0;
         _shadowOffsetX = _shadowOffsetY = 0;
         _outerColor = 0;
         _outerAlphaStart = 0;
      }
      
      override public function copyFrom(meshStyle:MeshStyle) : void
      {
         var _loc2_:DistanceFieldStyle = meshStyle as DistanceFieldStyle;
         if(_loc2_)
         {
            _mode = _loc2_._mode;
            _multiChannel = _loc2_._multiChannel;
            _threshold = _loc2_._threshold;
            _softness = _loc2_._softness;
            _alpha = _loc2_._alpha;
            _outerThreshold = _loc2_._outerThreshold;
            _outerAlphaEnd = _loc2_._outerAlphaEnd;
            _shadowOffsetX = _loc2_._shadowOffsetX;
            _shadowOffsetY = _loc2_._shadowOffsetY;
            _outerColor = _loc2_._outerColor;
            _outerAlphaStart = _loc2_._outerAlphaStart;
         }
         super.copyFrom(meshStyle);
      }
      
      override public function createEffect() : MeshEffect
      {
         return new DistanceFieldEffect();
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
         var _loc7_:int = 0;
         if(vertexData == null)
         {
            return;
         }
         var _loc1_:int = vertexData.numVertices;
         var _loc4_:int = 8;
         var _loc3_:int = 8;
         var _loc5_:Number = (_shadowOffsetX + _loc3_) / (2 * _loc3_);
         var _loc6_:Number = (_shadowOffsetY + _loc3_) / (2 * _loc3_);
         var _loc8_:uint = uint(uint(_threshold * 255) | uint(_alpha * 255) << 8 | uint(_softness / 2 * 255) << 16 | uint(1 / _loc4_ * 255) << 24);
         var _loc9_:uint = uint(uint(_outerThreshold * 255) | uint(_outerAlphaEnd * 255) << 8 | uint(_loc5_ * 255) << 16 | uint(_loc6_ * 255) << 24);
         var _loc2_:uint = uint(Color.getRed(_outerColor) | Color.getGreen(_outerColor) << 8 | Color.getBlue(_outerColor) << 16 | uint(_outerAlphaStart * 255) << 24);
         _loc7_ = 0;
         while(_loc7_ < _loc1_)
         {
            vertexData.setUnsignedInt(_loc7_,"basic",_loc8_);
            vertexData.setUnsignedInt(_loc7_,"extended",_loc9_);
            vertexData.setUnsignedInt(_loc7_,"outerColor",_loc2_);
            _loc7_++;
         }
         setVertexDataChanged();
      }
      
      override public function batchVertexData(targetStyle:MeshStyle, targetVertexID:int = 0, matrix:Matrix = null, vertexID:int = 0, numVertices:int = -1) : void
      {
         var _loc8_:Number = NaN;
         var _loc12_:VertexData = null;
         var _loc6_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc9_:int = 0;
         var _loc10_:uint = 0;
         var _loc14_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc7_:uint = 0;
         super.batchVertexData(targetStyle,targetVertexID,matrix,vertexID,numVertices);
         if(matrix)
         {
            _loc8_ = Math.sqrt(matrix.a * matrix.a + matrix.c * matrix.c);
            if(!MathUtil.isEquivalent(_loc8_,1,0.01))
            {
               _loc12_ = (targetStyle as DistanceFieldStyle).vertexData;
               _loc6_ = 8;
               _loc13_ = _loc6_ / 255;
               if(numVertices < 0)
               {
                  numVertices = vertexData.numVertices - vertexID;
               }
               _loc9_ = 0;
               while(_loc9_ < numVertices)
               {
                  _loc10_ = vertexData.getUnsignedInt(vertexID + _loc9_,"basic");
                  _loc14_ = (_loc10_ >> 24 & 0xFF) / 255 * _loc6_;
                  _loc11_ = MathUtil.clamp(_loc14_ * _loc8_,_loc13_,_loc6_);
                  _loc7_ = uint(_loc10_ & 0xFFFFFF | uint(_loc11_ / _loc6_ * 255) << 24);
                  _loc12_.setUnsignedInt(targetVertexID + _loc9_,"basic",_loc7_);
                  _loc9_++;
               }
            }
         }
      }
      
      override public function updateEffect(effect:MeshEffect, state:RenderState) : void
      {
         var _loc4_:Matrix = null;
         var _loc3_:Number = NaN;
         var _loc5_:DistanceFieldEffect = effect as DistanceFieldEffect;
         _loc5_.mode = _mode;
         _loc5_.multiChannel = _multiChannel;
         if(state.is3D)
         {
            _loc5_.scale = 1;
         }
         else
         {
            _loc4_ = state.modelviewMatrix;
            _loc3_ = Math.sqrt(_loc4_.a * _loc4_.a + _loc4_.c * _loc4_.c);
            _loc5_.scale = _loc3_ * Starling.contentScaleFactor;
         }
         super.updateEffect(effect,state);
      }
      
      override public function canBatchWith(meshStyle:MeshStyle) : Boolean
      {
         var _loc2_:DistanceFieldStyle = meshStyle as DistanceFieldStyle;
         if(_loc2_ && super.canBatchWith(meshStyle))
         {
            return _loc2_._mode == _mode && _loc2_._multiChannel == _multiChannel;
         }
         return false;
      }
      
      public function setupBasic() : void
      {
         _mode = "basic";
         setRequiresRedraw();
      }
      
      public function setupOutline(width:Number = 0.25, color:uint = 0, alpha:Number = 1) : void
      {
         _mode = "outline";
         _outerThreshold = MathUtil.clamp(_threshold - width,0,_threshold);
         _outerColor = color;
         _outerAlphaStart = _outerAlphaEnd = MathUtil.clamp(alpha,0,1);
         _shadowOffsetX = _shadowOffsetY = 0;
         updateVertices();
      }
      
      public function setupGlow(blur:Number = 0.2, color:uint = 16776960, alpha:Number = 0.5) : void
      {
         _mode = "glow";
         _outerThreshold = MathUtil.clamp(_threshold - blur,0,_threshold);
         _outerColor = color;
         _outerAlphaStart = MathUtil.clamp(alpha,0,1);
         _outerAlphaEnd = 0;
         _shadowOffsetX = _shadowOffsetY = 0;
         updateVertices();
      }
      
      public function setupDropShadow(blur:Number = 0.2, offsetX:Number = 2, offsetY:Number = 2, color:uint = 0, alpha:Number = 0.5) : void
      {
         var _loc6_:Number = NaN;
         _loc6_ = 8;
         _mode = "shadow";
         _outerThreshold = MathUtil.clamp(_threshold - blur,0,_threshold);
         _outerColor = color;
         _outerAlphaStart = MathUtil.clamp(alpha,0,1);
         _outerAlphaEnd = 0;
         _shadowOffsetX = MathUtil.clamp(offsetX,-8,8);
         _shadowOffsetY = MathUtil.clamp(offsetY,-8,8);
         updateVertices();
      }
      
      public function get mode() : String
      {
         return _mode;
      }
      
      public function set mode(value:String) : void
      {
         _mode = value;
         setRequiresRedraw();
      }
      
      public function get multiChannel() : Boolean
      {
         return _multiChannel;
      }
      
      public function set multiChannel(value:Boolean) : void
      {
         _multiChannel = value;
         setRequiresRedraw();
      }
      
      public function get threshold() : Number
      {
         return _threshold;
      }
      
      public function set threshold(value:Number) : void
      {
         value = MathUtil.clamp(value,0,1);
         if(_threshold != value)
         {
            _threshold = value;
            updateVertices();
         }
      }
      
      public function get softness() : Number
      {
         return _softness;
      }
      
      public function set softness(value:Number) : void
      {
         value = MathUtil.clamp(value,0,1);
         if(_softness != value)
         {
            _softness = value;
            updateVertices();
         }
      }
      
      public function get alpha() : Number
      {
         return _alpha;
      }
      
      public function set alpha(value:Number) : void
      {
         value = MathUtil.clamp(value,0,1);
         if(_alpha != value)
         {
            _alpha = value;
            updateVertices();
         }
      }
      
      public function get outerThreshold() : Number
      {
         return _outerThreshold;
      }
      
      public function set outerThreshold(value:Number) : void
      {
         value = MathUtil.clamp(value,0,1);
         if(_outerThreshold != value)
         {
            _outerThreshold = value;
            updateVertices();
         }
      }
      
      public function get outerAlphaStart() : Number
      {
         return _outerAlphaStart;
      }
      
      public function set outerAlphaStart(value:Number) : void
      {
         value = MathUtil.clamp(value,0,1);
         if(_outerAlphaStart != value)
         {
            _outerAlphaStart = value;
            updateVertices();
         }
      }
      
      public function get outerAlphaEnd() : Number
      {
         return _outerAlphaEnd;
      }
      
      public function set outerAlphaEnd(value:Number) : void
      {
         value = MathUtil.clamp(value,0,1);
         if(_outerAlphaEnd != value)
         {
            _outerAlphaEnd = value;
            updateVertices();
         }
      }
      
      public function get outerColor() : uint
      {
         return _outerColor;
      }
      
      public function set outerColor(value:uint) : void
      {
         if(_outerColor != value)
         {
            _outerColor = value;
            updateVertices();
         }
      }
      
      public function get shadowOffsetX() : Number
      {
         return _shadowOffsetX;
      }
      
      public function set shadowOffsetX(value:Number) : void
      {
         var _loc2_:Number = NaN;
         _loc2_ = 8;
         value = MathUtil.clamp(value,-8,8);
         if(_shadowOffsetX != value)
         {
            _shadowOffsetX = value;
            updateVertices();
         }
      }
      
      public function get shadowOffsetY() : Number
      {
         return _shadowOffsetY;
      }
      
      public function set shadowOffsetY(value:Number) : void
      {
         var _loc2_:Number = NaN;
         _loc2_ = 8;
         value = MathUtil.clamp(value,-8,8);
         if(_shadowOffsetY != value)
         {
            _shadowOffsetY = value;
            updateVertices();
         }
      }
   }
}

import flash.display3D.Context3D;
import starling.rendering.MeshEffect;
import starling.rendering.Program;
import starling.rendering.VertexDataFormat;
import starling.styles.DistanceFieldStyle;
import starling.utils.StringUtil;

class DistanceFieldEffect extends MeshEffect
{
   
   public static const MAX_OUTER_OFFSET:int = 8;
   
   public static const MAX_SCALE:int = 8;
   
   public static const VERTEX_FORMAT:VertexDataFormat = DistanceFieldStyle.VERTEX_FORMAT;
   
   private static const sVector:Vector.<Number> = new Vector.<Number>(4,true);
   
   private var _mode:String;
   
   private var _scale:Number;
   
   private var _multiChannel:Boolean;
   
   public function DistanceFieldEffect()
   {
      super();
      _scale = 1;
      _mode = "basic";
   }
   
   private static function step(inOutReg:String, minReg:String, maxReg:String, tmpReg:String = "ft6") : String
   {
      return [StringUtil.format("sub {0}, {1}, {2}",tmpReg,maxReg,minReg),StringUtil.format("rcp {0}, {0}",tmpReg),StringUtil.format("sub {0}, {0}, {1}",inOutReg,minReg),StringUtil.format("mul {0}, {0}, {1}",inOutReg,tmpReg),StringUtil.format("sat {0}, {0}",inOutReg)].join("\n");
   }
   
   private static function median(inOutReg:String) : String
   {
      return [StringUtil.format("max {0}.xyz, {0}.xxy, {0}.yzz",inOutReg),StringUtil.format("min {0}.x, {0}.x, {0}.y",inOutReg),StringUtil.format("min {0}, {0}.xxxx, {0}.zzzz",inOutReg)].join("\n");
   }
   
   override protected function createProgram() : Program
   {
      var _loc1_:Boolean = false;
      var _loc4_:Boolean = false;
      var _loc2_:Vector.<String> = undefined;
      var _loc3_:Vector.<String> = undefined;
      if(texture)
      {
         _loc1_ = _mode == "basic";
         _loc4_ = _mode == "shadow";
         _loc2_ = new <String>["m44 op, va0, vc0","mov v0, va1","mul vt4, va3.yyyy, vc4","mul v1, va2, vt4","mov v3, va3","mov v4, va4","mov v5, va5","mul vt4.w, vc4.w, va2.w","mul v4.y, va4.y, vt4.w","mul v5.w, va5.w, vt4.w","mul vt0.x, va3.w, vc5.z","mul vt0.x, vt0.x, vc5.w","div vt0.x, va3.z, vt0.x","mov vt1, vc4","sub vt1.x, va3.x, vt0.x","add vt1.y, va3.x, vt0.x"];
         if(!_loc1_)
         {
            _loc2_.push("sub vt1.z, va4.x, vt0.x","add vt1.w, va4.x, vt0.x");
         }
         _loc2_.push("sat v6, vt1");
         if(_loc4_)
         {
            _loc2_.push("mul vt0.xy, va4.zw, vc6.zz","sub vt0.xy, vt0.xy, vc6.yy","mul vt0.xy, vt0.xy, vc5.xy","sub v7, va1, vt0.xyxy","sub vt0.z, va3.x, va4.x","add v7.z, va3.x, vt0.z");
         }
         var _temp_18:* = new <String>[tex("ft0","v0",0,texture),_multiChannel ? median("ft0") : "mov ft0, ft0.xxxx","mov ft1, ft0",step("ft1.w","v6.x","v6.y"),"mov ft3, ft1","mul ft1, v1, ft1.wwww"];
         _loc3_ = new <String>[tex("ft0","v0",0,texture),_multiChannel ? median("ft0") : "mov ft0, ft0.xxxx","mov ft1, ft0",step("ft1.w","v6.x","v6.y"),"mov ft3, ft1","mul ft1, v1, ft1.wwww"];
         if(_loc4_)
         {
            _loc3_.push(tex("ft0","v7",0,texture),_multiChannel ? median("ft0") : "mov ft0, ft0.xxxx","mov ft5.x, v7.z");
         }
         else if(!_loc1_)
         {
            _loc3_.push("mov ft5.x, v6.x");
         }
         if(!_loc1_)
         {
            _loc3_.push("mov ft2, ft0",step("ft2.w","v6.z","v6.w"),"sub ft2.w, ft2.w, ft3.w","sat ft2.w, ft2.w","mov ft4, ft0",step("ft4.w","v6.z","ft5.x"),"sub ft6.w, v5.w, v4.y","mul ft4.w, ft4.w, ft6.w","add ft4.w, ft4.w, v4.y","mul ft2.w, ft2.w, ft4.w","mul ft2.xyz, v5.xyz, ft2.www");
         }
         if(_loc1_)
         {
            _loc3_.push("mov oc, ft1");
         }
         else
         {
            _loc3_.push("add oc, ft1, ft2");
         }
         return Program.fromSource(_loc2_.join("\n"),_loc3_.join("\n"));
      }
      return super.createProgram();
   }
   
   override protected function beforeDraw(context:Context3D) : void
   {
      var _loc3_:Number = NaN;
      var _loc2_:Number = NaN;
      super.beforeDraw(context);
      if(texture)
      {
         vertexFormat.setVertexBufferAt(3,vertexBuffer,"basic");
         vertexFormat.setVertexBufferAt(4,vertexBuffer,"extended");
         vertexFormat.setVertexBufferAt(5,vertexBuffer,"outerColor");
         _loc3_ = 1 / (texture.root.nativeWidth / texture.scale);
         _loc2_ = 1 / (texture.root.nativeHeight / texture.scale);
         sVector[0] = 8 * _loc3_;
         sVector[1] = 8 * _loc2_;
         sVector[2] = 8;
         sVector[3] = _scale;
         context.setProgramConstantsFromVector("vertex",5,sVector);
         sVector[0] = 0;
         sVector[1] = 1;
         sVector[2] = 2;
         context.setProgramConstantsFromVector("vertex",6,sVector);
      }
   }
   
   override protected function afterDraw(context:Context3D) : void
   {
      if(texture)
      {
         context.setVertexBufferAt(3,null);
         context.setVertexBufferAt(4,null);
         context.setVertexBufferAt(5,null);
      }
      super.afterDraw(context);
   }
   
   override public function get vertexFormat() : VertexDataFormat
   {
      return VERTEX_FORMAT;
   }
   
   override protected function get programVariantName() : uint
   {
      var _loc1_:uint = 0;
      switch(_mode)
      {
         case "shadow":
            _loc1_ = 3;
            break;
         case "glow":
            _loc1_ = 2;
            break;
         case "outline":
            _loc1_ = 1;
            break;
         default:
            _loc1_ = 0;
      }
      if(_multiChannel)
      {
         _loc1_ |= 4;
      }
      return super.programVariantName | _loc1_ << 8;
   }
   
   public function get scale() : Number
   {
      return _scale;
   }
   
   public function set scale(value:Number) : void
   {
      _scale = value;
   }
   
   public function get mode() : String
   {
      return _mode;
   }
   
   public function set mode(value:String) : void
   {
      _mode = value;
   }
   
   public function get multiChannel() : Boolean
   {
      return _multiChannel;
   }
   
   public function set multiChannel(value:Boolean) : void
   {
      _multiChannel = value;
   }
}
