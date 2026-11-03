package com.junkbyte.console.core
{
   import com.junkbyte.console.vos.WeakObject;
   import flash.Boot;
   
   public class ExeValue
   {
      
      public var prop:String;
      
      public var obj:*;
      
      public function ExeValue(b:* = undefined, p:String = undefined)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         obj = b;
         prop = p;
      }
      
      public function setValue(v:*) : void
      {
         if(prop == null || prop == "")
         {
            obj = v;
         }
         else if(obj is WeakObject)
         {
            obj.set(prop,v);
         }
         else
         {
            obj[prop] = v;
         }
      }
      
      public function get_value() : *
      {
         if(prop == null || prop == "")
         {
            return obj;
         }
         if(obj is WeakObject)
         {
            return obj.get(prop);
         }
         return obj[prop];
      }
      
      public function get value() : *
      {
         return get_value();
      }
   }
}

