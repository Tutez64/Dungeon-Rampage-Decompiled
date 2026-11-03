package com.junkbyte.console.vos
{
   import flash.Boot;
   import haxe.ds.WeakMap;
   
   public class WeakRef
   {
      
      public var _val:*;
      
      public var _strong:Boolean;
      
      public function WeakRef(ref:* = undefined, strong:Boolean = false)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         _strong = strong;
         set_reference(ref);
      }
      
      public function set_reference(ref:*) : *
      {
         var _loc2_:* = null as WeakMap;
         if(_strong)
         {
            _val = ref;
         }
         else
         {
            _loc2_ = new WeakMap();
            _loc2_[ref] = null;
            _val = _loc2_;
         }
         return ref;
      }
      
      public function set reference(value:*) : void
      {
         set_reference(value);
      }
      
      public function get_strong() : Boolean
      {
         return _strong;
      }
      
      public function get strong() : Boolean
      {
         return get_strong();
      }
      
      public function get_reference() : *
      {
         var _loc1_:* = null as WeakMap;
         var _loc2_:* = null;
         var _loc3_:* = null;
         if(_strong)
         {
            return _val;
         }
         _loc1_ = _val;
         _loc2_ = _loc1_.keys();
         if(!_loc2_.hasNext())
         {
            return null;
         }
         return _loc2_.next();
      }
      
      public function get reference() : *
      {
         return get_reference();
      }
   }
}

