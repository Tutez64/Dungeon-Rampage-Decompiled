package com.junkbyte.console
{
   import com.junkbyte.console.compat.ConsoleLib;
   import com.junkbyte.console.core.CommandLine;
   import com.junkbyte.console.core.ConsoleTools;
   import com.junkbyte.console.core.Graphing;
   import com.junkbyte.console.core.KeyBinder;
   import com.junkbyte.console.core.LogReferences;
   import com.junkbyte.console.core.Logs;
   import com.junkbyte.console.core.MemoryMonitor;
   import com.junkbyte.console.core.Remoting;
   import com.junkbyte.console.utils.FlashRegex;
   import com.junkbyte.console.view.ConsolePanel;
   import com.junkbyte.console.view.MainPanel;
   import com.junkbyte.console.view.PanelsManager;
   import com.junkbyte.console.view.RollerPanel;
   import com.junkbyte.console.vos.Log;
   import flash.Boot;
   import flash.display.DisplayObjectContainer;
   import flash.display.LoaderInfo;
   import flash.display.Sprite;
   import flash.display.Stage;
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
      
      public static var VERSION:Number = 2.6;
      
      public static var VERSION_STAGE:String = "";
      
      public static var BUILD:uint = 611;
      
      public static var BUILD_DATE:String = "2012/02/22 00:11";
      
      public static var LOG:uint = 1;
      
      public static var INFO:uint = 3;
      
      public static var DEBUG:uint = 6;
      
      public static var WARN:uint = 8;
      
      public static var ERROR:uint = 9;
      
      public static var FATAL:uint = 10;
      
      public static var GLOBAL_CHANNEL:String = " * ";
      
      public static var DEFAULT_CHANNEL:String = "-";
      
      public static var CONSOLE_CHANNEL:String = "C";
      
      public static var FILTER_CHANNEL:String = "~";
      
      public var _topTries:int;
      
      public var _tools:ConsoleTools;
      
      public var _soData:*;
      
      public var _so:SharedObject;
      
      public var _rollerKey:KeyBind;
      
      public var _remoter:Remoting;
      
      public var _refs:LogReferences;
      
      public var _paused:Boolean;
      
      public var _panels:PanelsManager;
      
      public var _mm:MemoryMonitor;
      
      public var _logs:Logs;
      
      public var _kb:KeyBinder;
      
      public var _graphing:Graphing;
      
      public var _config:ConsoleConfig;
      
      public var _cl:CommandLine;
      
      public function Console(password:String = undefined, config:ConsoleConfig = undefined)
      {
         var _gthis:Console;
         var _loc4_:* = null as Error;
         if(password == null)
         {
            password = "";
         }
         if(!Boot.skip_constructor)
         {
            _soData = {};
            _topTries = 50;
            _gthis = this;
            super();
            name = "Console";
            if(config == null)
            {
               config = new ConsoleConfig();
            }
            _config = config;
            if(password != null && password != "")
            {
               _config.keystrokePassword = password;
            }
            _remoter = new Remoting(this);
            _logs = new Logs(this);
            _refs = new LogReferences(this);
            _cl = new CommandLine(this);
            _tools = new ConsoleTools(this);
            _graphing = new Graphing(this);
            _mm = new MemoryMonitor(this);
            _kb = new KeyBinder(this);
            get_cl().addCLCmd("remotingSocket",function(str:String = undefined):void
            {
               if(str == null)
               {
                  str = "";
               }
               var _loc2_:Array = FlashRegex.split(str,new EReg("\\s+|:",""));
               _gthis.remotingSocket(_loc2_[0],ConsoleLib.parseInt(_loc2_[1]));
            },"Connect to socket remote. /remotingSocket ip port");
            if(_config.sharedObjectName != null)
            {
               try
               {
                  _so = SharedObject.getLocal(_config.sharedObjectName,_config.sharedObjectPath);
                  _soData = _so.data;
               }
               catch(_loc_e_:Error)
               {
                  _loc4_ = _loc_e_;
               }
            }
            _config.get_style().updateStyleSheet();
            _panels = new PanelsManager(this);
            if(password != null && password != "")
            {
               set_visible(false);
            }
            report("<b>Console v" + 2.6 + "" + "</b> build " + "611" + ". " + Capabilities.playerType + " " + Capabilities.version + ".",-2);
            addEventListener(Event.ENTER_FRAME,_onEnterFrame);
            addEventListener(Event.ADDED_TO_STAGE,stageAddedHandle);
         }
      }
      
      public static function MakeChannelName(obj:*) : String
      {
         if(obj is String)
         {
            var _temp_1:* = obj;
            §§push(_temp_1);
            if(!(_temp_1 is String))
            {
               throw "Class cast error";
            }
            return §§pop();
         }
         if(obj)
         {
            return LogReferences.ShortClassName(obj);
         }
         return "-";
      }
      
      public function watch(object:*, name:String = undefined) : String
      {
         return _mm.watch(object,name);
      }
      
      public function warnch(channel:*, ... rest) : void
      {
         addLine(rest.copy(),8,channel);
      }
      
      public function warn(... rest) : void
      {
         addLine(rest.copy(),8);
      }
      
      public function updateSO(key:String = undefined) : void
      {
         if(_so != null)
         {
            if(key != null)
            {
               _so.setDirty(key);
            }
            else
            {
               _so.clear();
            }
         }
      }
      
      public function unwatch(name:String) : void
      {
         _mm.unwatch(name);
      }
      
      public function uncaughtErrorHandle(e:Event) : void
      {
         var _loc2_:* = Reflect.hasField(e,"error") ? Reflect.field(e,"error") : e;
         var _loc3_:String = null;
         if(_loc2_ is Error)
         {
            _loc3_ = _refs.makeString(_loc2_);
         }
         else if(_loc2_ is ErrorEvent)
         {
            _loc3_ = _loc2_.text;
         }
         if(_loc3_ == null)
         {
            _loc3_ = Std.string(_loc2_);
         }
         report(_loc3_,10,false);
      }
      
      public function testHTML(args:Array) : Boolean
      {
         var _loc3_:* = null;
         try
         {
            new XML("<p>" + args.join("") + "</p>");
         }
         catch(_loc_e_:*)
         {
            _loc3_ = _loc_e_;
            null;
            return false;
         }
         return true;
      }
      
      public function store(name:String, obj:*, strong:Boolean = false) : void
      {
         _cl.store(name,obj,strong);
      }
      
      public function stageRemovedHandle(e:Event = undefined) : void
      {
         _cl.set_base(null);
         removeEventListener(Event.REMOVED_FROM_STAGE,stageRemovedHandle);
         addEventListener(Event.ADDED_TO_STAGE,stageAddedHandle);
         stage.removeEventListener(Event.MOUSE_LEAVE,onStageMouseLeave);
         stage.removeEventListener(KeyboardEvent.KEY_DOWN,_kb.keyDownHandler);
         stage.removeEventListener(KeyboardEvent.KEY_UP,_kb.keyUpHandler);
      }
      
      public function stageAddedHandle(e:Event = undefined) : void
      {
         if(_cl.get_base() == null)
         {
            _cl.set_base(parent);
         }
         if(loaderInfo != null)
         {
            listenUncaughtErrors(loaderInfo);
         }
         removeEventListener(Event.ADDED_TO_STAGE,stageAddedHandle);
         addEventListener(Event.REMOVED_FROM_STAGE,stageRemovedHandle);
         stage.addEventListener(Event.MOUSE_LEAVE,onStageMouseLeave,false,0,true);
         stage.addEventListener(KeyboardEvent.KEY_DOWN,_kb.keyDownHandler,false,0,true);
         stage.addEventListener(KeyboardEvent.KEY_UP,_kb.keyUpHandler,false,0,true);
      }
      
      public function stackch(channel:*, string:*, depth:int = -1, priority:int = 5) : void
      {
         addLine([string],priority,channel,false,false,depth >= 0 ? depth : _config.defaultStackDepth);
      }
      
      public function stack(string:*, depth:int = -1, priority:int = 5) : void
      {
         addLine([string],priority,"-",false,false,depth >= 0 ? depth : _config.defaultStackDepth);
      }
      
      public function set_y(value:Number) : Number
      {
         _panels.get_mainPanel().y = value;
         return value;
      }
      
      override public function set y(value:Number) : void
      {
         set_y(value);
      }
      
      public function set_x(value:Number) : Number
      {
         _panels.get_mainPanel().x = value;
         return value;
      }
      
      override public function set x(value:Number) : void
      {
         set_x(value);
      }
      
      public function set_width(value:Number) : Number
      {
         _panels.get_mainPanel().set_width(value);
         return value;
      }
      
      override public function set width(value:Number) : void
      {
         set_width(value);
      }
      
      public function set_visible(value:Boolean) : Boolean
      {
         super.visible = value;
         if(value)
         {
            _panels.get_mainPanel().set_visible(true);
         }
         return value;
      }
      
      override public function set visible(value:Boolean) : void
      {
         set_visible(value);
      }
      
      public function set_remoting(b:Boolean) : Boolean
      {
         _remoter.set_remoting(b ? 1 : 0);
         return b;
      }
      
      public function set remoting(value:Boolean) : void
      {
         set_remoting(value);
      }
      
      public function set_paused(newV:Boolean) : Boolean
      {
         if(_paused == newV)
         {
            return newV;
         }
         if(newV)
         {
            report("Paused",10);
         }
         else
         {
            report("Resumed",-1);
         }
         _paused = newV;
         _panels.get_mainPanel().setPaused(newV);
         return newV;
      }
      
      public function set paused(value:Boolean) : void
      {
         set_paused(value);
      }
      
      public function set_minimumPriority(level:uint) : uint
      {
         _panels.get_mainPanel().set_priority(level);
         return level;
      }
      
      public function set minimumPriority(value:uint) : void
      {
         set_minimumPriority(value);
      }
      
      public function set_memoryMonitor(b:Boolean) : Boolean
      {
         _graphing.set_memoryMonitor(b);
         return b;
      }
      
      public function set memoryMonitor(value:Boolean) : void
      {
         set_memoryMonitor(value);
      }
      
      public function set_height(value:Number) : Number
      {
         _panels.get_mainPanel().set_height(value);
         return value;
      }
      
      override public function set height(value:Number) : void
      {
         set_height(value);
      }
      
      public function set_fpsMonitor(b:Boolean) : Boolean
      {
         _graphing.set_fpsMonitor(b);
         return b;
      }
      
      public function set fpsMonitor(value:Boolean) : void
      {
         set_fpsMonitor(value);
      }
      
      public function set_displayRoller(b:Boolean) : Boolean
      {
         _panels.set_displayRoller(b);
         return b;
      }
      
      public function set displayRoller(value:Boolean) : void
      {
         set_displayRoller(value);
      }
      
      public function set_commandLine(b:Boolean) : Boolean
      {
         _panels.get_mainPanel().set_commandLine(b);
         return b;
      }
      
      public function set commandLine(value:Boolean) : void
      {
         set_commandLine(value);
      }
      
      public function setViewingChannels(... rest) : void
      {
         if(int(rest.length) == 0)
         {
            _panels.get_mainPanel().setViewingChannels();
         }
         else if(int(rest.length) == 1)
         {
            _panels.get_mainPanel().setViewingChannels(rest[0]);
         }
         else if(int(rest.length) == 2)
         {
            _panels.get_mainPanel().setViewingChannels(rest[0],rest[1]);
         }
         else if(int(rest.length) == 3)
         {
            _panels.get_mainPanel().setViewingChannels(rest[0],rest[1],rest[2]);
         }
         else if(int(rest.length) == 4)
         {
            _panels.get_mainPanel().setViewingChannels(rest[0],rest[1],rest[2],rest[3]);
         }
         else if(int(rest.length) == 5)
         {
            _panels.get_mainPanel().setViewingChannels(rest[0],rest[1],rest[2],rest[3],rest[4]);
         }
         else if(int(rest.length) == 6)
         {
            _panels.get_mainPanel().setViewingChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5]);
         }
         else if(int(rest.length) == 7)
         {
            _panels.get_mainPanel().setViewingChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6]);
         }
         else if(int(rest.length) == 8)
         {
            _panels.get_mainPanel().setViewingChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7]);
         }
         else if(int(rest.length) == 9)
         {
            _panels.get_mainPanel().setViewingChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8]);
         }
         else if(int(rest.length) == 10)
         {
            _panels.get_mainPanel().setViewingChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9]);
         }
         else if(int(rest.length) == 11)
         {
            _panels.get_mainPanel().setViewingChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10]);
         }
         else if(int(rest.length) == 12)
         {
            _panels.get_mainPanel().setViewingChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11]);
         }
         else if(int(rest.length) == 13)
         {
            _panels.get_mainPanel().setViewingChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12]);
         }
         else if(int(rest.length) == 14)
         {
            _panels.get_mainPanel().setViewingChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13]);
         }
         else if(int(rest.length) == 15)
         {
            _panels.get_mainPanel().setViewingChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14]);
         }
         else if(int(rest.length) == 16)
         {
            _panels.get_mainPanel().setViewingChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15]);
         }
         else if(int(rest.length) == 17)
         {
            _panels.get_mainPanel().setViewingChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15],rest[16]);
         }
         else if(int(rest.length) == 18)
         {
            _panels.get_mainPanel().setViewingChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15],rest[16],rest[17]);
         }
         else if(int(rest.length) == 19)
         {
            _panels.get_mainPanel().setViewingChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15],rest[16],rest[17],rest[18]);
         }
         else
         {
            if(int(rest.length) != 20)
            {
               throw "Too many rest arguments";
            }
            _panels.get_mainPanel().setViewingChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15],rest[16],rest[17],rest[18],rest[19]);
         }
      }
      
      public function setRollerCaptureKey(char:String, shift:Boolean = false, ctrl:Boolean = false, alt:Boolean = false) : void
      {
         if(_rollerKey != null)
         {
            bindKey(_rollerKey,null);
            _rollerKey = null;
         }
         if(char != null && char.length == 1)
         {
            _rollerKey = new KeyBind(char,shift,ctrl,alt);
            bindKey(_rollerKey,onRollerCaptureKey);
         }
      }
      
      public function setIgnoredChannels(... rest) : void
      {
         if(int(rest.length) == 0)
         {
            _panels.get_mainPanel().setIgnoredChannels();
         }
         else if(int(rest.length) == 1)
         {
            _panels.get_mainPanel().setIgnoredChannels(rest[0]);
         }
         else if(int(rest.length) == 2)
         {
            _panels.get_mainPanel().setIgnoredChannels(rest[0],rest[1]);
         }
         else if(int(rest.length) == 3)
         {
            _panels.get_mainPanel().setIgnoredChannels(rest[0],rest[1],rest[2]);
         }
         else if(int(rest.length) == 4)
         {
            _panels.get_mainPanel().setIgnoredChannels(rest[0],rest[1],rest[2],rest[3]);
         }
         else if(int(rest.length) == 5)
         {
            _panels.get_mainPanel().setIgnoredChannels(rest[0],rest[1],rest[2],rest[3],rest[4]);
         }
         else if(int(rest.length) == 6)
         {
            _panels.get_mainPanel().setIgnoredChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5]);
         }
         else if(int(rest.length) == 7)
         {
            _panels.get_mainPanel().setIgnoredChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6]);
         }
         else if(int(rest.length) == 8)
         {
            _panels.get_mainPanel().setIgnoredChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7]);
         }
         else if(int(rest.length) == 9)
         {
            _panels.get_mainPanel().setIgnoredChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8]);
         }
         else if(int(rest.length) == 10)
         {
            _panels.get_mainPanel().setIgnoredChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9]);
         }
         else if(int(rest.length) == 11)
         {
            _panels.get_mainPanel().setIgnoredChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10]);
         }
         else if(int(rest.length) == 12)
         {
            _panels.get_mainPanel().setIgnoredChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11]);
         }
         else if(int(rest.length) == 13)
         {
            _panels.get_mainPanel().setIgnoredChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12]);
         }
         else if(int(rest.length) == 14)
         {
            _panels.get_mainPanel().setIgnoredChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13]);
         }
         else if(int(rest.length) == 15)
         {
            _panels.get_mainPanel().setIgnoredChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14]);
         }
         else if(int(rest.length) == 16)
         {
            _panels.get_mainPanel().setIgnoredChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15]);
         }
         else if(int(rest.length) == 17)
         {
            _panels.get_mainPanel().setIgnoredChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15],rest[16]);
         }
         else if(int(rest.length) == 18)
         {
            _panels.get_mainPanel().setIgnoredChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15],rest[16],rest[17]);
         }
         else if(int(rest.length) == 19)
         {
            _panels.get_mainPanel().setIgnoredChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15],rest[16],rest[17],rest[18]);
         }
         else
         {
            if(int(rest.length) != 20)
            {
               throw "Too many rest arguments";
            }
            _panels.get_mainPanel().setIgnoredChannels(rest[0],rest[1],rest[2],rest[3],rest[4],rest[5],rest[6],rest[7],rest[8],rest[9],rest[10],rest[11],rest[12],rest[13],rest[14],rest[15],rest[16],rest[17],rest[18],rest[19]);
         }
      }
      
      public function report(obj:*, priority:int = 0, skipSafe:Boolean = true, channel:String = undefined) : void
      {
         if(channel == null)
         {
            channel = _panels.get_mainPanel().get_reportChannel();
         }
         addLine([obj],priority,channel,false,skipSafe,0);
      }
      
      public function removeGraph(name:String, obj:* = undefined, property:String = undefined) : void
      {
         _graphing.remove(name,obj,property);
      }
      
      public function remotingSocket(host:String, port:int) : void
      {
         _remoter.remotingSocket(host,port);
      }
      
      public function onStageMouseLeave(e:Event) : void
      {
         _panels.tooltip(null);
      }
      
      public function onRollerCaptureKey() : void
      {
         if(get_displayRoller())
         {
            report("Display Roller Capture:<br/>" + _panels.getPanel("rollerPanel").getMapString(true),-1);
         }
      }
      
      public function mapch(channel:*, container:DisplayObjectContainer, maxstep:uint = 0) : void
      {
         _tools.map(container,maxstep,Console.MakeChannelName(channel));
      }
      
      public function map(container:DisplayObjectContainer, maxstep:uint = 0) : void
      {
         _tools.map(container,maxstep,"-");
      }
      
      public function logch(channel:*, ... rest) : void
      {
         addLine(rest.copy(),1,channel);
      }
      
      public function log(... rest) : void
      {
         addLine(rest.copy(),1);
      }
      
      public function listenUncaughtErrors(loaderinfo:LoaderInfo) : void
      {
         var _loc3_:* = null as IEventDispatcher;
         var _loc4_:* = null as Error;
         try
         {
            _loc3_ = Reflect.field(loaderinfo,"uncaughtErrorEvents");
            if(_loc3_ != null)
            {
               _loc3_.addEventListener("uncaughtError",uncaughtErrorHandle,false,0,true);
            }
         }
         catch(_loc_e_:Error)
         {
            _loc4_ = _loc_e_;
         }
      }
      
      public function inspectch(channel:*, obj:*, showInherit:Boolean = true) : void
      {
         _refs.inspect(obj,showInherit,Console.MakeChannelName(channel));
      }
      
      public function inspect(obj:*, showInherit:Boolean = true) : void
      {
         _refs.inspect(obj,showInherit,"-");
      }
      
      public function infoch(channel:*, ... rest) : void
      {
         addLine(rest.copy(),3,channel);
      }
      
      public function info(... rest) : void
      {
         addLine(rest.copy(),3);
      }
      
      public function get_y() : Number
      {
         return _panels.get_mainPanel().y;
      }
      
      override public function get y() : Number
      {
         return get_y();
      }
      
      public function get_x() : Number
      {
         return _panels.get_mainPanel().x;
      }
      
      override public function get x() : Number
      {
         return get_x();
      }
      
      public function get_width() : Number
      {
         return _panels.get_mainPanel().get_width();
      }
      
      override public function get width() : Number
      {
         return get_width();
      }
      
      public function get_so() : *
      {
         return _soData;
      }
      
      public function get so() : *
      {
         return get_so();
      }
      
      public function get_rollerCaptureKey() : KeyBind
      {
         return _rollerKey;
      }
      
      public function get rollerCaptureKey() : KeyBind
      {
         return get_rollerCaptureKey();
      }
      
      public function get_remoting() : Boolean
      {
         return _remoter.get_remoting() == 1;
      }
      
      public function get remoting() : Boolean
      {
         return get_remoting();
      }
      
      public function get_remoter() : Remoting
      {
         return _remoter;
      }
      
      public function get remoter() : Remoting
      {
         return get_remoter();
      }
      
      public function get_refs() : LogReferences
      {
         return _refs;
      }
      
      public function get refs() : LogReferences
      {
         return get_refs();
      }
      
      public function get_paused() : Boolean
      {
         return _paused;
      }
      
      public function get paused() : Boolean
      {
         return get_paused();
      }
      
      public function get_panels() : PanelsManager
      {
         return _panels;
      }
      
      public function get panels() : PanelsManager
      {
         return get_panels();
      }
      
      public function get_memoryMonitor() : Boolean
      {
         return _graphing.get_memoryMonitor();
      }
      
      public function get memoryMonitor() : Boolean
      {
         return get_memoryMonitor();
      }
      
      public function get_mapper() : ConsoleTools
      {
         return _tools;
      }
      
      public function get mapper() : ConsoleTools
      {
         return get_mapper();
      }
      
      public function get_logs() : Logs
      {
         return _logs;
      }
      
      public function get logs() : Logs
      {
         return get_logs();
      }
      
      public function get_height() : Number
      {
         return _panels.get_mainPanel().get_height();
      }
      
      override public function get height() : Number
      {
         return get_height();
      }
      
      public function get_graphing() : Graphing
      {
         return _graphing;
      }
      
      public function get graphing() : Graphing
      {
         return get_graphing();
      }
      
      public function get_fpsMonitor() : Boolean
      {
         return _graphing.get_fpsMonitor();
      }
      
      public function get fpsMonitor() : Boolean
      {
         return get_fpsMonitor();
      }
      
      public function get_displayRoller() : Boolean
      {
         return _panels.get_displayRoller();
      }
      
      public function get displayRoller() : Boolean
      {
         return get_displayRoller();
      }
      
      public function get_config() : ConsoleConfig
      {
         return _config;
      }
      
      public function get config() : ConsoleConfig
      {
         return get_config();
      }
      
      public function get_commandLine() : Boolean
      {
         return _panels.get_mainPanel().get_commandLine();
      }
      
      public function get commandLine() : Boolean
      {
         return get_commandLine();
      }
      
      public function get_cl() : CommandLine
      {
         return _cl;
      }
      
      public function get cl() : CommandLine
      {
         return get_cl();
      }
      
      public function getAllLog(splitter:String = undefined) : String
      {
         if(splitter == null)
         {
            splitter = "\r\n";
         }
         return _logs.getLogsAsString(splitter);
      }
      
      public function gc() : void
      {
         _mm.gc();
      }
      
      public function fixGraphRange(name:String, min:Object = undefined, max:Object = undefined) : void
      {
         if(min == null)
         {
            min = Number(Number.NaN);
         }
         if(max == null)
         {
            max = Number(Number.NaN);
         }
         _graphing.fixRange(name,min,max);
      }
      
      public function fatalch(channel:*, ... rest) : void
      {
         addLine(rest.copy(),10,channel);
      }
      
      public function fatal(... rest) : void
      {
         addLine(rest.copy(),10);
      }
      
      public function explodech(channel:*, obj:*, depth:int = 3) : void
      {
         addLine([_tools.explode(obj,depth)],1,channel,false,true);
      }
      
      public function explode(obj:*, depth:int = 3) : void
      {
         addLine([_tools.explode(obj,depth)],1,null,false,true);
      }
      
      public function errorch(channel:*, ... rest) : void
      {
         addLine(rest.copy(),9,channel);
      }
      
      public function error(... rest) : void
      {
         addLine(rest.copy(),9);
      }
      
      public function debugch(channel:*, ... rest) : void
      {
         addLine(rest.copy(),6,channel);
      }
      
      public function debug(... rest) : void
      {
         addLine(rest.copy(),6);
      }
      
      public function clear(channel:String = undefined) : void
      {
         _logs.clear(channel);
         if(!_paused)
         {
            _panels.get_mainPanel().updateToBottom();
         }
         _panels.updateMenu();
      }
      
      public function ch(channel:*, string:*, priority:int = 2, isRepeating:Boolean = false) : void
      {
         addLine([string],priority,channel,isRepeating);
      }
      
      public function bindKey(key:KeyBind, callback:*, args:Array = undefined) : void
      {
         if(key != null)
         {
            _kb.bindKey(key,callback,args);
         }
      }
      
      public function addSlashCommand(name:String, callback:*, desc:String = undefined, alwaysAvailable:Boolean = true, endOfArgsMarker:String = undefined) : void
      {
         if(desc == null)
         {
            desc = "";
         }
         if(endOfArgsMarker == null)
         {
            endOfArgsMarker = ";";
         }
         _cl.addSlashCommand(name,callback,desc,alwaysAvailable,endOfArgsMarker);
      }
      
      public function addMenu(key:String, callback:*, args:Array = undefined, rollover:String = undefined) : void
      {
         get_panels().get_mainPanel().addMenu(key,callback,args,rollover);
      }
      
      public function addLine(strings:Array, priority:int = 0, channel:* = undefined, isRepeating:Boolean = false, html:Boolean = false, stacks:int = -1) : void
      {
         var _loc11_:int = 0;
         var _loc7_:String = "";
         var _loc8_:int = int(strings.length);
         var _loc9_:int = 0;
         var _loc10_:int = _loc8_;
         while(_loc9_ < _loc10_)
         {
            _loc11_ = _loc9_++;
            _loc7_ += (_loc11_ != 0 ? " " : "") + _refs.makeString(strings[_loc11_],null,html);
         }
         if(priority >= _config.autoStackPriority && stacks < 0)
         {
            stacks = _config.defaultStackDepth;
         }
         if(!html && stacks > 0)
         {
            _loc7_ += _tools.getStack(stacks,priority);
         }
         _logs.add(new Log(_loc7_,Console.MakeChannelName(channel),priority,isRepeating,html));
      }
      
      public function addHTMLch(channel:*, priority:int, ... rest) : void
      {
         var _loc5_:Array = rest.copy();
         addLine(_loc5_,priority,channel,false,testHTML(_loc5_));
      }
      
      public function addHTML(... rest) : void
      {
         var _loc3_:Array = rest.copy();
         addLine(_loc3_,2,"-",false,testHTML(_loc3_));
      }
      
      public function addGraph(name:String, obj:*, property:String, color:int = -1, key:String = undefined, rect:Rectangle = undefined, inverse:Boolean = false) : void
      {
         _graphing.add(name,obj,property,color,key,rect,inverse);
      }
      
      public function addCh(channel:*, strings:Array, priority:int = 2, isRepeating:Boolean = false) : void
      {
         addLine(strings,priority,channel,isRepeating);
      }
      
      public function add(string:*, priority:int = 2, isRepeating:Boolean = false) : void
      {
         addLine([string],priority,"-",isRepeating);
      }
      
      public function _onEnterFrame(e:Event) : void
      {
         var _loc2_:int = getTimer();
         _logs.update(_loc2_);
         _refs.update(_loc2_);
         _mm.update();
         var _loc3_:Array = null;
         if(get_remoter().get_remoting() != 2)
         {
            _loc3_ = _graphing.update(stage != null ? int(stage.frameRate) : 0);
         }
         _remoter.update();
         if(visible && parent != null)
         {
            if(get_config().alwaysOnTop && _topTries > 0 && parent.numChildren > parent.getChildIndex(this) + 1)
            {
               --_topTries;
               parent.addChild(this);
               report("Moved console on top (alwaysOnTop enabled), " + _topTries + " attempts left.",-1);
            }
            _panels.update(_paused,_logs.hasNewLog);
            _logs.hasNewLog = false;
            if(_loc3_ != null)
            {
               _panels.updateGraphs(_loc3_);
            }
         }
      }
   }
}

