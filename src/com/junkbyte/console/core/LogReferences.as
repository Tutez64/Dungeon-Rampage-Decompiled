package com.junkbyte.console.core
{
   import com.junkbyte.console.Console;
   import com.junkbyte.console.vos.WeakObject;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.events.Event;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import flash.utils.describeType;
   import flash.utils.getDefinitionByName;
   import flash.utils.getQualifiedClassName;
   
   public class LogReferences extends ConsoleCore
   {
      
      public static const INSPECTING_CHANNEL:String = "⌂";
      
      private var _refMap:WeakObject;
      
      private var _refRev:Dictionary;
      
      private var _refIndex:uint = 1;
      
      private var _dofull:Boolean;
      
      private var _current:*;
      
      private var _history:Array;
      
      private var _hisIndex:uint;
      
      private var _prevBank:Array;
      
      private var _currentBank:Array;
      
      private var _lastWithdraw:uint;
      
      public function LogReferences(console:Console)
      {
         this._refMap = new WeakObject();
         this._refRev = new Dictionary(true);
         this._prevBank = new Array();
         this._currentBank = new Array();
         super(console);
         remoter.registerCallback("ref",function(bytes:ByteArray):void
         {
            handleString(bytes.readUTF());
         });
         remoter.registerCallback("focus",this.handleFocused);
      }
      
      public static function EscHTML(str:String) : String
      {
         return str.replace(/</g,"&lt;").replace(/\>/g,"&gt;").replace(/\x00/g,"");
      }
      
      public static function ShortClassName(obj:Object, eschtml:Boolean = true) : String
      {
         var _loc3_:String = getQualifiedClassName(obj);
         var _loc4_:int = _loc3_.indexOf("::");
         var _loc5_:String = obj is Class ? "*" : "";
         _loc3_ = _loc5_ + _loc3_.substring(_loc4_ >= 0 ? _loc4_ + 2 : 0) + _loc5_;
         if(eschtml)
         {
            return EscHTML(_loc3_);
         }
         return _loc3_;
      }
      
      public function update(time:uint) : void
      {
         if(Boolean(this._currentBank.length) || Boolean(this._prevBank.length))
         {
            if(time > this._lastWithdraw + config.objectHardReferenceTimer * 1000)
            {
               this._prevBank = this._currentBank;
               this._currentBank = new Array();
               this._lastWithdraw = time;
            }
         }
      }
      
      public function setLogRef(o:*) : uint
      {
         var _loc3_:int = 0;
         if(!config.useObjectLinking)
         {
            return 0;
         }
         var _loc2_:uint = uint(this._refRev[o]);
         if(!_loc2_)
         {
            _loc2_ = this._refIndex;
            this._refMap[_loc2_] = o;
            this._refRev[o] = _loc2_;
            if(config.objectHardReferenceTimer)
            {
               this._currentBank.push(o);
            }
            ++this._refIndex;
            _loc3_ = _loc2_ - 50;
            while(_loc3_ >= 0)
            {
               if(this._refMap[_loc3_] === null)
               {
                  delete this._refMap[_loc3_];
               }
               _loc3_ -= 50;
            }
         }
         return _loc2_;
      }
      
      public function getRefId(o:*) : uint
      {
         return this._refRev[o];
      }
      
      public function getRefById(ind:uint) : *
      {
         return this._refMap[ind];
      }
      
      public function makeString(o:*, prop:* = null, html:Boolean = false, maxlen:int = -1) : String
      {
         var txt:String = null;
         var v:* = undefined;
         var err:Error = null;
         var stackstr:String = null;
         var str:String = null;
         var len:int = 0;
         var hasmaxlen:Boolean = false;
         var i:int = 0;
         var strpart:String = null;
         var add:String = null;
         try
         {
            v = prop ? o[prop] : o;
         }
         catch(err:Error)
         {
            return "<p0><i>" + err.toString() + "</i></p0>";
         }
         if(v is Error)
         {
            err = v as Error;
            stackstr = err.hasOwnProperty("getStackTrace") ? err.getStackTrace() : err.toString();
            if(stackstr)
            {
               return stackstr;
            }
            return err.toString();
         }
         if(v is XML || v is XMLList)
         {
            return this.shortenString(EscHTML(v.toXMLString()),maxlen,o,prop);
         }
         if(v is QName)
         {
            return String(v);
         }
         if(v is Array || getQualifiedClassName(v).indexOf("__AS3__.vec::Vector.") == 0)
         {
            str = "[";
            len = int(v.length);
            hasmaxlen = maxlen >= 0;
            i = 0;
            while(i < len)
            {
               strpart = this.makeString(v[i],null,false,maxlen);
               str += (i ? ", " : "") + strpart;
               maxlen -= strpart.length;
               if(hasmaxlen && maxlen <= 0 && i < len - 1)
               {
                  str += ", " + this.genLinkString(o,prop,"...");
                  break;
               }
               i++;
            }
            return str + "]";
         }
         if(Boolean(config.useObjectLinking) && Boolean(v) && typeof v == "object")
         {
            add = "";
            if(v is ByteArray)
            {
               add = " position:" + v.position + " length:" + v.length;
            }
            else if(v is Date || v is Rectangle || v is Point || v is Matrix || v is Event)
            {
               add = " " + String(v);
            }
            else if(v is DisplayObject && Boolean(v.name))
            {
               add = " " + v.name;
            }
            txt = "{" + this.genLinkString(o,prop,ShortClassName(v)) + EscHTML(add) + "}";
         }
         else
         {
            if(v is ByteArray)
            {
               txt = "[ByteArray position:" + ByteArray(v).position + " length:" + ByteArray(v).length + "]";
            }
            else
            {
               txt = String(v);
            }
            if(!html)
            {
               return this.shortenString(EscHTML(txt),maxlen,o,prop);
            }
         }
         return txt;
      }
      
      public function makeRefTyped(v:*) : String
      {
         if(Boolean(v) && Boolean(typeof v == "object") && !(v is QName))
         {
            return "{" + this.genLinkString(v,null,ShortClassName(v)) + "}";
         }
         return ShortClassName(v);
      }
      
      private function genLinkString(o:*, prop:*, str:String) : String
      {
         if(Boolean(prop) && !(prop is String))
         {
            o = o[prop];
            prop = null;
         }
         var _loc4_:uint = this.setLogRef(o);
         if(_loc4_)
         {
            return "<menu><a href=\'event:ref_" + _loc4_ + (prop ? "_" + prop : "") + "\'>" + str + "</a></menu>";
         }
         return str;
      }
      
      private function shortenString(str:String, maxlen:int, o:*, prop:* = null) : String
      {
         if(maxlen >= 0 && str.length > maxlen)
         {
            str = str.substring(0,maxlen);
            return str + this.genLinkString(o,prop," ...");
         }
         return str;
      }
      
      private function historyInc(i:int) : void
      {
         this._hisIndex += i;
         var _loc2_:* = this._history[this._hisIndex];
         if(_loc2_)
         {
            this.focus(_loc2_,this._dofull);
         }
      }
      
      public function handleRefEvent(str:String) : void
      {
         var _loc2_:ByteArray = null;
         if(remoter.remoting == Remoting.RECIEVER)
         {
            _loc2_ = new ByteArray();
            _loc2_.writeUTF(str);
            remoter.send("ref",_loc2_);
         }
         else
         {
            this.handleString(str);
         }
      }
      
      private function handleString(str:String) : void
      {
         var _loc2_:int = 0;
         var _loc3_:uint = 0;
         var _loc4_:String = null;
         var _loc5_:int = 0;
         var _loc6_:Object = null;
         if(str == "refexit")
         {
            this.exitFocus();
            console.setViewingChannels();
         }
         else if(str == "refprev")
         {
            this.historyInc(-2);
         }
         else if(str == "reffwd")
         {
            this.historyInc(0);
         }
         else if(str == "refi")
         {
            this.focus(this._current,!this._dofull);
         }
         else
         {
            _loc2_ = str.indexOf("_") + 1;
            if(_loc2_ > 0)
            {
               _loc4_ = "";
               _loc5_ = str.indexOf("_",_loc2_);
               if(_loc5_ > 0)
               {
                  _loc3_ = uint(str.substring(_loc2_,_loc5_));
                  _loc4_ = str.substring(_loc5_ + 1);
               }
               else
               {
                  _loc3_ = uint(str.substring(_loc2_));
               }
               _loc6_ = this.getRefById(_loc3_);
               if(_loc4_)
               {
                  _loc6_ = _loc6_[_loc4_];
               }
               if(_loc6_)
               {
                  if(str.indexOf("refe_") == 0)
                  {
                     console.explodech(console.panels.mainPanel.reportChannel,_loc6_);
                  }
                  else
                  {
                     this.focus(_loc6_,this._dofull);
                  }
                  return;
               }
            }
            report("Reference no longer exist (garbage collected).",-2);
         }
      }
      
      public function focus(o:*, full:Boolean = false) : void
      {
         remoter.send("focus");
         console.clear(LogReferences.INSPECTING_CHANNEL);
         console.setViewingChannels(LogReferences.INSPECTING_CHANNEL);
         if(!this._history)
         {
            this._history = new Array();
         }
         if(this._current != o)
         {
            this._current = o;
            if(this._history.length <= this._hisIndex)
            {
               this._history.push(o);
            }
            else
            {
               this._history[this._hisIndex] = o;
            }
            ++this._hisIndex;
         }
         this._dofull = full;
         this.inspect(o,this._dofull);
      }
      
      private function handleFocused() : void
      {
         console.clear(LogReferences.INSPECTING_CHANNEL);
         console.setViewingChannels(LogReferences.INSPECTING_CHANNEL);
      }
      
      public function exitFocus() : void
      {
         var _loc1_:ByteArray = null;
         this._current = null;
         this._dofull = false;
         this._history = null;
         this._hisIndex = 0;
         if(remoter.remoting == Remoting.SENDER)
         {
            _loc1_ = new ByteArray();
            _loc1_.writeUTF("refexit");
            remoter.send("ref",_loc1_);
         }
         console.clear(LogReferences.INSPECTING_CHANNEL);
      }
      
      public function inspect(obj:*, viewAll:Boolean = true, ch:String = null) : void
      {
         var refIndex:uint;
         var showInherit:String;
         var V:XML;
         var cls:Object;
         var clsV:XML;
         var self:String;
         var isClass:Boolean;
         var st:String;
         var str:String;
         var props:Array;
         var inherit:uint;
         var menuStr:String = null;
         var nodes:XMLList = null;
         var constantX:XML = null;
         var hasstuff:Boolean = false;
         var isstatic:Boolean = false;
         var methodX:XML = null;
         var accessorX:XML = null;
         var variableX:XML = null;
         var extendX:XML = null;
         var implementX:XML = null;
         var metadataX:XML = null;
         var mn:XMLList = null;
         var en:String = null;
         var et:String = null;
         var disp:DisplayObject = null;
         var theParent:DisplayObjectContainer = null;
         var pr:DisplayObjectContainer = null;
         var indstr:String = null;
         var cont:DisplayObjectContainer = null;
         var clen:int = 0;
         var ci:int = 0;
         var child:DisplayObject = null;
         var params:Array = null;
         var mparamsList:XMLList = null;
         var paraX:XML = null;
         var access:String = null;
         var X:* = undefined;
         if(!obj)
         {
            report(obj,-2,true,ch);
            return;
         }
         refIndex = this.setLogRef(obj);
         showInherit = "";
         if(!viewAll)
         {
            showInherit = " [<a href=\'event:refi\'>show inherited</a>]";
         }
         if(this._history)
         {
            menuStr = "<b>[<a href=\'event:refexit\'>exit</a>]";
            if(this._hisIndex > 1)
            {
               menuStr += " [<a href=\'event:refprev\'>previous</a>]";
            }
            if(Boolean(this._history) && this._hisIndex < this._history.length)
            {
               menuStr += " [<a href=\'event:reffwd\'>forward</a>]";
            }
            menuStr += "</b> || [<a href=\'event:ref_" + refIndex + "\'>refresh</a>]";
            menuStr += "</b> [<a href=\'event:refe_" + refIndex + "\'>explode</a>]";
            if(config.commandLineAllowed)
            {
               menuStr += " [<a href=\'event:cl_" + refIndex + "\'>scope</a>]";
            }
            if(viewAll)
            {
               menuStr += " [<a href=\'event:refi\'>hide inherited</a>]";
            }
            else
            {
               menuStr += showInherit;
            }
            report(menuStr,-1,true,ch);
            report("",1,true,ch);
         }
         V = describeType(obj);
         cls = obj is Class ? obj : obj.constructor;
         clsV = describeType(cls);
         self = V.@name;
         isClass = obj is Class;
         st = isClass ? "*" : "";
         str = "<b>{" + st + this.genLinkString(obj,null,EscHTML(self)) + st + "}</b>";
         props = [];
         if(V.@isStatic == "true")
         {
            props.push("<b>static</b>");
         }
         if(V.@isDynamic == "true")
         {
            props.push("dynamic");
         }
         if(V.@isFinal == "true")
         {
            props.push("final");
         }
         if(props.length > 0)
         {
            str += " <p-1>" + props.join(" | ") + "</p-1>";
         }
         report(str,-2,true,ch);
         nodes = V.extendsClass;
         if(nodes.length())
         {
            props = [];
            for each(extendX in nodes)
            {
               st = extendX.@type.toString();
               props.push(st.indexOf("*") < 0 ? this.makeValue(getDefinitionByName(st)) : EscHTML(st));
               if(!viewAll)
               {
                  break;
               }
            }
            report("<p10>Extends:</p10> " + props.join(" &gt; "),1,true,ch);
         }
         nodes = V.implementsInterface;
         if(nodes.length())
         {
            props = [];
            for each(implementX in nodes)
            {
               props.push(this.makeValue(getDefinitionByName(implementX.@type.toString())));
            }
            report("<p10>Implements:</p10> " + props.join(", "),1,true,ch);
         }
         report("",1,true,ch);
         props = [];
         nodes = V.metadata.(@name == "Event");
         if(nodes.length())
         {
            for each(metadataX in nodes)
            {
               mn = metadataX.arg;
               en = mn.(@key == "name").@value;
               et = mn.(@key == "type").@value;
               if(refIndex)
               {
                  props.push("<a href=\'event:cl_" + refIndex + "_dispatchEvent(new " + et + "(\"" + en + "\"))\'>" + en + "</a><p0>(" + et + ")</p0>");
               }
               else
               {
                  props.push(en + "<p0>(" + et + ")</p0>");
               }
            }
            report("<p10>Events:</p10> " + props.join("<p-1>; </p-1>"),1,true,ch);
            report("",1,true,ch);
         }
         if(obj is DisplayObject)
         {
            disp = obj as DisplayObject;
            theParent = disp.parent;
            if(theParent)
            {
               props = new Array("@" + theParent.getChildIndex(disp));
               while(theParent)
               {
                  pr = theParent;
                  theParent = theParent.parent;
                  indstr = theParent ? "@" + theParent.getChildIndex(pr) : "";
                  props.push("<b>" + pr.name + "</b>" + indstr + this.makeValue(pr));
               }
               report("<p10>Parents:</p10> " + props.join("<p-1> -> </p-1>") + "<br/>",1,true,ch);
            }
         }
         if(obj is DisplayObjectContainer)
         {
            props = [];
            cont = obj as DisplayObjectContainer;
            clen = cont.numChildren;
            ci = 0;
            while(ci < clen)
            {
               child = cont.getChildAt(ci);
               props.push("<b>" + child.name + "</b>@" + ci + this.makeValue(child));
               ci++;
            }
            if(clen)
            {
               report("<p10>Children:</p10> " + props.join("<p-1>; </p-1>") + "<br/>",1,true,ch);
            }
         }
         props = [];
         nodes = clsV..constant;
         for each(constantX in nodes)
         {
            report(" const <p3>" + constantX.@name + "</p3>:" + constantX.@type + " = " + this.makeValue(cls,constantX.@name.toString()) + "</p0>",1,true,ch);
         }
         if(nodes.length())
         {
            report("",1,true,ch);
         }
         inherit = 0;
         props = [];
         nodes = clsV..method;
         for each(methodX in nodes)
         {
            if(viewAll || self == methodX.@declaredBy)
            {
               hasstuff = true;
               isstatic = methodX.parent().name() != "factory";
               str = " " + (isstatic ? "static " : "") + "function ";
               params = [];
               mparamsList = methodX.parameter;
               for each(paraX in mparamsList)
               {
                  params.push(paraX.@optional == "true" ? "<i>" + paraX.@type + "</i>" : paraX.@type);
               }
               if(Boolean(refIndex) && (isstatic || !isClass))
               {
                  str += "<a href=\'event:cl_" + refIndex + "_" + methodX.@name + "()\'><p3>" + methodX.@name + "</p3></a>";
               }
               else
               {
                  str += "<p3>" + methodX.@name + "</p3>";
               }
               str += "(" + params.join(", ") + "):" + methodX.@returnType;
               report(str,1,true,ch);
            }
            else
            {
               inherit++;
            }
         }
         if(inherit)
         {
            report("   \t + " + inherit + " inherited methods." + showInherit,1,true,ch);
         }
         else if(hasstuff)
         {
            report("",1,true,ch);
         }
         hasstuff = false;
         inherit = 0;
         props = [];
         nodes = clsV..accessor;
         for each(accessorX in nodes)
         {
            if(viewAll || self == accessorX.@declaredBy)
            {
               hasstuff = true;
               isstatic = accessorX.parent().name() != "factory";
               str = " ";
               if(isstatic)
               {
                  str += "static ";
               }
               access = accessorX.@access;
               if(access == "readonly")
               {
                  str += "get";
               }
               else if(access == "writeonly")
               {
                  str += "set";
               }
               else
               {
                  str += "assign";
               }
               if(Boolean(refIndex) && (isstatic || !isClass))
               {
                  str += " <a href=\'event:cl_" + refIndex + "_" + accessorX.@name + "\'><p3>" + accessorX.@name + "</p3></a>:" + accessorX.@type;
               }
               else
               {
                  str += " <p3>" + accessorX.@name + "</p3>:" + accessorX.@type;
               }
               if(access != "writeonly" && (isstatic || !isClass))
               {
                  str += " = " + this.makeValue(isstatic ? cls : obj,accessorX.@name.toString());
               }
               report(str,1,true,ch);
            }
            else
            {
               inherit++;
            }
         }
         if(inherit)
         {
            report("   \t + " + inherit + " inherited accessors." + showInherit,1,true,ch);
         }
         else if(hasstuff)
         {
            report("",1,true,ch);
         }
         nodes = clsV..variable;
         for each(variableX in nodes)
         {
            isstatic = variableX.parent().name() != "factory";
            str = isstatic ? " static" : "";
            if(refIndex)
            {
               str += " var <p3><a href=\'event:cl_" + refIndex + "_" + variableX.@name + " = \'>" + variableX.@name + "</a>";
            }
            else
            {
               str += " var <p3>" + variableX.@name;
            }
            str += "</p3>:" + variableX.@type + " = " + this.makeValue(isstatic ? cls : obj,variableX.@name.toString());
            report(str,1,true,ch);
         }
         try
         {
            props = [];
            for(X in obj)
            {
               if(X is String)
               {
                  if(refIndex)
                  {
                     str = "<a href=\'event:cl_" + refIndex + "_" + X + " = \'>" + X + "</a>";
                  }
                  else
                  {
                     str = X;
                  }
                  report(" dynamic var <p3>" + str + "</p3> = " + this.makeValue(obj,X),1,true,ch);
               }
               else
               {
                  report(" dictionary <p3>" + this.makeValue(X) + "</p3> = " + this.makeValue(obj,X),1,true,ch);
               }
            }
         }
         catch(e:Error)
         {
            report("Could not get dynamic values. " + e.message,9,false,ch);
         }
         if(obj is String)
         {
            report("",1,true,ch);
            report("String",10,true,ch);
            report(EscHTML(obj),1,true,ch);
         }
         else if(obj is XML || obj is XMLList)
         {
            report("",1,true,ch);
            report("XMLString",10,true,ch);
            report(EscHTML(obj.toXMLString()),1,true,ch);
         }
         if(menuStr)
         {
            report("",1,true,ch);
            report(menuStr,-1,true,ch);
         }
      }
      
      public function getPossibleCalls(obj:*) : Array
      {
         var _loc5_:XML = null;
         var _loc6_:XML = null;
         var _loc7_:XML = null;
         var _loc8_:Array = null;
         var _loc9_:XMLList = null;
         var _loc10_:XML = null;
         var _loc2_:Array = new Array();
         var _loc3_:XML = describeType(obj);
         var _loc4_:XMLList = _loc3_.method;
         for each(_loc5_ in _loc4_)
         {
            _loc8_ = [];
            _loc9_ = _loc5_.parameter;
            for each(_loc10_ in _loc9_)
            {
               _loc8_.push(_loc10_.@optional == "true" ? "<i>" + _loc10_.@type + "</i>" : _loc10_.@type);
            }
            _loc2_.push([_loc5_.@name + "(",_loc8_.join(", ") + " ):" + _loc5_.@returnType]);
         }
         _loc4_ = _loc3_.accessor;
         for each(_loc6_ in _loc4_)
         {
            _loc2_.push([String(_loc6_.@name),String(_loc6_.@type)]);
         }
         _loc4_ = _loc3_.variable;
         for each(_loc7_ in _loc4_)
         {
            _loc2_.push([String(_loc7_.@name),String(_loc7_.@type)]);
         }
         return _loc2_;
      }
      
      private function makeValue(obj:*, prop:* = null) : String
      {
         return this.makeString(obj,prop,false,config.useObjectLinking ? 100 : -1);
      }
   }
}

