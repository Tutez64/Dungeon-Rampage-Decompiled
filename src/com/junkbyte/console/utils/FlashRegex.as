package com.junkbyte.console.utils
{
   public class FlashRegex
   {
      
      public function FlashRegex()
      {
      }
      
      public static function search(text:String, regex:EReg, lastIndex:int = 0) : int
      {
         var _loc4_:Boolean = FlashRegex.match(text,regex,lastIndex);
         if(_loc4_)
         {
            return int(regex.matchedPos().pos);
         }
         return -1;
      }
      
      public static function match(text:String, regex:EReg, lastIndex:int = 0) : Boolean
      {
         if(lastIndex < 1)
         {
            return regex.match(text);
         }
         return regex.matchSub(text,lastIndex);
      }
      
      public static function replace(text:String, search:EReg, value:String) : String
      {
         return search.replace(text,value);
      }
      
      public static function split(text:String, regex:EReg) : Array
      {
         var _loc3_:* = text;
         return _loc3_.split(regex.r);
      }
      
      public static function exec(text:String, regex:EReg, lastIndex:int = 0) : RegexResult
      {
         var _loc7_:* = null;
         if(lastIndex > text.length || !FlashRegex.match(text,regex,lastIndex))
         {
            return null;
         }
         var _loc5_:RegexResult = new RegexResult();
         _loc5_.index = int(regex.matchedPos().pos);
         var _loc6_:int = 0;
         while(true)
         {
            try
            {
               _loc5_.elements.push(regex.matched(_loc6_));
            }
            catch(_loc_e_:*)
            {
               _loc7_ = _loc_e_;
               null;
               break;
            }
            _loc6_++;
         }
         return _loc5_;
      }
   }
}

