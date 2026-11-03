package UI.Hud.StarlingConverted
{
   import Brain.Starling.SwfConverter.BakedPicture;
   import Brain.Starling.SwfConverter.FlashBaker;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.filters.BitmapFilter;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   
   internal class TextFilterBake
   {
      
      public function TextFilterBake()
      {
         super();
      }
      
      internal static function bake(field:TextField, ancestors:Vector.<ArtDisplay>, variant:int, scale:Number, placement:Matrix) : BakedPicture
      {
         var _loc11_:Sprite = null;
         var _loc6_:ArtDisplay = null;
         var _loc12_:Array = null;
         var _loc13_:BitmapFilter = null;
         var _loc16_:int = 0;
         var _loc8_:int = 0;
         var _loc15_:TextField = FlashBaker.textCopy(field);
         var _loc10_:Rectangle = field.getBounds(field);
         _loc15_.autoSize = field.autoSize;
         _loc15_.multiline = field.multiline;
         _loc15_.wordWrap = field.wordWrap;
         _loc15_.width = _loc10_.width;
         _loc15_.height = _loc10_.height;
         _loc15_.htmlText = field.htmlText;
         _loc15_.transform.matrix = field.transform.matrix;
         var _loc7_:Matrix = _loc15_.transform.matrix.clone();
         var _loc17_:DisplayObject = _loc15_;
         for each(_loc6_ in ancestors)
         {
            _loc8_ = int(_loc6_.art.filterStates.length);
            _loc16_ = _loc8_ > 0 ? variant % _loc8_ : 0;
            if(_loc8_ > 0)
            {
               variant /= _loc8_;
            }
            _loc12_ = [];
            if(_loc8_ > 0)
            {
               for each(_loc13_ in _loc6_.art.filterStates[_loc16_])
               {
                  _loc12_.push(_loc13_.clone());
               }
            }
            _loc11_ = new Sprite();
            _loc11_.filters = _loc12_;
            _loc11_.addChild(_loc17_);
            _loc11_.transform.matrix = _loc6_.art.matrix;
            _loc7_.concat(_loc6_.art.matrix);
            _loc17_ = _loc11_;
         }
         _loc11_ = new Sprite();
         _loc11_.addChild(_loc17_);
         var _loc9_:Number = scale / BakeScale.magnitude(_loc7_);
         var _loc14_:BakedPicture = StarlingRaster.bake(_loc11_,_loc9_);
         _loc7_.invert();
         _loc7_.concat(placement);
         placement.copyFrom(_loc7_);
         return _loc14_;
      }
   }
}

