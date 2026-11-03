package GameMasterDictionary
{
   import flash.Boot;
   import flash.utils.Dictionary;
   
   public class GMMap
   {
      
      public var mKeys:Array;
      
      public var mDict:Dictionary;
      
      public function GMMap()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         mDict = new Dictionary();
         mKeys = [];
      }
      
      public function toArray() : Array
      {
         var _loc4_:* = null;
         var _loc1_:Array = [];
         var _loc2_:int = 0;
         var _loc3_:Array = mKeys;
         while(_loc2_ < int(_loc3_.length))
         {
            _loc4_ = _loc3_[_loc2_];
            _loc2_++;
            _loc1_.push(itemFor(_loc4_));
         }
         return _loc1_;
      }
      
      public function removeKey(key:*) : *
      {
         if(!hasKey(key))
         {
            return null;
         }
         var _loc2_:* = mDict[key];
         delete mDict[key];
         mKeys.remove(key);
         return _loc2_;
      }
      
      public function keysToArray() : Array
      {
         return mKeys.copy();
      }
      
      public function iterator(cursor:* = undefined) : GMMapIterator
      {
         return new GMMapIterator(this,mKeys);
      }
      
      public function itemFor(key:*) : *
      {
         return mDict[key];
      }
      
      public function hasKey(key:*) : Boolean
      {
         return key in mDict;
      }
      
      public function get_size() : uint
      {
         return int(mKeys.length);
      }
      
      public function get size() : uint
      {
         return get_size();
      }
      
      public function clear() : Boolean
      {
         if(int(mKeys.length) == 0)
         {
            return false;
         }
         mDict = new Dictionary();
         mKeys = [];
         return true;
      }
      
      public function add(key:*, item:*) : Boolean
      {
         if(hasKey(key))
         {
            return false;
         }
         mDict[key] = item;
         mKeys.push(key);
         return true;
      }
   }
}

