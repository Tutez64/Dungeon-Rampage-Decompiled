package com.junkbyte.console
{
   import com.junkbyte.console.core.CommandLine;
   import com.junkbyte.console.core.ConsoleTools;
   import com.junkbyte.console.core.Graphing;
   import com.junkbyte.console.core.KeyBinder;
   import com.junkbyte.console.core.LogReferences;
   import com.junkbyte.console.core.Logs;
   import com.junkbyte.console.core.MemoryMonitor;
   import com.junkbyte.console.core.Remoting;
   import com.junkbyte.console.view.PanelsManager;
   import com.junkbyte.console.view.RollerPanel;
   import com.junkbyte.console.vos.Log;
   import flash.display.DisplayObjectContainer;
   import flash.display.LoaderInfo;
   import flash.display.Sprite;
   import flash.events.ErrorEvent;
   import flash.events.Event;
   import flash.events.IEventDispatcher;
   import flash.events.KeyboardEvent;
   import flash.geom.Rectangle;
   import flash.net.SharedObject;
   import flash.system.Capabilities;
   import flash.utils.getTimer;
   
   public class Console extends Sprite
   {
      
      public static const VERSION:Number = 2.6;
      
      public static const VERSION_STAGE:String = "";
      
      public static const BUILD:int = 611;
      
      public static const BUILD_DATE:String = "2012/02/22 00:11";
      
      public static const LOG:uint = 1;
      
      public static const INFO:uint = 3;
      
      public static const DEBUG:uint = 6;
      
      public static const WARN:uint = 8;
      
      public static const ERROR:uint = 9;
      
      public static const FATAL:uint = 10;
      
      public static const GLOBAL_CHANNEL:String = " * ";
      
      public static const DEFAULT_CHANNEL:String = "-";
      
      public static const CONSOLE_CHANNEL:String = "C";
      
      public static const FILTER_CHANNEL:String = "~";
      
      private var _config:ConsoleConfig;
      
      private var _panels:PanelsManager;
      
      private var _cl:CommandLine;
      
      private var _kb:KeyBinder;
      
      private var _refs:LogReferences;
      
      private var _mm:MemoryMonitor;
      
      private var _graphing:Graphing;
      
      private var _remoter:Remoting;
      
      private var _tools:ConsoleTools;
      
      private var _topTries:int = 50;
      
      private var _paused:Boolean;
      
      private var _rollerKey:KeyBind;
      
      private var _logs:Logs;
      
      private var _so:SharedObject;
      
      private var _soData:Object;
      
      public function Console(password:String = "", config:ConsoleConfig = null)
      {
         this._soData = {};
         super();
         name = "Console";
         if(config == null)
         {
            config = new ConsoleConfig();
         }
         this._config = config;
         if(password)
         {
            this._config.keystrokePassword = password;
         }
         this._remoter = new Remoting(this);
         this._logs = new Logs(this);
         this._refs = new LogReferences(this);
         this._cl = new CommandLine(this);
         this._tools = new ConsoleTools(this);
         this._graphing = new Graphing(this);
         this._mm = new MemoryMonitor(this);
         this._kb = new KeyBinder(this);
         this.cl.addCLCmd("remotingSocket",function(str:String = ""):void
         {
            var _loc2_:Array = str.split(/\s+|\:/);
            remotingSocket(_loc2_[0],_loc2_[1]);
         },"Connect to socket remote. /remotingSocket ip port");
         if(this._config.sharedObjectName)
         {
            try
            {
               this._so = SharedObject.getLocal(this._config.sharedObjectName,this._config.sharedObjectPath);
               this._soData = this._so.data;
            }
            catch(e:Error)
            {
            }
         }
         this._config.style.updateStyleSheet();
         this._panels = new PanelsManager(this);
         if(password)
         {
            this.visible = false;
         }
         this.report("<b>Console v" + VERSION + VERSION_STAGE + "</b> build " + BUILD + ". " + Capabilities.playerType + " " + Capabilities.version + ".",-2);
         addEventListener(Event.ENTER_FRAME,this._onEnterFrame);
         addEventListener(Event.ADDED_TO_STAGE,this.stageAddedHandle);
      }
      
      public static function MakeChannelName(obj:*) : String
      {
         if(obj is String)
         {
            return obj as String;
         }
         if(obj)
         {
            return LogReferences.ShortClassName(obj);
         }
         return DEFAULT_CHANNEL;
      }
      
      private function stageAddedHandle(e:Event = null) : void
      {
         if(this._cl.base == null)
         {
            this._cl.base = parent;
         }
         if(loaderInfo)
         {
            this.listenUncaughtErrors(loaderInfo);
         }
         removeEventListener(Event.ADDED_TO_STAGE,this.stageAddedHandle);
         addEventListener(Event.REMOVED_FROM_STAGE,this.stageRemovedHandle);
         stage.addEventListener(Event.MOUSE_LEAVE,this.onStageMouseLeave,false,0,true);
         stage.addEventListener(KeyboardEvent.KEY_DOWN,this._kb.keyDownHandler,false,0,true);
         stage.addEventListener(KeyboardEvent.KEY_UP,this._kb.keyUpHandler,false,0,true);
      }
      
      private function stageRemovedHandle(e:Event = null) : void
      {
         this._cl.base = null;
         removeEventListener(Event.REMOVED_FROM_STAGE,this.stageRemovedHandle);
         addEventListener(Event.ADDED_TO_STAGE,this.stageAddedHandle);
         stage.removeEventListener(Event.MOUSE_LEAVE,this.onStageMouseLeave);
         stage.removeEventListener(KeyboardEvent.KEY_DOWN,this._kb.keyDownHandler);
         stage.removeEventListener(KeyboardEvent.KEY_UP,this._kb.keyUpHandler);
      }
      
      private function onStageMouseLeave(e:Event) : void
      {
         this._panels.tooltip(null);
      }
      
      public function listenUncaughtErrors(loaderinfo:LoaderInfo) : void
      {
         var uncaughtErrorEvents:IEventDispatcher = null;
         try
         {
            uncaughtErrorEvents = loaderinfo["uncaughtErrorEvents"];
            if(uncaughtErrorEvents)
            {
               uncaughtErrorEvents.addEventListener("uncaughtError",this.uncaughtErrorHandle,false,0,true);
            }
         }
         catch(err:Error)
         {
         }
      }
      
      private function uncaughtErrorHandle(e:Event) : void
      {
         var _loc3_:String = null;
         var _loc2_:* = e.hasOwnProperty("error") ? e["error"] : e;
         if(_loc2_ is Error)
         {
            _loc3_ = this._refs.makeString(_loc2_);
         }
         else if(_loc2_ is ErrorEvent)
         {
            _loc3_ = ErrorEvent(_loc2_).text;
         }
         if(!_loc3_)
         {
            _loc3_ = String(_loc2_);
         }
         this.report(_loc3_,FATAL,false);
      }
      
      public function addGraph(name:String, obj:Object, property:String, color:Number = -1, key:String = null, rect:Rectangle = null, inverse:Boolean = false) : void
      {
         this._graphing.add(name,obj,property,color,key,rect,inverse);
      }
      
      public function fixGraphRange(name:String, min:Number = NaN, max:Number = NaN) : void
      {
         this._graphing.fixRange(name,min,max);
      }
      
      public function removeGraph(name:String, obj:Object = null, property:String = null) : void
      {
         this._graphing.remove(name,obj,property);
      }
      
      public function bindKey(key:KeyBind, callback:Function, args:Array = null) : void
      {
         if(key)
         {
            this._kb.bindKey(key,callback,args);
         }
      }
      
      public function addMenu(key:String, callback:Function, args:Array = null, rollover:String = null) : void
      {
         this.panels.mainPanel.addMenu(key,callback,args,rollover);
      }
      
      public function get displayRoller() : Boolean
      {
         return this._panels.displayRoller;
      }
      
      public function set displayRoller(b:Boolean) : void
      {
         this._panels.displayRoller = b;
      }
      
      public function setRollerCaptureKey(char:String, shift:Boolean = false, ctrl:Boolean = false, alt:Boolean = false) : void
      {
         if(this._rollerKey)
         {
            this.bindKey(this._rollerKey,null);
            this._rollerKey = null;
         }
         if(Boolean(char) && char.length == 1)
         {
            this._rollerKey = new KeyBind(char,shift,ctrl,alt);
            this.bindKey(this._rollerKey,this.onRollerCaptureKey);
         }
      }
      
      public function get rollerCaptureKey() : KeyBind
      {
         return this._rollerKey;
      }
      
      private function onRollerCaptureKey() : void
      {
         if(this.displayRoller)
         {
            this.report("Display Roller Capture:<br/>" + RollerPanel(this._panels.getPanel(RollerPanel.NAME)).getMapString(true),-1);
         }
      }
      
      public function get fpsMonitor() : Boolean
      {
         return this._graphing.fpsMonitor;
      }
      
      public function set fpsMonitor(b:Boolean) : void
      {
         this._graphing.fpsMonitor = b;
      }
      
      public function get memoryMonitor() : Boolean
      {
         return this._graphing.memoryMonitor;
      }
      
      public function set memoryMonitor(b:Boolean) : void
      {
         this._graphing.memoryMonitor = b;
      }
      
      public function watch(object:Object, name:String = null) : String
      {
         return this._mm.watch(object,name);
      }
      
      public function unwatch(name:String) : void
      {
         this._mm.unwatch(name);
      }
      
      public function gc() : void
      {
         this._mm.gc();
      }
      
      public function store(name:String, obj:Object, strong:Boolean = false) : void
      {
         this._cl.store(name,obj,strong);
      }
      
      public function map(container:DisplayObjectContainer, maxstep:uint = 0) : void
      {
         this._tools.map(container,maxstep,DEFAULT_CHANNEL);
      }
      
      public function mapch(channel:*, container:DisplayObjectContainer, maxstep:uint = 0) : void
      {
         this._tools.map(container,maxstep,MakeChannelName(channel));
      }
      
      public function inspect(obj:Object, showInherit:Boolean = true) : void
      {
         this._refs.inspect(obj,showInherit,DEFAULT_CHANNEL);
      }
      
      public function inspectch(channel:*, obj:Object, showInherit:Boolean = true) : void
      {
         this._refs.inspect(obj,showInherit,MakeChannelName(channel));
      }
      
      public function explode(obj:Object, depth:int = 3) : void
      {
         this.addLine(new Array(this._tools.explode(obj,depth)),1,null,false,true);
      }
      
      public function explodech(channel:*, obj:Object, depth:int = 3) : void
      {
         this.addLine(new Array(this._tools.explode(obj,depth)),1,channel,false,true);
      }
      
      public function get paused() : Boolean
      {
         return this._paused;
      }
      
      public function set paused(newV:Boolean) : void
      {
         if(this._paused == newV)
         {
            return;
         }
         if(newV)
         {
            this.report("Paused",10);
         }
         else
         {
            this.report("Resumed",-1);
         }
         this._paused = newV;
         this._panels.mainPanel.setPaused(newV);
      }
      
      override public function get width() : Number
      {
         return this._panels.mainPanel.width;
      }
      
      override public function set width(newW:Number) : void
      {
         this._panels.mainPanel.width = newW;
      }
      
      override public function set height(newW:Number) : void
      {
         this._panels.mainPanel.height = newW;
      }
      
      override public function get height() : Number
      {
         return this._panels.mainPanel.height;
      }
      
      override public function get x() : Number
      {
         return this._panels.mainPanel.x;
      }
      
      override public function set x(newW:Number) : void
      {
         this._panels.mainPanel.x = newW;
      }
      
      override public function set y(newW:Number) : void
      {
         this._panels.mainPanel.y = newW;
      }
      
      override public function get y() : Number
      {
         return this._panels.mainPanel.y;
      }
      
      override public function set visible(v:Boolean) : void
      {
         super.visible = v;
         if(v)
         {
            this._panels.mainPanel.visible = true;
         }
      }
      
      private function _onEnterFrame(e:Event) : void
      {
         var _loc4_:Array = null;
         var _loc2_:int = getTimer();
         var _loc3_:Boolean = this._logs.update(_loc2_);
         this._refs.update(_loc2_);
         this._mm.update();
         if(this.remoter.remoting != Remoting.RECIEVER)
         {
            _loc4_ = this._graphing.update(stage ? stage.frameRate : 0);
         }
         this._remoter.update();
         if(visible && Boolean(parent))
         {
            if(this.config.alwaysOnTop && parent.getChildAt(parent.numChildren - 1) != this && this._topTries > 0)
            {
               --this._topTries;
               parent.addChild(this);
               this.report("Moved console on top (alwaysOnTop enabled), " + this._topTries + " attempts left.",-1);
            }
            this._panels.update(this._paused,_loc3_);
            if(_loc4_)
            {
               this._panels.updateGraphs(_loc4_);
            }
         }
      }
      
      public function get remoting() : Boolean
      {
         return this._remoter.remoting == Remoting.SENDER;
      }
      
      public function set remoting(b:Boolean) : void
      {
         this._remoter.remoting = b ? Remoting.SENDER : Remoting.NONE;
      }
      
      public function remotingSocket(host:String, port:int) : void
      {
         this._remoter.remotingSocket(host,port);
      }
      
      public function setViewingChannels(... rest) : void
      {
         this._panels.mainPanel.setViewingChannels.apply(this,rest);
      }
      
      public function setIgnoredChannels(... rest) : void
      {
         this._panels.mainPanel.setIgnoredChannels.apply(this,rest);
      }
      
      public function set minimumPriority(level:uint) : void
      {
         this._panels.mainPanel.priority = level;
      }
      
      public function report(obj:*, priority:int = 0, skipSafe:Boolean = true, channel:String = null) : void
      {
         if(!channel)
         {
            channel = this._panels.mainPanel.reportChannel;
         }
         this.addLine([obj],priority,channel,false,skipSafe,0);
      }
      
      public function addLine(strings:Array, priority:int = 0, channel:* = null, isRepeating:Boolean = false, html:Boolean = false, stacks:int = -1) : void
      {
         var _loc7_:String = "";
         var _loc8_:int = int(strings.length);
         var _loc9_:* = 0;
         while(_loc9_ < _loc8_)
         {
            _loc7_ += (_loc9_ ? " " : "") + this._refs.makeString(strings[_loc9_],null,html);
            _loc9_++;
         }
         if(priority >= this._config.autoStackPriority && stacks < 0)
         {
            stacks = this._config.defaultStackDepth;
         }
         if(!html && stacks > 0)
         {
            _loc7_ += this._tools.getStack(stacks,priority);
         }
         this._logs.add(new Log(_loc7_,MakeChannelName(channel),priority,isRepeating,html));
      }
      
      public function set commandLine(b:Boolean) : void
      {
         this._panels.mainPanel.commandLine = b;
      }
      
      public function get commandLine() : Boolean
      {
         return this._panels.mainPanel.commandLine;
      }
      
      public function addSlashCommand(name:String, callback:Function, desc:String = "", alwaysAvailable:Boolean = true, endOfArgsMarker:String = ";") : void
      {
         this._cl.addSlashCommand(name,callback,desc,alwaysAvailable,endOfArgsMarker);
      }
      
      public function add(string:*, priority:int = 2, isRepeating:Boolean = false) : void
      {
         this.addLine([string],priority,DEFAULT_CHANNEL,isRepeating);
      }
      
      public function stack(string:*, depth:int = -1, priority:int = 5) : void
      {
         this.addLine([string],priority,DEFAULT_CHANNEL,false,false,depth >= 0 ? depth : this._config.defaultStackDepth);
      }
      
      public function stackch(channel:*, string:*, depth:int = -1, priority:int = 5) : void
      {
         this.addLine([string],priority,channel,false,false,depth >= 0 ? depth : this._config.defaultStackDepth);
      }
      
      public function log(... rest) : void
      {
         this.addLine(rest,LOG);
      }
      
      public function info(... rest) : void
      {
         this.addLine(rest,INFO);
      }
      
      public function debug(... rest) : void
      {
         this.addLine(rest,DEBUG);
      }
      
      public function warn(... rest) : void
      {
         this.addLine(rest,WARN);
      }
      
      public function error(... rest) : void
      {
         this.addLine(rest,ERROR);
      }
      
      public function fatal(... rest) : void
      {
         this.addLine(rest,FATAL);
      }
      
      public function ch(channel:*, string:*, priority:int = 2, isRepeating:Boolean = false) : void
      {
         this.addLine([string],priority,channel,isRepeating);
      }
      
      public function logch(channel:*, ... rest) : void
      {
         this.addLine(rest,LOG,channel);
      }
      
      public function infoch(channel:*, ... rest) : void
      {
         this.addLine(rest,INFO,channel);
      }
      
      public function debugch(channel:*, ... rest) : void
      {
         this.addLine(rest,DEBUG,channel);
      }
      
      public function warnch(channel:*, ... rest) : void
      {
         this.addLine(rest,WARN,channel);
      }
      
      public function errorch(channel:*, ... rest) : void
      {
         this.addLine(rest,ERROR,channel);
      }
      
      public function fatalch(channel:*, ... rest) : void
      {
         this.addLine(rest,FATAL,channel);
      }
      
      public function addCh(channel:*, strings:Array, priority:int = 2, isRepeating:Boolean = false) : void
      {
         this.addLine(strings,priority,channel,isRepeating);
      }
      
      public function addHTML(... rest) : void
      {
         this.addLine(rest,2,DEFAULT_CHANNEL,false,this.testHTML(rest));
      }
      
      public function addHTMLch(channel:*, priority:int, ... rest) : void
      {
         this.addLine(rest,priority,channel,false,this.testHTML(rest));
      }
      
      private function testHTML(args:Array) : Boolean
      {
         try
         {
            new XML("<p>" + args.join("") + "</p>");
         }
         catch(err:Error)
         {
            return false;
         }
         return true;
      }
      
      public function clear(channel:String = null) : void
      {
         this._logs.clear(channel);
         if(!this._paused)
         {
            this._panels.mainPanel.updateToBottom();
         }
         this._panels.updateMenu();
      }
      
      public function getAllLog(splitter:String = "\r\n") : String
      {
         return this._logs.getLogsAsString(splitter);
      }
      
      public function get config() : ConsoleConfig
      {
         return this._config;
      }
      
      public function get panels() : PanelsManager
      {
         return this._panels;
      }
      
      public function get cl() : CommandLine
      {
         return this._cl;
      }
      
      public function get remoter() : Remoting
      {
         return this._remoter;
      }
      
      public function get graphing() : Graphing
      {
         return this._graphing;
      }
      
      public function get refs() : LogReferences
      {
         return this._refs;
      }
      
      public function get logs() : Logs
      {
         return this._logs;
      }
      
      public function get mapper() : ConsoleTools
      {
         return this._tools;
      }
      
      public function get so() : Object
      {
         return this._soData;
      }
      
      public function updateSO(key:String = null) : void
      {
         if(this._so)
         {
            if(key)
            {
               this._so.setDirty(key);
            }
            else
            {
               this._so.clear();
            }
         }
      }
   }
}

