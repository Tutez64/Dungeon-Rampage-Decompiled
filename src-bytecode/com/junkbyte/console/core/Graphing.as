package com.junkbyte.console.core
{
   import com.junkbyte.console.Console;
   import com.junkbyte.console.ConsoleStyle;
   import com.junkbyte.console.view.MainPanel;
   import com.junkbyte.console.view.PanelsManager;
   import com.junkbyte.console.vos.GraphGroup;
   import com.junkbyte.console.vos.GraphInterest;
   import flash.Boot;
   import flash.geom.Rectangle;
   import flash.system.System;
   import flash.utils.ByteArray;
   import flash.utils.getTimer;
   import haxe.IMap;
   import haxe.ds.StringMap;
   
   public class Graphing extends ConsoleCore
   {
      
      public var _previousTime:int;
      
      public var _memGroup:GraphGroup;
      
      public var _map:IMap;
      
      public var _hadGraph:Boolean;
      
      public var _groups:Array;
      
      public var _fpsGroup:GraphGroup;
      
      public function Graphing(m:Console = undefined)
      {
         var _gthis:Graphing;
         if(!Boot.skip_constructor)
         {
            _previousTime = -1;
            _map = new StringMap();
            _groups = [];
            _gthis = this;
            super(m);
            get_remoter().registerCallback("fps",function(bytes:ByteArray):void
            {
               _gthis.set_fpsMonitor(bytes.readBoolean());
            });
            get_remoter().registerCallback("mem",function(bytes:ByteArray):void
            {
               _gthis.set_memoryMonitor(bytes.readBoolean());
            });
            get_remoter().registerCallback("removeGroup",function(bytes:ByteArray):void
            {
               _gthis.removeGroup(bytes.readUTF());
            });
            get_remoter().registerCallback("graph",handleRemoteGraph,true);
         }
      }
      
      public function updateExternalGraphGroup(group:GraphGroup) : void
      {
         var _loc5_:* = null as GraphInterest;
         var _loc6_:Number = NaN;
         var _loc7_:* = null as Error;
         var _loc3_:int = 0;
         var _loc4_:Array = group.interests;
         while(_loc3_ < int(_loc4_.length))
         {
            _loc5_ = _loc4_[_loc3_];
            _loc3_++;
            _loc6_ = 0;
            try
            {
               _loc6_ = _loc5_.getCurrentValue();
               _loc5_.setValue(_loc6_,group.averaging);
            }
            catch(_loc_e_:Error)
            {
               _loc7_ = _loc_e_;
               report("Error with graph value for key [" + _loc5_.key + "] in [" + group.name + "]. " + Std.string(_loc7_),10);
               remove(group.name,_loc5_.get_obj(),_loc5_.get_prop());
            }
            group.updateMinMax(_loc6_);
         }
      }
      
      public function update(fps:int = 0) : Array
      {
         var _loc2_:* = null as GraphInterest;
         var _loc3_:Number = NaN;
         var _loc4_:int = 0;
         var _loc6_:* = null as GraphGroup;
         var _loc7_:Boolean = false;
         var _loc8_:uint = 0;
         var _loc9_:uint = 0;
         var _loc10_:* = null as Array;
         var _loc11_:int = 0;
         var _loc12_:Number = NaN;
         var _loc13_:* = null as ByteArray;
         var _loc14_:int = 0;
         _loc4_ = 0;
         var _loc5_:Array = _groups;
         while(_loc4_ < int(_loc5_.length))
         {
            _loc6_ = _loc5_[_loc4_];
            _loc4_++;
            _loc7_ = true;
            if(_loc6_.freq > 1)
            {
               ++_loc6_.idle;
               if(_loc6_.idle < _loc6_.freq)
               {
                  _loc7_ = false;
               }
               else
               {
                  _loc6_.idle = 0;
               }
            }
            if(_loc7_)
            {
               _loc8_ = _loc6_.type;
               _loc9_ = _loc6_.averaging;
               _loc10_ = _loc6_.interests;
               if(_loc8_ == 1)
               {
                  _loc6_.hi = fps;
                  _loc2_ = _loc10_[0];
                  _loc11_ = getTimer();
                  if(_previousTime >= 0)
                  {
                     _loc12_ = _loc11_ - _previousTime;
                     _loc3_ = 1000 / _loc12_;
                     _loc2_.setValue(_loc3_,_loc9_);
                  }
                  _previousTime = _loc11_;
               }
               else if(_loc8_ == 2)
               {
                  _loc2_ = _loc10_[0];
                  _loc3_ = int(Math.round(System.totalMemory / 10485.76)) / 100;
                  _loc6_.updateMinMax(_loc3_);
                  _loc2_.setValue(_loc3_,_loc9_);
               }
               else
               {
                  updateExternalGraphGroup(_loc6_);
               }
            }
         }
         if(get_remoter().get_canSend() && (_hadGraph || int(_groups.length) != 0))
         {
            _loc8_ = uint(int(_groups.length));
            _loc13_ = new ByteArray();
            _loc4_ = 0;
            _loc11_ = int(_loc8_);
            while(_loc4_ < _loc11_)
            {
               _loc14_ = _loc4_++;
               _groups[_loc14_].toBytes(_loc13_);
            }
            get_remoter().send("graph",_loc13_);
            _hadGraph = int(_groups.length) > 0;
         }
         return _groups;
      }
      
      public function set_memoryMonitor(b:Boolean) : Boolean
      {
         var _loc2_:* = null as ByteArray;
         var _loc3_:int = 0;
         if(get_remoter().get_remoting() == 2)
         {
            _loc2_ = new ByteArray();
            _loc2_.writeBoolean(b);
            get_remoter().send("mem",_loc2_);
         }
         else if(b != get_memoryMonitor())
         {
            if(b)
            {
               _memGroup = addSpecialGroup(2);
               _memGroup.freq = 20;
            }
            else
            {
               _loc3_ = _groups.indexOf(_memGroup);
               if(_loc3_ >= 0)
               {
                  _groups.splice(_loc3_,1);
               }
               _memGroup = null;
            }
            console.get_panels().get_mainPanel().updateMenu();
         }
         return b;
      }
      
      public function set memoryMonitor(value:Boolean) : void
      {
         set_memoryMonitor(value);
      }
      
      public function set_fpsMonitor(b:Boolean) : Boolean
      {
         var _loc2_:* = null as ByteArray;
         var _loc3_:int = 0;
         if(get_remoter().get_remoting() == 2)
         {
            _loc2_ = new ByteArray();
            _loc2_.writeBoolean(b);
            get_remoter().send("fps",_loc2_);
         }
         else if(b != get_fpsMonitor())
         {
            if(b)
            {
               _fpsGroup = addSpecialGroup(1);
               _fpsGroup.low = 0;
               _fpsGroup.fixed = true;
               _fpsGroup.averaging = 30;
            }
            else
            {
               _previousTime = -1;
               _loc3_ = _groups.indexOf(_fpsGroup);
               if(_loc3_ >= 0)
               {
                  _groups.splice(_loc3_,1);
               }
               _fpsGroup = null;
            }
            console.get_panels().get_mainPanel().updateMenu();
         }
         return b;
      }
      
      public function set fpsMonitor(value:Boolean) : void
      {
         set_fpsMonitor(value);
      }
      
      public function removeGroup(n:String) : void
      {
         var _loc2_:* = null as ByteArray;
         var _loc3_:* = null as StringMap;
         var _loc4_:* = null as GraphGroup;
         var _loc5_:int = 0;
         if(get_remoter().get_remoting() == 2)
         {
            _loc2_ = new ByteArray();
            _loc2_.writeUTF(n);
            get_remoter().send("removeGroup",_loc2_);
         }
         else
         {
            _loc3_ = StringMap(_map);
            _loc4_ = n in StringMap.reserved ? GraphGroup(_loc3_.getReserved(n)) : _loc3_.h[n];
            _loc5_ = _groups.indexOf(_loc4_);
            if(_loc5_ >= 0)
            {
               _groups.splice(_loc5_,1);
            }
            StringMap(_map).remove(n);
         }
      }
      
      public function remove(n:String, obj:* = undefined, prop:String = undefined) : void
      {
         var _loc4_:* = null as StringMap;
         var _loc5_:* = null as StringMap;
         var _loc6_:* = null as Array;
         var _loc7_:* = 0;
         var _loc8_:* = null as GraphInterest;
         if(obj == null && prop == null)
         {
            removeGroup(n);
         }
         else
         {
            _loc4_ = StringMap(_map);
            if((n in StringMap.reserved ? GraphGroup(_loc4_.getReserved(n)) : _loc4_.h[n]) != null)
            {
               _loc5_ = StringMap(_map);
               _loc6_ = (n in StringMap.reserved ? GraphGroup(_loc5_.getReserved(n)) : _loc5_.h[n]).interests;
               _loc7_ = int(_loc6_.length) - 1;
               while(_loc7_ >= 0)
               {
                  _loc8_ = _loc6_[_loc7_];
                  if((obj == null || _loc8_.get_obj() == obj) && (prop == null || _loc8_.get_prop() == prop))
                  {
                     _loc6_.splice(_loc7_,1);
                  }
                  _loc7_--;
               }
               if(int(_loc6_.length) == 0)
               {
                  removeGroup(n);
               }
            }
         }
      }
      
      public function handleRemoteGraph(bytes:ByteArray = undefined) : void
      {
         var _loc2_:* = null as Array;
         if(bytes != null && bytes.length != 0)
         {
            bytes.position = 0;
            _loc2_ = [];
            while(bytes.bytesAvailable != 0)
            {
               _loc2_.push(GraphGroup.FromBytes(bytes));
            }
            console.get_panels().updateGraphs(_loc2_);
         }
         else
         {
            console.get_panels().updateGraphs([]);
         }
      }
      
      public function get_memoryMonitor() : Boolean
      {
         if(get_remoter().get_remoting() == 2)
         {
            return console.get_panels().get_memoryMonitor();
         }
         return _memGroup != null;
      }
      
      public function get memoryMonitor() : Boolean
      {
         return get_memoryMonitor();
      }
      
      public function get_fpsMonitor() : Boolean
      {
         if(get_remoter().get_remoting() == 2)
         {
            return console.get_panels().get_fpsMonitor();
         }
         return _fpsGroup != null;
      }
      
      public function get fpsMonitor() : Boolean
      {
         return get_fpsMonitor();
      }
      
      public function fixRange(n:String, low:Object = undefined, high:Object = undefined) : void
      {
         var _loc6_:Boolean = false;
         var _loc8_:Number = NaN;
         if(low == null)
         {
            low = Number(Number.NaN);
         }
         if(high == null)
         {
            high = Number(Number.NaN);
         }
         var _loc4_:StringMap = StringMap(_map);
         var _loc5_:GraphGroup = n in StringMap.reserved ? GraphGroup(_loc4_.getReserved(n)) : _loc4_.h[n];
         if(_loc5_ == null)
         {
            return;
         }
         _loc5_.low = low;
         _loc5_.hi = high;
         var _loc7_:Number = Number(low);
         if(_loc7_ == _loc7_)
         {
            _loc8_ = Number(high);
            _loc6_ = _loc8_ != _loc8_;
         }
         else
         {
            _loc6_ = true;
         }
         _loc5_.fixed = !_loc6_;
      }
      
      public function addSpecialGroup(type:int) : GraphGroup
      {
         var _loc2_:GraphGroup = new GraphGroup("special");
         _loc2_.type = type;
         _groups.push(_loc2_);
         var _loc3_:GraphInterest = new GraphInterest("special");
         if(type == 1)
         {
            _loc3_.col = 16724787;
         }
         else
         {
            _loc3_.col = 5267711;
         }
         _loc2_.interests.push(_loc3_);
         return _loc2_;
      }
      
      public function add(n:String, obj:*, prop:String, col:int = -1, key:String = undefined, rect:Rectangle = undefined, inverse:Boolean = false) : void
      {
         var _loc14_:* = null as GraphInterest;
         var _loc16_:* = null as Error;
         var _loc17_:* = null as StringMap;
         if(obj == null)
         {
            report("ERROR: Graph [" + n + "] received a null object to graph property [" + prop + "].",10);
            return;
         }
         var _loc9_:StringMap = StringMap(_map);
         var _loc10_:GraphGroup = n in StringMap.reserved ? GraphGroup(_loc9_.getReserved(n)) : _loc9_.h[n];
         var _loc11_:Boolean = false;
         if(_loc10_ == null)
         {
            _loc11_ = true;
            _loc10_ = new GraphGroup(n);
         }
         var _loc12_:Array = _loc10_.interests;
         if(col != col || col < 0)
         {
            if(int(_loc12_.length) <= 5)
            {
               col = Reflect.field(config.get_style(),"priority" + (10 - int(_loc12_.length) * 2));
            }
            else
            {
               col = Math.random() * 16777215;
            }
         }
         if(key == null)
         {
            key = prop;
         }
         var _loc13_:int = 0;
         while(_loc13_ < int(_loc12_.length))
         {
            _loc14_ = _loc12_[_loc13_];
            _loc13_++;
            if(_loc14_.key == key)
            {
               report("Graph with key [" + key + "] already exists in [" + n + "]",10);
               return;
            }
         }
         if(rect != null)
         {
            _loc10_.rect = rect;
         }
         if(inverse)
         {
            _loc10_.inv = inverse;
         }
         _loc14_ = new GraphInterest(key,col);
         var _loc15_:Number = Number(Number.NaN);
         try
         {
            _loc15_ = _loc14_.setObject(obj,prop);
         }
         catch(_loc_e_:Error)
         {
            _loc16_ = _loc_e_;
            report("Error with graph value for [" + key + "] in [" + n + "]. " + Std.string(_loc16_),10);
            return;
         }
         if(_loc15_ != _loc15_)
         {
            report("Graph value for key [" + key + "] in [" + n + "] is not a number (NaN).",10);
         }
         else
         {
            _loc10_.interests.push(_loc14_);
            if(_loc11_)
            {
               _loc17_ = StringMap(_map);
               if(n in StringMap.reserved)
               {
                  _loc17_.setReserved(n,_loc10_);
               }
               else
               {
                  _loc17_.h[n] = _loc10_;
               }
               _groups.push(_loc10_);
            }
         }
      }
   }
}

