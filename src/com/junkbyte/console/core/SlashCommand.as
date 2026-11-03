package com.junkbyte.console.core
{
   import flash.Boot;
   
   public class SlashCommand
   {
      
      public var user:Boolean;
      
      public var n:String;
      
      public var f:*;
      
      public var endMarker:String;
      
      public var d:String;
      
      public var allow:Boolean;
      
      public function SlashCommand(nn:String = undefined, ff:* = undefined, dd:String = undefined, cus:Boolean = false, permit:Boolean = false, argsMarker:String = undefined)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         n = nn;
         f = ff;
         d = dd != null ? dd : "";
         user = cus;
         allow = permit;
         endMarker = argsMarker;
      }
   }
}

