package
{
   import _Xml.XmlType_Impl_;
   import flash.Boot;
   import haxe.Exception;
   import haxe.IMap;
   import haxe.ds.StringMap;
   import haxe.ds._StringMap.StringMapKeysIterator;
   import haxe.iterators.ArrayIterator;
   import haxe.xml.Parser;
   import haxe.xml.Printer;
   
   public class Xml
   {
      
      public static var Element:int = 0;
      
      public static var PCData:int = 1;
      
      public static var CData:int = 2;
      
      public static var Comment:int = 3;
      
      public static var DocType:int = 4;
      
      public static var ProcessingInstruction:int = 5;
      
      public static var Document:int = 6;
      
      public var parent:Xml;
      
      public var nodeValue:String;
      
      public var nodeType:int;
      
      public var nodeName:String;
      
      public var children:Array;
      
      public var attributeMap:IMap;
      
      public function Xml(nodeType:int = 0)
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         this.nodeType = nodeType;
         children = [];
         attributeMap = new StringMap();
      }
      
      public static function parse(str:String) : Xml
      {
         return Parser.parse(str);
      }
      
      public static function createElement(name:String) : Xml
      {
         var _loc2_:Xml = new Xml(Xml.Element);
         if(_loc2_.nodeType != Xml.Element)
         {
            throw Exception.thrown("Bad node type, expected Element but found " + XmlType_Impl_.toString(_loc2_.nodeType));
         }
         _loc2_.nodeName = name;
         return _loc2_;
      }
      
      public static function createPCData(data:String) : Xml
      {
         var _loc2_:Xml = new Xml(Xml.PCData);
         if(_loc2_.nodeType == Xml.Document || _loc2_.nodeType == Xml.Element)
         {
            throw Exception.thrown("Bad node type, unexpected " + XmlType_Impl_.toString(_loc2_.nodeType));
         }
         _loc2_.nodeValue = data;
         return _loc2_;
      }
      
      public static function createCData(data:String) : Xml
      {
         var _loc2_:Xml = new Xml(Xml.CData);
         if(_loc2_.nodeType == Xml.Document || _loc2_.nodeType == Xml.Element)
         {
            throw Exception.thrown("Bad node type, unexpected " + XmlType_Impl_.toString(_loc2_.nodeType));
         }
         _loc2_.nodeValue = data;
         return _loc2_;
      }
      
      public static function createComment(data:String) : Xml
      {
         var _loc2_:Xml = new Xml(Xml.Comment);
         if(_loc2_.nodeType == Xml.Document || _loc2_.nodeType == Xml.Element)
         {
            throw Exception.thrown("Bad node type, unexpected " + XmlType_Impl_.toString(_loc2_.nodeType));
         }
         _loc2_.nodeValue = data;
         return _loc2_;
      }
      
      public static function createDocType(data:String) : Xml
      {
         var _loc2_:Xml = new Xml(Xml.DocType);
         if(_loc2_.nodeType == Xml.Document || _loc2_.nodeType == Xml.Element)
         {
            throw Exception.thrown("Bad node type, unexpected " + XmlType_Impl_.toString(_loc2_.nodeType));
         }
         _loc2_.nodeValue = data;
         return _loc2_;
      }
      
      public static function createProcessingInstruction(data:String) : Xml
      {
         var _loc2_:Xml = new Xml(Xml.ProcessingInstruction);
         if(_loc2_.nodeType == Xml.Document || _loc2_.nodeType == Xml.Element)
         {
            throw Exception.thrown("Bad node type, unexpected " + XmlType_Impl_.toString(_loc2_.nodeType));
         }
         _loc2_.nodeValue = data;
         return _loc2_;
      }
      
      public static function createDocument() : Xml
      {
         return new Xml(Xml.Document);
      }
      
      public function toString() : String
      {
         return Printer.print(this);
      }
      
      public function set_nodeValue(v:String) : String
      {
         if(nodeType == Xml.Document || nodeType == Xml.Element)
         {
            throw Exception.thrown("Bad node type, unexpected " + XmlType_Impl_.toString(nodeType));
         }
         return nodeValue = v;
      }
      
      public function set_nodeName(v:String) : String
      {
         if(nodeType != Xml.Element)
         {
            throw Exception.thrown("Bad node type, expected Element but found " + XmlType_Impl_.toString(nodeType));
         }
         return nodeName = v;
      }
      
      public function set(att:String, value:String) : void
      {
         if(nodeType != Xml.Element)
         {
            throw Exception.thrown("Bad node type, expected Element but found " + XmlType_Impl_.toString(nodeType));
         }
         var _loc3_:StringMap = StringMap(attributeMap);
         if(att in StringMap.reserved)
         {
            _loc3_.setReserved(att,value);
         }
         else
         {
            _loc3_.h[att] = value;
         }
      }
      
      public function removeChild(x:Xml) : Boolean
      {
         if(nodeType != Xml.Document && nodeType != Xml.Element)
         {
            throw Exception.thrown("Bad node type, expected Element or Document but found " + XmlType_Impl_.toString(nodeType));
         }
         if(children.remove(x))
         {
            x.parent = null;
            return true;
         }
         return false;
      }
      
      public function remove(att:String) : void
      {
         if(nodeType != Xml.Element)
         {
            throw Exception.thrown("Bad node type, expected Element but found " + XmlType_Impl_.toString(nodeType));
         }
         StringMap(attributeMap).remove(att);
      }
      
      public function iterator() : Object
      {
         if(nodeType != Xml.Document && nodeType != Xml.Element)
         {
            throw Exception.thrown("Bad node type, expected Element or Document but found " + XmlType_Impl_.toString(nodeType));
         }
         return new ArrayIterator(children);
      }
      
      public function insertChild(x:Xml, pos:int) : void
      {
         if(nodeType != Xml.Document && nodeType != Xml.Element)
         {
            throw Exception.thrown("Bad node type, expected Element or Document but found " + XmlType_Impl_.toString(nodeType));
         }
         if(x.parent != null)
         {
            x.parent.children.remove(x);
         }
         children.insert(pos,x);
         x.parent = this;
      }
      
      public function get_nodeValue() : String
      {
         if(nodeType == Xml.Document || nodeType == Xml.Element)
         {
            throw Exception.thrown("Bad node type, unexpected " + XmlType_Impl_.toString(nodeType));
         }
         return nodeValue;
      }
      
      public function get_nodeName() : String
      {
         if(nodeType != Xml.Element)
         {
            throw Exception.thrown("Bad node type, expected Element but found " + XmlType_Impl_.toString(nodeType));
         }
         return nodeName;
      }
      
      public function get(att:String) : String
      {
         if(nodeType != Xml.Element)
         {
            throw Exception.thrown("Bad node type, expected Element but found " + XmlType_Impl_.toString(nodeType));
         }
         var _loc2_:StringMap = StringMap(attributeMap);
         if(att in StringMap.reserved)
         {
            return _loc2_.getReserved(att);
         }
         return _loc2_.h[att];
      }
      
      public function firstElement() : Xml
      {
         var _loc3_:* = null as Xml;
         if(nodeType != Xml.Document && nodeType != Xml.Element)
         {
            throw Exception.thrown("Bad node type, expected Element or Document but found " + XmlType_Impl_.toString(nodeType));
         }
         var _loc1_:int = 0;
         var _loc2_:Array = children;
         while(_loc1_ < int(_loc2_.length))
         {
            _loc3_ = _loc2_[_loc1_];
            _loc1_++;
            if(_loc3_.nodeType == Xml.Element)
            {
               return _loc3_;
            }
         }
         return null;
      }
      
      public function firstChild() : Xml
      {
         if(nodeType != Xml.Document && nodeType != Xml.Element)
         {
            throw Exception.thrown("Bad node type, expected Element or Document but found " + XmlType_Impl_.toString(nodeType));
         }
         return children[0];
      }
      
      public function exists(att:String) : Boolean
      {
         if(nodeType != Xml.Element)
         {
            throw Exception.thrown("Bad node type, expected Element but found " + XmlType_Impl_.toString(nodeType));
         }
         var _loc2_:StringMap = StringMap(attributeMap);
         if(att in StringMap.reserved)
         {
            return _loc2_.existsReserved(att);
         }
         return att in _loc2_.h;
      }
      
      public function ensureElementType() : void
      {
         if(nodeType != Xml.Document && nodeType != Xml.Element)
         {
            throw Exception.thrown("Bad node type, expected Element or Document but found " + XmlType_Impl_.toString(nodeType));
         }
      }
      
      public function elementsNamed(name:String) : Object
      {
         var _loc5_:* = null as Xml;
         var _loc6_:Boolean = false;
         if(nodeType != Xml.Document && nodeType != Xml.Element)
         {
            throw Exception.thrown("Bad node type, expected Element or Document but found " + XmlType_Impl_.toString(nodeType));
         }
         var _loc2_:Array = [];
         var _loc3_:int = 0;
         var _loc4_:Array = children;
         while(_loc3_ < int(_loc4_.length))
         {
            _loc5_ = _loc4_[_loc3_];
            _loc3_++;
            if(_loc5_.nodeType == Xml.Element)
            {
               if(_loc5_.nodeType != Xml.Element)
               {
                  throw Exception.thrown("Bad node type, expected Element but found " + XmlType_Impl_.toString(_loc5_.nodeType));
               }
               _loc6_ = _loc5_.nodeName == name;
            }
            else
            {
               _loc6_ = false;
            }
            if(_loc6_)
            {
               _loc2_.push(_loc5_);
            }
         }
         _loc4_ = _loc2_;
         return new ArrayIterator(_loc4_);
      }
      
      public function elements() : Object
      {
         var _loc4_:* = null as Xml;
         if(nodeType != Xml.Document && nodeType != Xml.Element)
         {
            throw Exception.thrown("Bad node type, expected Element or Document but found " + XmlType_Impl_.toString(nodeType));
         }
         var _loc1_:Array = [];
         var _loc2_:int = 0;
         var _loc3_:Array = children;
         while(_loc2_ < int(_loc3_.length))
         {
            _loc4_ = _loc3_[_loc2_];
            _loc2_++;
            if(_loc4_.nodeType == Xml.Element)
            {
               _loc1_.push(_loc4_);
            }
         }
         _loc3_ = _loc1_;
         return new ArrayIterator(_loc3_);
      }
      
      public function attributes() : Object
      {
         if(nodeType != Xml.Element)
         {
            throw Exception.thrown("Bad node type, expected Element but found " + XmlType_Impl_.toString(nodeType));
         }
         var _loc1_:StringMap = StringMap(attributeMap);
         return new StringMapKeysIterator(_loc1_.h,_loc1_.rh);
      }
      
      public function addChild(x:Xml) : void
      {
         if(nodeType != Xml.Document && nodeType != Xml.Element)
         {
            throw Exception.thrown("Bad node type, expected Element or Document but found " + XmlType_Impl_.toString(nodeType));
         }
         if(x.parent != null)
         {
            x.parent.removeChild(x);
         }
         children.push(x);
         x.parent = this;
      }
   }
}

