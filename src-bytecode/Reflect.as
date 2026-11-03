package
{
   public class Reflect
   {
      
      public function Reflect()
      {
      }
      
      public static function hasField(o:*, field:String) : Boolean
      {
         return o.hasOwnProperty(field);
      }
      
      public static function field(o:*, field:String) : *
      {
         if(o != null && field in o)
         {
            return o[field];
         }
         return null;
      }
      
      public static function setField(o:*, field:String, value:*) : void
      {
         o[field] = value;
      }
      
      public static function getProperty(o:*, field:String) : *
      {
         if(o == null)
         {
            return null;
         }
         var _loc3_:String = "get_" + field;
         if(_loc3_ in o)
         {
            return o[_loc3_]();
         }
         if(field in o)
         {
            return o[field];
         }
         return null;
      }
      
      public static function setProperty(o:*, field:String, value:*) : void
      {
         var _loc4_:String = "set_" + field;
         if(_loc4_ in o)
         {
            o[_loc4_](value);
         }
         else
         {
            o[field] = value;
         }
      }
      
      public static function callMethod(o:*, func:*, args:Array) : *
      {
         return func.apply(o,args);
      }
      
      public static function fields(o:*) : Array
      {
         var _loc4_:* = null as String;
         if(o == null)
         {
            return [];
         }
         var _loc3_:Array = [];
         for(_loc4_ in o)
         {
            if(o.hasOwnProperty(_loc4_))
            {
               _loc3_.push(_loc4_);
            }
         }
         return _loc3_;
      }
      
      public static function isFunction(f:*) : Boolean
      {
         return typeof f == "function";
      }
      
      public static function compare(a:Object, b:Object) : int
      {
         var _loc3_:* = a;
         var _loc4_:* = b;
         if(_loc3_ == _loc4_)
         {
            return 0;
         }
         if(_loc3_ > _loc4_)
         {
            return 1;
         }
         return -1;
      }
      
      public static function compareMethods(f1:*, f2:*) : Boolean
      {
         return f1 == f2;
      }
      
      public static function isObject(v:*) : Boolean
      {
         if(v == null)
         {
            return false;
         }
         var _loc2_:String = typeof v;
         if(_loc2_ == "object")
         {
            return !Reflect.isEnumValue(v);
         }
         return _loc2_ == "string";
      }
      
      public static function isEnumValue(v:*) : Boolean
      {
         var _loc3_:* = null;
         try
         {
            return v.__enum__ == true;
         }
         catch(_loc_e_:*)
         {
            _loc3_ = _loc_e_;
            null;
            return false;
         }
      }
      
      public static function deleteField(o:*, field:String) : Boolean
      {
         if(o.hasOwnProperty(field) != true)
         {
            return false;
         }
         delete o[field];
         return true;
      }
      
      public static function copy(o:Object) : Object
      {
         var _loc5_:* = null as String;
         if(o == null)
         {
            return null;
         }
         var _loc2_:* = {};
         var _loc3_:int = 0;
         var _loc4_:Array = Reflect.fields(o);
         while(_loc3_ < int(_loc4_.length))
         {
            _loc5_ = _loc4_[_loc3_];
            _loc3_++;
            _loc2_[_loc5_] = Reflect.field(o,_loc5_);
         }
         return _loc2_;
      }
      
      public static function makeVarArgs(f:Function) : *
      {
         return function(... rest):*
         {
            return f(rest);
         };
      }
   }
}

