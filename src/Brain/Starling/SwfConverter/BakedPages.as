package Brain.Starling.SwfConverter
{
   import flash.display.DisplayObject;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import starling.core.Starling;
   import starling.events.Event;
   import starling.textures.SubTexture;
   
   public class BakedPages
   {
      
      private static var sAttached:Starling;
      
      private static var sRenders:int = 0;
      
      private static const sAll:Vector.<BakedPages> = new Vector.<BakedPages>(0);
      
      private static const sSlotPages:Vector.<BakedPage> = new Vector.<BakedPage>(0);
      
      private static const sSlotX:Vector.<int> = new Vector.<int>(0);
      
      private static const sSlotY:Vector.<int> = new Vector.<int>(0);
      
      private static const sSlotWidth:Vector.<int> = new Vector.<int>(0);
      
      private static const sSlotStamp:Vector.<int> = new Vector.<int>(0);
      
      private static const sRetired:Vector.<BakedPage> = new Vector.<BakedPage>(0);
      
      private static const sPoint:Point = new Point();
      
      private static const sRegion:Rectangle = new Rectangle();
      
      private var mPool:String;
      
      private var mPageWidth:int;
      
      private var mPageHeight:int;
      
      private var mCells:Object = {};
      
      private var mPages:Vector.<BakedPage> = new Vector.<BakedPage>(0);
      
      public function BakedPages(pool:String, pageWidth:int = 1024, pageHeight:int = 512)
      {
         super();
         mPool = pool;
         mPageWidth = pageWidth;
         mPageHeight = pageHeight;
         sAll.push(this);
      }
      
      public static function scaleKey(pixelScale:Number) : String
      {
         return String(Math.round(pixelScale * 1000) / 1000);
      }
      
      public static function attach(starling:Starling) : void
      {
         if(sAttached == starling)
         {
            return;
         }
         if(sAttached != null)
         {
            sAttached.removeEventListener("render",onRender);
         }
         sAttached = starling;
         if(starling != null)
         {
            starling.addEventListener("render",onRender);
         }
      }
      
      private static function onRender(event:Event) : void
      {
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         var _loc4_:BakedPage = null;
         _loc3_ = sRetired.length - 1;
         while(_loc3_ >= 0)
         {
            if(sRetired[_loc3_].retiredAt < sRenders)
            {
               sRetired[_loc3_].dispose();
               sRetired.removeAt(_loc3_);
            }
            _loc3_--;
         }
         _loc2_ = sSlotPages.length - 1;
         while(_loc2_ >= 0)
         {
            if(sSlotStamp[_loc2_] < sRenders)
            {
               _loc4_ = sSlotPages[_loc2_];
               if(_loc4_.texture != null && _loc4_.retiredAt < 0)
               {
                  _loc4_.free(sSlotX[_loc2_],sSlotY[_loc2_],sSlotWidth[_loc2_]);
               }
               sSlotPages.removeAt(_loc2_);
               sSlotX.removeAt(_loc2_);
               sSlotY.removeAt(_loc2_);
               sSlotWidth.removeAt(_loc2_);
               sSlotStamp.removeAt(_loc2_);
            }
            _loc2_--;
         }
         sRenders = sRenders + 1;
         uploadAll();
      }
      
      private static function retire(page:BakedPage) : void
      {
         page.retiredAt = sRenders;
         sRetired.push(page);
      }
      
      public static function uploadAll() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < sAll.length)
         {
            try
            {
               sAll[_loc1_].uploadDirty();
            }
            catch(error:Error)
            {
            }
            _loc1_++;
         }
      }
      
      public static function restoreAll() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < sAll.length)
         {
            for each(var _loc3_:BakedPage in sAll[_loc1_].mPages)
            {
               restorePage(_loc3_);
            }
            _loc1_++;
         }
         for each(var _loc2_:BakedPage in sRetired)
         {
            restorePage(_loc2_);
         }
      }
      
      private static function restorePage(page:BakedPage) : void
      {
         try
         {
            page.restore();
         }
         catch(error:Error)
         {
            page.dirty = true;
         }
      }
      
      public static function disposeAll() : void
      {
         while(sAll.length > 0)
         {
            sAll[sAll.length - 1].dispose();
         }
         flushRetired();
         attach(null);
      }
      
      private static function flushRetired() : void
      {
         while(sRetired.length > 0)
         {
            sRetired.pop().dispose();
         }
         sSlotPages.length = sSlotX.length = sSlotY.length = sSlotWidth.length = sSlotStamp.length = 0;
      }
      
      public function get pageWidth() : int
      {
         return mPageWidth;
      }
      
      public function get pageHeight() : int
      {
         return mPageHeight;
      }
      
      public function acquire(key:String) : BakedCell
      {
         var _loc2_:BakedCell = mCells[key];
         if(_loc2_ != null)
         {
            _loc2_.mRefCount++;
         }
         return _loc2_;
      }
      
      public function bake(key:String, source:DisplayObject, pixelScale:Number, hide:Vector.<DisplayObject> = null) : BakedCell
      {
         var _loc6_:BakedCell = acquire(key);
         if(_loc6_ != null)
         {
            return _loc6_;
         }
         var _loc5_:BakedPicture = FlashBaker.bake(source,pixelScale,hide);
         return _loc5_ != null ? add(key,_loc5_) : null;
      }
      
      public function add(key:String, bake:BakedPicture, force:Boolean = false) : BakedCell
      {
         var _loc4_:BakedCell = null;
         try
         {
            _loc4_ = acquire(key);
            if(_loc4_ != null)
            {
               return _loc4_;
            }
            _loc4_ = new BakedCell();
            _loc4_.mKey = key;
            if(!placeAndWrite(_loc4_,bake,force))
            {
               return null;
            }
            _loc4_.mRefCount = 1;
            mCells[key] = _loc4_;
            return _loc4_;
         }
         finally
         {
            bake.dispose();
         }
         return null;
      }
      
      public function release(cell:BakedCell) : void
      {
         if(cell == null || mCells[cell.mKey] != cell)
         {
            return;
         }
         if(--cell.mRefCount > 0)
         {
            return;
         }
         delete mCells[cell.mKey];
         cell.mTexture.dispose();
         cell.mTexture = null;
         freeSlot(cell.mPage,cell.mSlotX,cell.mSlotY,cell.mSlotWidth);
         cell.mPage = null;
      }
      
      public function uploadDirty() : void
      {
         for each(var _loc1_:BakedPage in mPages)
         {
            if(_loc1_.dirty)
            {
               _loc1_.upload();
            }
         }
      }
      
      public function dispose() : void
      {
         var _loc3_:BakedCell = null;
         for(var _loc4_:String in mCells)
         {
            _loc3_ = mCells[_loc4_];
            _loc3_.mTexture.dispose();
            _loc3_.mTexture = null;
            _loc3_.mPage = null;
            _loc3_.mRefCount = 0;
         }
         mCells = {};
         for each(var _loc2_:BakedPage in mPages)
         {
            retire(_loc2_);
         }
         mPages.length = 0;
         var _loc1_:int = sAll.indexOf(this);
         if(_loc1_ >= 0)
         {
            sAll.splice(_loc1_,1);
         }
      }
      
      private function placeAndWrite(cell:BakedCell, bake:BakedPicture, force:Boolean) : Boolean
      {
         var _loc5_:int = bake.bitmap.width;
         var _loc7_:int = bake.bitmap.height;
         var _loc6_:int = 1;
         var _loc9_:BakedPage = null;
         if(_loc5_ + _loc6_ <= mPageWidth && _loc7_ + _loc6_ <= mPageHeight)
         {
            for each(var _loc4_:BakedPage in mPages)
            {
               if(!_loc4_.single && _loc4_.place(_loc5_ + _loc6_,_loc7_ + _loc6_,sPoint))
               {
                  _loc9_ = _loc4_;
                  break;
               }
            }
            if(_loc9_ == null)
            {
               _loc9_ = BakedPage.create(mPool,mPageWidth,mPageHeight,false,force);
               if(_loc9_ == null || !_loc9_.place(_loc5_ + _loc6_,_loc7_ + _loc6_,sPoint))
               {
                  if(_loc9_ != null)
                  {
                     _loc9_.dispose();
                  }
                  return false;
               }
               mPages.push(_loc9_);
            }
         }
         else
         {
            _loc9_ = BakedPage.create(mPool,_loc5_,_loc7_,true,force);
            if(_loc9_ == null)
            {
               return false;
            }
            _loc9_.place(_loc5_,_loc7_,sPoint);
            mPages.push(_loc9_);
         }
         if(sAll.indexOf(this) < 0)
         {
            sAll.push(this);
         }
         cell.mPage = _loc9_;
         cell.mSlotX = sPoint.x;
         cell.mSlotY = sPoint.y;
         cell.mSlotWidth = _loc9_.single ? _loc9_.width : _loc5_;
         var _loc8_:int = _loc9_.single ? _loc9_.height : _loc7_;
         _loc9_.cells++;
         _loc9_.write(bake,cell.mSlotX,cell.mSlotY,cell.mSlotWidth,_loc8_);
         cell.mWidth = _loc5_;
         cell.mHeight = _loc7_;
         cell.mOriginX = bake.originX;
         cell.mOriginY = bake.originY;
         cell.mPixelScale = bake.pixelScale;
         cell.mEmpty = bake.empty;
         sRegion.setTo(cell.mSlotX,cell.mSlotY,cell.mSlotWidth,_loc8_);
         cell.mTexture = new SubTexture(_loc9_.texture,sRegion,false,null,false,bake.pixelScale);
         return true;
      }
      
      private function freeSlot(page:BakedPage, x:int, y:int, slotWidth:int) : void
      {
         var _loc7_:Boolean = false;
         page.cells--;
         if(!page.single)
         {
            sSlotPages.push(page);
            sSlotX.push(x);
            sSlotY.push(y);
            sSlotWidth.push(slotWidth + 1);
            sSlotStamp.push(sRenders);
         }
         if(page.cells > 0)
         {
            return;
         }
         if(!page.single)
         {
            _loc7_ = false;
            for each(var _loc5_:BakedPage in mPages)
            {
               if(_loc5_ != page && !_loc5_.single && _loc5_.cells == 0)
               {
                  _loc7_ = true;
               }
            }
            if(!_loc7_)
            {
               return;
            }
         }
         var _loc6_:int = mPages.indexOf(page);
         if(_loc6_ >= 0)
         {
            mPages.splice(_loc6_,1);
         }
         retire(page);
      }
   }
}

