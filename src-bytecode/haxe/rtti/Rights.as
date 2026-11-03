package haxe.rtti
{
   import flash.Boot;
   
   public final class Rights
   {
      
      public static const __isenum:Boolean = true;
      
      public static var RDynamic:Rights = new Rights("RDynamic",4,null);
      
      public static var RInline:Rights = new Rights("RInline",5,null);
      
      public static var RMethod:Rights = new Rights("RMethod",3,null);
      
      public static var RNo:Rights = new Rights("RNo",1,null);
      
      public static var RNormal:Rights = new Rights("RNormal",0,null);
      
      public static var __constructs__:Array = ["RNormal","RNo","RCall","RMethod","RDynamic","RInline"];
      
      public var tag:String;
      
      public var index:int;
      
      public var params:Array;
      
      public const __enum__:Boolean = true;
      
      public function Rights(tag:String, index:int, params:Array)
      {
         this.tag = tag;
         this.index = index;
         this.params = params;
      }
      
      public static function RCall(m:String) : Rights
      {
         return new Rights("RCall",2,[m]);
      }
      
      final public function toString() : String
      {
         return Boot.enum_to_string(this);
      }
   }
}

