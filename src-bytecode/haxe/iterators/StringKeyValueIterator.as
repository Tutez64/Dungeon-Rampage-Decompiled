package haxe.iterators
{
   import flash.Boot;
   
   public class StringKeyValueIterator
   {
      
      public var s:String;
      
      public var offset:int;
      
      public function StringKeyValueIterator(s:String = undefined)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         offset = 0;
         this.s = s;
      }
      
      public function next() : Object
      {
         var _temp_5:* = "key";
         var _temp_4:* = offset;
         var _temp_3:* = "value";
         var _temp_2:* = s;
         var _loc1_:int;
         offset = (_loc1_ = offset) + 1;
         return {
            _temp_5:_temp_4,
            _temp_3:int(_temp_2.charCodeAt(_loc1_))
         };
      }
      
      public function hasNext() : Boolean
      {
         return offset < s.length;
      }
   }
}

