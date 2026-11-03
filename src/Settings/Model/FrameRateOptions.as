package Settings.Model
{
   public class FrameRateOptions
   {
      
      public static const DEFAULT:Number = 60;
      
      public static const UNLIMITED:Number = 1000;
      
      private static const DIVISORS:Array = [2,3,4,5,6,8,10];
      
      private var mChoices:Vector.<SettingChoice> = new Vector.<SettingChoice>();
      
      public function FrameRateOptions()
      {
         super();
         remember(24);
         remember(30);
         remember(60);
         remember(1000);
      }
      
      public static function coerce(raw:*) : Number
      {
         if(!(raw is Number) && !(raw is String))
         {
            return 60;
         }
         var _loc2_:Number = raw;
         return isFinite(_loc2_) && _loc2_ >= 0.01 && _loc2_ <= 1000 ? _loc2_ : 60;
      }
      
      private static function compareRates(a:SettingChoice, b:SettingChoice) : Number
      {
         return Number(a.value) - Number(b.value);
      }
      
      public function get choices() : Vector.<SettingChoice>
      {
         return mChoices;
      }
      
      public function remember(value:Number) : Boolean
      {
         if(!isFinite(value) || value < 0.01 || value > 1000)
         {
            return false;
         }
         for each(var _loc2_:SettingChoice in mChoices)
         {
            if(_loc2_.value == value)
            {
               return false;
            }
         }
         mChoices.push(new SettingChoice(value,value == 1000 ? "SETTING_FPS_UNLIMITED" : null));
         mChoices.sort(compareRates);
         return true;
      }
      
      public function rememberMonitor(hz:Number) : Boolean
      {
         var _loc4_:Number = NaN;
         if(!isFinite(hz) || hz <= 0)
         {
            return false;
         }
         var _loc6_:Boolean = remember(hz);
         var _loc5_:Number = NaN;
         var _loc3_:Number = NaN;
         for each(var _loc2_:int in DIVISORS)
         {
            _loc4_ = hz / _loc2_;
            if(!(_loc4_ < 44 || _loc4_ > 93))
            {
               if(_loc4_ != 60 && (isNaN(_loc5_) || Math.abs(_loc4_ - 60) < Math.abs(_loc5_ - 60) || Math.abs(_loc4_ - 60) == Math.abs(_loc5_ - 60) && _loc4_ < _loc5_))
               {
                  _loc5_ = _loc4_;
               }
               if(isNaN(_loc3_) || _loc4_ > _loc3_)
               {
                  _loc3_ = _loc4_;
               }
            }
         }
         if(remember(_loc5_))
         {
            _loc6_ = true;
         }
         if(remember(_loc3_))
         {
            _loc6_ = true;
         }
         return _loc6_;
      }
   }
}

