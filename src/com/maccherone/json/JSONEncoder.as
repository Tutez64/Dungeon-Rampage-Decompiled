package com.maccherone.json
{
   import flash.utils.describeType;
   
   public class JSONEncoder
   {
      
      private static const tabWidth:int = 4;
      
      private var jsonString:String;
      
      private var level:int;
      
      private var maxLength:int;
      
      private var pretty:Boolean;
      
      public function JSONEncoder(value:*, pretty:Boolean = false, maxLength:int = 60)
      {
         super();
         level = 0;
         this.pretty = pretty;
         if(pretty)
         {
            this.maxLength = maxLength;
         }
         else
         {
            this.maxLength = int.MAX_VALUE;
         }
         jsonString = convertToString(value);
      }
      
      private static function getPadding(level:int) : String
      {
         var _loc2_:int = level * tabWidth;
         var _loc3_:String = "";
         var _loc4_:* = 1;
         while(_loc4_ <= _loc2_)
         {
            _loc3_ += " ";
            _loc4_++;
         }
         return _loc3_;
      }
      
      private function objectToStringPretty(o:Object) : String
      {
         var s:String;
         var classInfo:XML;
         var value:Object = null;
         var key:String = null;
         var v:XML = null;
         ++level;
         s = "";
         classInfo = describeType(o);
         if(classInfo.@name.toString() == "Object")
         {
            for(key in o)
            {
               value = o[key];
               if(!(value is Function))
               {
                  if(s.length > 0)
                  {
                     s += ",\n";
                  }
                  s += getPadding(level) + escapeString(key) + ":";
                  if(pretty)
                  {
                     s += " ";
                  }
                  s += convertToString(value);
               }
            }
         }
         else
         {
            for each(v in classInfo..*.(name() == "variable" || name() == "accessor"))
            {
               if(s.length > 0)
               {
                  s += ",\n";
               }
               s += getPadding(level) + escapeString(v.@name.toString()) + ":";
               if(pretty)
               {
                  s += " ";
               }
               s += convertToString(o[v.@name]);
            }
         }
         --level;
         return "{" + "\n" + s + "\n" + getPadding(level) + "}";
      }
      
      private function arrayToString(a:Array) : String
      {
         var _loc2_:String = "";
         var _loc3_:* = 0;
         while(_loc3_ < a.length)
         {
            if(_loc2_.length > 0)
            {
               _loc2_ += ",";
               if(pretty)
               {
                  _loc2_ += " ";
               }
            }
            _loc2_ += convertToString(a[_loc3_]);
            _loc3_++;
         }
         return "[" + _loc2_ + "]";
      }
      
      public function getString() : String
      {
         return jsonString;
      }
      
      private function objectToString(o:Object) : String
      {
         var value:Object = null;
         var key:String = null;
         var v:XML = null;
         var s:String = "";
         var classInfo:XML = describeType(o);
         if(classInfo.@name.toString() == "Object")
         {
            for(key in o)
            {
               value = o[key];
               if(!(value is Function))
               {
                  if(s.length > 0)
                  {
                     s += ",";
                     if(pretty)
                     {
                        s += " ";
                     }
                  }
                  s += escapeString(key) + ":";
                  if(pretty)
                  {
                     s += " ";
                  }
                  s += convertToString(value);
               }
            }
         }
         else
         {
            for each(v in classInfo..*.(name() == "variable" || name() == "accessor"))
            {
               if(s.length > 0)
               {
                  s += ",";
                  if(pretty)
                  {
                     s += " ";
                  }
               }
               s += escapeString(v.@name.toString()) + ":";
               if(pretty)
               {
                  s += " ";
               }
               s += convertToString(o[v.@name]);
            }
         }
         return "{" + s + "}";
      }
      
      private function escapeString(str:String) : String
      {
         var _loc3_:String = null;
         var _loc6_:String = null;
         var _loc7_:String = null;
         var _loc2_:String = "";
         var _loc4_:Number = str.length;
         var _loc5_:* = 0;
         while(_loc5_ < _loc4_)
         {
            _loc3_ = str.charAt(_loc5_);
            switch(_loc3_)
            {
               case "\"":
                  _loc2_ += "\\\"";
                  break;
               case "\\":
                  _loc2_ += "\\\\";
                  break;
               case "\b":
                  _loc2_ += "\\b";
                  break;
               case "\f":
                  _loc2_ += "\\f";
                  break;
               case "\n":
                  _loc2_ += "\\n";
                  break;
               case "\r":
                  _loc2_ += "\\r";
                  break;
               case "\t":
                  _loc2_ += "\\t";
                  break;
               default:
                  if(_loc3_ < " ")
                  {
                     _loc6_ = _loc3_.charCodeAt(0).toString(16);
                     _loc7_ = _loc6_.length == 2 ? "00" : "000";
                     _loc2_ += "\\u" + _loc7_ + _loc6_;
                  }
                  else
                  {
                     _loc2_ += _loc3_;
                  }
            }
            _loc5_++;
         }
         return "\"" + _loc2_ + "\"";
      }
      
      private function arrayToStringPretty(a:Array) : String
      {
         ++level;
         var _loc2_:String = "";
         var _loc3_:* = 0;
         while(_loc3_ < a.length)
         {
            if(_loc2_.length > 0)
            {
               _loc2_ += ",\n";
            }
            _loc2_ += getPadding(level) + convertToString(a[_loc3_]);
            _loc3_++;
         }
         --level;
         return "[" + "\n" + _loc2_ + "\n" + getPadding(level) + "]";
      }
      
      private function convertToString(value:*) : String
      {
         var _loc2_:String = null;
         if(value is String)
         {
            return escapeString(value as String);
         }
         if(value is Number)
         {
            return isFinite(value as Number) ? value.toString() : "null";
         }
         if(value is Boolean)
         {
            return value ? "true" : "false";
         }
         if(value is Array)
         {
            if(maxLength <= 2)
            {
               _loc2_ = arrayToStringPretty(value as Array);
            }
            else
            {
               _loc2_ = arrayToString(value as Array);
               if(_loc2_.length > maxLength)
               {
                  _loc2_ = arrayToStringPretty(value as Array);
               }
            }
            return _loc2_;
         }
         if(value is Object && value != null)
         {
            if(maxLength <= 2)
            {
               _loc2_ = objectToStringPretty(value);
            }
            else
            {
               _loc2_ = objectToString(value);
               if(_loc2_.length > maxLength)
               {
                  _loc2_ = objectToStringPretty(value);
               }
            }
            return _loc2_;
         }
         return "null";
      }
   }
}

