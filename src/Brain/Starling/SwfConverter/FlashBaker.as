package Brain.Starling.SwfConverter
{
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.filters.BitmapFilter;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFormat;
   
   public class FlashBaker
   {
      
      public static const MAX_SIDE:int = 2048;
      
      public static const BORDER:int = 1;
      
      private static const sMatrix:Matrix = new Matrix();
      
      private static const sPoint:Point = new Point();
      
      private static const sProbe:BitmapData = new BitmapData(4,4,true,0);
      
      private static const sProbeRect:Rectangle = new Rectangle(0,0,4,4);
      
      public function FlashBaker()
      {
         super();
      }
      
      public static function bake(source:DisplayObject, pixelScale:Number, hide:Vector.<DisplayObject> = null, ownFilters:Boolean = true, shrinkToFit:Boolean = false, rethrow:Boolean = false) : BakedPicture
      {
         var _loc7_:BakedPicture = null;
         var _loc9_:Vector.<DisplayObject> = null;
         var _loc11_:Boolean = !source.visible;
         try
         {
            if(hide != null)
            {
               _loc9_ = new Vector.<DisplayObject>(0);
               for each(var _loc8_:DisplayObject in hide)
               {
                  if(_loc8_ != null && _loc8_.visible)
                  {
                     _loc8_.visible = false;
                     _loc9_.push(_loc8_);
                  }
               }
            }
            if(_loc11_)
            {
               source.visible = true;
            }
            _loc7_ = draw(source,pixelScale,ownFilters,shrinkToFit);
         }
         catch(error:Error)
         {
            if(rethrow)
            {
               throw error;
            }
            _loc7_ = null;
         }
         finally
         {
            if(_loc11_)
            {
               source.visible = false;
            }
            if(_loc9_ != null)
            {
               for each(var _loc10_:DisplayObject in _loc9_)
               {
                  _loc10_.visible = true;
               }
            }
         }
         return _loc7_;
      }
      
      private static function draw(source:DisplayObject, scale:Number, ownFilters:Boolean, shrinkToFit:Boolean) : BakedPicture
      {
         var _loc8_:int = 0;
         var _loc7_:int = 0;
         var _loc10_:int = 0;
         var _loc12_:int = 0;
         var _loc5_:int = 0;
         var _loc11_:int = 0;
         if(scale <= 0 || !isFinite(scale))
         {
            return null;
         }
         var _loc9_:Rectangle = new Rectangle();
         visibleBounds(source,source,_loc9_,true);
         if(_loc9_.width <= 0 || _loc9_.height <= 0)
         {
            return emptyBake(scale);
         }
         _loc11_ = 0;
         while(true)
         {
            _loc5_ = 1 + 2 + Math.ceil(nestedPadding(source,!ownFilters) * Math.max(1,scale));
            _loc8_ = Math.floor(_loc9_.left * scale) - _loc5_;
            _loc7_ = Math.floor(_loc9_.top * scale) - _loc5_;
            _loc10_ = Math.ceil(_loc9_.right * scale) + _loc5_ - _loc8_;
            _loc12_ = Math.ceil(_loc9_.bottom * scale) + _loc5_ - _loc7_;
            if(!shrinkToFit || _loc10_ <= 2048 && _loc12_ <= 2048 || _loc11_ >= 8)
            {
               break;
            }
            scale *= (2048 - 4) / Math.max(_loc10_,_loc12_);
            _loc11_++;
         }
         if(_loc10_ > 2048 || _loc12_ > 2048)
         {
            return null;
         }
         var _loc6_:BitmapData = new BitmapData(_loc10_,_loc12_,true,0);
         try
         {
            return drawOnto(_loc6_,source,scale,ownFilters,_loc8_,_loc7_);
         }
         catch(error:Error)
         {
            _loc6_.dispose();
            throw error;
         }
      }
      
      private static function drawOnto(canvas:BitmapData, source:DisplayObject, scale:Number, ownFilters:Boolean, left:int, top:int) : BakedPicture
      {
         sMatrix.setTo(scale,0,0,scale,-left,-top);
         var _loc7_:Array = ownFilters ? null : source.filters;
         if(_loc7_ != null && _loc7_.length > 0)
         {
            source.filters = [];
         }
         try
         {
            canvas.draw(source,sMatrix,null,null,null,true);
         }
         finally
         {
            if(_loc7_ != null && _loc7_.length > 0)
            {
               source.filters = _loc7_;
            }
         }
         var _loc9_:Rectangle = canvas.getColorBoundsRect(4278190080,0,false);
         if(_loc9_.width <= 0 || _loc9_.height <= 0)
         {
            canvas.dispose();
            return emptyBake(scale);
         }
         var _loc8_:BakedPicture = new BakedPicture();
         _loc8_.bitmap = new BitmapData(_loc9_.width + 1 * 2,_loc9_.height + 1 * 2,true,0);
         sPoint.setTo(1,1);
         _loc8_.bitmap.copyPixels(canvas,_loc9_,sPoint);
         canvas.dispose();
         _loc8_.originX = -left - _loc9_.x + 1;
         _loc8_.originY = -top - _loc9_.y + 1;
         _loc8_.pixelScale = scale;
         return _loc8_;
      }
      
      private static function visibleBounds(node:DisplayObject, space:DisplayObject, out:Rectangle, isRoot:Boolean) : void
      {
         var _loc7_:int = 0;
         var _loc10_:DisplayObject = null;
         var _loc9_:Boolean = false;
         if(!isRoot && !node.visible)
         {
            return;
         }
         var _loc5_:DisplayObjectContainer = node as DisplayObjectContainer;
         if(_loc5_ == null || _loc5_.numChildren == 0 || _loc5_.scrollRect != null)
         {
            unionInto(out,boundsIn(node,space));
            return;
         }
         var _loc6_:Rectangle = new Rectangle();
         _loc7_ = 0;
         while(_loc7_ < _loc5_.numChildren)
         {
            _loc10_ = _loc5_.getChildAt(_loc7_);
            if(_loc10_ != null)
            {
               visibleBounds(_loc10_,space,_loc6_,false);
            }
            _loc7_++;
         }
         var _loc8_:Rectangle = boundsIn(node,space);
         if(_loc5_ is Sprite && !(_loc6_.width > 0 && _loc6_.height > 0 && _loc6_.containsRect(_loc8_)))
         {
            try
            {
               _loc9_ = Sprite(_loc5_).graphics.readGraphicsData(false).length > 0;
            }
            catch(error:Error)
            {
               _loc9_ = true;
            }
            if(_loc9_)
            {
               unionInto(out,_loc8_);
               return;
            }
         }
         unionInto(out,_loc6_);
      }
      
      private static function boundsIn(node:DisplayObject, space:DisplayObject) : Rectangle
      {
         var _loc13_:Matrix = null;
         var _loc6_:DisplayObject = null;
         var _loc12_:Rectangle = node.getBounds(space);
         if(_loc12_.width > 0 && _loc12_.height > 0 || node == space)
         {
            return _loc12_;
         }
         var _loc9_:Rectangle = node.getBounds(node);
         if(_loc9_.width <= 0 && _loc9_.height <= 0)
         {
            return _loc12_;
         }
         var _loc8_:Matrix = new Matrix();
         _loc6_ = node;
         while(_loc6_ != null && _loc6_ != space)
         {
            if(_loc6_ != node && _loc6_.scrollRect != null)
            {
               _loc8_.translate(-_loc6_.scrollRect.x,-_loc6_.scrollRect.y);
            }
            _loc13_ = _loc6_.transform.matrix;
            if(_loc13_ == null)
            {
               return _loc12_;
            }
            _loc8_.concat(_loc13_);
            _loc6_ = _loc6_.parent;
         }
         var _loc3_:Point = _loc8_.transformPoint(_loc9_.topLeft);
         var _loc4_:Point = _loc8_.transformPoint(new Point(_loc9_.right,_loc9_.top));
         var _loc5_:Point = _loc8_.transformPoint(_loc9_.bottomRight);
         var _loc7_:Point = _loc8_.transformPoint(new Point(_loc9_.left,_loc9_.bottom));
         var _loc11_:Number = Math.min(_loc3_.x,_loc4_.x,_loc5_.x,_loc7_.x);
         var _loc10_:Number = Math.min(_loc3_.y,_loc4_.y,_loc5_.y,_loc7_.y);
         return new Rectangle(_loc11_,_loc10_,Math.max(_loc3_.x,_loc4_.x,_loc5_.x,_loc7_.x) - _loc11_,Math.max(_loc3_.y,_loc4_.y,_loc5_.y,_loc7_.y) - _loc10_);
      }
      
      private static function unionInto(out:Rectangle, rect:Rectangle) : void
      {
         if(rect.width <= 0 || rect.height <= 0)
         {
            return;
         }
         if(out.width <= 0 || out.height <= 0)
         {
            out.copyFrom(rect);
         }
         else
         {
            out.copyFrom(out.union(rect));
         }
      }
      
      public static function textCopy(field:TextField, text:String = null) : TextField
      {
         var _loc4_:TextField = new TextField();
         var _loc3_:TextFormat = field.length > 0 ? field.getTextFormat(0,field.length) : null;
         _loc4_.defaultTextFormat = _loc3_ != null && _loc3_.size != null ? _loc3_ : field.defaultTextFormat;
         _loc4_.embedFonts = field.embedFonts;
         _loc4_.antiAliasType = field.antiAliasType;
         _loc4_.gridFitType = field.gridFitType;
         _loc4_.sharpness = field.sharpness;
         _loc4_.thickness = field.thickness;
         _loc4_.multiline = false;
         _loc4_.wordWrap = false;
         _loc4_.selectable = false;
         _loc4_.autoSize = "left";
         _loc4_.filters = field.filters;
         _loc4_.text = text ?? field.text;
         _loc4_.textColor = field.textColor;
         return _loc4_;
      }
      
      private static function emptyBake(scale:Number) : BakedPicture
      {
         var _loc2_:BakedPicture = new BakedPicture();
         _loc2_.bitmap = new BitmapData(1 * 2,1 * 2,true,0);
         _loc2_.originX = _loc2_.originY = 1;
         _loc2_.pixelScale = scale;
         _loc2_.empty = true;
         return _loc2_;
      }
      
      private static function nestedPadding(node:DisplayObject, skipOwn:Boolean) : int
      {
         var _loc8_:Rectangle = null;
         var _loc7_:int = 0;
         var _loc9_:DisplayObject = null;
         var _loc6_:int = 0;
         if(!skipOwn && !node.visible)
         {
            return 0;
         }
         if(!skipOwn)
         {
            for each(var _loc3_:BitmapFilter in node.filters)
            {
               _loc8_ = sProbe.generateFilterRect(sProbeRect,_loc3_);
               _loc6_ += Math.ceil(Math.max(-_loc8_.x,-_loc8_.y,_loc8_.right - sProbeRect.right,_loc8_.bottom - sProbeRect.bottom,estimate(_loc3_)));
            }
         }
         var _loc5_:int = 0;
         var _loc4_:DisplayObjectContainer = node as DisplayObjectContainer;
         if(_loc4_ != null)
         {
            _loc7_ = 0;
            while(_loc7_ < _loc4_.numChildren)
            {
               _loc9_ = _loc4_.getChildAt(_loc7_);
               if(_loc9_ != null)
               {
                  _loc5_ = Math.max(_loc5_,nestedPadding(_loc9_,false));
               }
               _loc7_++;
            }
         }
         return _loc6_ + _loc5_;
      }
      
      private static function estimate(filter:BitmapFilter) : Number
      {
         var _loc3_:Number = "blurX" in filter ? Math.max(Number(filter["blurX"]),Number(filter["blurY"])) : 0;
         var _loc4_:Number = "quality" in filter ? Math.max(1,Number(filter["quality"])) : 1;
         var _loc2_:Number = "distance" in filter ? Math.abs(Number(filter["distance"])) : 0;
         return _loc3_ * _loc4_ / 2 + _loc2_ + 2;
      }
   }
}

