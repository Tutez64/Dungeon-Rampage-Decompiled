package haxe.ds
{
   import flash.Boot;
   import flash.utils.Dictionary;
   import haxe.IMap;
   import haxe.ds._IntMap.IntMapKeysIterator;
   import haxe.ds._IntMap.IntMapValuesIterator;
   import haxe.iterators.MapKeyValueIterator;
   
   public class IntMap implements IMap
   {
      
      public var h:Dictionary;
      
      public function IntMap()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         h = new Dictionary();
      }
      
      public function toString() : String
      {
         var _loc8_:* = null as Dictionary;
         var _loc9_:int = 0;
         var _loc10_:Boolean = false;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:* = null as Dictionary;
         var _loc14_:int = 0;
         var _loc15_:Boolean = false;
         var _loc1_:String = "";
         _loc1_ += "[";
         var _loc2_:Dictionary = h;
         var _loc3_:int = 0;
         var _loc4_:Dictionary = _loc2_;
         var _loc5_:int = _loc3_;
         var _loc6_:Boolean = §§hasnext(_loc4_,_loc5_);
         var _loc7_:int = _loc5_;
         while(true)
         {
            _loc8_ = _loc2_;
            _loc9_ = _loc3_;
            _loc10_ = §§hasnext(_loc8_,_loc9_);
            _loc7_ = _loc9_;
            if(!_loc10_)
            {
               break;
            }
            _loc11_ = §§nextname(_loc7_,_loc2_);
            _loc3_ = _loc7_;
            _loc12_ = _loc11_;
            _loc1_ += Std.string(_loc12_);
            _loc1_ += " => ";
            _loc1_ += Std.string(Std.string(h[_loc12_]));
            _loc13_ = _loc2_;
            _loc14_ = _loc3_;
            _loc15_ = §§hasnext(_loc13_,_loc14_);
            _loc7_ = _loc14_;
            if(_loc15_)
            {
               _loc1_ += ", ";
            }
         }
         return _loc1_ + "]";
      }
      
      public function set(_tmp_key:Object, value:Object) : void
      {
         var _loc3_:int = int(_tmp_key);
         h[_loc3_] = value;
      }
      
      public function remove(_tmp_key:Object) : Boolean
      {
         var _loc2_:int = int(_tmp_key);
         if(!(_loc2_ in h))
         {
            return false;
         }
         delete h[_loc2_];
         return true;
      }
      
      public function keys() : Object
      {
         return new IntMapKeysIterator(h);
      }
      
      public function keyValueIterator() : Object
      {
         return new MapKeyValueIterator(this);
      }
      
      public function iterator() : Object
      {
         return new IntMapValuesIterator(h);
      }
      
      public function get(_tmp_key:Object) : Object
      {
         var _loc2_:int = int(_tmp_key);
         return h[_loc2_];
      }
      
      public function exists(_tmp_key:Object) : Boolean
      {
         var _loc2_:int = int(_tmp_key);
         return _loc2_ in h;
      }
      
      public function copy() : IMap
      {
         var _loc8_:* = null as Dictionary;
         var _loc9_:int = 0;
         var _loc10_:Boolean = false;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc1_:IntMap = new IntMap();
         var _loc2_:Dictionary = h;
         var _loc3_:int = 0;
         var _loc4_:Dictionary = _loc2_;
         var _loc5_:int = _loc3_;
         var _loc6_:Boolean = §§hasnext(_loc4_,_loc5_);
         var _loc7_:int = _loc5_;
         while(true)
         {
            _loc8_ = _loc2_;
            _loc9_ = _loc3_;
            _loc10_ = §§hasnext(_loc8_,_loc9_);
            _loc7_ = _loc9_;
            if(!_loc10_)
            {
               break;
            }
            _loc11_ = §§nextname(_loc7_,_loc2_);
            _loc3_ = _loc7_;
            _loc12_ = _loc11_;
            _loc1_.h[_loc12_] = h[_loc12_];
         }
         return _loc1_;
      }
      
      public function clear() : void
      {
         h = new Dictionary();
      }
   }
}

