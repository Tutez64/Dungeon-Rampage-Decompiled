package haxe.xml
{
   import _Xml.XmlType_Impl_;
   import flash.Boot;
   import haxe.Exception;
   
   public class Printer
   {
      
      public var pretty:Boolean;
      
      public var output:StringBuf;
      
      public function Printer(pretty:Boolean = false)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         output = new StringBuf();
         this.pretty = pretty;
      }
      
      public static function print(xml:Xml, pretty:Object = undefined) : String
      {
         if(pretty == null)
         {
            pretty = false;
         }
         var _loc3_:Printer = new Printer(pretty);
         _loc3_.writeNode(xml,"");
         return _loc3_.output.b;
      }
      
      public function writeNode(value:Xml, tabs:String) : void
      {
         var _loc3_:* = null;
         var _loc4_:* = null as String;
         var _loc5_:* = null as String;
         var _loc6_:int = 0;
         var _loc7_:* = null as Array;
         var _loc8_:* = null as Xml;
         switch(value.nodeType)
         {
            case 0:
               output.b += Std.string(tabs + "<");
               if(value.nodeType != Xml.Element)
               {
                  throw Exception.thrown("Bad node type, expected Element but found " + XmlType_Impl_.toString(value.nodeType));
               }
               output.b += Std.string(value.nodeName);
               _loc3_ = value.attributes();
               while(_loc3_.hasNext())
               {
                  _loc4_ = _loc3_.next();
                  output.b += Std.string(" " + _loc4_ + "=\"");
                  _loc5_ = StringTools.htmlEscape(value.get(_loc4_),true);
                  output.b += Std.string(_loc5_);
                  output.b += "\"";
               }
               if(hasChildren(value))
               {
                  output.b += ">";
                  if(pretty)
                  {
                     output.b += "\n";
                  }
                  if(value.nodeType != Xml.Document && value.nodeType != Xml.Element)
                  {
                     throw Exception.thrown("Bad node type, expected Element or Document but found " + XmlType_Impl_.toString(value.nodeType));
                  }
                  _loc6_ = 0;
                  _loc7_ = value.children;
                  while(_loc6_ < int(_loc7_.length))
                  {
                     _loc8_ = _loc7_[_loc6_++];
                     writeNode(_loc8_,pretty ? tabs + "\t" : tabs);
                  }
                  output.b += Std.string(tabs + "</");
                  if(value.nodeType != Xml.Element)
                  {
                     throw Exception.thrown("Bad node type, expected Element but found " + XmlType_Impl_.toString(value.nodeType));
                  }
                  output.b += Std.string(value.nodeName);
                  output.b += ">";
                  if(pretty)
                  {
                     output.b += "\n";
                  }
               }
               else
               {
                  output.b += "/>";
                  if(pretty)
                  {
                     output.b += "\n";
                  }
               }
               break;
            case 1:
               if(value.nodeType == Xml.Document || value.nodeType == Xml.Element)
               {
                  throw Exception.thrown("Bad node type, unexpected " + XmlType_Impl_.toString(value.nodeType));
               }
               _loc4_ = value.nodeValue;
               if(_loc4_.length != 0)
               {
                  _loc5_ = tabs + StringTools.htmlEscape(_loc4_);
                  output.b += Std.string(_loc5_);
                  if(pretty)
                  {
                     output.b += "\n";
                  }
               }
               break;
            case 2:
               output.b += Std.string(tabs + "<![CDATA[");
               if(value.nodeType == Xml.Document || value.nodeType == Xml.Element)
               {
                  throw Exception.thrown("Bad node type, unexpected " + XmlType_Impl_.toString(value.nodeType));
               }
               output.b += Std.string(value.nodeValue);
               output.b += "]]>";
               if(pretty)
               {
                  output.b += "\n";
               }
               break;
            case 3:
               if(value.nodeType == Xml.Document || value.nodeType == Xml.Element)
               {
                  throw Exception.thrown("Bad node type, unexpected " + XmlType_Impl_.toString(value.nodeType));
               }
               _loc4_ = value.nodeValue;
               _loc4_ = new EReg("[\n\r\t]+","g").replace(_loc4_,"");
               _loc4_ = "<!--" + _loc4_ + "-->";
               output.b += Std.string(tabs);
               _loc5_ = StringTools.trim(_loc4_);
               output.b += Std.string(_loc5_);
               if(pretty)
               {
                  output.b += "\n";
               }
               break;
            case 4:
               if(value.nodeType == Xml.Document || value.nodeType == Xml.Element)
               {
                  throw Exception.thrown("Bad node type, unexpected " + XmlType_Impl_.toString(value.nodeType));
               }
               output.b += Std.string("<!DOCTYPE " + value.nodeValue + ">");
               if(pretty)
               {
                  output.b += "\n";
               }
               break;
            case 5:
               if(value.nodeType == Xml.Document || value.nodeType == Xml.Element)
               {
                  throw Exception.thrown("Bad node type, unexpected " + XmlType_Impl_.toString(value.nodeType));
               }
               output.b += Std.string("<?" + value.nodeValue + "?>");
               if(pretty)
               {
                  output.b += "\n";
               }
               break;
            case 6:
               if(value.nodeType != Xml.Document && value.nodeType != Xml.Element)
               {
                  throw Exception.thrown("Bad node type, expected Element or Document but found " + XmlType_Impl_.toString(value.nodeType));
               }
               _loc6_ = 0;
               _loc7_ = value.children;
               while(_loc6_ < int(_loc7_.length))
               {
                  _loc8_ = _loc7_[_loc6_++];
                  writeNode(_loc8_,tabs);
               }
         }
      }
      
      public function write(input:String) : void
      {
         output.b += Std.string(input);
      }
      
      public function newline() : void
      {
         if(pretty)
         {
            output.b += "\n";
         }
      }
      
      public function hasChildren(value:Xml) : Boolean
      {
         var _loc4_:* = null as Xml;
         if(value.nodeType != Xml.Document && value.nodeType != Xml.Element)
         {
            throw Exception.thrown("Bad node type, expected Element or Document but found " + XmlType_Impl_.toString(value.nodeType));
         }
         var _loc2_:int = 0;
         var _loc3_:Array = value.children;
         while(_loc2_ < int(_loc3_.length))
         {
            switch((_loc4_ = _loc3_[_loc2_++]).nodeType)
            {
               case 0:
               case 1:
                  return true;
               case 2:
               case 3:
                  if(_loc4_.nodeType == Xml.Document || _loc4_.nodeType == Xml.Element)
                  {
                     throw Exception.thrown("Bad node type, unexpected " + XmlType_Impl_.toString(_loc4_.nodeType));
                  }
                  if(StringTools.ltrim(_loc4_.nodeValue).length != 0)
                  {
                     return true;
                  }
            }
         }
         return false;
      }
   }
}

