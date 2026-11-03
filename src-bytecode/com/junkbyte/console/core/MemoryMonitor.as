package com.junkbyte.console.core
{
   import com.junkbyte.console.Console;
   import com.junkbyte.console.compat.ConsoleLib;
   import flash.Boot;
   import flash.system.System;
   import flash.utils.getTimer;
   import haxe.IMap;
   import haxe.ds.StringMap;
   import haxe.ds.WeakMap;
   
   public class MemoryMonitor extends ConsoleCore
   {
      
      public var _objectsList:WeakMap;
      
      public var _namesList:IMap;
      
      public var _count:uint;
      
      public function MemoryMonitor(m:Console = undefined)
      {
         if(!Boot.skip_constructor)
         {
            super(m);
            _namesList = new StringMap();
            _objectsList = new WeakMap();
            console.get_remoter().registerCallback("gc",gc);
         }
      }
      
      public function watch(obj:*, n:String) : String
      {
         var _loc4_:* = null as String;
         var _loc5_:* = null as StringMap;
         var _loc3_:String = ConsoleLib.getQualifiedClassName(obj);
         if(_loc3_ == null)
         {
            _loc3_ = "Object";
         }
         if(n == null || n == "")
         {
            n = _loc3_ + "@" + getTimer();
         }
         if(_objectsList[obj] != null)
         {
            _loc4_ = _objectsList[obj];
            _loc5_ = StringMap(_namesList);
            if(_loc4_ in StringMap.reserved ? _loc5_.getReserved(_loc4_) : _loc5_.h[_loc4_])
            {
               unwatch(_objectsList[obj]);
            }
         }
         _loc5_ = StringMap(_namesList);
         if(n in StringMap.reserved ? _loc5_.getReserved(n) : _loc5_.h[n])
         {
            if(_objectsList[obj] == n)
            {
               --_count;
            }
            else
            {
               n = n + "@" + getTimer() + "_" + int(Math.floor(Math.random() * 100));
            }
         }
         var _loc6_:StringMap = StringMap(_namesList);
         if(n in StringMap.reserved)
         {
            _loc6_.setReserved(n,true);
         }
         else
         {
            _loc6_.h[n] = true;
         }
         ++_count;
         _objectsList[obj] = n;
         return n;
      }
      
      public function update() : void
      {
         var _loc4_:* = null as String;
         var _loc13_:* = null;
         var _loc14_:int = 0;
         var _loc15_:Boolean = false;
         var _loc16_:* = null as String;
         if(_count == 0)
         {
            return;
         }
         var _loc1_:Array = [];
         var _loc2_:* = {};
         var _loc3_:* = _objectsList.iterator();
         while(_loc3_.hasNext())
         {
            _loc4_ = _loc3_.next();
            _loc2_[_loc4_] = true;
         }
         var _loc5_:StringMap = StringMap(_namesList);
         _loc3_ = _loc5_.h;
         var _loc6_:* = _loc5_.rh;
         var _loc7_:int = 0;
         var _loc8_:Boolean = false;
         var _loc9_:* = _loc3_;
         var _loc10_:int = _loc7_;
         var _loc11_:Boolean = §§hasnext(_loc9_,_loc10_);
         if(!_loc11_ && _loc6_ != null)
         {
            _loc3_ = _loc6_;
            _loc9_ = _loc3_;
            _loc10_ = _loc7_ = 0;
            _loc6_ = null;
            _loc8_ = true;
            _loc11_ = §§hasnext(_loc9_,_loc10_);
         }
         var _loc12_:int = _loc10_;
         while(true)
         {
            _loc13_ = _loc3_;
            _loc14_ = _loc7_;
            _loc15_ = §§hasnext(_loc13_,_loc14_);
            if(!_loc15_ && _loc6_ != null)
            {
               _loc3_ = _loc6_;
               _loc13_ = _loc3_;
               _loc14_ = _loc7_ = 0;
               _loc6_ = null;
               _loc8_ = true;
               _loc15_ = §§hasnext(_loc13_,_loc14_);
            }
            _loc12_ = _loc14_;
            if(!_loc15_)
            {
               break;
            }
            _loc4_ = §§nextname(_loc12_,_loc3_);
            _loc7_ = _loc12_;
            if(_loc8_)
            {
               _loc4_ = _loc4_.substr(1);
            }
            _loc16_ = _loc4_;
            if(Reflect.field(_loc2_,_loc16_) == null)
            {
               _loc1_.push(_loc16_);
               StringMap(_namesList).remove(_loc16_);
               --_count;
            }
         }
         if(int(_loc1_.length) != 0)
         {
            report("<b>GARBAGE COLLECTED " + int(_loc1_.length) + " item(s): </b>" + _loc1_.join(", "),-2);
         }
      }
      
      public function unwatch(n:String) : void
      {
         var _loc3_:* = null;
         var _loc4_:* = null;
         var _loc2_:Array = [];
         _loc3_ = _objectsList.keys();
         while(_loc3_.hasNext())
         {
            _loc4_ = _loc3_.next();
            _loc2_.push(_loc4_);
         }
         var _loc5_:Array = _loc2_;
         var _loc6_:int = 0;
         while(_loc6_ < int(_loc5_.length))
         {
            _loc3_ = _loc5_[_loc6_];
            _loc6_++;
            if(_objectsList[_loc3_] == n)
            {
               _objectsList.remove(_loc3_);
            }
         }
         var _loc7_:StringMap = StringMap(_namesList);
         if(n in StringMap.reserved ? _loc7_.getReserved(n) : _loc7_.h[n])
         {
            StringMap(_namesList).remove(n);
            --_count;
         }
      }
      
      public function get_count() : uint
      {
         return _count;
      }
      
      public function get count() : uint
      {
         return get_count();
      }
      
      public function gc() : void
      {
         var _loc2_:* = null as Error;
         var _loc3_:Boolean = false;
         var _loc4_:* = null as String;
         if(get_remoter().get_remoting() == 2)
         {
            try
            {
               get_remoter().send("gc");
            }
            catch(_loc_e_:Error)
            {
               _loc2_ = _loc_e_;
               report(_loc2_,10);
            }
         }
         else
         {
            _loc3_ = false;
            try
            {
               if(Reflect.hasField(System,"gc"))
               {
                  System.gc();
                  _loc3_ = true;
               }
            }
            catch(_loc_e_:Error)
            {
               _loc2_ = _loc_e_;
            }
            _loc4_ = "Manual garbage collection " + (_loc3_ ? "successful." : "FAILED. You need debugger version of flash player.");
            report(_loc4_,_loc3_ ? -1 : 10);
         }
      }
   }
}

