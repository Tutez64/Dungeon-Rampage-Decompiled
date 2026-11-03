package com.junkbyte.console.vos
{
   import flash.Boot;
   import haxe.IMap;
   import haxe.ds.IntMap;
   import haxe.ds._IntMap.IntMapKeysIterator;
   
   public class WeakObject
   {
      
      public var _dict:IMap;
      
      public function WeakObject()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         _dict = new IntMap();
      }
      
      public function set(_tmp_n:Object, obj:*, strong:Boolean = false) : void
      {
         var _loc5_:* = null as IMap;
         var _loc6_:* = null as WeakRef;
         var _loc4_:Object = _tmp_n;
         remove(_loc4_);
         if(obj != null)
         {
            _loc5_ = _dict;
            _loc6_ = new WeakRef(obj,strong);
            _loc5_.h[int(_loc4_)] = _loc6_;
         }
      }
      
      public function remove(_tmp_n:Object) : void
      {
         var _loc2_:Object = _tmp_n;
         IntMap(_dict).remove(int(_loc2_));
      }
      
      public function keys() : Array
      {
         var _loc3_:* = null as Object;
         var _loc1_:Array = [];
         var _loc2_:* = new IntMapKeysIterator(IntMap(_dict).h);
         while(_loc2_.hasNext())
         {
            _loc3_ = _loc2_.next();
            _loc1_.push(_loc3_);
         }
         return _loc1_;
      }
      
      public function getWeakRef(_tmp_n:Object) : WeakRef
      {
         var _loc2_:Object = _tmp_n;
         return IntMap(_dict).h[int(_loc2_)];
      }
      
      public function getReferenceIndex(reference:*) : Object
      {
         var _loc3_:* = null as Object;
         var _loc4_:* = null as WeakRef;
         var _loc2_:* = new IntMapKeysIterator(IntMap(_dict).h);
         while(_loc2_.hasNext())
         {
            _loc3_ = _loc2_.next();
            _loc4_ = IntMap(_dict).h[int(_loc3_)];
            if(_loc4_.get_reference() == reference)
            {
               return _loc3_;
            }
         }
         return null;
      }
      
      public function get(_tmp_n:Object) : *
      {
         var _loc2_:Object = _tmp_n;
         var _loc3_:WeakRef = getWeakRef(_loc2_);
         if(_loc3_ != null)
         {
            return _loc3_.get_reference();
         }
         return null;
      }
      
      public function exists(_tmp_n:Object) : Boolean
      {
         var _loc2_:Object = _tmp_n;
         var _loc3_:IMap = _dict;
         if(int(_loc2_) in IntMap(_loc3_).h)
         {
            return get(_loc2_) != null;
         }
         return false;
      }
   }
}

