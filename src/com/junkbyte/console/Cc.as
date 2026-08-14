package com.junkbyte.console
{
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.LoaderInfo;
   import flash.events.Event;
   import flash.geom.Rectangle;
   
   public class Cc
   {
      
      private static var _console:Console;
      
      private static var _config:ConsoleConfig;
      
      public function Cc()
      {
         super();
      }
      
      public static function get config() : ConsoleConfig
      {
         if(!_config)
         {
            _config = new ConsoleConfig();
         }
         return _config;
      }
      
      public static function start(container:DisplayObjectContainer, password:String = "") : void
      {
         if(_console)
         {
            if(Boolean(container) && !_console.parent)
            {
               container.addChild(_console);
            }
         }
         else
         {
            _console = new Console(password,config);
            if(container)
            {
               container.addChild(_console);
            }
         }
      }
      
      public static function startOnStage(display:DisplayObject, password:String = "") : void
      {
         if(_console)
         {
            if(Boolean(display) && Boolean(display.stage) && _console.parent != display.stage)
            {
               display.stage.addChild(_console);
            }
         }
         else if(Boolean(display) && Boolean(display.stage))
         {
            start(display.stage,password);
         }
         else
         {
            _console = new Console(password,config);
            if(display)
            {
               display.addEventListener(Event.ADDED_TO_STAGE,addedToStageHandle);
            }
         }
      }
      
      public static function add(string:*, priority:int = 2, isRepeating:Boolean = false) : void
      {
         if(_console)
         {
            _console.add(string,priority,isRepeating);
         }
      }
      
      public static function ch(channel:*, string:*, priority:int = 2, isRepeating:Boolean = false) : void
      {
         if(_console)
         {
            _console.ch(channel,string,priority,isRepeating);
         }
      }
      
      public static function log(... rest) : void
      {
         if(_console)
         {
            _console.log.apply(null,rest);
         }
      }
      
      public static function info(... rest) : void
      {
         if(_console)
         {
            _console.info.apply(null,rest);
         }
      }
      
      public static function debug(... rest) : void
      {
         if(_console)
         {
            _console.debug.apply(null,rest);
         }
      }
      
      public static function warn(... rest) : void
      {
         if(_console)
         {
            _console.warn.apply(null,rest);
         }
      }
      
      public static function error(... rest) : void
      {
         if(_console)
         {
            _console.error.apply(null,rest);
         }
      }
      
      public static function fatal(... rest) : void
      {
         if(_console)
         {
            _console.fatal.apply(null,rest);
         }
      }
      
      public static function logch(channel:*, ... rest) : void
      {
         if(_console)
         {
            _console.addCh(channel,rest,Console.LOG);
         }
      }
      
      public static function infoch(channel:*, ... rest) : void
      {
         if(_console)
         {
            _console.addCh(channel,rest,Console.INFO);
         }
      }
      
      public static function debugch(channel:*, ... rest) : void
      {
         if(_console)
         {
            _console.addCh(channel,rest,Console.DEBUG);
         }
      }
      
      public static function warnch(channel:*, ... rest) : void
      {
         if(_console)
         {
            _console.addCh(channel,rest,Console.WARN);
         }
      }
      
      public static function errorch(channel:*, ... rest) : void
      {
         if(_console)
         {
            _console.addCh(channel,rest,Console.ERROR);
         }
      }
      
      public static function fatalch(channel:*, ... rest) : void
      {
         if(_console)
         {
            _console.addCh(channel,rest,Console.FATAL);
         }
      }
      
      public static function stack(string:*, depth:int = -1, priority:int = 5) : void
      {
         if(_console)
         {
            _console.stack(string,depth,priority);
         }
      }
      
      public static function stackch(channel:*, string:*, depth:int = -1, priority:int = 5) : void
      {
         if(_console)
         {
            _console.stackch(channel,string,depth,priority);
         }
      }
      
      public static function inspect(obj:Object, showInherit:Boolean = true) : void
      {
         if(_console)
         {
            _console.inspect(obj,showInherit);
         }
      }
      
      public static function inspectch(channel:*, obj:Object, showInherit:Boolean = true) : void
      {
         if(_console)
         {
            _console.inspectch(channel,obj,showInherit);
         }
      }
      
      public static function explode(obj:Object, depth:int = 3) : void
      {
         if(_console)
         {
            _console.explode(obj,depth);
         }
      }
      
      public static function explodech(channel:*, obj:Object, depth:int = 3) : void
      {
         if(_console)
         {
            _console.explodech(channel,obj,depth);
         }
      }
      
      public static function addHTML(... rest) : void
      {
         if(_console)
         {
            _console.addHTML.apply(null,rest);
         }
      }
      
      public static function addHTMLch(channel:*, priority:int, ... rest) : void
      {
         if(_console)
         {
            _console.addHTMLch.apply(null,new Array(channel,priority).concat(rest));
         }
      }
      
      public static function map(container:DisplayObjectContainer, maxDepth:uint = 0) : void
      {
         if(_console)
         {
            _console.map(container,maxDepth);
         }
      }
      
      public static function mapch(channel:*, container:DisplayObjectContainer, maxDepth:uint = 0) : void
      {
         if(_console)
         {
            _console.mapch(channel,container,maxDepth);
         }
      }
      
      public static function clear(channel:String = null) : void
      {
         if(_console)
         {
            _console.clear(channel);
         }
      }
      
      public static function bindKey(key:KeyBind, callback:Function = null, args:Array = null) : void
      {
         if(_console)
         {
            _console.bindKey(key,callback,args);
         }
      }
      
      public static function addMenu(key:String, callback:Function, args:Array = null, rollover:String = null) : void
      {
         if(_console)
         {
            _console.addMenu(key,callback,args,rollover);
         }
      }
      
      public static function listenUncaughtErrors(loaderinfo:LoaderInfo) : void
      {
         if(_console)
         {
            _console.listenUncaughtErrors(loaderinfo);
         }
      }
      
      public static function store(name:String, obj:Object, useStrong:Boolean = false) : void
      {
         if(_console)
         {
            _console.store(name,obj,useStrong);
         }
      }
      
      public static function addSlashCommand(name:String, callback:Function, description:String = "", alwaysAvailable:Boolean = true, endOfArgsMarker:String = ";") : void
      {
         if(_console)
         {
            _console.addSlashCommand(name,callback,description,alwaysAvailable,endOfArgsMarker);
         }
      }
      
      public static function watch(obj:Object, name:String = null) : String
      {
         if(_console)
         {
            return _console.watch(obj,name);
         }
         return null;
      }
      
      public static function unwatch(name:String) : void
      {
         if(_console)
         {
            _console.unwatch(name);
         }
      }
      
      public static function addGraph(panelName:String, obj:Object, property:String, color:Number = -1, idKey:String = null, rectArea:Rectangle = null, inverse:Boolean = false) : void
      {
         if(_console)
         {
            _console.addGraph(panelName,obj,property,color,idKey,rectArea,inverse);
         }
      }
      
      public static function fixGraphRange(panelName:String, min:Number = NaN, max:Number = NaN) : void
      {
         if(_console)
         {
            _console.fixGraphRange(panelName,min,max);
         }
      }
      
      public static function removeGraph(panelName:String, obj:Object = null, property:String = null) : void
      {
         if(_console)
         {
            _console.removeGraph(panelName,obj,property);
         }
      }
      
      public static function setViewingChannels(... rest) : void
      {
         if(_console)
         {
            _console.setViewingChannels.apply(null,rest);
         }
      }
      
      public static function setIgnoredChannels(... rest) : void
      {
         if(_console)
         {
            _console.setIgnoredChannels.apply(null,rest);
         }
      }
      
      public static function set minimumPriority(level:uint) : void
      {
         if(_console)
         {
            _console.minimumPriority = level;
         }
      }
      
      public static function get width() : Number
      {
         if(_console)
         {
            return _console.width;
         }
         return 0;
      }
      
      public static function set width(v:Number) : void
      {
         if(_console)
         {
            _console.width = v;
         }
      }
      
      public static function get height() : Number
      {
         if(_console)
         {
            return _console.height;
         }
         return 0;
      }
      
      public static function set height(v:Number) : void
      {
         if(_console)
         {
            _console.height = v;
         }
      }
      
      public static function get x() : Number
      {
         if(_console)
         {
            return _console.x;
         }
         return 0;
      }
      
      public static function set x(v:Number) : void
      {
         if(_console)
         {
            _console.x = v;
         }
      }
      
      public static function get y() : Number
      {
         if(_console)
         {
            return _console.y;
         }
         return 0;
      }
      
      public static function set y(v:Number) : void
      {
         if(_console)
         {
            _console.y = v;
         }
      }
      
      public static function get visible() : Boolean
      {
         if(_console)
         {
            return _console.visible;
         }
         return false;
      }
      
      public static function set visible(v:Boolean) : void
      {
         if(_console)
         {
            _console.visible = v;
         }
      }
      
      public static function get fpsMonitor() : Boolean
      {
         if(_console)
         {
            return _console.fpsMonitor;
         }
         return false;
      }
      
      public static function set fpsMonitor(v:Boolean) : void
      {
         if(_console)
         {
            _console.fpsMonitor = v;
         }
      }
      
      public static function get memoryMonitor() : Boolean
      {
         if(_console)
         {
            return _console.memoryMonitor;
         }
         return false;
      }
      
      public static function set memoryMonitor(v:Boolean) : void
      {
         if(_console)
         {
            _console.memoryMonitor = v;
         }
      }
      
      public static function get commandLine() : Boolean
      {
         if(_console)
         {
            return _console.commandLine;
         }
         return false;
      }
      
      public static function set commandLine(v:Boolean) : void
      {
         if(_console)
         {
            _console.commandLine = v;
         }
      }
      
      public static function get displayRoller() : Boolean
      {
         if(_console)
         {
            return _console.displayRoller;
         }
         return false;
      }
      
      public static function set displayRoller(v:Boolean) : void
      {
         if(_console)
         {
            _console.displayRoller = v;
         }
      }
      
      public static function setRollerCaptureKey(character:String, ctrl:Boolean = false, alt:Boolean = false, shift:Boolean = false) : void
      {
         if(_console)
         {
            _console.setRollerCaptureKey(character,shift,ctrl,alt);
         }
      }
      
      public static function get remoting() : Boolean
      {
         if(_console)
         {
            return _console.remoting;
         }
         return false;
      }
      
      public static function set remoting(v:Boolean) : void
      {
         if(_console)
         {
            _console.remoting = v;
         }
      }
      
      public static function remotingSocket(host:String, port:int) : void
      {
         if(_console)
         {
            _console.remotingSocket(host,port);
         }
      }
      
      public static function remove() : void
      {
         if(_console)
         {
            if(_console.parent)
            {
               _console.parent.removeChild(_console);
            }
            _console = null;
         }
      }
      
      public static function getAllLog(splitter:String = "\r\n") : String
      {
         if(_console)
         {
            return _console.getAllLog(splitter);
         }
         return "";
      }
      
      public static function get instance() : Console
      {
         return _console;
      }
      
      private static function addedToStageHandle(e:Event) : void
      {
         var _loc2_:DisplayObjectContainer = e.currentTarget as DisplayObjectContainer;
         _loc2_.removeEventListener(Event.ADDED_TO_STAGE,addedToStageHandle);
         if(Boolean(_console) && _console.parent == null)
         {
            _loc2_.stage.addChild(_console);
         }
      }
   }
}

