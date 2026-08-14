package SteamInput
{
   import com.amanitadesign.steam.FRESteamWorks;
   import com.amanitadesign.steam.InputAnalogActionData;
   import com.amanitadesign.steam.InputDigitalActionData;
   import flash.geom.Vector3D;
   import flash.utils.Dictionary;
   
   public class SteamController
   {
      
      public var controllerHandle:String;
      
      private var mIsConnected:Boolean;
      
      private var mInGameControlsActionSet:SteamInputActionSet;
      
      private var mMenuControlsActionSet:SteamInputActionSet;
      
      private var mAnalogActionsNamesToVector3D:Dictionary = new Dictionary();
      
      private var mPressedDigitalButtons:Dictionary = new Dictionary();
      
      private var mReleasedDigitalButtons:Dictionary = new Dictionary();
      
      private var mHeldDigitalButtons:Dictionary = new Dictionary();
      
      public function SteamController(inControllerHandle:String, inGameControlsActionSet:SteamInputActionSet, inMenuControlsActionSet:SteamInputActionSet)
      {
         super();
         controllerHandle = inControllerHandle;
         mInGameControlsActionSet = inGameControlsActionSet;
         mMenuControlsActionSet = inMenuControlsActionSet;
         mIsConnected = false;
      }
      
      public function get analogInputs() : Dictionary
      {
         return mAnalogActionsNamesToVector3D;
      }
      
      public function get pressedDigitalButtons() : Dictionary
      {
         return mPressedDigitalButtons;
      }
      
      public function get releasedDigitalButtons() : Dictionary
      {
         return mReleasedDigitalButtons;
      }
      
      public function get heldDigitalButtons() : Dictionary
      {
         return mHeldDigitalButtons;
      }
      
      public function set isConnected(isConnected:Boolean) : void
      {
         mIsConnected = isConnected;
      }
      
      public function get isConnected() : Boolean
      {
         return mIsConnected;
      }
      
      public function flushInput() : void
      {
         clearInputDictionary(mAnalogActionsNamesToVector3D);
         clearInputDictionary(mPressedDigitalButtons);
         clearInputDictionary(mReleasedDigitalButtons);
      }
      
      public function handleDisconnect() : void
      {
         flushInput();
      }
      
      public function readInput(mSteamworks:FRESteamWorks) : void
      {
         readAnalogActions(mSteamworks);
         readDigitalActions(mSteamworks);
      }
      
      private function clearInputDictionary(inputDictionary:Dictionary) : void
      {
         for(var _loc2_:Object in inputDictionary)
         {
            delete inputDictionary[_loc2_];
         }
      }
      
      private function readAnalogActions(mSteamworks:FRESteamWorks) : void
      {
         var _loc4_:InputAnalogActionData = null;
         var _loc2_:Vector.<SteamInputAction> = mInGameControlsActionSet.analogActionHandles;
         for each(var _loc3_:SteamInputAction in _loc2_)
         {
            _loc4_ = mSteamworks.getAnalogActionData(controllerHandle,_loc3_.actionHandle);
            mAnalogActionsNamesToVector3D[_loc3_.actionName] = new Vector3D(_loc4_.x,_loc4_.y,0);
         }
      }
      
      private function readDigitalActions(mSteamworks:FRESteamWorks) : void
      {
         var _loc5_:InputDigitalActionData = null;
         var _loc3_:Vector.<SteamInputAction> = new Vector.<SteamInputAction>();
         for each(var _loc6_:SteamInputAction in mInGameControlsActionSet.digitalActionHandles)
         {
            _loc3_.push(_loc6_);
         }
         for each(var _loc2_:SteamInputAction in mMenuControlsActionSet.digitalActionHandles)
         {
            _loc3_.push(_loc2_);
         }
         for each(var _loc4_:SteamInputAction in _loc3_)
         {
            _loc5_ = mSteamworks.getDigitalActionData(controllerHandle,_loc4_.actionHandle);
            writeDigitalActionState(_loc4_.actionName,_loc5_.bState);
         }
      }
      
      private function writeDigitalActionState(actionName:String, isDown:Boolean) : void
      {
         if(isDown)
         {
            if(!(actionName in mHeldDigitalButtons))
            {
               mPressedDigitalButtons[actionName] = true;
               mHeldDigitalButtons[actionName] = true;
            }
         }
         else if(actionName in mHeldDigitalButtons)
         {
            mReleasedDigitalButtons[actionName] = true;
            delete mHeldDigitalButtons[actionName];
         }
      }
   }
}

