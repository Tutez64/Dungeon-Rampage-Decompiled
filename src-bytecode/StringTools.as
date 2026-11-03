package
{
   import flash.Boot;
   import haxe.SysTools;
   import haxe.iterators.StringIterator;
   import haxe.iterators.StringKeyValueIterator;
   
   public class StringTools
   {
      
      public static var MIN_SURROGATE_CODE_POINT:int = 65536;
      
      public static var winMetaCharacters:Array = SysTools.winMetaCharacters;
      
      public function StringTools()
      {
      }
      
      public static function urlEncode(s:String) : String
      {
         return encodeURIComponent(s);
      }
      
      public static function urlDecode(s:String) : String
      {
         return decodeURIComponent(s.split("+").join(" "));
      }
      
      public static function htmlEscape(s:String, quotes:Object = undefined) : String
      {
         var _loc6_:* = null as String;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:int = 0;
         var _loc3_:String = "";
         var _loc4_:int = 0;
         var _loc5_:String = s;
         while(_loc4_ < _loc5_.length)
         {
            _loc6_ = _loc5_;
            _loc7_ = _loc4_++;
            _loc8_ = _loc6_.charCodeAt(_loc7_);
            if(_loc8_ >= 55296 && _loc8_ <= 56319)
            {
               _loc8_ = _loc8_ - 55232 << 10 | int(_loc6_.charCodeAt(_loc7_ + 1)) & 0x03FF;
            }
            _loc9_ = _loc8_;
            if(_loc9_ >= 65536)
            {
               _loc4_++;
            }
            switch(_loc10_ = _loc9_)
            {
               case 34:
                  if(quotes)
                  {
                     _loc3_ += "&quot;";
                  }
                  else
                  {
                     _loc3_ += _loc10_ < 65536 ? String["fromCharCode"](_loc10_) : Boot.fromCodePoint(_loc10_);
                  }
                  break;
               case 38:
                  _loc3_ += "&amp;";
                  break;
               case 39:
                  if(quotes)
                  {
                     _loc3_ += "&#039;";
                  }
                  else
                  {
                     _loc3_ += _loc10_ < 65536 ? String["fromCharCode"](_loc10_) : Boot.fromCodePoint(_loc10_);
                  }
                  break;
               case 60:
                  _loc3_ += "&lt;";
                  break;
               case 62:
                  _loc3_ += "&gt;";
                  break;
               default:
                  _loc3_ += _loc10_ < 65536 ? String["fromCharCode"](_loc10_) : Boot.fromCodePoint(_loc10_);
            }
         }
         return _loc3_;
      }
      
      public static function htmlUnescape(s:String) : String
      {
         return s.split("&gt;").join(">").split("&lt;").join("<").split("&quot;").join("\"").split("&#039;").join("\'").split("&amp;").join("&");
      }
      
      public static function contains(s:String, value:String) : Boolean
      {
         return s.indexOf(value) != -1;
      }
      
      public static function startsWith(s:String, start:String) : Boolean
      {
         if(s.length >= start.length)
         {
            return s.lastIndexOf(start,0) == 0;
         }
         return false;
      }
      
      public static function endsWith(s:String, end:String) : Boolean
      {
         var _loc3_:int = end.length;
         var _loc4_:int = s.length;
         if(_loc4_ >= _loc3_)
         {
            return s.indexOf(end,_loc4_ - _loc3_) == _loc4_ - _loc3_;
         }
         return false;
      }
      
      public static function isSpace(s:String, pos:int) : Boolean
      {
         var _loc3_:Object = s.charCodeAt(pos);
         if(!(_loc3_ > 8 && _loc3_ < 14))
         {
            return _loc3_ == 32;
         }
         return true;
      }
      
      public static function ltrim(s:String) : String
      {
         var _loc2_:int = s.length;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_ && StringTools.isSpace(s,_loc3_))
         {
            _loc3_++;
         }
         if(_loc3_ > 0)
         {
            return s.substr(_loc3_,_loc2_ - _loc3_);
         }
         return s;
      }
      
      public static function rtrim(s:String) : String
      {
         var _loc2_:int = s.length;
         var _loc3_:int = 0;
         while(_loc3_ < _loc2_ && StringTools.isSpace(s,_loc2_ - _loc3_ - 1))
         {
            _loc3_++;
         }
         if(_loc3_ > 0)
         {
            return s.substr(0,_loc2_ - _loc3_);
         }
         return s;
      }
      
      public static function trim(s:String) : String
      {
         return StringTools.ltrim(StringTools.rtrim(s));
      }
      
      public static function lpad(s:String, c:String, l:int) : String
      {
         if(c.length <= 0)
         {
            return s;
         }
         var _loc4_:String = "";
         l -= s.length;
         while(_loc4_.length < l)
         {
            _loc4_ += Std.string(c);
         }
         return _loc4_ + Std.string(s);
      }
      
      public static function rpad(s:String, c:String, l:int) : String
      {
         if(c.length <= 0)
         {
            return s;
         }
         var _loc4_:String = "";
         _loc4_ = _loc4_ + Std.string(s);
         while(_loc4_.length < l)
         {
            _loc4_ += Std.string(c);
         }
         return _loc4_;
      }
      
      public static function replace(s:String, sub:String, by:String) : String
      {
         return s.split(sub).join(by);
      }
      
      public static function hex(n:int, digits:Object = undefined) : String
      {
         var _loc3_:uint = uint(n);
         var _loc4_:String = _loc3_.toString(16);
         _loc4_ = _loc4_.toUpperCase();
         if(digits != null)
         {
            while(_loc4_.length < digits)
            {
               _loc4_ = "0" + _loc4_;
            }
         }
         return _loc4_;
      }
      
      public static function fastCodeAt(s:String, index:int) : int
      {
         return int(s.charCodeAt(index));
      }
      
      public static function unsafeCodeAt(s:String, index:int) : int
      {
         return int(s.charCodeAt(index));
      }
      
      public static function iterator(s:String) : StringIterator
      {
         return new StringIterator(s);
      }
      
      public static function keyValueIterator(s:String) : StringKeyValueIterator
      {
         return new StringKeyValueIterator(s);
      }
      
      public static function isEof(c:int) : Boolean
      {
         return c == 0;
      }
      
      public static function quoteUnixArg(argument:String) : String
      {
         if(argument == "")
         {
            return "\'\'";
         }
         if(!new EReg("[^a-zA-Z0-9_@%+=:,./-]","").match(argument))
         {
            return argument;
         }
         return "\'" + StringTools.replace(argument,"\'","\'\"\'\"\'") + "\'";
      }
      
      public static function quoteWinArg(argument:String, escapeMetaCharacters:Boolean) : String
      {
         var _loc4_:* = null as String;
         var _loc5_:Boolean = false;
         var _loc6_:* = null as StringBuf;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:int = 0;
         var _loc10_:* = null as Object;
         var _loc11_:* = null as Object;
         var _loc12_:int = 0;
         var _loc13_:* = null as String;
         var _loc3_:String = argument;
         if(!new EReg("^(/)?[^ \t/\\\\\"]+$","").match(_loc3_))
         {
            _loc4_ = "";
            _loc5_ = _loc3_.indexOf(" ") != -1 || _loc3_.indexOf("\t") != -1 || _loc3_ == "" || _loc3_.indexOf("/") > 0;
            if(_loc5_)
            {
               _loc4_ += "\"";
            }
            _loc6_ = new StringBuf();
            _loc7_ = 0;
            _loc8_ = _loc3_.length;
            while(_loc7_ < _loc8_)
            {
               _loc9_ = _loc7_++;
               _loc10_ = _loc3_.charCodeAt(_loc9_);
               if(_loc10_ == null)
               {
                  _loc11_ = _loc10_;
                  if(_loc6_.b.length > 0)
                  {
                     _loc4_ += Std.string(_loc6_.b);
                     _loc6_ = new StringBuf();
                  }
                  _loc12_ = _loc11_;
                  _loc4_ += _loc12_ < 65536 ? String["fromCharCode"](_loc12_) : Boot.fromCodePoint(_loc12_);
               }
               else
               {
                  _loc11_ = _loc10_;
                  if(_loc11_ == 34)
                  {
                     _loc13_ = _loc6_.b;
                     _loc4_ += Std.string(_loc13_);
                     _loc4_ = _loc4_ + Std.string(_loc13_);
                     _loc6_ = new StringBuf();
                     _loc4_ += "\\\"";
                  }
                  else if(_loc11_ == 92)
                  {
                     _loc6_.b += "\\";
                  }
                  else
                  {
                     _loc11_ = _loc10_;
                     if(_loc6_.b.length > 0)
                     {
                        _loc4_ += Std.string(_loc6_.b);
                        _loc6_ = new StringBuf();
                     }
                     _loc12_ = _loc11_;
                     _loc4_ += _loc12_ < 65536 ? String["fromCharCode"](_loc12_) : Boot.fromCodePoint(_loc12_);
                  }
               }
            }
            _loc4_ += Std.string(_loc6_.b);
            if(_loc5_)
            {
               _loc4_ += Std.string(_loc6_.b);
               _loc4_ = _loc4_ + "\"";
            }
            _loc3_ = _loc4_;
         }
         if(escapeMetaCharacters)
         {
            _loc4_ = "";
            _loc7_ = 0;
            _loc8_ = _loc3_.length;
            while(_loc7_ < _loc8_)
            {
               _loc9_ = _loc7_++;
               _loc10_ = _loc3_.charCodeAt(_loc9_);
               if(SysTools.winMetaCharacters.indexOf(_loc10_) >= 0)
               {
                  _loc4_ += String["fromCharCode"](94);
               }
               _loc12_ = _loc10_;
               _loc4_ += _loc12_ < 65536 ? String["fromCharCode"](_loc12_) : Boot.fromCodePoint(_loc12_);
            }
            return _loc4_;
         }
         return _loc3_;
      }
      
      public static function utf16CodePointAt(s:String, index:int) : int
      {
         var _loc3_:int = s.charCodeAt(index);
         if(_loc3_ >= 55296 && _loc3_ <= 56319)
         {
            _loc3_ = _loc3_ - 55232 << 10 | int(s.charCodeAt(index + 1)) & 0x03FF;
         }
         return _loc3_;
      }
   }
}

