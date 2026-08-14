package Account
{
   public class PlayerSpecialStatus
   {
      
      public function PlayerSpecialStatus()
      {
         super();
      }
      
      public static function getSpecialTextColor(playerName:String, defaultColor:uint) : uint
      {
         if(playerName.charAt(0) == "★")
         {
            return 380536;
         }
         if(playerName.charAt(0) == "⚡")
         {
            return 16738339;
         }
         if(playerName.charAt(0) == "⚠")
         {
            return defaultColor;
         }
         return defaultColor;
      }
   }
}

