package Brain.Render.Tweens
{
   import Brain.Logger.Logger;
   import flash.display.DisplayObject;
   import flash.filters.BitmapFilter;
   import flash.filters.ColorMatrixFilter;
   
   internal class ColorMatrixFilterAdapter
   {
      
      private static const LUM_R:Number = 0.212671;
      
      private static const LUM_G:Number = 0.71516;
      
      private static const LUM_B:Number = 0.072169;
      
      private static const IDENTITY:Array = [1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0];
      
      private var mTarget:DisplayObject;
      
      private var mFromProps:Object;
      
      private var mToProps:Object;
      
      private var mRemove:Boolean;
      
      private var mStart:Array;
      
      private var mEnd:Array;
      
      private var mProgress:Number = 0;
      
      private var mOriginalFilter:ColorMatrixFilter = null;
      
      public function ColorMatrixFilterAdapter(target:DisplayObject, fromProps:Object, toProps:Object)
      {
         super();
         mTarget = target;
         mFromProps = fromProps;
         mToProps = toProps || {};
         mRemove = mToProps.remove == true;
         var _loc4_:ColorMatrixFilter = findExisting();
         mOriginalFilter = _loc4_ ? _loc4_.clone() as ColorMatrixFilter : null;
      }
      
      private static function buildMatrix(base:Array, props:Object) : Array
      {
         var _loc3_:Number = NaN;
         var _loc4_:Array = props.matrix is Array ? (props.matrix as Array).concat() : base.concat();
         if("colorize" in props)
         {
            _loc3_ = "amount" in props ? Number(props.amount) : 1;
            _loc4_ = colorize(_loc4_,uint(props.colorize),_loc3_);
         }
         for(var _loc5_:String in props)
         {
            if(_loc5_ != "matrix" && _loc5_ != "colorize" && _loc5_ != "amount" && _loc5_ != "remove")
            {
               Logger.warn("ColorMatrixFilterAdapter: unsupported colorMatrixFilter property \'" + _loc5_ + "\' ignored");
            }
         }
         return _loc4_;
      }
      
      private static function colorize(matrix:Array, color:uint, amount:Number) : Array
      {
         var _loc5_:Number = (color >> 16 & 0xFF) / 255;
         var _loc7_:Number = (color >> 8 & 0xFF) / 255;
         var _loc6_:Number = (color & 0xFF) / 255;
         var _loc4_:Number = 1 - amount;
         var _loc8_:Array = [_loc4_ + amount * _loc5_ * 0.212671,amount * _loc5_ * 0.71516,amount * _loc5_ * 0.072169,0,0,amount * _loc7_ * 0.212671,_loc4_ + amount * _loc7_ * 0.71516,amount * _loc7_ * 0.072169,0,0,amount * _loc6_ * 0.212671,amount * _loc6_ * 0.71516,_loc4_ + amount * _loc6_ * 0.072169,0,0,0,0,0,1,0];
         return multiply(_loc8_,matrix);
      }
      
      private static function multiply(a:Array, b:Array) : Array
      {
         var _loc7_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:Number = NaN;
         var _loc3_:Array = new Array(20);
         var _loc6_:int = 0;
         _loc7_ = 0;
         while(_loc7_ < 4)
         {
            _loc4_ = 0;
            while(_loc4_ < 5)
            {
               _loc5_ = Number(_loc4_ == 4 ? a[_loc6_ + 4] : 0);
               _loc3_[_loc6_ + _loc4_] = a[_loc6_] * b[_loc4_] + a[_loc6_ + 1] * b[_loc4_ + 5] + a[_loc6_ + 2] * b[_loc4_ + 10] + a[_loc6_ + 3] * b[_loc4_ + 15] + _loc5_;
               _loc4_++;
            }
            _loc6_ += 5;
            _loc7_++;
         }
         return _loc3_;
      }
      
      public function get progress() : Number
      {
         return mProgress;
      }
      
      public function set progress(value:Number) : void
      {
         var _loc2_:int = 0;
         mProgress = value;
         if(mStart == null)
         {
            capture();
         }
         var _loc3_:Array = new Array(20);
         _loc2_ = 0;
         while(_loc2_ < 20)
         {
            _loc3_[_loc2_] = mStart[_loc2_] + (mEnd[_loc2_] - mStart[_loc2_]) * value;
            _loc2_++;
         }
         applyFilter(new ColorMatrixFilter(_loc3_));
      }
      
      public function finish() : void
      {
         if(mRemove)
         {
            removeFilter();
         }
      }
      
      public function revert() : void
      {
         if(mTarget == null)
         {
            return;
         }
         if(mOriginalFilter != null)
         {
            applyFilter(mOriginalFilter);
         }
         else
         {
            removeFilter();
         }
      }
      
      private function capture() : void
      {
         var _loc1_:ColorMatrixFilter = findExisting();
         var _loc2_:Array = _loc1_ ? _loc1_.matrix : IDENTITY.concat();
         mStart = mFromProps ? buildMatrix(_loc2_,mFromProps) : _loc2_;
         mEnd = buildMatrix(_loc2_,mToProps);
      }
      
      private function findExisting() : ColorMatrixFilter
      {
         var _loc2_:Array = mTarget.filters;
         if(_loc2_)
         {
            for each(var _loc1_:BitmapFilter in _loc2_)
            {
               if(_loc1_ is ColorMatrixFilter)
               {
                  return ColorMatrixFilter(_loc1_);
               }
            }
         }
         return null;
      }
      
      private function applyFilter(filter:ColorMatrixFilter) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Array = mTarget.filters || [];
         var _loc2_:Boolean = false;
         _loc3_ = 0;
         while(_loc3_ < _loc4_.length)
         {
            if(_loc4_[_loc3_] is ColorMatrixFilter)
            {
               _loc4_[_loc3_] = filter;
               _loc2_ = true;
               break;
            }
            _loc3_++;
         }
         if(!_loc2_)
         {
            _loc4_.push(filter);
         }
         mTarget.filters = _loc4_;
      }
      
      private function removeFilter() : void
      {
         var _loc2_:Array = mTarget.filters;
         if(!_loc2_)
         {
            return;
         }
         var _loc3_:Array = [];
         for each(var _loc1_:BitmapFilter in _loc2_)
         {
            if(!(_loc1_ is ColorMatrixFilter))
            {
               _loc3_.push(_loc1_);
            }
         }
         mTarget.filters = _loc3_;
      }
   }
}

