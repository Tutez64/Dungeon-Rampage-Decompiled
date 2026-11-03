package com.junkbyte.console.core
{
   import com.junkbyte.console.Console;
   import com.junkbyte.console.compat.ConsoleLib;
   import com.junkbyte.console.utils.FlashRegex;
   import com.junkbyte.console.view.MainPanel;
   import com.junkbyte.console.view.PanelsManager;
   import com.junkbyte.console.vos.WeakObject;
   import flash.Boot;
   import flash.Lib;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.events.Event;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import haxe.Exception;
   
   public class LogReferences extends ConsoleCore
   {
      
      public static var INSPECTING_CHANNEL:String = "⌂";
      
      public var _refRev:WeakObject;
      
      public var _refIndex:uint;
      
      public var _refIds:Dictionary;
      
      public var _prevBank:Array;
      
      public var _lastWithdraw:uint;
      
      public var _history:Array;
      
      public var _hisIndex:int;
      
      public var _dofull:Boolean;
      
      public var _currentBank:Array;
      
      public var _current:*;
      
      public function LogReferences(console:Console = undefined)
      {
         var _gthis:LogReferences;
         if(!Boot.skip_constructor)
         {
            _currentBank = [];
            _prevBank = [];
            _refIndex = 1;
            _refIds = new Dictionary(true);
            _refRev = new WeakObject();
            _gthis = this;
            super(console);
            get_remoter().registerCallback("ref",function(bytes:ByteArray):void
            {
               _gthis.handleString(bytes.readUTF());
            });
            get_remoter().registerCallback("focus",handleFocused);
         }
      }
      
      public static function EscHTML(str:String) : String
      {
         str = FlashRegex.replace(str,new EReg("<","g"),"&lt;");
         str = FlashRegex.replace(str,new EReg(">","g"),"&gt;");
         return FlashRegex.replace(str,new EReg("\\x00","g"),"");
      }
      
      public static function ShortClassName(obj:*, eschtml:Boolean = true) : String
      {
         var _loc3_:String = LogReferences.getQualifiedClassName(obj);
         var _loc4_:int = _loc3_.indexOf("::");
         var _loc5_:String = Std.isOfType(obj,Class) ? "*" : "";
         _loc3_ = _loc5_ + _loc3_.substring(_loc4_ >= 0 ? _loc4_ + 2 : 0) + _loc5_;
         if(eschtml)
         {
            return LogReferences.EscHTML(_loc3_);
         }
         return _loc3_;
      }
      
      public static function getQualifiedClassName(value:*) : String
      {
         return ConsoleLib.getQualifiedClassName(value);
      }
      
      public function update(time:uint) : void
      {
         if(int(_currentBank.length) != 0 || int(_prevBank.length) != 0)
         {
            if(time > uint(_lastWithdraw + uint(config.objectHardReferenceTimer * 1000)))
            {
               _prevBank = _currentBank;
               _currentBank = [];
               _lastWithdraw = time;
            }
         }
      }
      
      public function shortenString(str:String, maxlen:int, o:*, prop:* = undefined) : String
      {
         if(maxlen >= 0 && str.length > maxlen)
         {
            str = str.substring(0,maxlen);
            return str + genLinkString(o,prop," ...");
         }
         return str;
      }
      
      public function setLogRef(o:*) : uint
      {
         var _loc3_:* = 0;
         if(!config.useObjectLinking)
         {
            return 0;
         }
         var _loc2_:uint = uint(_refIds[o]);
         if(_loc2_ == 0)
         {
            _loc2_ = _refIndex;
            _refRev.set(_loc2_,o);
            _refIds[o] = _loc2_;
            if(config.objectHardReferenceTimer != 0)
            {
               _currentBank.push(o);
            }
            ++_refIndex;
            _loc3_ = int(uint(_loc2_ - 50));
            while(_loc3_ >= 0)
            {
               if(!_refRev.exists(_loc3_))
               {
                  _refRev.remove(_loc3_);
               }
               _loc3_ -= 50;
            }
         }
         return _loc2_;
      }
      
      public function makeValue(obj:*, prop:* = undefined) : String
      {
         return makeString(obj,prop,false,config.useObjectLinking ? 100 : -1);
      }
      
      public function makeString(o:*, prop:* = undefined, html:Boolean = false, maxlen:int = -1) : String
      {
         var _loc8_:* = null;
         var _loc9_:* = null;
         var _loc10_:* = null as Error;
         var _loc11_:* = null as String;
         var _loc12_:int = 0;
         var _loc13_:Boolean = false;
         var _loc14_:int = 0;
         var _loc15_:int = 0;
         var _loc16_:int = 0;
         var _loc17_:* = null as String;
         var _loc6_:String = null;
         var _loc7_:* = null;
         try
         {
            _loc7_ = ConsoleLib.truthy(prop) ? o[prop] : o;
         }
         catch(_loc_e_:*)
         {
            _loc8_ = _loc_e_;
            null;
            _loc9_ = Exception.caught(_loc8_).unwrap();
            return "<p0><i>" + ConsoleLib.string(_loc9_) + "</i></p0>";
         }
         if(_loc7_ is Error)
         {
            _loc10_ = _loc7_;
            _loc11_ = _loc10_.getStackTrace();
            if(_loc11_ != null && _loc11_ != "")
            {
               return _loc11_;
            }
            return ConsoleLib.string(_loc10_);
         }
         if(_loc7_ is XML || _loc7_ is XMLList)
         {
            return shortenString(LogReferences.EscHTML(_loc7_.toXMLString()),maxlen,o,prop);
         }
         if(_loc7_ is QName)
         {
            return ConsoleLib.string(_loc7_);
         }
         if(_loc7_ is Array || LogReferences.getQualifiedClassName(_loc7_).indexOf("__AS3__.vec::Vector.") == 0)
         {
            _loc11_ = "[";
            _loc12_ = _loc7_.length;
            _loc13_ = maxlen >= 0;
            _loc14_ = 0;
            _loc15_ = _loc12_;
            while(_loc14_ < _loc15_)
            {
               _loc16_ = _loc14_++;
               _loc17_ = makeString(_loc7_[_loc16_],null,false,maxlen);
               _loc11_ += (_loc16_ != 0 ? ", " : "") + _loc17_;
               maxlen -= _loc17_.length;
               if(_loc13_ && maxlen <= 0 && _loc16_ < _loc12_ - 1)
               {
                  _loc11_ += ", " + genLinkString(o,prop,"...");
                  break;
               }
            }
            return _loc11_ + "]";
         }
         if(config.useObjectLinking && ConsoleLib.truthy(_loc7_) && ConsoleLib.typeOf(_loc7_) == "object")
         {
            _loc11_ = "";
            if(_loc7_ is ByteArray)
            {
               _loc11_ = " position:" + Std.string(_loc7_.position) + " length:" + Std.string(_loc7_.length);
            }
            else if(_loc7_ is Date || _loc7_ is Rectangle || _loc7_ is Point || _loc7_ is Matrix || _loc7_ is Event)
            {
               _loc11_ = " " + ConsoleLib.string(_loc7_);
            }
            else if(_loc7_ is DisplayObject && ConsoleLib.truthy(_loc7_.name))
            {
               _loc11_ = " " + Std.string(_loc7_.name);
            }
            _loc6_ = "{" + genLinkString(o,prop,LogReferences.ShortClassName(_loc7_)) + LogReferences.EscHTML(_loc11_) + "}";
         }
         else
         {
            if(_loc7_ is ByteArray)
            {
               _loc6_ = "[ByteArray position:" + Std.string(_loc7_.position) + " length:" + Std.string(_loc7_.length) + "]";
            }
            else
            {
               _loc6_ = ConsoleLib.string(_loc7_);
            }
            if(!html)
            {
               return shortenString(LogReferences.EscHTML(_loc6_),maxlen,o,prop);
            }
         }
         return _loc6_;
      }
      
      public function makeRefTyped(v:*) : String
      {
         if(ConsoleLib.truthy(v) && ConsoleLib.typeOf(v) == "object" && !(v is QName))
         {
            return "{" + genLinkString(v,null,LogReferences.ShortClassName(v)) + "}";
         }
         return LogReferences.ShortClassName(v);
      }
      
      public function inspect(obj:*, viewAll:Boolean = true, ch:String = undefined) : void
      {
         var _loc17_:* = 0;
         var _loc18_:int = 0;
         var _loc19_:int = 0;
         var _loc20_:* = null as XML;
         var _loc21_:* = null as XMLList;
         var _loc22_:* = null as String;
         var _loc23_:* = null as String;
         var _loc24_:int = 0;
         var _loc25_:int = 0;
         var _loc26_:int = 0;
         var _loc27_:* = null as String;
         var _loc28_:* = null as DisplayObject;
         var _loc29_:* = null as DisplayObjectContainer;
         var _loc30_:* = null as DisplayObjectContainer;
         var _loc33_:Boolean = false;
         var _loc34_:* = null as Array;
         var _loc35_:* = null as XML;
         var _loc36_:* = null as Array;
         var _loc37_:* = null;
         var _loc38_:* = null;
         if(!ConsoleLib.truthy(obj))
         {
            report(obj,-2,true,ch);
            return;
         }
         var _loc5_:uint = setLogRef(obj);
         var _loc6_:String = "";
         if(!viewAll)
         {
            _loc6_ = " [<a href=\'event:refi\'>show inherited</a>]";
         }
         var _loc7_:String = null;
         if(_history != null)
         {
            _loc7_ = "<b>[<a href=\'event:refexit\'>exit</a>]";
            if(_hisIndex > 1)
            {
               _loc7_ += " [<a href=\'event:refprev\'>previous</a>]";
            }
            if(_history != null && _hisIndex < int(_history.length))
            {
               _loc7_ += " [<a href=\'event:reffwd\'>forward</a>]";
            }
            _loc7_ += "</b> || [<a href=\'event:ref_" + ("" + _loc5_) + "\'>refresh</a>]";
            _loc7_ = _loc7_ + ("</b> [<a href=\'event:refe_" + ("" + _loc5_) + "\'>explode</a>]");
            if(config.commandLineAllowed)
            {
               _loc7_ += " [<a href=\'event:cl_" + ("" + _loc5_) + "\'>scope</a>]";
            }
            if(viewAll)
            {
               _loc7_ += " [<a href=\'event:refi\'>hide inherited</a>]";
            }
            else
            {
               _loc7_ += _loc6_;
            }
            report(_loc7_,-1,true,ch);
            report("",1,true,ch);
         }
         var _loc8_:XML = Lib.describeType(obj);
         var _loc9_:Boolean = Std.isOfType(obj,Class);
         var _loc10_:* = _loc9_ ? obj : obj.constructor;
         var _loc11_:XML = Lib.describeType(_loc10_);
         var _loc12_:String = _loc8_.attribute("name").toString();
         var _loc13_:String = _loc9_ ? "*" : "";
         var _loc14_:String = "<b>{" + _loc13_ + genLinkString(obj,null,LogReferences.EscHTML(_loc12_)) + _loc13_ + "}</b>";
         var _loc15_:Array = [];
         if(_loc8_.attribute("isStatic").toString() == "true")
         {
            _loc15_.push("<b>static</b>");
         }
         if(_loc8_.attribute("isDynamic").toString() == "true")
         {
            _loc15_.push("dynamic");
         }
         if(_loc8_.attribute("isFinal").toString() == "true")
         {
            _loc15_.push("final");
         }
         if(int(_loc15_.length) > 0)
         {
            _loc14_ += " <p-1>" + _loc15_.join(" | ") + "</p-1>";
         }
         report(_loc14_,-2,true,ch);
         var _loc16_:XMLList = _loc8_.child("extendsClass");
         if(_loc16_.length() != 0)
         {
            _loc15_ = [];
            _loc17_ = 0;
            _loc18_ = _loc16_.length();
            while(_loc17_ < _loc18_)
            {
               _loc19_ = _loc17_++;
               _loc13_ = _loc16_[_loc19_].attribute("type").toString();
               _loc15_.push(_loc13_.indexOf("*") < 0 ? makeValue(ConsoleLib.getDefinitionByName(_loc13_)) : LogReferences.EscHTML(_loc13_));
               if(!viewAll)
               {
                  break;
               }
            }
            report("<p10>Extends:</p10> " + _loc15_.join(" &gt; "),1,true,ch);
         }
         _loc16_ = _loc8_.child("implementsInterface");
         if(_loc16_.length() != 0)
         {
            _loc15_ = [];
            _loc17_ = 0;
            _loc18_ = _loc16_.length();
            while(_loc17_ < _loc18_)
            {
               _loc19_ = _loc17_++;
               _loc15_.push(makeValue(ConsoleLib.getDefinitionByName(_loc16_[_loc19_].attribute("type").toString())));
            }
            report("<p10>Implements:</p10> " + _loc15_.join(", "),1,true,ch);
         }
         report("",1,true,ch);
         _loc15_ = [];
         _loc16_ = _loc8_.child("metadata");
         _loc17_ = 0;
         _loc18_ = _loc16_.length();
         while(_loc17_ < _loc18_)
         {
            _loc19_ = _loc17_++;
            _loc20_ = _loc16_[_loc19_];
            if(_loc20_.attribute("name").toString() == "Event")
            {
               _loc21_ = _loc20_.child("arg");
               _loc22_ = "";
               _loc23_ = "";
               _loc24_ = 0;
               _loc25_ = _loc21_.length();
               while(_loc24_ < _loc25_)
               {
                  _loc26_ = _loc24_++;
                  _loc27_ = _loc21_[_loc26_].attribute("key").toString();
                  if(_loc27_ == "name")
                  {
                     _loc22_ += _loc21_[_loc26_].attribute("value").toString();
                  }
                  else if(_loc27_ == "type")
                  {
                     _loc23_ += _loc21_[_loc26_].attribute("value").toString();
                  }
               }
               if(_loc5_ != 0)
               {
                  _loc15_.push("<a href=\'event:cl_" + ("" + _loc5_) + "_dispatchEvent(new " + _loc23_ + "(\"" + _loc22_ + "\"))\'>" + _loc22_ + "</a><p0>(" + _loc23_ + ")</p0>");
               }
               else
               {
                  _loc15_.push(_loc22_ + "<p0>(" + _loc23_ + ")</p0>");
               }
            }
         }
         if(int(_loc15_.length) != 0)
         {
            report("<p10>Events:</p10> " + _loc15_.join("<p-1>; </p-1>"),1,true,ch);
            report("",1,true,ch);
         }
         if(obj is DisplayObject)
         {
            _loc28_ = obj;
            _loc29_ = _loc28_.parent;
            if(_loc29_ != null)
            {
               _loc15_ = ["@" + _loc29_.getChildIndex(_loc28_)];
               while(_loc29_ != null)
               {
                  _loc30_ = _loc29_;
                  _loc29_ = _loc29_.parent;
                  _loc22_ = _loc29_ != null ? "@" + _loc29_.getChildIndex(_loc30_) : "";
                  _loc15_.push("<b>" + _loc30_.name + "</b>" + _loc22_ + makeValue(_loc30_));
               }
               report("<p10>Parents:</p10> " + _loc15_.join("<p-1> -> </p-1>") + "<br/>",1,true,ch);
            }
         }
         if(obj is DisplayObjectContainer)
         {
            _loc15_ = [];
            _loc29_ = obj;
            _loc17_ = _loc29_.numChildren;
            _loc18_ = 0;
            _loc19_ = _loc17_;
            while(_loc18_ < _loc19_)
            {
               _loc24_ = _loc18_++;
               _loc28_ = _loc29_.getChildAt(_loc24_);
               _loc15_.push("<b>" + _loc28_.name + "</b>@" + _loc24_ + makeValue(_loc28_));
            }
            if(_loc17_ != 0)
            {
               report("<p10>Children:</p10> " + _loc15_.join("<p-1>; </p-1>") + "<br/>",1,true,ch);
            }
         }
         _loc16_ = _loc11_.descendants("constant");
         _loc17_ = 0;
         _loc18_ = _loc16_.length();
         while(_loc17_ < _loc18_)
         {
            _loc19_ = _loc17_++;
            _loc20_ = _loc16_[_loc19_];
            _loc22_ = _loc20_.attribute("name").toString();
            report(" const <p3>" + _loc22_ + "</p3>:" + _loc20_.attribute("type").toString() + " = " + makeValue(_loc10_,_loc22_) + "</p0>",1,true,ch);
         }
         if(_loc16_.length() != 0)
         {
            report("",1,true,ch);
         }
         var _loc31_:uint = 0;
         var _loc32_:Boolean = false;
         _loc16_ = _loc11_.descendants("method");
         _loc17_ = 0;
         _loc18_ = _loc16_.length();
         while(_loc17_ < _loc18_)
         {
            _loc19_ = _loc17_++;
            _loc20_ = _loc16_[_loc19_];
            if(viewAll || _loc12_ == _loc20_.attribute("declaredBy").toString())
            {
               _loc32_ = true;
               _loc33_ = ConsoleLib.string(_loc20_.parent().name()) != "factory";
               _loc14_ = " " + (_loc33_ ? "static " : "") + "function ";
               _loc34_ = [];
               _loc21_ = _loc20_.child("parameter");
               _loc24_ = 0;
               _loc25_ = _loc21_.length();
               while(_loc24_ < _loc25_)
               {
                  _loc26_ = _loc24_++;
                  _loc35_ = _loc21_[_loc26_];
                  _loc22_ = _loc35_.attribute("type").toString();
                  _loc34_.push(_loc35_.attribute("optional").toString() == "true" ? "<i>" + _loc22_ + "</i>" : _loc22_);
               }
               _loc22_ = _loc20_.attribute("name").toString();
               if(_loc5_ != 0 && (_loc33_ || !_loc9_))
               {
                  _loc14_ += "<a href=\'event:cl_" + ("" + _loc5_) + "_" + _loc22_ + "()\'><p3>" + _loc22_ + "</p3></a>";
               }
               else
               {
                  _loc14_ += "<p3>" + _loc22_ + "</p3>";
               }
               _loc14_ += "(" + _loc34_.join(", ") + "):" + _loc20_.attribute("returnType").toString();
               report(_loc14_,1,true,ch);
            }
            else
            {
               _loc31_ += 1;
            }
         }
         if(_loc31_ != 0)
         {
            report("   \t + " + ("" + _loc31_) + " inherited methods." + _loc6_,1,true,ch);
         }
         else if(_loc32_)
         {
            report("",1,true,ch);
         }
         _loc32_ = false;
         _loc31_ = 0;
         _loc16_ = _loc11_.descendants("accessor");
         _loc17_ = 0;
         _loc18_ = _loc16_.length();
         while(_loc17_ < _loc18_)
         {
            _loc19_ = _loc17_++;
            _loc20_ = _loc16_[_loc19_];
            if(viewAll || _loc12_ == _loc20_.attribute("declaredBy").toString())
            {
               _loc32_ = true;
               _loc33_ = ConsoleLib.string(_loc20_.parent().name()) != "factory";
               _loc14_ = " ";
               if(_loc33_)
               {
                  _loc14_ += "static ";
               }
               _loc22_ = _loc20_.attribute("access").toString();
               if(_loc22_ == "readonly")
               {
                  _loc14_ += "get";
               }
               else if(_loc22_ == "writeonly")
               {
                  _loc14_ += "set";
               }
               else
               {
                  _loc14_ += "assign";
               }
               _loc23_ = _loc20_.attribute("name").toString();
               _loc27_ = _loc20_.attribute("type").toString();
               if(_loc5_ != 0 && (_loc33_ || !_loc9_))
               {
                  _loc14_ += " <a href=\'event:cl_" + ("" + _loc5_) + "_" + _loc23_ + "\'><p3>" + _loc23_ + "</p3></a>:" + _loc27_;
               }
               else
               {
                  _loc14_ += " <p3>" + _loc23_ + "</p3>:" + _loc27_;
               }
               if(_loc22_ != "writeonly" && (_loc33_ || !_loc9_))
               {
                  _loc14_ += " = " + makeValue(_loc33_ ? _loc10_ : obj,_loc23_);
               }
               report(_loc14_,1,true,ch);
            }
            else
            {
               _loc31_ += 1;
            }
         }
         if(_loc31_ != 0)
         {
            report("   \t + " + ("" + _loc31_) + " inherited accessors." + _loc6_,1,true,ch);
         }
         else if(_loc32_)
         {
            report("",1,true,ch);
         }
         _loc16_ = _loc11_.descendants("variable");
         _loc17_ = 0;
         _loc18_ = _loc16_.length();
         while(_loc17_ < _loc18_)
         {
            _loc19_ = _loc17_++;
            _loc20_ = _loc16_[_loc19_];
            _loc33_ = ConsoleLib.string(_loc20_.parent().name()) != "factory";
            _loc14_ = _loc33_ ? " static" : "";
            _loc22_ = _loc20_.attribute("name").toString();
            if(_loc5_ != 0)
            {
               _loc14_ += " var <p3><a href=\'event:cl_" + ("" + _loc5_) + "_" + _loc22_ + " = \'>" + _loc22_ + "</a>";
            }
            else
            {
               _loc14_ += " var <p3>" + _loc22_;
            }
            _loc14_ += "</p3>:" + _loc20_.attribute("type").toString() + " = " + makeValue(_loc33_ ? _loc10_ : obj,_loc22_);
            report(_loc14_,1,true,ch);
         }
         try
         {
            _loc17_ = 0;
            _loc36_ = [];
            _loc37_ = obj;
            for(_loc17_ in _loc37_)
            {
               _loc36_.push(_loc17_);
            }
            _loc34_ = _loc36_;
            _loc17_ = 0;
            while(_loc17_ < int(_loc34_.length))
            {
               _loc37_ = _loc34_[_loc17_];
               _loc17_++;
               if(_loc37_ is String)
               {
                  if(_loc5_ != 0)
                  {
                     _loc14_ = "<a href=\'event:cl_" + ("" + _loc5_) + "_" + Std.string(_loc37_) + " = \'>" + Std.string(_loc37_) + "</a>";
                  }
                  else
                  {
                     _loc14_ = _loc37_;
                  }
                  report(" dynamic var <p3>" + _loc14_ + "</p3> = " + makeValue(obj,_loc37_),1,true,ch);
               }
               else
               {
                  report(" dictionary <p3>" + makeValue(_loc37_) + "</p3> = " + makeValue(obj,_loc37_),1,true,ch);
               }
            }
         }
         catch(_loc_e_:*)
         {
            _loc37_ = _loc_e_;
            null;
            _loc38_ = Exception.caught(_loc37_).unwrap();
            report("Could not get dynamic values. " + ConsoleLib.string(_loc38_.message),9,false,ch);
         }
         if(obj is String)
         {
            report("",1,true,ch);
            report("String",10,true,ch);
            report(LogReferences.EscHTML(obj),1,true,ch);
         }
         else if(obj is XML || obj is XMLList)
         {
            report("",1,true,ch);
            report("XMLString",10,true,ch);
            report(LogReferences.EscHTML(obj.toXMLString()),1,true,ch);
         }
         if(_loc7_ != null)
         {
            report("",1,true,ch);
            report(_loc7_,-1,true,ch);
         }
      }
      
      public function historyInc(i:int) : void
      {
         _hisIndex += i;
         var _loc2_:* = _history[_hisIndex];
         if(_loc2_)
         {
            focus(_loc2_,_dofull);
         }
      }
      
      public function handleString(str:String) : void
      {
         var _loc2_:* = 0;
         var _loc3_:uint = 0;
         var _loc4_:* = null as String;
         var _loc5_:int = 0;
         var _loc6_:* = null;
         if(str == "refexit")
         {
            exitFocus();
            if(int([].length) == 0)
            {
               console.setViewingChannels();
            }
            else if(int([].length) == 1)
            {
               console.setViewingChannels([][0]);
            }
            else if(int([].length) == 2)
            {
               console.setViewingChannels([][0],[][1]);
            }
            else if(int([].length) == 3)
            {
               console.setViewingChannels([][0],[][1],[][2]);
            }
            else if(int([].length) == 4)
            {
               console.setViewingChannels([][0],[][1],[][2],[][3]);
            }
            else if(int([].length) == 5)
            {
               console.setViewingChannels([][0],[][1],[][2],[][3],[][4]);
            }
            else if(int([].length) == 6)
            {
               console.setViewingChannels([][0],[][1],[][2],[][3],[][4],[][5]);
            }
            else if(int([].length) == 7)
            {
               console.setViewingChannels([][0],[][1],[][2],[][3],[][4],[][5],[][6]);
            }
            else if(int([].length) == 8)
            {
               console.setViewingChannels([][0],[][1],[][2],[][3],[][4],[][5],[][6],[][7]);
            }
            else if(int([].length) == 9)
            {
               console.setViewingChannels([][0],[][1],[][2],[][3],[][4],[][5],[][6],[][7],[][8]);
            }
            else if(int([].length) == 10)
            {
               console.setViewingChannels([][0],[][1],[][2],[][3],[][4],[][5],[][6],[][7],[][8],[][9]);
            }
            else if(int([].length) == 11)
            {
               console.setViewingChannels([][0],[][1],[][2],[][3],[][4],[][5],[][6],[][7],[][8],[][9],[][10]);
            }
            else if(int([].length) == 12)
            {
               console.setViewingChannels([][0],[][1],[][2],[][3],[][4],[][5],[][6],[][7],[][8],[][9],[][10],[][11]);
            }
            else if(int([].length) == 13)
            {
               console.setViewingChannels([][0],[][1],[][2],[][3],[][4],[][5],[][6],[][7],[][8],[][9],[][10],[][11],[][12]);
            }
            else if(int([].length) == 14)
            {
               console.setViewingChannels([][0],[][1],[][2],[][3],[][4],[][5],[][6],[][7],[][8],[][9],[][10],[][11],[][12],[][13]);
            }
            else if(int([].length) == 15)
            {
               console.setViewingChannels([][0],[][1],[][2],[][3],[][4],[][5],[][6],[][7],[][8],[][9],[][10],[][11],[][12],[][13],[][14]);
            }
            else if(int([].length) == 16)
            {
               console.setViewingChannels([][0],[][1],[][2],[][3],[][4],[][5],[][6],[][7],[][8],[][9],[][10],[][11],[][12],[][13],[][14],[][15]);
            }
            else if(int([].length) == 17)
            {
               console.setViewingChannels([][0],[][1],[][2],[][3],[][4],[][5],[][6],[][7],[][8],[][9],[][10],[][11],[][12],[][13],[][14],[][15],[][16]);
            }
            else if(int([].length) == 18)
            {
               console.setViewingChannels([][0],[][1],[][2],[][3],[][4],[][5],[][6],[][7],[][8],[][9],[][10],[][11],[][12],[][13],[][14],[][15],[][16],[][17]);
            }
            else if(int([].length) == 19)
            {
               console.setViewingChannels([][0],[][1],[][2],[][3],[][4],[][5],[][6],[][7],[][8],[][9],[][10],[][11],[][12],[][13],[][14],[][15],[][16],[][17],[][18]);
            }
            else
            {
               if(int([].length) != 20)
               {
                  throw "Too many rest arguments";
               }
               console.setViewingChannels([][0],[][1],[][2],[][3],[][4],[][5],[][6],[][7],[][8],[][9],[][10],[][11],[][12],[][13],[][14],[][15],[][16],[][17],[][18],[][19]);
            }
         }
         else if(str == "refprev")
         {
            historyInc(-2);
         }
         else if(str == "reffwd")
         {
            historyInc(0);
         }
         else if(str == "refi")
         {
            focus(_current,!_dofull);
         }
         else
         {
            _loc2_ = str.indexOf("_") + 1;
            if(_loc2_ > 0)
            {
               _loc4_ = null;
               _loc5_ = str.indexOf("_",_loc2_);
               if(_loc5_ > 0)
               {
                  _loc3_ = uint(ConsoleLib.parseInt(str.substring(_loc2_,_loc5_)));
                  _loc4_ = str.substring(_loc5_ + 1);
               }
               else
               {
                  _loc3_ = uint(ConsoleLib.parseInt(str.substring(_loc2_)));
               }
               _loc6_ = getRefById(_loc3_);
               if(_loc4_ != null)
               {
                  _loc6_ = Reflect.field(_loc6_,_loc4_);
               }
               if(_loc6_ != null)
               {
                  if(str.indexOf("refe_") == 0)
                  {
                     console.explodech(console.get_panels().get_mainPanel().get_reportChannel(),_loc6_);
                  }
                  else
                  {
                     focus(_loc6_,_dofull);
                  }
                  return;
               }
            }
            report("Reference no longer exist (garbage collected).",-2);
         }
      }
      
      public function handleRefEvent(str:String) : void
      {
         var _loc2_:* = null as ByteArray;
         if(get_remoter().get_remoting() == 2)
         {
            _loc2_ = new ByteArray();
            _loc2_.writeUTF(str);
            get_remoter().send("ref",_loc2_);
         }
         else
         {
            handleString(str);
         }
      }
      
      public function handleFocused() : void
      {
         console.clear("⌂");
         if(int(["⌂"].length) == 0)
         {
            console.setViewingChannels();
         }
         else if(int(["⌂"].length) == 1)
         {
            console.setViewingChannels(["⌂"][0]);
         }
         else if(int(["⌂"].length) == 2)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1]);
         }
         else if(int(["⌂"].length) == 3)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2]);
         }
         else if(int(["⌂"].length) == 4)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3]);
         }
         else if(int(["⌂"].length) == 5)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4]);
         }
         else if(int(["⌂"].length) == 6)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4],["⌂"][5]);
         }
         else if(int(["⌂"].length) == 7)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4],["⌂"][5],["⌂"][6]);
         }
         else if(int(["⌂"].length) == 8)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4],["⌂"][5],["⌂"][6],["⌂"][7]);
         }
         else if(int(["⌂"].length) == 9)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4],["⌂"][5],["⌂"][6],["⌂"][7],["⌂"][8]);
         }
         else if(int(["⌂"].length) == 10)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4],["⌂"][5],["⌂"][6],["⌂"][7],["⌂"][8],["⌂"][9]);
         }
         else if(int(["⌂"].length) == 11)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4],["⌂"][5],["⌂"][6],["⌂"][7],["⌂"][8],["⌂"][9],["⌂"][10]);
         }
         else if(int(["⌂"].length) == 12)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4],["⌂"][5],["⌂"][6],["⌂"][7],["⌂"][8],["⌂"][9],["⌂"][10],["⌂"][11]);
         }
         else if(int(["⌂"].length) == 13)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4],["⌂"][5],["⌂"][6],["⌂"][7],["⌂"][8],["⌂"][9],["⌂"][10],["⌂"][11],["⌂"][12]);
         }
         else if(int(["⌂"].length) == 14)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4],["⌂"][5],["⌂"][6],["⌂"][7],["⌂"][8],["⌂"][9],["⌂"][10],["⌂"][11],["⌂"][12],["⌂"][13]);
         }
         else if(int(["⌂"].length) == 15)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4],["⌂"][5],["⌂"][6],["⌂"][7],["⌂"][8],["⌂"][9],["⌂"][10],["⌂"][11],["⌂"][12],["⌂"][13],["⌂"][14]);
         }
         else if(int(["⌂"].length) == 16)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4],["⌂"][5],["⌂"][6],["⌂"][7],["⌂"][8],["⌂"][9],["⌂"][10],["⌂"][11],["⌂"][12],["⌂"][13],["⌂"][14],["⌂"][15]);
         }
         else if(int(["⌂"].length) == 17)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4],["⌂"][5],["⌂"][6],["⌂"][7],["⌂"][8],["⌂"][9],["⌂"][10],["⌂"][11],["⌂"][12],["⌂"][13],["⌂"][14],["⌂"][15],["⌂"][16]);
         }
         else if(int(["⌂"].length) == 18)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4],["⌂"][5],["⌂"][6],["⌂"][7],["⌂"][8],["⌂"][9],["⌂"][10],["⌂"][11],["⌂"][12],["⌂"][13],["⌂"][14],["⌂"][15],["⌂"][16],["⌂"][17]);
         }
         else if(int(["⌂"].length) == 19)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4],["⌂"][5],["⌂"][6],["⌂"][7],["⌂"][8],["⌂"][9],["⌂"][10],["⌂"][11],["⌂"][12],["⌂"][13],["⌂"][14],["⌂"][15],["⌂"][16],["⌂"][17],["⌂"][18]);
         }
         else
         {
            if(int(["⌂"].length) != 20)
            {
               throw "Too many rest arguments";
            }
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4],["⌂"][5],["⌂"][6],["⌂"][7],["⌂"][8],["⌂"][9],["⌂"][10],["⌂"][11],["⌂"][12],["⌂"][13],["⌂"][14],["⌂"][15],["⌂"][16],["⌂"][17],["⌂"][18],["⌂"][19]);
         }
      }
      
      public function getRefById(o:*) : *
      {
         return _refRev.get(o);
      }
      
      public function getPossibleCalls(obj:*) : Array
      {
         var _loc7_:int = 0;
         var _loc8_:* = null as XML;
         var _loc9_:* = null as Array;
         var _loc10_:* = null as XMLList;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:* = null as XML;
         var _loc15_:* = null as String;
         var _loc2_:Array = [];
         var _loc3_:XML = Lib.describeType(obj);
         var _loc4_:XMLList = _loc3_.child("method");
         var _loc5_:int = 0;
         var _loc6_:int = _loc4_.length();
         while(_loc5_ < _loc6_)
         {
            _loc7_ = _loc5_++;
            _loc8_ = _loc4_[_loc7_];
            _loc9_ = [];
            _loc10_ = _loc8_.child("parameter");
            _loc11_ = 0;
            _loc12_ = _loc10_.length();
            while(_loc11_ < _loc12_)
            {
               _loc13_ = _loc11_++;
               _loc14_ = _loc10_[_loc13_];
               _loc15_ = _loc14_.attribute("type").toString();
               _loc9_.push(_loc14_.attribute("optional").toString() == "true" ? "<i>" + _loc15_ + "</i>" : _loc15_);
            }
            _loc2_.push([_loc8_.attribute("name").toString() + "(",_loc9_.join(", ") + " ):" + _loc8_.attribute("returnType").toString()]);
         }
         _loc4_ = _loc3_.child("accessor");
         _loc5_ = 0;
         _loc6_ = _loc4_.length();
         while(_loc5_ < _loc6_)
         {
            _loc7_ = _loc5_++;
            _loc2_.push([_loc4_[_loc7_].attribute("name").toString(),_loc4_[_loc7_].attribute("type").toString()]);
         }
         _loc4_ = _loc3_.child("variable");
         _loc5_ = 0;
         _loc6_ = _loc4_.length();
         while(_loc5_ < _loc6_)
         {
            _loc7_ = _loc5_++;
            _loc2_.push([_loc4_[_loc7_].attribute("name").toString(),_loc4_[_loc7_].attribute("type").toString()]);
         }
         return _loc2_;
      }
      
      public function genLinkString(o:*, prop:*, str:String) : String
      {
         if(ConsoleLib.truthy(prop) && !(prop is String))
         {
            o = o[prop];
            prop = null;
         }
         var _loc4_:uint = setLogRef(o);
         if(_loc4_ != 0)
         {
            return "<menu><a href=\'event:ref_" + ("" + _loc4_) + (prop ? "_" + Std.string(prop) : "") + "\'>" + str + "</a></menu>";
         }
         return str;
      }
      
      public function focus(o:*, full:Boolean = false) : void
      {
         get_remoter().send("focus");
         console.clear("⌂");
         if(int(["⌂"].length) == 0)
         {
            console.setViewingChannels();
         }
         else if(int(["⌂"].length) == 1)
         {
            console.setViewingChannels(["⌂"][0]);
         }
         else if(int(["⌂"].length) == 2)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1]);
         }
         else if(int(["⌂"].length) == 3)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2]);
         }
         else if(int(["⌂"].length) == 4)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3]);
         }
         else if(int(["⌂"].length) == 5)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4]);
         }
         else if(int(["⌂"].length) == 6)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4],["⌂"][5]);
         }
         else if(int(["⌂"].length) == 7)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4],["⌂"][5],["⌂"][6]);
         }
         else if(int(["⌂"].length) == 8)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4],["⌂"][5],["⌂"][6],["⌂"][7]);
         }
         else if(int(["⌂"].length) == 9)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4],["⌂"][5],["⌂"][6],["⌂"][7],["⌂"][8]);
         }
         else if(int(["⌂"].length) == 10)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4],["⌂"][5],["⌂"][6],["⌂"][7],["⌂"][8],["⌂"][9]);
         }
         else if(int(["⌂"].length) == 11)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4],["⌂"][5],["⌂"][6],["⌂"][7],["⌂"][8],["⌂"][9],["⌂"][10]);
         }
         else if(int(["⌂"].length) == 12)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4],["⌂"][5],["⌂"][6],["⌂"][7],["⌂"][8],["⌂"][9],["⌂"][10],["⌂"][11]);
         }
         else if(int(["⌂"].length) == 13)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4],["⌂"][5],["⌂"][6],["⌂"][7],["⌂"][8],["⌂"][9],["⌂"][10],["⌂"][11],["⌂"][12]);
         }
         else if(int(["⌂"].length) == 14)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4],["⌂"][5],["⌂"][6],["⌂"][7],["⌂"][8],["⌂"][9],["⌂"][10],["⌂"][11],["⌂"][12],["⌂"][13]);
         }
         else if(int(["⌂"].length) == 15)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4],["⌂"][5],["⌂"][6],["⌂"][7],["⌂"][8],["⌂"][9],["⌂"][10],["⌂"][11],["⌂"][12],["⌂"][13],["⌂"][14]);
         }
         else if(int(["⌂"].length) == 16)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4],["⌂"][5],["⌂"][6],["⌂"][7],["⌂"][8],["⌂"][9],["⌂"][10],["⌂"][11],["⌂"][12],["⌂"][13],["⌂"][14],["⌂"][15]);
         }
         else if(int(["⌂"].length) == 17)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4],["⌂"][5],["⌂"][6],["⌂"][7],["⌂"][8],["⌂"][9],["⌂"][10],["⌂"][11],["⌂"][12],["⌂"][13],["⌂"][14],["⌂"][15],["⌂"][16]);
         }
         else if(int(["⌂"].length) == 18)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4],["⌂"][5],["⌂"][6],["⌂"][7],["⌂"][8],["⌂"][9],["⌂"][10],["⌂"][11],["⌂"][12],["⌂"][13],["⌂"][14],["⌂"][15],["⌂"][16],["⌂"][17]);
         }
         else if(int(["⌂"].length) == 19)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4],["⌂"][5],["⌂"][6],["⌂"][7],["⌂"][8],["⌂"][9],["⌂"][10],["⌂"][11],["⌂"][12],["⌂"][13],["⌂"][14],["⌂"][15],["⌂"][16],["⌂"][17],["⌂"][18]);
         }
         else
         {
            if(int(["⌂"].length) != 20)
            {
               throw "Too many rest arguments";
            }
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4],["⌂"][5],["⌂"][6],["⌂"][7],["⌂"][8],["⌂"][9],["⌂"][10],["⌂"][11],["⌂"][12],["⌂"][13],["⌂"][14],["⌂"][15],["⌂"][16],["⌂"][17],["⌂"][18],["⌂"][19]);
         }
         if(int(["⌂"].length) == 0)
         {
            console.setViewingChannels();
         }
         else if(int(["⌂"].length) == 1)
         {
            console.setViewingChannels(["⌂"][0]);
         }
         else if(int(["⌂"].length) == 2)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1]);
         }
         else if(int(["⌂"].length) == 3)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2]);
         }
         else if(int(["⌂"].length) == 4)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3]);
         }
         else if(int(["⌂"].length) == 5)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4]);
         }
         else if(int(["⌂"].length) == 6)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4],["⌂"][5]);
         }
         else if(int(["⌂"].length) == 7)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4],["⌂"][5],["⌂"][6]);
         }
         else if(int(["⌂"].length) == 8)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4],["⌂"][5],["⌂"][6],["⌂"][7]);
         }
         else if(int(["⌂"].length) == 9)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4],["⌂"][5],["⌂"][6],["⌂"][7],["⌂"][8]);
         }
         else if(int(["⌂"].length) == 10)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4],["⌂"][5],["⌂"][6],["⌂"][7],["⌂"][8],["⌂"][9]);
         }
         else if(int(["⌂"].length) == 11)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4],["⌂"][5],["⌂"][6],["⌂"][7],["⌂"][8],["⌂"][9],["⌂"][10]);
         }
         else if(int(["⌂"].length) == 12)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4],["⌂"][5],["⌂"][6],["⌂"][7],["⌂"][8],["⌂"][9],["⌂"][10],["⌂"][11]);
         }
         else if(int(["⌂"].length) == 13)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4],["⌂"][5],["⌂"][6],["⌂"][7],["⌂"][8],["⌂"][9],["⌂"][10],["⌂"][11],["⌂"][12]);
         }
         else if(int(["⌂"].length) == 14)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4],["⌂"][5],["⌂"][6],["⌂"][7],["⌂"][8],["⌂"][9],["⌂"][10],["⌂"][11],["⌂"][12],["⌂"][13]);
         }
         else if(int(["⌂"].length) == 15)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4],["⌂"][5],["⌂"][6],["⌂"][7],["⌂"][8],["⌂"][9],["⌂"][10],["⌂"][11],["⌂"][12],["⌂"][13],["⌂"][14]);
         }
         else if(int(["⌂"].length) == 16)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4],["⌂"][5],["⌂"][6],["⌂"][7],["⌂"][8],["⌂"][9],["⌂"][10],["⌂"][11],["⌂"][12],["⌂"][13],["⌂"][14],["⌂"][15]);
         }
         else if(int(["⌂"].length) == 17)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4],["⌂"][5],["⌂"][6],["⌂"][7],["⌂"][8],["⌂"][9],["⌂"][10],["⌂"][11],["⌂"][12],["⌂"][13],["⌂"][14],["⌂"][15],["⌂"][16]);
         }
         else if(int(["⌂"].length) == 18)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4],["⌂"][5],["⌂"][6],["⌂"][7],["⌂"][8],["⌂"][9],["⌂"][10],["⌂"][11],["⌂"][12],["⌂"][13],["⌂"][14],["⌂"][15],["⌂"][16],["⌂"][17]);
         }
         else if(int(["⌂"].length) == 19)
         {
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4],["⌂"][5],["⌂"][6],["⌂"][7],["⌂"][8],["⌂"][9],["⌂"][10],["⌂"][11],["⌂"][12],["⌂"][13],["⌂"][14],["⌂"][15],["⌂"][16],["⌂"][17],["⌂"][18]);
         }
         else
         {
            if(int(["⌂"].length) != 20)
            {
               throw "Too many rest arguments";
            }
            console.setViewingChannels(["⌂"][0],["⌂"][1],["⌂"][2],["⌂"][3],["⌂"][4],["⌂"][5],["⌂"][6],["⌂"][7],["⌂"][8],["⌂"][9],["⌂"][10],["⌂"][11],["⌂"][12],["⌂"][13],["⌂"][14],["⌂"][15],["⌂"][16],["⌂"][17],["⌂"][18],["⌂"][19]);
         }
         if(_history == null)
         {
            _history = [];
         }
         if(_current != o)
         {
            _current = o;
            if(int(_history.length) <= _hisIndex)
            {
               _history.push(o);
            }
            else
            {
               _history[_hisIndex] = o;
            }
            ++_hisIndex;
         }
         _dofull = full;
         inspect(o,_dofull);
      }
      
      public function exitFocus() : void
      {
         var _loc1_:* = null as ByteArray;
         _current = null;
         _dofull = false;
         _history = null;
         _hisIndex = 0;
         if(get_remoter().get_remoting() == 1)
         {
            _loc1_ = new ByteArray();
            _loc1_.writeUTF("refexit");
            get_remoter().send("ref",_loc1_);
         }
         console.clear("⌂");
      }
   }
}

