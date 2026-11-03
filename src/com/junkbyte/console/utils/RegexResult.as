package com.junkbyte.console.utils
{
   import flash.Boot;
   
   public class RegexResult
   {
      
      public var index:int;
      
      public var elements:Array;
      
      public function RegexResult()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         index = 0;
         elements = [];
      }
   }
}

