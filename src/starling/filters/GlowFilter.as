package starling.filters
{
   import starling.rendering.Painter;
   import starling.textures.Texture;
   
   public class GlowFilter extends FragmentFilter
   {
      
      private var _blurFilter:BlurFilter;
      
      private var _compositeFilter:CompositeFilter;
      
      private var _inner:Boolean;
      
      private var _knockout:Boolean;
      
      public function GlowFilter(color:uint = 16776960, alpha:Number = 1, blur:Number = 1, quality:Number = 0.5, inner:Boolean = false, knockout:Boolean = false)
      {
         super();
         _compositeFilter = new CompositeFilter();
         _blurFilter = new BlurFilter(blur,blur);
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
         padding.copyFrom(_blurFilter.padding);
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

