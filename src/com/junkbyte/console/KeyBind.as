package com.junkbyte.console
{
   public class KeyBind
   {
      
      private var _code:Boolean;
      
      private var _key:String;
      
      public function KeyBind(v:*, shift:Boolean = false, ctrl:Boolean = false, alt:Boolean = false, onUp:Boolean = false)
      {
         super();
         this._key = String(v).toUpperCase();
         if(v is uint)
         {
            this._code = true;
         }
         else if(!v || this._key.length != 1)
         {
            throw new Error("KeyBind: character (first char) must be a single character. You gave [" + v + "]");
         }
         if(this._code)
         {
            this._key = "keycode:" + this._key;
         }
         if(shift)
         {
            this._key += "+shift";
         }
         if(ctrl)
         {
            this._key += "+ctrl";
         }
         if(alt)
         {
            this._key += "+alt";
         }
         if(onUp)
         {
            this._key += "+up";
         }
      }
      
      public function get useKeyCode() : Boolean
      {
         return this._code;
      }
      
      public function get key() : String
      {
         return this._key;
      }
   }
}

