package com.junkbyte.console.compat
{
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   public class ConsoleLib
   {
      
      public function ConsoleLib()
      {
      }
      
      public static function getQualifiedClassName(value:*) : String
      {
         return flash.utils.getQualifiedClassName(value);
      }
      
      public static function getDefinitionByName(name:String) : *
      {
         return flash.utils.getDefinitionByName(name);
      }
      
      public static function isNaN(f:Number) : Boolean
      {
         return f != f;
      }
      
      public static function get_NAN() : Number
      {
         return Number(Number.NaN);
      }
      
      public static function parseInt(s:String) : Object
      {
         var _loc2_:Number = Number(parseInt(s));
         if(_loc2_ != _loc2_)
         {
            return null;
         }
         return int(_loc2_);
      }
      
      public static function now() : Date
      {
         return new Date();
      }
      
      public static function typeOf(v:*) : String
      {
         return typeof v;
      }
      
      public static function truthy(v:*) : Boolean
      {
         return Boolean(v);
      }
      
      public static function toNumber(v:*) : Number
      {
         return Number(v);
      }
      
      public static function string(v:*) : String
      {
         return String(v);
      }
      
      public static function strictEquals(a:*, b:*) : Boolean
      {
         if(ConsoleLib.typeOf(a) == ConsoleLib.typeOf(b))
         {
            return a == b;
         }
         return false;
      }
   }
}

