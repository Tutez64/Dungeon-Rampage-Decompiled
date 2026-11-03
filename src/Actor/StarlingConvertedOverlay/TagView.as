package Actor.StarlingConvertedOverlay
{
   import Brain.Starling.SwfConverter.BakedImage;
   import flash.geom.Matrix;
   import starling.display.DisplayObject;
   import starling.display.Sprite;
   
   internal class TagView
   {
      
      public static const BAR:int = 0;
      
      public static const NAME:int = 1;
      
      public static const AFK:int = 2;
      
      public const tag:TagSprite = new TagSprite();
      
      public const art:Sprite = new Sprite();
      
      public const bar:Sprite = new Sprite();
      
      public const under:BakedImage = newImage();
      
      public const fill:BakedImage = newImage();
      
      public const over:BakedImage = newImage();
      
      public const name:BakedImage = newImage();
      
      public const afk:BakedImage = newImage();
      
      private const mScreen:Matrix = new Matrix();
      
      private const mParentScreen:Matrix = new Matrix();
      
      public function TagView()
      {
         super();
         bar.addChild(under);
         bar.addChild(fill);
         bar.addChild(over);
         tag.addChild(art);
      }
      
      private static function newImage() : BakedImage
      {
         var _loc1_:BakedImage = new BakedImage();
         _loc1_.visible = false;
         return _loc1_;
      }
      
      public function order(back:int, middle:int, front:int) : void
      {
         art.removeChildren();
         art.addChild(part(back));
         art.addChild(part(middle));
         art.addChild(part(front));
      }
      
      public function snapToScreen(text:BakedImage, pixelSize:Number, baseX:Number, baseY:Number, cameraOffsetX:Number, cameraOffsetY:Number) : void
      {
         art.x = baseX;
         art.y = baseY;
         if(text == null || tag.stage == null || pixelSize <= 0 || !isFinite(pixelSize))
         {
            return;
         }
         text.getTransformationMatrix(tag.stage,mScreen);
         tag.getTransformationMatrix(tag.stage,mParentScreen);
         var _loc9_:Number = mParentScreen.a * mParentScreen.d - mParentScreen.b * mParentScreen.c;
         if(_loc9_ == 0 || !isFinite(_loc9_))
         {
            return;
         }
         var _loc7_:Number = Math.round((mScreen.tx + cameraOffsetX) / pixelSize) * pixelSize - mScreen.tx;
         var _loc8_:Number = Math.round((mScreen.ty + cameraOffsetY) / pixelSize) * pixelSize - mScreen.ty;
         if(!isFinite(_loc7_) || !isFinite(_loc8_))
         {
            return;
         }
         art.x = baseX + (mParentScreen.d * _loc7_ - mParentScreen.c * _loc8_) / _loc9_;
         art.y = baseY + (mParentScreen.a * _loc8_ - mParentScreen.b * _loc7_) / _loc9_;
      }
      
      private function part(id:int) : DisplayObject
      {
         return id == 0 ? bar : (id == 1 ? name : afk);
      }
   }
}

