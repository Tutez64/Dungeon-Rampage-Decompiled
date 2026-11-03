package Util
{
   import Brain.Logger.Logger;
   import com.junkbyte.console.Cc;
   import com.junkbyte.console.vos.Log;
   import flash.filesystem.File;
   import flash.filesystem.FileStream;
   import flash.net.Socket;
   import flash.utils.IDataOutput;
   
   public class GameLogOutput
   {
      
      private static var mConfigured:Boolean;
      
      private static var mInstalled:Boolean;
      
      private static var mPreviousTracing:Boolean;
      
      private static var mPreviousTrace:Function;
      
      private static var mFile:FileStream;
      
      private static var mOutput:IDataOutput;
      
      private static var mWriting:Boolean;
      
      private static var mDestination:String;
      
      public function GameLogOutput()
      {
         super();
      }
      
      public static function configure(arguments:Array) : void
      {
         var _loc7_:Boolean = false;
         var _loc2_:String = null;
         var _loc9_:String = null;
         var _loc3_:Boolean = false;
         var _loc6_:File = null;
         var _loc5_:File = null;
         var _loc8_:String = null;
         if(mConfigured)
         {
            return;
         }
         for each(var _loc4_:String in arguments)
         {
            _loc4_ = unquote(_loc4_);
            if(!(_loc4_ != "--log" && _loc4_.indexOf("--log=") != 0))
            {
               mConfigured = true;
               _loc7_ = _loc4_ == "--log";
               _loc2_ = _loc7_ ? "dungeon-rampage.log" : unquote(_loc4_.substr(6));
               _loc9_ = "resolve log path";
               try
               {
                  _loc3_ = _loc7_ || isDirectoryDestination(_loc2_,resolveDestination(_loc2_));
                  _loc6_ = resolveFile(_loc2_);
                  _loc2_ = _loc6_.nativePath;
                  if(_loc6_.isDirectory)
                  {
                     throw new Error("Log file \"" + _loc2_ + "\" is a directory");
                  }
                  if(_loc3_ && Boolean(_loc6_.exists))
                  {
                     _loc5_ = _loc6_.parent.resolvePath("dungeon-rampage.previous.log");
                     _loc9_ = "rotate log to \"" + _loc5_.nativePath + "\"";
                     _loc6_.moveTo(_loc5_,true);
                  }
                  _loc9_ = null;
                  openFile(_loc6_,true);
               }
               catch(error:Error)
               {
                  close();
                  _loc8_ = _loc9_ ? "Could not " + _loc9_ + " \"" + _loc2_ + "\": " + error.message : error.message;
                  warn("Log output unavailable: " + _loc8_.replace(/\.+$/,"") + ". Continuing without file logging.");
               }
               return;
            }
         }
      }
      
      private static function unquote(value:String) : String
      {
         if(value && value.length >= 2 && value.charAt(0) == "\"" && value.charAt(value.length - 1) == "\"")
         {
            return value.substring(1,value.length - 1);
         }
         return value;
      }
      
      public static function resolveFile(path:String) : File
      {
         var _loc2_:File = resolveDestination(path);
         if(isDirectoryDestination(path,_loc2_))
         {
            _loc2_ = _loc2_.resolvePath("dungeon-rampage.log");
         }
         validatePath(_loc2_.nativePath);
         return _loc2_;
      }
      
      private static function isDirectoryDestination(path:String, destination:File) : Boolean
      {
         return /[\\/]$/.test(unquote(path)) || Boolean(destination.isDirectory);
      }
      
      private static function resolveDestination(path:String) : File
      {
         var _loc4_:String = null;
         var _loc5_:String = null;
         path = unquote(path);
         validatePath(path,true);
         var _loc2_:Boolean = /^([A-Za-z]:[\\/]|[\\/])/.test(path);
         var _loc3_:File = _loc2_ ? new File(path) : File.applicationStorageDirectory.resolvePath(path);
         validatePath(_loc3_.nativePath,true);
         if(!_loc2_)
         {
            _loc4_ = File.applicationStorageDirectory.nativePath.replace(new RegExp("\\\\","g"),"/");
            _loc5_ = _loc3_.nativePath.replace(new RegExp("\\\\","g"),"/");
            if(_loc5_ != _loc4_ && _loc5_.indexOf(_loc4_ + "/") != 0)
            {
               throw new Error("Relative log paths must stay within application storage");
            }
         }
         return _loc3_;
      }
      
      private static function validatePath(path:String, allowDirectory:Boolean = false) : void
      {
         if(!path || /[\x00-\x1f]/.test(path))
         {
            throw new Error("Expected a nonempty log file path");
         }
         if(path.indexOf("\"") >= 0)
         {
            throw new Error("Unexpected quote in log path; Use forward slashes, for example --log=\"C:/logs folder/\"");
         }
         var _loc4_:String = path.replace(new RegExp("\\\\","g"),"/");
         if(/^\/\/[.?]\//.test(_loc4_))
         {
            throw new Error("Device paths and named pipes are not supported for logging");
         }
         if(_loc4_.replace(/^[A-Za-z]:\//,"").indexOf(":") >= 0)
         {
            throw new Error("Expected a native file path");
         }
         var _loc6_:Array = _loc4_.split("/");
         for each(var _loc5_:String in _loc6_)
         {
            if(/^\.\.[ .]*$/.test(_loc5_))
            {
               throw new Error("Parent traversal is not allowed in log paths");
            }
         }
         var _loc3_:String = String(_loc6_[_loc6_.length - 1]).replace(/[ .]+$/g,"");
         if(!allowDirectory && (!_loc3_ || /\.json$/i.test(_loc3_)))
         {
            throw new Error("Log destination must be a file or folder and must not end in .json");
         }
      }
      
      public static function setFile(path:String, includeHistory:Boolean = false) : void
      {
         openFile(resolveFile(path),includeHistory);
      }
      
      private static function openFile(destination:File, includeHistory:Boolean) : void
      {
         var _loc5_:Log = null;
         if(!Cc.instance)
         {
            throw new Error("Could not open log file \"" + destination.nativePath + "\": game console is not initialized");
         }
         if(destination.isDirectory)
         {
            throw new Error("Log file \"" + destination.nativePath + "\" is a directory");
         }
         var _loc3_:File = destination.parent;
         try
         {
            _loc3_.createDirectory();
         }
         catch(error:Error)
         {
            throw new Error("Could not create log directory \"" + _loc3_.nativePath + "\" for log file \"" + destination.nativePath + "\": " + error.message);
         }
         releaseOutput();
         var _loc4_:FileStream;
         mFile = _loc4_ = new FileStream();
         mDestination = destination.nativePath;
         try
         {
            _loc4_.open(destination,"write");
            _loc4_.close();
            _loc4_.open(destination,"append");
         }
         catch(openError:Error)
         {
            close();
            throw new Error("Could not open log file \"" + destination.nativePath + "\": " + openError.message);
         }
         useStream(_loc4_);
         if(includeHistory)
         {
            _loc5_ = Cc.instance.logs.first;
            while(_loc5_ != null)
            {
               write(_loc5_.ch,_loc5_.plainText());
               _loc5_ = _loc5_.next;
            }
         }
         Logger.info("Log file: " + destination.nativePath);
      }
      
      public static function useStream(output:IDataOutput) : void
      {
         if(!output)
         {
            throw new Error("Log stream must not be null");
         }
         if(output === mOutput)
         {
            return;
         }
         if(!Cc.instance)
         {
            throw new Error("Game console is not initialized");
         }
         mConfigured = true;
         if(mFile !== output)
         {
            releaseOutput();
         }
         mOutput = output;
         if(!mInstalled)
         {
            mPreviousTracing = Cc.config.tracing;
            mPreviousTrace = Cc.config.traceCall;
            Cc.config.traceCall = onTrace;
            Cc.config.tracing = true;
            mInstalled = true;
         }
      }
      
      private static function onTrace(channel:String, line:String, priority:int) : void
      {
         var _loc4_:Function = mPreviousTracing ? mPreviousTrace : null;
         write(channel,line);
         if(_loc4_ != null)
         {
            _loc4_(channel,line,priority);
         }
      }
      
      private static function write(channel:String, line:String) : void
      {
         var _loc3_:String = null;
         var _loc4_:String = null;
         if(!mOutput || mWriting)
         {
            return;
         }
         mWriting = true;
         try
         {
            _loc3_ = "[" + channel + "] ";
            mOutput.writeUTFBytes(_loc3_ + line.replace(/\r?\n/g,"\n" + _loc3_) + "\n");
            if(mOutput is Socket)
            {
               (mOutput as Socket).flush();
            }
         }
         catch(error:Error)
         {
            _loc4_ = mDestination ? "file \"" + mDestination + "\"" : "stream";
            close();
            warn("Log output disabled after write failure to " + _loc4_ + ": " + error.message.replace(/\.+$/,"") + ". Continuing without this log output.");
         }
         finally
         {
            mWriting = false;
         }
      }
      
      private static function warn(message:String) : void
      {
         try
         {
            Logger.warn(message);
         }
         catch(ignored:Error)
         {
         }
      }
      
      private static function releaseOutput() : void
      {
         mOutput = null;
         mDestination = null;
         if(mFile)
         {
            try
            {
               mFile.close();
            }
            catch(ignored:Error)
            {
            }
            mFile = null;
         }
      }
      
      public static function close() : void
      {
         mConfigured = true;
         releaseOutput();
         if(mInstalled)
         {
            Cc.config.traceCall = mPreviousTrace;
            Cc.config.tracing = mPreviousTracing;
            mInstalled = false;
            mPreviousTrace = null;
         }
      }
   }
}

