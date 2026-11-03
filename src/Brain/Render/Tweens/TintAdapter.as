package Brain.Render.Tweens
{
   import flash.display.DisplayObject;
   import flash.geom.ColorTransform;
   
   internal class TintAdapter
   {
      
      private var mTarget:DisplayObject;
      
      private var mTint:uint;
      
      private var mRemove:Boolean;
      
      private var mStart:ColorTransform;
      
      private var mEnd:ColorTransform;
      
      private var mProgress:Number = 0;
      
      public function TintAdapter(target:DisplayObject, tint:uint, remove:Boolean)
      {
         super();
         mTarget = target;
         mTint = tint;
         mRemove = remove;
      }
      
      private static function lerp(from:Number, to:Number, ratio:Number) : Number
      {
         return from + (to - from) * ratio;
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
         mTarget.transform.colorTransform = new ColorTransform(lerp(mStart.redMultiplier,mEnd.redMultiplier,value),lerp(mStart.greenMultiplier,mEnd.greenMultiplier,value),lerp(mStart.blueMultiplier,mEnd.blueMultiplier,value),mStart.alphaMultiplier,lerp(mStart.redOffset,mEnd.redOffset,value),lerp(mStart.greenOffset,mEnd.greenOffset,value),lerp(mStart.blueOffset,mEnd.blueOffset,value),mStart.alphaOffset);
      }
      
      public function revert() : void
      {
         if(mTarget != null && mStart != null)
         {
            mTarget.transform.colorTransform = mStart;
         }
      }
      
      private function capture() : void
      {
         mStart = mTarget.transform.colorTransform;
         mEnd = new ColorTransform();
         if(!mRemove)
         {
            mEnd.color = mTint;
         }
         mEnd.alphaMultiplier = mStart.alphaMultiplier;
         mEnd.alphaOffset = mStart.alphaOffset;
      }
   }
}

