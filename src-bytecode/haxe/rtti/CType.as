package haxe.rtti
{
   import flash.Boot;
   
   public final class CType
   {
      
      public static const __isenum:Boolean = true;
      
      public static var CUnknown:CType = new CType("CUnknown",0,null);
      
      public static var __constructs__:Array = ["CUnknown","CEnum","CClass","CTypedef","CFunction","CAnonymous","CDynamic","CAbstract"];
      
      public var tag:String;
      
      public var index:int;
      
      public var params:Array;
      
      public const __enum__:Boolean = true;
      
      public function CType(tag:String, index:int, params:Array)
      {
         this.tag = tag;
         this.index = index;
         this.params = params;
      }
      
      public static function CAbstract(name:String, params:Array) : CType
      {
         return new CType("CAbstract",7,[name,params]);
      }
      
      public static function CAnonymous(fields:Array) : CType
      {
         return new CType("CAnonymous",5,[fields]);
      }
      
      public static function CClass(name:String, params:Array) : CType
      {
         return new CType("CClass",2,[name,params]);
      }
      
      public static function CDynamic(t:CType = undefined) : CType
      {
         return new CType("CDynamic",6,[t]);
      }
      
      public static function CEnum(name:String, params:Array) : CType
      {
         return new CType("CEnum",1,[name,params]);
      }
      
      public static function CFunction(args:Array, ret:CType) : CType
      {
         return new CType("CFunction",4,[args,ret]);
      }
      
      public static function CTypedef(name:String, params:Array) : CType
      {
         return new CType("CTypedef",3,[name,params]);
      }
      
      final public function toString() : String
      {
         return Boot.enum_to_string(this);
      }
   }
}

