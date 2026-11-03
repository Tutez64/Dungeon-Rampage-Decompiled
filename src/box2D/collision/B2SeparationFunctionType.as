package box2D.collision
{
   import flash.Boot;
   
   public final class B2SeparationFunctionType
   {
      
      public static const __isenum:Boolean = true;
      
      public static var FACE_A:B2SeparationFunctionType = new B2SeparationFunctionType("FACE_A",1,null);
      
      public static var FACE_B:B2SeparationFunctionType = new B2SeparationFunctionType("FACE_B",2,null);
      
      public static var POINTS:B2SeparationFunctionType = new B2SeparationFunctionType("POINTS",0,null);
      
      public static var __constructs__:Array = ["POINTS","FACE_A","FACE_B"];
      
      public var tag:String;
      
      public var index:int;
      
      public var params:Array;
      
      public const __enum__:Boolean = true;
      
      public function B2SeparationFunctionType(tag:String, index:int, params:Array)
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

