package haxe.iterators
{
   import flash.Boot;
   
   public class StringIterator
   {
      
      public var s:String;
      
      public var offset:int;
      
      public function StringIterator(s:String = undefined)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         offset = 0;
         this.s = s;
      }
      
      public function next() : int
      {
         var _temp_2:* = s;
         var _loc1_:int;
         offset = (_loc1_ = offset) + 1;
         return int(_temp_2.charCodeAt(_loc1_));
      }
      
      public function hasNext() : Boolean
      {
         return offset < s.length;
      }
   }
}

