package com.junkbyte.console.core
{
   import com.junkbyte.console.Console;
   import com.junkbyte.console.ConsoleConfig;
   import flash.Boot;
   import flash.events.EventDispatcher;
   
   public class ConsoleCore extends EventDispatcher
   {
      
      public var console:Console;
      
      public var config:ConsoleConfig;
      
      public function ConsoleCore(c:Console = undefined)
      {
         if(!Boot.skip_constructor)
         {
            super();
            console = c;
            config = console.get_config();
         }
      }
      
      public function report(obj:* = undefined, priority:int = 0, skipSafe:Boolean = true, ch:String = undefined) : void
      {
         if(obj == null)
         {
            obj = "";
         }
         console.report(obj,priority,skipSafe,ch);
      }
      
      public function get_remoter() : Remoting
      {
         return console.get_remoter();
      }
      
      public function get remoter() : Remoting
      {
         return get_remoter();
      }
   }
}

