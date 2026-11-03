package haxe.xml._Access
{
   import _Xml.XmlType_Impl_;
   import haxe.Exception;
   import haxe.xml.Printer;
   
   public final class Access_Impl_
   {
      
      public function Access_Impl_()
      {
      }
      
      public static function get_x(this1:Xml) : Xml
      {
         return this1;
      }
      
      public static function get_name(this1:Xml) : String
      {
         if(this1.nodeType == Xml.Document)
         {
            return "Document";
         }
         if(this1.nodeType != Xml.Element)
         {
            throw Exception.thrown("Bad node type, expected Element but found " + XmlType_Impl_.toString(this1.nodeType));
         }
         return this1.nodeName;
      }
      
      public static function get_node(this1:Xml) : Xml
      {
         return this1;
      }
      
      public static function get_nodes(this1:Xml) : Xml
      {
         return this1;
      }
      
      public static function get_att(this1:Xml) : Xml
      {
         return this1;
      }
      
      public static function get_has(this1:Xml) : Xml
      {
         return this1;
      }
      
      public static function get_hasNode(this1:Xml) : Xml
      {
         return this1;
      }
      
      public static function get_elements(this1:Xml) : Object
      {
         return this1.elements();
      }
      
      public static function _new(x:Xml) : Xml
      {
         if(x.nodeType != Xml.Document && x.nodeType != Xml.Element)
         {
            throw Exception.thrown("Invalid nodeType " + XmlType_Impl_.toString(x.nodeType));
         }
         return x;
      }
      
      public static function get_innerData(this1:Xml) : String
      {
         var _loc4_:* = null as String;
         var _loc6_:* = null as Xml;
         var _loc7_:Boolean = false;
         var _loc8_:* = null as Xml;
         var _loc9_:Boolean = false;
         if(this1.nodeType != Xml.Document && this1.nodeType != Xml.Element)
         {
            throw Exception.thrown("Bad node type, expected Element or Document but found " + XmlType_Impl_.toString(this1.nodeType));
         }
         var _loc2_:int = 0;
         var _loc3_:Array = this1.children;
         if(_loc2_ >= int(_loc3_.length))
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
            throw Exception.thrown(_loc4_ + " does not have data");
         }
         var _loc5_:Xml = _loc3_[_loc2_++];
         if(_loc2_ < int(_loc3_.length))
         {
            _loc6_ = _loc3_[_loc2_++];
            if(_loc5_.nodeType == Xml.PCData && _loc6_.nodeType == Xml.CData)
            {
               if(_loc5_.nodeType == Xml.Document || _loc5_.nodeType == Xml.Element)
               {
                  throw Exception.thrown("Bad node type, unexpected " + XmlType_Impl_.toString(_loc5_.nodeType));
               }
               _loc7_ = StringTools.trim(_loc5_.nodeValue) == "";
            }
            else
            {
               _loc7_ = false;
            }
            if(_loc7_)
            {
               if(_loc2_ >= int(_loc3_.length))
               {
                  if(_loc6_.nodeType == Xml.Document || _loc6_.nodeType == Xml.Element)
                  {
                     throw Exception.thrown("Bad node type, unexpected " + XmlType_Impl_.toString(_loc6_.nodeType));
                  }
                  return _loc6_.nodeValue;
               }
               _loc8_ = _loc3_[_loc2_++];
               if(_loc8_.nodeType == Xml.PCData)
               {
                  if(_loc8_.nodeType == Xml.Document || _loc8_.nodeType == Xml.Element)
                  {
                     throw Exception.thrown("Bad node type, unexpected " + XmlType_Impl_.toString(_loc8_.nodeType));
                  }
                  _loc9_ = StringTools.trim(_loc8_.nodeValue) == "";
               }
               else
               {
                  _loc9_ = false;
               }
               if(_loc9_ && _loc2_ >= int(_loc3_.length))
               {
                  if(_loc6_.nodeType == Xml.Document || _loc6_.nodeType == Xml.Element)
                  {
                     throw Exception.thrown("Bad node type, unexpected " + XmlType_Impl_.toString(_loc6_.nodeType));
                  }
                  return _loc6_.nodeValue;
               }
            }
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
            throw Exception.thrown(_loc4_ + " does not only have data");
         }
         if(_loc5_.nodeType != Xml.PCData && _loc5_.nodeType != Xml.CData)
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
            throw Exception.thrown(_loc4_ + " does not have data");
         }
         if(_loc5_.nodeType == Xml.Document || _loc5_.nodeType == Xml.Element)
         {
            throw Exception.thrown("Bad node type, unexpected " + XmlType_Impl_.toString(_loc5_.nodeType));
         }
         return _loc5_.nodeValue;
      }
      
      public static function get_innerHTML(this1:Xml) : String
      {
         var _loc5_:* = null as Xml;
         var _loc2_:String = "";
         if(this1.nodeType != Xml.Document && this1.nodeType != Xml.Element)
         {
            throw Exception.thrown("Bad node type, expected Element or Document but found " + XmlType_Impl_.toString(this1.nodeType));
         }
         var _loc3_:int = 0;
         var _loc4_:Array = this1.children;
         while(_loc3_ < int(_loc4_.length))
         {
            _loc5_ = _loc4_[_loc3_++];
            _loc2_ += Std.string(Printer.print(_loc5_));
         }
         return _loc2_;
      }
   }
}

