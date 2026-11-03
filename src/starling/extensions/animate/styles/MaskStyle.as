package starling.extensions.animate.styles
{
   import starling.rendering.MeshEffect;
   import starling.styles.MeshStyle;
   
   public class MaskStyle extends MeshStyle
   {
      
      public function MaskStyle()
      {
         super();
      }
      
      override public function createEffect() : MeshEffect
      {
         return new MaskEffect();
      }
   }
}

import flash.display3D.Context3D;
import starling.rendering.MeshEffect;
import starling.rendering.Program;

class MaskEffect extends MeshEffect
{
   
   private static const sThreshold:Vector.<Number> = new <Number>[0.5,0.5,0.5,0.5];
   
   public function MaskEffect()
   {
      super();
   }
   
   override protected function createProgram() : Program
   {
      if(texture == null)
      {
         return super.createProgram();
      }
      var _loc1_:String = "m44 op, va0, vc0 \nmov v0, va1      \nmul v1, va2, vc4 \n";
      var _loc2_:String = tex("ft0","v0",0,texture) + "sub ft1, ft0.wwww, fc0 \n" + "kil ft1.x              \n" + "mul oc, ft0, v1        \n";
      return Program.fromSource(_loc1_,_loc2_);
   }
   
   override protected function beforeDraw(context:Context3D) : void
   {
      super.beforeDraw(context);
      context.setProgramConstantsFromVector("fragment",0,sThreshold);
   }
}
