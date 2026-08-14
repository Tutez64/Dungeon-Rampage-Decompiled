package SteamAchievements
{
   public class SteamAchievement
   {
      
      private var mAPIName:String;
      
      private var mIsAchieved:Boolean;
      
      public function SteamAchievement(inAPIName:String)
      {
         super();
         mAPIName = inAPIName;
         mIsAchieved = false;
      }
      
      public static function steamAchievementFactory(inAPIName:String) : SteamAchievement
      {
         return new SteamAchievement(inAPIName);
      }
      
      public function get APIName() : String
      {
         return mAPIName;
      }
      
      public function get IsAchieved() : Boolean
      {
         return mIsAchieved;
      }
      
      public function setIsAchieved(inAchieved:Boolean) : void
      {
         mIsAchieved = inAchieved;
      }
   }
}

