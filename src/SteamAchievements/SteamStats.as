package SteamAchievements
{
   public class SteamStats
   {
      
      public static const INT_STAT:int = 0;
      
      private var mAPIName:String;
      
      private var mStatType:int;
      
      private var mClientIntValue:int;
      
      private var mStoreStatsThreshold:int;
      
      private var mMaxValue:int;
      
      public function SteamStats(inAPIName:String, inType:int, inUpdateThreshold:int = 1, inMaxValue:int = 2000000000)
      {
         super();
         mAPIName = inAPIName;
         mStatType = inType;
         mStoreStatsThreshold = inUpdateThreshold;
         mMaxValue = inMaxValue;
      }
      
      public static function steamStatFactory(inAPIName:String, inSteamStatsType:int, inUpdateThreshold:int, inMaxValue:int = 2000000000) : SteamStats
      {
         return new SteamStats(inAPIName,inSteamStatsType,inUpdateThreshold,inMaxValue);
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
      
      public function setClientIntValue(inClientIntValue:Number) : void
      {
         if(inClientIntValue < 0 || inClientIntValue % 1 != 0)
         {
            return;
         }
         mClientIntValue = Math.min(mMaxValue,inClientIntValue);
      }
      
      public function increaseClientIntValue(inClientIntValue:Number) : void
      {
         if(inClientIntValue < 0 || inClientIntValue % 1 != 0)
         {
            return;
         }
         setClientIntValue(mClientIntValue + inClientIntValue);
      }
   }
}

