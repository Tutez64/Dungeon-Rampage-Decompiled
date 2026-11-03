package haxe
{
   import flash.Boot;
   
   public class SysTools
   {
      
      public static var winMetaCharacters:Array = [32,40,41,37,33,94,34,60,62,38,124,10,13,44,59];
      
      public function SysTools()
      {
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
         var _loc3_:* = null as String;
         var _loc4_:Boolean = false;
         var _loc5_:* = null as StringBuf;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:* = null as Object;
         var _loc10_:* = null as Object;
         var _loc11_:int = 0;
         var _loc12_:* = null as String;
         if(!new EReg("^(/)?[^ \t/\\\\\"]+$","").match(argument))
         {
            _loc3_ = "";
            _loc4_ = argument.indexOf(" ") != -1 || argument.indexOf("\t") != -1 || argument == "" || argument.indexOf("/") > 0;
            if(_loc4_)
            {
               _loc3_ += "\"";
            }
            _loc5_ = new StringBuf();
            _loc6_ = 0;
            _loc7_ = argument.length;
            while(_loc6_ < _loc7_)
            {
               _loc8_ = _loc6_++;
               _loc9_ = argument.charCodeAt(_loc8_);
               if(_loc9_ == null)
               {
                  _loc10_ = _loc9_;
                  if(_loc5_.b.length > 0)
                  {
                     _loc3_ += Std.string(_loc5_.b);
                     _loc5_ = new StringBuf();
                  }
                  _loc11_ = _loc10_;
                  _loc3_ += _loc11_ < 65536 ? String["fromCharCode"](_loc11_) : Boot.fromCodePoint(_loc11_);
               }
               else
               {
                  _loc10_ = _loc9_;
                  if(_loc10_ == 34)
                  {
                     _loc12_ = _loc5_.b;
                     _loc3_ += Std.string(_loc12_);
                     _loc3_ += Std.string(_loc12_);
                     _loc5_ = new StringBuf();
                     _loc3_ += "\\\"";
                  }
                  else if(_loc10_ == 92)
                  {
                     _loc5_.b += "\\";
                  }
                  else
                  {
                     _loc10_ = _loc9_;
                     if(_loc5_.b.length > 0)
                     {
                        _loc3_ += Std.string(_loc5_.b);
                        _loc5_ = new StringBuf();
                     }
                     _loc11_ = _loc10_;
                     _loc3_ += _loc11_ < 65536 ? String["fromCharCode"](_loc11_) : Boot.fromCodePoint(_loc11_);
                  }
               }
            }
            _loc3_ += Std.string(_loc5_.b);
            if(_loc4_)
            {
               _loc3_ += Std.string(_loc5_.b);
               _loc3_ += "\"";
            }
            argument = _loc3_;
         }
         if(escapeMetaCharacters)
         {
            _loc3_ = "";
            _loc6_ = 0;
            _loc7_ = argument.length;
            while(_loc6_ < _loc7_)
            {
               _loc8_ = _loc6_++;
               _loc9_ = argument.charCodeAt(_loc8_);
               if(SysTools.winMetaCharacters.indexOf(_loc9_) >= 0)
               {
                  _loc3_ += String["fromCharCode"](94);
               }
               _loc11_ = _loc9_;
               _loc3_ += _loc11_ < 65536 ? String["fromCharCode"](_loc11_) : Boot.fromCodePoint(_loc11_);
            }
            return _loc3_;
         }
         return argument;
      }
   }
}

