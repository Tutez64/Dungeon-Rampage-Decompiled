package Brain.Input
{
   import Brain.Facade.Facade;
   import Brain.Logger.Logger;
   import Brain.MouseScrollPlugin.CustomMouseWheelEvent;
   import Brain.Utils.MemoryTracker;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   
   public class InputManager
   {
      
      private var mEnabled:Boolean = false;
      
      private var mKeysDown:Vector.<Boolean> = new Vector.<Boolean>(256);
      
      private var mNumberOfKeysDown:int = 0;
      
      private var mKeysPressed:Vector.<int> = new Vector.<int>(256);
      
      private var mKeysReleased:Vector.<int> = new Vector.<int>(256);
      
      private var mNumberOfKeysPressed:int = 0;
      
      private var mNumberOfKeysReleased:int = 0;
      
      private var mMouseWheelDelta:int = 0;
      
      public var lastKey:int;
      
      public var mouseDown:Boolean = false;
      
      public var mouseUp:Boolean = true;
      
      public var mousePressed:Boolean = false;
      
      public var mouseReleased:Boolean = false;
      
      public var mouseWheel:Boolean = false;
      
      private var mFacade:Facade;
      
      public var disableInputs:Boolean;
      
      private var menuNavigationCallback:Function;
      
      public function InputManager(facade:Facade)
      {
         super();
         mFacade = facade;
         MemoryTracker.track(mKeysDown,"Vector.<Boolean> - keys down state in InputManager()","brain");
         MemoryTracker.track(mKeysPressed,"Vector.<int> - keys pressed in InputManager()","brain");
         MemoryTracker.track(mKeysReleased,"Vector.<int> - keys released in InputManager()","brain");
         enable();
      }
      
      public function registerMenuNavigationCallback(callback:Function) : void
      {
         menuNavigationCallback = callback;
      }
      
      public function unregisterKeyPressedCallback(callback:*) : void
      {
         if(Boolean(menuNavigationCallback))
         {
            menuNavigationCallback = null;
            return;
         }
         Logger.warn("Unregistering MenuNavigation shouldn\'t have an empty callback");
      }
      
      public function get mouseWheelDelta() : int
      {
         if(mouseWheel)
         {
            mouseWheel = false;
            return mMouseWheelDelta;
         }
         return 0;
      }
      
      public function get mouseX() : int
      {
         return mFacade.stageRef.mouseX;
      }
      
      public function get mouseY() : int
      {
         return mFacade.stageRef.mouseY;
      }
      
      public function get mouseFlashX() : int
      {
         return mFacade.stageRef.mouseX;
      }
      
      public function get mouseFlashY() : int
      {
         return mFacade.stageRef.mouseY;
      }
      
      public function check(input:*) : Boolean
      {
         return input < 0 ? mNumberOfKeysDown > 0 : mKeysDown[input];
      }
      
      public function pressed(input:*) : Boolean
      {
         return input < 0 ? mNumberOfKeysPressed : mKeysPressed.indexOf(input) >= 0;
      }
      
      public function released(input:*) : Boolean
      {
         return input < 0 ? mNumberOfKeysReleased : mKeysReleased.indexOf(input) >= 0;
      }
      
      protected function enable() : void
      {
         mFacade.stageRef.addEventListener("keyDown",onKeyDown);
         mFacade.stageRef.addEventListener("keyUp",onKeyUp);
         mFacade.stageRef.addEventListener("mouseDown",onMouseDown);
         mFacade.stageRef.addEventListener("mouseUp",onMouseUp);
         mFacade.stageRef.addEventListener("onMove",onMouseWheel);
         mFacade.stageRef.addEventListener("mouseLeave",onMouseLeave);
         mFacade.stageRef.addEventListener("deactivate",onDeactivate);
      }
      
      public function flush() : void
      {
         while(mNumberOfKeysPressed--)
         {
            mKeysPressed[mNumberOfKeysPressed] = -1;
         }
         mNumberOfKeysPressed = 0;
         while(mNumberOfKeysReleased--)
         {
            mKeysReleased[mNumberOfKeysReleased] = -1;
         }
         mNumberOfKeysReleased = 0;
         mousePressed = false;
         mouseReleased = false;
      }
      
      public function clear() : void
      {
         flush();
         var _loc1_:int = int(mKeysDown.length);
         while(_loc1_--)
         {
            mKeysDown[_loc1_] = false;
         }
         mNumberOfKeysDown = 0;
      }
      
      private function onKeyDown(e:KeyboardEvent = null) : void
      {
         var _loc2_:int = 0;
         if(!disableInputs)
         {
            _loc2_ = lastKey = e.keyCode;
            if(!mKeysDown[_loc2_])
            {
               mKeysDown[_loc2_] = true;
               mNumberOfKeysDown = mNumberOfKeysDown + 1;
               mKeysPressed[mNumberOfKeysPressed++] = _loc2_;
            }
            if(Boolean(menuNavigationCallback))
            {
               menuNavigationCallback(_loc2_);
            }
         }
      }
      
      private function onKeyUp(e:KeyboardEvent) : void
      {
         var _loc2_:int = 0;
         if(!disableInputs)
         {
            _loc2_ = int(e.keyCode);
            if(mKeysDown[_loc2_])
            {
               mKeysDown[_loc2_] = false;
               mNumberOfKeysDown = mNumberOfKeysDown - 1;
               mKeysReleased[mNumberOfKeysReleased++] = _loc2_;
            }
         }
      }
      
      private function onDeactivate(e:Event) : void
      {
         clear();
      }
      
      private function onMouseLeave(e:Event) : void
      {
         clear();
      }
      
      public function onMouseDown(e:MouseEvent) : void
      {
         if(!disableInputs)
         {
            mouseDown = true;
            mouseUp = false;
            mousePressed = true;
         }
      }
      
      public function onMouseUp(e:MouseEvent) : void
      {
         if(!disableInputs)
         {
            mouseUp = true;
            mouseDown = false;
            mouseReleased = true;
         }
      }
      
      private function onMouseWheel(e:CustomMouseWheelEvent) : void
      {
         if(!disableInputs)
         {
            mouseWheel = true;
            mMouseWheelDelta = e.delta;
         }
      }
      
      public function enableControls() : void
      {
         clear();
         disableInputs = false;
      }
      
      public function disableControls() : void
      {
         clear();
         disableInputs = true;
      }
   }
}

