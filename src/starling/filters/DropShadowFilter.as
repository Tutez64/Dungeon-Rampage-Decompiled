package starling.filters
{
   import starling.rendering.Painter;
   import starling.textures.Texture;
   import starling.utils.Padding;
   
   public class DropShadowFilter extends FragmentFilter
   {
      
      private var _blurFilter:BlurFilter;
      
      private var _compositeFilter:CompositeFilter;
      
      private var _distance:Number;
      
      private var _angle:Number;
      
      private var _inner:Boolean;
      
      private var _knockout:Boolean;
      
      public function DropShadowFilter(distance:Number = 4, angle:Number = 0.785, color:uint = 0, alpha:Number = 0.5, blur:Number = 1, quality:Number = 0.5, inner:Boolean = false, knockout:Boolean = false)
      {
         super();
         _compositeFilter = new CompositeFilter();
         _blurFilter = new BlurFilter(blur,blur);
         _distance = distance;
         _angle = angle;
         this.color = color;
         this.alpha = alpha;
         this.quality = quality;
         this.inner = inner;
         this.knockout = knockout;
         updatePadding();
      }
      
      private static function getMode(inner:Boolean, knockout:Boolean) : String
      {
         return knockout ? (inner ? "insideKnockout" : "outsideKnockout") : (inner ? "inside" : "outside");
      }
      
      override public function dispose() : void
      {
         _blurFilter.dispose();
         _compositeFilter.dispose();
         super.dispose();
      }
      
      override public function process(painter:Painter, helper:IFilterHelper, input0:Texture = null, input1:Texture = null, input2:Texture = null, input3:Texture = null) : Texture
      {
         var _loc8_:Texture = _blurFilter.process(painter,helper,input0);
         var _loc7_:Texture = _compositeFilter.process(painter,helper,input0,_loc8_);
         helper.putTexture(_loc8_);
         return _loc7_;
      }
      
      override public function get numPasses() : int
      {
         return _blurFilter.numPasses + _compositeFilter.numPasses;
      }
      
      private function updatePadding() : void
      {
         var _loc1_:Number = Math.cos(_angle) * _distance;
         var _loc2_:Number = Math.sin(_angle) * _distance;
         _compositeFilter.setOffsetAt(1,_loc1_,_loc2_);
         var _loc6_:Padding = _blurFilter.padding;
         var _loc4_:Number = _loc6_.left;
         var _loc7_:Number = _loc6_.right;
         var _loc3_:Number = _loc6_.top;
         var _loc5_:Number = _loc6_.bottom;
         if(_loc1_ > 0)
         {
            _loc7_ += _loc1_;
         }
         else
         {
            _loc4_ -= _loc1_;
         }
         if(_loc2_ > 0)
         {
            _loc5_ += _loc2_;
         }
         else
         {
            _loc3_ -= _loc2_;
         }
         padding.setTo(_loc4_,_loc7_,_loc3_,_loc5_);
      }
      
      public function get color() : uint
      {
         return _compositeFilter.getColorAt(1);
      }
      
      public function set color(value:uint) : void
      {
         if(color != value || !_compositeFilter.getReplaceColorAt(1))
         {
            _compositeFilter.setColorAt(1,value,true);
            setRequiresRedraw();
         }
      }
      
      public function get alpha() : Number
      {
         return _compositeFilter.getAlphaAt(1);
      }
      
      public function set alpha(value:Number) : void
      {
         if(alpha != value)
         {
            _compositeFilter.setAlphaAt(1,value);
            setRequiresRedraw();
         }
      }
      
      public function get distance() : Number
      {
         return _distance;
      }
      
      public function set distance(value:Number) : void
      {
         if(_distance != value)
         {
            _distance = value;
            setRequiresRedraw();
            updatePadding();
         }
      }
      
      public function get angle() : Number
      {
         return _angle;
      }
      
      public function set angle(value:Number) : void
      {
         if(_angle != value)
         {
            _angle = value;
            setRequiresRedraw();
            updatePadding();
         }
      }
      
      public function get blur() : Number
      {
         return _blurFilter.blurX;
      }
      
      public function set blur(value:Number) : void
      {
         if(blur != value)
         {
            _blurFilter.blurX = _blurFilter.blurY = value;
            setRequiresRedraw();
            updatePadding();
         }
      }
      
      public function get quality() : Number
      {
         return _blurFilter.quality;
      }
      
      public function set quality(value:Number) : void
      {
         if(quality != value)
         {
            _blurFilter.quality = value;
            setRequiresRedraw();
            updatePadding();
         }
      }
      
      public function get inner() : Boolean
      {
         return _inner;
      }
      
      public function set inner(value:Boolean) : void
      {
         _inner = value;
         _compositeFilter.setModeAt(1,getMode(_inner,_knockout));
         _compositeFilter.setInvertAlphaAt(1,_inner);
         setRequiresRedraw();
      }
      
      public function get knockout() : Boolean
      {
         return _knockout;
      }
      
      public function set knockout(value:Boolean) : void
      {
         _knockout = value;
         _compositeFilter.setModeAt(1,getMode(_inner,_knockout));
         setRequiresRedraw();
      }
   }
}

