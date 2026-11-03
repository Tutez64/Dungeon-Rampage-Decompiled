package DBGlobals
{
   public class As3Compat
   {
      
      public function As3Compat()
      {
      }
      
      public static function isNaN(f:Number) : Boolean
      {
         return f != f;
      }
      
      public static function get_NAN() : Number
      {
         return Number(Number.NaN);
      }
      
      public static function truthy(v:*) : Boolean
      {
         var _loc2_:Number = NaN;
         if(v == null)
         {
            return false;
         }
         if(Std.isOfType(v,Boolean))
         {
            return Boolean(v);
         }
         if(Std.isOfType(v,int) || Std.isOfType(v,Number))
         {
            _loc2_ = v;
            if(_loc2_ != 0)
            {
               return _loc2_ == _loc2_;
            }
            return false;
         }
         if(v is String)
         {
            return v.length > 0;
         }
         return true;
      }
      
      public static function truthyString(s:String) : Boolean
      {
         if(s != null)
         {
            return s.length > 0;
         }
         return false;
      }
      
      public static function toFloat(v:*) : Number
      {
         var _loc2_:* = null as String;
         if(v == null)
         {
            return 0;
         }
         if(v is String)
         {
            _loc2_ = StringTools.trim(v);
            if(_loc2_.length == 0)
            {
               return 0;
            }
            return Std.parseFloat(_loc2_);
         }
         if(Std.isOfType(v,Boolean))
         {
            if(v)
            {
               return 1;
            }
            return 0;
         }
         return Number(v);
      }
      
      public static function parseHex(s:String) : Number
      {
         if(s == null)
         {
            return Number(Number.NaN);
         }
         var _loc2_:String = StringTools.trim(s);
         if(_loc2_.length == 0)
         {
            return Number(Number.NaN);
         }
         return parseInt(_loc2_,16);
      }
      
      public static function toUInt(v:*) : uint
      {
         var _loc2_:Number = NaN;
         if(v == null)
         {
            return 0;
         }
         if(v is String)
         {
            _loc2_ = parseInt(v);
            if(_loc2_ != _loc2_)
            {
               return 0;
            }
            return int(_loc2_);
         }
         if(Std.isOfType(v,Boolean))
         {
            if(v)
            {
               return 1;
            }
            return 0;
         }
         _loc2_ = v;
         if(_loc2_ != _loc2_)
         {
            return 0;
         }
         return int(_loc2_);
      }
      
      public static function values(o:*) : Array
      {
         var _loc5_:* = null as String;
         var _loc2_:Array = [];
         if(o == null)
         {
            return _loc2_;
         }
         if(o is Array)
         {
            return o;
         }
         var _loc3_:int = 0;
         var _loc4_:Array = Reflect.fields(o);
         while(_loc3_ < int(_loc4_.length))
         {
            _loc5_ = _loc4_[_loc3_];
            _loc3_++;
            _loc2_.push(Reflect.field(o,_loc5_));
         }
         return _loc2_;
      }
   }
}

