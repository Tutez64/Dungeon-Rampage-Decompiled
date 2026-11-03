package haxe
{
   import flash.Boot;
   
   public final class StackItem
   {
      
      public static const __isenum:Boolean = true;
      
      public static var CFunction:StackItem = new StackItem("CFunction",0,null);
      
      public static var __constructs__:Array = ["CFunction","Module","FilePos","Method","LocalFunction"];
      
      public var tag:String;
      
      public var index:int;
      
      public var params:Array;
      
      public const __enum__:Boolean = true;
      
      public function StackItem(tag:String, index:int, params:Array)
      {
         this.tag = tag;
         this.index = index;
         this.params = params;
      }
      
      public static function FilePos(s:StackItem, file:String, line:int, column:Object = undefined) : StackItem
      {
         return new StackItem("FilePos",2,[s,file,line,column]);
      }
      
      public static function LocalFunction(v:Object = undefined) : StackItem
      {
         return new StackItem("LocalFunction",4,[v]);
      }
      
      public static function Method(classname:String, method:String) : StackItem
      {
         return new StackItem("Method",3,[classname,method]);
      }
      
      public static function Module(m:String) : StackItem
      {
         return new StackItem("Module",1,[m]);
      }
      
      final public function toString() : String
      {
         return Boot.enum_to_string(this);
      }
   }
}

