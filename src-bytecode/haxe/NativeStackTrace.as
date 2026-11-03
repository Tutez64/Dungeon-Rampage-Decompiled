package haxe
{
   import flash.Boot;
   
   public class NativeStackTrace
   {
      
      public function NativeStackTrace()
      {
      }
      
      public static function saveStack(e:*) : void
      {
      }
      
      public static function callStack() : String
      {
         return NativeStackTrace.normalize(new Error().getStackTrace(),1);
      }
      
      public static function exceptionStack() : String
      {
         var _loc1_:Error = Boot.lastError;
         if(_loc1_ == null)
         {
            return "";
         }
         return NativeStackTrace.normalize(_loc1_.getStackTrace());
      }
      
      public static function toHaxe(native:String, skip:int = 0) : Array
      {
         var _loc7_:* = null as String;
         var _loc8_:* = null as String;
         var _loc9_:* = null as StackItem;
         var _loc3_:Array = [];
         var _loc4_:EReg = new EReg("at ([^/]+?)\\$?(/[^\\(]+)?\\(\\)(\\[(.*?):([0-9]+)\\])?","");
         var _loc5_:EReg = new EReg("^MethodInfo-([0-9]+)$","g");
         var _loc6_:int = 0;
         while(_loc4_.match(native))
         {
            native = _loc4_.matchedRight();
            if(skip <= _loc6_++)
            {
               _loc7_ = _loc4_.matched(1).split("::").join(".");
               _loc8_ = _loc4_.matched(2);
               if(_loc8_ == null)
               {
                  if(_loc5_.match(_loc7_))
                  {
                     _loc9_ = StackItem.LocalFunction(Std.parseInt(_loc5_.matched(1)));
                  }
                  else
                  {
                     _loc9_ = StackItem.Method(_loc7_,"new");
                  }
               }
               else
               {
                  _loc9_ = StackItem.Method(_loc7_,_loc8_.substring(1));
               }
               if(_loc4_.matched(3) != null)
               {
                  _loc9_ = StackItem.FilePos(_loc9_,_loc4_.matched(4),Std.parseInt(_loc4_.matched(5)));
               }
               _loc3_.push(_loc9_);
            }
         }
         return _loc3_;
      }
      
      public static function normalize(stack:String, skipItems:int = 0) : String
      {
         var _loc3_:String = stack.substring(0,6);
         while(true)
         {
            if(_loc3_ != "Error\n")
            {
               if(_loc3_ != "Error:")
               {
                  break;
               }
            }
            skipItems++;
            break;
         }
         return NativeStackTrace.skipLines(stack,skipItems);
      }
      
      public static function skipLines(stack:String, skip:int, pos:int = 0) : String
      {
         if(skip > 0)
         {
            pos = stack.indexOf("\n",pos);
            if(pos < 0)
            {
               return "";
            }
            return NativeStackTrace.skipLines(stack,--skip,pos + 1);
         }
         return stack.substring(pos);
      }
   }
}

