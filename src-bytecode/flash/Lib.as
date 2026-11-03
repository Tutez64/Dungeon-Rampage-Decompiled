package flash
{
   import flash.display.MovieClip;
   import flash.external.ExternalInterface;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.system.fscommand;
   import flash.utils.describeType;
   import flash.utils.getDefinitionByName;
   import flash.utils.getTimer;
   import haxe.Log;
   
   public class Lib
   {
      
      public static var current:MovieClip;
      
      public function Lib()
      {
      }
      
      public static function getTimer() : int
      {
         return flash.utils.getTimer();
      }
      
      public static function eval(path:String) : *
      {
         var _loc6_:* = null;
         var _loc8_:* = null as String;
         var _loc3_:Array = path.split(".");
         var _loc4_:Array = [];
         var _loc5_:* = null;
         while(int(_loc3_.length) > 0)
         {
            try
            {
               _loc5_ = getDefinitionByName(_loc3_.join("."));
            }
            catch(_loc_e_:*)
            {
               _loc6_ = _loc_e_;
               null;
               _loc4_.unshift(_loc3_.pop());
            }
            if(_loc5_ != null)
            {
               break;
            }
         }
         var _loc7_:int = 0;
         while(_loc7_ < int(_loc4_.length))
         {
            _loc8_ = _loc4_[_loc7_];
            _loc7_++;
            if(_loc5_ == null)
            {
               return null;
            }
            _loc5_ = _loc5_[_loc8_];
         }
         return _loc5_;
      }
      
      public static function getURL(url:URLRequest, target:String = undefined) : void
      {
         var _loc3_:Function = navigateToURL;
         if(target == null)
         {
            _loc3_(url);
         }
         else
         {
            _loc3_(url,target);
         }
      }
      
      public static function fscommand(cmd:String, param:String = undefined) : void
      {
         flash.system.fscommand(cmd,param == null ? "" : param);
      }
      
      public static function trace(arg:*) : void
      {
         trace(arg);
      }
      
      public static function describeType(value:*) : XML
      {
         return flash.utils.describeType(value);
      }
      
      public static function attach(name:String) : MovieClip
      {
         var _loc2_:* = getDefinitionByName(name) as Class;
         return new _loc2_();
      }
      
      public static function §as§(v:*, c:Class) : Object
      {
         return v as c;
      }
      
      public static function redirectTraces() : void
      {
         if(ExternalInterface.available)
         {
            Log.trace = Lib.traceToConsole;
         }
      }
      
      public static function traceToConsole(v:*, inf:Object = undefined) : void
      {
         var _loc6_:* = null;
         var _loc4_:String = inf != null && inf.customParams != null ? inf.customParams[0] : null;
         if(_loc4_ != "warn" && _loc4_ != "info" && _loc4_ != "debug" && _loc4_ != "error")
         {
            _loc4_ = inf == null ? "error" : "log";
         }
         var _loc5_:String = inf == null ? "" : inf.fileName + ":" + int(inf.lineNumber) + " : ";
         try
         {
            _loc5_ += Std.string(v);
         }
         catch(_loc_e_:*)
         {
            _loc6_ = _loc_e_;
            null;
            _loc5_ += "????";
         }
         _loc5_ = _loc5_.split("\\").join("\\\\");
         ExternalInterface.call("console." + _loc4_,_loc5_);
      }
   }
}

