package SteamInput
{
   import flash.display.Stage;
   import flash.events.KeyboardEvent;
   import flash.utils.Dictionary;
   
   public class KeyboardEventSpoofer
   {
      
      private var mStageRef:Stage;
      
      private var mKeyboardEventsSpoofMap:KeyboardEventsSpoofMap = new KeyboardEventsSpoofMap();
      
      private var mPressedActions:Dictionary = new Dictionary();
      
      public function KeyboardEventSpoofer(stageRef:Stage)
      {
         super();
         mStageRef = stageRef;
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
         if(action in mPressedActions)
         {
            fireReleasedEvent(action);
            delete mPressedActions[action];
         }
      }
      
      private function handlePressedAction(action:String) : void
      {
         if(action in mPressedActions)
         {
            return;
         }
         mPressedActions[action] = true;
         firePressedEvent(action);
      }
      
      private function fireReleasedEvent(action:String) : void
      {
         fireKeyboardEvent("keyUp",action);
      }
      
      private function firePressedEvent(action:String) : void
      {
         fireKeyboardEvent("keyDown",action);
      }
      
      private function fireKeyboardEvent(inputType:String, action:String) : void
      {
         var _loc3_:int = mKeyboardEventsSpoofMap.getKeyCode(action);
         var _loc4_:KeyboardEvent = new KeyboardEvent(inputType,true,false,0,_loc3_);
         mStageRef.dispatchEvent(_loc4_);
      }
   }
}

