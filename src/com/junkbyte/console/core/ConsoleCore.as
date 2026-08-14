package com.junkbyte.console.core
{
   import com.junkbyte.console.Console;
   import com.junkbyte.console.ConsoleConfig;
   import flash.events.EventDispatcher;
   
   public class ConsoleCore extends EventDispatcher
   {
      
      protected var console:Console;
      
      protected var config:ConsoleConfig;
      
      public function ConsoleCore(c:Console)
      {
         super();
         this.console = c;
         this.config = this.console.config;
      }
      
      protected function get remoter() : Remoting
      {
         return this.console.remoter;
      }
      
      protected function report(obj:* = "", priority:int = 0, skipSafe:Boolean = true, ch:String = null) : void
      {
         this.console.report(obj,priority,skipSafe,ch);
      }
   }
}

