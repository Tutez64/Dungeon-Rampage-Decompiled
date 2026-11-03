package haxe._CallStack
{
   import haxe.Exception;
   import haxe.NativeStackTrace;
   import haxe.StackItem;
   
   public final class CallStack_Impl_
   {
      
      public function CallStack_Impl_()
      {
      }
      
      public static function get_length(this1:Array) : int
      {
         return int(this1.length);
      }
      
      public static function callStack() : Array
      {
         return NativeStackTrace.toHaxe(NativeStackTrace.normalize(new Error().getStackTrace(),1));
      }
      
      public static function exceptionStack(fullStack:Boolean = false) : Array
      {
         var _loc2_:Array = NativeStackTrace.toHaxe(NativeStackTrace.exceptionStack());
         return fullStack ? _loc2_ : CallStack_Impl_.subtract(_loc2_,CallStack_Impl_.callStack());
      }
      
      public static function toString(stack:Array) : String
      {
         var _loc5_:* = null as StackItem;
         var _loc2_:StringBuf = new StringBuf();
         var _loc3_:int = 0;
         var _loc4_:Array = stack;
         while(_loc3_ < int(_loc4_.length))
         {
            _loc5_ = _loc4_[_loc3_];
            _loc3_++;
            _loc2_.b += "\nCalled from ";
            CallStack_Impl_.itemToString(_loc2_,_loc5_);
         }
         return _loc2_.b;
      }
      
      public static function subtract(this1:Array, stack:Array) : Array
      {
         var _loc5_:int = 0;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc3_:int = -1;
         var _loc4_:int = -1;
         while(++_loc4_ < int(this1.length))
         {
            _loc5_ = 0;
            _loc6_ = int(stack.length);
            while(_loc5_ < _loc6_)
            {
               _loc7_ = _loc5_++;
               if(CallStack_Impl_.equalItems(this1[_loc4_],stack[_loc7_]))
               {
                  if(_loc3_ < 0)
                  {
                     _loc3_ = _loc4_;
                  }
                  if(++_loc4_ >= int(this1.length))
                  {
                     break;
                  }
               }
               else
               {
                  _loc3_ = -1;
               }
            }
            if(_loc3_ >= 0)
            {
               break;
            }
         }
         if(_loc3_ >= 0)
         {
            return this1.slice(0,_loc3_);
         }
         return this1;
      }
      
      public static function copy(this1:Array) : Array
      {
         return this1.copy();
      }
      
      public static function get(this1:Array, index:int) : StackItem
      {
         return this1[index];
      }
      
      public static function asArray(this1:Array) : Array
      {
         return this1;
      }
      
      public static function equalItems(item1:StackItem, item2:StackItem) : Boolean
      {
         var _loc3_:* = null as String;
         var _loc4_:* = null as String;
         var _loc5_:* = null as StackItem;
         var _loc6_:int = 0;
         var _loc7_:* = null as Object;
         var _loc8_:* = null as Object;
         var _loc9_:int = 0;
         var _loc10_:* = null as StackItem;
         var _loc11_:* = null as String;
         var _loc12_:* = null as String;
         if(item1 == null)
         {
            if(item2 == null)
            {
               return true;
            }
            return false;
         }
         switch(item1.index)
         {
            case 0:
               if(item2 == null)
               {
                  return false;
               }
               if(item2.index == 0)
               {
                  return true;
               }
               return false;
               break;
            case 1:
               if(item2 == null)
               {
                  return false;
               }
               if(item2.index == 1)
               {
                  _loc3_ = item2.params[0];
                  _loc4_ = item1.params[0];
                  return _loc4_ == _loc3_;
               }
               return false;
               break;
            case 2:
               if(item2 == null)
               {
                  return false;
               }
               if(item2.index == 2)
               {
                  _loc5_ = item2.params[0];
                  _loc3_ = item2.params[1];
                  _loc6_ = int(item2.params[2]);
                  _loc7_ = item2.params[3];
                  _loc8_ = item1.params[3];
                  _loc9_ = int(item1.params[2]);
                  _loc4_ = item1.params[1];
                  _loc10_ = item1.params[0];
                  if(_loc4_ == _loc3_ && _loc9_ == _loc6_ && _loc8_ == _loc7_)
                  {
                     return CallStack_Impl_.equalItems(_loc10_,_loc5_);
                  }
                  return false;
               }
               return false;
               break;
            case 3:
               if(item2 == null)
               {
                  return false;
               }
               if(item2.index == 3)
               {
                  _loc3_ = item2.params[0];
                  _loc4_ = item2.params[1];
                  _loc11_ = item1.params[1];
                  _loc12_ = item1.params[0];
                  if(_loc12_ == _loc3_)
                  {
                     return _loc11_ == _loc4_;
                  }
                  return false;
               }
               return false;
               break;
            case 4:
               if(item2 == null)
               {
                  return false;
               }
               if(item2.index == 4)
               {
                  _loc7_ = item2.params[0];
                  _loc8_ = item1.params[0];
                  return _loc8_ == _loc7_;
               }
               return false;
               break;
            default:
               return undefined;
         }
      }
      
      public static function exceptionToString(e:Exception) : String
      {
         var _loc2_:* = null as String;
         var _loc3_:* = null as Array;
         var _loc6_:* = null as String;
         if(e.get_previous() == null)
         {
            _loc2_ = "Exception: " + e.toString();
            _loc3_ = e.get_stack();
            return _loc2_ + (_loc3_ == null ? "null" : CallStack_Impl_.toString(_loc3_));
         }
         _loc2_ = "";
         var _loc4_:Exception = e;
         var _loc5_:Exception = null;
         while(_loc4_ != null)
         {
            if(_loc5_ == null)
            {
               _loc6_ = "Exception: " + _loc4_.get_message();
               _loc3_ = _loc4_.get_stack();
               _loc2_ = _loc6_ + (_loc3_ == null ? "null" : CallStack_Impl_.toString(_loc3_)) + _loc2_;
            }
            else
            {
               _loc3_ = CallStack_Impl_.subtract(_loc4_.get_stack(),_loc5_.get_stack());
               _loc2_ = "Exception: " + _loc4_.get_message() + (_loc3_ == null ? "null" : CallStack_Impl_.toString(_loc3_)) + "\n\nNext " + _loc2_;
            }
            _loc5_ = _loc4_;
            _loc4_ = _loc4_.get_previous();
         }
         return _loc2_;
      }
      
      public static function itemToString(b:StringBuf, s:StackItem) : void
      {
         var _loc3_:* = null as String;
         var _loc4_:* = null as StackItem;
         var _loc5_:int = 0;
         var _loc6_:* = null as Object;
         var _loc7_:* = null as String;
         switch(s.index)
         {
            case 0:
               b.b += "a C function";
               break;
            case 1:
               _loc3_ = s.params[0];
               b.b += "module ";
               b.b += Std.string(_loc3_);
               break;
            case 2:
               _loc4_ = s.params[0];
               _loc3_ = s.params[1];
               _loc5_ = int(s.params[2]);
               _loc6_ = s.params[3];
               if(_loc4_ != null)
               {
                  CallStack_Impl_.itemToString(b,_loc4_);
                  b.b += " (";
               }
               b.b += Std.string(_loc3_);
               b.b += " line ";
               b.b += Std.string(_loc5_);
               if(_loc6_ != null)
               {
                  b.b += " column ";
                  b.b += Std.string(_loc6_);
               }
               if(_loc4_ != null)
               {
                  b.b += ")";
               }
               break;
            case 3:
               _loc3_ = s.params[0];
               _loc7_ = s.params[1];
               b.b += Std.string(_loc3_ == null ? "<unknown>" : _loc3_);
               b.b += ".";
               b.b += Std.string(_loc7_);
               break;
            case 4:
               _loc6_ = s.params[0];
               b.b += "local function #";
               b.b += Std.string(_loc6_);
         }
      }
   }
}

