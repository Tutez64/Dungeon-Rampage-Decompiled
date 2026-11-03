package Brain.Starling.SwfConverter
{
   import flash.geom.Point;
   
   public class ShelfPacker
   {
      
      private var mWidth:int;
      
      private var mHeight:int;
      
      private var mShelfY:Vector.<int> = new Vector.<int>(0);
      
      private var mShelfHeight:Vector.<int> = new Vector.<int>(0);
      
      private var mShelfFree:Vector.<Vector.<int>> = new Vector.<Vector.<int>>(0);
      
      private var mUsedHeight:int = 0;
      
      public function ShelfPacker(width:int, height:int)
      {
         super();
         mWidth = width;
         mHeight = height;
      }
      
      public function place(w:int, h:int, out:Point) : Boolean
      {
         var _loc5_:int = 0;
         if(w > mWidth || h > mHeight)
         {
            return false;
         }
         var _loc6_:int = findShelf(w,h,h + (h >> 1) + 4);
         if(_loc6_ < 0 && mUsedHeight + h <= mHeight)
         {
            _loc6_ = int(mShelfY.length);
            mShelfY.push(mUsedHeight);
            mShelfHeight.push(h);
            mShelfFree.push(new <int>[0,mWidth]);
            mUsedHeight += h;
         }
         if(_loc6_ < 0)
         {
            _loc6_ = findShelf(w,h,2147483647);
         }
         if(_loc6_ < 0)
         {
            return false;
         }
         var _loc4_:Vector.<int> = mShelfFree[_loc6_];
         _loc5_ = 0;
         while(_loc5_ < _loc4_.length)
         {
            if(_loc4_[_loc5_ + 1] >= w)
            {
               out.setTo(_loc4_[_loc5_],mShelfY[_loc6_]);
               _loc4_[_loc5_] += w;
               _loc4_[_loc5_ + 1] -= w;
               if(_loc4_[_loc5_ + 1] == 0)
               {
                  _loc4_.splice(_loc5_,2);
               }
               return true;
            }
            _loc5_ += 2;
         }
         return false;
      }
      
      public function free(x:int, y:int, w:int) : void
      {
         var _loc5_:Vector.<int> = undefined;
         var _loc7_:int = mShelfY.indexOf(y);
         if(_loc7_ < 0)
         {
            return;
         }
         var _loc4_:Vector.<int> = mShelfFree[_loc7_];
         var _loc6_:int = 0;
         while(_loc6_ < _loc4_.length && _loc4_[_loc6_] < x)
         {
            _loc6_ += 2;
         }
         _loc4_.splice(_loc6_,0,x,w);
         if(_loc6_ + 2 < _loc4_.length && _loc4_[_loc6_] + _loc4_[_loc6_ + 1] == _loc4_[_loc6_ + 2])
         {
            var _loc8_:Number = _loc6_ + 1;
            var _loc9_:Number = _loc4_[_loc8_] + _loc4_[_loc6_ + 3];
            _loc4_[_loc8_] = _loc9_;
            _loc4_.splice(_loc6_ + 2,2);
         }
         if(_loc6_ >= 2 && _loc4_[_loc6_ - 2] + _loc4_[_loc6_ - 1] == _loc4_[_loc6_])
         {
            _loc9_ = _loc6_ - 1;
            _loc8_ = _loc4_[_loc9_] + _loc4_[_loc6_ + 1];
            _loc4_[_loc9_] = _loc8_;
            _loc4_.splice(_loc6_,2);
         }
         while(mShelfY.length > 0)
         {
            _loc5_ = mShelfFree[mShelfFree.length - 1];
            if(_loc5_.length != 2 || _loc5_[0] != 0 || _loc5_[1] != mWidth)
            {
               break;
            }
            mUsedHeight -= mShelfHeight.pop();
            mShelfY.pop();
            mShelfFree.pop();
         }
      }
      
      private function findShelf(w:int, h:int, maxHeight:int) : int
      {
         var _loc5_:int = 0;
         var _loc7_:int = 0;
         var _loc4_:Vector.<int> = undefined;
         var _loc6_:int = 0;
         _loc5_ = 0;
         while(_loc5_ < mShelfY.length)
         {
            _loc7_ = mShelfHeight[_loc5_];
            if(!(_loc7_ < h || _loc7_ > maxHeight))
            {
               _loc4_ = mShelfFree[_loc5_];
               _loc6_ = 1;
               while(_loc6_ < _loc4_.length)
               {
                  if(_loc4_[_loc6_] >= w)
                  {
                     return _loc5_;
                  }
                  _loc6_ += 2;
               }
            }
            _loc5_++;
         }
         return -1;
      }
   }
}

