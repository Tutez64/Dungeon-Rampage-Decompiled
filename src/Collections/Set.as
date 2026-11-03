package Collections
{
   import collections.StringKeyStore;
   import flash.Boot;
   import flash.utils.Dictionary;
   
   public class Set
   {
      
      public var _stringItems:StringKeyStore;
      
      public var _size:uint;
      
      public var _items:Dictionary;
      
      public function Set()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         _size = 0;
         _items = new Dictionary();
         _stringItems = new StringKeyStore();
      }
      
      public function toArray() : Array
      {
         var _loc4_:* = null;
         var _loc7_:* = null;
         var _loc1_:Array = [];
         var _loc2_:int = 0;
         var _loc3_:Array = _stringItems.keys();
         while(_loc2_ < int(_loc3_.length))
         {
            _loc4_ = _loc3_[_loc2_];
            _loc2_++;
            _loc1_.push(_stringItems.get(_loc4_));
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
      
      public function remove(item:*) : Boolean
      {
         var _loc2_:* = null;
         var _loc3_:* = null;
         if(item is String)
         {
            if(!_stringItems.hasKey(item))
            {
               return false;
            }
            _stringItems.remove(item);
         }
         else
         {
            _loc2_ = _items;
            if(!(item in _loc2_))
            {
               return false;
            }
            _loc3_ = _items;
            delete _loc3_[item];
         }
         _size -= 1;
         return true;
      }
      
      public function iterator(cursor:* = undefined) : IIterator
      {
         return new SetIterator(this);
      }
      
      public function has(item:*) : Boolean
      {
         if(item is String)
         {
            return _stringItems.hasKey(item);
         }
         var _loc2_:* = _items;
         return item in _loc2_;
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
         _items = new Dictionary();
         _stringItems.clear();
         _size = 0;
         return true;
      }
      
      public function add(item:*) : Boolean
      {
         var _loc2_:* = null;
         if(item is String)
         {
            if(_stringItems.hasKey(item))
            {
               return false;
            }
            _stringItems.set(item,item);
         }
         else
         {
            _loc2_ = _items;
            if(item in _loc2_)
            {
               return false;
            }
            _items[item] = item;
         }
         _size += 1;
         return true;
      }
   }
}

