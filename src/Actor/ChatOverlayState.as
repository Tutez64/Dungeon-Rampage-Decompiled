package Actor
{
   import flash.display.Sprite;
   import flash.filters.ColorMatrixFilter;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   
   internal class ChatOverlayState
   {
      
      public var frame:uint;
      
      private const mMatrix:Matrix = new Matrix();
      
      private const mColor:ColorTransform = new ColorTransform();
      
      private var mFilters:Array = [];
      
      private var mFirst:Boolean = true;
      
      public function ChatOverlayState()
      {
         super();
      }
      
      public function apply(content:Sprite, matrix:Matrix, color:ColorTransform, filters:Array) : void
      {
         if(mFirst || matrix.a != mMatrix.a || matrix.b != mMatrix.b || matrix.c != mMatrix.c || matrix.d != mMatrix.d || matrix.tx != mMatrix.tx || matrix.ty != mMatrix.ty)
         {
            content.transform.matrix = matrix;
            mMatrix.copyFrom(matrix);
         }
         if(mFirst || color.redMultiplier != mColor.redMultiplier || color.greenMultiplier != mColor.greenMultiplier || color.blueMultiplier != mColor.blueMultiplier || color.alphaMultiplier != mColor.alphaMultiplier || color.redOffset != mColor.redOffset || color.greenOffset != mColor.greenOffset || color.blueOffset != mColor.blueOffset || color.alphaOffset != mColor.alphaOffset)
         {
            content.transform.colorTransform = color;
            mColor.redMultiplier = color.redMultiplier;
            mColor.greenMultiplier = color.greenMultiplier;
            mColor.blueMultiplier = color.blueMultiplier;
            mColor.alphaMultiplier = color.alphaMultiplier;
            mColor.redOffset = color.redOffset;
            mColor.greenOffset = color.greenOffset;
            mColor.blueOffset = color.blueOffset;
            mColor.alphaOffset = color.alphaOffset;
         }
         if(mFirst || !sameFilters(filters))
         {
            content.filters = filters;
            mFilters = filters.concat();
         }
         mFirst = false;
      }
      
      private function sameFilters(filters:Array) : Boolean
      {
         var _loc5_:int = 0;
         var _loc2_:ColorMatrixFilter = null;
         var _loc3_:ColorMatrixFilter = null;
         var _loc4_:Array = null;
         var _loc6_:int = 0;
         if(filters.length != mFilters.length)
         {
            return false;
         }
         _loc5_ = 0;
         while(_loc5_ < filters.length)
         {
            if(filters[_loc5_] != mFilters[_loc5_])
            {
               _loc2_ = filters[_loc5_] as ColorMatrixFilter;
               _loc3_ = mFilters[_loc5_] as ColorMatrixFilter;
               if(_loc2_ == null || _loc3_ == null)
               {
                  return false;
               }
               _loc4_ = _loc2_.matrix;
               var _loc7_:Array = _loc3_.matrix;
               _loc6_ = 0;
               while(_loc6_ < _loc4_.length)
               {
                  if(_loc4_[_loc6_] != _loc7_[_loc6_])
                  {
                     return false;
                  }
                  _loc6_++;
               }
            }
            _loc5_++;
         }
         return true;
      }
   }
}

