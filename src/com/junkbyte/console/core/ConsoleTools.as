package com.junkbyte.console.core
{
   import com.junkbyte.console.Cc;
   import com.junkbyte.console.Console;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.utils.ByteArray;
   import flash.utils.describeType;
   import flash.utils.getQualifiedClassName;
   
   public class ConsoleTools extends ConsoleCore
   {
      
      public function ConsoleTools(console:Console)
      {
         super(console);
      }
      
      public function map(base:DisplayObjectContainer, maxstep:uint = 0, ch:String = null) : void
      {
         var _loc5_:Boolean = false;
         var _loc9_:DisplayObject = null;
         var _loc10_:String = null;
         var _loc11_:DisplayObjectContainer = null;
         var _loc12_:int = 0;
         var _loc13_:* = 0;
         var _loc14_:DisplayObject = null;
         var _loc15_:uint = 0;
         var _loc16_:String = null;
         if(!base)
         {
            report("Not a DisplayObjectContainer.",10,true,ch);
            return;
         }
         var _loc4_:* = 0;
         var _loc6_:* = 0;
         var _loc7_:DisplayObject = null;
         var _loc8_:Array = new Array();
         _loc8_.push(base);
         while(_loc6_ < _loc8_.length)
         {
            _loc9_ = _loc8_[_loc6_];
            _loc6_++;
            if(_loc9_ is DisplayObjectContainer)
            {
               _loc11_ = _loc9_ as DisplayObjectContainer;
               _loc12_ = _loc11_.numChildren;
               _loc13_ = 0;
               while(_loc13_ < _loc12_)
               {
                  _loc14_ = _loc11_.getChildAt(_loc13_);
                  _loc8_.splice(_loc6_ + _loc13_,0,_loc14_);
                  _loc13_++;
               }
            }
            if(_loc7_)
            {
               if(_loc7_ is DisplayObjectContainer && (_loc7_ as DisplayObjectContainer).contains(_loc9_))
               {
                  _loc4_++;
               }
               else
               {
                  while(_loc7_)
                  {
                     _loc7_ = _loc7_.parent;
                     if(_loc7_ is DisplayObjectContainer)
                     {
                        if(_loc4_ > 0)
                        {
                           _loc4_--;
                        }
                        if((_loc7_ as DisplayObjectContainer).contains(_loc9_))
                        {
                           _loc4_++;
                           break;
                        }
                     }
                  }
               }
            }
            _loc10_ = "";
            _loc13_ = 0;
            while(_loc13_ < _loc4_)
            {
               _loc10_ += _loc13_ == _loc4_ - 1 ? " ∟ " : " - ";
               _loc13_++;
            }
            if(maxstep <= 0 || _loc4_ <= maxstep)
            {
               _loc5_ = false;
               _loc15_ = console.refs.setLogRef(_loc9_);
               _loc16_ = _loc9_.name;
               if(_loc15_)
               {
                  _loc16_ = "<a href=\'event:cl_" + _loc15_ + "\'>" + _loc16_ + "</a>";
               }
               if(_loc9_ is DisplayObjectContainer)
               {
                  _loc16_ = "<b>" + _loc16_ + "</b>";
               }
               else
               {
                  _loc16_ = "<i>" + _loc16_ + "</i>";
               }
               _loc10_ += _loc16_ + " " + console.refs.makeRefTyped(_loc9_);
               report(_loc10_,_loc9_ is DisplayObjectContainer ? 5 : 2,true,ch);
            }
            else if(!_loc5_)
            {
               _loc5_ = true;
               report(_loc10_ + "...",5,true,ch);
            }
            _loc7_ = _loc9_;
         }
         report(base.name + ":" + console.refs.makeRefTyped(base) + " has " + (_loc8_.length - 1) + " children/sub-children.",9,true,ch);
         if(config.commandLineAllowed)
         {
            report("Click on the child display\'s name to set scope.",-2,true,ch);
         }
      }
      
      public function explode(obj:Object, depth:int = 3, p:int = 9) : String
      {
         var V:XML;
         var list:Array;
         var nodes:XMLList = null;
         var n:String = null;
         var accessorX:XML = null;
         var variableX:XML = null;
         var X:String = null;
         var t:String = typeof obj;
         if(obj == null)
         {
            return "<p-2>" + obj + "</p-2>";
         }
         if(obj is String)
         {
            return "\"" + LogReferences.EscHTML(obj as String) + "\"";
         }
         if(t != "object" || depth == 0 || obj is ByteArray)
         {
            return console.refs.makeString(obj);
         }
         if(p < 0)
         {
            p = 0;
         }
         V = describeType(obj);
         list = [];
         nodes = V["accessor"];
         for each(accessorX in nodes)
         {
            n = accessorX.@name;
            if(accessorX.@access != "writeonly")
            {
               try
               {
                  list.push(this.stepExp(obj,n,depth,p));
               }
               catch(e:Error)
               {
               }
            }
            else
            {
               list.push(n);
            }
         }
         nodes = V["variable"];
         for each(variableX in nodes)
         {
            n = variableX.@name;
            list.push(this.stepExp(obj,n,depth,p));
         }
         try
         {
            for(X in obj)
            {
               list.push(this.stepExp(obj,X,depth,p));
            }
         }
         catch(e:Error)
         {
         }
         return "<p" + p + ">{" + LogReferences.ShortClassName(obj) + "</p" + p + "> " + list.join(", ") + "<p" + p + ">}</p" + p + ">";
      }
      
      private function stepExp(o:*, n:String, d:int, p:int) : String
      {
         return n + ":" + this.explode(o[n],d - 1,p - 1);
      }
      
      public function getStack(depth:int, priority:int) : String
      {
         var _loc3_:Error = new Error();
         var _loc4_:String = _loc3_.hasOwnProperty("getStackTrace") ? _loc3_.getStackTrace() : null;
         if(!_loc4_)
         {
            return "";
         }
         var _loc5_:String = "";
         var _loc6_:Array = _loc4_.split(/\n\sat\s/);
         var _loc7_:int = int(_loc6_.length);
         var _loc8_:RegExp = new RegExp("Function|" + getQualifiedClassName(Console) + "|" + getQualifiedClassName(Cc));
         var _loc9_:Boolean = false;
         var _loc10_:* = 2;
         while(_loc10_ < _loc7_)
         {
            if(!_loc9_ && _loc6_[_loc10_].search(_loc8_) != 0)
            {
               _loc9_ = true;
            }
            if(_loc9_)
            {
               _loc5_ += "\n<p" + priority + "> @ " + _loc6_[_loc10_] + "</p" + priority + ">";
               if(priority > 0)
               {
                  priority--;
               }
               depth--;
               if(depth <= 0)
               {
                  break;
               }
            }
            _loc10_++;
         }
         return _loc5_;
      }
   }
}

