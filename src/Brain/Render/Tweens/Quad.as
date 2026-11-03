package Brain.Render.Tweens
{
   public class Quad
   {
      
      public static function easeIn(param1:Number):Number
      {
         return param1 * param1;
      }
      public static function easeOut(param1:Number):Number
      {
         return -param1 * (param1 - 2);
      }
      public static function easeInOut(param1:Number):Number
      {
         param1 *= 2;
         if(param1 < 1)
         {
            return 0.5 * param1 * param1;
         }
         param1 -= 1;
         return -0.5 * (param1 * (param1 - 2) - 1);
      }
      public function Quad()
      {
         super();
      }
   }
}

