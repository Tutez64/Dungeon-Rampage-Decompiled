package Brain.Render.Tweens
{
   public class Sine
   {
      
      private static const HALF_PI:Number = 1.5707963267948966;
      
      public static function easeIn(param1:Number):Number
      {
         return 1 - Math.cos(param1 * 1.5707963267948966);
      }
      public static function easeOut(param1:Number):Number
      {
         return Math.sin(param1 * 1.5707963267948966);
      }
      public static function easeInOut(param1:Number):Number
      {
         return -0.5 * (Math.cos(3.141592653589793 * param1) - 1);
      }
      public function Sine()
      {
         super();
      }
   }
}

