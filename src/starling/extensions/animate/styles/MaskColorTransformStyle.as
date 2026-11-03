package starling.extensions.animate.styles
{
   public class MaskColorTransformStyle extends ColorTransformStyle
   {
      
      public function MaskColorTransformStyle(matrix:Vector.<Number> = null)
      {
         super(matrix);
         maskDiscard = true;
      }
   }
}

