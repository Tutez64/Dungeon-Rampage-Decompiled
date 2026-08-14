package SteamAchievements
{
   public class SteamStats
   {
      
      public static const INT_STAT:int = 0;
      
      private var mAPIName:String;
      
      private var mStatType:int;
      
      private var mClientIntValue:int;
      
      private var mStoreStatsThreshold:int;
      
      public function SteamStats(inAPIName:String, inType:int, inUpdateThreshold:int = 1)
      {
         super();
         mAPIName = inAPIName;
         mStatType = inType;
         mStoreStatsThreshold = inUpdateThreshold;
      }
      
      public static function steamStatFactory(inAPIName:String, inSteamStatsType:int, inUpdateThreshold:int) : SteamStats
      {
         return new SteamStats(inAPIName,inSteamStatsType,inUpdateThreshold);
      }
      
      public function get APIName() : String
      {
         return mAPIName;
      }
      
      public function get StatType() : int
      {
         return mStatType;
      }
      
      public function get ClientIntValue() : int
      {
         return mClientIntValue;
      }
      
      public function get StoreStatsThreshold() : int
      {
         return mStoreStatsThreshold;
      }
      
      public function setClientIntValue(inClientIntValue:int) : void
      {
         mClientIntValue = inClientIntValue;
      }
      
      public function increaseClientIntValue(inClientIntValue:int) : void
      {
         mClientIntValue += inClientIntValue;
      }
   }
}

