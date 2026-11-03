package com.junkbyte.console.core
{
   import flash.Boot;
   
   public class FakeFunction
   {
      
      public var run:*;
      
      public var line:String;
      
      public function FakeFunction(r:* = undefined, l:String = undefined)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         run = r;
         line = l;
      }
      
      public function exec(... rest) : *
      {
         return run(line,rest);
      }
   }
}

