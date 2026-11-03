package
{
   import flash.Boot;
   import flash.utils.describeType;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   import flash.utils.getQualifiedSuperclassName;
   import haxe.Exception;
   
   public class Type
   {
      
      public function Type()
      {
      }
      
      public static function getClass(o:Object) : Class
      {
         var _loc2_:String = getQualifiedClassName(o);
         if(_loc2_ == "null" || _loc2_ == "Object" || _loc2_ == "int" || _loc2_ == "Number" || _loc2_ == "Boolean")
         {
            return null;
         }
         if(o.hasOwnProperty("prototype"))
         {
            return null;
         }
         var _loc3_:* = getDefinitionByName(_loc2_) as Class;
         if(_loc3_.__isenum)
         {
            return null;
         }
         return _loc3_;
      }
      
      public static function getEnum(o:Object) : Class
      {
         var _loc2_:String = getQualifiedClassName(o);
         if(_loc2_ == "null" || _loc2_.substr(0,8) == "builtin.")
         {
            return null;
         }
         if(o.hasOwnProperty("prototype"))
         {
            return null;
         }
         var _loc3_:* = getDefinitionByName(_loc2_) as Class;
         if(!Boolean(_loc3_.__isenum))
         {
            return null;
         }
         return _loc3_;
      }
      
      public static function getSuperClass(c:Class) : Class
      {
         var _loc2_:String = getQualifiedSuperclassName(c);
         if(_loc2_ == null || _loc2_ == "Object")
         {
            return null;
         }
         return getDefinitionByName(_loc2_) as Class;
      }
      
      public static function getClassName(c:Class) : String
      {
         var _loc4_:int = 0;
         if(c == null)
         {
            return null;
         }
         var _loc2_:String = getQualifiedClassName(c);
         var _loc3_:String = _loc2_;
         if(_loc3_ == "Boolean")
         {
            return "Bool";
         }
         if(_loc3_ == "Number")
         {
            return "Float";
         }
         if(_loc3_ == "int")
         {
            return "Int";
         }
         _loc4_ = _loc2_.lastIndexOf("::");
         if(_loc4_ == -1)
         {
            return _loc2_;
         }
         return _loc2_.substring(0,_loc4_) + "." + _loc2_.substring(_loc4_ + 2);
      }
      
      public static function getEnumName(e:Class) : String
      {
         return Type.getClassName(e);
      }
      
      public static function resolveClass(name:String) : Class
      {
         var _loc3_:* = null as Class;
         var _loc4_:* = null;
         var _loc5_:* = null as String;
         try
         {
            _loc3_ = getDefinitionByName(name) as Class;
            if(_loc3_.__isenum)
            {
               return null;
            }
            return _loc3_;
         }
         catch(_loc_e_:*)
         {
            _loc4_ = _loc_e_;
            null;
            _loc5_ = name;
            if(_loc5_ == "Float")
            {
               return Number;
            }
            if(_loc5_ == "Int")
            {
               return int;
            }
            return null;
         }
      }
      
      public static function resolveEnum(name:String) : Class
      {
         var _loc3_:* = null;
         var _loc4_:* = null;
         try
         {
            _loc3_ = getDefinitionByName(name);
            if(!_loc3_.__isenum)
            {
               return null;
            }
            return _loc3_;
         }
         catch(_loc_e_:*)
         {
            _loc4_ = _loc_e_;
            null;
            if(name == "Bool")
            {
               return Boolean;
            }
            return null;
         }
      }
      
      public static function createInstance(cl:Class, args:Array) : Object
      {
         switch(int(args.length))
         {
            case 0:
               return new cl();
            case 1:
               return new cl(args[0]);
            case 2:
               return new cl(args[0],args[1]);
            case 3:
               return new cl(args[0],args[1],args[2]);
            case 4:
               return new cl(args[0],args[1],args[2],args[3]);
            case 5:
               return new cl(args[0],args[1],args[2],args[3],args[4]);
            case 6:
               return new cl(args[0],args[1],args[2],args[3],args[4],args[5]);
            case 7:
               return new cl(args[0],args[1],args[2],args[3],args[4],args[5],args[6]);
            case 8:
               return new cl(args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7]);
            case 9:
               return new cl(args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7],args[8]);
            case 10:
               return new cl(args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7],args[8],args[9]);
            case 11:
               return new cl(args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7],args[8],args[9],args[10]);
            case 12:
               return new cl(args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7],args[8],args[9],args[10],args[11]);
            case 13:
               return new cl(args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7],args[8],args[9],args[10],args[11],args[12]);
            case 14:
               return new cl(args[0],args[1],args[2],args[3],args[4],args[5],args[6],args[7],args[8],args[9],args[10],args[11],args[12],args[13]);
            default:
               throw Exception.thrown("Too many arguments");
         }
      }
      
      public static function createEmptyInstance(cl:Class) : Object
      {
         var _loc3_:* = null as Object;
         var _loc4_:* = null;
         var _loc5_:* = null;
         try
         {
            Boot.skip_constructor = true;
            _loc3_ = new cl();
            Boot.skip_constructor = false;
            return _loc3_;
         }
         catch(_loc_e_:*)
         {
            null;
            _loc5_ = Exception.caught(_loc4_).unwrap();
            Boot.skip_constructor = false;
            throw Exception.thrown(_loc5_);
         }
      }
      
      public static function createEnum(e:Class, constr:String, params:Array = undefined) : Object
      {
         var _loc4_:* = e[constr];
         if(_loc4_ == null)
         {
            throw Exception.thrown("No such constructor " + constr);
         }
         if(Reflect.isFunction(_loc4_))
         {
            if(params == null)
            {
               throw Exception.thrown("Constructor " + constr + " need parameters");
            }
            return _loc4_.apply(e,params);
         }
         if(params != null && int(params.length) != 0)
         {
            throw Exception.thrown("Constructor " + constr + " does not need parameters");
         }
         return _loc4_;
      }
      
      public static function createEnumIndex(e:Class, index:int, params:Array = undefined) : Object
      {
         var _loc4_:String = e.__constructs__[index];
         if(_loc4_ == null)
         {
            throw Exception.thrown(index + " is not a valid enum constructor index");
         }
         return Type.createEnum(e,_loc4_,params);
      }
      
      public static function describe(t:*, fact:Boolean) : Array
      {
         var _loc8_:int = 0;
         var _loc3_:Array = [];
         var _loc4_:XML = describeType(t);
         if(fact)
         {
            _loc4_ = _loc4_.factory[0];
         }
         var _loc5_:XMLList = _loc4_.child("method");
         var _loc6_:int = 0;
         var _loc7_:int = _loc5_.length();
         while(_loc6_ < _loc7_)
         {
            _loc8_ = _loc6_++;
            _loc3_.push(Std.string(_loc5_[_loc8_].attribute("name")));
         }
         var _loc9_:XMLList = _loc4_.child("variable");
         _loc6_ = 0;
         _loc7_ = _loc9_.length();
         while(_loc6_ < _loc7_)
         {
            _loc8_ = _loc6_++;
            _loc3_.push(Std.string(_loc9_[_loc8_].attribute("name")));
         }
         var _loc10_:XMLList = _loc4_.child("accessor");
         _loc6_ = 0;
         _loc7_ = _loc10_.length();
         while(_loc6_ < _loc7_)
         {
            _loc8_ = _loc6_++;
            _loc3_.push(Std.string(_loc10_[_loc8_].attribute("name")));
         }
         return _loc3_;
      }
      
      public static function getInstanceFields(c:Class) : Array
      {
         return Type.describe(c,true);
      }
      
      public static function getClassFields(c:Class) : Array
      {
         var _loc2_:Array = Type.describe(c,false);
         _loc2_.remove("__construct__");
         _loc2_.remove("prototype");
         return _loc2_;
      }
      
      public static function getEnumConstructs(e:Class) : Array
      {
         var _loc2_:Array = e.__constructs__;
         return _loc2_.copy();
      }
      
      public static function §typeof§(v:*) : ValueType
      {
         var _loc5_:* = null;
         var _loc6_:* = null;
         var _loc3_:String = getQualifiedClassName(v);
         var _loc4_:String = _loc3_;
         if(_loc4_ == "Boolean")
         {
            return ValueType.TBool;
         }
         if(_loc4_ == "Function")
         {
            return ValueType.TFunction;
         }
         if(_loc4_ == "Number")
         {
            if((v < -268435456 || v >= 268435456) && int(Number(v)) == v)
            {
               return ValueType.TInt;
            }
            return ValueType.TFloat;
         }
         if(_loc4_ == "Object")
         {
            return ValueType.TObject;
         }
         if(_loc4_ == "int")
         {
            return ValueType.TInt;
         }
         if(_loc4_ == "null")
         {
            return ValueType.TNull;
         }
         if(_loc4_ == "void")
         {
            return ValueType.TNull;
         }
         _loc5_ = null;
         try
         {
            _loc5_ = getDefinitionByName(_loc3_);
            if(v.hasOwnProperty("prototype"))
            {
               return ValueType.TObject;
            }
            if(_loc5_.__isenum)
            {
               return ValueType.TEnum(_loc5_);
            }
            return ValueType.TClass(_loc5_);
         }
         catch(_loc_e_:*)
         {
            _loc6_ = _loc_e_;
            null;
            if(_loc3_ == "builtin.as$0::MethodClosure" || _loc3_.indexOf("-") != -1)
            {
               return ValueType.TFunction;
            }
            if(_loc5_ == null)
            {
               return ValueType.TFunction;
            }
            return ValueType.TClass(_loc5_);
         }
      }
      
      public static function enumEq(a:Object, b:Object) : Boolean
      {
         var _loc4_:* = null as Array;
         var _loc5_:* = null as Array;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc9_:* = null;
         if(a == b)
         {
            return true;
         }
         try
         {
            if(a.index != b.index)
            {
               return false;
            }
            _loc4_ = a.params;
            _loc5_ = b.params;
            _loc6_ = 0;
            _loc7_ = int(_loc4_.length);
            while(_loc6_ < _loc7_)
            {
               _loc8_ = _loc6_++;
               if(!Type.enumEq(_loc4_[_loc8_],_loc5_[_loc8_]))
               {
                  return false;
               }
            }
         }
         catch(_loc_e_:*)
         {
            _loc9_ = _loc_e_;
            null;
            return false;
         }
         return true;
      }
      
      public static function enumConstructor(e:Object) : String
      {
         return e.tag;
      }
      
      public static function enumParameters(e:Object) : Array
      {
         if(e.params == null)
         {
            return [];
         }
         return e.params;
      }
      
      public static function allEnums(e:Class) : Array
      {
         var _loc5_:* = null as String;
         var _loc6_:* = null as Object;
         var _loc2_:Array = [];
         var _loc3_:Array = e.__constructs__;
         var _loc4_:int = 0;
         while(_loc4_ < int(_loc3_.length))
         {
            _loc5_ = _loc3_[_loc4_];
            _loc4_++;
            _loc6_ = Reflect.field(e,_loc5_);
            if(!Reflect.isFunction(_loc6_))
            {
               _loc2_.push(_loc6_);
            }
         }
         return _loc2_;
      }
   }
}

