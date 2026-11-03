package haxe.ds
{
   import flash.Boot;
   import flash.utils.Dictionary;
   import haxe.IMap;
   import haxe.ds._ObjectMap.NativePropertyIterator;
   import haxe.ds._ObjectMap.NativeValueIterator;
   import haxe.iterators.MapKeyValueIterator;
   
   public dynamic class ObjectMap extends Dictionary implements IMap
   {
      
      public function ObjectMap()
      {
         if(!Boot.skip_constructor)
         {
            super(false);
         }
      }
      
      public function toString() : String
      {
         var _loc4_:* = null as Object;
         var _loc1_:String = "[";
         var _loc2_:* = keys();
         var _loc3_:* = _loc2_;
         while(_loc3_.hasNext())
         {
            _loc4_ = _loc3_.next();
            _loc1_ += (_loc1_ == "" ? "" : ",") + Std.string(_loc4_);
            _loc1_ += " => ";
            _loc1_ += Std.string(this[_loc4_]);
         }
         return _loc1_ + "]";
      }
      
      public function set(_tmp_key:Object, value:Object) : void
      {
         var _loc3_:Object = _tmp_key;
         this[_loc3_] = value;
      }
      
      public function remove(_tmp_key:Object) : Boolean
      {
         var _loc2_:Object = _tmp_key;
         var _loc3_:Boolean = this[_loc2_] != null;
         delete this[_loc2_];
         return _loc3_;
      }
      
      public function keys() : Object
      {
         var _loc1_:NativePropertyIterator = new NativePropertyIterator();
         _loc1_.collection = this;
         return _loc1_;
      }
      
      public function keyValueIterator() : Object
      {
         return new MapKeyValueIterator(this);
      }
      
      public function iterator() : Object
      {
         var _loc1_:NativeValueIterator = new NativeValueIterator();
         _loc1_.collection = this;
         return _loc1_;
      }
      
      public function get(_tmp_key:Object) : Object
      {
         var _loc2_:Object = _tmp_key;
         return this[_loc2_];
      }
      
      public function exists(_tmp_key:Object) : Boolean
      {
         var _loc2_:Object = _tmp_key;
         return this[_loc2_] != null;
      }
      
      public function copy() : IMap
      {
         var _loc3_:* = null as Object;
         var _loc1_:ObjectMap = new ObjectMap();
         var _loc2_:* = keys();
         while(_loc2_.hasNext())
         {
            _loc3_ = _loc2_.next();
            _loc1_[_loc3_] = this[_loc3_];
         }
         return _loc1_;
      }
      
      public function clear() : void
      {
         var _loc2_:* = null as Object;
         var _loc1_:* = keys();
         while(_loc1_.hasNext())
         {
            _loc2_ = _loc1_.next();
            delete this[_loc2_];
         }
      }
   }
}

