package com.junkbyte.console.core
{
   import com.junkbyte.console.Cc;
   import com.junkbyte.console.Console;
   import com.junkbyte.console.compat.ConsoleLib;
   import com.junkbyte.console.utils.FlashRegex;
   import flash.Boot;
   import flash.Lib;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.utils.ByteArray;
   
   public class ConsoleTools extends ConsoleCore
   {
      
      public function ConsoleTools(console:Console = undefined)
      {
         if(!Boot.skip_constructor)
         {
            super(console);
         }
      }
      
      public function stepExp(o:*, n:*, d:int, p:int) : String
      {
         return Std.string(n) + ":" + explode(o[n],d - 1,p - 1);
      }
      
      public function map(base:DisplayObjectContainer, maxstep:int = 0, ch:String = undefined) : void
      {
         var _loc9_:* = null as DisplayObject;
         var _loc10_:* = null as DisplayObjectContainer;
         var _loc11_:int = 0;
         var _loc12_:int = 0;
         var _loc13_:int = 0;
         var _loc14_:int = 0;
         var _loc15_:* = null as DisplayObject;
         var _loc16_:* = null as String;
         var _loc17_:uint = 0;
         var _loc18_:* = null as String;
         if(base == null)
         {
            report("Not a DisplayObjectContainer.",10,true,ch);
            return;
         }
         var _loc4_:int = 0;
         var _loc5_:Boolean = false;
         var _loc6_:int = 0;
         var _loc7_:DisplayObject = null;
         var _loc8_:Array = [];
         _loc8_.push(base);
         while(_loc6_ < int(_loc8_.length))
         {
            _loc9_ = _loc8_[_loc6_];
            _loc6_++;
            if(_loc9_ is DisplayObjectContainer)
            {
               _loc10_ = _loc9_;
               _loc11_ = _loc10_.numChildren;
               _loc12_ = 0;
               _loc13_ = _loc11_;
               while(_loc12_ < _loc13_)
               {
                  _loc14_ = _loc12_++;
                  _loc15_ = _loc10_.getChildAt(_loc14_);
                  _loc8_.splice(_loc6_ + _loc14_,0,_loc15_);
               }
            }
            if(_loc7_ != null)
            {
               if(_loc7_ is DisplayObjectContainer && _loc7_.contains(_loc9_))
               {
                  _loc4_++;
               }
               else
               {
                  while(_loc7_ != null)
                  {
                     _loc7_ = _loc7_.parent;
                     if(_loc7_ is DisplayObjectContainer)
                     {
                        if(_loc4_ > 0)
                        {
                           _loc4_--;
                        }
                        if(_loc7_.contains(_loc9_))
                        {
                           _loc4_++;
                           break;
                        }
                     }
                  }
               }
            }
            _loc16_ = "";
            _loc11_ = 0;
            _loc12_ = _loc4_;
            while(_loc11_ < _loc12_)
            {
               _loc13_ = _loc11_++;
               _loc16_ += _loc13_ == _loc4_ - 1 ? " ∟ " : " - ";
            }
            if(maxstep <= 0 || _loc4_ <= maxstep)
            {
               _loc5_ = false;
               _loc17_ = console.get_refs().setLogRef(_loc9_);
               _loc18_ = _loc9_.name;
               if(_loc17_ != 0)
               {
                  _loc18_ = "<a href=\'event:cl_" + ("" + _loc17_) + "\'>" + _loc18_ + "</a>";
               }
               if(_loc9_ is DisplayObjectContainer)
               {
                  _loc18_ = "<b>" + _loc18_ + "</b>";
               }
               else
               {
                  _loc18_ = "<i>" + _loc18_ + "</i>";
               }
               _loc16_ += _loc18_ + " " + console.get_refs().makeRefTyped(_loc9_);
               report(_loc16_,_loc9_ is DisplayObjectContainer ? 5 : 2,true,ch);
            }
            else if(!_loc5_)
            {
               _loc5_ = true;
               report(_loc16_ + "...",5,true,ch);
            }
            _loc7_ = _loc9_;
         }
         report(base.name + ":" + console.get_refs().makeRefTyped(base) + " has " + (int(_loc8_.length) - 1) + " children/sub-children.",9,true,ch);
         if(config.commandLineAllowed)
         {
            report("Click on the child display\'s name to set scope.",-2,true,ch);
         }
      }
      
      public function getStack(depth:int, priority:int) : String
      {
         var _loc12_:int = 0;
         var _loc3_:Error = new Error();
         var _loc4_:String = _loc3_.getStackTrace();
         if(_loc4_ == null || _loc4_ == "")
         {
            return "";
         }
         var _loc5_:String = "";
         var _loc6_:Array = FlashRegex.split(_loc4_,new EReg("\n\\sat\\s",""));
         var _loc7_:int = int(_loc6_.length);
         var _loc8_:EReg = new EReg("Function|" + ConsoleLib.getQualifiedClassName(Console) + "|" + ConsoleLib.getQualifiedClassName(Cc),"");
         var _loc9_:Boolean = false;
         var _loc10_:int = 2;
         var _loc11_:int = _loc7_;
         while(_loc10_ < _loc11_)
         {
            _loc12_ = _loc10_++;
            if(!_loc9_ && FlashRegex.search(_loc6_[_loc12_],_loc8_) != 0)
            {
               _loc9_ = true;
            }
            if(_loc9_)
            {
               _loc5_ += "\n<p" + priority + "> @ " + _loc6_[_loc12_] + "</p" + priority + ">";
               if(priority > 0)
               {
                  priority--;
               }
               if(--depth <= 0)
               {
                  break;
               }
            }
         }
         return _loc5_;
      }
      
      public function explode(obj:*, depth:int = 3, p:int = 9) : String
      {
         var _loc9_:* = 0;
         var _loc11_:int = 0;
         var _loc12_:* = null as XML;
         var _loc13_:* = null as String;
         var _loc14_:* = null;
         var _loc15_:* = null as Array;
         var _loc16_:* = null as Array;
         var _loc5_:String = ConsoleLib.typeOf(obj);
         if(obj == null)
         {
            return "<p-2>" + Std.string(obj) + "</p-2>";
         }
         if(obj is String)
         {
            var _temp_1:* = obj;
            if(!(_temp_1 is String))
            {
               throw "Class cast error";
            }
            return "\"" + LogReferences.EscHTML(_temp_1) + "\"";
         }
         if(_loc5_ != "object" || depth == 0 || obj is ByteArray)
         {
            return console.get_refs().makeString(obj);
         }
         if(p < 0)
         {
            p = 0;
         }
         var _loc6_:XML = Lib.describeType(obj);
         var _loc7_:Array = [];
         var _loc8_:XMLList = _loc6_.child("accessor");
         _loc9_ = 0;
         var _loc10_:int = _loc8_.length();
         while(_loc9_ < _loc10_)
         {
            _loc11_ = _loc9_++;
            _loc12_ = _loc8_[_loc11_];
            _loc13_ = _loc12_.attribute("name").toString();
            if(_loc12_.attribute("access").toString() != "writeonly")
            {
               try
               {
                  _loc7_.push(stepExp(obj,_loc13_,depth,p));
               }
               catch(_loc_e_:*)
               {
                  _loc14_ = _loc_e_;
                  null;
               }
            }
            else
            {
               _loc7_.push(_loc13_);
            }
         }
         _loc8_ = _loc6_.child("variable");
         _loc9_ = 0;
         _loc10_ = _loc8_.length();
         while(_loc9_ < _loc10_)
         {
            _loc11_ = _loc9_++;
            _loc7_.push(stepExp(obj,_loc8_[_loc11_].attribute("name").toString(),depth,p));
         }
         try
         {
            _loc9_ = 0;
            _loc16_ = [];
            _loc14_ = obj;
            for(_loc9_ in _loc14_)
            {
               _loc16_.push(_loc9_);
            }
            _loc15_ = _loc16_;
            _loc9_ = 0;
            while(_loc9_ < int(_loc15_.length))
            {
               _loc14_ = _loc15_[_loc9_];
               _loc9_++;
               _loc7_.push(stepExp(obj,_loc14_,depth,p));
            }
         }
         catch(_loc_e_:*)
         {
            _loc14_ = _loc_e_;
            null;
         }
         return "<p" + p + ">{" + LogReferences.ShortClassName(obj) + "</p" + p + "> " + _loc7_.join(", ") + "<p" + p + ">}</p" + p + ">";
      }
   }
}

