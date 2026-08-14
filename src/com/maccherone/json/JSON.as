package com.maccherone.json
{
   public class JSON
   {
      
      public function JSON()
      {
         super();
      }
      
      public static function decode(s:String, strict:Boolean = true) : *
      {
         return new JSONDecoder(s,strict).getValue();
      }
      
      public static function encode(o:Object, pretty:Boolean = false, maxLength:int = 60) : String
      {
         return new JSONEncoder(o,pretty,maxLength).getString();
      }
   }
}

