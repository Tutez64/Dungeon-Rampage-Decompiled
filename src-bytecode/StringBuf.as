package
{
   import flash.Boot;
   
   public class StringBuf
   {
      
      public var b:String;
      
      public function StringBuf()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         b = "";
      }
      
      public function toString() : String
      {
         return b;
      }
      
      public function get_length() : int
      {
         return b.length;
      }
      
      public function addSub(s:String, pos:int, len:Object = undefined) : void
      {
         b += len == null ? s.substr(pos) : s.substr(pos,len);
      }
      
      public function addChar(c:int) : void
      {
         b += c < 65536 ? String["fromCharCode"](c) : Boot.fromCodePoint(c);
      }
      
      public function add(x:Object) : void
      {
         b += Std.string(x);
      }
   }
}

