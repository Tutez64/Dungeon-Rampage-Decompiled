package Starling
{
   import starling.extensions.animate.styles.ColorTransformStyle;
   
   public class StatusTintFilter
   {
      
      private var mMatrix:Vector.<Number>;
      
      private var mActive:Boolean = false;
      
      public function StatusTintFilter()
      {
         super();
      }
      
      public function get matrix() : Vector.<Number>
      {
         return mActive ? mMatrix : null;
      }
      
      public function get active() : Boolean
      {
         return mActive;
      }
      
      public function set(color:uint, amount:Number) : void
      {
         if(amount <= 0)
         {
            mActive = false;
            return;
         }
         mMatrix = ColorTransformStyle.tintMatrix(color,amount,mMatrix);
         mActive = true;
      }
      
      public function clear() : void
      {
         mActive = false;
      }
      
      public function dispose() : void
      {
         mMatrix = null;
         mActive = false;
      }
   }
}

