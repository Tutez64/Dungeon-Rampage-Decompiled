package GameMasterDictionary
{
   import flash.Boot;
   
   public class GMMapIterator
   {
      
      public var mMap:GMMap;
      
      public var mKeys:Array;
      
      public var mIndex:int;
      
      public function GMMapIterator(map:GMMap = undefined, keys:Array = undefined)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         mMap = map;
         mKeys = keys.copy();
         mIndex = -1;
      }
      
      public function next() : *
      {
         if(!hasNext())
         {
            mIndex = int(mKeys.length);
            return null;
         }
         ++mIndex;
         return mMap.itemFor(mKeys[mIndex]);
      }
      
      public function hasNext() : Boolean
      {
         return mIndex + 1 < int(mKeys.length);
      }
      
      public function get_key() : *
      {
         if(mIndex >= 0 && mIndex < int(mKeys.length))
         {
            return mKeys[mIndex];
         }
         return null;
      }
      
      public function get key() : *
      {
         return get_key();
      }
      
      public function get_current() : *
      {
         if(mIndex >= 0 && mIndex < int(mKeys.length))
         {
            return mMap.itemFor(mKeys[mIndex]);
         }
         return null;
      }
      
      public function get current() : *
      {
         return get_current();
      }
   }
}

