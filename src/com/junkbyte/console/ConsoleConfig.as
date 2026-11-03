package com.junkbyte.console
{
   import flash.Boot;
   
   public class ConsoleConfig
   {
      
      public var useObjectLinking:Boolean;
      
      public var tracing:Boolean;
      
      public var traceCall:*;
      
      public var timeStampFormatter:*;
      
      public var showTimestamp:Boolean;
      
      public var showLineNumber:Boolean;
      
      public var sharedObjectPath:String;
      
      public var sharedObjectName:String;
      
      public var rulerToolEnabled:Boolean;
      
      public var rulerHidesMouse:Boolean;
      
      public var remotingPassword:String;
      
      public var remotingConnectionName:String;
      
      public var rememberFilterSettings:Boolean;
      
      public var objectHardReferenceTimer:uint;
      
      public var maxRepeats:int;
      
      public var maxLines:uint;
      
      public var keystrokePassword:String;
      
      public var keyBindsEnabled:Boolean;
      
      public var displayRollerTilemapCapturingEnabled:Boolean;
      
      public var displayRollerEnabled:Boolean;
      
      public var defaultStackDepth:int;
      
      public var commandLineInputPassThrough:*;
      
      public var commandLineAutoScope:Boolean;
      
      public var commandLineAutoCompleteEnabled:Boolean;
      
      public var commandLineAllowed:Boolean;
      
      public var autoStackPriority:int;
      
      public var alwaysOnTop:Boolean;
      
      public var allowedRemoteDomain:String;
      
      public var _style:ConsoleStyle;
      
      public function ConsoleConfig()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         alwaysOnTop = true;
         sharedObjectPath = "/";
         sharedObjectName = "com.junkbyte/Console/UserData";
         rulerHidesMouse = true;
         rulerToolEnabled = true;
         displayRollerTilemapCapturingEnabled = false;
         displayRollerEnabled = true;
         keyBindsEnabled = true;
         commandLineAutoCompleteEnabled = true;
         allowedRemoteDomain = "*";
         remotingConnectionName = "_Console";
         showLineNumber = false;
         timeStampFormatter = function(timer:uint):String
         {
            var _loc2_:uint = uint(int(timer * 0.001));
            return ConsoleConfig.makeTimeDigit(int(_loc2_ / 60)) + ":" + ConsoleConfig.makeTimeDigit(int(_loc2_ % 60));
         };
         showTimestamp = false;
         traceCall = function(ch:String, line:String, ... rest):void
         {
            trace("[" + ch + "] " + line);
         };
         objectHardReferenceTimer = 0;
         useObjectLinking = true;
         defaultStackDepth = 2;
         autoStackPriority = int(10);
         maxRepeats = 75;
         maxLines = 1000;
         _style = new ConsoleStyle();
      }
      
      public static function makeTimeDigit(v:uint) : String
      {
         if(v < 10)
         {
            return "0" + ("" + v);
         }
         return "" + v;
      }
      
      public function get_style() : ConsoleStyle
      {
         return _style;
      }
      
      public function get style() : ConsoleStyle
      {
         return get_style();
      }
   }
}

