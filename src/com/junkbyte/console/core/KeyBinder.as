package com.junkbyte.console.core
{
   import com.junkbyte.console.Console;
   import com.junkbyte.console.KeyBind;
   import flash.events.KeyboardEvent;
   import flash.text.TextField;
   import flash.text.TextFieldType;
   
   public class KeyBinder extends ConsoleCore
   {
      
      private var _passInd:int;
      
      private var _binds:Object = {};
      
      private var _warns:uint;
      
      public function KeyBinder(console:Console)
      {
         super(console);
         console.cl.addCLCmd("keybinds",this.printBinds,"List all keybinds used");
      }
      
      public function bindKey(key:KeyBind, fun:Function, args:Array = null) : void
      {
         if(Boolean(config.keystrokePassword) && (!key.useKeyCode && key.key.charAt(0) == config.keystrokePassword.charAt(0)))
         {
            report("Error: KeyBind [" + key.key + "] is conflicting with Console password.",9);
            return;
         }
         if(fun == null)
         {
            delete this._binds[key.key];
         }
         else
         {
            this._binds[key.key] = [fun,args];
         }
      }
      
      public function keyDownHandler(e:KeyboardEvent) : void
      {
         this.handleKeyEvent(e,false);
      }
      
      public function keyUpHandler(e:KeyboardEvent) : void
      {
         this.handleKeyEvent(e,true);
      }
      
      private function handleKeyEvent(e:KeyboardEvent, isKeyUp:Boolean) : void
      {
         var _loc4_:KeyBind = null;
         var _loc3_:String = String.fromCharCode(e.charCode);
         if(Boolean(isKeyUp && config.keystrokePassword != null) && Boolean(_loc3_) && _loc3_ == config.keystrokePassword.substring(this._passInd,this._passInd + 1))
         {
            ++this._passInd;
            if(this._passInd >= config.keystrokePassword.length)
            {
               this._passInd = 0;
               if(this.canTrigger())
               {
                  if(console.visible && !console.panels.mainPanel.visible)
                  {
                     console.panels.mainPanel.visible = true;
                  }
                  else
                  {
                     console.visible = !console.visible;
                  }
                  if(console.visible && console.panels.mainPanel.visible)
                  {
                     console.panels.mainPanel.visible = true;
                     console.panels.mainPanel.moveBackSafePosition();
                  }
               }
               else if(this._warns < 3)
               {
                  ++this._warns;
                  report("Password did not trigger because you have focus on an input TextField.",8);
               }
            }
         }
         else
         {
            if(isKeyUp)
            {
               this._passInd = 0;
            }
            _loc4_ = new KeyBind(e.keyCode,e.shiftKey,e.ctrlKey,e.altKey,isKeyUp);
            this.tryRunKey(_loc4_.key);
            if(_loc3_)
            {
               _loc4_ = new KeyBind(_loc3_,e.shiftKey,e.ctrlKey,e.altKey,isKeyUp);
               this.tryRunKey(_loc4_.key);
            }
         }
      }
      
      private function printBinds(... rest) : void
      {
         var _loc3_:String = null;
         report("Key binds:",-2);
         var _loc2_:uint = 0;
         for(_loc3_ in this._binds)
         {
            _loc2_++;
            report(_loc3_,-2);
         }
         report("--- Found " + _loc2_,-2);
      }
      
      private function tryRunKey(key:String) : void
      {
         var _loc2_:Array = this._binds[key];
         if(config.keyBindsEnabled && Boolean(_loc2_))
         {
            if(this.canTrigger())
            {
               (_loc2_[0] as Function).apply(null,_loc2_[1]);
            }
            else if(this._warns < 3)
            {
               ++this._warns;
               report("Key bind [" + key + "] did not trigger because you have focus on an input TextField.",8);
            }
         }
      }
      
      private function canTrigger() : Boolean
      {
         var txt:TextField = null;
         try
         {
            if(Boolean(console.stage) && console.stage.focus is TextField)
            {
               txt = console.stage.focus as TextField;
               if(txt.type == TextFieldType.INPUT)
               {
                  return false;
               }
            }
         }
         catch(err:Error)
         {
         }
         return true;
      }
   }
}

