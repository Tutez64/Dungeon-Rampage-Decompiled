package com.junkbyte.console.core
{
   import com.junkbyte.console.Console;
   import com.junkbyte.console.KeyBind;
   import com.junkbyte.console.view.MainPanel;
   import com.junkbyte.console.view.PanelsManager;
   import flash.Boot;
   import flash.display.Stage;
   import flash.events.KeyboardEvent;
   import flash.text.TextField;
   import flash.text.TextFieldType;
   import haxe.IMap;
   import haxe.ds.StringMap;
   
   public class KeyBinder extends ConsoleCore
   {
      
      public var _warns:uint;
      
      public var _passInd:int;
      
      public var _binds:IMap;
      
      public function KeyBinder(console:Console = undefined)
      {
         if(!Boot.skip_constructor)
         {
            super(console);
            console.get_cl().addCLCmd("keybinds",printBinds,"List all keybinds used");
            _binds = new StringMap();
         }
      }
      
      public function tryRunKey(key:String) : void
      {
         var _loc4_:* = null;
         var _loc2_:StringMap = StringMap(_binds);
         var _loc3_:Array = key in StringMap.reserved ? Array(_loc2_.getReserved(key)) : _loc2_.h[key];
         if(config.keyBindsEnabled && _loc3_ != null)
         {
            if(canTrigger())
            {
               _loc4_ = null;
               _loc3_[0].apply(_loc4_,_loc3_[1]);
            }
            else if(_warns < 3)
            {
               ++_warns;
               report("Key bind [" + key + "] did not trigger because you have focus on an input TextField.",8);
            }
         }
      }
      
      public function printBinds(... rest) : void
      {
         var _loc13_:* = null;
         var _loc14_:int = 0;
         var _loc15_:Boolean = false;
         var _loc16_:* = null as String;
         var _loc17_:* = null as String;
         report("Key binds:",-2);
         var _loc3_:uint = 0;
         var _loc4_:StringMap = StringMap(_binds);
         var _loc5_:* = _loc4_.h;
         var _loc6_:* = _loc4_.rh;
         var _loc7_:int = 0;
         var _loc8_:Boolean = false;
         var _loc9_:* = _loc5_;
         var _loc10_:int = _loc7_;
         var _loc11_:Boolean = §§hasnext(_loc9_,_loc10_);
         if(!_loc11_ && _loc6_ != null)
         {
            _loc9_ = _loc5_ = _loc6_;
            _loc10_ = _loc7_ = 0;
            _loc6_ = null;
            _loc8_ = true;
            _loc11_ = §§hasnext(_loc9_,_loc10_);
         }
         var _loc12_:int = _loc10_;
         while(true)
         {
            _loc13_ = _loc5_;
            _loc14_ = _loc7_;
            _loc15_ = §§hasnext(_loc13_,_loc14_);
            if(!_loc15_ && _loc6_ != null)
            {
               _loc13_ = _loc5_ = _loc6_;
               _loc14_ = _loc7_ = 0;
               _loc6_ = null;
               _loc8_ = true;
               _loc15_ = §§hasnext(_loc13_,_loc14_);
            }
            _loc12_ = _loc14_;
            if(!_loc15_)
            {
               break;
            }
            _loc16_ = §§nextname(_loc12_,_loc5_);
            _loc7_ = _loc12_;
            if(_loc8_)
            {
               _loc16_ = _loc16_.substr(1);
            }
            _loc17_ = _loc16_;
            _loc3_ += 1;
            report(_loc17_,-2);
         }
         report("--- Found " + ("" + _loc3_),-2);
      }
      
      public function keyUpHandler(e:KeyboardEvent) : void
      {
         handleKeyEvent(e,true);
      }
      
      public function keyDownHandler(e:KeyboardEvent) : void
      {
         handleKeyEvent(e,false);
      }
      
      public function handleKeyEvent(e:KeyboardEvent, isKeyUp:Boolean) : void
      {
         var _loc5_:* = null as KeyBind;
         var _loc3_:int = int(e.charCode);
         var _loc4_:String = _loc3_ < 65536 ? String["fromCharCode"](_loc3_) : Boot.fromCodePoint(_loc3_);
         if(isKeyUp && config.keystrokePassword != null && _loc4_ != null && _loc4_ == config.keystrokePassword.substring(_passInd,_passInd + 1))
         {
            ++_passInd;
            if(_passInd >= config.keystrokePassword.length)
            {
               _passInd = 0;
               if(canTrigger())
               {
                  if(console.visible && !console.get_panels().get_mainPanel().visible)
                  {
                     console.get_panels().get_mainPanel().set_visible(true);
                  }
                  else
                  {
                     console.set_visible(!console.visible);
                  }
                  if(console.visible && console.get_panels().get_mainPanel().visible)
                  {
                     console.get_panels().get_mainPanel().set_visible(true);
                     console.get_panels().get_mainPanel().moveBackSafePosition();
                  }
               }
               else if(_warns < 3)
               {
                  ++_warns;
                  report("Password did not trigger because you have focus on an input TextField.",8);
               }
            }
         }
         else
         {
            if(isKeyUp)
            {
               _passInd = 0;
            }
            _loc5_ = new KeyBind(e.keyCode,e.shiftKey,e.ctrlKey,e.altKey,isKeyUp);
            tryRunKey(_loc5_.get_key());
            if(_loc4_ != null)
            {
               _loc5_ = new KeyBind(_loc4_,e.shiftKey,e.ctrlKey,e.altKey,isKeyUp);
               tryRunKey(_loc5_.get_key());
            }
         }
      }
      
      public function canTrigger() : Boolean
      {
         var _loc2_:* = null as TextField;
         var _loc3_:* = null as Error;
         try
         {
            if(console.stage != null && console.stage.focus is TextField)
            {
               _loc2_ = console.stage.focus;
               if(_loc2_.type == TextFieldType.INPUT)
               {
                  return false;
               }
            }
         }
         catch(_loc_e_:Error)
         {
            _loc3_ = _loc_e_;
         }
         return true;
      }
      
      public function bindKey(key:KeyBind, fun:*, args:Array = undefined) : void
      {
         var _loc4_:* = null as Array;
         var _loc5_:* = null as IMap;
         var _loc6_:* = null as String;
         var _loc7_:* = null as StringMap;
         if(config.keystrokePassword != null && (!key.get_useKeyCode() && key.get_key().charAt(0) == config.keystrokePassword.charAt(0)))
         {
            report("Error: KeyBind [" + key.get_key() + "] is conflicting with Console password.",9);
            return;
         }
         if(fun == null)
         {
            StringMap(_binds).remove(key.get_key());
         }
         else
         {
            _loc4_ = [fun,args];
            _loc5_ = _binds;
            _loc6_ = key.get_key();
            _loc7_ = _loc5_;
            if(_loc6_ in StringMap.reserved)
            {
               _loc7_.setReserved(_loc6_,_loc4_);
            }
            else
            {
               _loc7_.h[_loc6_] = _loc4_;
            }
         }
      }
   }
}

