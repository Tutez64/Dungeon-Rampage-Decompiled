package UI.Hud.StarlingConverted
{
   import Brain.Starling.SwfConverter.BakedCell;
   import Brain.Starling.SwfConverter.BakedPicture;
   import starling.textures.Texture;
   
   internal class HudCell extends BakedCell
   {
      
      internal var mKey:String;
      
      internal var mPage:HudPage;
      
      internal var mTexture:Texture;
      
      internal var mReferences:int = 1;
      
      internal var mX:int;
      
      internal var mY:int;
      
      internal var mSlotWidth:int;
      
      internal var mSlotHeight:int;
      
      internal var mBake:BakedPicture;
      
      internal var mLiveViews:int = 0;
      
      internal var mPinned:Boolean = false;
      
      internal var mSource:HudCell;
      
      public function HudCell()
      {
         super();
      }
      
      override public function get key() : String
      {
         return mKey;
      }
      
      override public function get texture() : Texture
      {
         return mTexture;
      }
      
      override public function get pivotX() : Number
      {
         return mBake.originX / mBake.pixelScale;
      }
      
      override public function get pivotY() : Number
      {
         return mBake.originY / mBake.pixelScale;
      }
      
      override public function get pixelScale() : Number
      {
         return mBake.pixelScale;
      }
      
      override public function get pixelWidth() : int
      {
         return mSlotWidth;
      }
      
      override public function get pixelHeight() : int
      {
         return mSlotHeight;
      }
      
      override public function get isEmpty() : Boolean
      {
         return mBake.empty;
      }
      
      override public function get refCount() : int
      {
         return mReferences;
      }
      
      override public function get alive() : Boolean
      {
         return mTexture != null;
      }
      
      override public function opaqueAt(localX:Number, localY:Number, threshold:uint = 16) : Boolean
      {
         if(!alive)
         {
            return false;
         }
         var _loc4_:int = Math.floor(localX * pixelScale);
         var _loc5_:int = Math.floor(localY * pixelScale);
         if(_loc4_ < 0 || _loc5_ < 0 || _loc4_ >= mSlotWidth || _loc5_ >= mSlotHeight)
         {
            return false;
         }
         return mPage.mPixels.getPixel32(mX + _loc4_,mY + _loc5_) >>> 24 > threshold;
      }
   }
}

