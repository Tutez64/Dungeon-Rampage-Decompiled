package com.junkbyte.console
{
   import flash.Boot;
   
   public class KeyBind
   {
      
      public var _key:String;
      
      public var _code:Boolean;
      
      public function KeyBind(v:* = undefined, shift:Boolean = false, ctrl:Boolean = false, alt:Boolean = false, onUp:Boolean = false)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         _key = Std.string(v).toUpperCase();
         if(Std.isOfType(v,int))
         {
            _code = true;
         }
         else if(v == null || _key.length != 1)
         {
            throw new Error("KeyBind: character (first char) must be a single character. You gave [" + Std.string(v) + "]");
         }
         if(_code)
         {
            _key = "keycode:" + _key;
         }
         if(shift)
         {
            _key += "+shift";
         }
         if(ctrl)
         {
            _key += "+ctrl";
         }
         if(alt)
         {
            _key += "+alt";
         }
         if(onUp)
         {
            _key += "+up";
         }
      }
      
      public function get_useKeyCode() : Boolean
      {
         return _code;
      }
      
      public function get useKeyCode() : Boolean
      {
         return get_useKeyCode();
      }
      
      public function get_key() : String
      {
         return _key;
      }
      
      public function get key() : String
      {
         return get_key();
      }
   }
}

