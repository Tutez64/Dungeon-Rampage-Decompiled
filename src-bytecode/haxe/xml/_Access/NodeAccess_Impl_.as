package haxe.xml._Access
{
   import _Xml.XmlType_Impl_;
   import haxe.Exception;
   
   public final class NodeAccess_Impl_
   {
      
      public function NodeAccess_Impl_()
      {
      }
      
      public static function resolve(this1:Xml, name:String) : Xml
      {
         var _loc4_:* = null as String;
         var _loc3_:Xml = this1.elementsNamed(name).next();
         if(_loc3_ == null)
         {
            if(this1.nodeType == Xml.Document)
            {
               _loc4_ = "Document";
            }
            else
            {
               if(this1.nodeType != Xml.Element)
               {
                  throw Exception.thrown("Bad node type, expected Element but found " + XmlType_Impl_.toString(this1.nodeType));
               }
               _loc4_ = this1.nodeName;
            }
            throw Exception.thrown(_loc4_ + " is missing element " + name);
         }
         if(_loc3_.nodeType != Xml.Document && _loc3_.nodeType != Xml.Element)
         {
            throw Exception.thrown("Invalid nodeType " + XmlType_Impl_.toString(_loc3_.nodeType));
         }
         return _loc3_;
      }
   }
}

