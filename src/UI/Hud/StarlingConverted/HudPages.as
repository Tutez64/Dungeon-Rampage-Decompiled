package UI.Hud.StarlingConverted
{
   import Brain.Starling.SwfConverter.BakeBudget;
   import Brain.Starling.SwfConverter.BakedCell;
   import Brain.Starling.SwfConverter.BakedPages;
   import Brain.Starling.SwfConverter.BakedPicture;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import starling.core.Starling;
   import starling.textures.SubTexture;
   
   internal class HudPages extends BakedPages
   {
      
      internal static var sCapacityRefused:Boolean = false;
      
      internal var mPinBakes:Boolean = false;
      
      private var mCells:Object = {};
      
      private var mPages:Vector.<HudPage> = new Vector.<HudPage>(0);
      
      private var mPoint:Point = new Point();
      
      private var mRegion:Rectangle = new Rectangle();
      
      public function HudPages(frames:Boolean = false)
      {
         super("hudStarling",frames ? 512 : 1024,frames ? 512 : 1024);
      }
      
      public function get accountedBytes() : Number
      {
         var _loc2_:HudPage = null;
         var _loc1_:Number = 0;
         for each(_loc2_ in mPages)
         {
            _loc1_ += BakeBudget.accountedBytes(_loc2_.mWidth,_loc2_.mHeight,_loc2_.mRectangle);
         }
         return _loc1_;
      }
      
      internal function get pinnedBytes() : Number
      {
         var _loc2_:HudCell = null;
         var _loc1_:Number = 0;
         for each(_loc2_ in mCells)
         {
            if(_loc2_.mPinned)
            {
               _loc1_ += _loc2_.pixelWidth * _loc2_.pixelHeight * 4;
            }
         }
         return _loc1_;
      }
      
      override public function acquire(key:String) : BakedCell
      {
         var _loc2_:HudCell = mCells[key];
         if(_loc2_ != null)
         {
            _loc2_.mReferences++;
            if(mPinBakes)
            {
               _loc2_.mPinned = true;
            }
         }
         return _loc2_;
      }
      
      override public function add(key:String, bake:BakedPicture, force:Boolean = false) : BakedCell
      {
         var _loc4_:HudCell = acquire(key) as HudCell;
         if(_loc4_ != null)
         {
            bake.dispose();
            return _loc4_;
         }
         _loc4_ = new HudCell();
         _loc4_.mKey = key;
         _loc4_.mPinned = mPinBakes;
         try
         {
            StarlingRaster.limit(bake);
            if(!place(_loc4_,bake))
            {
               return null;
            }
            mCells[key] = _loc4_;
            return _loc4_;
         }
         finally
         {
            bake.dispose();
         }
         return null;
      }
      
      private function place(cell:HudCell, bake:BakedPicture) : Boolean
      {
         var _loc6_:HudPage = null;
         var _loc4_:HudPage = null;
         sCapacityRefused = false;
         if(Starling.current == null || !Starling.current.contextValid)
         {
            return false;
         }
         var _loc5_:int = bake.bitmap.width;
         var _loc7_:int = bake.bitmap.height;
         var _loc3_:Boolean = _loc5_ + 1 > pageWidth || _loc7_ + 1 > pageHeight;
         HudArt.beginEviction();
         while(true)
         {
            if(!_loc3_)
            {
               for each(_loc4_ in mPages)
               {
                  if(!_loc4_.mSingle && _loc4_.place(_loc5_ + 1,_loc7_ + 1,mPoint))
                  {
                     _loc6_ = _loc4_;
                     break;
                  }
               }
            }
            if(_loc6_ == null)
            {
               _loc6_ = HudPage.create(_loc3_ ? _loc5_ : pageWidth,_loc3_ ? _loc7_ : pageHeight,_loc3_);
               if(_loc6_ != null)
               {
                  _loc6_.place(_loc3_ ? _loc5_ : _loc5_ + 1,_loc3_ ? _loc7_ : _loc7_ + 1,mPoint);
                  mPages.push(_loc6_);
               }
            }
            if(_loc6_ != null)
            {
               break;
            }
            if(!sCapacityRefused)
            {
               return false;
            }
            if(!HudArt.evictContent())
            {
               return false;
            }
         }
         cell.mPage = _loc6_;
         cell.mX = mPoint.x;
         cell.mY = mPoint.y;
         cell.mSlotWidth = _loc5_;
         cell.mSlotHeight = _loc7_;
         _loc6_.mCells++;
         try
         {
            _loc6_.write(bake,cell.mX,cell.mY,_loc5_,_loc7_);
            mRegion.setTo(cell.mX,cell.mY,_loc5_,_loc7_);
            cell.mTexture = new SubTexture(_loc6_.mTexture,mRegion,false,null,false,bake.pixelScale);
            cell.mBake = bake;
         }
         catch(error:Error)
         {
            free(_loc6_,cell.mX,cell.mY,_loc5_);
            throw error;
         }
         return true;
      }
      
      override public function release(value:BakedCell) : void
      {
         var _loc2_:HudCell = value as HudCell;
         if(_loc2_ == null || mCells[_loc2_.key] != _loc2_ || _loc2_.mReferences <= 0)
         {
            return;
         }
         if(--_loc2_.mReferences > 0 || _loc2_.mPinned)
         {
            return;
         }
         delete mCells[_loc2_.key];
         _loc2_.mTexture.dispose();
         _loc2_.mTexture = null;
         free(_loc2_.mPage,_loc2_.mX,_loc2_.mY,_loc2_.mSlotWidth);
         _loc2_.mPage = null;
      }
      
      private function free(page:HudPage, x:int, y:int, width:int) : void
      {
         page.mCells--;
         page.free(x,y,width + 1);
         if(page.mCells == 0)
         {
            mPages.removeAt(mPages.indexOf(page));
            page.dispose();
         }
      }
      
      override public function uploadDirty() : void
      {
         var _loc1_:HudPage = null;
         for each(_loc1_ in mPages)
         {
            try
            {
               _loc1_.upload();
            }
            catch(error:Error)
            {
               StarlingHud.reportError(error);
            }
         }
      }
      
      override public function dispose() : void
      {
         var _loc2_:HudCell = null;
         var _loc1_:HudPage = null;
         for each(_loc2_ in mCells)
         {
            _loc2_.mTexture.dispose();
            _loc2_.mTexture = null;
         }
         for each(_loc1_ in mPages)
         {
            _loc1_.dispose();
         }
         mPages.length = 0;
         mCells = {};
         super.dispose();
      }
   }
}

