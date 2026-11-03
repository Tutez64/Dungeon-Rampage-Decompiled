package com.junkbyte.console.view
{
   import com.junkbyte.console.Console;
   import com.junkbyte.console.ConsoleConfig;
   import com.junkbyte.console.ConsoleStyle;
   import com.junkbyte.console.core.Logs;
   import com.junkbyte.console.vos.GraphGroup;
   import flash.Boot;
   import flash.display.DisplayObject;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import haxe.IMap;
   import haxe.ds.StringMap;
   
   public class PanelsManager
   {
      
      public var console:Console;
      
      public var _tooltipField:TextField;
      
      public var _ruler:Ruler;
      
      public var _memPanel:GraphingPanel;
      
      public var _mainPanel:MainPanel;
      
      public var _graphsMap:IMap;
      
      public var _graphPlaced:uint;
      
      public var _fpsPanel:GraphingPanel;
      
      public var _chsPanel:ChannelsPanel;
      
      public var _canDraw:Boolean;
      
      public function PanelsManager(master:Console = undefined)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         _graphPlaced = 0;
         _graphsMap = new StringMap();
         console = master;
         _mainPanel = new MainPanel(console);
         _tooltipField = get_mainPanel().makeTF("tooltip",true);
         _tooltipField.mouseEnabled = false;
         _tooltipField.autoSize = TextFieldAutoSize.CENTER;
         _tooltipField.multiline = true;
         addPanel(_mainPanel);
      }
      
      public function updateMenu() : void
      {
         _mainPanel.updateMenu();
         var _loc1_:ConsolePanel = getPanel("channelsPanel");
         var _loc2_:ChannelsPanel = _loc1_ as ChannelsPanel;
         if(_loc2_ != null)
         {
            _loc2_.update();
         }
      }
      
      public function updateGraphs(graphs:Array) : void
      {
         var _loc6_:* = null as GraphGroup;
         var _loc7_:* = null as String;
         var _loc8_:* = null as StringMap;
         var _loc9_:* = null as GraphingPanel;
         var _loc10_:* = null as Rectangle;
         var _loc11_:int = 0;
         var _loc12_:Boolean = false;
         var _loc13_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc15_:* = 0;
         var _loc16_:int = 0;
         var _loc17_:int = 0;
         var _loc18_:Boolean = false;
         var _loc19_:Boolean = false;
         var _loc20_:* = null as StringMap;
         var _loc24_:* = null;
         var _loc25_:* = null as String;
         var _loc2_:* = null;
         var _loc3_:GraphGroup = null;
         var _loc4_:GraphGroup = null;
         _graphPlaced = 0;
         var _loc5_:int = 0;
         while(_loc5_ < int(graphs.length))
         {
            _loc6_ = graphs[_loc5_];
            _loc5_++;
            if(_loc6_.type == 1)
            {
               _loc3_ = _loc6_;
            }
            else if(_loc6_.type == 2)
            {
               _loc4_ = _loc6_;
            }
            else
            {
               _loc7_ = _loc6_.name;
               _loc8_ = StringMap(_graphsMap);
               _loc9_ = _loc7_ in StringMap.reserved ? GraphingPanel(_loc8_.getReserved(_loc7_)) : _loc8_.h[_loc7_];
               if(_loc9_ == null)
               {
                  _loc10_ = _loc6_.rect;
                  if(_loc10_ == null)
                  {
                     _loc10_ = new Rectangle(Number(Number.NaN),Number(Number.NaN),0,0);
                  }
                  _loc11_ = 100;
                  _loc13_ = _loc10_.x;
                  if(_loc13_ == _loc13_)
                  {
                     _loc14_ = _loc10_.y;
                     _loc12_ = _loc14_ != _loc14_;
                  }
                  else
                  {
                     _loc12_ = true;
                  }
                  if(_loc12_)
                  {
                     if(_mainPanel.get_width() < 150)
                     {
                        _loc11_ = 50;
                     }
                     _loc15_ = int(Math.floor(_mainPanel.get_width() / _loc11_)) - 1;
                     if(_loc15_ <= 1)
                     {
                        _loc15_ = 2;
                     }
                     _loc16_ = _graphPlaced % _loc15_;
                     _loc17_ = Math.floor(_graphPlaced / _loc15_);
                     _loc10_.x = _mainPanel.x + _loc11_ + _loc16_ * _loc11_;
                     _loc10_.y = _mainPanel.y + _loc11_ * 0.6 + _loc17_ * _loc11_;
                     ++_graphPlaced;
                  }
                  if(_loc10_.width > 0)
                  {
                     _loc14_ = _loc10_.width;
                     _loc18_ = _loc14_ != _loc14_;
                  }
                  else
                  {
                     _loc18_ = true;
                  }
                  if(_loc18_)
                  {
                     _loc10_.width = _loc11_;
                  }
                  if(_loc10_.height > 0)
                  {
                     _loc14_ = _loc10_.height;
                     _loc19_ = _loc14_ != _loc14_;
                  }
                  else
                  {
                     _loc19_ = true;
                  }
                  if(_loc19_)
                  {
                     _loc10_.height = _loc11_;
                  }
                  _loc9_ = new GraphingPanel(console,_loc10_.width,_loc10_.height);
                  _loc9_.x = _loc10_.x;
                  _loc9_.y = _loc10_.y;
                  _loc9_.name = "graph_" + _loc7_;
                  _loc20_ = StringMap(_graphsMap);
                  if(_loc7_ in StringMap.reserved)
                  {
                     _loc20_.setReserved(_loc7_,_loc9_);
                  }
                  else
                  {
                     _loc20_.h[_loc7_] = _loc9_;
                  }
                  addPanel(_loc9_);
               }
               if(_loc2_ == null)
               {
                  _loc2_ = {};
               }
               _loc2_[_loc7_] = true;
               _loc9_.update(_loc6_,_canDraw);
            }
         }
         _loc8_ = StringMap(_graphsMap);
         var _loc21_:* = _loc8_.h;
         var _loc22_:* = _loc8_.rh;
         _loc5_ = 0;
         _loc12_ = false;
         var _loc23_:* = _loc21_;
         _loc11_ = _loc5_;
         _loc18_ = §§hasnext(_loc23_,_loc11_);
         if(!_loc18_ && _loc22_ != null)
         {
            _loc23_ = _loc21_ = _loc22_;
            _loc11_ = _loc5_ = 0;
            _loc22_ = null;
            _loc12_ = true;
            _loc18_ = §§hasnext(_loc23_,_loc11_);
         }
         _loc15_ = _loc11_;
         while(true)
         {
            _loc24_ = _loc21_;
            _loc16_ = _loc5_;
            _loc19_ = §§hasnext(_loc24_,_loc16_);
            if(!_loc19_ && _loc22_ != null)
            {
               _loc24_ = _loc21_ = _loc22_;
               _loc16_ = _loc5_ = 0;
               _loc22_ = null;
               _loc12_ = true;
               _loc19_ = §§hasnext(_loc24_,_loc16_);
            }
            _loc15_ = _loc16_;
            if(!_loc19_)
            {
               break;
            }
            _loc7_ = §§nextname(_loc15_,_loc21_);
            _loc5_ = _loc15_;
            if(_loc12_)
            {
               _loc7_ = _loc7_.substr(1);
            }
            _loc25_ = _loc7_;
            if(_loc2_ == null || !Reflect.hasField(_loc2_,_loc25_))
            {
               _loc20_ = StringMap(_graphsMap);
               (_loc25_ in StringMap.reserved ? GraphingPanel(_loc20_.getReserved(_loc25_)) : _loc20_.h[_loc25_]).close();
               StringMap(_graphsMap).remove(_loc25_);
            }
         }
         if(_loc3_ != null)
         {
            if(_fpsPanel == null)
            {
               _fpsPanel = new GraphingPanel(console,80,40,"fpsPanel");
               _fpsPanel.name = "fpsPanel";
               _fpsPanel.x = _mainPanel.x + _mainPanel.get_width() - 160;
               _fpsPanel.y = _mainPanel.y + 15;
               addPanel(_fpsPanel);
               _mainPanel.updateMenu();
            }
            _fpsPanel.update(_loc3_,_canDraw);
         }
         else if(_fpsPanel != null)
         {
            removePanel("fpsPanel");
            _fpsPanel = null;
         }
         if(_loc4_ != null)
         {
            if(_memPanel == null)
            {
               _memPanel = new GraphingPanel(console,80,40,"memoryPanel");
               _memPanel.name = "memoryPanel";
               _memPanel.x = _mainPanel.x + _mainPanel.get_width() - 80;
               _memPanel.y = _mainPanel.y + 15;
               addPanel(_memPanel);
               _mainPanel.updateMenu();
            }
            _memPanel.update(_loc4_,_canDraw);
         }
         else if(_memPanel != null)
         {
            removePanel("memoryPanel");
            _memPanel = null;
         }
         _canDraw = false;
      }
      
      public function update(paused:Boolean, lineAdded:Boolean) : void
      {
         _canDraw = !paused;
         _mainPanel.update(!paused && lineAdded);
         if(!paused)
         {
            if(lineAdded && _chsPanel != null)
            {
               _chsPanel.update();
            }
         }
      }
      
      public function tooltip(str:String = undefined, panel:ConsolePanel = undefined) : void
      {
         var _loc3_:* = null as Array;
         var _loc4_:* = null as Rectangle;
         var _loc5_:* = null as Rectangle;
         var _loc6_:Number = NaN;
         var _loc7_:* = null as TextField;
         var _loc8_:Number = NaN;
         var _loc9_:Number = NaN;
         if(str != null && str != "" && !get_rulerActive())
         {
            _loc3_ = str.split("::");
            str = _loc3_[0];
            if(int(_loc3_.length) > 1)
            {
               str += "<br/><low>" + _loc3_[1] + "</low>";
            }
            console.addChild(_tooltipField);
            _tooltipField.wordWrap = false;
            _tooltipField.htmlText = "<tt>" + str + "</tt>";
            if(_tooltipField.width > 120)
            {
               _tooltipField.width = 120;
               _tooltipField.wordWrap = true;
            }
            _tooltipField.x = console.mouseX - _tooltipField.width / 2;
            _tooltipField.y = console.mouseY + 20;
            if(panel != null)
            {
               _loc4_ = _tooltipField.getBounds(console);
               _loc5_ = new Rectangle(panel.x,panel.y,panel.get_width(),panel.get_height());
               _loc6_ = _loc4_.bottom - _loc5_.bottom;
               if(_loc6_ > 0)
               {
                  if(_tooltipField.y - _loc6_ > console.mouseY + 15)
                  {
                     _loc7_ = _tooltipField;
                     _loc7_.y -= _loc6_;
                  }
                  else if(_loc5_.y < console.mouseY - 24 && _loc4_.y > _loc5_.bottom)
                  {
                     _tooltipField.y = console.mouseY - _tooltipField.height - 15;
                  }
               }
               _loc8_ = _loc4_.left - _loc5_.left;
               _loc9_ = _loc4_.right - _loc5_.right;
               if(_loc8_ < 0)
               {
                  _loc7_ = _tooltipField;
                  _loc7_.x -= _loc8_;
               }
               else if(_loc9_ > 0)
               {
                  _loc7_ = _tooltipField;
                  _loc7_.x -= _loc9_;
               }
            }
         }
         else if(console.contains(_tooltipField))
         {
            console.removeChild(_tooltipField);
         }
      }
      
      public function startRuler() : void
      {
         if(get_rulerActive())
         {
            return;
         }
         _ruler = new Ruler(console);
         _ruler.addEventListener(Event.COMPLETE,onRulerExit,false,0,true);
         console.addChild(_ruler);
         _mainPanel.updateMenu();
      }
      
      public function set_displayRoller(n:Boolean) : Boolean
      {
         var _loc2_:* = null as RollerPanel;
         if(get_displayRoller() != n)
         {
            if(n)
            {
               if(console.get_config().displayRollerEnabled)
               {
                  _loc2_ = new RollerPanel(console);
                  _loc2_.x = _mainPanel.x + _mainPanel.get_width() - 180;
                  _loc2_.y = _mainPanel.y + 55;
                  addPanel(_loc2_);
               }
               else
               {
                  console.report("Display roller is disabled in config.",9);
               }
            }
            else
            {
               removePanel("rollerPanel");
            }
            _mainPanel.updateMenu();
         }
         return n;
      }
      
      public function set displayRoller(value:Boolean) : void
      {
         set_displayRoller(value);
      }
      
      public function set_channelsPanel(b:Boolean) : Boolean
      {
         if(get_channelsPanel() != b)
         {
            console.get_logs().cleanChannels();
            if(b)
            {
               _chsPanel = new ChannelsPanel(console);
               _chsPanel.x = _mainPanel.x + _mainPanel.get_width() - 332;
               _chsPanel.y = _mainPanel.y - 2;
               addPanel(_chsPanel);
               _chsPanel.update();
               updateMenu();
            }
            else
            {
               removePanel("channelsPanel");
               _chsPanel = null;
            }
            updateMenu();
         }
         return b;
      }
      
      public function set channelsPanel(value:Boolean) : void
      {
         set_channelsPanel(value);
      }
      
      public function setPanelArea(panelname:String, rect:Rectangle) : void
      {
         var _loc3_:ConsolePanel = getPanel(panelname);
         if(_loc3_ != null)
         {
            _loc3_.x = rect.x;
            _loc3_.y = rect.y;
            if(rect.width != 0)
            {
               _loc3_.set_width(rect.width);
            }
            if(rect.height != 0)
            {
               _loc3_.set_height(rect.height);
            }
         }
      }
      
      public function removePanel(n:String) : void
      {
         var _loc2_:DisplayObject = console.getChildByName(n);
         var _loc3_:ConsolePanel = _loc2_ as ConsolePanel;
         if(_loc3_ != null)
         {
            _loc3_.close();
         }
      }
      
      public function removeGraph(group:GraphGroup) : void
      {
         var _loc2_:* = null as String;
         var _loc3_:* = null as StringMap;
         var _loc4_:* = null as GraphingPanel;
         if(_fpsPanel != null && group == _fpsPanel.get_group())
         {
            _fpsPanel.close();
            _fpsPanel = null;
         }
         else if(_memPanel != null && group == _memPanel.get_group())
         {
            _memPanel.close();
            _memPanel = null;
         }
         else
         {
            _loc2_ = group.name;
            _loc3_ = StringMap(_graphsMap);
            _loc4_ = _loc2_ in StringMap.reserved ? GraphingPanel(_loc3_.getReserved(_loc2_)) : _loc3_.h[_loc2_];
            if(_loc4_ != null)
            {
               _loc4_.close();
               StringMap(_graphsMap).remove(group.name);
            }
         }
      }
      
      public function panelExists(n:String) : Boolean
      {
         if(console.getChildByName(n) is ConsolePanel)
         {
            return true;
         }
         return false;
      }
      
      public function onRulerExit(e:Event) : void
      {
         if(_ruler != null && console.contains(_ruler))
         {
            console.removeChild(_ruler);
         }
         _ruler = null;
         _mainPanel.updateMenu();
      }
      
      public function onPanelStartDragScale(e:Event) : void
      {
         var _loc3_:* = null as Array;
         var _loc4_:* = null as Array;
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:* = null as ConsolePanel;
         var _loc2_:ConsolePanel = ConsolePanel(e.currentTarget);
         if(console.get_config().get_style().panelSnapping != 0)
         {
            _loc3_ = [0];
            _loc4_ = [0];
            if(console.stage != null)
            {
               _loc3_.push(console.stage.stageWidth);
               _loc4_.push(console.stage.stageHeight);
            }
            _loc5_ = console.numChildren;
            _loc6_ = 0;
            _loc7_ = _loc5_;
            while(_loc6_ < _loc7_)
            {
               _loc8_ = _loc6_++;
               if(console.getChildAt(_loc8_) is ConsolePanel)
               {
                  _loc9_ = console.getChildAt(_loc8_);
                  if(_loc9_ != null && _loc9_.visible)
                  {
                     _loc3_.push(_loc9_.x);
                     _loc3_.push(_loc9_.x + _loc9_.get_width());
                     _loc4_.push(_loc9_.y);
                     _loc4_.push(_loc9_.y + _loc9_.get_height());
                  }
               }
            }
            _loc2_.registerSnaps(_loc3_,_loc4_);
         }
      }
      
      public function get_rulerActive() : Boolean
      {
         if(_ruler != null && console.contains(_ruler))
         {
            return true;
         }
         return false;
      }
      
      public function get rulerActive() : Boolean
      {
         return get_rulerActive();
      }
      
      public function get_memoryMonitor() : Boolean
      {
         return _memPanel != null;
      }
      
      public function get memoryMonitor() : Boolean
      {
         return get_memoryMonitor();
      }
      
      public function get_mainPanel() : MainPanel
      {
         return _mainPanel;
      }
      
      public function get mainPanel() : MainPanel
      {
         return get_mainPanel();
      }
      
      public function get_fpsMonitor() : Boolean
      {
         return _fpsPanel != null;
      }
      
      public function get fpsMonitor() : Boolean
      {
         return get_fpsMonitor();
      }
      
      public function get_displayRoller() : Boolean
      {
         if(getPanel("rollerPanel") is RollerPanel)
         {
            return true;
         }
         return false;
      }
      
      public function get displayRoller() : Boolean
      {
         return get_displayRoller();
      }
      
      public function get_channelsPanel() : Boolean
      {
         return _chsPanel != null;
      }
      
      public function get channelsPanel() : Boolean
      {
         return get_channelsPanel();
      }
      
      public function getPanel(n:String) : ConsolePanel
      {
         var _loc2_:DisplayObject = console.getChildByName(n);
         return _loc2_ as ConsolePanel;
      }
      
      public function addPanel(panel:ConsolePanel) : void
      {
         if(console.contains(_tooltipField))
         {
            console.addChildAt(panel,console.getChildIndex(_tooltipField));
         }
         else
         {
            console.addChild(panel);
         }
         panel.addEventListener("draggingStarted",onPanelStartDragScale,false,0,true);
         panel.addEventListener("scalingStarted",onPanelStartDragScale,false,0,true);
      }
   }
}

