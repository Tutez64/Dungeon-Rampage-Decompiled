package com.junkbyte.console.core
{
   import com.junkbyte.console.Console;
   import com.junkbyte.console.vos.Log;
   import flash.events.Event;
   import flash.utils.ByteArray;
   
   public class Logs extends ConsoleCore
   {
      
      private var _channels:Object;
      
      private var _repeating:uint;
      
      private var _lastRepeat:Log;
      
      private var _newRepeat:Log;
      
      private var _hasNewLog:Boolean;
      
      private var _timer:uint;
      
      public var first:Log;
      
      public var last:Log;
      
      private var _length:uint;
      
      private var _lines:uint;
      
      public function Logs(console:Console)
      {
         super(console);
         this._channels = new Object();
         remoter.addEventListener(Event.CONNECT,this.onRemoteConnection);
         remoter.registerCallback("log",function(bytes:ByteArray):void
         {
            registerLog(Log.FromBytes(bytes));
         });
      }
      
      private function onRemoteConnection(e:Event) : void
      {
         var _loc2_:Log = this.first;
         while(_loc2_)
         {
            this.send2Remote(_loc2_);
            _loc2_ = _loc2_.next;
         }
      }
      
      private function send2Remote(line:Log) : void
      {
         var _loc2_:ByteArray = null;
         if(remoter.canSend)
         {
            _loc2_ = new ByteArray();
            line.toBytes(_loc2_);
            remoter.send("log",_loc2_);
         }
      }
      
      public function update(time:uint) : Boolean
      {
         this._timer = time;
         if(this._repeating > 0)
         {
            --this._repeating;
         }
         if(this._newRepeat)
         {
            if(this._lastRepeat)
            {
               this.remove(this._lastRepeat);
            }
            this._lastRepeat = this._newRepeat;
            this._newRepeat = null;
            this.push(this._lastRepeat);
         }
         var _loc2_:Boolean = this._hasNewLog;
         this._hasNewLog = false;
         return _loc2_;
      }
      
      public function add(line:Log) : void
      {
         ++this._lines;
         line.line = this._lines;
         line.time = this._timer;
         this.registerLog(line);
      }
      
      private function registerLog(line:Log) : void
      {
         this._hasNewLog = true;
         this.addChannel(line.ch);
         line.lineStr = line.line + " ";
         line.chStr = "[<a href=\"event:channel_" + line.ch + "\">" + line.ch + "</a>] ";
         line.timeStr = config.timeStampFormatter(line.time) + " ";
         this.send2Remote(line);
         if(line.repeat)
         {
            if(this._repeating > 0 && Boolean(this._lastRepeat))
            {
               line.line = this._lastRepeat.line;
               this._newRepeat = line;
               return;
            }
            this._repeating = config.maxRepeats;
            this._lastRepeat = line;
         }
         this.push(line);
         while(this._length > config.maxLines && config.maxLines > 0)
         {
            this.remove(this.first);
         }
         if(config.tracing && config.traceCall != null)
         {
            config.traceCall(line.ch,line.plainText(),line.priority);
         }
      }
      
      public function clear(channel:String = null) : void
      {
         var _loc2_:Log = null;
         if(channel)
         {
            _loc2_ = this.first;
            while(_loc2_)
            {
               if(_loc2_.ch == channel)
               {
                  this.remove(_loc2_);
               }
               _loc2_ = _loc2_.next;
            }
            delete this._channels[channel];
         }
         else
         {
            this.first = null;
            this.last = null;
            this._length = 0;
            this._channels = new Object();
         }
      }
      
      public function getLogsAsString(splitter:String, incChNames:Boolean = true, filter:Function = null) : String
      {
         var _loc4_:String = "";
         var _loc5_:Log = this.first;
         while(_loc5_)
         {
            if(filter == null || Boolean(filter(_loc5_)))
            {
               if(this.first != _loc5_)
               {
                  _loc4_ += splitter;
               }
               _loc4_ += incChNames ? _loc5_.toString() : _loc5_.plainText();
            }
            _loc5_ = _loc5_.next;
         }
         return _loc4_;
      }
      
      public function getChannels() : Array
      {
         var _loc3_:String = null;
         var _loc1_:Array = new Array(Console.GLOBAL_CHANNEL);
         this.addIfexist(Console.DEFAULT_CHANNEL,_loc1_);
         this.addIfexist(Console.FILTER_CHANNEL,_loc1_);
         this.addIfexist(LogReferences.INSPECTING_CHANNEL,_loc1_);
         this.addIfexist(Console.CONSOLE_CHANNEL,_loc1_);
         var _loc2_:Array = new Array();
         for(_loc3_ in this._channels)
         {
            if(_loc1_.indexOf(_loc3_) < 0)
            {
               _loc2_.push(_loc3_);
            }
         }
         return _loc1_.concat(_loc2_.sort(Array.CASEINSENSITIVE));
      }
      
      private function addIfexist(n:String, arr:Array) : void
      {
         if(this._channels.hasOwnProperty(n))
         {
            arr.push(n);
         }
      }
      
      public function cleanChannels() : void
      {
         this._channels = new Object();
         var _loc1_:Log = this.first;
         while(_loc1_)
         {
            this.addChannel(_loc1_.ch);
            _loc1_ = _loc1_.next;
         }
      }
      
      public function addChannel(n:String) : void
      {
         this._channels[n] = null;
      }
      
      private function push(v:Log) : void
      {
         if(this.last == null)
         {
            this.first = v;
         }
         else
         {
            this.last.next = v;
            v.prev = this.last;
         }
         this.last = v;
         ++this._length;
      }
      
      private function remove(log:Log) : void
      {
         if(this.first == log)
         {
            this.first = log.next;
         }
         if(this.last == log)
         {
            this.last = log.prev;
         }
         if(log == this._lastRepeat)
         {
            this._lastRepeat = null;
         }
         if(log == this._newRepeat)
         {
            this._newRepeat = null;
         }
         if(log.next != null)
         {
            log.next.prev = log.prev;
         }
         if(log.prev != null)
         {
            log.prev.next = log.next;
         }
         --this._length;
      }
   }
}

