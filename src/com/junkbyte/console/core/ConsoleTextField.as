package com.junkbyte.console.core
{
   import flash.Boot;
   import flash.text.TextField;
   
   public class ConsoleTextField extends TextField
   {
      
      public function ConsoleTextField()
      {
         if(!Boot.skip_constructor)
         {
            super();
         }
      }
   }
}

