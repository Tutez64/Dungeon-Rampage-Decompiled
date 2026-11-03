package Brain.Render.Tweens
{
   import flash.display.DisplayObject;
   import flash.filters.BitmapFilter;
   import flash.filters.GlowFilter;
   
   internal class GlowFilterAdapter
   {
      
      private var mTarget:DisplayObject;
      
      private var mProps:Object;
      
      private var mRemove:Boolean;
      
      private var mStart:GlowFilter;
      
      private var mEnd:GlowFilter;
      
      private var mProgress:Number = 0;
      
      private var mOriginalFilter:GlowFilter = null;
      
      public function GlowFilterAdapter(target:DisplayObject, props:Object)
      {
         super();
         mTarget = target;
         mProps = props || {};
         mRemove = mProps.remove == true;
         var _loc3_:GlowFilter = findExisting();
         mOriginalFilter = _loc3_ ? _loc3_.clone() as GlowFilter : null;
      }
      
      private static function lerp(from:Number, to:Number, ratio:Number) : Number
      {
         return from + (to - from) * ratio;
      }
      
      private static function lerpColor(from:uint, to:uint, ratio:Number) : uint
      {
         var _loc4_:int = lerp(from >> 16 & 0xFF,to >> 16 & 0xFF,ratio);
         var _loc6_:int = lerp(from >> 8 & 0xFF,to >> 8 & 0xFF,ratio);
         var _loc5_:int = lerp(from & 0xFF,to & 0xFF,ratio);
         return clampChannel(_loc4_) << 16 | clampChannel(_loc6_) << 8 | clampChannel(_loc5_);
      }
      
      private static function clampChannel(value:int) : uint
      {
         return value < 0 ? 0 : (value > 255 ? 255 : value);
      }
      
      public function get progress() : Number
      {
         return mProgress;
      }
      
      public function set progress(value:Number) : void
      {
         mProgress = value;
         if(mStart == null)
         {
            capture();
         }
         var _loc2_:GlowFilter = new GlowFilter(lerpColor(mStart.color,mEnd.color,value),lerp(mStart.alpha,mEnd.alpha,value),lerp(mStart.blurX,mEnd.blurX,value),lerp(mStart.blurY,mEnd.blurY,value),lerp(mStart.strength,mEnd.strength,value),mEnd.quality,mEnd.inner,mEnd.knockout);
         applyFilter(_loc2_);
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
         var _loc1_:GlowFilter = findExisting();
         if(_loc1_)
         {
            mStart = _loc1_.clone() as GlowFilter;
         }
         else
         {
            mStart = new GlowFilter(16777215,0,0,0,"strength" in mProps ? Number(mProps.strength) : 1,"quality" in mProps ? int(mProps.quality) : 2,mProps.inner == true,mProps.knockout == true);
         }
         mEnd = mStart.clone() as GlowFilter;
         if("color" in mProps)
         {
            mEnd.color = Number(mProps.color);
         }
         if("alpha" in mProps)
         {
            mEnd.alpha = Number(mProps.alpha);
         }
         if("blurX" in mProps)
         {
            mEnd.blurX = Number(mProps.blurX);
         }
         if("blurY" in mProps)
         {
            mEnd.blurY = Number(mProps.blurY);
         }
         if("strength" in mProps)
         {
            mEnd.strength = Number(mProps.strength);
         }
         if("quality" in mProps)
         {
            mEnd.quality = int(mProps.quality);
         }
         if("inner" in mProps)
         {
            mEnd.inner = mProps.inner == true;
         }
         if("knockout" in mProps)
         {
            mEnd.knockout = mProps.knockout == true;
         }
      }
      
      private function findExisting() : GlowFilter
      {
         var _loc2_:Array = mTarget.filters;
         if(_loc2_)
         {
            for each(var _loc1_:BitmapFilter in _loc2_)
            {
               if(_loc1_ is GlowFilter)
               {
                  return GlowFilter(_loc1_);
               }
            }
         }
         return null;
      }
      
      private function applyFilter(filter:GlowFilter) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Array = mTarget.filters || [];
         var _loc2_:Boolean = false;
         _loc3_ = 0;
         while(_loc3_ < _loc4_.length)
         {
            if(_loc4_[_loc3_] is GlowFilter)
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
            if(!(_loc1_ is GlowFilter))
            {
               _loc3_.push(_loc1_);
            }
         }
         mTarget.filters = _loc3_;
      }
   }
}

