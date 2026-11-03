package starling.filters
{
   import flash.geom.Point;
   import starling.rendering.FilterEffect;
   import starling.rendering.Painter;
   import starling.textures.Texture;
   
   public class CompositeFilter extends FragmentFilter
   {
      
      public function CompositeFilter()
      {
         super();
      }
      
      override public function process(painter:Painter, helper:IFilterHelper, input0:Texture = null, input1:Texture = null, input2:Texture = null, input3:Texture = null) : Texture
      {
         compositeEffect.texture = input0;
         compositeEffect.getLayerAt(1).texture = input1;
         compositeEffect.getLayerAt(2).texture = input2;
         compositeEffect.getLayerAt(3).texture = input3;
         if(input1)
         {
            input1.setupTextureCoordinates(vertexData,0,"texCoords1");
         }
         if(input2)
         {
            input2.setupTextureCoordinates(vertexData,0,"texCoords2");
         }
         if(input3)
         {
            input3.setupTextureCoordinates(vertexData,0,"texCoords3");
         }
         return super.process(painter,helper,input0,input1,input2,input3);
      }
      
      override protected function createEffect() : FilterEffect
      {
         return new CompositeEffect();
      }
      
      public function getOffsetAt(layerID:int, out:Point = null) : Point
      {
         if(out == null)
         {
            out = new Point();
         }
         out.x = compositeEffect.getLayerAt(layerID).x;
         out.y = compositeEffect.getLayerAt(layerID).y;
         return out;
      }
      
      public function setOffsetAt(layerID:int, x:Number, y:Number) : void
      {
         compositeEffect.getLayerAt(layerID).x = x;
         compositeEffect.getLayerAt(layerID).y = y;
      }
      
      public function getColorAt(layerID:int) : uint
      {
         return compositeEffect.getLayerAt(layerID).color;
      }
      
      public function getReplaceColorAt(layerID:int) : Boolean
      {
         return compositeEffect.getLayerAt(layerID).replaceColor;
      }
      
      public function setColorAt(layerID:int, color:uint, replace:Boolean = false) : void
      {
         compositeEffect.getLayerAt(layerID).color = color;
         compositeEffect.getLayerAt(layerID).replaceColor = replace;
      }
      
      public function getAlphaAt(layerID:int) : Number
      {
         return compositeEffect.getLayerAt(layerID).alpha;
      }
      
      public function setAlphaAt(layerID:int, alpha:Number) : void
      {
         compositeEffect.getLayerAt(layerID).alpha = alpha;
      }
      
      public function getModeAt(layerID:int) : String
      {
         return compositeEffect.getLayerAt(layerID).mode;
      }
      
      public function setModeAt(layerID:int, mode:String) : void
      {
         compositeEffect.getLayerAt(layerID).mode = mode;
      }
      
      public function getInvertAlphaAt(layerID:int) : Boolean
      {
         return compositeEffect.getLayerAt(layerID).invertAlpha;
      }
      
      public function setInvertAlphaAt(layerID:int, value:Boolean = true) : void
      {
         compositeEffect.getLayerAt(layerID).invertAlpha = value;
      }
      
      private function get compositeEffect() : CompositeEffect
      {
         return this.effect as CompositeEffect;
      }
   }
}

import flash.display3D.Context3D;
import starling.filters.CompositeMode;
import starling.rendering.FilterEffect;
import starling.rendering.Program;
import starling.rendering.VertexDataFormat;
import starling.textures.Texture;
import starling.utils.Color;
import starling.utils.RenderUtil;
import starling.utils.StringUtil;

class CompositeEffect extends FilterEffect
{
   
   public static const VERTEX_FORMAT:VertexDataFormat = FilterEffect.VERTEX_FORMAT.extend("texCoords1:float2, texCoords2:float2, texCoords3:float2");
   
   private static var sLayers:Array = [];
   
   private static var sOffset:Vector.<Number> = new <Number>[0,0,0,0];
   
   private static var sColor:Vector.<Number> = new <Number>[0,0,0,0];
   
   private var _layers:Vector.<CompositeLayer>;
   
   public function CompositeEffect(numLayers:int = 4)
   {
      var _loc2_:int = 0;
      super();
      if(numLayers < 1 || numLayers > 4)
      {
         throw new ArgumentError("number of layers must be between 1 and 4");
      }
      _layers = new Vector.<CompositeLayer>(numLayers,true);
      _loc2_ = 0;
      while(_loc2_ < numLayers)
      {
         _layers[_loc2_] = new CompositeLayer();
         _loc2_++;
      }
   }
   
   public function getLayerAt(layerID:int) : CompositeLayer
   {
      return _layers[layerID];
   }
   
   private function getUsedLayers(out:Array = null) : Array
   {
      if(out == null)
      {
         out = [];
      }
      else
      {
         out.length = 0;
      }
      for each(var _loc2_:CompositeLayer in _layers)
      {
         if(_loc2_.texture)
         {
            out[out.length] = _loc2_;
         }
      }
      return out;
   }
   
   override protected function createProgram() : Program
   {
      var _loc6_:int = 0;
      var _loc3_:Array = null;
      var _loc9_:CompositeLayer = null;
      var _loc5_:Array = null;
      var _loc7_:String = null;
      var _loc8_:String = null;
      var _loc2_:String = null;
      var _loc4_:Array = getUsedLayers(sLayers);
      var _loc1_:int = int(_loc4_.length);
      if(_loc1_)
      {
         _loc3_ = ["m44 op, va0, vc0"];
         _loc9_ = _layers[0];
         _loc6_ = 0;
         while(_loc6_ < _loc1_)
         {
            _loc3_.push(StringUtil.format("add v{0}, va{1}, vc{2}",_loc6_,_loc6_ + 1,_loc6_ + 4));
            _loc6_++;
         }
         _loc5_ = ["sge ft5, v0, v0"];
         _loc6_ = 0;
         for(; _loc6_ < _loc1_; _loc6_++)
         {
            _loc7_ = "ft" + _loc6_;
            _loc8_ = "fc" + _loc6_;
            _loc2_ = "v" + _loc6_;
            _loc9_ = _layers[_loc6_];
            _loc5_.push(tex(_loc7_,_loc2_,_loc6_,_loc4_[_loc6_].texture));
            if(_loc9_.replaceColor)
            {
               if(_loc9_.invertAlpha)
               {
                  _loc5_.push("sub " + _loc7_ + ".w, ft5.w, " + _loc7_ + ".w");
               }
               _loc5_.push("mul " + _loc7_ + ".w,   " + _loc7_ + ".w,   " + _loc8_ + ".w","sat " + _loc7_ + ".w,   " + _loc7_ + ".w    ","mul " + _loc7_ + ".xyz, " + _loc8_ + ".xyz, " + _loc7_ + ".www");
            }
            else
            {
               _loc5_.push("mul " + _loc7_ + ", " + _loc7_ + ", " + _loc8_);
            }
            if(_loc6_ == 0)
            {
               continue;
            }
            switch(_loc9_.mode)
            {
               case "normal":
                  _loc5_.push("sub ft4, ft5, " + _loc7_ + ".wwww","mul ft0, ft0, ft4","add ft0, ft0, " + _loc7_);
                  break;
               case "inside":
                  _loc5_.push("mul ft4, ft0.wwww, " + _loc7_,"sub ft6, ft5, " + _loc7_ + ".wwww","mul ft6, ft6, ft0","add ft0, ft6, ft4");
                  break;
               case "insideKnockout":
                  _loc5_.push("mul ft0, ft0.wwww, " + _loc7_);
                  break;
               case "outside":
                  _loc5_.push("sub ft4, ft5, ft0.wwww","mul ft4, ft4, " + _loc7_,"add ft0, ft0, ft4");
                  break;
               case "outsideKnockout":
                  _loc5_.push("sub ft4, ft5, ft0.wwww","mul ft0, ft4, " + _loc7_);
                  break;
               default:
                  throw new ArgumentError("Invalid composite mode: " + _loc9_.mode);
            }
         }
         _loc5_.push("mov oc, ft0");
         return Program.fromSource(_loc3_.join("\n"),_loc5_.join("\n"));
      }
      return super.createProgram();
   }
   
   override protected function get programVariantName() : uint
   {
      var _loc4_:uint = 0;
      var _loc8_:uint = 0;
      var _loc3_:uint = 0;
      var _loc10_:uint = 0;
      var _loc6_:uint = 0;
      var _loc9_:CompositeLayer = null;
      var _loc7_:int = 0;
      var _loc2_:uint = 0;
      var _loc5_:Array = getUsedLayers(sLayers);
      var _loc1_:int = int(_loc5_.length);
      _loc7_ = 0;
      while(_loc7_ < _loc1_)
      {
         _loc9_ = _loc5_[_loc7_];
         _loc3_ = RenderUtil.getTextureVariantBits(_loc9_.texture);
         _loc8_ = uint(CompositeMode.getIndex(_loc9_.mode));
         _loc6_ = uint(int(_loc9_.replaceColor));
         _loc10_ = uint(int(_loc9_.invertAlpha));
         _loc4_ = uint(_loc3_ | _loc8_ << 3 | _loc6_ << 6 | _loc10_ << 7);
         _loc2_ |= _loc4_ << _loc7_ * 8;
         _loc7_++;
      }
      return _loc2_;
   }
   
   override protected function beforeDraw(context:Context3D) : void
   {
      var _loc5_:int = 0;
      var _loc6_:CompositeLayer = null;
      var _loc3_:Texture = null;
      var _loc7_:Number = NaN;
      super.beforeDraw(context);
      var _loc4_:Array = getUsedLayers(sLayers);
      var _loc2_:int = int(_loc4_.length);
      if(_loc2_)
      {
         _loc5_ = 0;
         while(_loc5_ < _loc2_)
         {
            _loc6_ = _loc4_[_loc5_];
            _loc3_ = _loc6_.texture;
            _loc7_ = _loc6_.replaceColor ? 1 : _loc6_.alpha;
            sOffset[0] = -_loc6_.x / (_loc3_.root.nativeWidth / _loc3_.scale);
            sOffset[1] = -_loc6_.y / (_loc3_.root.nativeHeight / _loc3_.scale);
            sColor[0] = Color.getRed(_loc6_.color) * _loc7_ / 255;
            sColor[1] = Color.getGreen(_loc6_.color) * _loc7_ / 255;
            sColor[2] = Color.getBlue(_loc6_.color) * _loc7_ / 255;
            sColor[3] = _loc6_.alpha;
            context.setProgramConstantsFromVector("vertex",_loc5_ + 4,sOffset);
            context.setProgramConstantsFromVector("fragment",_loc5_,sColor);
            if(_loc5_ > 0)
            {
               context.setTextureAt(_loc5_,_loc3_.base);
               RenderUtil.setSamplerStateAt(_loc5_,_loc3_.mipMapping,textureSmoothing);
               vertexFormat.setVertexBufferAt(_loc5_ + 1,vertexBuffer,"texCoords" + _loc5_);
            }
            _loc5_++;
         }
      }
   }
   
   override protected function afterDraw(context:Context3D) : void
   {
      var _loc4_:int = 0;
      var _loc3_:Array = getUsedLayers(sLayers);
      var _loc2_:int = int(_loc3_.length);
      _loc4_ = 1;
      while(_loc4_ < _loc2_)
      {
         context.setTextureAt(_loc4_,null);
         context.setVertexBufferAt(_loc4_ + 1,null);
         _loc4_++;
      }
      super.afterDraw(context);
   }
   
   override public function get vertexFormat() : VertexDataFormat
   {
      return VERTEX_FORMAT;
   }
   
   public function get numLayers() : int
   {
      return _layers.length;
   }
   
   override public function set texture(value:Texture) : void
   {
      _layers[0].texture = value;
      super.texture = value;
   }
}

class CompositeLayer
{
   
   public var texture:Texture;
   
   public var x:Number;
   
   public var y:Number;
   
   public var color:uint;
   
   public var alpha:Number;
   
   public var replaceColor:Boolean;
   
   public var invertAlpha:Boolean;
   
   public var mode:String;
   
   public function CompositeLayer()
   {
      super();
      x = y = 0;
      alpha = 1;
      color = 16777215;
      mode = "normal";
   }
}
