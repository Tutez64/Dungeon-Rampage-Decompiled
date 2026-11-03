package Brain.Utils
{
   import flash.utils.Timer;
   
   public class Timers
   {
      
      public function Timers()
      {
         super();
      }
      
      public static function create(delay:Number, repeatCount:int = 0, label:String = null) : Timer
      {
         return new Timer(delay,repeatCount);
      }
   }
}

