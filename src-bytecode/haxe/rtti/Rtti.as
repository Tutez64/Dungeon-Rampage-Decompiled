package haxe.rtti
{
   import haxe.Exception;
   
   public class Rtti
   {
      
      public function Rtti()
      {
      }
      
      public static function getRtti(c:Class) : Object
      {
         var _loc5_:* = null;
         var _loc6_:* = null as TypeTree;
         var _loc2_:String = Reflect.field(c,"__rtti");
         if(_loc2_ == null)
         {
            throw Exception.thrown("Class " + Type.getClassName(c) + " has no RTTI information, consider adding @:rtti");
         }
         var _loc3_:Xml = Xml.parse(_loc2_).firstElement();
         var _loc4_:TypeTree = new XmlParser().processElement(_loc3_);
         if(_loc4_.index == 1)
         {
            return _loc4_.params[0];
         }
         _loc6_ = _loc4_;
         throw Exception.thrown("Enum mismatch: expected TClassDecl but found " + Std.string(_loc6_));
      }
      
      public static function hasRtti(c:Class) : Boolean
      {
         return Lambda.has(Type.getClassFields(c),"__rtti");
      }
   }
}

