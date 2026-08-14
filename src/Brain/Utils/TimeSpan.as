package Brain.Utils
{
   public class TimeSpan
   {
      
      public static const MILLISECONDS_IN_DAY:Number = 86400000;
      
      public static const MILLISECONDS_IN_HOUR:Number = 3600000;
      
      public static const MILLISECONDS_IN_MINUTE:Number = 60000;
      
      public static const MILLISECONDS_IN_SECOND:Number = 1000;
      
      private var _totalMilliseconds:Number;
      
      public function TimeSpan(milliseconds:Number)
      {
         super();
         _totalMilliseconds = Math.floor(milliseconds);
      }
      
      public static function fromDates(start:Date, end:Date) : TimeSpan
      {
         return new TimeSpan(end.time - start.time);
      }
      
      public static function fromMilliseconds(milliseconds:Number) : TimeSpan
      {
         return new TimeSpan(milliseconds);
      }
      
      public static function fromSeconds(seconds:Number) : TimeSpan
      {
         return new TimeSpan(seconds * 1000);
      }
      
      public static function fromMinutes(minutes:Number) : TimeSpan
      {
         return new TimeSpan(minutes * 60000);
      }
      
      public static function fromHours(hours:Number) : TimeSpan
      {
         return new TimeSpan(hours * 3600000);
      }
      
      public static function fromDays(days:Number) : TimeSpan
      {
         return new TimeSpan(days * 86400000);
      }
      
      public function get days() : int
      {
         return int(_totalMilliseconds / 86400000);
      }
      
      public function get hours() : int
      {
         return int(_totalMilliseconds / 3600000) % 24;
      }
      
      public function get minutes() : int
      {
         return int(_totalMilliseconds / 60000) % 60;
      }
      
      public function get seconds() : int
      {
         return int(_totalMilliseconds / 1000) % 60;
      }
      
      public function get milliseconds() : int
      {
         return int(_totalMilliseconds) % 1000;
      }
      
      public function get totalDays() : Number
      {
         return _totalMilliseconds / 86400000;
      }
      
      public function get totalHours() : Number
      {
         return _totalMilliseconds / 3600000;
      }
      
      public function get totalMinutes() : Number
      {
         return _totalMilliseconds / 60000;
      }
      
      public function get totalSeconds() : Number
      {
         return _totalMilliseconds / 1000;
      }
      
      public function get totalMilliseconds() : Number
      {
         return _totalMilliseconds;
      }
      
      public function getTimeBetweenTimeSpanAndNow(countdownTimer:Boolean = false) : String
      {
         var _loc5_:Date = new Date();
         var _loc6_:TimeSpan = new TimeSpan(this.totalMilliseconds - _loc5_.time);
         var _loc2_:String = Math.abs(_loc6_.hours).toString();
         if(_loc2_.length == 1)
         {
            _loc2_ = "0" + _loc2_;
         }
         var _loc4_:String = Math.abs(_loc6_.minutes).toString();
         if(_loc4_.length == 1)
         {
            _loc4_ = "0" + _loc4_;
         }
         var _loc3_:String = Math.abs(_loc6_.seconds).toString();
         if(_loc3_.length == 1)
         {
            _loc3_ = "0" + _loc3_;
         }
         if(countdownTimer && _loc6_.totalMilliseconds < 0)
         {
            return "00:00:00";
         }
         return _loc2_ + ":" + _loc4_ + ":" + _loc3_;
      }
      
      public function add(date:Date) : Date
      {
         var _loc2_:Date = new Date(date.time);
         _loc2_.milliseconds += totalMilliseconds;
         return _loc2_;
      }
   }
}

