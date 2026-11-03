package SteamInput
{
   import Brain.AssetRepository.AssetLoader;
   import Brain.Event.EventComponent;
   import Brain.Logger.Logger;
   import Facade.DBFacade;
   import com.amanitadesign.steam.FRESteamWorks;
   import flash.display.DisplayObject;
   import flash.display.Stage;
   import flash.filesystem.File;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import flash.utils.Dictionary;
   
   public class SteamInputManager
   {
      
      private static const GAMEPAD_DEADZONE_TOLERANCE:Number = 0.05;
      
      private var mDBFacade:DBFacade;
      
      private var mSteamworks:FRESteamWorks;
      
      private var mEventComponent:EventComponent;
      
      private var mKeyboardEventSpoofer:KeyboardEventSpoofer;
      
      private var mControllerRumble:ControllerRumble;
      
      private var mLocalGlyphs:LocalSteamInputGlyphs = new LocalSteamInputGlyphs();
      
      private var mLoggedGlyphOrigins:Dictionary = new Dictionary();
      
      private var mIsInitialized:Boolean = false;
      
      private var mIsSteamInputManagerEnabled:Boolean = false;
      
      private var mControllerWasConnectedLastUpdate:Boolean = false;
      
      private var mHandlesToSteamControllers:Dictionary = new Dictionary();
      
      private var mConnectedSteamControllers:Vector.<SteamController> = new Vector.<SteamController>();
      
      private var mLastActiveSteamController:SteamController;
      
      private var mIsRunningOnSteamDeck:Boolean = false;
      
      private var mInGameControlsActionSet:SteamInputActionSet;
      
      private var mMenuControlsActionSet:SteamInputActionSet;
      
      private var mUseMenuControlsInsteadOfInGameControls:Boolean = true;
      
      private var mHasLoggedActionSetLoadFailure:Boolean = false;
      
      private var mActionManifestSetupHasRun:Boolean = false;
      
      private var mInputActionNameToControllerGlyphFilePath:Dictionary = new Dictionary();
      
      private const ZERO_VECTOR:Vector3D = new Vector3D(0,0,0);
      
      private var mIsInActionSetWarningState:Boolean = false;
      
      public function SteamInputManager(inDBFacade:DBFacade, inSteamworks:FRESteamWorks, stageRef:Stage, isSteamInputManagerEnabled:Boolean = true)
      {
         super();
         mDBFacade = inDBFacade;
         mSteamworks = inSteamworks;
         mIsSteamInputManagerEnabled = isSteamInputManagerEnabled;
         mEventComponent = new EventComponent(inDBFacade);
         mControllerRumble = new ControllerRumble(inDBFacade,inSteamworks);
         mKeyboardEventSpoofer = new KeyboardEventSpoofer(stageRef,inDBFacade.keyBindings);
      }
      
      private static function controllerHasActiveInput(steamController:SteamController) : Boolean
      {
         var _loc5_:int = 0;
         var _loc4_:Dictionary = steamController.heldDigitalButtons;
         for(var _loc2_:Object in _loc4_)
         {
            return true;
         }
         for each(var _loc3_:Vector3D in steamController.analogInputs)
         {
            if(_loc3_ != null && _loc3_.lengthSquared > 0.05)
            {
               return true;
            }
         }
         return false;
      }
      
      private static function pushActionOrigins(digitalActionOrigins:Vector.<String>, origins:Array) : void
      {
         for each(var _loc3_:Object in origins)
         {
            digitalActionOrigins.push(String(_loc3_));
         }
      }
      
      public function destroy() : void
      {
         mControllerRumble.stopAll();
         mControllerRumble.update(mConnectedSteamControllers);
         mControllerRumble = null;
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
         reconcileControllerStateAndNotify();
         updateControllers();
         var _loc1_:Boolean = updateLastActiveController();
         updateActionOrigins();
         mControllerRumble.update(mConnectedSteamControllers);
         mKeyboardEventSpoofer.update(this);
         if(_loc1_)
         {
            mDBFacade.mouseCursorManager.hideMouseCursor();
         }
         fireButtonEvents();
      }
      
      private function updateLastActiveController() : Boolean
      {
         for each(var _loc1_:SteamController in mConnectedSteamControllers)
         {
            if(controllerHasActiveInput(_loc1_))
            {
               mLastActiveSteamController = _loc1_;
               return true;
            }
         }
         return false;
      }
      
      private function get glyphController() : SteamController
      {
         if(mLastActiveSteamController != null && mConnectedSteamControllers.indexOf(mLastActiveSteamController) != -1)
         {
            return mLastActiveSteamController;
         }
         if(mConnectedSteamControllers.length == 0)
         {
            return null;
         }
         if(mIsRunningOnSteamDeck)
         {
            for each(var _loc1_:SteamController in mConnectedSteamControllers)
            {
               if(mSteamworks.getInputTypeForHandle(_loc1_.controllerHandle) == 14)
               {
                  return _loc1_;
               }
            }
         }
         return mConnectedSteamControllers[0];
      }
      
      private function updateActionOrigins() : void
      {
         var _loc3_:String = null;
         var _loc6_:String = null;
         if(!isSteamInputReady)
         {
            return;
         }
         var _loc2_:Dictionary = new Dictionary();
         var _loc5_:Boolean = false;
         for each(var _loc1_:SteamInputAction in mMenuControlsActionSet.digitalActionHandles)
         {
            _loc3_ = getFirstGlyphFilePathForDigitalAction(_loc1_.actionName);
            if(!mIsInActionSetWarningState)
            {
               if(_loc3_ == "error1")
               {
                  _loc5_ = true;
                  Logger.warnch("Input","SteamInputManager: Couldn\'t load Menu actionSet \'" + _loc1_.actionName + "\'");
               }
            }
            _loc2_[_loc1_.actionName] = _loc3_;
         }
         for each(var _loc4_:SteamInputAction in mInGameControlsActionSet.digitalActionHandles)
         {
            _loc6_ = getFirstGlyphFilePathForDigitalAction(_loc4_.actionName);
            if(!mIsInActionSetWarningState)
            {
               if(_loc6_ == "error1")
               {
                  _loc5_ = true;
                  Logger.warnch("Input","SteamInputManager: Couldn\'t load In-Game actionSet \'" + _loc4_.actionName + "\'");
               }
            }
            _loc2_[_loc4_.actionName] = _loc6_;
         }
         if(_loc5_)
         {
            mIsInActionSetWarningState = true;
         }
         if(!dictionariesHaveSameContents(mInputActionNameToControllerGlyphFilePath,_loc2_))
         {
            mInputActionNameToControllerGlyphFilePath = _loc2_;
            mEventComponent.dispatchEvent(new SteamInputGlyphsChangedEvent());
         }
      }
      
      private function getFirstGlyphFilePathForDigitalAction(inActionName:String) : String
      {
         var _loc2_:Vector.<String> = getFilePathsOfGlyphsAssignedToDigitalAction(inActionName);
         return _loc2_.length > 0 ? _loc2_[0] : null;
      }
      
      public function getFilePathsOfGlyphsAssignedToDigitalAction(inActionName:String, inGlyphSize:uint = 1, inGlyphFlag:uint = 2) : Vector.<String>
      {
         var _loc4_:Vector.<String> = getDigitalActionOriginsAssignedToControlsAction(inActionName);
         var _loc6_:Vector.<String> = new Vector.<String>();
         if(_loc4_ == null)
         {
            Logger.warnch("Input","actionOrigins is null please ensure it\'s loaded properly.");
            return _loc6_;
         }
         for each(var _loc5_:String in _loc4_)
         {
            if(_loc5_ == null)
            {
               Logger.warnch("Input","origin is null please ensure actionOrigins is loaded properly.");
               return _loc6_;
            }
            _loc6_.push(getGlyphFilePathForOrigin(_loc5_,inGlyphSize,inGlyphFlag));
         }
         return _loc6_;
      }
      
      public function getGlyphFilePathForOrigin(origin:String, glyphSize:uint = 1, glyphFlag:uint = 2) : String
      {
         var _loc6_:String = mSteamworks.getGlyphPNGForActionOrigin(origin,glyphSize,glyphFlag);
         var _loc4_:String = getControllerGlyphPreference();
         var _loc5_:String = mLocalGlyphs.getGlyphPath(_loc6_,_loc4_);
         if(_loc5_ != null)
         {
            logGlyphResolutionOnce(origin,"preferred \'" + _loc4_ + "\' glyph \'" + _loc5_ + "\'");
            return _loc5_;
         }
         logGlyphResolutionOnce(origin,"Steam fallback \'" + _loc6_ + "\' (preferred family: \'" + _loc4_ + "\')");
         return _loc6_;
      }
      
      private function getControllerGlyphPreference() : String
      {
         var _loc1_:String = mDBFacade.dbConfigManager.getConfigString("ControllerGlyphPreference","");
         if(_loc1_ != "")
         {
            return _loc1_;
         }
         var _loc2_:SteamController = glyphController;
         if(_loc2_ == null)
         {
            return "";
         }
         switch(int(mSteamworks.getInputTypeForHandle(_loc2_.controllerHandle)) - 1)
         {
            case 0:
               return "Steam";
            case 1:
               return "Xbox 360";
            case 2:
               return "Xbox One";
            case 4:
               return "PS4";
            case 7:
            case 8:
            case 9:
               return "Switch";
            case 11:
               return "PS3";
            case 12:
               return "PS5";
            case 13:
               return "Steam Deck";
            default:
               return "";
         }
      }
      
      private function logGlyphResolutionOnce(origin:String, resolution:String) : void
      {
         if(mLoggedGlyphOrigins[origin])
         {
            return;
         }
         mLoggedGlyphOrigins[origin] = true;
         Logger.infoch("Input","SteamInputManager: Glyph origin \'" + origin + "\' resolved to " + resolution + ".");
      }
      
      public function getGlyphFilePathForAction(inActionName:String) : String
      {
         if(mInputActionNameToControllerGlyphFilePath[inActionName] == null || mInputActionNameToControllerGlyphFilePath[inActionName] == "error1")
         {
            updateActionOrigins();
         }
         return mInputActionNameToControllerGlyphFilePath[inActionName];
      }
      
      public function getGlyphFilePathForAnalogAction(inActionName:String) : String
      {
         var _loc3_:Array = null;
         var _loc4_:SteamController = glyphController;
         if(!isSteamInputReady || _loc4_ == null)
         {
            return null;
         }
         for each(var _loc5_:SteamInputActionSet in [mInGameControlsActionSet,mMenuControlsActionSet])
         {
            for each(var _loc2_:SteamInputAction in _loc5_.analogActionHandles)
            {
               if(_loc2_.actionName == inActionName)
               {
                  _loc3_ = mSteamworks.getAnalogActionOrigins(_loc4_.controllerHandle,_loc5_.actionSetHandle,_loc2_.actionHandle);
                  if(_loc3_ == null || _loc3_.length == 0)
                  {
                     return null;
                  }
                  return getGlyphFilePathForOrigin(String(_loc3_[0]));
               }
            }
         }
         return null;
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
         if(mUseMenuControlsInsteadOfInGameControls)
         {
            flushInputs();
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
      
      public function getDigitalActionOriginsAssignedToControlsAction(inActionName:String) : Vector.<String>
      {
         var _loc4_:Vector.<String> = new Vector.<String>();
         var _loc5_:SteamController = glyphController;
         if(mMenuControlsActionSet == null || mInGameControlsActionSet == null || _loc5_ == null || mMenuControlsActionSet.digitalActionHandles == null || mInGameControlsActionSet.digitalActionHandles == null)
         {
            Logger.warnch("Input","SteamInputManager: digitalActionHandles or connectedSteamControllers is null. Unable to getDigitalActionOriginsAssignedToMenuControlsAction.");
            return _loc4_;
         }
         for each(var _loc2_:SteamInputAction in mMenuControlsActionSet.digitalActionHandles)
         {
            if(_loc2_.actionName == inActionName)
            {
               pushActionOrigins(_loc4_,mSteamworks.getDigitalActionOrigins(_loc5_.controllerHandle,mMenuControlsActionSet.actionSetHandle,_loc2_.actionHandle));
            }
         }
         for each(var _loc3_:SteamInputAction in mInGameControlsActionSet.digitalActionHandles)
         {
            if(_loc3_.actionName == inActionName)
            {
               pushActionOrigins(_loc4_,mSteamworks.getDigitalActionOrigins(_loc5_.controllerHandle,mInGameControlsActionSet.actionSetHandle,_loc3_.actionHandle));
            }
         }
         return _loc4_;
      }
      
      public function get isUsingMenuControlsInsteadOfInGameControls() : Boolean
      {
         return mUseMenuControlsInsteadOfInGameControls;
      }
      
      public function get isSteamInputReady() : Boolean
      {
         return mConnectedSteamControllers != null && mConnectedSteamControllers.length > 0;
      }
      
      public function get wantsControllerPrompts() : Boolean
      {
         return isSteamInputReady;
      }
      
      public function hasGlyphForAction(inActionName:String) : Boolean
      {
         if(!isSteamInputReady)
         {
            return false;
         }
         var _loc2_:String = getGlyphFilePathForAction(inActionName);
         return _loc2_ != null && _loc2_ != "" && _loc2_ != "error1";
      }
      
      public function get isRunningOnSteamDeck() : Boolean
      {
         return mIsRunningOnSteamDeck;
      }
      
      public function get usesSteamOnScreenKeyboard() : Boolean
      {
         return isBigPictureMode() || mIsRunningOnSteamDeck;
      }
      
      private function initSteamInput() : void
      {
         if(!mSteamworks.isReady)
         {
            return;
         }
         if(mDBFacade.dbConfigManager == null)
         {
            return;
         }
         if(!mActionManifestSetupHasRun)
         {
            mActionManifestSetupHasRun = true;
            setActionManifestFilePathFromConfig();
            mIsRunningOnSteamDeck = mSteamworks.isSteamRunningOnSteamDeck();
            if(mIsRunningOnSteamDeck && mDBFacade.mouseCursorManager)
            {
               mDBFacade.mouseCursorManager.hideMouseCursor();
            }
            return;
         }
         var _loc1_:Boolean = Boolean(mSteamworks.inputInit());
         if(!_loc1_)
         {
            Logger.infoch("Input","SteamInputManager: Steamworks inputInit failed");
            return;
         }
         mControllerRumble.isEnabled = mDBFacade.dbConfigManager.getConfigBoolean("ControllerVibrationEnabled",true);
         mIsInitialized = true;
         Logger.infoch("Input","SteamInputManager: Steam Input initialized." + (mIsRunningOnSteamDeck ? " Running on a Steam Deck." : ""));
      }
      
      private function setActionManifestFilePathFromConfig() : void
      {
         var _loc2_:String = mDBFacade.dbConfigManager.getConfigString("ActionManifestRelativePath","");
         if(_loc2_ == "")
         {
            return;
         }
         var _loc1_:File = AssetLoader.resolveFile(_loc2_);
         if(!_loc1_.exists)
         {
            Logger.warnch("Input","SteamInputManager: Action manifest file not found at \'" + _loc1_.nativePath + "\'");
            return;
         }
         if(!mSteamworks.setInputActionManifestFilePath(_loc1_.nativePath))
         {
            Logger.warnch("Input","SteamInputManager: setInputActionManifestFilePath failed for \'" + _loc1_.nativePath + "\'");
         }
      }
      
      private function reconcileControllerStateAndNotify() : void
      {
         resetControllerConnectedStates();
         updateOrCreateConnectedControllers();
         removeDisconnectedControllers();
         if(mControllerWasConnectedLastUpdate != isSteamInputReady)
         {
            mControllerRumble.forgetHardwareState();
            mEventComponent.dispatchEvent(new ControllerConnectionChangedEvent(isSteamInputReady));
            mControllerWasConnectedLastUpdate = isSteamInputReady;
         }
      }
      
      private function dictionariesHaveSameContents(inDictOne:Dictionary, inDictTwo:Dictionary) : Boolean
      {
         for(var _loc4_:Object in inDictOne)
         {
            if(inDictOne[_loc4_] != inDictTwo[_loc4_])
            {
               return false;
            }
         }
         for(var _loc3_:Object in inDictTwo)
         {
            if(inDictTwo[_loc3_] != inDictOne[_loc3_])
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
            if(!mHasLoggedActionSetLoadFailure)
            {
               Logger.warnch("Input","SteamInputManager: Couldn\'t load actionSet \'" + actionSetName + "\'");
               mHasLoggedActionSetLoadFailure = true;
            }
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
            if(!mHasLoggedActionSetLoadFailure)
            {
               Logger.warnch("Input","SteamInputManager: Couldn\'t load actionSet actions for \'" + actionSetName + "\'");
               mHasLoggedActionSetLoadFailure = true;
            }
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
      
      public function isBigPictureMode() : Boolean
      {
         return mSteamworks.isSteamInBigPictureMode();
      }
      
      public function showFloatingGamepadTextInputForField(field:DisplayObject) : void
      {
         var _loc2_:Stage = null;
         if(field == null || field.stage == null)
         {
            Logger.warnch("Input","Steam floating keyboard requested for a text field that is not on stage");
            _loc2_ = mDBFacade.stageRef;
            showFloatingGamepadTextInput(0,_loc2_.stageHeight / 2,_loc2_.stageWidth,_loc2_.stageHeight / 2);
            return;
         }
         var _loc5_:Rectangle = field.getBounds(field.stage);
         var _loc4_:int = Math.floor(_loc5_.left);
         var _loc3_:int = Math.floor(_loc5_.top);
         showFloatingGamepadTextInput(_loc4_,_loc3_,Math.ceil(_loc5_.right) - _loc4_,Math.ceil(_loc5_.bottom) - _loc3_);
      }
      
      private function showFloatingGamepadTextInput(textFieldXPosition:int, textFieldYPosition:int, textFieldWidth:int, textFieldHeight:int) : void
      {
         var _loc5_:int = 0;
         if(!mSteamworks.showFloatingGamepadTextInput(_loc5_,textFieldXPosition,textFieldYPosition,textFieldWidth,textFieldHeight))
         {
            Logger.warnch("Input","Steam Input Manager couldn\'t open the virtual keyboard");
         }
      }
      
      public function playRumble(effect:RumbleEffect) : void
      {
         mControllerRumble.play(effect);
      }
      
      public function stopRumble() : void
      {
         mControllerRumble.stopAll();
      }
      
      public function get isRumbleEnabled() : Boolean
      {
         return mControllerRumble.isEnabled;
      }
      
      public function set isRumbleEnabled(value:Boolean) : void
      {
         mControllerRumble.isEnabled = value;
      }
   }
}

