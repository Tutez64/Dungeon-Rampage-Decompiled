package haxe.xml._Access
{
   import haxe.Exception;
   
   public final class HasAttribAccess_Impl_
   {
      
      public function HasAttribAccess_Impl_()
      {
      }
      
      public static function resolve(this1:Xml, name:String) : Boolean
      {
         if(this1.nodeType == Xml.Document)
         {
            throw Exception.thrown("Cannot access document attribute " + name);
         }
         return this1.exists(name);
      }
   }
}

