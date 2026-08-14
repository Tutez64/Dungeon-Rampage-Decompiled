package com.junkbyte.console.vos
{
   import flash.utils.Dictionary;
   
   public class WeakRef
   {
      
      private var _val:*;
      
      private var _strong:Boolean;
      
      public function WeakRef(ref:*, strong:Boolean = false)
      {
         super();
         this._strong = strong;
         this.reference = ref;
      }
      
      public function get reference() : *
      {
         var _loc1_:* = undefined;
         if(this._strong)
         {
            return this._val;
         }
         var _loc2_:int = 0;
         var _loc3_:* = this._val;
         for(_loc1_ in _loc3_)
         {
            return _loc1_;
         }
         return null;
      }
      
      public function set reference(ref:*) : void
      {
         if(this._strong)
         {
            this._val = ref;
         }
         else
         {
            this._val = new Dictionary(true);
            this._val[ref] = null;
         }
      }
      
      public function get strong() : Boolean
      {
         return this._strong;
      }
   }
}

