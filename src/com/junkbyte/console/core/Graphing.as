package com.junkbyte.console.core
{
   import com.junkbyte.console.Console;
   import com.junkbyte.console.vos.GraphGroup;
   import com.junkbyte.console.vos.GraphInterest;
   import flash.geom.Rectangle;
   import flash.system.System;
   import flash.utils.ByteArray;
   import flash.utils.getTimer;
   
   public class Graphing extends ConsoleCore
   {
      
      private var _groups:Array;
      
      private var _map:Object;
      
      private var _fpsGroup:GraphGroup;
      
      private var _memGroup:GraphGroup;
      
      private var _hadGraph:Boolean;
      
      private var _previousTime:Number = -1;
      
      public function Graphing(m:Console)
      {
         this._groups = [];
         this._map = {};
         super(m);
         remoter.registerCallback("fps",function(bytes:ByteArray):void
         {
            fpsMonitor = bytes.readBoolean();
         });
         remoter.registerCallback("mem",function(bytes:ByteArray):void
         {
            memoryMonitor = bytes.readBoolean();
         });
         remoter.registerCallback("removeGroup",function(bytes:ByteArray):void
         {
            removeGroup(bytes.readUTF());
         });
         remoter.registerCallback("graph",this.handleRemoteGraph,true);
      }
      
      public function add(n:String, obj:Object, prop:String, col:Number = -1, key:String = null, rect:Rectangle = null, inverse:Boolean = false) : void
      {
         var group:GraphGroup;
         var interests:Array;
         var interest:GraphInterest;
         var v:Number;
         var newGroup:Boolean = false;
         var i:GraphInterest = null;
         if(obj == null)
         {
            report("ERROR: Graph [" + n + "] received a null object to graph property [" + prop + "].",10);
            return;
         }
         group = this._map[n];
         if(!group)
         {
            newGroup = true;
            group = new GraphGroup(n);
         }
         interests = group.interests;
         if(isNaN(col) || col < 0)
         {
            if(interests.length <= 5)
            {
               col = Number(config.style["priority" + (10 - interests.length * 2)]);
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
         for each(i in interests)
         {
            if(i.key == key)
            {
               report("Graph with key [" + key + "] already exists in [" + n + "]",10);
               return;
            }
         }
         if(rect)
         {
            group.rect = rect;
         }
         if(inverse)
         {
            group.inv = inverse;
         }
         interest = new GraphInterest(key,col);
         v = NaN;
         try
         {
            v = interest.setObject(obj,prop);
         }
         catch(e:Error)
         {
            report("Error with graph value for [" + key + "] in [" + n + "]. " + e,10);
            return;
         }
         if(isNaN(v))
         {
            report("Graph value for key [" + key + "] in [" + n + "] is not a number (NaN).",10);
         }
         else
         {
            group.interests.push(interest);
            if(newGroup)
            {
               this._map[n] = group;
               this._groups.push(group);
            }
         }
      }
      
      public function fixRange(n:String, low:Number = NaN, high:Number = NaN) : void
      {
         var _loc4_:GraphGroup = this._map[n];
         if(!_loc4_)
         {
            return;
         }
         _loc4_.low = low;
         _loc4_.hi = high;
         _loc4_.fixed = !(isNaN(low) || isNaN(high));
      }
      
      public function remove(n:String, obj:Object = null, prop:String = null) : void
      {
         var _loc4_:Array = null;
         var _loc5_:* = 0;
         var _loc6_:GraphInterest = null;
         if(obj == null && prop == null)
         {
            this.removeGroup(n);
         }
         else if(this._map[n])
         {
            _loc4_ = this._map[n].interests;
            _loc5_ = int(_loc4_.length - 1);
            while(_loc5_ >= 0)
            {
               _loc6_ = _loc4_[_loc5_];
               if((obj == null || _loc6_.obj == obj) && (prop == null || _loc6_.prop == prop))
               {
                  _loc4_.splice(_loc5_,1);
               }
               _loc5_--;
            }
            if(_loc4_.length == 0)
            {
               this.removeGroup(n);
            }
         }
      }
      
      private function removeGroup(n:String) : void
      {
         var _loc2_:ByteArray = null;
         var _loc3_:GraphGroup = null;
         var _loc4_:int = 0;
         if(remoter.remoting == Remoting.RECIEVER)
         {
            _loc2_ = new ByteArray();
            _loc2_.writeUTF(n);
            remoter.send("removeGroup",_loc2_);
         }
         else
         {
            _loc3_ = this._map[n];
            _loc4_ = this._groups.indexOf(_loc3_);
            if(_loc4_ >= 0)
            {
               this._groups.splice(_loc4_,1);
            }
            delete this._map[n];
         }
      }
      
      public function get fpsMonitor() : Boolean
      {
         if(remoter.remoting == Remoting.RECIEVER)
         {
            return console.panels.fpsMonitor;
         }
         return this._fpsGroup != null;
      }
      
      public function set fpsMonitor(b:Boolean) : void
      {
         var _loc2_:ByteArray = null;
         var _loc3_:int = 0;
         if(remoter.remoting == Remoting.RECIEVER)
         {
            _loc2_ = new ByteArray();
            _loc2_.writeBoolean(b);
            remoter.send("fps",_loc2_);
         }
         else if(b != this.fpsMonitor)
         {
            if(b)
            {
               this._fpsGroup = this.addSpecialGroup(GraphGroup.FPS);
               this._fpsGroup.low = 0;
               this._fpsGroup.fixed = true;
               this._fpsGroup.averaging = 30;
            }
            else
            {
               this._previousTime = -1;
               _loc3_ = this._groups.indexOf(this._fpsGroup);
               if(_loc3_ >= 0)
               {
                  this._groups.splice(_loc3_,1);
               }
               this._fpsGroup = null;
            }
            console.panels.mainPanel.updateMenu();
         }
      }
      
      public function get memoryMonitor() : Boolean
      {
         if(remoter.remoting == Remoting.RECIEVER)
         {
            return console.panels.memoryMonitor;
         }
         return this._memGroup != null;
      }
      
      public function set memoryMonitor(b:Boolean) : void
      {
         var _loc2_:ByteArray = null;
         var _loc3_:int = 0;
         if(remoter.remoting == Remoting.RECIEVER)
         {
            _loc2_ = new ByteArray();
            _loc2_.writeBoolean(b);
            remoter.send("mem",_loc2_);
         }
         else if(b != this.memoryMonitor)
         {
            if(b)
            {
               this._memGroup = this.addSpecialGroup(GraphGroup.MEM);
               this._memGroup.freq = 20;
            }
            else
            {
               _loc3_ = this._groups.indexOf(this._memGroup);
               if(_loc3_ >= 0)
               {
                  this._groups.splice(_loc3_,1);
               }
               this._memGroup = null;
            }
            console.panels.mainPanel.updateMenu();
         }
      }
      
      private function addSpecialGroup(type:int) : GraphGroup
      {
         var _loc2_:GraphGroup = new GraphGroup("special");
         _loc2_.type = type;
         this._groups.push(_loc2_);
         var _loc3_:GraphInterest = new GraphInterest("special");
         if(type == GraphGroup.FPS)
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
      
      public function update(fps:Number = 0) : Array
      {
         var _loc2_:GraphInterest = null;
         var _loc3_:Number = NaN;
         var _loc4_:GraphGroup = null;
         var _loc5_:Boolean = false;
         var _loc6_:uint = 0;
         var _loc7_:uint = 0;
         var _loc8_:Array = null;
         var _loc9_:int = 0;
         var _loc10_:Number = NaN;
         var _loc11_:uint = 0;
         var _loc12_:ByteArray = null;
         var _loc13_:uint = 0;
         for each(_loc4_ in this._groups)
         {
            _loc5_ = true;
            if(_loc4_.freq > 1)
            {
               ++_loc4_.idle;
               if(_loc4_.idle < _loc4_.freq)
               {
                  _loc5_ = false;
               }
               else
               {
                  _loc4_.idle = 0;
               }
            }
            if(_loc5_)
            {
               _loc6_ = _loc4_.type;
               _loc7_ = _loc4_.averaging;
               _loc8_ = _loc4_.interests;
               if(_loc6_ == GraphGroup.FPS)
               {
                  _loc4_.hi = fps;
                  _loc2_ = _loc8_[0];
                  _loc9_ = getTimer();
                  if(this._previousTime >= 0)
                  {
                     _loc10_ = _loc9_ - this._previousTime;
                     _loc3_ = 1000 / _loc10_;
                     _loc2_.setValue(_loc3_,_loc7_);
                  }
                  this._previousTime = _loc9_;
               }
               else if(_loc6_ == GraphGroup.MEM)
               {
                  _loc2_ = _loc8_[0];
                  _loc3_ = Math.round(System.totalMemory / 10485.76) / 100;
                  _loc4_.updateMinMax(_loc3_);
                  _loc2_.setValue(_loc3_,_loc7_);
               }
               else
               {
                  this.updateExternalGraphGroup(_loc4_);
               }
            }
         }
         if(remoter.canSend && (Boolean(this._hadGraph) || Boolean(this._groups.length)))
         {
            _loc11_ = this._groups.length;
            _loc12_ = new ByteArray();
            _loc13_ = 0;
            while(_loc13_ < _loc11_)
            {
               GraphGroup(this._groups[_loc13_]).toBytes(_loc12_);
               _loc13_++;
            }
            remoter.send("graph",_loc12_);
            this._hadGraph = this._groups.length > 0;
         }
         return this._groups;
      }
      
      private function updateExternalGraphGroup(group:GraphGroup) : void
      {
         var i:GraphInterest = null;
         var v:Number = NaN;
         for each(i in group.interests)
         {
            try
            {
               v = i.getCurrentValue();
               i.setValue(v,group.averaging);
            }
            catch(e:Error)
            {
               report("Error with graph value for key [" + i.key + "] in [" + group.name + "]. " + e,10);
               remove(group.name,i.obj,i.prop);
            }
            group.updateMinMax(v);
         }
      }
      
      private function handleRemoteGraph(bytes:ByteArray = null) : void
      {
         var _loc2_:Array = null;
         if(Boolean(bytes) && Boolean(bytes.length))
         {
            bytes.position = 0;
            _loc2_ = new Array();
            while(bytes.bytesAvailable)
            {
               _loc2_.push(GraphGroup.FromBytes(bytes));
            }
            console.panels.updateGraphs(_loc2_);
         }
         else
         {
            console.panels.updateGraphs(new Array());
         }
      }
   }
}

