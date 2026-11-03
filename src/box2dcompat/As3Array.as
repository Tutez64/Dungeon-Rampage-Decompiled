package box2dcompat
{
   public class As3Array
   {
      
      public function As3Array()
      {
      }
      
      public static function of(v:*) : Array
      {
         var _loc6_:int = 0;
         if(v == null || v is Array)
         {
            return v;
         }
         var _loc2_:int = int(v.length);
         var _loc3_:Array = [];
         var _loc4_:int = 0;
         var _loc5_:int = _loc2_;
         while(_loc4_ < _loc5_)
         {
            _loc6_ = _loc4_++;
            _loc3_[_loc6_] = v[_loc6_];
         }
         return _loc3_;
      }
   }
}

