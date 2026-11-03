package Json
{
   import flash.Boot;
   import flash.utils.describeType;
   
   public class JsonEncoder
   {
      
      public static var TAB_WIDTH:int = 4;
      
      public var _pretty:Boolean;
      
      public var _maxLength:int;
      
      public var _level:int;
      
      public var _jsonString:String;
      
      public function JsonEncoder(value:* = undefined, pretty:Boolean = false, maxLength:int = 0)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         _level = 0;
         _pretty = pretty;
         _maxLength = pretty ? maxLength : 2147483647;
         _jsonString = convertToString(value);
      }
      
      public static function memberNames(o:*, classInfo:XML, plainObject:Boolean) : Array
      {
         var _loc5_:* = null as Array;
         var _loc6_:* = null as Array;
         var _loc7_:* = 0;
         var _loc8_:* = null;
         var _loc9_:* = null as XMLList;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:* = null as XML;
         var _loc13_:* = null as String;
         var _loc4_:Array = [];
         if(plainObject)
         {
            _loc7_ = 0;
            _loc6_ = [];
            _loc8_ = o;
            for(_loc7_ in _loc8_)
            {
               _loc6_.push(_loc7_);
            }
            _loc5_ = _loc6_;
            _loc7_ = 0;
            while(_loc7_ < int(_loc5_.length))
            {
               _loc8_ = _loc5_[_loc7_];
               _loc7_++;
               _loc4_.push(String(_loc8_));
            }
         }
         else
         {
            _loc9_ = classInfo.descendants("*");
            _loc7_ = 0;
            _loc10_ = _loc9_.length();
            while(_loc7_ < _loc10_)
            {
               _loc11_ = _loc7_++;
               _loc12_ = _loc9_[_loc11_];
               _loc13_ = String(_loc12_.name());
               if(_loc13_ == "variable" || _loc13_ == "accessor")
               {
                  _loc4_.push(_loc12_.attribute("name").toString());
               }
            }
         }
         return _loc4_;
      }
      
      public static function getPadding(level:int) : String
      {
         var _loc2_:Number = level * 4;
         var _loc3_:String = "";
         var _loc4_:int = 1;
         while(_loc4_ <= _loc2_)
         {
            _loc3_ += " ";
            _loc4_++;
         }
         return _loc3_;
      }
      
      public function objectToStringPretty(o:*) : String
      {
         var _loc7_:* = null as String;
         var _loc8_:* = null;
         ++_level;
         var _loc2_:String = "";
         var _loc3_:XML = describeType(o);
         var _loc4_:Boolean = _loc3_.attribute("name").toString() == "Object";
         var _loc5_:int = 0;
         var _loc6_:Array = JsonEncoder.memberNames(o,_loc3_,_loc4_);
         while(_loc5_ < int(_loc6_.length))
         {
            _loc7_ = _loc6_[_loc5_];
            _loc5_++;
            _loc8_ = o[_loc7_];
            if(!(_loc4_ && _loc8_ is Function))
            {
               if(_loc2_.length > 0)
               {
                  _loc2_ += ",\n";
               }
               _loc2_ += JsonEncoder.getPadding(_level) + escapeString(_loc7_) + ":";
               if(_pretty)
               {
                  _loc2_ += " ";
               }
               _loc2_ += convertToString(_loc8_);
            }
         }
         --_level;
         return "{\n" + _loc2_ + "\n" + JsonEncoder.getPadding(_level) + "}";
      }
      
      public function objectToString(o:*) : String
      {
         var _loc7_:* = null as String;
         var _loc8_:* = null;
         var _loc2_:String = "";
         var _loc3_:XML = describeType(o);
         var _loc4_:Boolean = _loc3_.attribute("name").toString() == "Object";
         var _loc5_:int = 0;
         var _loc6_:Array = JsonEncoder.memberNames(o,_loc3_,_loc4_);
         while(_loc5_ < int(_loc6_.length))
         {
            _loc7_ = _loc6_[_loc5_];
            _loc5_++;
            _loc8_ = o[_loc7_];
            if(!(_loc4_ && _loc8_ is Function))
            {
               if(_loc2_.length > 0)
               {
                  _loc2_ += ",";
                  if(_pretty)
                  {
                     _loc2_ += " ";
                  }
               }
               _loc2_ += escapeString(_loc7_) + ":";
               if(_pretty)
               {
                  _loc2_ += " ";
               }
               _loc2_ += convertToString(_loc8_);
            }
         }
         return "{" + _loc2_ + "}";
      }
      
      public function getString() : String
      {
         return _jsonString;
      }
      
      public function escapeString(str:String) : String
      {
         var _loc5_:int = 0;
         var _loc6_:* = null as String;
         var _loc7_:* = null as String;
         var _loc8_:int = 0;
         var _loc9_:* = null as String;
         var _loc2_:String = "";
         var _loc3_:int = 0;
         var _loc4_:int = str.length;
         while(_loc3_ < _loc4_)
         {
            _loc5_ = _loc3_++;
            _loc7_ = _loc6_ = str.charAt(_loc5_);
            if(_loc7_ == "\b")
            {
               _loc2_ += "\\b";
            }
            else if(_loc7_ == "\t")
            {
               _loc2_ += "\\t";
            }
            else if(_loc7_ == "\n")
            {
               _loc2_ += "\\n";
            }
            else if(_loc7_ == "\f")
            {
               _loc2_ += "\\f";
            }
            else if(_loc7_ == "\r")
            {
               _loc2_ += "\\r";
            }
            else if(_loc7_ == "\"")
            {
               _loc2_ += "\\\"";
            }
            else if(_loc7_ == "\\")
            {
               _loc2_ += "\\\\";
            }
            else if(_loc6_ < " ")
            {
               _loc8_ = int(_loc6_.charCodeAt(0));
               _loc7_ = _loc8_.toString(16);
               _loc9_ = _loc7_.length == 2 ? "00" : "000";
               _loc2_ += "\\u" + _loc9_ + _loc7_;
            }
            else
            {
               _loc2_ += _loc6_;
            }
         }
         return "\"" + _loc2_ + "\"";
      }
      
      public function convertToString(value:*) : String
      {
         var _loc2_:* = null as String;
         if(value is String)
         {
            return escapeString(value);
         }
         if(value is Number)
         {
            if(isFinite(value))
            {
               return value.toString();
            }
            return "null";
         }
         if(value is Boolean)
         {
            if(value)
            {
               return "true";
            }
            return "false";
         }
         if(value is Array)
         {
            if(_maxLength <= 2)
            {
               return arrayToStringPretty(value);
            }
            _loc2_ = arrayToString(value);
            if(_loc2_.length > _maxLength)
            {
               return arrayToStringPretty(value);
            }
            return _loc2_;
         }
         if(value is Object && value != null)
         {
            if(_maxLength <= 2)
            {
               return objectToStringPretty(value);
            }
            _loc2_ = objectToString(value);
            if(_loc2_.length > _maxLength)
            {
               return objectToStringPretty(value);
            }
            return _loc2_;
         }
         return "null";
      }
      
      public function arrayToStringPretty(a:Array) : String
      {
         var _loc5_:int = 0;
         ++_level;
         var _loc2_:String = "";
         var _loc3_:int = 0;
         var _loc4_:int = int(a.length);
         while(_loc3_ < _loc4_)
         {
            _loc5_ = _loc3_++;
            if(_loc2_.length > 0)
            {
               _loc2_ += ",\n";
            }
            _loc2_ += JsonEncoder.getPadding(_level) + convertToString(a[_loc5_]);
         }
         --_level;
         return "[\n" + _loc2_ + "\n" + JsonEncoder.getPadding(_level) + "]";
      }
      
      public function arrayToString(a:Array) : String
      {
         var _loc5_:int = 0;
         var _loc2_:String = "";
         var _loc3_:int = 0;
         var _loc4_:int = int(a.length);
         while(_loc3_ < _loc4_)
         {
            _loc5_ = _loc3_++;
            if(_loc2_.length > 0)
            {
               _loc2_ += ",";
               if(_pretty)
               {
                  _loc2_ += " ";
               }
            }
            _loc2_ += convertToString(a[_loc5_]);
         }
         return "[" + _loc2_ + "]";
      }
   }
}

