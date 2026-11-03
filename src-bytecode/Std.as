package
{
   import flash.Boot;
   
   public class Std
   {
      
      public function Std()
      {
      }
      
      public static function §is§(v:*, t:*) : Boolean
      {
         return Std.isOfType(v,t);
      }
      
      public static function isOfType(v:*, t:*) : Boolean
      {
         return Boot.__instanceof(v,t);
      }
      
      public static function downcast(value:Object, c:Class) : Object
      {
         return value as c;
      }
      
      public static function instance(value:Object, c:Class) : Object
      {
         return value as c;
      }
      
      public static function string(s:*) : String
      {
         return Boot.__string_rec(s,"");
      }
      
      public static function _int(x:Number) : int
      {
         return int(x);
      }
      
      public static function parseInt(x:String) : Object
      {
         var _loc2_:Number = Number(parseInt(x));
         if(Math.isNaN(_loc2_))
         {
            return null;
         }
         return _loc2_;
      }
      
      public static function parseFloat(x:String) : Number
      {
         return parseFloat(x);
      }
      
      public static function random(x:int) : int
      {
         if(x <= 0)
         {
            return 0;
         }
         return int(Math.floor(Math.random() * x));
      }
   }
}

