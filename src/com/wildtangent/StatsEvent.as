package com.wildtangent
{
   import flash.events.Event;
   
   public class StatsEvent extends Event
   {
      
      public static const STATS_COMPLETE:String = "statsLoaded";
      
      public var StatsData:Object;
      
      public function StatsEvent(param1:String, param2:Object)
      {
         super(param1);
         StatsData = param2;
      }
   }
}

