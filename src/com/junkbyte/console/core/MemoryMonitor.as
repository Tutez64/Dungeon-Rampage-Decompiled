package com.junkbyte.console.core
{
   import com.junkbyte.console.Console;
   import flash.system.System;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   import flash.utils.getTimer;
   
   public class MemoryMonitor extends ConsoleCore
   {
      
      private var _namesList:Object;
      
      private var _objectsList:Dictionary;
      
      private var _count:uint;
      
      public function MemoryMonitor(m:Console)
      {
         super(m);
         this._namesList = new Object();
         this._objectsList = new Dictionary(true);
         console.remoter.registerCallback("gc",this.gc);
      }
      
      public function watch(obj:Object, n:String) : String
      {
         var _loc3_:String = getQualifiedClassName(obj);
         if(!n)
         {
            n = _loc3_ + "@" + getTimer();
         }
         if(this._objectsList[obj])
         {
            if(this._namesList[this._objectsList[obj]])
            {
               this.unwatch(this._objectsList[obj]);
            }
         }
         if(this._namesList[n])
         {
            if(this._objectsList[obj] == n)
            {
               --this._count;
            }
            else
            {
               n = n + "@" + getTimer() + "_" + Math.floor(Math.random() * 100);
            }
         }
         this._namesList[n] = true;
         ++this._count;
         this._objectsList[obj] = n;
         return n;
      }
      
      public function unwatch(n:String) : void
      {
         var _loc2_:Object = null;
         for(_loc2_ in this._objectsList)
         {
            if(this._objectsList[_loc2_] == n)
            {
               delete this._objectsList[_loc2_];
            }
         }
         if(this._namesList[n])
         {
            delete this._namesList[n];
            --this._count;
         }
      }
      
      public function update() : void
      {
         var _loc3_:Object = null;
         var _loc4_:String = null;
         if(this._count == 0)
         {
            return;
         }
         var _loc1_:Array = new Array();
         var _loc2_:Object = new Object();
         for(_loc3_ in this._objectsList)
         {
            _loc2_[this._objectsList[_loc3_]] = true;
         }
         for(_loc4_ in this._namesList)
         {
            if(!_loc2_[_loc4_])
            {
               _loc1_.push(_loc4_);
               delete this._namesList[_loc4_];
               --this._count;
            }
         }
         if(_loc1_.length)
         {
            report("<b>GARBAGE COLLECTED " + _loc1_.length + " item(s): </b>" + _loc1_.join(", "),-2);
         }
      }
      
      public function get count() : uint
      {
         return this._count;
      }
      
      public function gc() : void
      {
         var ok:Boolean = false;
         var str:String = null;
         if(remoter.remoting == Remoting.RECIEVER)
         {
            try
            {
               remoter.send("gc");
            }
            catch(e:Error)
            {
               report(e,10);
            }
         }
         else
         {
            try
            {
               if(System["gc"] != null)
               {
                  System["gc"]();
                  ok = true;
               }
            }
            catch(e:Error)
            {
            }
            str = "Manual garbage collection " + (ok ? "successful." : "FAILED. You need debugger version of flash player.");
            report(str,ok ? -1 : 10);
         }
      }
   }
}

