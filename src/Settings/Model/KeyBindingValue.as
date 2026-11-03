package Settings.Model
{
   import Input.KeyBindings.KeyBindings;
   
   public class KeyBindingValue
   {
      
      public static const PRIMARY:String = "primary";
      
      public static const ALTERNATE:String = "alternate";
      
      public function KeyBindingValue()
      {
         super();
      }
      
      public static function make(primary:int, alternate:int) : Object
      {
         var _loc3_:Object = {};
         _loc3_["primary"] = primary;
         _loc3_["alternate"] = alternate;
         return _loc3_;
      }
      
      public static function primary(value:Object) : int
      {
         return slot(value,"primary");
      }
      
      public static function alternate(value:Object) : int
      {
         return slot(value,"alternate");
      }
      
      public static function slot(value:Object, name:String) : int
      {
         if(value == null || !value.hasOwnProperty(name))
         {
            return 0;
         }
         var _loc3_:Number = Number(value[name]);
         return isNaN(_loc3_) ? 0 : int(_loc3_);
      }
      
      public static function withSlot(value:Object, name:String, keyCode:int) : Object
      {
         return name == "primary" ? make(keyCode,alternate(value)) : make(primary(value),keyCode);
      }
      
      public static function equals(a:Object, b:Object) : Boolean
      {
         return primary(a) == primary(b) && alternate(a) == alternate(b);
      }
      
      public static function coerce(raw:*, fallback:Object) : Object
      {
         if(raw == null || typeof raw != "object")
         {
            return fallback;
         }
         var _loc4_:int = slot(raw,"primary");
         var _loc3_:int = slot(raw,"alternate");
         return make(KeyBindings.isBindable(_loc4_) ? _loc4_ : 0,KeyBindings.isBindable(_loc3_) ? _loc3_ : 0);
      }
   }
}

