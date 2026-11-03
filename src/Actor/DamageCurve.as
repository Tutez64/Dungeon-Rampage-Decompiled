package Actor
{
   public class DamageCurve
   {
      
      public function DamageCurve()
      {
         super();
      }
      
      public static function npcHealthCurve(level:uint) : Number
      {
         return Math.pow(level,1.5);
      }
      
      public static function heroAttackCurve(level:uint) : Number
      {
         return Math.pow(level,1.5) * 0.05;
      }
   }
}

