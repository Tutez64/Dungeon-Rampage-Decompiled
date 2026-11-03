package haxe.xml._Access
{
   import _Xml.XmlType_Impl_;
   import haxe.Exception;
   
   public final class AttribAccess_Impl_
   {
      
      public function AttribAccess_Impl_()
      {
      }
      
      public static function resolve(this1:Xml, name:String) : String
      {
         if(this1.nodeType == Xml.Document)
         {
            throw Exception.thrown("Cannot access document attribute " + name);
         }
         var _loc3_:String = this1.get(name);
         if(_loc3_ == null)
         {
            if(this1.nodeType != Xml.Element)
            {
               throw Exception.thrown("Bad node type, expected Element but found " + XmlType_Impl_.toString(this1.nodeType));
            }
            throw Exception.thrown(this1.nodeName + " is missing attribute " + name);
         }
         return _loc3_;
      }
      
      public static function _hx_set(this1:Xml, name:String, value:String) : String
      {
         if(this1.nodeType == Xml.Document)
         {
            throw Exception.thrown("Cannot access document attribute " + name);
         }
         this1.set(name,value);
         return value;
      }
   }
}

