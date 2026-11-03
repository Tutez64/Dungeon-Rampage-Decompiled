package haxe.xml._Access
{
   import _Xml.XmlType_Impl_;
   import haxe.Exception;
   
   public final class NodeListAccess_Impl_
   {
      
      public function NodeListAccess_Impl_()
      {
      }
      
      public static function resolve(this1:Xml, name:String) : Array
      {
         var _loc5_:* = null as Xml;
         var _loc3_:Array = [];
         var _loc4_:* = this1.elementsNamed(name);
         while(_loc4_.hasNext())
         {
            _loc5_ = _loc4_.next();
            if(_loc5_.nodeType != Xml.Document && _loc5_.nodeType != Xml.Element)
            {
               throw Exception.thrown("Invalid nodeType " + XmlType_Impl_.toString(_loc5_.nodeType));
            }
            _loc3_.push(_loc5_);
         }
         return _loc3_;
      }
   }
}

