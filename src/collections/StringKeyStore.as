package collections
{
   import flash.Boot;
   
   public class StringKeyStore
   {
      
      public static var _reserved:* = {};
      
      public var _overflow:*;
      
      public var _main:*;
      
      public function StringKeyStore()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         _main = {};
      }
      
      public function unescape(escapedKey:String) : String
      {
         return escapedKey.substr(1);
      }
      
      public function set(key:String, value:*) : void
      {
         if(isReserved(key))
         {
            if(_overflow == null)
            {
               _overflow = {};
            }
            _overflow[escape(key)] = value;
         }
         else
         {
            _main[key] = value;
         }
      }
      
      public function remove(key:String) : void
      {
         var _loc2_:* = null;
         var _loc3_:* = null;
         if(isReserved(key))
         {
            if(_overflow != null)
            {
               _loc2_ = _overflow;
               _loc3_ = escape(key);
               delete _loc2_[_loc3_];
            }
         }
         else
         {
            _loc2_ = _main;
            delete _loc2_[key];
         }
      }
      
      public function keys() : Array
      {
         var _loc3_:* = null as Array;
         var _loc4_:* = 0;
         var _loc5_:* = null;
         var _loc6_:* = null as Array;
         var _loc7_:* = 0;
         var _loc8_:* = null;
         var _loc1_:* = _main;
         _loc4_ = 0;
         _loc3_ = [];
         _loc5_ = _loc1_;
         for(_loc4_ in _loc5_)
         {
            _loc3_.push(_loc4_);
         }
         var _loc2_:Array = _loc3_;
         if(_overflow != null)
         {
            _loc4_ = 0;
            _loc5_ = _overflow;
            _loc7_ = 0;
            _loc6_ = [];
            _loc8_ = _loc5_;
            for(_loc7_ in _loc8_)
            {
               _loc6_.push(_loc7_);
            }
            _loc3_ = _loc6_;
            while(_loc4_ < int(_loc3_.length))
            {
               _loc8_ = _loc3_[_loc4_];
               _loc4_++;
               _loc2_.push(unescape(_loc8_));
            }
         }
         return _loc2_;
      }
      
      public function isReserved(key:String) : Boolean
      {
         var _loc2_:* = StringKeyStore._reserved;
         return key in _loc2_;
      }
      
      public function hasKey(key:String) : Boolean
      {
         var _loc2_:* = null;
         var _loc3_:* = null;
         if(isReserved(key))
         {
            if(_overflow != null)
            {
               _loc2_ = _overflow;
               _loc3_ = escape(key);
               return _loc3_ in _loc2_;
            }
            return false;
         }
         _loc2_ = _main;
         return key in _loc2_;
      }
      
      public function get(key:String) : *
      {
         if(isReserved(key))
         {
            if(_overflow == null)
            {
               return undefined;
            }
            return _overflow[escape(key)];
         }
         return _main[key];
      }
      
      public function escape(key:String) : String
      {
         return "$" + key;
      }
      
      public function clear() : void
      {
         _main = {};
         _overflow = null;
      }
   }
}

