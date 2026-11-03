package com.junkbyte.console.view
{
   import com.junkbyte.console.Console;
   import com.junkbyte.console.ConsoleConfig;
   import com.junkbyte.console.ConsoleStyle;
   import com.junkbyte.console.compat.ConsoleLib;
   import com.junkbyte.console.core.CommandLine;
   import com.junkbyte.console.core.LogReferences;
   import com.junkbyte.console.core.Logs;
   import com.junkbyte.console.core.Remoting;
   import com.junkbyte.console.utils.FlashRegex;
   import com.junkbyte.console.utils.RegexResult;
   import com.junkbyte.console.vos.Log;
   import flash.Boot;
   import flash.display.InteractiveObject;
   import flash.display.Shape;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.events.TextEvent;
   import flash.geom.ColorTransform;
   import flash.geom.Rectangle;
   import flash.net.FileReference;
   import flash.system.Security;
   import flash.system.SecurityPanel;
   import flash.system.System;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFieldType;
   import flash.text.TextFormat;
   import flash.ui.Keyboard;
   import haxe.IMap;
   import haxe.ds.StringMap;
   
   public class MainPanel extends ConsolePanel
   {
      
      public static var NAME:String = "mainPanel";
      
      public static var CL_HISTORY:String = "clhistory";
      
      public static var VIEWING_CH_HISTORY:String = "viewingChannels";
      
      public static var IGNORED_CH_HISTORY:String = "ignoredChannels";
      
      public static var PRIORITY_HISTORY:String = "priority";
      
      public var _viewingChannels:Array;
      
      public var _traceField:TextField;
      
      public var _shift:Boolean;
      
      public var _selectionStart:int;
      
      public var _selectionEnd:int;
      
      public var _scrolling:Boolean;
      
      public var _scroller:Sprite;
      
      public var _scrolldir:int;
      
      public var _scrolldelay:uint;
      
      public var _scrollHeight:Number;
      
      public var _scroll:Sprite;
      
      public var _priority:int;
      
      public var _needUpdateTrace:Boolean;
      
      public var _needUpdateMenu:Boolean;
      
      public var _mini:Boolean;
      
      public var _lockScrollUpdate:Boolean;
      
      public var _ignoredChannels:Array;
      
      public var _hintField:TextField;
      
      public var _hint:String;
      
      public var _filterText:String;
      
      public var _filterRegExp:EReg;
      
      public var _extraMenus:IMap;
      
      public var _enteringLogin:Boolean;
      
      public var _ctrl:Boolean;
      
      public var _cmdsInd:int;
      
      public var _cmdsHistory:Array;
      
      public var _cmdPrefx:TextField;
      
      public var _cmdField:TextField;
      
      public var _cmdBG:Shape;
      
      public var _clScope:String;
      
      public var _bottomLine:Shape;
      
      public var _atBottom:Boolean;
      
      public var _alt:Boolean;
      
      public function MainPanel(m:Console = undefined)
      {
         var _loc4_:* = null as Array;
         if(!Boot.skip_constructor)
         {
            _cmdsHistory = null;
            _hint = null;
            _enteringLogin = false;
            _atBottom = true;
            _lockScrollUpdate = false;
            _needUpdateTrace = false;
            _needUpdateMenu = false;
            _clScope = "";
            _filterText = null;
            _priority = 0;
            _cmdsInd = -1;
            _extraMenus = new StringMap();
            _ignoredChannels = null;
            _viewingChannels = null;
            _selectionEnd = 0;
            _selectionStart = 0;
            _scrollHeight = 0;
            _scrolling = false;
            _scrolldir = 0;
            _scrolldelay = 0;
            _scroller = null;
            _scroll = null;
            _alt = false;
            _ctrl = false;
            _shift = false;
            _mini = false;
            _bottomLine = null;
            _cmdBG = null;
            _hintField = null;
            _cmdField = null;
            _cmdPrefx = null;
            _traceField = null;
            super(m);
            var _loc2_:int = get_style().menuFontSize;
            console.get_cl().addCLCmd("filter",setFilterText,"Filter console logs to matching string. When done, click on the * (global channel) at top.",true);
            console.get_cl().addCLCmd("filterexp",setFilterRegExp,"Filter console logs to matching regular expression",true);
            console.get_cl().addCLCmd("clearhistory",clearCommandLineHistory,"Clear history of commands you have entered.",true);
            name = "mainPanel";
            minWidth = 50;
            minHeight = 18;
            _traceField = makeTF("traceField");
            _traceField.wordWrap = true;
            _traceField.multiline = true;
            _traceField.y = _loc2_;
            _traceField.addEventListener(Event.SCROLL,onTraceScroll);
            addChild(_traceField);
            txtField = makeTF("menuField");
            txtField.wordWrap = true;
            txtField.multiline = true;
            txtField.autoSize = TextFieldAutoSize.RIGHT;
            txtField.height = _loc2_ + 6;
            txtField.y = -2;
            registerTFRoller(txtField,onMenuRollOverEvent);
            addChild(txtField);
            _cmdBG = new Shape();
            _cmdBG.name = "commandBackground";
            _cmdBG.graphics.beginFill(get_style().commandLineColor,0.1);
            _cmdBG.graphics.drawRoundRect(0,0,100,18,_loc2_,_loc2_);
            _cmdBG.scale9Grid = new Rectangle(9,9,80,1);
            addChild(_cmdBG);
            var _loc3_:TextFormat = new TextFormat(get_style().menuFont,get_style().menuFontSize,get_style().highColor);
            _cmdField = new TextField();
            _cmdField.name = "commandField";
            _cmdField.type = TextFieldType.INPUT;
            _cmdField.x = 40;
            _cmdField.height = _loc2_ + 6;
            _cmdField.addEventListener(KeyboardEvent.KEY_DOWN,commandKeyDown);
            _cmdField.addEventListener(KeyboardEvent.KEY_UP,commandKeyUp);
            _cmdField.addEventListener(FocusEvent.FOCUS_IN,updateCmdHint);
            _cmdField.addEventListener(FocusEvent.FOCUS_OUT,onCmdFocusOut);
            _cmdField.defaultTextFormat = _loc3_;
            addChild(_cmdField);
            _hintField = makeTF("hintField",true);
            _hintField.mouseEnabled = false;
            _hintField.x = _cmdField.x;
            _hintField.autoSize = TextFieldAutoSize.LEFT;
            addChild(_hintField);
            setHints();
            _loc3_.color = get_style().commandLineColor;
            _cmdPrefx = new TextField();
            _cmdPrefx.name = "commandPrefx";
            _cmdPrefx.type = TextFieldType.DYNAMIC;
            _cmdPrefx.x = 2;
            _cmdPrefx.height = _loc2_ + 6;
            _cmdPrefx.selectable = false;
            _cmdPrefx.defaultTextFormat = _loc3_;
            _cmdPrefx.addEventListener(MouseEvent.MOUSE_DOWN,onCmdPrefMouseDown);
            _cmdPrefx.addEventListener(MouseEvent.MOUSE_MOVE,onCmdPrefRollOverOut);
            _cmdPrefx.addEventListener(MouseEvent.ROLL_OUT,onCmdPrefRollOverOut);
            addChild(_cmdPrefx);
            _bottomLine = new Shape();
            _bottomLine.name = "blinkLine";
            _bottomLine.alpha = 0.2;
            addChild(_bottomLine);
            _scroll = new Sprite();
            _scroll.name = "scroller";
            _scroll.tabEnabled = false;
            _scroll.y = _loc2_ + 4;
            _scroll.buttonMode = true;
            _scroll.addEventListener(MouseEvent.MOUSE_DOWN,onScrollbarDown,false,0,true);
            _scroller = new Sprite();
            _scroller.name = "scrollbar";
            _scroller.tabEnabled = false;
            _scroller.y = get_style().controlSize;
            _scroller.graphics.beginFill(get_style().controlColor,1);
            _scroller.graphics.drawRect(-get_style().controlSize,0,get_style().controlSize,30);
            _scroller.graphics.beginFill(0,0);
            _scroller.graphics.drawRect(-get_style().controlSize * 2,0,uint(get_style().controlSize * 2),30);
            _scroller.graphics.endFill();
            _scroller.addEventListener(MouseEvent.MOUSE_DOWN,onScrollerDown,false,0,true);
            _scroll.addChild(_scroller);
            addChild(_scroll);
            _cmdField.visible = false;
            _cmdPrefx.visible = false;
            _cmdBG.visible = false;
            updateCLScope("");
            init(640,100,true);
            registerDragger(txtField);
            if(Reflect.field(console.get_so(),"clhistory") is Array)
            {
               _cmdsHistory = Reflect.field(console.get_so(),"clhistory");
            }
            else
            {
               console.get_so()["clhistory"] = _cmdsHistory = [];
            }
            if(get_config().rememberFilterSettings && Reflect.field(console.get_so(),"viewingChannels") is Array)
            {
               _viewingChannels = Reflect.field(console.get_so(),"viewingChannels");
            }
            else
            {
               console.get_so()["viewingChannels"] = _viewingChannels = [];
            }
            if(get_config().rememberFilterSettings && Reflect.field(console.get_so(),"ignoredChannels") is Array)
            {
               _ignoredChannels = Reflect.field(console.get_so(),"ignoredChannels");
            }
            if(int(_viewingChannels.length) > 0 || _ignoredChannels == null)
            {
               console.get_so()["ignoredChannels"] = _ignoredChannels = [];
            }
            if(get_config().rememberFilterSettings && Std.isOfType(Reflect.field(console.get_so(),"priority"),int))
            {
               _priority = Reflect.field(console.get_so(),"priority");
            }
            addEventListener(MouseEvent.MOUSE_WHEEL,onMouseWheel,false,0,true);
            addEventListener(TextEvent.LINK,linkHandler,false,0,true);
            addEventListener(Event.ADDED_TO_STAGE,stageAddedHandle,false,0,true);
            addEventListener(Event.REMOVED_FROM_STAGE,stageRemovedHandle,false,0,true);
         }
      }
      
      public function updateTraceFHeight() : void
      {
         var _loc1_:Boolean = _mini || !get_style().topMenu;
         _traceField.y = _loc1_ ? 0 : txtField.y + txtField.height - 6;
         _traceField.height = Math.max(0,get_height() - (_cmdField.visible ? get_style().menuFontSize + 4 : 0) - _traceField.y);
      }
      
      public function updateToBottom() : void
      {
         _atBottom = true;
         _needUpdateTrace = true;
      }
      
      public function updateScroller() : void
      {
         if(_traceField.maxScrollV <= 1)
         {
            _scroll.visible = false;
         }
         else
         {
            _scroll.visible = true;
            if(_atBottom)
            {
               set_scrollPercent(1);
            }
            else
            {
               set_scrollPercent((_traceField.scrollV - 1) / (_traceField.maxScrollV - 1));
            }
         }
      }
      
      public function updateMenu(instant:Boolean = false) : void
      {
         if(instant)
         {
            _updateMenu();
         }
         else
         {
            _needUpdateMenu = true;
         }
      }
      
      public function updateFull() : void
      {
         var _loc1_:String = "";
         var _loc2_:Log = console.get_logs().first;
         var _loc3_:Boolean = int(_viewingChannels.length) != 1;
         var _loc4_:Boolean = _priority == 0 && int(_viewingChannels.length) == 0;
         while(_loc2_ != null)
         {
            if(_loc4_ || lineShouldShow(_loc2_))
            {
               _loc1_ += makeLine(_loc2_,_loc3_);
            }
            _loc2_ = _loc2_.next;
         }
         _lockScrollUpdate = true;
         _traceField.htmlText = "<logs>" + _loc1_ + "</logs>";
         _lockScrollUpdate = false;
         updateScroller();
      }
      
      public function updateCmdHint(e:Event = undefined) : void
      {
         var _loc4_:* = null as Error;
         var _loc3_:String = _cmdField.text;
         if(_loc3_ != null && _loc3_ != "" && get_config().commandLineAutoCompleteEnabled && console.get_remoter().get_remoting() != 2)
         {
            try
            {
               setHints(console.get_cl().getHintsFor(_loc3_,10));
               return;
            }
            catch(_loc_e_:Error)
            {
               _loc4_ = _loc_e_;
            }
         }
         setHints();
      }
      
      public function updateCLSize() : void
      {
         var _loc1_:Number = get_width() - 48;
         if(_cmdPrefx.width > 120 || _cmdPrefx.width > _loc1_)
         {
            _cmdPrefx.autoSize = TextFieldAutoSize.NONE;
            _cmdPrefx.width = _loc1_ > 120 ? 120 : _loc1_;
            _cmdPrefx.scrollH = _cmdPrefx.maxScrollH;
         }
         _cmdField.x = _cmdPrefx.width + 2;
         _cmdField.width = get_width() - 15 - _cmdField.x;
         _hintField.x = _cmdField.x;
      }
      
      public function updateCLScope(str:String) : void
      {
         if(_enteringLogin)
         {
            _enteringLogin = false;
            requestLogin(false);
         }
         _cmdPrefx.autoSize = TextFieldAutoSize.LEFT;
         _cmdPrefx.text = str;
         updateCLSize();
      }
      
      public function updateBottom() : void
      {
         var _loc6_:int = 0;
         var _loc1_:String = "";
         var _loc2_:* = int(Math.round(_traceField.height / get_style().traceFontSize));
         var _loc3_:int = Math.round(_traceField.width * 5 / get_style().traceFontSize);
         var _loc4_:Log = console.get_logs().last;
         var _loc5_:Boolean = int(_viewingChannels.length) != 1;
         while(_loc4_ != null)
         {
            if(lineShouldShow(_loc4_))
            {
               _loc6_ = Math.ceil(_loc4_.text.length / _loc3_);
               if(!(_loc4_.html || _loc2_ >= _loc6_))
               {
                  _loc4_ = _loc4_.clone();
                  _loc4_.text = _loc4_.text.substring(int(Math.max(0,_loc4_.text.length - _loc3_ * _loc2_)));
                  _loc1_ = makeLine(_loc4_,_loc5_) + _loc1_;
                  break;
               }
               _loc1_ = makeLine(_loc4_,_loc5_) + _loc1_;
               _loc2_ -= _loc6_;
               if(_loc2_ <= 0)
               {
                  break;
               }
            }
            _loc4_ = _loc4_.prev;
         }
         _lockScrollUpdate = true;
         _traceField.htmlText = "<logs>" + _loc1_ + "</logs>";
         _traceField.scrollV = _traceField.maxScrollV;
         _lockScrollUpdate = false;
         updateScroller();
      }
      
      public function update(changed:Boolean) : void
      {
         var _loc2_:* = null as Shape;
         if(_bottomLine.alpha > 0)
         {
            _loc2_ = _bottomLine;
            _loc2_.alpha -= 0.25;
         }
         if(get_style().showCommandLineScope)
         {
            if(_clScope != console.get_cl().get_scopeString())
            {
               _clScope = console.get_cl().get_scopeString();
               updateCLScope(_clScope);
            }
         }
         else if(_clScope != null)
         {
            _clScope = "";
            updateCLScope("");
         }
         if(changed)
         {
            _bottomLine.alpha = 1;
            _needUpdateMenu = true;
            _needUpdateTrace = true;
         }
         if(_needUpdateTrace)
         {
            _needUpdateTrace = false;
            _updateTraces(true);
         }
         if(_needUpdateMenu)
         {
            _needUpdateMenu = false;
            _updateMenu();
         }
      }
      
      public function toggleCHList(current:Array, chn:String) : Array
      {
         current = current.concat([]);
         var _loc3_:int = current.indexOf(chn);
         if(_loc3_ >= 0)
         {
            current.splice(_loc3_,1);
            if(int(current.length) == 0)
            {
               current.push(" * ");
            }
         }
         else
         {
            current.push(chn);
         }
         return current;
      }
      
      public function startFilter() : void
      {
         console.clear("~");
         console.get_logs().addChannel("~");
         if(int(["~"].length) == 0)
         {
            setViewingChannels();
         }
         else if(int(["~"].length) == 1)
         {
            setViewingChannels(["~"][0]);
         }
         else if(int(["~"].length) == 2)
         {
            setViewingChannels(["~"][0],["~"][1]);
         }
         else if(int(["~"].length) == 3)
         {
            setViewingChannels(["~"][0],["~"][1],["~"][2]);
         }
         else if(int(["~"].length) == 4)
         {
            setViewingChannels(["~"][0],["~"][1],["~"][2],["~"][3]);
         }
         else if(int(["~"].length) == 5)
         {
            setViewingChannels(["~"][0],["~"][1],["~"][2],["~"][3],["~"][4]);
         }
         else if(int(["~"].length) == 6)
         {
            setViewingChannels(["~"][0],["~"][1],["~"][2],["~"][3],["~"][4],["~"][5]);
         }
         else if(int(["~"].length) == 7)
         {
            setViewingChannels(["~"][0],["~"][1],["~"][2],["~"][3],["~"][4],["~"][5],["~"][6]);
         }
         else if(int(["~"].length) == 8)
         {
            setViewingChannels(["~"][0],["~"][1],["~"][2],["~"][3],["~"][4],["~"][5],["~"][6],["~"][7]);
         }
         else if(int(["~"].length) == 9)
         {
            setViewingChannels(["~"][0],["~"][1],["~"][2],["~"][3],["~"][4],["~"][5],["~"][6],["~"][7],["~"][8]);
         }
         else if(int(["~"].length) == 10)
         {
            setViewingChannels(["~"][0],["~"][1],["~"][2],["~"][3],["~"][4],["~"][5],["~"][6],["~"][7],["~"][8],["~"][9]);
         }
         else if(int(["~"].length) == 11)
         {
            setViewingChannels(["~"][0],["~"][1],["~"][2],["~"][3],["~"][4],["~"][5],["~"][6],["~"][7],["~"][8],["~"][9],["~"][10]);
         }
         else if(int(["~"].length) == 12)
         {
            setViewingChannels(["~"][0],["~"][1],["~"][2],["~"][3],["~"][4],["~"][5],["~"][6],["~"][7],["~"][8],["~"][9],["~"][10],["~"][11]);
         }
         else if(int(["~"].length) == 13)
         {
            setViewingChannels(["~"][0],["~"][1],["~"][2],["~"][3],["~"][4],["~"][5],["~"][6],["~"][7],["~"][8],["~"][9],["~"][10],["~"][11],["~"][12]);
         }
         else if(int(["~"].length) == 14)
         {
            setViewingChannels(["~"][0],["~"][1],["~"][2],["~"][3],["~"][4],["~"][5],["~"][6],["~"][7],["~"][8],["~"][9],["~"][10],["~"][11],["~"][12],["~"][13]);
         }
         else if(int(["~"].length) == 15)
         {
            setViewingChannels(["~"][0],["~"][1],["~"][2],["~"][3],["~"][4],["~"][5],["~"][6],["~"][7],["~"][8],["~"][9],["~"][10],["~"][11],["~"][12],["~"][13],["~"][14]);
         }
         else if(int(["~"].length) == 16)
         {
            setViewingChannels(["~"][0],["~"][1],["~"][2],["~"][3],["~"][4],["~"][5],["~"][6],["~"][7],["~"][8],["~"][9],["~"][10],["~"][11],["~"][12],["~"][13],["~"][14],["~"][15]);
         }
         else if(int(["~"].length) == 17)
         {
            setViewingChannels(["~"][0],["~"][1],["~"][2],["~"][3],["~"][4],["~"][5],["~"][6],["~"][7],["~"][8],["~"][9],["~"][10],["~"][11],["~"][12],["~"][13],["~"][14],["~"][15],["~"][16]);
         }
         else if(int(["~"].length) == 18)
         {
            setViewingChannels(["~"][0],["~"][1],["~"][2],["~"][3],["~"][4],["~"][5],["~"][6],["~"][7],["~"][8],["~"][9],["~"][10],["~"][11],["~"][12],["~"][13],["~"][14],["~"][15],["~"][16],["~"][17]);
         }
         else if(int(["~"].length) == 19)
         {
            setViewingChannels(["~"][0],["~"][1],["~"][2],["~"][3],["~"][4],["~"][5],["~"][6],["~"][7],["~"][8],["~"][9],["~"][10],["~"][11],["~"][12],["~"][13],["~"][14],["~"][15],["~"][16],["~"][17],["~"][18]);
         }
         else
         {
            if(int(["~"].length) != 20)
            {
               throw "Too many rest arguments";
            }
            setViewingChannels(["~"][0],["~"][1],["~"][2],["~"][3],["~"][4],["~"][5],["~"][6],["~"][7],["~"][8],["~"][9],["~"][10],["~"][11],["~"][12],["~"][13],["~"][14],["~"][15],["~"][16],["~"][17],["~"][18],["~"][19]);
         }
      }
      
      public function stageRemovedHandle(e:Event = undefined) : void
      {
         stage.removeEventListener(MouseEvent.MOUSE_DOWN,onStageMouseDown,true);
         stage.removeEventListener(KeyboardEvent.KEY_UP,keyUpHandler);
         stage.removeEventListener(KeyboardEvent.KEY_DOWN,keyDownHandler);
      }
      
      public function stageAddedHandle(e:Event = undefined) : void
      {
         stage.addEventListener(MouseEvent.MOUSE_DOWN,onStageMouseDown,true,0,true);
         stage.addEventListener(KeyboardEvent.KEY_UP,keyUpHandler,false,0,true);
         stage.addEventListener(KeyboardEvent.KEY_DOWN,keyDownHandler,false,0,true);
      }
      
      override public function set_width(value:Number) : Number
      {
         _lockScrollUpdate = true;
         super.set_width(value);
         _traceField.width = value - 4;
         txtField.width = value - 6;
         _cmdField.width = get_width() - 15 - _cmdField.x;
         _cmdBG.width = value;
         _bottomLine.graphics.clear();
         _bottomLine.graphics.lineStyle(1,get_style().controlColor);
         _bottomLine.graphics.moveTo(10,-1);
         _bottomLine.graphics.lineTo(value - 10,-1);
         _scroll.x = value;
         _atBottom = true;
         updateCLSize();
         _needUpdateMenu = true;
         _needUpdateTrace = true;
         _lockScrollUpdate = false;
         return value;
      }
      
      public function set_scrollPercent(per:Number) : Number
      {
         _scroller.y = get_style().controlSize + (_scrollHeight - 30 - uint(get_style().controlSize * 2)) * per;
         return per;
      }
      
      public function set_priority(p:uint) : uint
      {
         _priority = p;
         console.get_so()["priority"] = _priority;
         updateToBottom();
         updateMenu();
         return p;
      }
      
      public function set priority(value:uint) : void
      {
         set_priority(value);
      }
      
      override public function set_height(value:Number) : Number
      {
         _lockScrollUpdate = true;
         var _loc2_:int = get_style().menuFontSize;
         var _loc3_:Number = _loc2_ + 6 + get_style().traceFontSize;
         if(get_height() != value)
         {
            _mini = value < (_cmdField.visible ? _loc3_ + _loc2_ + 4 : _loc3_);
         }
         super.set_height(value);
         var _loc4_:Boolean = _mini || !get_style().topMenu;
         updateTraceFHeight();
         _traceField.y = _loc4_ ? 0 : _loc2_;
         _traceField.height = value - (_cmdField.visible ? _loc2_ + 4 : 0) - (_loc4_ ? 0 : _loc2_);
         var _loc5_:Number = value - (_loc2_ + 6);
         _cmdField.y = _loc5_;
         _cmdPrefx.y = _loc5_;
         _hintField.y = _cmdField.y - _hintField.height;
         _cmdBG.y = _loc5_;
         _bottomLine.y = _cmdField.visible ? _loc5_ : value;
         _scroll.y = _loc4_ ? 6 : _loc2_ + 4;
         var _loc6_:uint = get_style().controlSize;
         _scrollHeight = _bottomLine.y - (_cmdField.visible ? 0 : int(uint(_loc6_ * 2))) - _scroll.y;
         _scroller.visible = _scrollHeight > 40;
         _scroll.graphics.clear();
         if(_scrollHeight >= 10)
         {
            _scroll.graphics.beginFill(get_style().controlColor,0.7);
            _scroll.graphics.drawRect(-_loc6_,0,_loc6_,_loc6_);
            _scroll.graphics.drawRect(-_loc6_,_scrollHeight - _loc6_,_loc6_,_loc6_);
            _scroll.graphics.beginFill(get_style().controlColor,0.25);
            _scroll.graphics.drawRect(-_loc6_,_loc6_,_loc6_,_scrollHeight - uint(_loc6_ * 2));
            _scroll.graphics.beginFill(0,0);
            _scroll.graphics.drawRect(-_loc6_ * 2,uint(_loc6_ * 2),uint(_loc6_ * 2),_scrollHeight - uint(_loc6_ * 2));
            _scroll.graphics.endFill();
         }
         _atBottom = true;
         _needUpdateTrace = true;
         _lockScrollUpdate = false;
         return value;
      }
      
      public function set_commandLine(b:Boolean) : Boolean
      {
         if(b)
         {
            _cmdField.visible = true;
            _cmdPrefx.visible = true;
            _cmdBG.visible = true;
         }
         else
         {
            _cmdField.visible = false;
            _cmdPrefx.visible = false;
            _cmdBG.visible = false;
         }
         _needUpdateMenu = true;
         var _loc2_:Number = get_height();
         set_height(_loc2_);
         return b;
      }
      
      public function set commandLine(value:Boolean) : void
      {
         set_commandLine(value);
      }
      
      public function setViewingChannels(... rest) : void
      {
         var _loc4_:int = 0;
         var _loc6_:* = null;
         var _loc7_:* = null as String;
         var _loc3_:Array = [];
         _loc4_ = 0;
         var _loc5_:Array = rest;
         while(_loc4_ < int(_loc5_.length))
         {
            _loc6_ = _loc5_[_loc4_++];
            _loc3_.push(Console.MakeChannelName(_loc6_));
         }
         if(_viewingChannels[0] == "⌂" && (_loc3_ == null || _loc3_[0] != _viewingChannels[0]))
         {
            console.get_refs().exitFocus();
         }
         _ignoredChannels.splice(0,int(_ignoredChannels.length));
         _viewingChannels.splice(0,int(_viewingChannels.length));
         if(_loc3_.indexOf(" * ") < 0 && _loc3_.indexOf(null) < 0)
         {
            _loc4_ = 0;
            while(_loc4_ < int(_loc3_.length))
            {
               _loc7_ = _loc3_[_loc4_];
               _loc4_++;
               if(_loc7_ != null)
               {
                  _viewingChannels.push(_loc7_);
               }
            }
         }
         updateToBottom();
         console.get_panels().updateMenu();
      }
      
      public function setPaused(b:Boolean) : void
      {
         if(b && _atBottom)
         {
            _atBottom = false;
            _updateTraces();
            _traceField.scrollV = _traceField.maxScrollV;
         }
         else if(!b)
         {
            _atBottom = true;
            updateBottom();
         }
         updateMenu();
      }
      
      public function setIgnoredChannels(... rest) : void
      {
         var _loc4_:int = 0;
         var _loc6_:* = null;
         var _loc7_:* = null as String;
         var _loc3_:Array = [];
         _loc4_ = 0;
         var _loc5_:Array = rest;
         while(_loc4_ < int(_loc5_.length))
         {
            _loc6_ = _loc5_[_loc4_++];
            _loc3_.push(Console.MakeChannelName(_loc6_));
         }
         if(_viewingChannels[0] == "⌂")
         {
            console.get_refs().exitFocus();
         }
         _ignoredChannels.splice(0,int(_ignoredChannels.length));
         _viewingChannels.splice(0,int(_viewingChannels.length));
         if(_loc3_.indexOf(" * ") < 0 && _loc3_.indexOf(null) < 0)
         {
            _loc4_ = 0;
            while(_loc4_ < int(_loc3_.length))
            {
               _loc7_ = _loc3_[_loc4_];
               _loc4_++;
               if(_loc7_ != null)
               {
                  _ignoredChannels.push(_loc7_);
               }
            }
         }
         updateToBottom();
         console.get_panels().updateMenu();
      }
      
      public function setHints(hints:Array = undefined) : void
      {
         var _loc2_:* = null as String;
         var _loc3_:Boolean = false;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:* = null as Array;
         var _loc8_:* = null as Array;
         var _loc9_:* = null as Rectangle;
         if(hints != null && int(hints.length) != 0)
         {
            _hint = hints[0][0];
            if(int(hints.length) > 1)
            {
               _loc2_ = hints[1][0];
               _loc3_ = false;
               _loc4_ = 0;
               _loc5_ = _loc2_.length;
               while(_loc4_ < _loc5_)
               {
                  _loc6_ = _loc4_++;
                  if(_loc2_.charAt(_loc6_) != _hint.charAt(_loc6_))
                  {
                     if(_loc3_ && _cmdField.text.length < _loc6_)
                     {
                        _hint = _hint.substring(0,_loc6_);
                     }
                     break;
                  }
                  _loc3_ = true;
               }
            }
            _loc7_ = [];
            _loc4_ = 0;
            while(_loc4_ < int(hints.length))
            {
               _loc8_ = hints[_loc4_];
               _loc4_++;
               _loc7_.push("<p3>" + _loc8_[0] + "</p3> <p0>" + (_loc8_[1] != null ? _loc8_[1] : "") + "</p0>");
            }
            _loc7_.reverse();
            _hintField.htmlText = "<p>" + _loc7_.join("\n") + "</p>";
            _hintField.visible = true;
            _loc9_ = _cmdField.getCharBoundaries(_cmdField.text.length - 1);
            if(_loc9_ == null)
            {
               _loc9_ = new Rectangle();
            }
            _hintField.x = _cmdField.x + _loc9_.x + _loc9_.width + 30;
            _hintField.y = get_height() - _hintField.height;
         }
         else
         {
            _hintField.visible = false;
            _hint = null;
         }
      }
      
      public function setFilterText(str:String = undefined) : void
      {
         if(str == null)
         {
            str = "";
         }
         if(str != null && str != "")
         {
            _filterRegExp = null;
            _filterText = LogReferences.EscHTML(str.toLowerCase());
            startFilter();
         }
         else
         {
            endFilter();
         }
      }
      
      public function setFilterRegExp(expstr:String = undefined) : void
      {
         if(expstr == null)
         {
            expstr = "";
         }
         if(expstr != null && expstr != "")
         {
            _filterText = null;
            _filterRegExp = new EReg(LogReferences.EscHTML(expstr),"gi");
            startFilter();
         }
         else
         {
            endFilter();
         }
      }
      
      public function setCLSelectionAtEnd() : void
      {
         _cmdField.setSelection(_cmdField.text.length,_cmdField.text.length);
      }
      
      public function requestLogin(on:Boolean = true) : void
      {
         var _loc2_:ColorTransform = new ColorTransform();
         if(on)
         {
            console.set_commandLine(true);
            console.report("//",-2);
            console.report("// <b>Enter remoting password</b> in CommandLine below...",-2);
            updateCLScope("Password");
            _loc2_.color = get_style().controlColor;
            _cmdBG.transform.colorTransform = _loc2_;
            _traceField.transform.colorTransform = new ColorTransform(0.7,0.7,0.7);
         }
         else
         {
            updateCLScope("");
            _cmdBG.transform.colorTransform = _loc2_;
            _traceField.transform.colorTransform = _loc2_;
         }
         _cmdField.displayAsPassword = on;
         _enteringLogin = on;
      }
      
      public function onTraceScroll(e:Event = undefined) : void
      {
         var _loc3_:* = 0;
         if(_lockScrollUpdate || _shift)
         {
            return;
         }
         var _loc2_:Boolean = _traceField.scrollV >= _traceField.maxScrollV;
         if(!console.get_paused() && _atBottom != _loc2_)
         {
            _loc3_ = _traceField.maxScrollV - _traceField.scrollV;
            _selectionStart = _traceField.text.length - _traceField.selectionBeginIndex;
            _selectionEnd = _traceField.text.length - _traceField.selectionEndIndex;
            _atBottom = _loc2_;
            _updateTraces();
            _traceField.scrollV = _traceField.maxScrollV - _loc3_;
         }
         updateScroller();
      }
      
      public function onStageMouseDown(e:MouseEvent) : void
      {
         _shift = e.shiftKey;
         _ctrl = e.ctrlKey;
         _alt = e.altKey;
      }
      
      public function onScrollerUp(e:MouseEvent) : void
      {
         _scroller.stopDrag();
         stage.removeEventListener(MouseEvent.MOUSE_MOVE,onScrollerMove);
         stage.removeEventListener(MouseEvent.MOUSE_UP,onScrollerUp);
         _scrolling = false;
         onTraceScroll();
      }
      
      public function onScrollerMove(e:MouseEvent) : void
      {
         _lockScrollUpdate = true;
         _traceField.scrollV = int(Math.round(get_scrollPercent() * (_traceField.maxScrollV - 1) + 1));
         _lockScrollUpdate = false;
      }
      
      public function onScrollerDown(e:MouseEvent) : void
      {
         var _loc2_:Number = NaN;
         _scrolling = true;
         if(!console.get_paused() && _atBottom)
         {
            _atBottom = false;
            _loc2_ = get_scrollPercent();
            _updateTraces();
            set_scrollPercent(_loc2_);
         }
         _scroller.startDrag(false,new Rectangle(0,get_style().controlSize,0,_scrollHeight - 30 - uint(get_style().controlSize * 2)));
         stage.addEventListener(MouseEvent.MOUSE_MOVE,onScrollerMove,false,0,true);
         stage.addEventListener(MouseEvent.MOUSE_UP,onScrollerUp,false,0,true);
         e.stopPropagation();
      }
      
      public function onScrollbarDown(e:MouseEvent) : void
      {
         if(_scroller.visible && _scroller.mouseY > 0 || !_scroller.visible && _scroll.mouseY > _scrollHeight / 2)
         {
            _scrolldir = 3;
         }
         else
         {
            _scrolldir = -3;
         }
         var _loc2_:TextField = _traceField;
         _loc2_.scrollV += _scrolldir;
         _scrolldelay = 0;
         addEventListener(Event.ENTER_FRAME,onScrollBarFrame,false,0,true);
         stage.addEventListener(MouseEvent.MOUSE_UP,onScrollBarUp,false,0,true);
      }
      
      public function onScrollBarUp(e:Event) : void
      {
         removeEventListener(Event.ENTER_FRAME,onScrollBarFrame);
         stage.removeEventListener(MouseEvent.MOUSE_UP,onScrollBarUp);
      }
      
      public function onScrollBarFrame(e:Event) : void
      {
         var _loc2_:* = null as TextField;
         ++_scrolldelay;
         if(_scrolldelay > 10)
         {
            _scrolldelay = 9;
            if(_scrolldir < 0 && _scroller.y > _scroll.mouseY || _scrolldir > 0 && _scroller.y + _scroller.height < _scroll.mouseY)
            {
               _loc2_ = _traceField;
               _loc2_.scrollV += _scrolldir;
            }
         }
      }
      
      public function onMouseWheel(e:MouseEvent) : void
      {
         var _loc2_:* = 0;
         if(_shift)
         {
            _loc2_ = console.get_config().get_style().traceFontSize + (e.delta > 0 ? 1 : -1);
            if(_loc2_ > 10 && _loc2_ < 20)
            {
               console.get_config().get_style().traceFontSize = _loc2_;
               console.get_config().get_style().updateStyleSheet();
               updateToBottom();
               e.stopPropagation();
            }
         }
      }
      
      public function onMenuRollOverEvent(e:TextEvent) : void
      {
         onMenuRollOver(e);
      }
      
      public function onMenuRollOver(e:TextEvent, src:ConsolePanel = undefined) : void
      {
         var _loc4_:* = null as IMap;
         var _loc5_:* = null as String;
         var _loc6_:* = null as StringMap;
         var _loc7_:* = null as Array;
         var _loc8_:* = null;
         if(src == null)
         {
            src = this;
         }
         var _loc3_:String = e.text != null ? StringTools.replace(e.text,"event:","") : "";
         if(_loc3_ == "channel_" + " * ")
         {
            _loc3_ = "View all channels";
         }
         else if(_loc3_ == "channel_" + "-")
         {
            _loc3_ = "Default channel::Logs with no channel";
         }
         else if(_loc3_ == "channel_" + "C")
         {
            _loc3_ = "Console\'s channel::Logs generated from Console";
         }
         else if(_loc3_ == "channel_" + "~")
         {
            _loc3_ = _filterRegExp != null ? ConsoleLib.string(_filterRegExp.r) : _filterText;
            _loc3_ = "Filtering channel" + "::*" + _loc3_ + "*";
         }
         else if(_loc3_ == "channel_" + "⌂")
         {
            _loc3_ = "Inspecting channel";
         }
         else if(_loc3_.indexOf("channel_") == 0)
         {
            _loc3_ = "Change channel::shift: select multiple\nctrl: ignore channel";
         }
         else if(_loc3_ == "pause")
         {
            if(console.get_paused())
            {
               _loc3_ = "Resume updates";
            }
            else
            {
               _loc3_ = "Pause updates";
            }
         }
         else if(_loc3_ == "close" && src == this)
         {
            _loc3_ = "Close::Type password to show again";
         }
         else if(_loc3_.indexOf("external_") == 0)
         {
            _loc4_ = _extraMenus;
            _loc5_ = _loc3_.substring(9);
            _loc6_ = _loc4_;
            _loc7_ = _loc5_ in StringMap.reserved ? Array(_loc6_.getReserved(_loc5_)) : _loc6_.h[_loc5_];
            if(_loc7_ != null)
            {
               _loc3_ = _loc7_[2];
            }
         }
         else
         {
            _loc8_ = {
               "fps":"Frames Per Second",
               "mm":"Memory Monitor",
               "roller":"Display Roller::Map the display list under your mouse",
               "ruler":"Screen Ruler::Measure the distance and angle between two points on screen.",
               "command":"Command Line",
               "copy":"Save to clipboard::shift: no channel name\nctrl: use viewing filters\nalt: save to file",
               "clear":"Clear log",
               "priority":"Priority filter::shift: previous priority\n(skips unused priorites)",
               "channels":"Expand channels",
               "close":"Close"
            };
            _loc3_ = Reflect.field(_loc8_,_loc3_);
         }
         console.get_panels().tooltip(_loc3_,src);
      }
      
      public function onCmdPrefRollOverOut(e:MouseEvent) : void
      {
         console.get_panels().tooltip(e.type == MouseEvent.MOUSE_MOVE ? "Current scope::(CommandLine)" : "",this);
      }
      
      public function onCmdPrefMouseDown(e:MouseEvent) : void
      {
         var _loc3_:* = null as Error;
         try
         {
            stage.focus = _cmdField;
            setCLSelectionAtEnd();
         }
         catch(_loc_e_:Error)
         {
            _loc3_ = _loc_e_;
         }
      }
      
      public function onCmdFocusOut(e:Event) : void
      {
         setHints();
      }
      
      public function onChannelPressed(chn:String) : void
      {
         var _loc2_:* = null as Array;
         if(_ctrl && chn != " * ")
         {
            _loc2_ = toggleCHList(_ignoredChannels,chn);
            if(int(_loc2_.length) == 0)
            {
               setIgnoredChannels();
            }
            else if(int(_loc2_.length) == 1)
            {
               setIgnoredChannels(_loc2_[0]);
            }
            else if(int(_loc2_.length) == 2)
            {
               setIgnoredChannels(_loc2_[0],_loc2_[1]);
            }
            else if(int(_loc2_.length) == 3)
            {
               setIgnoredChannels(_loc2_[0],_loc2_[1],_loc2_[2]);
            }
            else if(int(_loc2_.length) == 4)
            {
               setIgnoredChannels(_loc2_[0],_loc2_[1],_loc2_[2],_loc2_[3]);
            }
            else if(int(_loc2_.length) == 5)
            {
               setIgnoredChannels(_loc2_[0],_loc2_[1],_loc2_[2],_loc2_[3],_loc2_[4]);
            }
            else if(int(_loc2_.length) == 6)
            {
               setIgnoredChannels(_loc2_[0],_loc2_[1],_loc2_[2],_loc2_[3],_loc2_[4],_loc2_[5]);
            }
            else if(int(_loc2_.length) == 7)
            {
               setIgnoredChannels(_loc2_[0],_loc2_[1],_loc2_[2],_loc2_[3],_loc2_[4],_loc2_[5],_loc2_[6]);
            }
            else if(int(_loc2_.length) == 8)
            {
               setIgnoredChannels(_loc2_[0],_loc2_[1],_loc2_[2],_loc2_[3],_loc2_[4],_loc2_[5],_loc2_[6],_loc2_[7]);
            }
            else if(int(_loc2_.length) == 9)
            {
               setIgnoredChannels(_loc2_[0],_loc2_[1],_loc2_[2],_loc2_[3],_loc2_[4],_loc2_[5],_loc2_[6],_loc2_[7],_loc2_[8]);
            }
            else if(int(_loc2_.length) == 10)
            {
               setIgnoredChannels(_loc2_[0],_loc2_[1],_loc2_[2],_loc2_[3],_loc2_[4],_loc2_[5],_loc2_[6],_loc2_[7],_loc2_[8],_loc2_[9]);
            }
            else if(int(_loc2_.length) == 11)
            {
               setIgnoredChannels(_loc2_[0],_loc2_[1],_loc2_[2],_loc2_[3],_loc2_[4],_loc2_[5],_loc2_[6],_loc2_[7],_loc2_[8],_loc2_[9],_loc2_[10]);
            }
            else if(int(_loc2_.length) == 12)
            {
               setIgnoredChannels(_loc2_[0],_loc2_[1],_loc2_[2],_loc2_[3],_loc2_[4],_loc2_[5],_loc2_[6],_loc2_[7],_loc2_[8],_loc2_[9],_loc2_[10],_loc2_[11]);
            }
            else if(int(_loc2_.length) == 13)
            {
               setIgnoredChannels(_loc2_[0],_loc2_[1],_loc2_[2],_loc2_[3],_loc2_[4],_loc2_[5],_loc2_[6],_loc2_[7],_loc2_[8],_loc2_[9],_loc2_[10],_loc2_[11],_loc2_[12]);
            }
            else if(int(_loc2_.length) == 14)
            {
               setIgnoredChannels(_loc2_[0],_loc2_[1],_loc2_[2],_loc2_[3],_loc2_[4],_loc2_[5],_loc2_[6],_loc2_[7],_loc2_[8],_loc2_[9],_loc2_[10],_loc2_[11],_loc2_[12],_loc2_[13]);
            }
            else if(int(_loc2_.length) == 15)
            {
               setIgnoredChannels(_loc2_[0],_loc2_[1],_loc2_[2],_loc2_[3],_loc2_[4],_loc2_[5],_loc2_[6],_loc2_[7],_loc2_[8],_loc2_[9],_loc2_[10],_loc2_[11],_loc2_[12],_loc2_[13],_loc2_[14]);
            }
            else if(int(_loc2_.length) == 16)
            {
               setIgnoredChannels(_loc2_[0],_loc2_[1],_loc2_[2],_loc2_[3],_loc2_[4],_loc2_[5],_loc2_[6],_loc2_[7],_loc2_[8],_loc2_[9],_loc2_[10],_loc2_[11],_loc2_[12],_loc2_[13],_loc2_[14],_loc2_[15]);
            }
            else if(int(_loc2_.length) == 17)
            {
               setIgnoredChannels(_loc2_[0],_loc2_[1],_loc2_[2],_loc2_[3],_loc2_[4],_loc2_[5],_loc2_[6],_loc2_[7],_loc2_[8],_loc2_[9],_loc2_[10],_loc2_[11],_loc2_[12],_loc2_[13],_loc2_[14],_loc2_[15],_loc2_[16]);
            }
            else if(int(_loc2_.length) == 18)
            {
               setIgnoredChannels(_loc2_[0],_loc2_[1],_loc2_[2],_loc2_[3],_loc2_[4],_loc2_[5],_loc2_[6],_loc2_[7],_loc2_[8],_loc2_[9],_loc2_[10],_loc2_[11],_loc2_[12],_loc2_[13],_loc2_[14],_loc2_[15],_loc2_[16],_loc2_[17]);
            }
            else if(int(_loc2_.length) == 19)
            {
               setIgnoredChannels(_loc2_[0],_loc2_[1],_loc2_[2],_loc2_[3],_loc2_[4],_loc2_[5],_loc2_[6],_loc2_[7],_loc2_[8],_loc2_[9],_loc2_[10],_loc2_[11],_loc2_[12],_loc2_[13],_loc2_[14],_loc2_[15],_loc2_[16],_loc2_[17],_loc2_[18]);
            }
            else
            {
               if(int(_loc2_.length) != 20)
               {
                  throw "Too many rest arguments";
               }
               setIgnoredChannels(_loc2_[0],_loc2_[1],_loc2_[2],_loc2_[3],_loc2_[4],_loc2_[5],_loc2_[6],_loc2_[7],_loc2_[8],_loc2_[9],_loc2_[10],_loc2_[11],_loc2_[12],_loc2_[13],_loc2_[14],_loc2_[15],_loc2_[16],_loc2_[17],_loc2_[18],_loc2_[19]);
            }
         }
         else if(_shift && chn != " * " && _viewingChannels[0] != "⌂")
         {
            _loc2_ = toggleCHList(_viewingChannels,chn);
            if(int(_loc2_.length) == 0)
            {
               setViewingChannels();
            }
            else if(int(_loc2_.length) == 1)
            {
               setViewingChannels(_loc2_[0]);
            }
            else if(int(_loc2_.length) == 2)
            {
               setViewingChannels(_loc2_[0],_loc2_[1]);
            }
            else if(int(_loc2_.length) == 3)
            {
               setViewingChannels(_loc2_[0],_loc2_[1],_loc2_[2]);
            }
            else if(int(_loc2_.length) == 4)
            {
               setViewingChannels(_loc2_[0],_loc2_[1],_loc2_[2],_loc2_[3]);
            }
            else if(int(_loc2_.length) == 5)
            {
               setViewingChannels(_loc2_[0],_loc2_[1],_loc2_[2],_loc2_[3],_loc2_[4]);
            }
            else if(int(_loc2_.length) == 6)
            {
               setViewingChannels(_loc2_[0],_loc2_[1],_loc2_[2],_loc2_[3],_loc2_[4],_loc2_[5]);
            }
            else if(int(_loc2_.length) == 7)
            {
               setViewingChannels(_loc2_[0],_loc2_[1],_loc2_[2],_loc2_[3],_loc2_[4],_loc2_[5],_loc2_[6]);
            }
            else if(int(_loc2_.length) == 8)
            {
               setViewingChannels(_loc2_[0],_loc2_[1],_loc2_[2],_loc2_[3],_loc2_[4],_loc2_[5],_loc2_[6],_loc2_[7]);
            }
            else if(int(_loc2_.length) == 9)
            {
               setViewingChannels(_loc2_[0],_loc2_[1],_loc2_[2],_loc2_[3],_loc2_[4],_loc2_[5],_loc2_[6],_loc2_[7],_loc2_[8]);
            }
            else if(int(_loc2_.length) == 10)
            {
               setViewingChannels(_loc2_[0],_loc2_[1],_loc2_[2],_loc2_[3],_loc2_[4],_loc2_[5],_loc2_[6],_loc2_[7],_loc2_[8],_loc2_[9]);
            }
            else if(int(_loc2_.length) == 11)
            {
               setViewingChannels(_loc2_[0],_loc2_[1],_loc2_[2],_loc2_[3],_loc2_[4],_loc2_[5],_loc2_[6],_loc2_[7],_loc2_[8],_loc2_[9],_loc2_[10]);
            }
            else if(int(_loc2_.length) == 12)
            {
               setViewingChannels(_loc2_[0],_loc2_[1],_loc2_[2],_loc2_[3],_loc2_[4],_loc2_[5],_loc2_[6],_loc2_[7],_loc2_[8],_loc2_[9],_loc2_[10],_loc2_[11]);
            }
            else if(int(_loc2_.length) == 13)
            {
               setViewingChannels(_loc2_[0],_loc2_[1],_loc2_[2],_loc2_[3],_loc2_[4],_loc2_[5],_loc2_[6],_loc2_[7],_loc2_[8],_loc2_[9],_loc2_[10],_loc2_[11],_loc2_[12]);
            }
            else if(int(_loc2_.length) == 14)
            {
               setViewingChannels(_loc2_[0],_loc2_[1],_loc2_[2],_loc2_[3],_loc2_[4],_loc2_[5],_loc2_[6],_loc2_[7],_loc2_[8],_loc2_[9],_loc2_[10],_loc2_[11],_loc2_[12],_loc2_[13]);
            }
            else if(int(_loc2_.length) == 15)
            {
               setViewingChannels(_loc2_[0],_loc2_[1],_loc2_[2],_loc2_[3],_loc2_[4],_loc2_[5],_loc2_[6],_loc2_[7],_loc2_[8],_loc2_[9],_loc2_[10],_loc2_[11],_loc2_[12],_loc2_[13],_loc2_[14]);
            }
            else if(int(_loc2_.length) == 16)
            {
               setViewingChannels(_loc2_[0],_loc2_[1],_loc2_[2],_loc2_[3],_loc2_[4],_loc2_[5],_loc2_[6],_loc2_[7],_loc2_[8],_loc2_[9],_loc2_[10],_loc2_[11],_loc2_[12],_loc2_[13],_loc2_[14],_loc2_[15]);
            }
            else if(int(_loc2_.length) == 17)
            {
               setViewingChannels(_loc2_[0],_loc2_[1],_loc2_[2],_loc2_[3],_loc2_[4],_loc2_[5],_loc2_[6],_loc2_[7],_loc2_[8],_loc2_[9],_loc2_[10],_loc2_[11],_loc2_[12],_loc2_[13],_loc2_[14],_loc2_[15],_loc2_[16]);
            }
            else if(int(_loc2_.length) == 18)
            {
               setViewingChannels(_loc2_[0],_loc2_[1],_loc2_[2],_loc2_[3],_loc2_[4],_loc2_[5],_loc2_[6],_loc2_[7],_loc2_[8],_loc2_[9],_loc2_[10],_loc2_[11],_loc2_[12],_loc2_[13],_loc2_[14],_loc2_[15],_loc2_[16],_loc2_[17]);
            }
            else if(int(_loc2_.length) == 19)
            {
               setViewingChannels(_loc2_[0],_loc2_[1],_loc2_[2],_loc2_[3],_loc2_[4],_loc2_[5],_loc2_[6],_loc2_[7],_loc2_[8],_loc2_[9],_loc2_[10],_loc2_[11],_loc2_[12],_loc2_[13],_loc2_[14],_loc2_[15],_loc2_[16],_loc2_[17],_loc2_[18]);
            }
            else
            {
               if(int(_loc2_.length) != 20)
               {
                  throw "Too many rest arguments";
               }
               setViewingChannels(_loc2_[0],_loc2_[1],_loc2_[2],_loc2_[3],_loc2_[4],_loc2_[5],_loc2_[6],_loc2_[7],_loc2_[8],_loc2_[9],_loc2_[10],_loc2_[11],_loc2_[12],_loc2_[13],_loc2_[14],_loc2_[15],_loc2_[16],_loc2_[17],_loc2_[18],_loc2_[19]);
            }
         }
         else
         {
            console.setViewingChannels(chn);
         }
      }
      
      public function makeLine(line:Log, showch:Boolean) : String
      {
         var _loc3_:String = "<p>";
         if(showch)
         {
            _loc3_ += line.chStr;
         }
         if(get_config().showLineNumber)
         {
            _loc3_ += line.lineStr;
         }
         if(get_config().showTimestamp)
         {
            _loc3_ += line.timeStr;
         }
         var _loc4_:String = "p" + line.priority;
         return _loc3_ + "<" + _loc4_ + ">" + addFilterText(line.text) + "</" + _loc4_ + "></p>";
      }
      
      public function linkHandler(e:TextEvent) : void
      {
         var _loc4_:Number = NaN;
         var _loc5_:* = null;
         var _loc6_:* = null as String;
         var _loc7_:* = null as FileReference;
         var _loc8_:* = null as Error;
         var _loc9_:int = 0;
         var _loc10_:* = null as IMap;
         var _loc11_:* = null as StringMap;
         var _loc12_:* = null as Array;
         txtField.setSelection(0,0);
         stopDrag();
         var _loc3_:String = e.text;
         if(_loc3_ == "pause")
         {
            if(console.get_paused())
            {
               console.set_paused(false);
            }
            else
            {
               console.set_paused(true);
            }
            console.get_panels().tooltip(null);
         }
         else if(_loc3_ == "hide")
         {
            console.get_panels().tooltip();
            _mini = true;
            console.get_config().get_style().topMenu = false;
            _loc4_ = get_height();
            set_height(_loc4_);
            updateMenu();
         }
         else if(_loc3_ == "show")
         {
            console.get_panels().tooltip();
            _mini = false;
            console.get_config().get_style().topMenu = true;
            _loc4_ = get_height();
            set_height(_loc4_);
            updateMenu();
         }
         else if(_loc3_ == "close")
         {
            console.get_panels().tooltip();
            set_visible(false);
            dispatchEvent(new Event(Event.CLOSE));
         }
         else if(_loc3_ == "channels")
         {
            console.get_panels().set_channelsPanel(!console.get_panels().get_channelsPanel());
         }
         else if(_loc3_ == "fps")
         {
            console.set_fpsMonitor(!console.get_fpsMonitor());
         }
         else if(_loc3_ == "priority")
         {
            incPriority(_shift);
         }
         else if(_loc3_ == "mm")
         {
            console.set_memoryMonitor(!console.get_memoryMonitor());
         }
         else if(_loc3_ == "roller")
         {
            console.set_displayRoller(!console.get_displayRoller());
         }
         else if(_loc3_ == "ruler")
         {
            console.get_panels().tooltip();
            console.get_panels().startRuler();
         }
         else if(_loc3_ == "command")
         {
            set_commandLine(!get_commandLine());
         }
         else if(_loc3_ == "copy")
         {
            _loc5_ = _ctrl ? lineShouldShow : null;
            _loc6_ = console.get_logs().getLogsAsString("\r\n",!_shift,_loc5_);
            if(_alt)
            {
               _loc7_ = new FileReference();
               try
               {
                  _loc7_.save(_loc6_,"log.txt");
               }
               catch(_loc_e_:Error)
               {
                  _loc8_ = _loc_e_;
                  console.report("Save to file is not supported in your flash player.",8);
               }
            }
            else
            {
               System.setClipboard(_loc6_);
               console.report("Copied log to clipboard.",-1);
            }
         }
         else if(_loc3_ == "clear")
         {
            console.clear();
         }
         else if(_loc3_ == "settings")
         {
            console.report("A new window should open in browser. If not, try searching for \'Flash Player Global Security Settings panel\' online :)",-1);
            Security.showSettings(SecurityPanel.SETTINGS_MANAGER);
         }
         else if(_loc3_ == "remote")
         {
            console.get_remoter().set_remoting(2);
         }
         else if(_loc3_.indexOf("ref") == 0)
         {
            console.get_refs().handleRefEvent(_loc3_);
         }
         else if(_loc3_.indexOf("channel_") == 0)
         {
            onChannelPressed(_loc3_.substring(8));
         }
         else if(_loc3_.indexOf("cl_") == 0)
         {
            _loc9_ = _loc3_.indexOf("_",3);
            console.get_cl().handleScopeEvent(ConsoleLib.parseInt(_loc3_.substring(3,_loc9_ < 0 ? _loc3_.length : _loc9_)));
            if(_loc9_ >= 0)
            {
               _cmdField.text = _loc3_.substring(_loc9_ + 1);
            }
         }
         else if(_loc3_.indexOf("external_") == 0)
         {
            _loc10_ = _extraMenus;
            _loc6_ = _loc3_.substring(9);
            _loc11_ = _loc10_;
            _loc12_ = _loc6_ in StringMap.reserved ? Array(_loc11_.getReserved(_loc6_)) : _loc11_.h[_loc6_];
            if(_loc12_ != null)
            {
               _loc5_ = null;
               _loc12_[0].apply(_loc5_,_loc12_[1]);
            }
         }
         txtField.setSelection(0,0);
         e.stopPropagation();
      }
      
      public function lineShouldShow(line:Log) : Boolean
      {
         if(_priority == 0 || line.priority >= _priority)
         {
            if(!(chShouldShow(line.ch) || _filterText != null && _viewingChannels.indexOf("~") >= 0 && line.text.toLowerCase().indexOf(_filterText) >= 0))
            {
               if(_filterRegExp != null && _viewingChannels.indexOf("~") >= 0)
               {
                  return FlashRegex.search(line.text,_filterRegExp) >= 0;
               }
               return false;
            }
            return true;
         }
         return false;
      }
      
      public function keyUpHandler(e:KeyboardEvent) : void
      {
         var _loc3_:* = null as Error;
         if(e.keyCode == Keyboard.SHIFT)
         {
            _shift = false;
         }
         else if(e.keyCode == Keyboard.CONTROL)
         {
            _ctrl = false;
         }
         else if(e.keyCode == 18)
         {
            _alt = false;
         }
         if((e.keyCode == Keyboard.TAB || e.keyCode == Keyboard.ENTER) && parent.visible && visible && _cmdField.visible)
         {
            try
            {
               stage.focus = _cmdField;
               setCLSelectionAtEnd();
            }
            catch(_loc_e_:Error)
            {
               _loc3_ = _loc_e_;
            }
         }
      }
      
      public function keyDownHandler(e:KeyboardEvent) : void
      {
         if(e.keyCode == Keyboard.SHIFT)
         {
            _shift = true;
         }
         if(e.keyCode == Keyboard.CONTROL)
         {
            _ctrl = true;
         }
         if(e.keyCode == 18)
         {
            _alt = true;
         }
      }
      
      public function incPriority(down:Boolean) : void
      {
         var _loc2_:int = 10;
         var _loc3_:int = 0;
         var _loc4_:Log = console.get_logs().last;
         var _loc5_:int = _priority;
         _priority = 0;
         var _loc6_:uint = 32000;
         while(_loc4_ != null && _loc6_ > 0)
         {
            _loc6_ -= 1;
            if(lineShouldShow(_loc4_))
            {
               if(_loc4_.priority > _loc5_ && _loc2_ > _loc4_.priority)
               {
                  _loc2_ = _loc4_.priority;
               }
               if(_loc4_.priority < _loc5_ && _loc3_ < _loc4_.priority)
               {
                  _loc3_ = _loc4_.priority;
               }
            }
            _loc4_ = _loc4_.prev;
         }
         if(down)
         {
            if(_loc3_ == _loc5_)
            {
               _loc5_ = 10;
            }
            else
            {
               _loc5_ = _loc3_;
            }
         }
         else if(_loc2_ == _loc5_)
         {
            _loc5_ = 0;
         }
         else
         {
            _loc5_ = _loc2_;
         }
         set_priority(_loc5_);
      }
      
      public function get_viewingChannels() : Array
      {
         return _viewingChannels;
      }
      
      public function get viewingChannels() : Array
      {
         return get_viewingChannels();
      }
      
      public function get_scrollPercent() : Number
      {
         return (_scroller.y - get_style().controlSize) / (_scrollHeight - 30 - uint(get_style().controlSize * 2));
      }
      
      public function get_reportChannel() : String
      {
         if(int(_viewingChannels.length) == 1)
         {
            return _viewingChannels[0];
         }
         return "C";
      }
      
      public function get reportChannel() : String
      {
         return get_reportChannel();
      }
      
      public function get_priority() : uint
      {
         return _priority;
      }
      
      public function get priority() : uint
      {
         return get_priority();
      }
      
      public function get_ignoredChannels() : Array
      {
         return _ignoredChannels;
      }
      
      public function get ignoredChannels() : Array
      {
         return get_ignoredChannels();
      }
      
      public function get_commandLine() : Boolean
      {
         return _cmdField.visible;
      }
      
      public function get commandLine() : Boolean
      {
         return get_commandLine();
      }
      
      public function getChannelsLink(limited:Boolean = false) : String
      {
         var _loc8_:int = 0;
         var _loc9_:* = null as String;
         var _loc10_:* = null as String;
         var _loc2_:String = "<chs>";
         var _loc3_:Array = console.get_logs().getChannels();
         var _loc4_:int = int(_loc3_.length);
         if(limited && _loc4_ > get_style().maxChannelsInMenu)
         {
            _loc4_ = get_style().maxChannelsInMenu;
         }
         var _loc5_:Boolean = int(_viewingChannels.length) > 0 || int(_ignoredChannels.length) > 0;
         var _loc6_:int = 0;
         var _loc7_:int = _loc4_;
         while(_loc6_ < _loc7_)
         {
            _loc8_ = _loc6_++;
            _loc9_ = _loc3_[_loc8_];
            _loc10_ = !_loc5_ && _loc8_ == 0 || _loc5_ && _loc8_ != 0 && chShouldShow(_loc9_) ? "<ch><b>" + _loc9_ + "</b></ch>" : _loc9_;
            _loc2_ += "<a href=\"event:channel_" + _loc9_ + "\">[" + _loc10_ + "]</a> ";
         }
         if(limited)
         {
            _loc2_ += "<ch><a href=\"event:channels\"><b>" + (int(_loc3_.length) > _loc4_ ? "..." : "") + "</b>^^ </a></ch>";
         }
         return _loc2_ + "</chs> ";
      }
      
      public function endFilter() : void
      {
         _filterRegExp = null;
         _filterText = null;
         if(int(_viewingChannels.length) == 1 && _viewingChannels[0] == "~")
         {
            if(int([" * "].length) == 0)
            {
               setViewingChannels();
            }
            else if(int([" * "].length) == 1)
            {
               setViewingChannels([" * "][0]);
            }
            else if(int([" * "].length) == 2)
            {
               setViewingChannels([" * "][0],[" * "][1]);
            }
            else if(int([" * "].length) == 3)
            {
               setViewingChannels([" * "][0],[" * "][1],[" * "][2]);
            }
            else if(int([" * "].length) == 4)
            {
               setViewingChannels([" * "][0],[" * "][1],[" * "][2],[" * "][3]);
            }
            else if(int([" * "].length) == 5)
            {
               setViewingChannels([" * "][0],[" * "][1],[" * "][2],[" * "][3],[" * "][4]);
            }
            else if(int([" * "].length) == 6)
            {
               setViewingChannels([" * "][0],[" * "][1],[" * "][2],[" * "][3],[" * "][4],[" * "][5]);
            }
            else if(int([" * "].length) == 7)
            {
               setViewingChannels([" * "][0],[" * "][1],[" * "][2],[" * "][3],[" * "][4],[" * "][5],[" * "][6]);
            }
            else if(int([" * "].length) == 8)
            {
               setViewingChannels([" * "][0],[" * "][1],[" * "][2],[" * "][3],[" * "][4],[" * "][5],[" * "][6],[" * "][7]);
            }
            else if(int([" * "].length) == 9)
            {
               setViewingChannels([" * "][0],[" * "][1],[" * "][2],[" * "][3],[" * "][4],[" * "][5],[" * "][6],[" * "][7],[" * "][8]);
            }
            else if(int([" * "].length) == 10)
            {
               setViewingChannels([" * "][0],[" * "][1],[" * "][2],[" * "][3],[" * "][4],[" * "][5],[" * "][6],[" * "][7],[" * "][8],[" * "][9]);
            }
            else if(int([" * "].length) == 11)
            {
               setViewingChannels([" * "][0],[" * "][1],[" * "][2],[" * "][3],[" * "][4],[" * "][5],[" * "][6],[" * "][7],[" * "][8],[" * "][9],[" * "][10]);
            }
            else if(int([" * "].length) == 12)
            {
               setViewingChannels([" * "][0],[" * "][1],[" * "][2],[" * "][3],[" * "][4],[" * "][5],[" * "][6],[" * "][7],[" * "][8],[" * "][9],[" * "][10],[" * "][11]);
            }
            else if(int([" * "].length) == 13)
            {
               setViewingChannels([" * "][0],[" * "][1],[" * "][2],[" * "][3],[" * "][4],[" * "][5],[" * "][6],[" * "][7],[" * "][8],[" * "][9],[" * "][10],[" * "][11],[" * "][12]);
            }
            else if(int([" * "].length) == 14)
            {
               setViewingChannels([" * "][0],[" * "][1],[" * "][2],[" * "][3],[" * "][4],[" * "][5],[" * "][6],[" * "][7],[" * "][8],[" * "][9],[" * "][10],[" * "][11],[" * "][12],[" * "][13]);
            }
            else if(int([" * "].length) == 15)
            {
               setViewingChannels([" * "][0],[" * "][1],[" * "][2],[" * "][3],[" * "][4],[" * "][5],[" * "][6],[" * "][7],[" * "][8],[" * "][9],[" * "][10],[" * "][11],[" * "][12],[" * "][13],[" * "][14]);
            }
            else if(int([" * "].length) == 16)
            {
               setViewingChannels([" * "][0],[" * "][1],[" * "][2],[" * "][3],[" * "][4],[" * "][5],[" * "][6],[" * "][7],[" * "][8],[" * "][9],[" * "][10],[" * "][11],[" * "][12],[" * "][13],[" * "][14],[" * "][15]);
            }
            else if(int([" * "].length) == 17)
            {
               setViewingChannels([" * "][0],[" * "][1],[" * "][2],[" * "][3],[" * "][4],[" * "][5],[" * "][6],[" * "][7],[" * "][8],[" * "][9],[" * "][10],[" * "][11],[" * "][12],[" * "][13],[" * "][14],[" * "][15],[" * "][16]);
            }
            else if(int([" * "].length) == 18)
            {
               setViewingChannels([" * "][0],[" * "][1],[" * "][2],[" * "][3],[" * "][4],[" * "][5],[" * "][6],[" * "][7],[" * "][8],[" * "][9],[" * "][10],[" * "][11],[" * "][12],[" * "][13],[" * "][14],[" * "][15],[" * "][16],[" * "][17]);
            }
            else if(int([" * "].length) == 19)
            {
               setViewingChannels([" * "][0],[" * "][1],[" * "][2],[" * "][3],[" * "][4],[" * "][5],[" * "][6],[" * "][7],[" * "][8],[" * "][9],[" * "][10],[" * "][11],[" * "][12],[" * "][13],[" * "][14],[" * "][15],[" * "][16],[" * "][17],[" * "][18]);
            }
            else
            {
               if(int([" * "].length) != 20)
               {
                  throw "Too many rest arguments";
               }
               setViewingChannels([" * "][0],[" * "][1],[" * "][2],[" * "][3],[" * "][4],[" * "][5],[" * "][6],[" * "][7],[" * "][8],[" * "][9],[" * "][10],[" * "][11],[" * "][12],[" * "][13],[" * "][14],[" * "][15],[" * "][16],[" * "][17],[" * "][18],[" * "][19]);
            }
         }
      }
      
      public function doActive(str:String, b:Boolean) : String
      {
         if(b)
         {
            return "<menuHi>" + str + "</menuHi>";
         }
         return str;
      }
      
      public function commandKeyUp(e:KeyboardEvent) : void
      {
         var _loc2_:* = null as String;
         var _loc3_:int = 0;
         e.stopPropagation();
         if(e.keyCode == Keyboard.ENTER)
         {
            updateToBottom();
            setHints();
            if(_enteringLogin)
            {
               console.get_remoter().login(_cmdField.text);
               _cmdField.text = "";
               requestLogin(false);
            }
            else
            {
               _loc2_ = _cmdField.text;
               if(_loc2_.length > 2)
               {
                  _loc3_ = _cmdsHistory.indexOf(_loc2_);
                  while(_loc3_ >= 0)
                  {
                     _cmdsHistory.splice(_loc3_,1);
                     _loc3_ = _cmdsHistory.indexOf(_loc2_);
                  }
                  _cmdsHistory.unshift(_loc2_);
                  _cmdsInd = -1;
                  if(int(_cmdsHistory.length) > 20)
                  {
                     _cmdsHistory.splice(20,int(_cmdsHistory.length));
                  }
                  console.updateSO("clhistory");
               }
               _cmdField.text = "";
               if(get_config().commandLineInputPassThrough != null)
               {
                  _loc2_ = get_config().commandLineInputPassThrough(_loc2_);
               }
               if(_loc2_ != null && _loc2_ != "")
               {
                  console.get_cl().run(_loc2_);
               }
            }
         }
         else if(e.keyCode == Keyboard.ESCAPE)
         {
            if(stage != null)
            {
               stage.focus = null;
            }
         }
         else if(e.keyCode == Keyboard.UP)
         {
            setHints();
            if(_cmdField.text != null && _cmdField.text != "" && _cmdsInd < 0)
            {
               _cmdsHistory.unshift(_cmdField.text);
               ++_cmdsInd;
            }
            if(_cmdsInd < int(_cmdsHistory.length) - 1)
            {
               ++_cmdsInd;
               _cmdField.text = _cmdsHistory[_cmdsInd];
               setCLSelectionAtEnd();
            }
            else
            {
               _cmdsInd = int(_cmdsHistory.length);
               _cmdField.text = "";
            }
         }
         else if(e.keyCode == Keyboard.DOWN)
         {
            setHints();
            if(_cmdsInd > 0)
            {
               --_cmdsInd;
               _cmdField.text = _cmdsHistory[_cmdsInd];
               setCLSelectionAtEnd();
            }
            else
            {
               _cmdsInd = -1;
               _cmdField.text = "";
            }
         }
         else if(e.keyCode == Keyboard.TAB)
         {
            setCLSelectionAtEnd();
         }
         else if(!_enteringLogin)
         {
            updateCmdHint();
         }
      }
      
      public function commandKeyDown(e:KeyboardEvent) : void
      {
         e.stopPropagation();
         if(e.keyCode == Keyboard.TAB)
         {
            if(_hint != null)
            {
               _cmdField.text = _hint;
               setCLSelectionAtEnd();
               setHints();
            }
         }
      }
      
      public function clearCommandLineHistory(... rest) : void
      {
         _cmdsInd = -1;
         console.updateSO();
         _cmdsHistory = [];
      }
      
      public function chShouldShow(ch:String) : Boolean
      {
         if(int(_viewingChannels.length) == 0 || _viewingChannels.indexOf(ch) >= 0)
         {
            if(int(_ignoredChannels.length) != 0)
            {
               return _ignoredChannels.indexOf(ch) < 0;
            }
            return true;
         }
         return false;
      }
      
      public function addMenu(key:String, f:*, args:Array, rollover:String) : void
      {
         var _loc5_:* = null as Array;
         var _loc6_:* = null as StringMap;
         if(key != null)
         {
            key = FlashRegex.replace(key,new EReg("[^\\w]*","g"),"");
            if(f == null)
            {
               StringMap(_extraMenus).remove(key);
            }
            else
            {
               _loc5_ = [f,args,rollover];
               _loc6_ = StringMap(_extraMenus);
               if(key in StringMap.reserved)
               {
                  _loc6_.setReserved(key,_loc5_);
               }
               else
               {
                  _loc6_.h[key] = _loc5_;
               }
            }
            _needUpdateMenu = true;
         }
         else
         {
            console.report("ERROR: Invalid add menu params.",9);
         }
      }
      
      public function addFilterText(txt:String) : String
      {
         var _loc3_:* = null as RegexResult;
         var _loc4_:int = 0;
         var _loc5_:* = null as String;
         var _loc2_:* = 0;
         if(_filterRegExp != null)
         {
            _loc2_ = 0;
            _loc3_ = FlashRegex.exec(txt,_filterRegExp,_loc2_);
            while(_loc3_ != null)
            {
               _loc4_ = _loc3_.index;
               _loc5_ = _loc3_.elements[0];
               _loc2_ = _loc4_ + (_loc5_.length > 0 ? _loc5_.length : 1);
               if(FlashRegex.search(_loc5_,new EReg("<|>","")) >= 0)
               {
                  _loc2_ -= _loc5_.length - FlashRegex.search(_loc5_,new EReg("<|>",""));
               }
               else if(txt.lastIndexOf("<",_loc4_) <= txt.lastIndexOf(">",_loc4_))
               {
                  txt = txt.substring(0,_loc4_) + "<u>" + txt.substring(_loc4_,_loc4_ + _loc5_.length) + "</u>" + txt.substring(_loc4_ + _loc5_.length);
                  _loc2_ += 7;
               }
               _loc3_ = FlashRegex.exec(txt,_filterRegExp,_loc2_);
            }
         }
         else if(_filterText != null)
         {
            _loc5_ = txt.toLowerCase();
            _loc4_ = _loc5_.lastIndexOf(_filterText);
            while(_loc4_ >= 0)
            {
               txt = txt.substring(0,_loc4_) + "<u>" + txt.substring(_loc4_,_loc4_ + _filterText.length) + "</u>" + txt.substring(_loc4_ + _filterText.length);
               _loc4_ = _loc5_.lastIndexOf(_filterText,_loc4_ - 2);
            }
         }
         return txt;
      }
      
      public function _updateTraces(onlyBottom:Boolean = false) : void
      {
         if(_atBottom)
         {
            updateBottom();
         }
         else if(!onlyBottom)
         {
            updateFull();
         }
         if(_selectionStart != _selectionEnd)
         {
            if(_atBottom)
            {
               _traceField.setSelection(_traceField.text.length - _selectionStart,_traceField.text.length - _selectionEnd);
            }
            else
            {
               _traceField.setSelection(_traceField.text.length - _selectionEnd,_traceField.text.length - _selectionStart);
            }
            _selectionEnd = -1;
            _selectionStart = -1;
         }
      }
      
      public function _updateMenu() : void
      {
         var _loc2_:Boolean = false;
         var _loc3_:* = null as StringMap;
         var _loc4_:* = null;
         var _loc5_:* = null;
         var _loc6_:int = 0;
         var _loc7_:Boolean = false;
         var _loc8_:* = null;
         var _loc9_:int = 0;
         var _loc10_:Boolean = false;
         var _loc11_:int = 0;
         var _loc12_:* = null;
         var _loc13_:int = 0;
         var _loc14_:Boolean = false;
         var _loc15_:* = null as String;
         var _loc16_:* = null as String;
         var _loc1_:String = "<r><high>";
         if(_mini || !get_style().topMenu)
         {
            _loc1_ += "<menu><b> <a href=\"event:show\">‹</a>";
         }
         else
         {
            if(!console.get_panels().get_channelsPanel())
            {
               _loc1_ += getChannelsLink(true);
            }
            _loc1_ += "<menu> <b>";
            _loc2_ = false;
            _loc3_ = StringMap(_extraMenus);
            _loc4_ = _loc3_.h;
            _loc5_ = _loc3_.rh;
            _loc6_ = 0;
            _loc7_ = false;
            _loc8_ = _loc4_;
            _loc9_ = _loc6_;
            _loc10_ = §§hasnext(_loc8_,_loc9_);
            if(!_loc10_ && _loc5_ != null)
            {
               _loc8_ = _loc4_ = _loc5_;
               _loc9_ = _loc6_ = 0;
               _loc5_ = null;
               _loc7_ = true;
               _loc10_ = §§hasnext(_loc8_,_loc9_);
            }
            _loc11_ = _loc9_;
            while(true)
            {
               _loc12_ = _loc4_;
               _loc13_ = _loc6_;
               _loc14_ = §§hasnext(_loc12_,_loc13_);
               if(!_loc14_ && _loc5_ != null)
               {
                  _loc12_ = _loc4_ = _loc5_;
                  _loc13_ = _loc6_ = 0;
                  _loc5_ = null;
                  _loc7_ = true;
                  _loc14_ = §§hasnext(_loc12_,_loc13_);
               }
               _loc11_ = _loc13_;
               if(!_loc14_)
               {
                  break;
               }
               _loc15_ = §§nextname(_loc11_,_loc4_);
               _loc6_ = _loc11_;
               if(_loc7_)
               {
                  _loc15_ = _loc15_.substr(1);
               }
               _loc16_ = _loc15_;
               _loc1_ += "<a href=\"event:external_" + _loc16_ + "\">" + _loc16_ + "</a> ";
               _loc2_ = true;
            }
            if(_loc2_)
            {
               _loc1_ += "¦ ";
            }
            _loc1_ += doActive("<a href=\"event:fps\">F</a>",console.get_fpsMonitor() == true);
            _loc1_ += doActive(" <a href=\"event:mm\">M</a>",console.get_memoryMonitor() == true);
            _loc1_ += doActive(" <a href=\"event:command\">CL</a>",get_commandLine());
            if(console.get_remoter().get_remoting() != 2)
            {
               if(get_config().displayRollerEnabled)
               {
                  _loc1_ += doActive(" <a href=\"event:roller\">Ro</a>",console.get_displayRoller());
               }
               if(get_config().rulerToolEnabled)
               {
                  _loc1_ += doActive(" <a href=\"event:ruler\">RL</a>",console.get_panels().get_rulerActive());
               }
            }
            _loc1_ += " ¦</b>";
            _loc1_ += " <a href=\"event:copy\">Sv</a>";
            _loc1_ += " <a href=\"event:priority\">P" + _priority + "</a>";
            _loc1_ += doActive(" <a href=\"event:pause\">P</a>",console.get_paused());
            _loc1_ += " <a href=\"event:clear\">C</a> <a href=\"event:close\">X</a> <a href=\"event:hide\">›</a>";
         }
         _loc1_ += " </b></menu></high></r>";
         txtField.htmlText = _loc1_;
         txtField.scrollH = txtField.maxScrollH;
         updateTraceFHeight();
      }
   }
}

