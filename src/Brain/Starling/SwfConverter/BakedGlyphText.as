package Brain.Starling.SwfConverter
{
   import starling.display.Image;
   import starling.display.MeshBatch;
   import starling.rendering.Painter;
   import starling.styles.MeshStyle;
   
   public class BakedGlyphText extends MeshBatch
   {
      
      private static var sScratch:Image;
      
      private var mFont:BakedGlyphFont;
      
      private var mColor:uint = 16777215;
      
      private var mCodes:Vector.<int> = new Vector.<int>(0);
      
      private var mCount:int = 0;
      
      private var mWidth:Number = 0;
      
      private var mDisposed:Boolean = false;
      
      public function BakedGlyphText(font:BakedGlyphFont)
      {
         super();
         mFont = font;
         batchable = true;
         touchable = false;
      }
      
      public function get font() : BakedGlyphFont
      {
         return mFont;
      }
      
      public function set font(value:BakedGlyphFont) : void
      {
         if(mDisposed)
         {
            return;
         }
         mFont = value;
         layout();
      }
      
      override public function get color() : uint
      {
         return mColor;
      }
      
      override public function set color(value:uint) : void
      {
         mColor = value;
         if(numVertices > 0)
         {
            super.color = value;
         }
      }
      
      public function get textWidth() : Number
      {
         return mWidth;
      }
      
      public function setText(text:String) : void
      {
         var _loc3_:int = 0;
         var _loc2_:int = int(text != null ? text.length : 0);
         if(mCodes.length < _loc2_)
         {
            mCodes.length = _loc2_;
         }
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            mCodes[_loc3_] = text.charCodeAt(_loc3_);
            _loc3_++;
         }
         mCount = _loc2_;
         layout();
      }
      
      override public function render(painter:Painter) : void
      {
         if(mFont == null || !mFont.alive)
         {
            return;
         }
         super.render(painter);
      }
      
      override public function dispose() : void
      {
         mDisposed = true;
         mFont = null;
         super.dispose();
      }
      
      private function layout() : void
      {
         var _loc2_:int = 0;
         var _loc5_:int = 0;
         if(mDisposed)
         {
            return;
         }
         clear();
         mWidth = 0;
         if(mFont == null || !mFont.alive)
         {
            return;
         }
         var _loc3_:Number = 0;
         _loc5_ = 0;
         while(_loc5_ < mCount)
         {
            _loc3_ += mFont.advance(mCodes[_loc5_]);
            _loc5_++;
         }
         mWidth = _loc3_;
         var _loc6_:Number = mFont.pixelScale;
         var _loc1_:Number = Math.round(2 * _loc6_) / _loc6_;
         var _loc4_:Number = -_loc1_;
         if(sScratch == null)
         {
            sScratch = new Image(null);
         }
         var _loc7_:Image = sScratch;
         if(_loc7_.style.type != style.type)
         {
            _loc7_.style = new style.type() as MeshStyle;
         }
         _loc5_ = 0;
         while(_loc5_ < mCount)
         {
            _loc2_ = mCodes[_loc5_];
            if(!mFont.hasGlyph(_loc2_))
            {
               _loc4_ += mFont.advance(_loc2_);
            }
            else
            {
               _loc7_.texture = mFont.glyphTexture(_loc2_);
               _loc7_.readjustSize();
               _loc7_.x = _loc4_ + mFont.glyphOffsetX(_loc2_);
               _loc7_.y = -_loc1_ + mFont.glyphOffsetY(_loc2_);
               addMesh(_loc7_);
               _loc4_ += mFont.advance(_loc2_);
            }
            _loc5_++;
         }
         if(mColor != 16777215 && numVertices > 0)
         {
            super.color = mColor;
         }
      }
   }
}

