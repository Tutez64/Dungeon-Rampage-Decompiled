package Json
{
   public class JsonCodec
   {
      
      public function JsonCodec()
      {
      }
      
      public static function encode(value:*, pretty:Boolean = false, maxLength:int = 60) : String
      {
         return new JsonEncoder(value,pretty,maxLength).getString();
      }
      
      public static function decode(text:String) : *
      {
         return JSON.parse(text);
      }
   }
}

