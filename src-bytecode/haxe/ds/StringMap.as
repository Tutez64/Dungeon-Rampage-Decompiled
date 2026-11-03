package haxe.ds
{
   import flash.Boot;
   import haxe.IMap;
   import haxe.ds._StringMap.StringMapKeysIterator;
   import haxe.ds._StringMap.StringMapValuesIterator;
   import haxe.iterators.MapKeyValueIterator;
   
   public class StringMap implements IMap
   {
      
      public static var reserved:Object = {};
      
      public var rh:*;
      
      public var h:*;
      
      public function StringMap()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         h = {};
      }
      
      public function toString() : String
      {
         var _loc10_:* = null;
         var _loc11_:int = 0;
         var _loc12_:Boolean = false;
         var _loc13_:* = null as String;
         var _loc14_:* = null as String;
         var _loc15_:* = null;
         var _loc16_:int = 0;
         var _loc17_:Boolean = false;
         var _loc1_:String = "";
         _loc1_ += "[";
         var _loc2_:* = h;
         var _loc3_:* = rh;
         var _loc4_:int = 0;
         var _loc5_:Boolean = false;
         var _loc6_:* = _loc2_;
         var _loc7_:int = _loc4_;
         var _loc8_:Boolean = §§hasnext(_loc6_,_loc7_);
         if(!_loc8_ && _loc3_ != null)
         {
            _loc2_ = _loc3_;
            _loc6_ = _loc2_;
            _loc7_ = _loc4_ = 0;
            _loc3_ = null;
            _loc5_ = true;
            _loc8_ = §§hasnext(_loc6_,_loc7_);
         }
         var _loc9_:int = _loc7_;
         while(true)
         {
            _loc10_ = _loc2_;
            _loc11_ = _loc4_;
            _loc12_ = §§hasnext(_loc10_,_loc11_);
            if(!_loc12_ && _loc3_ != null)
            {
               _loc2_ = _loc3_;
               _loc10_ = _loc2_;
               _loc11_ = _loc4_ = 0;
               _loc3_ = null;
               _loc5_ = true;
               _loc12_ = §§hasnext(_loc10_,_loc11_);
            }
            _loc9_ = _loc11_;
            if(!_loc12_)
            {
               break;
            }
            _loc13_ = §§nextname(_loc9_,_loc2_);
            _loc4_ = _loc9_;
            if(_loc5_)
            {
               _loc13_ = _loc13_.substr(1);
            }
            _loc14_ = _loc13_;
            _loc1_ += Std.string(_loc14_);
            _loc1_ += " => ";
            _loc1_ += Std.string(Std.string(_loc14_ in StringMap.reserved ? getReserved(_loc14_) : h[_loc14_]));
            _loc15_ = _loc2_;
            _loc16_ = _loc4_;
            _loc17_ = §§hasnext(_loc15_,_loc16_);
            if(!_loc17_ && _loc3_ != null)
            {
               _loc2_ = _loc3_;
               _loc15_ = _loc2_;
               _loc16_ = _loc4_ = 0;
               _loc3_ = null;
               _loc5_ = true;
               _loc17_ = §§hasnext(_loc15_,_loc16_);
            }
            _loc9_ = _loc16_;
            if(_loc17_)
            {
               _loc1_ += ", ";
            }
         }
         return _loc1_ + "]";
      }
      
      public function setReserved(key:String, value:Object) : void
      {
         if(rh == null)
         {
            rh = {};
         }
         rh["$" + key] = value;
      }
      
      public function set(_tmp_key:Object, value:Object) : void
      {
         var _loc3_:String = _tmp_key;
         if(_loc3_ in StringMap.reserved)
         {
            setReserved(_loc3_,value);
         }
         else
         {
            h[_loc3_] = value;
         }
      }
      
      public function remove(_tmp_key:Object) : Boolean
      {
         var _loc2_:String = _tmp_key;
         if(_loc2_ in StringMap.reserved)
         {
            _loc2_ = "$" + _loc2_;
            if(rh == null || !(_loc2_ in rh))
            {
               return false;
            }
            delete rh[_loc2_];
            return true;
         }
         if(!(_loc2_ in h))
         {
            return false;
         }
         delete h[_loc2_];
         return true;
      }
      
      public function keys() : Object
      {
         return new StringMapKeysIterator(h,rh);
      }
      
      public function keyValueIterator() : Object
      {
         return new MapKeyValueIterator(this);
      }
      
      public function iterator() : Object
      {
         return new StringMapValuesIterator(h,rh);
      }
      
      public function isReserved(key:String) : Boolean
      {
         return key in StringMap.reserved;
      }
      
      public function getReserved(key:String) : Object
      {
         if(rh == null)
         {
            return null;
         }
         return rh["$" + key];
      }
      
      public function get(_tmp_key:Object) : Object
      {
         var _loc2_:String = _tmp_key;
         if(_loc2_ in StringMap.reserved)
         {
            return getReserved(_loc2_);
         }
         return h[_loc2_];
      }
      
      public function existsReserved(key:String) : Boolean
      {
         if(rh == null)
         {
            return false;
         }
         return "$" + key in rh;
      }
      
      public function exists(_tmp_key:Object) : Boolean
      {
         var _loc2_:String = _tmp_key;
         if(_loc2_ in StringMap.reserved)
         {
            return existsReserved(_loc2_);
         }
         return _loc2_ in h;
      }
      
      public function copy() : IMap
      {
         var _loc10_:* = null;
         var _loc11_:int = 0;
         var _loc12_:Boolean = false;
         var _loc13_:* = null as String;
         var _loc14_:* = null as String;
         var _loc15_:* = null as Object;
         var _loc1_:StringMap = new StringMap();
         var _loc2_:* = h;
         var _loc3_:* = rh;
         var _loc4_:int = 0;
         var _loc5_:Boolean = false;
         var _loc6_:* = _loc2_;
         var _loc7_:int = _loc4_;
         var _loc8_:Boolean = §§hasnext(_loc6_,_loc7_);
         if(!_loc8_ && _loc3_ != null)
         {
            _loc2_ = _loc3_;
            _loc6_ = _loc2_;
            _loc7_ = _loc4_ = 0;
            _loc3_ = null;
            _loc5_ = true;
            _loc8_ = §§hasnext(_loc6_,_loc7_);
         }
         var _loc9_:int = _loc7_;
         while(true)
         {
            _loc10_ = _loc2_;
            _loc11_ = _loc4_;
            _loc12_ = §§hasnext(_loc10_,_loc11_);
            if(!_loc12_ && _loc3_ != null)
            {
               _loc2_ = _loc3_;
               _loc10_ = _loc2_;
               _loc11_ = _loc4_ = 0;
               _loc3_ = null;
               _loc5_ = true;
               _loc12_ = §§hasnext(_loc10_,_loc11_);
            }
            _loc9_ = _loc11_;
            if(!_loc12_)
            {
               break;
            }
            _loc13_ = §§nextname(_loc9_,_loc2_);
            _loc4_ = _loc9_;
            if(_loc5_)
            {
               _loc13_ = _loc13_.substr(1);
            }
            _loc14_ = _loc13_;
            _loc15_ = _loc14_ in StringMap.reserved ? getReserved(_loc14_) : h[_loc14_];
            if(_loc14_ in StringMap.reserved)
            {
               _loc1_.setReserved(_loc14_,_loc15_);
            }
            else
            {
               _loc1_.h[_loc14_] = _loc15_;
            }
         }
         return _loc1_;
      }
      
      public function clear() : void
      {
         h = {};
         rh = null;
      }
   }
}

