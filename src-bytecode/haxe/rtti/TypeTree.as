package haxe.rtti
{
   import flash.Boot;
   
   public final class TypeTree
   {
      
      public static const __isenum:Boolean = true;
      
      public static var __constructs__:Array = ["TPackage","TClassdecl","TEnumdecl","TTypedecl","TAbstractdecl"];
      
      public var tag:String;
      
      public var index:int;
      
      public var params:Array;
      
      public const __enum__:Boolean = true;
      
      public function TypeTree(tag:String, index:int, params:Array)
      {
         this.tag = tag;
         this.index = index;
         this.params = params;
      }
      
      public static function TAbstractdecl(a:Object) : TypeTree
      {
         return new TypeTree("TAbstractdecl",4,[a]);
      }
      
      public static function TClassdecl(c:Object) : TypeTree
      {
         return new TypeTree("TClassdecl",1,[c]);
      }
      
      public static function TEnumdecl(e:Object) : TypeTree
      {
         return new TypeTree("TEnumdecl",2,[e]);
      }
      
      public static function TPackage(name:String, full:String, subs:Array) : TypeTree
      {
         return new TypeTree("TPackage",0,[name,full,subs]);
      }
      
      public static function TTypedecl(t:Object) : TypeTree
      {
         return new TypeTree("TTypedecl",3,[t]);
      }
      
      final public function toString() : String
      {
         return Boot.enum_to_string(this);
      }
   }
}

