package haxe.xml
{
   import _Xml.XmlType_Impl_;
   import flash.Boot;
   import haxe.Exception;
   import haxe.ds.StringMap;
   
   public class Parser
   {
      
      public static var escapes:StringMap;
      
      public function Parser()
      {
      }
      
      public static function parse(str:String, strict:Boolean = false) : Xml
      {
         var _loc3_:Xml = Xml.createDocument();
         Parser.doParse(str,strict,0,_loc3_);
         return _loc3_;
      }
      
      public static function doParse(str:String, strict:Boolean, p:int = 0, parent:Xml = undefined) : int
      {
         var _loc15_:int = 0;
         var _loc16_:* = null as String;
         var _loc17_:* = null as Object;
         var _loc18_:* = null as Xml;
         var _loc19_:int = 0;
         var _loc20_:* = null as StringMap;
         var _loc21_:* = null as StringMap;
         var _loc22_:* = null as String;
         var _loc5_:Xml = null;
         var _loc6_:int = 1;
         var _loc7_:int = 1;
         var _loc8_:String = null;
         var _loc9_:* = 0;
         var _loc10_:int = 0;
         var _loc11_:int = 0;
         var _loc12_:StringBuf = new StringBuf();
         var _loc13_:int = 1;
         var _loc14_:int = -1;
         while(p < str.length)
         {
            _loc15_ = str.charCodeAt(p);
            switch(_loc6_)
            {
               case 0:
                  switch(_loc15_)
                  {
                     case 9:
                     case 10:
                     case 13:
                     case 32:
                        break;
                     default:
                        _loc6_ = _loc7_;
                        continue;
                  }
                  break;
               case 1:
                  if(_loc15_ == 60)
                  {
                     _loc6_ = 0;
                     _loc7_ = 2;
                     break;
                  }
                  _loc9_ = int(p);
                  _loc6_ = 13;
                  continue;
               case 2:
                  switch(_loc15_)
                  {
                     case 33:
                        if(int(str.charCodeAt(p + 1)) == 91)
                        {
                           p += 2;
                           if(str.substr(p,6).toUpperCase() != "CDATA[")
                           {
                              throw Exception.thrown(new XmlParserException("Expected <![CDATA[",str,p));
                           }
                           p += 5;
                           _loc6_ = 17;
                           _loc9_ = p + 1;
                        }
                        else if(int(str.charCodeAt(p + 1)) == 68 || int(str.charCodeAt(p + 1)) == 100)
                        {
                           if(str.substr(p + 2,6).toUpperCase() != "OCTYPE")
                           {
                              throw Exception.thrown(new XmlParserException("Expected <!DOCTYPE",str,p));
                           }
                           p += 8;
                           _loc6_ = 16;
                           _loc9_ = p + 1;
                        }
                        else
                        {
                           if(int(str.charCodeAt(p + 1)) != 45 || int(str.charCodeAt(p + 2)) != 45)
                           {
                              throw Exception.thrown(new XmlParserException("Expected <!--",str,p));
                           }
                           p += 2;
                           _loc6_ = 15;
                           _loc9_ = p + 1;
                        }
                        break;
                     case 47:
                        if(parent == null)
                        {
                           throw Exception.thrown(new XmlParserException("Expected node name",str,p));
                        }
                        _loc9_ = p + 1;
                        _loc6_ = 0;
                        _loc7_ = 10;
                        break;
                     case 63:
                        _loc6_ = 14;
                        _loc9_ = int(p);
                        break;
                     default:
                        _loc6_ = 3;
                        _loc9_ = int(p);
                        continue;
                  }
                  break;
               case 3:
                  if(_loc15_ >= 97 && _loc15_ <= 122 || _loc15_ >= 65 && _loc15_ <= 90 || _loc15_ >= 48 && _loc15_ <= 57 || _loc15_ == 58 || _loc15_ == 46 || _loc15_ == 95 || _loc15_ == 45)
                  {
                     break;
                  }
                  if(p == _loc9_)
                  {
                     throw Exception.thrown(new XmlParserException("Expected node name",str,p));
                  }
                  _loc5_ = Xml.createElement(str.substr(_loc9_,p - _loc9_));
                  parent.addChild(_loc5_);
                  _loc10_++;
                  _loc6_ = 0;
                  _loc7_ = 4;
                  continue;
               case 4:
                  switch(_loc15_)
                  {
                     case 47:
                        _loc6_ = 11;
                        break;
                     case 62:
                        _loc6_ = 9;
                        break;
                     default:
                        _loc6_ = 5;
                        _loc9_ = int(p);
                        continue;
                  }
                  break;
               case 5:
                  if(_loc15_ >= 97 && _loc15_ <= 122 || _loc15_ >= 65 && _loc15_ <= 90 || _loc15_ >= 48 && _loc15_ <= 57 || _loc15_ == 58 || _loc15_ == 46 || _loc15_ == 95 || _loc15_ == 45)
                  {
                     break;
                  }
                  if(_loc9_ == p)
                  {
                     throw Exception.thrown(new XmlParserException("Expected attribute name",str,p));
                  }
                  _loc8_ = _loc16_ = str.substr(_loc9_,p - _loc9_);
                  if(_loc5_.exists(_loc8_))
                  {
                     throw Exception.thrown(new XmlParserException("Duplicate attribute [" + _loc8_ + "]",str,p));
                  }
                  _loc6_ = 0;
                  _loc7_ = 6;
                  continue;
               case 6:
                  if(_loc15_ == 61)
                  {
                     _loc6_ = 0;
                     _loc7_ = 7;
                     break;
                  }
                  throw Exception.thrown(new XmlParserException("Expected =",str,p));
                  break;
               case 7:
                  switch(_loc15_)
                  {
                     case 34:
                     case 39:
                        _loc12_ = new StringBuf();
                        _loc6_ = 8;
                        _loc9_ = p + 1;
                        _loc14_ = _loc15_;
                        break;
                     default:
                        throw Exception.thrown(new XmlParserException("Expected \"",str,p));
                  }
                  break;
               case 8:
                  switch(_loc15_)
                  {
                     case 38:
                        _loc17_ = p - _loc9_;
                        _loc12_.b += _loc17_ == null ? str.substr(_loc9_) : str.substr(_loc9_,_loc17_);
                        _loc6_ = 18;
                        _loc13_ = 8;
                        _loc9_ = p + 1;
                        break;
                     case 60:
                     case 62:
                        if(strict)
                        {
                           throw Exception.thrown(new XmlParserException("Invalid unescaped " + (_loc15_ < 65536 ? String["fromCharCode"](_loc15_) : Boot.fromCodePoint(_loc15_)) + " in attribute value",str,p));
                        }
                        if(_loc15_ == _loc14_)
                        {
                           _loc17_ = p - _loc9_;
                           _loc12_.b += _loc17_ == null ? str.substr(_loc9_) : str.substr(_loc9_,_loc17_);
                           _loc16_ = _loc12_.b;
                           _loc12_ = new StringBuf();
                           _loc5_.set(_loc8_,_loc16_);
                           _loc6_ = 0;
                           _loc7_ = 4;
                        }
                        break;
                     default:
                        if(_loc15_ == _loc14_)
                        {
                           _loc17_ = p - _loc9_;
                           _loc12_.b += _loc17_ == null ? str.substr(_loc9_) : str.substr(_loc9_,_loc17_);
                           _loc16_ = _loc12_.b;
                           _loc12_ = new StringBuf();
                           _loc5_.set(_loc8_,_loc16_);
                           _loc6_ = 0;
                           _loc7_ = 4;
                        }
                  }
                  break;
               case 9:
                  p = Parser.doParse(str,strict,p,_loc5_);
                  _loc9_ = int(p);
                  _loc6_ = 1;
                  break;
               case 10:
                  if(_loc15_ >= 97 && _loc15_ <= 122 || _loc15_ >= 65 && _loc15_ <= 90 || _loc15_ >= 48 && _loc15_ <= 57 || _loc15_ == 58 || _loc15_ == 46 || _loc15_ == 95 || _loc15_ == 45)
                  {
                     break;
                  }
                  if(_loc9_ == p)
                  {
                     throw Exception.thrown(new XmlParserException("Expected node name",str,p));
                  }
                  _loc16_ = str.substr(_loc9_,p - _loc9_);
                  if(parent == null || parent.nodeType != 0)
                  {
                     throw Exception.thrown(new XmlParserException("Unexpected </" + _loc16_ + ">, tag is not open",str,p));
                  }
                  if(parent.nodeType != Xml.Element)
                  {
                     throw Exception.thrown("Bad node type, expected Element but found " + XmlType_Impl_.toString(parent.nodeType));
                  }
                  if(_loc16_ != parent.nodeName)
                  {
                     if(parent.nodeType != Xml.Element)
                     {
                        throw Exception.thrown("Bad node type, expected Element but found " + XmlType_Impl_.toString(parent.nodeType));
                     }
                     throw Exception.thrown(new XmlParserException("Expected </" + parent.nodeName + ">",str,p));
                  }
                  _loc6_ = 0;
                  _loc7_ = 12;
                  continue;
               case 11:
                  if(_loc15_ == 62)
                  {
                     _loc6_ = 1;
                     break;
                  }
                  throw Exception.thrown(new XmlParserException("Expected >",str,p));
                  break;
               case 12:
                  if(_loc15_ == 62)
                  {
                     if(_loc10_ == 0)
                     {
                        parent.addChild(Xml.createPCData(""));
                     }
                     return p;
                  }
                  throw Exception.thrown(new XmlParserException("Expected >",str,p));
                  break;
               case 13:
                  if(_loc15_ == 60)
                  {
                     _loc17_ = p - _loc9_;
                     _loc12_.b += _loc17_ == null ? str.substr(_loc9_) : str.substr(_loc9_,_loc17_);
                     _loc18_ = Xml.createPCData(_loc12_.b);
                     _loc12_ = new StringBuf();
                     parent.addChild(_loc18_);
                     _loc10_++;
                     _loc6_ = 0;
                     _loc7_ = 2;
                  }
                  else if(_loc15_ == 38)
                  {
                     _loc17_ = p - _loc9_;
                     _loc12_.b += _loc17_ == null ? str.substr(_loc9_) : str.substr(_loc9_,_loc17_);
                     _loc6_ = 18;
                     _loc13_ = 13;
                     _loc9_ = p + 1;
                  }
                  break;
               case 14:
                  if(_loc15_ == 63 && int(str.charCodeAt(p + 1)) == 62)
                  {
                     p++;
                     _loc16_ = str.substr(_loc9_ + 1,p - _loc9_ - 2);
                     parent.addChild(Xml.createProcessingInstruction(_loc16_));
                     _loc10_++;
                     _loc6_ = 1;
                  }
                  break;
               case 15:
                  if(_loc15_ == 45 && int(str.charCodeAt(p + 1)) == 45 && int(str.charCodeAt(p + 2)) == 62)
                  {
                     parent.addChild(Xml.createComment(str.substr(_loc9_,p - _loc9_)));
                     _loc10_++;
                     p += 2;
                     _loc6_ = 1;
                  }
                  break;
               case 16:
                  if(_loc15_ == 91)
                  {
                     _loc11_++;
                  }
                  else if(_loc15_ == 93)
                  {
                     _loc11_--;
                  }
                  else if(_loc15_ == 62 && _loc11_ == 0)
                  {
                     parent.addChild(Xml.createDocType(str.substr(_loc9_,p - _loc9_)));
                     _loc10_++;
                     _loc6_ = 1;
                  }
                  break;
               case 17:
                  if(_loc15_ == 93 && int(str.charCodeAt(p + 1)) == 93 && int(str.charCodeAt(p + 2)) == 62)
                  {
                     _loc18_ = Xml.createCData(str.substr(_loc9_,p - _loc9_));
                     parent.addChild(_loc18_);
                     _loc10_++;
                     p += 2;
                     _loc6_ = 1;
                  }
                  break;
               case 18:
                  if(_loc15_ == 59)
                  {
                     _loc16_ = str.substr(_loc9_,p - _loc9_);
                     if(int(_loc16_.charCodeAt(0)) == 35)
                     {
                        _loc19_ = _loc17_ = int(_loc16_.charCodeAt(1)) == 120 ? Std.parseInt("0" + _loc16_.substr(1,_loc16_.length - 1)) : Std.parseInt(_loc16_.substr(1,_loc16_.length - 1));
                        _loc12_.b += _loc19_ < 65536 ? String["fromCharCode"](_loc19_) : Boot.fromCodePoint(_loc19_);
                     }
                     else
                     {
                        _loc20_ = Parser.escapes;
                        if(!(_loc16_ in StringMap.reserved ? _loc20_.existsReserved(_loc16_) : _loc16_ in _loc20_.h))
                        {
                           if(strict)
                           {
                              throw Exception.thrown(new XmlParserException("Undefined entity: " + _loc16_,str,p));
                           }
                           _loc12_.b += Std.string("&" + _loc16_ + ";");
                        }
                        else
                        {
                           _loc21_ = Parser.escapes;
                           _loc22_ = _loc16_ in StringMap.reserved ? _loc21_.getReserved(_loc16_) : _loc21_.h[_loc16_];
                           _loc12_.b += Std.string(_loc22_);
                        }
                     }
                     _loc9_ = p + 1;
                     _loc6_ = _loc13_;
                     break;
                  }
                  if(!(_loc15_ >= 97 && _loc15_ <= 122 || _loc15_ >= 65 && _loc15_ <= 90 || _loc15_ >= 48 && _loc15_ <= 57 || _loc15_ == 58 || _loc15_ == 46 || _loc15_ == 95 || _loc15_ == 45) && _loc15_ != 35)
                  {
                     if(strict)
                     {
                        throw Exception.thrown(new XmlParserException("Invalid character in entity: " + (_loc15_ < 65536 ? String["fromCharCode"](_loc15_) : Boot.fromCodePoint(_loc15_)),str,p));
                     }
                     _loc12_.b += String["fromCharCode"](38);
                     _loc17_ = p - _loc9_;
                     _loc12_.b += _loc17_ == null ? str.substr(_loc9_) : str.substr(_loc9_,_loc17_);
                     _loc9_ = --p + 1;
                     _loc6_ = _loc13_;
                  }
            }
            p++;
         }
         if(_loc6_ == 1)
         {
            _loc9_ = int(p);
            _loc6_ = 13;
         }
         if(_loc6_ == 13)
         {
            if(parent.nodeType == 0)
            {
               if(parent.nodeType != Xml.Element)
               {
                  throw Exception.thrown("Bad node type, expected Element but found " + XmlType_Impl_.toString(parent.nodeType));
               }
               throw Exception.thrown(new XmlParserException("Unclosed node <" + parent.nodeName + ">",str,p));
            }
            if(p != _loc9_ || _loc10_ == 0)
            {
               _loc17_ = p - _loc9_;
               _loc12_.b += _loc17_ == null ? str.substr(_loc9_) : str.substr(_loc9_,_loc17_);
               parent.addChild(Xml.createPCData(_loc12_.b));
               _loc10_++;
            }
            return p;
         }
         if(!strict && _loc6_ == 18 && _loc13_ == 13)
         {
            _loc12_.b += String["fromCharCode"](38);
            _loc17_ = p - _loc9_;
            _loc12_.b += _loc17_ == null ? str.substr(_loc9_) : str.substr(_loc9_,_loc17_);
            parent.addChild(Xml.createPCData(_loc12_.b));
            _loc10_++;
            return p;
         }
         throw Exception.thrown(new XmlParserException("Unexpected end",str,p));
      }
      
      public static function isValidChar(c:int) : Boolean
      {
         if(!(c >= 97 && c <= 122 || c >= 65 && c <= 90 || c >= 48 && c <= 57 || c == 58 || c == 46 || c == 95))
         {
            return c == 45;
         }
         return true;
      }
   }
}

import haxe.ds.StringMap;

§§push(Parser);
new StringMap();
if("lt" in StringMap.reserved)
{
   _loc1_.setReserved("lt","<");
}
else
{
   _loc1_.h["lt"] = "<";
}
if("gt" in StringMap.reserved)
{
   _loc1_.setReserved("gt",">");
}
else
{
   _loc1_.h["gt"] = ">";
}
if("amp" in StringMap.reserved)
{
   _loc1_.setReserved("amp","&");
}
else
{
   _loc1_.h["amp"] = "&";
}
if("quot" in StringMap.reserved)
{
   _loc1_.setReserved("quot","\"");
}
else
{
   _loc1_.h["quot"] = "\"";
}
if("apos" in StringMap.reserved)
{
   _loc1_.setReserved("apos","\'");
}
else
{
   _loc1_.h["apos"] = "\'";
}

