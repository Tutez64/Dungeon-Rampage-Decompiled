package com.junkbyte.console.view
{
   import com.junkbyte.console.Console;
   import com.junkbyte.console.ConsoleStyle;
   import com.junkbyte.console.core.Graphing;
   import com.junkbyte.console.text.StyleSheet;
   import com.junkbyte.console.vos.GraphGroup;
   import com.junkbyte.console.vos.GraphInterest;
   import flash.Boot;
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.events.TextEvent;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import haxe.IMap;
   import haxe.ds.StringMap;
   
   public class GraphingPanel extends ConsolePanel
   {
      
      public static var FPS:String = "fpsPanel";
      
      public static var MEM:String = "memoryPanel";
      
      public var underlay:Shape;
      
      public var startOffset:int;
      
      public var lowTxt:TextField;
      
      public var highTxt:TextField;
      
      public var graph:Shape;
      
      public var _type:String;
      
      public var _needRedraw:Boolean;
      
      public var _menuString:String;
      
      public var _interest:GraphInterest;
      
      public var _infoMap:IMap;
      
      public var _group:GraphGroup;
      
      public function GraphingPanel(m:Console = undefined, W:Number = 0, H:Number = 0, type:String = undefined)
      {
         if(!Boot.skip_constructor)
         {
            startOffset = 5;
            _infoMap = new StringMap();
            super(m);
            _type = type;
            registerDragger(bg);
            minWidth = 32;
            minHeight = 26;
            var _loc5_:TextFormat = new TextFormat();
            var _loc6_:* = get_style().get_styleSheet().getStyle("low");
            _loc5_.font = _loc6_.fontFamily;
            _loc5_.size = _loc6_.fontSize;
            _loc5_.color = get_style().lowColor;
            lowTxt = new TextField();
            lowTxt.name = "lowestField";
            lowTxt.defaultTextFormat = _loc5_;
            lowTxt.mouseEnabled = false;
            lowTxt.height = get_style().menuFontSize + 2;
            addChild(lowTxt);
            highTxt = new TextField();
            highTxt.name = "highestField";
            highTxt.defaultTextFormat = _loc5_;
            highTxt.mouseEnabled = false;
            highTxt.height = get_style().menuFontSize + 2;
            highTxt.y = get_style().menuFontSize - 4;
            addChild(highTxt);
            txtField = makeTF("menuField");
            txtField.height = get_style().menuFontSize + 4;
            txtField.y = -3;
            txtField.selectable = false;
            registerTFRoller(txtField,onMenuRollOver,linkHandler);
            registerDragger(txtField);
            addChild(txtField);
            underlay = new Shape();
            addChild(underlay);
            graph = new Shape();
            graph.name = "graph";
            graph.y = get_style().menuFontSize;
            addChild(graph);
            _menuString = "<menu>";
            if(_type == "memoryPanel")
            {
               _menuString += " <a href=\"event:gc\">G</a> ";
            }
            _menuString += "<a href=\"event:reset\">R</a> <a href=\"event:close\">X</a></menu></low></r>";
            init(W,H,true);
         }
      }
      
      public function updateKeyText() : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:* = null;
         var _loc4_:* = null as StringMap;
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
         var _loc17_:* = null as StringMap;
         var _loc1_:String = "<r><low>";
         if(_type != null)
         {
            _loc2_ = _interest.v;
            if(_loc2_ != _loc2_)
            {
               _loc1_ += "no input";
            }
            else if(_type == "fpsPanel")
            {
               _loc3_ = _interest.avg;
               _loc1_ += Std.string(_loc3_.toFixed(1));
            }
            else if(_type == "memoryPanel")
            {
               _loc1_ += _interest.v + "mb";
            }
         }
         else
         {
            _loc4_ = StringMap(_infoMap);
            _loc3_ = _loc4_.h;
            _loc5_ = _loc4_.rh;
            _loc6_ = 0;
            _loc7_ = false;
            _loc8_ = _loc3_;
            _loc9_ = _loc6_;
            _loc10_ = §§hasnext(_loc8_,_loc9_);
            if(!_loc10_ && _loc5_ != null)
            {
               _loc3_ = _loc5_;
               _loc8_ = _loc3_;
               _loc9_ = _loc6_ = 0;
               _loc5_ = null;
               _loc7_ = true;
               _loc10_ = §§hasnext(_loc8_,_loc9_);
            }
            _loc11_ = _loc9_;
            while(true)
            {
               _loc12_ = _loc3_;
               _loc13_ = _loc6_;
               _loc14_ = §§hasnext(_loc12_,_loc13_);
               if(!_loc14_ && _loc5_ != null)
               {
                  _loc3_ = _loc5_;
                  _loc12_ = _loc3_;
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
               _loc15_ = §§nextname(_loc11_,_loc3_);
               _loc6_ = _loc11_;
               if(_loc7_)
               {
                  _loc15_ = _loc15_.substr(1);
               }
               _loc16_ = _loc15_;
               _loc17_ = StringMap(_infoMap);
               _loc1_ += " <font color=\'#" + Std.string((_loc16_ in StringMap.reserved ? Array(_loc17_.getReserved(_loc16_)) : _loc17_.h[_loc16_])[0]) + "\'>" + _loc16_ + "</font>";
            }
            _loc1_ += " |";
         }
         txtField.htmlText = _loc1_ + _menuString;
         txtField.scrollH = txtField.maxScrollH;
      }
      
      public function update(group:GraphGroup, draw:Boolean) : void
      {
         var _loc12_:* = null as GraphInterest;
         var _loc13_:* = null as String;
         var _loc14_:* = null as StringMap;
         var _loc15_:* = null as Array;
         var _loc16_:* = null as StringMap;
         var _loc17_:* = null as Array;
         var _loc18_:* = 0;
         var _loc19_:int = 0;
         var _loc20_:int = 0;
         var _loc21_:Number = NaN;
         var _loc22_:int = 0;
         var _loc23_:int = 0;
         var _loc24_:int = 0;
         var _loc25_:Number = NaN;
         var _loc31_:* = null;
         var _loc32_:Boolean = false;
         var _loc33_:* = null as String;
         var _loc34_:Boolean = false;
         _group = group;
         var _loc3_:int = 1;
         if(group.idle > 0)
         {
            _loc3_ = 0;
            if(!_needRedraw)
            {
               return;
            }
         }
         if(_needRedraw)
         {
            draw = true;
         }
         _needRedraw = false;
         var _loc4_:Array = group.interests;
         var _loc5_:int = get_width() - startOffset;
         var _loc6_:int = get_height() - graph.y;
         var _loc7_:Number = group.low;
         var _loc8_:Number = group.hi;
         var _loc9_:Number = _loc8_ - _loc7_;
         var _loc10_:Boolean = false;
         if(draw)
         {
            (group.inv ? highTxt : lowTxt).text = "" + group.low;
            (group.inv ? lowTxt : highTxt).text = "" + group.hi;
            graph.graphics.clear();
         }
         var _loc11_:int = 0;
         while(_loc11_ < int(_loc4_.length))
         {
            _loc12_ = _loc4_[_loc11_];
            _loc11_++;
            _interest = _loc12_;
            _loc13_ = _interest.key;
            _loc14_ = StringMap(_infoMap);
            _loc15_ = _loc13_ in StringMap.reserved ? Array(_loc14_.getReserved(_loc13_)) : _loc14_.h[_loc13_];
            if(_loc15_ == null)
            {
               _loc10_ = true;
               _loc15_ = [StringTools.hex(_interest.col),[]];
               _loc16_ = StringMap(_infoMap);
               if(_loc13_ in StringMap.reserved)
               {
                  _loc16_.setReserved(_loc13_,_loc15_);
               }
               else
               {
                  _loc16_.h[_loc13_] = _loc15_;
               }
            }
            _loc17_ = _loc15_[1];
            if(_loc3_ == 1)
            {
               if(group.type == 1)
               {
                  _loc18_ = int(Math.floor(group.hi / _interest.v));
                  if(_loc18_ > 30)
                  {
                     _loc18_ = 30;
                  }
                  while(_loc18_ > 0)
                  {
                     _loc17_.push(_interest.v);
                     _loc18_--;
                  }
               }
               else
               {
                  _loc17_.push(_interest.v);
               }
            }
            _loc18_ = int(Math.floor(_loc5_)) + 10;
            while(int(_loc17_.length) > _loc18_)
            {
               _loc17_.shift();
            }
            if(draw)
            {
               _loc19_ = int(_loc17_.length);
               graph.graphics.lineStyle(1,_interest.col);
               _loc20_ = _loc5_ > _loc19_ ? _loc19_ : _loc5_;
               _loc22_ = 1;
               _loc23_ = _loc20_;
               while(_loc22_ < _loc23_)
               {
                  _loc24_ = _loc22_++;
                  _loc21_ = (_loc9_ != 0 ? (Number(_loc17_[_loc19_ - _loc24_]) - _loc7_) / _loc9_ : 0.5) * _loc6_;
                  if(!group.inv)
                  {
                     _loc21_ = _loc6_ - _loc21_;
                  }
                  if(_loc21_ < 0)
                  {
                     _loc21_ = 0;
                  }
                  if(_loc21_ > _loc6_)
                  {
                     _loc21_ = _loc6_;
                  }
                  if(_loc24_ == 1)
                  {
                     graph.graphics.moveTo(get_width(),_loc21_);
                  }
                  graph.graphics.lineTo(_loc5_ - _loc24_,_loc21_);
               }
               _loc25_ = _interest.avg;
               if(_loc25_ == _loc25_ && _loc9_ != 0)
               {
                  _loc21_ = (_interest.avg - _loc7_) / _loc9_ * _loc6_;
                  if(!group.inv)
                  {
                     _loc21_ = _loc6_ - _loc21_;
                  }
                  if(_loc21_ < 0)
                  {
                     _loc21_ = 0;
                  }
                  if(_loc21_ > _loc6_)
                  {
                     _loc21_ = _loc6_;
                  }
                  graph.graphics.lineStyle(1,_interest.col,0.3);
                  graph.graphics.moveTo(0,_loc21_);
                  graph.graphics.lineTo(_loc5_,_loc21_);
               }
            }
         }
         _loc14_ = StringMap(_infoMap);
         var _loc26_:* = _loc14_.h;
         var _loc27_:* = _loc14_.rh;
         _loc11_ = 0;
         var _loc28_:Boolean = false;
         var _loc29_:* = _loc26_;
         _loc18_ = _loc11_;
         var _loc30_:Boolean = §§hasnext(_loc29_,_loc18_);
         if(!_loc30_ && _loc27_ != null)
         {
            _loc29_ = _loc26_ = _loc27_;
            _loc18_ = _loc11_ = 0;
            _loc27_ = null;
            _loc28_ = true;
            _loc30_ = §§hasnext(_loc29_,_loc18_);
         }
         _loc19_ = _loc18_;
         while(true)
         {
            _loc31_ = _loc26_;
            _loc20_ = _loc11_;
            _loc32_ = §§hasnext(_loc31_,_loc20_);
            if(!_loc32_ && _loc27_ != null)
            {
               _loc31_ = _loc26_ = _loc27_;
               _loc20_ = _loc11_ = 0;
               _loc27_ = null;
               _loc28_ = true;
               _loc32_ = §§hasnext(_loc31_,_loc20_);
            }
            _loc19_ = _loc20_;
            if(!_loc32_)
            {
               break;
            }
            _loc13_ = §§nextname(_loc19_,_loc26_);
            _loc11_ = _loc19_;
            if(_loc28_)
            {
               _loc13_ = _loc13_.substr(1);
            }
            _loc33_ = _loc13_;
            _loc34_ = false;
            _loc22_ = 0;
            while(_loc22_ < int(_loc4_.length))
            {
               _loc12_ = _loc4_[_loc22_];
               _loc22_++;
               if(_loc12_.key == _loc33_)
               {
                  _loc34_ = true;
               }
            }
            if(!_loc34_)
            {
               _loc10_ = true;
               StringMap(_infoMap).remove(_loc33_);
            }
         }
         if(draw && (_loc10_ || _type != null))
         {
            updateKeyText();
         }
      }
      
      public function stop() : void
      {
         if(_group != null)
         {
            console.get_graphing().remove(_group.name);
         }
      }
      
      override public function set_width(value:Number) : Number
      {
         super.set_width(value);
         lowTxt.width = value;
         highTxt.width = value;
         txtField.width = value;
         txtField.scrollH = txtField.maxScrollH;
         graph.graphics.clear();
         _needRedraw = true;
         return value;
      }
      
      override public function set_height(value:Number) : Number
      {
         super.set_height(value);
         lowTxt.y = value - get_style().menuFontSize;
         _needRedraw = true;
         var _loc2_:Graphics = underlay.graphics;
         _loc2_.clear();
         _loc2_.lineStyle(1,get_style().controlColor,0.6);
         _loc2_.moveTo(0,graph.y);
         _loc2_.lineTo(get_width() - startOffset,graph.y);
         _loc2_.lineTo(get_width() - startOffset,value);
         return value;
      }
      
      public function reset() : void
      {
         var _loc1_:StringMap = StringMap(_infoMap);
         _loc1_.h = {};
         _loc1_.rh = null;
         graph.graphics.clear();
         if(!_group.fixed)
         {
            _group.low = Number(Number.NaN);
            _group.hi = Number(Number.NaN);
         }
      }
      
      public function onMenuRollOver(e:TextEvent) : void
      {
         var _loc2_:String = e.text != null ? StringTools.replace(e.text,"event:","") : "";
         if(_loc2_ == "gc")
         {
            _loc2_ = "Garbage collect::Requires debugger version of flash player";
         }
         console.get_panels().tooltip(_loc2_,this);
      }
      
      public function linkHandler(e:TextEvent) : void
      {
         TextField(e.currentTarget).setSelection(0,0);
         if(e.text == "reset")
         {
            reset();
         }
         else if(e.text == "close")
         {
            if(_type == "fpsPanel")
            {
               console.set_fpsMonitor(false);
            }
            else if(_type == "memoryPanel")
            {
               console.set_memoryMonitor(false);
            }
            else
            {
               stop();
            }
            console.get_panels().removeGraph(_group);
         }
         else if(e.text == "gc")
         {
            console.gc();
         }
         e.stopPropagation();
      }
      
      public function get_group() : GraphGroup
      {
         return _group;
      }
      
      public function get group() : GraphGroup
      {
         return get_group();
      }
   }
}

