package box2D.collision
{
   import flash.Boot;
   
   public final class B2ManifoldType
   {
      
      public static const __isenum:Boolean = true;
      
      public static var CIRCLES:B2ManifoldType = new B2ManifoldType("CIRCLES",0,null);
      
      public static var FACE_A:B2ManifoldType = new B2ManifoldType("FACE_A",1,null);
      
      public static var FACE_B:B2ManifoldType = new B2ManifoldType("FACE_B",2,null);
      
      public static var __constructs__:Array = ["CIRCLES","FACE_A","FACE_B"];
      
      public var tag:String;
      
      public var index:int;
      
      public var params:Array;
      
      public const __enum__:Boolean = true;
      
      public function B2ManifoldType(tag:String, index:int, params:Array)
      {
         this.tag = tag;
         this.index = index;
         this.params = params;
      }
      
      final public function toString() : String
      {
         return Boot.enum_to_string(this);
      }
   }
}

