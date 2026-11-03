package SteamInput
{
   import Input.KeyBindings.KeyBindings;
   import flash.display.Stage;
   import flash.events.KeyboardEvent;
   import flash.utils.Dictionary;
   
   public class KeyboardEventSpoofer
   {
      
      private var mStageRef:Stage;
      
      private var mKeyboardEventsSpoofMap:KeyboardEventsSpoofMap;
      
      private var mPressedActions:Dictionary = new Dictionary();
      
      public function KeyboardEventSpoofer(stageRef:Stage, keyBindings:KeyBindings)
      {
         super();
         mStageRef = stageRef;
         mKeyboardEventsSpoofMap = new KeyboardEventsSpoofMap(keyBindings);
      }
      
      public function update(steamInputManager:SteamInputManager) : void
      {
         for each(var _loc2_:String in mKeyboardEventsSpoofMap.actionNames)
         {
            if(steamInputManager.releasedAction(_loc2_))
            {
               handleReleasedAction(_loc2_);
            }
            if(steamInputManager.pressedAction(_loc2_))
            {
               handlePressedAction(_loc2_);
            }
         }
      }
      
      private function handleReleasedAction(action:String) : void
      {
         var _loc2_:int = 0;
         if(action in mPressedActions)
         {
            _loc2_ = int(mPressedActions[action]);
            delete mPressedActions[action];
            fireKeyboardEvent("keyUp","UnboundActionEvent.RELEASED",action,_loc2_);
         }
      }
      
      private function handlePressedAction(action:String) : void
      {
         if(action in mPressedActions)
         {
            return;
         }
         var _loc2_:int = mKeyboardEventsSpoofMap.getKeyCode(action);
         mPressedActions[action] = _loc2_;
         fireKeyboardEvent("keyDown","UnboundActionEvent.PRESSED",action,_loc2_);
      }
      
      private function fireKeyboardEvent(inputType:String, unboundType:String, action:String, keyCode:int) : void
      {
         if(keyCode == 0)
         {
            mStageRef.dispatchEvent(new UnboundActionEvent(unboundType,action));
            return;
         }
         var _loc5_:KeyboardEvent = new KeyboardEvent(inputType,true,false,0,keyCode);
         mStageRef.dispatchEvent(_loc5_);
      }
   }
}

