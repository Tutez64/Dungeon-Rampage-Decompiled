package Brain.Starling.SwfConverter
{
   import starling.textures.Texture;
   
   public class BakedCell
   {
      
      internal var mKey:String;
      
      internal var mPage:BakedPage;
      
      internal var mTexture:Texture;
      
      internal var mRefCount:int = 0;
      
      internal var mPixelScale:Number = 1;
      
      internal var mOriginX:int;
      
      internal var mOriginY:int;
      
      internal var mEmpty:Boolean;
      
      internal var mSlotX:int;
      
      internal var mSlotY:int;
      
      internal var mSlotWidth:int;
      
      internal var mWidth:int;
      
      internal var mHeight:int;
      
      public function BakedCell()
      {
         super();
      }
      
      public function get key() : String
      {
         return mKey;
      }
      
      public function get texture() : Texture
      {
         return mTexture;
      }
      
      public function get pivotX() : Number
      {
         return mOriginX / mPixelScale;
      }
      
      public function get pivotY() : Number
      {
         return mOriginY / mPixelScale;
      }
      
      public function get pixelScale() : Number
      {
         return mPixelScale;
      }
      
      public function get pixelWidth() : int
      {
         return mWidth;
      }
      
      public function get pixelHeight() : int
      {
         return mHeight;
      }
      
      public function get isEmpty() : Boolean
      {
         return mEmpty;
      }
      
      public function get refCount() : int
      {
         return mRefCount;
      }
      
      public function get alive() : Boolean
      {
         return mTexture != null;
      }
      
      public function opaqueAt(localX:Number, localY:Number, threshold:uint = 16) : Boolean
      {
         if(mTexture == null || mPage == null || mPage.pixels == null)
         {
            return false;
         }
         var _loc4_:int = Math.floor(localX * mPixelScale);
         var _loc5_:int = Math.floor(localY * mPixelScale);
         if(_loc4_ < 0 || _loc5_ < 0 || _loc4_ >= mWidth || _loc5_ >= mHeight)
         {
            return false;
         }
         return mPage.pixels.getPixel32(mSlotX + _loc4_,mSlotY + _loc5_) >>> 24 > threshold;
      }
   }
}

