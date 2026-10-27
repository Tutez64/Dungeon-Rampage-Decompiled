package Brain.Logger
{
   import Brain.Clock.GameClock;
   import com.junkbyte.console.Cc;
   import com.junkbyte.console.KeyBind;
   import flash.display.Stage;
   import flash.system.Capabilities;
   
   public class Logger
   {
      
      private static var mReentrentLock:Boolean = false;
      
      private static var mWantConsole:Boolean = false;
      
      private static var mWantCommandLine:Boolean = false;
      
      private static var mWantThrowErrors:Boolean = true;
      
      private static var mShowDebug:Boolean = true;
      
      private static var mShowInfo:Boolean = true;
      
      public static var errorCallback:Function;
      
      public static var customLoggerString:String;
      
      private static var mListSlashCommands:Array = [];
      
      public function Logger()
      {
         super();
      }
      
      public static function init(stageRef:Stage, wantConsole:Boolean = false) : void
      {
         mWantConsole = wantConsole;
         if(mWantConsole)
         {
            Cc.startOnStage(stageRef,"0");
         }
      }
      
      public static function displayConsole() : void
      {
         Cc.visible = true;
      }
      
      public static function hideConsole() : void
      {
         Cc.visible = false;
      }
      
      public static function isConsoleVisible() : Boolean
      {
         if(Cc.visible)
         {
            return true;
         }
         return false;
      }
      
      public static function enableCommandLine() : void
      {
         mWantCommandLine = true;
         Cc.config.commandLineAllowed = mWantCommandLine;
         mShowDebug = true;
         mShowInfo = true;
      }
      
      public static function setDebugMessages(showThem:Boolean) : void
      {
         mShowDebug = showThem;
      }
      
      public static function setInfoMessages(showThem:Boolean) : void
      {
         mShowInfo = showThem;
      }
      
      public static function addSlashCommand(arg0:String, arg1:Function, arg2:String = "", arg3:Boolean = true) : void
      {
         Cc.addSlashCommand(arg0,arg1,arg2,arg3);
         mListSlashCommands.push(arg0);
      }
      
      public static function listSlashCommands() : void
      {
         for each(var _loc1_:String in mListSlashCommands)
         {
            log(_loc1_);
         }
      }
      
      public static function bindKey(bindKey:KeyBind, bindFunction:Function, bindArray:Array = null) : void
      {
         Cc.bindKey(bindKey,bindFunction,bindArray);
      }
      
      public static function set CustomLoggerString(val:String) : void
      {
         customLoggerString = val;
      }
      
      private static function pad(num:Number, digits:uint) : String
      {
         var _loc3_:String = num.toString();
         while(_loc3_.length < digits)
         {
            _loc3_ = "0" + _loc3_;
         }
         return _loc3_;
      }
      
      public static function set errorsCanThrow(val:Boolean) : void
      {
         mWantThrowErrors = val;
      }
      
      public static function get errorsCanThrow() : Boolean
      {
         return mWantThrowErrors;
      }
      
      protected static function getDateString() : String
      {
         var _loc1_:Date = GameClock.date;
         return "[" + _loc1_.fullYear + "-" + pad(_loc1_.month + 1,2) + "-" + pad(_loc1_.date,2) + " " + pad(_loc1_.hours,2) + ":" + pad(_loc1_.minutes,2) + ":" + pad(_loc1_.seconds,2) + "." + pad(_loc1_.milliseconds,3) + "] ";
      }
      
      public static function log(logString:String) : void
      {
         logString = "" + logString;
         if(mWantConsole)
         {
            Cc.log(logString);
         }
      }
      
      public static function debug(logString:String) : void
      {
         if(!mShowDebug || customLoggerString != null)
         {
            return;
         }
         logString = "[DEBUG] " + getDateString() + logString;
         if(mWantConsole)
         {
            Cc.debug(logString);
         }
      }
      
      public static function debugch(channel:String, logString:String) : void
      {
         if(!mShowDebug || customLoggerString != null)
         {
            return;
         }
         logString = "[DEBUG] " + getDateString() + logString;
         if(mWantConsole)
         {
            Cc.debugch(channel,logString);
         }
      }
      
      public static function info(logString:String) : void
      {
         if(!mShowInfo)
         {
            return;
         }
         logString = "[INFO]  " + getDateString() + logString;
         if(mWantConsole)
         {
            Cc.info(logString);
         }
      }
      
      public static function infoch(channel:String, logString:String) : void
      {
         if(!mShowInfo)
         {
            return;
         }
         logString = "[INFO] " + getDateString() + logString;
         if(mWantConsole)
         {
            Cc.infoch(channel,logString);
         }
      }
      
      public static function warn(logString:String) : void
      {
         if(customLoggerString != null)
         {
            return;
         }
         logString = "[WARN]  " + getDateString() + logString;
         if(mWantConsole)
         {
            Cc.warn(logString);
         }
      }
      
      public static function warnch(channel:String, logString:String) : void
      {
         if(customLoggerString != null)
         {
            return;
         }
         logString = "[WARN] " + getDateString() + logString;
         if(mWantConsole)
         {
            Cc.warnch(channel,logString);
         }
      }
      
      public static function error(logString:String, originalError:Error = null) : void
      {
         var _loc5_:Error = originalError ? originalError : new Error(logString);
         var _loc4_:String = _loc5_.hasOwnProperty("getStackTrace") ? _loc5_.getStackTrace() : null;
         var _loc3_:String = _loc4_ ? logString + "\n" + _loc4_ : logString;
         tryErrorCallback(_loc3_);
         logString = "[ERROR] " + getDateString() + _loc3_;
         if(mWantConsole)
         {
            Cc.error(logString);
         }
         if(mWantThrowErrors && Capabilities.isDebugger)
         {
            displayConsole();
            Cc.minimumPriority = 8;
            _loc5_.name = "LOGGED " + _loc5_.name;
            throw _loc5_;
         }
      }
      
      private static function tryErrorCallback(logString:String) : void
      {
         if(errorCallback != null && !mReentrentLock)
         {
            mReentrentLock = true;
            errorCallback(logString);
            mReentrentLock = false;
         }
      }
      
      public static function fatal(logString:String, originalError:Error = null) : void
      {
         var _loc5_:Error = originalError ? originalError : new Error(logString);
         var _loc4_:String = _loc5_.hasOwnProperty("getStackTrace") ? _loc5_.getStackTrace() : null;
         logString = "[FATAL] " + getDateString() + logString;
         var _loc3_:String = logString + "\n" + _loc4_;
         if(mWantConsole)
         {
            displayConsole();
            Cc.minimumPriority = 8;
            Cc.height = 250;
            Cc.warn(_loc3_);
            Cc.fatal(logString);
            Cc.warn("If you are reporting this error please click \'Sv\' at the top to copy the logs to your clipboard");
         }
         tryErrorCallback(logString);
         if(mWantThrowErrors)
         {
            _loc5_.name = "LOGGED " + _loc5_.name;
            throw _loc5_;
         }
      }
      
      public static function reloadPage() : void
      {
      }
      
      public static function custom(myLoggerString:String, logString:String) : void
      {
         if(customLoggerString != myLoggerString)
         {
            return;
         }
         logString = "[" + customLoggerString + "]  " + getDateString() + logString;
         if(mWantConsole)
         {
            Cc.warn(logString);
         }
      }
   }
}

