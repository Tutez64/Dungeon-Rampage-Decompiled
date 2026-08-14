package com.adobe.serialization.json
{
   import flash.utils.describeType;
   
   public class JSONEncoder
   {
      
      private var jsonString:String;
      
      public function JSONEncoder(value:*)
      {
         super();
         this.jsonString = this.convertToString(value);
      }
      
      public function getString() : String
      {
         return this.jsonString;
      }
      
      private function convertToString(value:*) : String
      {
         if(value is String)
         {
            return this.escapeString(value as String);
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
            return this.arrayToString(value as Array);
         }
         if(value is Object && value != null)
         {
            return this.objectToString(value);
         }
         return "null";
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
      
      private function arrayToString(a:Array) : String
      {
         var _loc2_:String = "";
         var _loc3_:int = int(a.length);
         var _loc4_:* = 0;
         while(_loc4_ < _loc3_)
         {
            if(_loc2_.length > 0)
            {
               _loc2_ += ",";
            }
            _loc2_ += this.convertToString(a[_loc4_]);
            _loc4_++;
         }
         return "[" + _loc2_ + "]";
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
                  }
                  s += this.escapeString(key) + ":" + this.convertToString(value);
               }
            }
         }
         else
         {
            for each(v in classInfo..*.(name() == "variable" || name() == "accessor" && attribute("access").charAt(0) == "r"))
            {
               if(!(Boolean(v.metadata) && v.metadata.(@name == "Transient").length() > 0))
               {
                  if(s.length > 0)
                  {
                     s += ",";
                  }
                  s += this.escapeString(v.@name.toString()) + ":" + this.convertToString(o[v.@name]);
               }
            }
         }
         return "{" + s + "}";
      }
   }
}

