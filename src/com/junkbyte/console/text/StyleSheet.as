package com.junkbyte.console.text
{
   import flash.Boot;
   import flash.text.StyleSheet;
   
   public class StyleSheet extends flash.text.StyleSheet
   {
      
      public function StyleSheet()
      {
         if(!Boot.skip_constructor)
         {
            super();
         }
      }
   }
}

