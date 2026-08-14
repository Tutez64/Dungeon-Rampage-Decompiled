package SteamInput
{
   import Brain.Event.EventComponent;
   import Brain.Logger.Logger;
   import Facade.DBFacade;
   import com.amanitadesign.steam.FRESteamWorks;
   import flash.display.Stage;
   import flash.geom.Vector3D;
   import flash.utils.Dictionary;
   
   public class SteamInputManager
   {
      
      private var mSteamworks:FRESteamWorks;
      
      private var mEventComponent:EventComponent;
      
      private var mKeyboardEventSpoofer:KeyboardEventSpoofer;
      
      private var mIsInitialized:Boolean = false;
      
      private var mIsSteamInputManagerEnabled:Boolean = false;
      
      private var mControllerWasConnectedLastUpdate:Boolean = false;
      
      private var mHandlesToSteamControllers:Dictionary = new Dictionary();
      
      private var mConnectedSteamControllers:Vector.<SteamController> = new Vector.<SteamController>();
      
      private var mInGameControlsActionSet:SteamInputActionSet;
      
      private var mMenuControlsActionSet:SteamInputActionSet;
      
      private var mUseMenuControlsInsteadOfInGameControls:Boolean = true;
      
      private var mInputActionNameToControllerGlyphFilePath:Dictionary = new Dictionary();
      
      private const ZERO_VECTOR:Vector3D = new Vector3D(0,0,0);
      
      public function SteamInputManager(inDBFacade:DBFacade, inSteamworks:FRESteamWorks, stageRef:Stage, isSteamInputManagerEnabled:Boolean = true)
      {
         super();
         mSteamworks = inSteamworks;
         mIsSteamInputManagerEnabled = isSteamInputManagerEnabled;
         mEventComponent = new EventComponent(inDBFacade);
         mKeyboardEventSpoofer = new KeyboardEventSpoofer(stageRef);
      }
      
      public function destroy() : void
      {
         mConnectedSteamControllers.length = 0;
         for(var _loc1_:Object in mHandlesToSteamControllers)
         {
            delete mHandlesToSteamControllers[_loc1_];
         }
         mHandlesToSteamControllers = null;
         if(mEventComponent != null)
         {
            mEventComponent.destroy();
            mEventComponent = null;
         }
         mSteamworks.steamInputShutdown();
      }
      
      public function runFrame() : void
      {
         if(!mIsSteamInputManagerEnabled)
         {
            return;
         }
         if(!mIsInitialized)
         {
            initSteamInput();
            return;
         }
         mSteamworks.runFrame();
         checkForHardwareChanges();
         updateControllers();
         updateActionOrigins();
         mKeyboardEventSpoofer.update(this);
         fireButtonEvents();
      }
      
      private function updateActionOrigins() : void
      {
         var _loc3_:String = null;
         if(mConnectedSteamControllers.length <= 0)
         {
            return;
         }
         var _loc1_:Dictionary = new Dictionary();
         for each(var _loc2_:SteamInputAction in mMenuControlsActionSet.digitalActionHandles)
         {
            _loc3_ = getFilePathsOfControllerGlyphsAssignedToMenuControlsDigitalAction(_loc2_.actionName)[0];
            _loc1_[_loc2_.actionName] = _loc3_;
         }
         if(!dictionariesHaveSameContents(mInputActionNameToControllerGlyphFilePath,_loc1_))
         {
            mInputActionNameToControllerGlyphFilePath = _loc1_;
            mEventComponent.dispatchEvent(new SteamInputGlyphsChangedEvent());
         }
      }
      
      public function getFilePathsOfControllerGlyphsAssignedToMenuControlsDigitalAction(inActionName:String, inGlyphSize:uint = 0, inGlyphFlag:uint = 2) : Vector.<String>
      {
         var _loc6_:* = undefined;
         var _loc5_:Vector.<String> = new Vector.<String>();
         _loc6_ = getDigitalActionOriginsAssignedToMenuControlsAction(inActionName);
         if(_loc6_ == null)
         {
            Logger.warn("menuActionOrigins is null please ensure it\'s loaded properly.");
            return _loc5_;
         }
         for each(var _loc4_:String in _loc6_)
         {
            if(_loc4_ == null)
            {
               Logger.warn("origin is null please ensure menuActionOrigins is loaded properly.");
               return _loc5_;
            }
            _loc5_.push(mSteamworks.getGlyphPNGForActionOrigin(_loc4_,inGlyphSize,inGlyphFlag));
         }
         return _loc5_;
      }
      
      public function getGlyphFilePathForAction(inActionName:String) : String
      {
         return mInputActionNameToControllerGlyphFilePath[inActionName];
      }
      
      public function flushInputs() : void
      {
         for each(var _loc1_:SteamController in mConnectedSteamControllers)
         {
            _loc1_.flushInput();
         }
      }
      
      public function getAnalogAction(movementActionName:String) : Vector3D
      {
         var _loc2_:Vector3D = null;
         for each(var _loc3_:SteamController in mConnectedSteamControllers)
         {
            _loc2_ = _loc3_.analogInputs[movementActionName];
            if(_loc2_ != null)
            {
               if(_loc2_.lengthSquared > 0)
               {
                  return _loc2_;
               }
            }
         }
         ZERO_VECTOR.setTo(0,0,0);
         return ZERO_VECTOR;
      }
      
      public function fireButtonEvents() : void
      {
         for each(var _loc3_:SteamController in mConnectedSteamControllers)
         {
            for(var _loc1_:Object in _loc3_.pressedDigitalButtons)
            {
               mEventComponent.dispatchEvent(new OnSteamInputButtonPressedEvent(String(_loc1_)));
            }
            for(var _loc2_:Object in _loc3_.releasedDigitalButtons)
            {
               mEventComponent.dispatchEvent(new OnSteamInputButtonReleasedEvent(String(_loc2_)));
            }
         }
      }
      
      public function pressedAction(actionName:String) : Boolean
      {
         for each(var _loc2_:SteamController in mConnectedSteamControllers)
         {
            if(actionName in _loc2_.pressedDigitalButtons)
            {
               return true;
            }
         }
         return false;
      }
      
      public function releasedAction(actionName:String) : Boolean
      {
         for each(var _loc2_:SteamController in mConnectedSteamControllers)
         {
            if(actionName in _loc2_.releasedDigitalButtons)
            {
               return true;
            }
         }
         return false;
      }
      
      public function heldAction(actionName:String) : Boolean
      {
         for each(var _loc2_:SteamController in mConnectedSteamControllers)
         {
            if(actionName in _loc2_.heldDigitalButtons)
            {
               return true;
            }
         }
         return false;
      }
      
      public function activateInGameActionLayer() : void
      {
         mUseMenuControlsInsteadOfInGameControls = false;
      }
      
      public function activateMenuControlsActionLayer() : void
      {
         mUseMenuControlsInsteadOfInGameControls = true;
      }
      
      public function getDigitalActionOriginsAssignedToMenuControlsAction(inActionName:String) : Vector.<String>
      {
         var _loc4_:Vector.<String> = new Vector.<String>();
         if(mMenuControlsActionSet.digitalActionHandles == null || mConnectedSteamControllers == null)
         {
            Logger.warn("SteamInputManager: digitalActionHandles or connectedSteamControllers is null. Unable to getDigitalActionOriginsAssignedToMenuControlsAction.");
            return _loc4_;
         }
         for each(var _loc3_:SteamInputAction in mMenuControlsActionSet.digitalActionHandles)
         {
            if(_loc3_.actionName == inActionName)
            {
               for each(var _loc2_:SteamController in mConnectedSteamControllers)
               {
                  _loc4_.push(mSteamworks.getDigitalActionOrigins(_loc2_.controllerHandle,mMenuControlsActionSet.actionSetHandle,_loc3_.actionHandle));
               }
            }
         }
         return _loc4_;
      }
      
      public function get isUsingMenuControlsInsteadOfInGameControls() : Boolean
      {
         return mUseMenuControlsInsteadOfInGameControls;
      }
      
      public function get isSteamControllerConnected() : Boolean
      {
         return mSteamworks.isReady && mSteamworks.getConnectedControllers().length > 0;
      }
      
      private function initSteamInput() : void
      {
         if(!mSteamworks.isReady)
         {
            return;
         }
         var _loc1_:Boolean = Boolean(mSteamworks.inputInit());
         if(!_loc1_)
         {
            Logger.info("SteamInputManager: Steamworks inputInit failed");
            return;
         }
         mIsInitialized = true;
         Logger.info("SteamInputManager: Steam Input initialized.");
      }
      
      private function checkForHardwareChanges() : void
      {
         resetControllerConnectedStates();
         updateOrCreateConnectedControllers();
         removeDisconnectedControllers();
         if(mControllerWasConnectedLastUpdate != isSteamControllerConnected)
         {
            mEventComponent.dispatchEvent(new ControllerConnectionChangedEvent(isSteamControllerConnected));
            mControllerWasConnectedLastUpdate = isSteamControllerConnected;
         }
      }
      
      private function dictionariesHaveSameContents(inDictOne:Dictionary, inDictTwo:Dictionary) : Boolean
      {
         if(inDictOne.length != inDictTwo.length)
         {
            return false;
         }
         for(var _loc3_:Object in inDictOne)
         {
            if(inDictOne[_loc3_] != inDictTwo[_loc3_])
            {
               return false;
            }
         }
         return true;
      }
      
      private function resetControllerConnectedStates() : void
      {
         for each(var _loc1_:SteamController in mConnectedSteamControllers)
         {
            _loc1_.isConnected = false;
         }
      }
      
      private function updateOrCreateConnectedControllers() : void
      {
         var _loc2_:SteamController = null;
         var _loc1_:Array = mSteamworks.getConnectedControllers();
         if(!tryLazyLoadInGameActionSet(_loc1_))
         {
            return;
         }
         if(!tryLazyLoadMenuControlsActionSet(_loc1_))
         {
            return;
         }
         for each(var _loc3_:String in _loc1_)
         {
            _loc2_ = mHandlesToSteamControllers[_loc3_];
            if(_loc2_ == null)
            {
               _loc2_ = new SteamController(_loc3_,mInGameControlsActionSet,mMenuControlsActionSet);
               mHandlesToSteamControllers[_loc3_] = _loc2_;
            }
            if(mConnectedSteamControllers.indexOf(_loc2_) == -1)
            {
               mConnectedSteamControllers.push(_loc2_);
            }
            _loc2_.isConnected = true;
            if(mUseMenuControlsInsteadOfInGameControls)
            {
               mSteamworks.activateActionSet(_loc2_.controllerHandle,mMenuControlsActionSet.actionSetHandle);
            }
            else
            {
               mSteamworks.activateActionSet(_loc2_.controllerHandle,mInGameControlsActionSet.actionSetHandle);
            }
         }
      }
      
      private function tryLazyLoadMenuControlsActionSet(connectedControllerHandles:Array) : Boolean
      {
         if(mMenuControlsActionSet != null)
         {
            return true;
         }
         var _loc2_:SteamInputActionSet = tryLoadActionSet("MenuControls",connectedControllerHandles);
         if(_loc2_ == null)
         {
            return false;
         }
         mMenuControlsActionSet = _loc2_;
         return true;
      }
      
      private function tryLazyLoadInGameActionSet(connectedControllerHandles:Array) : Boolean
      {
         if(mInGameControlsActionSet != null)
         {
            return true;
         }
         var _loc2_:SteamInputActionSet = tryLoadActionSet("InGameControls",connectedControllerHandles);
         if(_loc2_ == null)
         {
            return false;
         }
         mInGameControlsActionSet = _loc2_;
         return true;
      }
      
      private function tryLoadActionSet(actionSetName:String, connectedControllerHandles:Array) : SteamInputActionSet
      {
         if(connectedControllerHandles.length == 0)
         {
            return null;
         }
         var _loc4_:String = mSteamworks.getActionSetHandle(actionSetName);
         if(_loc4_ == "0")
         {
            Logger.warn("SteamInputManager: Couldn\'t load actionSet \'" + actionSetName + "\'");
            return null;
         }
         var _loc6_:SteamInputActionSet = new SteamInputActionSet(actionSetName,_loc4_);
         var _loc3_:Boolean = false;
         var _loc5_:Boolean = false;
         if(actionSetName == "InGameControls")
         {
            _loc3_ = _loc6_.tryLoadAnalogActions(InGameControlsActionSetData.gatherAnalogActionNames(),mSteamworks);
            _loc5_ = _loc6_.tryLoadDigitalActions(InGameControlsActionSetData.gatherDigitalActionNames(),mSteamworks);
         }
         if(actionSetName == "MenuControls")
         {
            _loc3_ = _loc6_.tryLoadAnalogActions(MenuControlsActionSetData.gatherAnalogActionNames(),mSteamworks);
            _loc5_ = _loc6_.tryLoadDigitalActions(MenuControlsActionSetData.gatherDigitalActionNames(),mSteamworks);
         }
         if(!_loc3_ || !_loc5_)
         {
            Logger.warn("SteamInputManager: Couldn\'t load actionSet actions for \'" + actionSetName + "\'");
            return null;
         }
         return _loc6_;
      }
      
      private function removeDisconnectedControllers() : void
      {
         var _loc1_:int = 0;
         var _loc2_:SteamController = null;
         _loc1_ = mConnectedSteamControllers.length - 1;
         while(_loc1_ >= 0)
         {
            _loc2_ = mConnectedSteamControllers[_loc1_];
            if(!_loc2_.isConnected)
            {
               _loc2_.handleDisconnect();
               mConnectedSteamControllers.removeAt(_loc1_);
            }
            _loc1_--;
         }
      }
      
      private function updateControllers() : void
      {
         for each(var _loc1_:SteamController in mConnectedSteamControllers)
         {
            _loc1_.readInput(mSteamworks);
         }
      }
   }
}

