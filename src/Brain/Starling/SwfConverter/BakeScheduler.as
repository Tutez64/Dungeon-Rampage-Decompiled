package Brain.Starling.SwfConverter
{
   import flash.utils.getTimer;
   
   public class BakeScheduler
   {
      
      public static const FIGHT_QUIET_MS:int = 5000;
      
      public static var enabled:Boolean = false;
      
      private static var sLoading:Boolean = false;
      
      private static var sLastCombat:int = -2147483648;
      
      public function BakeScheduler()
      {
         super();
      }
      
      public static function floorLoadStarted() : void
      {
         if(enabled)
         {
            sLoading = true;
         }
      }
      
      public static function floorLoaded() : void
      {
         sLoading = false;
      }
      
      public static function floorPurged() : void
      {
         sLoading = false;
         sLastCombat = -2147483648;
      }
      
      public static function noteCombat() : void
      {
         if(enabled)
         {
            sLastCombat = getTimer();
         }
      }
      
      public static function get loading() : Boolean
      {
         return sLoading;
      }
      
      public static function get fighting() : Boolean
      {
         return sLastCombat != -2147483648 && getTimer() - sLastCombat < 5000;
      }
   }
}

