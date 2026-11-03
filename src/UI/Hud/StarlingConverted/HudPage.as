package UI.Hud.StarlingConverted
{
   import Brain.Starling.SwfConverter.BakeBudget;
   import Brain.Starling.SwfConverter.BakedPicture;
   import Brain.Starling.SwfConverter.ShelfPacker;
   import flash.display.BitmapData;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import starling.core.Starling;
   import starling.textures.Texture;
   import starling.utils.MathUtil;
   
   internal class HudPage
   {
      
      private static const POOL:String = "hudStarling";
      
      private static const sRect:Rectangle = new Rectangle();
      
      private static const sPoint:Point = new Point();
      
      internal var mTexture:Texture;
      
      internal var mPixels:BitmapData;
      
      internal var mSingle:Boolean;
      
      internal var mDirty:Boolean = false;
      
      internal var mCells:int = 0;
      
      internal var mWidth:int;
      
      internal var mHeight:int;
      
      internal var mRectangle:Boolean = true;
      
      private var mPacker:ShelfPacker;
      
      public function HudPage()
      {
         super();
      }
      
      internal static function create(width:int, height:int, single:Boolean) : HudPage
      {
         HudPages.sCapacityRefused = false;
         var _loc4_:Starling = Starling.current;
         if(_loc4_ == null || !_loc4_.contextValid)
         {
            return null;
         }
         var _loc5_:Boolean = _loc4_.profile != "baselineConstrained";
         if(!_loc5_)
         {
            width = MathUtil.getNextPowerOfTwo(width);
            height = MathUtil.getNextPowerOfTwo(height);
         }
         if(!BakeBudget.reserve("hudStarling",width,height,true,_loc5_))
         {
            HudPages.sCapacityRefused = true;
            return null;
         }
         var _loc6_:HudPage = new HudPage();
         _loc6_.mWidth = width;
         _loc6_.mHeight = height;
         _loc6_.mSingle = single;
         _loc6_.mRectangle = _loc5_;
         _loc6_.mPacker = new ShelfPacker(width,height);
         try
         {
            _loc6_.mTexture = Texture.empty(width,height,true,false,false,1);
            _loc6_.mTexture.root.onRestore = _loc6_.restorePixels;
            _loc6_.mPixels = new BitmapData(width,height,true,0);
            _loc6_.mDirty = true;
         }
         catch(error:Error)
         {
            if(_loc6_.mTexture != null)
            {
               _loc6_.mTexture.dispose();
            }
            if(_loc6_.mPixels != null)
            {
               _loc6_.mPixels.dispose();
            }
            BakeBudget.unreserve("hudStarling",width,height,_loc5_);
            StarlingHud.reportError(error);
            return null;
         }
         return _loc6_;
      }
      
      internal function place(w:int, h:int, out:Point) : Boolean
      {
         if(w > mWidth || h > mHeight)
         {
            return false;
         }
         if(mSingle)
         {
            if(mCells > 0)
            {
               return false;
            }
            out.setTo(0,0);
            return true;
         }
         return mPacker.place(w,h,out);
      }
      
      internal function free(x:int, y:int, w:int) : void
      {
         if(mSingle)
         {
            return;
         }
         mPacker.free(x,y,w);
      }
      
      internal function write(bake:BakedPicture, x:int, y:int, slotWidth:int, slotHeight:int) : void
      {
         sRect.setTo(x,y,slotWidth + 1,slotHeight + 1);
         mPixels.fillRect(sRect,0);
         sPoint.setTo(x,y);
         mPixels.copyPixels(bake.bitmap,bake.bitmap.rect,sPoint);
         mDirty = true;
         if(Starling.current != null)
         {
            Starling.current.setRequiresRedraw();
         }
      }
      
      internal function upload() : Boolean
      {
         if(!mDirty || mTexture == null)
         {
            return false;
         }
         mTexture.root.uploadBitmapData(mPixels);
         mDirty = false;
         return true;
      }
      
      private function restorePixels() : void
      {
         try
         {
            mTexture.root.uploadBitmapData(mPixels);
            mDirty = false;
         }
         catch(error:Error)
         {
            mDirty = true;
            StarlingHud.reportError(error);
         }
      }
      
      internal function dispose() : void
      {
         if(mTexture == null)
         {
            return;
         }
         mTexture.dispose();
         mTexture = null;
         mPixels.dispose();
         mPixels = null;
         BakeBudget.unreserve("hudStarling",mWidth,mHeight,mRectangle);
      }
   }
}

