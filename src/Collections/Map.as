package Collections
{
   import collections.StringKeyStore;
   import flash.Boot;
   import flash.utils.Dictionary;
   
   public class Map
   {
      
      public var _stringMap:StringKeyStore;
      
      public var _size:uint;
      
      public var _keys:Dictionary;
      
      public var _items:Dictionary;
      
      public function Map()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         _size = 0;
         _items = new Dictionary();
         _keys = new Dictionary();
         _stringMap = new StringKeyStore();
      }
      
      public function toArray() : Array
      {
         var _loc4_:* = null;
         var _loc7_:* = null;
         var _loc1_:Array = [];
         var _loc2_:int = 0;
         var _loc3_:Array = _stringMap.keys();
         while(_loc2_ < int(_loc3_.length))
         {
            _loc4_ = _loc3_[_loc2_];
            _loc2_++;
            _loc1_.push(_stringMap.get(_loc4_));
         }
         _loc2_ = 0;
         _loc4_ = _items;
         var _loc6_:* = 0;
         var _loc5_:Array = [];
         _loc7_ = _loc4_;
         for(_loc6_ in _loc7_)
         {
            _loc5_.push(_loc6_);
         }
         _loc3_ = _loc5_;
         while(_loc2_ < int(_loc3_.length))
         {
            _loc7_ = _loc3_[_loc2_];
            _loc2_++;
            _loc1_.push(_items[_loc7_]);
         }
         return _loc1_;
      }
      
      public function replaceFor(key:*, item:*) : Boolean
      {
         var _loc3_:* = null;
         var _loc4_:* = null;
         if(key is String)
         {
            if(!_stringMap.hasKey(key))
            {
               return false;
            }
            _loc3_ = _stringMap.get(key);
            if(typeof _loc3_ == typeof item && _loc3_ == item)
            {
               return false;
            }
            _stringMap.set(key,item);
         }
         else
         {
            _loc3_ = _keys;
            if(!(key in _loc3_))
            {
               return false;
            }
            _loc4_ = _items[key];
            if(typeof _loc4_ == typeof item && _loc4_ == item)
            {
               return false;
            }
            _items[key] = item;
         }
         return true;
      }
      
      public function removeKey(key:*) : *
      {
         var _loc2_:* = null;
         var _loc3_:* = null;
         var _loc4_:* = null;
         if(key is String)
         {
            if(!_stringMap.hasKey(key))
            {
               return undefined;
            }
            _loc2_ = _stringMap.get(key);
            _stringMap.remove(key);
         }
         else
         {
            _loc3_ = _keys;
            if(!(key in _loc3_))
            {
               return undefined;
            }
            _loc2_ = _items[key];
            _loc4_ = _keys;
            delete _loc4_[key];
            _loc4_ = _items;
            delete _loc4_[key];
         }
         _size -= 1;
         return _loc2_;
      }
      
      public function remove(item:*) : Boolean
      {
         var _loc4_:* = null;
         var _loc5_:* = null;
         var _loc8_:* = null;
         var _loc9_:* = null;
         var _loc2_:int = 0;
         var _loc3_:Array = _stringMap.keys();
         while(_loc2_ < int(_loc3_.length))
         {
            _loc4_ = _loc3_[_loc2_];
            _loc2_++;
            _loc5_ = _stringMap.get(_loc4_);
            if(typeof _loc5_ == typeof item && _loc5_ == item)
            {
               _stringMap.remove(_loc4_);
               _size -= 1;
               return true;
            }
         }
         _loc2_ = 0;
         _loc4_ = _items;
         var _loc7_:* = 0;
         var _loc6_:Array = [];
         _loc5_ = _loc4_;
         for(_loc7_ in _loc5_)
         {
            _loc6_.push(_loc7_);
         }
         _loc3_ = _loc6_;
         while(_loc2_ < int(_loc3_.length))
         {
            _loc5_ = _loc3_[_loc2_];
            _loc2_++;
            _loc8_ = _items[_loc5_];
            if(typeof _loc8_ == typeof item && _loc8_ == item)
            {
               _loc9_ = _keys;
               delete _loc9_[_loc5_];
               _loc9_ = _items;
               delete _loc9_[_loc5_];
               _size -= 1;
               return true;
            }
         }
         return false;
      }
      
      public function keysToArray() : Array
      {
         var _loc7_:* = null;
         var _loc1_:Array = _stringMap.keys();
         var _loc2_:int = 0;
         var _loc3_:* = _keys;
         var _loc6_:* = 0;
         var _loc5_:Array = [];
         _loc7_ = _loc3_;
         for(_loc6_ in _loc7_)
         {
            _loc5_.push(_loc6_);
         }
         var _loc4_:Array = _loc5_;
         while(_loc2_ < int(_loc4_.length))
         {
            _loc7_ = _loc4_[_loc2_];
            _loc2_++;
            _loc1_.push(_keys[_loc7_]);
         }
         return _loc1_;
      }
      
      public function iterator(cursor:* = undefined) : IIterator
      {
         return new MapIterator(this);
      }
      
      public function itemFor(key:*) : *
      {
         if(key is String)
         {
            return _stringMap.get(key);
         }
         return _items[key];
      }
      
      public function hasKey(key:*) : Boolean
      {
         if(key is String)
         {
            return _stringMap.hasKey(key);
         }
         var _loc2_:* = _keys;
         return key in _loc2_;
      }
      
      public function has(item:*) : Boolean
      {
         var _loc4_:* = null;
         var _loc5_:* = null;
         var _loc8_:* = null;
         var _loc2_:int = 0;
         var _loc3_:Array = _stringMap.keys();
         while(_loc2_ < int(_loc3_.length))
         {
            _loc4_ = _loc3_[_loc2_];
            _loc2_++;
            _loc5_ = _stringMap.get(_loc4_);
            if(typeof _loc5_ == typeof item && _loc5_ == item)
            {
               return true;
            }
         }
         _loc2_ = 0;
         _loc4_ = _items;
         var _loc7_:* = 0;
         var _loc6_:Array = [];
         _loc5_ = _loc4_;
         for(_loc7_ in _loc5_)
         {
            _loc6_.push(_loc7_);
         }
         _loc3_ = _loc6_;
         while(_loc2_ < int(_loc3_.length))
         {
            _loc5_ = _loc3_[_loc2_];
            _loc2_++;
            _loc8_ = _items[_loc5_];
            if(typeof _loc8_ == typeof item && _loc8_ == item)
            {
               return true;
            }
         }
         return false;
      }
      
      public function get_size() : uint
      {
         return _size;
      }
      
      public function get size() : uint
      {
         return get_size();
      }
      
      public function clear() : Boolean
      {
         if(_size == 0)
         {
            return false;
         }
         _keys = new Dictionary();
         _items = new Dictionary();
         _stringMap.clear();
         _size = 0;
         return true;
      }
      
      public function add(key:*, item:*) : Boolean
      {
         var _loc3_:* = null;
         if(key is String)
         {
            if(_stringMap.hasKey(key))
            {
               return false;
            }
            _stringMap.set(key,item);
         }
         else
         {
            _loc3_ = _keys;
            if(key in _loc3_)
            {
               return false;
            }
            _keys[key] = key;
            _items[key] = item;
         }
         _size += 1;
         return true;
      }
   }
}

