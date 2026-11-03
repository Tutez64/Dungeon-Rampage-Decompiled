package haxe.rtti
{
   import _Xml.XmlType_Impl_;
   import flash.Boot;
   import haxe.Exception;
   import haxe.IMap;
   import haxe.ds.StringMap;
   import haxe.iterators.ArrayIterator;
   import haxe.xml._Access.Access_Impl_;
   import haxe.xml._Access.AttribAccess_Impl_;
   import haxe.xml._Access.HasAttribAccess_Impl_;
   import haxe.xml._Access.HasNodeAccess_Impl_;
   import haxe.xml._Access.NodeAccess_Impl_;
   import haxe.xml._Access.NodeListAccess_Impl_;
   
   public class XmlParser
   {
      
      public var root:Array;
      
      public var newField:Function;
      
      public var curplatform:String;
      
      public function XmlParser()
      {
         if(Boot.skip_constructor)
         {
            return;
         }
         if(!newField)
         {
            newField = function(c:Object, f:Object):void
            {
            };
         }
         root = [];
      }
      
      public function xtypeparams(x:Xml) : Array
      {
         var _loc4_:* = null as Xml;
         var _loc2_:Array = [];
         var _loc3_:* = x.elements();
         while(_loc3_.hasNext())
         {
            _loc4_ = _loc3_.next();
            _loc2_.push(xtype(_loc4_));
         }
         return _loc2_;
      }
      
      public function xtypedef(x:Xml) : Object
      {
         var _loc6_:* = null as Xml;
         var _loc7_:* = null as String;
         var _loc8_:* = null as String;
         var _loc2_:String = null;
         var _loc3_:CType = null;
         var _loc4_:Array = [];
         var _loc5_:* = x.elements();
         while(_loc5_.hasNext())
         {
            _loc6_ = _loc5_.next();
            if(_loc6_.nodeType == Xml.Document)
            {
               _loc7_ = "Document";
            }
            else
            {
               if(_loc6_.nodeType != Xml.Element)
               {
                  throw Exception.thrown("Bad node type, expected Element but found " + XmlType_Impl_.toString(_loc6_.nodeType));
               }
               _loc7_ = _loc6_.nodeName;
            }
            if(_loc7_ == "haxe_doc")
            {
               _loc2_ = Access_Impl_.get_innerData(_loc6_);
            }
            else
            {
               if(_loc6_.nodeType == Xml.Document)
               {
                  _loc8_ = "Document";
               }
               else
               {
                  if(_loc6_.nodeType != Xml.Element)
                  {
                     throw Exception.thrown("Bad node type, expected Element but found " + XmlType_Impl_.toString(_loc6_.nodeType));
                  }
                  _loc8_ = _loc6_.nodeName;
               }
               if(_loc8_ == "meta")
               {
                  _loc4_ = xmeta(_loc6_);
               }
               else
               {
                  _loc3_ = xtype(_loc6_);
               }
            }
         }
         var _loc9_:StringMap = new StringMap();
         if(curplatform != null)
         {
            _loc7_ = curplatform;
            if(_loc7_ in StringMap.reserved)
            {
               _loc9_.setReserved(_loc7_,_loc3_);
            }
            else
            {
               _loc9_.h[_loc7_] = _loc3_;
            }
         }
         return {
            "file":(HasAttribAccess_Impl_.resolve(x,"file") ? AttribAccess_Impl_.resolve(x,"file") : null),
            "path":mkPath(AttribAccess_Impl_.resolve(x,"path")),
            "module":(HasAttribAccess_Impl_.resolve(x,"module") ? mkPath(AttribAccess_Impl_.resolve(x,"module")) : null),
            "doc":_loc2_,
            "isPrivate":x.exists("private"),
            "params":mkTypeParams(AttribAccess_Impl_.resolve(x,"params")),
            "type":_loc3_,
            "types":_loc9_,
            "platforms":defplat(),
            "meta":_loc4_
         };
      }
      
      public function xtype(x:Xml) : CType
      {
         var _loc2_:* = null as String;
         var _loc4_:* = null as Array;
         var _loc5_:* = null;
         var _loc6_:* = null as Xml;
         var _loc7_:* = null;
         var _loc8_:* = null as CType;
         var _loc9_:* = null as Array;
         var _loc10_:int = 0;
         var _loc11_:* = null as Array;
         var _loc12_:* = null as ArrayIterator;
         var _loc13_:Boolean = false;
         var _loc14_:* = null as String;
         var _loc15_:* = null as String;
         var _loc16_:int = 0;
         if(x.nodeType == Xml.Document)
         {
            _loc2_ = "Document";
         }
         else
         {
            if(x.nodeType != Xml.Element)
            {
               throw Exception.thrown("Bad node type, expected Element but found " + XmlType_Impl_.toString(x.nodeType));
            }
            _loc2_ = x.nodeName;
         }
         var _loc3_:String = _loc2_;
         if(_loc3_ == "a")
         {
            _loc4_ = [];
            _loc5_ = x.elements();
            while(_loc5_.hasNext())
            {
               _loc6_ = _loc5_.next();
               _loc7_ = xclassfield(_loc6_,true);
               _loc7_.platforms = [];
               _loc4_.push(_loc7_);
            }
            return CType.CAnonymous(_loc4_);
         }
         if(_loc3_ == "c")
         {
            return CType.CClass(mkPath(AttribAccess_Impl_.resolve(x,"path")),xtypeparams(x));
         }
         if(_loc3_ == "d")
         {
            _loc8_ = null;
            _loc6_ = x.firstElement();
            if(_loc6_ != null)
            {
               if(_loc6_.nodeType != Xml.Document && _loc6_.nodeType != Xml.Element)
               {
                  throw Exception.thrown("Invalid nodeType " + XmlType_Impl_.toString(_loc6_.nodeType));
               }
               _loc8_ = xtype(_loc6_);
            }
            return CType.CDynamic(_loc8_);
         }
         if(_loc3_ == "e")
         {
            return CType.CEnum(mkPath(AttribAccess_Impl_.resolve(x,"path")),xtypeparams(x));
         }
         if(_loc3_ == "f")
         {
            _loc4_ = [];
            _loc9_ = AttribAccess_Impl_.resolve(x,"a").split(":");
            _loc10_ = 0;
            _loc11_ = _loc9_;
            _loc12_ = HasAttribAccess_Impl_.resolve(x,"v") ? new ArrayIterator(AttribAccess_Impl_.resolve(x,"v").split(":")) : null;
            _loc5_ = x.elements();
            while(_loc5_.hasNext())
            {
               _loc6_ = _loc5_.next();
               _loc13_ = false;
               _loc14_ = _loc10_ < int(_loc11_.length) ? _loc11_[_loc10_++] : null;
               if(_loc14_ == null)
               {
                  _loc14_ = "";
               }
               if(_loc14_.charAt(0) == "?")
               {
                  _loc13_ = true;
                  _loc14_ = _loc14_.substr(1);
               }
               var _temp_5:*;
               _loc15_ = _loc12_ == null || _loc12_.current >= int(_loc12_.array.length) ? null : (_temp_5 = _loc12_.array,_loc12_.current = (_loc16_ = _loc12_.current) + 1,_temp_5[_loc16_]);
               _loc4_.push({
                  "name":_loc14_,
                  "opt":_loc13_,
                  "t":xtype(_loc6_),
                  "value":(_loc15_ == "" ? null : _loc15_)
               });
            }
            _loc5_ = _loc4_[int(_loc4_.length) - 1];
            _loc4_.remove(_loc5_);
            return CType.CFunction(_loc4_,_loc5_.t);
         }
         if(_loc3_ == "t")
         {
            return CType.CTypedef(mkPath(AttribAccess_Impl_.resolve(x,"path")),xtypeparams(x));
         }
         if(_loc3_ == "unknown")
         {
            return CType.CUnknown;
         }
         if(_loc3_ == "x")
         {
            return CType.CAbstract(mkPath(AttribAccess_Impl_.resolve(x,"path")),xtypeparams(x));
         }
         return xerror(x);
      }
      
      public function xroot(x:Xml) : void
      {
         var _loc3_:* = null as Xml;
         var _loc2_:* = x.elements();
         while(_loc2_.hasNext())
         {
            _loc3_ = _loc2_.next();
            merge(processElement(_loc3_));
         }
      }
      
      public function xpath(x:Xml) : Object
      {
         var _loc5_:* = null as Xml;
         var _loc2_:String = mkPath(AttribAccess_Impl_.resolve(x,"path"));
         var _loc3_:Array = [];
         var _loc4_:* = x.elements();
         while(_loc4_.hasNext())
         {
            _loc5_ = _loc4_.next();
            _loc3_.push(xtype(_loc5_));
         }
         return {
            "path":_loc2_,
            "params":_loc3_
         };
      }
      
      public function xoverloads(x:Xml) : Array
      {
         var _loc4_:* = null as Xml;
         var _loc2_:Array = [];
         var _loc3_:* = x.elements();
         while(_loc3_.hasNext())
         {
            _loc4_ = _loc3_.next();
            _loc2_.push(xclassfield(_loc4_));
         }
         return _loc2_;
      }
      
      public function xmeta(x:Xml) : Array
      {
         var _loc5_:* = null as Xml;
         var _loc6_:* = null as Array;
         var _loc7_:int = 0;
         var _loc8_:* = null as Array;
         var _loc9_:* = null as Xml;
         var _loc2_:Array = [];
         var _loc3_:int = 0;
         var _loc4_:Array = NodeListAccess_Impl_.resolve(x,"m");
         while(_loc3_ < int(_loc4_.length))
         {
            _loc5_ = _loc4_[_loc3_];
            _loc3_++;
            _loc6_ = [];
            _loc7_ = 0;
            _loc8_ = NodeListAccess_Impl_.resolve(_loc5_,"e");
            while(_loc7_ < int(_loc8_.length))
            {
               _loc9_ = _loc8_[_loc7_];
               _loc7_++;
               _loc6_.push(Access_Impl_.get_innerHTML(_loc9_));
            }
            _loc2_.push({
               "name":AttribAccess_Impl_.resolve(_loc5_,"n"),
               "params":_loc6_
            });
         }
         return _loc2_;
      }
      
      public function xerror(c:Xml) : *
      {
         var _loc2_:* = null as String;
         if(c.nodeType == Xml.Document)
         {
            _loc2_ = "Document";
         }
         else
         {
            if(c.nodeType != Xml.Element)
            {
               throw Exception.thrown("Bad node type, expected Element but found " + XmlType_Impl_.toString(c.nodeType));
            }
            _loc2_ = c.nodeName;
         }
         throw Exception.thrown("Invalid " + _loc2_);
      }
      
      public function xenumfield(x:Xml) : Object
      {
         var _loc6_:* = null as Array;
         var _loc7_:* = null;
         var _loc8_:int = 0;
         var _loc9_:* = null as String;
         var _loc10_:Boolean = false;
         var _loc11_:* = null as String;
         var _loc2_:Array = null;
         var _loc3_:* = x.elementsNamed("haxe_doc");
         var _loc4_:Xml = _loc3_.hasNext() ? _loc3_.next() : null;
         var _loc5_:Array = HasNodeAccess_Impl_.resolve(x,"meta") ? xmeta(NodeAccess_Impl_.resolve(x,"meta")) : [];
         if(HasAttribAccess_Impl_.resolve(x,"a"))
         {
            _loc6_ = AttribAccess_Impl_.resolve(x,"a").split(":");
            _loc7_ = x.elements();
            _loc2_ = [];
            _loc8_ = 0;
            while(_loc8_ < int(_loc6_.length))
            {
               _loc9_ = _loc6_[_loc8_];
               _loc8_++;
               _loc10_ = false;
               if(_loc9_.charAt(0) == "?")
               {
                  _loc10_ = true;
                  _loc9_ = _loc9_.substr(1);
               }
               _loc2_.push({
                  "name":_loc9_,
                  "opt":_loc10_,
                  "t":xtype(_loc7_.next())
               });
            }
         }
         if(x.nodeType == Xml.Document)
         {
            _loc9_ = "Document";
         }
         else
         {
            if(x.nodeType != Xml.Element)
            {
               throw Exception.thrown("Bad node type, expected Element but found " + XmlType_Impl_.toString(x.nodeType));
            }
            _loc9_ = x.nodeName;
         }
         if(_loc4_ == null)
         {
            _loc11_ = null;
         }
         else
         {
            if(_loc4_.nodeType != Xml.Document && _loc4_.nodeType != Xml.Element)
            {
               throw Exception.thrown("Invalid nodeType " + XmlType_Impl_.toString(_loc4_.nodeType));
            }
            _loc11_ = Access_Impl_.get_innerData(_loc4_);
         }
         return {
            "name":_loc9_,
            "args":_loc2_,
            "doc":_loc11_,
            "meta":_loc5_,
            "platforms":defplat()
         };
      }
      
      public function xenum(x:Xml) : Object
      {
         var _loc6_:* = null as Xml;
         var _loc7_:* = null as String;
         var _loc8_:* = null as String;
         var _loc2_:Array = [];
         var _loc3_:String = null;
         var _loc4_:Array = [];
         var _loc5_:* = x.elements();
         while(_loc5_.hasNext())
         {
            _loc6_ = _loc5_.next();
            if(_loc6_.nodeType == Xml.Document)
            {
               _loc7_ = "Document";
            }
            else
            {
               if(_loc6_.nodeType != Xml.Element)
               {
                  throw Exception.thrown("Bad node type, expected Element but found " + XmlType_Impl_.toString(_loc6_.nodeType));
               }
               _loc7_ = _loc6_.nodeName;
            }
            if(_loc7_ == "haxe_doc")
            {
               _loc3_ = Access_Impl_.get_innerData(_loc6_);
            }
            else
            {
               if(_loc6_.nodeType == Xml.Document)
               {
                  _loc8_ = "Document";
               }
               else
               {
                  if(_loc6_.nodeType != Xml.Element)
                  {
                     throw Exception.thrown("Bad node type, expected Element but found " + XmlType_Impl_.toString(_loc6_.nodeType));
                  }
                  _loc8_ = _loc6_.nodeName;
               }
               if(_loc8_ == "meta")
               {
                  _loc4_ = xmeta(_loc6_);
               }
               else
               {
                  _loc2_.push(xenumfield(_loc6_));
               }
            }
         }
         return {
            "file":(HasAttribAccess_Impl_.resolve(x,"file") ? AttribAccess_Impl_.resolve(x,"file") : null),
            "path":mkPath(AttribAccess_Impl_.resolve(x,"path")),
            "module":(HasAttribAccess_Impl_.resolve(x,"module") ? mkPath(AttribAccess_Impl_.resolve(x,"module")) : null),
            "doc":_loc3_,
            "isPrivate":x.exists("private"),
            "isExtern":x.exists("extern"),
            "params":mkTypeParams(AttribAccess_Impl_.resolve(x,"params")),
            "constructors":_loc2_,
            "platforms":defplat(),
            "meta":_loc4_
         };
      }
      
      public function xclassfield(x:Xml, defPublic:Object = undefined) : Object
      {
         var _loc9_:* = null as Xml;
         var _loc10_:* = null as String;
         var _loc11_:* = null as String;
         if(defPublic == null)
         {
            defPublic = false;
         }
         var _loc3_:* = x.elements();
         var _loc4_:CType = xtype(_loc3_.next());
         var _loc5_:String = null;
         var _loc6_:Array = [];
         var _loc7_:Array = null;
         var _loc8_:* = _loc3_;
         while(_loc8_.hasNext())
         {
            _loc9_ = _loc8_.next();
            if(_loc9_.nodeType == Xml.Document)
            {
               _loc10_ = "Document";
            }
            else
            {
               if(_loc9_.nodeType != Xml.Element)
               {
                  throw Exception.thrown("Bad node type, expected Element but found " + XmlType_Impl_.toString(_loc9_.nodeType));
               }
               _loc10_ = _loc9_.nodeName;
            }
            _loc11_ = _loc10_;
            if(_loc11_ == "haxe_doc")
            {
               _loc5_ = Access_Impl_.get_innerData(_loc9_);
            }
            else if(_loc11_ == "meta")
            {
               _loc6_ = xmeta(_loc9_);
            }
            else if(_loc11_ == "overloads")
            {
               _loc7_ = xoverloads(_loc9_);
            }
            else
            {
               xerror(_loc9_);
            }
         }
         if(x.nodeType == Xml.Document)
         {
            _loc10_ = "Document";
         }
         else
         {
            if(x.nodeType != Xml.Element)
            {
               throw Exception.thrown("Bad node type, expected Element but found " + XmlType_Impl_.toString(x.nodeType));
            }
            _loc10_ = x.nodeName;
         }
         return {
            "name":_loc10_,
            "type":_loc4_,
            "isPublic":x.exists("public") || Boolean(defPublic),
            "isFinal":x.exists("final"),
            "isOverride":x.exists("override"),
            "line":(HasAttribAccess_Impl_.resolve(x,"line") ? Std.parseInt(AttribAccess_Impl_.resolve(x,"line")) : null),
            "doc":_loc5_,
            "get":(HasAttribAccess_Impl_.resolve(x,"get") ? mkRights(AttribAccess_Impl_.resolve(x,"get")) : Rights.RNormal),
            "set":(HasAttribAccess_Impl_.resolve(x,"set") ? mkRights(AttribAccess_Impl_.resolve(x,"set")) : Rights.RNormal),
            "params":(HasAttribAccess_Impl_.resolve(x,"params") ? mkTypeParams(AttribAccess_Impl_.resolve(x,"params")) : []),
            "platforms":defplat(),
            "meta":_loc6_,
            "overloads":_loc7_,
            "expr":(HasAttribAccess_Impl_.resolve(x,"expr") ? AttribAccess_Impl_.resolve(x,"expr") : null)
         };
      }
      
      public function xclass(x:Xml) : Object
      {
         var _loc11_:* = null as Xml;
         var _loc12_:* = null as String;
         var _loc13_:* = null as String;
         var _loc14_:* = null as Xml;
         var _loc2_:* = null;
         var _loc3_:String = null;
         var _loc4_:CType = null;
         var _loc5_:Array = [];
         var _loc6_:Array = [];
         var _loc7_:Array = [];
         var _loc8_:Array = [];
         var _loc9_:Boolean = x.exists("interface");
         var _loc10_:* = x.elements();
         while(_loc10_.hasNext())
         {
            _loc11_ = _loc10_.next();
            if(_loc11_.nodeType == Xml.Document)
            {
               _loc12_ = "Document";
            }
            else
            {
               if(_loc11_.nodeType != Xml.Element)
               {
                  throw Exception.thrown("Bad node type, expected Element but found " + XmlType_Impl_.toString(_loc11_.nodeType));
               }
               _loc12_ = _loc11_.nodeName;
            }
            _loc13_ = _loc12_;
            if(_loc13_ == "extends")
            {
               if(_loc9_)
               {
                  _loc5_.push(xpath(_loc11_));
               }
               else
               {
                  _loc2_ = xpath(_loc11_);
               }
            }
            else if(_loc13_ == "haxe_doc")
            {
               _loc3_ = Access_Impl_.get_innerData(_loc11_);
            }
            else if(_loc13_ == "haxe_dynamic")
            {
               _loc14_ = _loc11_.firstElement();
               if(_loc14_.nodeType != Xml.Document && _loc14_.nodeType != Xml.Element)
               {
                  throw Exception.thrown("Invalid nodeType " + XmlType_Impl_.toString(_loc14_.nodeType));
               }
               _loc4_ = xtype(_loc14_);
            }
            else if(_loc13_ == "implements")
            {
               _loc5_.push(xpath(_loc11_));
            }
            else if(_loc13_ == "meta")
            {
               _loc8_ = xmeta(_loc11_);
            }
            else if(_loc11_.exists("static"))
            {
               _loc7_.push(xclassfield(_loc11_));
            }
            else
            {
               _loc6_.push(xclassfield(_loc11_));
            }
         }
         return {
            "file":(HasAttribAccess_Impl_.resolve(x,"file") ? AttribAccess_Impl_.resolve(x,"file") : null),
            "path":mkPath(AttribAccess_Impl_.resolve(x,"path")),
            "module":(HasAttribAccess_Impl_.resolve(x,"module") ? mkPath(AttribAccess_Impl_.resolve(x,"module")) : null),
            "doc":_loc3_,
            "isPrivate":x.exists("private"),
            "isExtern":x.exists("extern"),
            "isFinal":x.exists("final"),
            "isInterface":_loc9_,
            "params":mkTypeParams(AttribAccess_Impl_.resolve(x,"params")),
            "superClass":_loc2_,
            "interfaces":_loc5_,
            "fields":_loc6_,
            "statics":_loc7_,
            "tdynamic":_loc4_,
            "platforms":defplat(),
            "meta":_loc8_
         };
      }
      
      public function xabstract(x:Xml) : Object
      {
         var _loc9_:* = null as Xml;
         var _loc10_:* = null as String;
         var _loc11_:* = null as String;
         var _loc12_:* = null;
         var _loc13_:* = null as Xml;
         var _loc14_:* = null as Xml;
         var _loc2_:String = null;
         var _loc3_:* = null;
         var _loc4_:CType = null;
         var _loc5_:Array = [];
         var _loc6_:Array = [];
         var _loc7_:Array = [];
         var _loc8_:* = x.elements();
         while(_loc8_.hasNext())
         {
            _loc9_ = _loc8_.next();
            if(_loc9_.nodeType == Xml.Document)
            {
               _loc10_ = "Document";
            }
            else
            {
               if(_loc9_.nodeType != Xml.Element)
               {
                  throw Exception.thrown("Bad node type, expected Element but found " + XmlType_Impl_.toString(_loc9_.nodeType));
               }
               _loc10_ = _loc9_.nodeName;
            }
            _loc11_ = _loc10_;
            if(_loc11_ == "from")
            {
               _loc12_ = _loc9_.elements();
               while(_loc12_.hasNext())
               {
                  _loc13_ = _loc12_.next();
                  _loc14_ = _loc13_.firstElement();
                  if(_loc14_.nodeType != Xml.Document && _loc14_.nodeType != Xml.Element)
                  {
                     throw Exception.thrown("Invalid nodeType " + XmlType_Impl_.toString(_loc14_.nodeType));
                  }
                  _loc7_.push({
                     "t":xtype(_loc14_),
                     "field":(HasAttribAccess_Impl_.resolve(_loc13_,"field") ? AttribAccess_Impl_.resolve(_loc13_,"field") : null)
                  });
               }
            }
            else if(_loc11_ == "haxe_doc")
            {
               _loc2_ = Access_Impl_.get_innerData(_loc9_);
            }
            else if(_loc11_ == "impl")
            {
               _loc3_ = xclass(NodeAccess_Impl_.resolve(_loc9_,"class"));
            }
            else if(_loc11_ == "meta")
            {
               _loc5_ = xmeta(_loc9_);
            }
            else if(_loc11_ == "this")
            {
               _loc13_ = _loc9_.firstElement();
               if(_loc13_.nodeType != Xml.Document && _loc13_.nodeType != Xml.Element)
               {
                  throw Exception.thrown("Invalid nodeType " + XmlType_Impl_.toString(_loc13_.nodeType));
               }
               _loc4_ = xtype(_loc13_);
            }
            else if(_loc11_ == "to")
            {
               _loc12_ = _loc9_.elements();
               while(_loc12_.hasNext())
               {
                  _loc13_ = _loc12_.next();
                  _loc14_ = _loc13_.firstElement();
                  if(_loc14_.nodeType != Xml.Document && _loc14_.nodeType != Xml.Element)
                  {
                     throw Exception.thrown("Invalid nodeType " + XmlType_Impl_.toString(_loc14_.nodeType));
                  }
                  _loc6_.push({
                     "t":xtype(_loc14_),
                     "field":(HasAttribAccess_Impl_.resolve(_loc13_,"field") ? AttribAccess_Impl_.resolve(_loc13_,"field") : null)
                  });
               }
            }
            else
            {
               xerror(_loc9_);
            }
         }
         return {
            "file":(HasAttribAccess_Impl_.resolve(x,"file") ? AttribAccess_Impl_.resolve(x,"file") : null),
            "path":mkPath(AttribAccess_Impl_.resolve(x,"path")),
            "module":(HasAttribAccess_Impl_.resolve(x,"module") ? mkPath(AttribAccess_Impl_.resolve(x,"module")) : null),
            "doc":_loc2_,
            "isPrivate":x.exists("private"),
            "params":mkTypeParams(AttribAccess_Impl_.resolve(x,"params")),
            "platforms":defplat(),
            "meta":_loc5_,
            "athis":_loc4_,
            "to":_loc6_,
            "from":_loc7_,
            "impl":_loc3_
         };
      }
      
      public function sortFields(a:Array) : void
      {
         a.sort(function(f1:Object, f2:Object):int
         {
            var _loc3_:Boolean = TypeApi.isVar(f1.type);
            var _loc4_:Boolean = TypeApi.isVar(f2.type);
            if(_loc3_ && !_loc4_)
            {
               return -1;
            }
            if(_loc4_ && !_loc3_)
            {
               return 1;
            }
            if(f1.name == "new")
            {
               return -1;
            }
            if(f2.name == "new")
            {
               return 1;
            }
            if(f1.name > f2.name)
            {
               return 1;
            }
            return -1;
         });
      }
      
      public function sort(l:Array = undefined) : void
      {
         var _loc3_:* = null as TypeTree;
         var _loc4_:* = null as String;
         var _loc5_:* = null as String;
         var _loc6_:* = null as Array;
         var _loc7_:* = null;
         if(l == null)
         {
            l = root;
         }
         l.sort(function(e1:TypeTree, e2:TypeTree):int
         {
            var _loc3_:* = null as String;
            var _loc4_:* = null as String;
            var _loc5_:* = null as Array;
            var _loc6_:* = null as String;
            var _loc7_:* = null as String;
            if(e1.index == 0)
            {
               _loc4_ = e1.params[1];
               _loc5_ = e1.params[2];
               _loc6_ = e1.params[0];
               _loc3_ = " " + _loc6_;
            }
            else
            {
               _loc3_ = TypeApi.typeInfos(e1).path;
            }
            if(e2.index == 0)
            {
               _loc6_ = e2.params[1];
               _loc5_ = e2.params[2];
               _loc7_ = e2.params[0];
               _loc4_ = " " + _loc7_;
            }
            else
            {
               _loc4_ = TypeApi.typeInfos(e2).path;
            }
            if(_loc3_ > _loc4_)
            {
               return 1;
            }
            return -1;
         });
         var _loc2_:int = 0;
         while(_loc2_ < int(l.length))
         {
            _loc3_ = l[_loc2_];
            _loc2_++;
            switch(_loc3_.index)
            {
               case 0:
                  _loc4_ = _loc3_.params[0];
                  _loc5_ = _loc3_.params[1];
                  _loc6_ = _loc3_.params[2];
                  sort(_loc6_);
                  break;
               case 1:
                  _loc7_ = _loc3_.params[0];
                  sortFields(_loc7_.fields);
                  sortFields(_loc7_.statics);
                  break;
               case 2:
                  _loc7_ = _loc3_.params[0];
                  break;
               case 3:
                  _loc7_ = _loc3_.params[0];
                  break;
               case 4:
                  _loc7_ = _loc3_.params[0];
            }
         }
      }
      
      public function processElement(x:Xml) : TypeTree
      {
         var _loc3_:* = null as String;
         if(x.nodeType != Xml.Document && x.nodeType != Xml.Element)
         {
            throw Exception.thrown("Invalid nodeType " + XmlType_Impl_.toString(x.nodeType));
         }
         var _loc2_:Xml = x;
         if(_loc2_.nodeType == Xml.Document)
         {
            _loc3_ = "Document";
         }
         else
         {
            if(_loc2_.nodeType != Xml.Element)
            {
               throw Exception.thrown("Bad node type, expected Element but found " + XmlType_Impl_.toString(_loc2_.nodeType));
            }
            _loc3_ = _loc2_.nodeName;
         }
         var _loc4_:String = _loc3_;
         if(_loc4_ == "abstract")
         {
            return TypeTree.TAbstractdecl(xabstract(_loc2_));
         }
         if(_loc4_ == "class")
         {
            return TypeTree.TClassdecl(xclass(_loc2_));
         }
         if(_loc4_ == "enum")
         {
            return TypeTree.TEnumdecl(xenum(_loc2_));
         }
         if(_loc4_ == "typedef")
         {
            return TypeTree.TTypedecl(xtypedef(_loc2_));
         }
         return xerror(_loc2_);
      }
      
      public function process(x:Xml, platform:String) : void
      {
         curplatform = platform;
         if(x.nodeType != Xml.Document && x.nodeType != Xml.Element)
         {
            throw Exception.thrown("Invalid nodeType " + XmlType_Impl_.toString(x.nodeType));
         }
         xroot(x);
      }
      
      public function mkTypeParams(p:String) : Array
      {
         var _loc2_:Array = p.split(":");
         if(_loc2_[0] == "")
         {
            return [];
         }
         return _loc2_;
      }
      
      public function mkRights(r:String) : Rights
      {
         var _loc2_:String = r;
         if(_loc2_ == "dynamic")
         {
            return Rights.RDynamic;
         }
         if(_loc2_ == "inline")
         {
            return Rights.RInline;
         }
         if(_loc2_ == "method")
         {
            return Rights.RMethod;
         }
         if(_loc2_ == "null")
         {
            return Rights.RNo;
         }
         return Rights.RCall(r);
      }
      
      public function mkPath(p:String) : String
      {
         return p;
      }
      
      public function mergeTypedefs(t:Object, t2:Object) : Boolean
      {
         if(curplatform == null)
         {
            return false;
         }
         t.platforms.push(curplatform);
         var _loc3_:String = curplatform;
         var _loc4_:CType = t2.type;
         var _loc5_:StringMap = StringMap(t.types);
         if(_loc3_ in StringMap.reserved)
         {
            _loc5_.setReserved(_loc3_,_loc4_);
         }
         else
         {
            _loc5_.h[_loc3_] = _loc4_;
         }
         return true;
      }
      
      public function mergeRights(f1:Object, f2:Object) : Boolean
      {
         if(f1.get == Rights.RInline && f1.set == Rights.RNo && f2.get == Rights.RNormal && f2.set == Rights.RMethod)
         {
            f1.get = Rights.RNormal;
            f1.set = Rights.RMethod;
            return true;
         }
         if(Type.enumEq(f1.get,f2.get))
         {
            return Type.enumEq(f1.set,f2.set);
         }
         return false;
      }
      
      public function mergeFields(f:Object, f2:Object) : Boolean
      {
         if(!TypeApi.fieldEq(f,f2))
         {
            if(f.name == f2.name && (mergeRights(f,f2) || mergeRights(f2,f)) && mergeDoc(f,f2))
            {
               return TypeApi.fieldEq(f,f2);
            }
            return false;
         }
         return true;
      }
      
      public function mergeEnums(e:Object, e2:Object) : Boolean
      {
         var _loc5_:* = null;
         var _loc6_:* = null;
         var _loc7_:int = 0;
         var _loc8_:* = null as Array;
         var _loc9_:* = null;
         if(Boolean(e.isExtern) != Boolean(e2.isExtern))
         {
            return false;
         }
         if(curplatform != null)
         {
            e.platforms.push(curplatform);
         }
         var _loc3_:int = 0;
         var _loc4_:Array = e2.constructors;
         while(_loc3_ < int(_loc4_.length))
         {
            _loc5_ = _loc4_[_loc3_];
            _loc3_++;
            _loc6_ = null;
            _loc7_ = 0;
            _loc8_ = e.constructors;
            while(_loc7_ < int(_loc8_.length))
            {
               _loc9_ = _loc8_[_loc7_];
               _loc7_++;
               if(TypeApi.constructorEq(_loc9_,_loc5_))
               {
                  _loc6_ = _loc9_;
                  break;
               }
            }
            if(_loc6_ == null)
            {
               e.constructors.push(_loc5_);
            }
            else if(curplatform != null)
            {
               _loc6_.platforms.push(curplatform);
            }
         }
         return true;
      }
      
      public function mergeDoc(f1:Object, f2:Object) : Boolean
      {
         if(f1.doc == null)
         {
            f1.doc = f2.doc;
         }
         else if(f2.doc == null)
         {
            f2.doc = f1.doc;
         }
         return true;
      }
      
      public function mergeClasses(c:Object, c2:Object) : Boolean
      {
         var _loc5_:* = null;
         var _loc6_:* = null;
         var _loc7_:int = 0;
         var _loc8_:* = null as Array;
         var _loc9_:* = null;
         if(Boolean(c.isInterface) != Boolean(c2.isInterface))
         {
            return false;
         }
         if(curplatform != null)
         {
            c.platforms.push(curplatform);
         }
         if(Boolean(c.isExtern) != Boolean(c2.isExtern))
         {
            c.isExtern = false;
         }
         var _loc3_:int = 0;
         var _loc4_:Array = c2.fields;
         while(_loc3_ < int(_loc4_.length))
         {
            _loc5_ = _loc4_[_loc3_];
            _loc3_++;
            _loc6_ = null;
            _loc7_ = 0;
            _loc8_ = c.fields;
            while(_loc7_ < int(_loc8_.length))
            {
               _loc9_ = _loc8_[_loc7_];
               _loc7_++;
               if(mergeFields(_loc9_,_loc5_))
               {
                  _loc6_ = _loc9_;
                  break;
               }
            }
            if(_loc6_ == null)
            {
               newField(c,_loc5_);
               c.fields.push(_loc5_);
            }
            else if(curplatform != null)
            {
               _loc6_.platforms.push(curplatform);
            }
         }
         _loc3_ = 0;
         _loc4_ = c2.statics;
         while(_loc3_ < int(_loc4_.length))
         {
            _loc5_ = _loc4_[_loc3_];
            _loc3_++;
            _loc6_ = null;
            _loc7_ = 0;
            _loc8_ = c.statics;
            while(_loc7_ < int(_loc8_.length))
            {
               _loc9_ = _loc8_[_loc7_];
               _loc7_++;
               if(mergeFields(_loc9_,_loc5_))
               {
                  _loc6_ = _loc9_;
                  break;
               }
            }
            if(_loc6_ == null)
            {
               newField(c,_loc5_);
               c.statics.push(_loc5_);
            }
            else if(curplatform != null)
            {
               _loc6_.platforms.push(curplatform);
            }
         }
         return true;
      }
      
      public function mergeAbstracts(a:Object, a2:Object) : Boolean
      {
         var _loc5_:int = 0;
         if(curplatform == null)
         {
            return false;
         }
         if(int(a.to.length) != int(a2.to.length) || int(a.from.length) != int(a2.from.length))
         {
            return false;
         }
         var _loc3_:int = 0;
         var _loc4_:int = int(a.to.length);
         while(_loc3_ < _loc4_)
         {
            _loc5_ = _loc3_++;
            if(!TypeApi.typeEq(a.to[_loc5_].t,a2.to[_loc5_].t))
            {
               return false;
            }
         }
         _loc3_ = 0;
         _loc4_ = int(a.from.length);
         while(_loc3_ < _loc4_)
         {
            _loc5_ = _loc3_++;
            if(!TypeApi.typeEq(a.from[_loc5_].t,a2.from[_loc5_].t))
            {
               return false;
            }
         }
         if(a2.impl != null)
         {
            mergeClasses(a.impl,a2.impl);
         }
         a.platforms.push(curplatform);
         return true;
      }
      
      public function merge(t:TypeTree) : void
      {
         var _loc7_:* = null as String;
         var _loc8_:Boolean = false;
         var _loc9_:int = 0;
         var _loc10_:* = null as TypeTree;
         var _loc11_:* = null as String;
         var _loc12_:* = null as String;
         var _loc13_:* = null as Array;
         var _loc14_:* = null;
         var _loc15_:Boolean = false;
         var _loc16_:* = null;
         var _loc17_:* = null;
         var _loc2_:* = TypeApi.typeInfos(t);
         var _loc3_:Array = _loc2_.path.split(".");
         var _loc4_:Array = root;
         var _loc5_:Array = [];
         _loc3_.pop();
         var _loc6_:int = 0;
         while(_loc6_ < int(_loc3_.length))
         {
            _loc7_ = _loc3_[_loc6_];
            _loc6_++;
            _loc8_ = false;
            _loc9_ = 0;
            while(_loc9_ < int(_loc4_.length))
            {
               _loc10_ = _loc4_[_loc9_];
               _loc9_++;
               if(_loc10_.index == 0)
               {
                  _loc11_ = _loc10_.params[1];
                  _loc12_ = _loc10_.params[0];
                  _loc13_ = _loc10_.params[2];
                  if(_loc12_ == _loc7_)
                  {
                     _loc8_ = true;
                     _loc4_ = _loc13_;
                     break;
                  }
               }
            }
            _loc5_.push(_loc7_);
            if(!_loc8_)
            {
               _loc13_ = [];
               _loc4_.push(TypeTree.TPackage(_loc7_,_loc5_.join("."),_loc13_));
               _loc4_ = _loc13_;
            }
         }
         _loc6_ = 0;
         while(_loc6_ < int(_loc4_.length))
         {
            _loc10_ = _loc4_[_loc6_];
            _loc6_++;
            if(_loc10_.index == 0)
            {
               _loc7_ = _loc10_.params[0];
               _loc11_ = _loc10_.params[1];
               _loc13_ = _loc10_.params[2];
               _loc8_ = true;
            }
            else
            {
               _loc8_ = false;
            }
            if(!_loc8_)
            {
               _loc14_ = TypeApi.typeInfos(_loc10_);
               if(_loc14_.path == _loc2_.path)
               {
                  _loc15_ = true;
                  if(_loc14_.doc == null != (_loc2_.doc == null))
                  {
                     if(_loc2_.doc == null)
                     {
                        _loc2_.doc = _loc14_.doc;
                     }
                     else
                     {
                        _loc14_.doc = _loc2_.doc;
                     }
                  }
                  if(_loc14_.path != "haxe._Int64.NativeInt64")
                  {
                     if(_loc14_.module == _loc2_.module && _loc14_.doc == _loc2_.doc && Boolean(_loc14_.isPrivate) == Boolean(_loc2_.isPrivate))
                     {
                        switch(_loc10_.index)
                        {
                           case 0:
                              _loc7_ = _loc10_.params[0];
                              _loc11_ = _loc10_.params[1];
                              _loc13_ = _loc10_.params[2];
                              _loc15_ = false;
                              break;
                           case 1:
                              _loc16_ = _loc10_.params[0];
                              if(t.index == 1)
                              {
                                 _loc17_ = t.params[0];
                                 if(mergeClasses(_loc16_,_loc17_))
                                 {
                                    return;
                                 }
                              }
                              else
                              {
                                 _loc15_ = false;
                              }
                              break;
                           case 2:
                              _loc16_ = _loc10_.params[0];
                              if(t.index == 2)
                              {
                                 _loc17_ = t.params[0];
                                 if(mergeEnums(_loc16_,_loc17_))
                                 {
                                    return;
                                 }
                              }
                              else
                              {
                                 _loc15_ = false;
                              }
                              break;
                           case 3:
                              _loc16_ = _loc10_.params[0];
                              if(t.index == 3)
                              {
                                 _loc17_ = t.params[0];
                                 if(mergeTypedefs(_loc16_,_loc17_))
                                 {
                                    return;
                                 }
                              }
                              break;
                           case 4:
                              _loc16_ = _loc10_.params[0];
                              if(t.index == 4)
                              {
                                 _loc17_ = t.params[0];
                                 if(mergeAbstracts(_loc16_,_loc17_))
                                 {
                                    return;
                                 }
                                 break;
                              }
                              _loc15_ = false;
                        }
                     }
                     _loc7_ = _loc14_.module != _loc2_.module ? "module " + _loc2_.module + " should be " + _loc14_.module : (_loc14_.doc != _loc2_.doc ? "documentation is different" : (Boolean(_loc14_.isPrivate) != Boolean(_loc2_.isPrivate) ? "private flag is different" : (!_loc15_ ? "type kind is different" : "could not merge definition")));
                     throw Exception.thrown("Incompatibilities between " + _loc14_.path + " in " + _loc14_.platforms.join(",") + " and " + curplatform + " (" + _loc7_ + ")");
                  }
               }
            }
         }
         _loc4_.push(t);
      }
      
      public function defplat() : Array
      {
         var _loc1_:Array = [];
         if(curplatform != null)
         {
            _loc1_.push(curplatform);
         }
         return _loc1_;
      }
   }
}

