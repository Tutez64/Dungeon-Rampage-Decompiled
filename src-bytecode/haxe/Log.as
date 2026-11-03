package haxe
{
   import flash.Boot;
   
   public class Log
   {
      
      public static function trace(v:*, infos:Object = undefined):void
      {
         Boot.__trace(v,infos);
      }
      public static function clear():void
      {
         Boot.__clear_trace();
      }
      public static function setColor(rgb:int):void
      {
         Boot.__set_trace_color(rgb);
      }
      public function Log()
      {
      }
      
      public static function formatOutput(v:*, infos:Object) : String
      {
         var _loc5_:int = 0;
         var _loc6_:* = null as Array;
         var _loc7_:* = null;
         var _loc3_:String = Std.string(v);
         if(infos == null)
         {
            return _loc3_;
         }
         var _loc4_:String = infos.fileName + ":" + int(infos.lineNumber);
         if(infos != null && infos.customParams != null)
         {
            _loc5_ = 0;
            _loc6_ = infos.customParams;
            while(_loc5_ < int(_loc6_.length))
            {
               _loc7_ = _loc6_[_loc5_];
               _loc5_++;
               _loc3_ += ", " + Std.string(_loc7_);
            }
         }
         return _loc4_ + ": " + _loc3_;
      }
   }
}

import flash.Boot;

var _temp_2:* = global;
var _temp_1:* = §§newclass(Log,Object);

