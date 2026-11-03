package Input
{
   import Brain.Event.EventComponent;
   import Brain.Input.*;
   import Brain.Logger.Logger;
   import Brain.UI.UIObject;
   import Facade.DBFacade;
   import SteamInput.OnSteamInputButtonPressedEvent;
   import SteamInput.OnSteamInputButtonReleasedEvent;
   import SteamInput.RumbleEffect;
   import SteamInput.SteamInputManager;
   import flash.utils.Dictionary;
   
   public class MenuNavigationController
   {
      
      private static const MAX_NAVIGATION_ITERATIONS:uint = 150;
      
      private static const RETURN_LAYERS:Array = ["EXIT_DUNGEON","EXIT_INFINITE_DUNGEON","TOWN_MENU","EXIT_POPUP"];
      
      private var mTopLayer:uint = 0;
      
      private var mUILayerConstants:Array = [];
      
      private var mSelectedUIObjs:Dictionary = new Dictionary();
      
      private var mDefaultUIObjs:Dictionary = new Dictionary();
      
      private var mLayerExitCallbacks:Dictionary = new Dictionary();
      
      private var mLayerPreviousCategoryCallbacks:Dictionary = new Dictionary();
      
      private var mLayerNextCategoryCallbacks:Dictionary = new Dictionary();
      
      private var mSteamInputActionsToKeyCodes:Dictionary = new Dictionary();
      
      private var mDBFacade:DBFacade;
      
      private var mSteamInputManager:SteamInputManager;
      
      private var mEventComponent:EventComponent;
      
      public function MenuNavigationController(dbFacade:DBFacade)
      {
         super();
         mDBFacade = dbFacade;
         mDBFacade.inputManager.registerMenuNavigationCallback(onKeyPressed);
         mSteamInputManager = mDBFacade.steamInputManager;
         mEventComponent = new EventComponent(mDBFacade);
         mEventComponent.addListener("OnSteamInputButtonPressedEvent",onSteamInputButtonPressed);
         mEventComponent.addListener("OnSteamInputButtonReleasedEvent",onSteamInputButtonReleased);
         UIObject.mouseFocusRequestHandler = onMouseRequestedFocus;
         mSteamInputActionsToKeyCodes["menu_left"] = 37;
         mSteamInputActionsToKeyCodes["menu_right"] = 39;
         mSteamInputActionsToKeyCodes["menu_up"] = 38;
         mSteamInputActionsToKeyCodes["menu_down"] = 40;
         mSteamInputActionsToKeyCodes["menu_select"] = 13;
         mSteamInputActionsToKeyCodes["menu_cancel"] = 27;
         mSteamInputActionsToKeyCodes["menu_previous_category"] = 81;
         mSteamInputActionsToKeyCodes["menu_next_category"] = 69;
         syncSteamInputActionSet();
      }
      
      public function getTopUILayer() : String
      {
         return mUILayerConstants[mTopLayer];
      }
      
      public function setLayerCategoryCallbacks(previousCategoryCallback:Function, nextCategoryCallback:Function, ownerLayer:String = null) : void
      {
         if(mTopLayer == 0 && ownerLayer == null)
         {
            return;
         }
         var _loc4_:String = ownerLayer ?? mUILayerConstants[mTopLayer];
         if(mUILayerConstants.indexOf(_loc4_) == -1)
         {
            return;
         }
         mLayerPreviousCategoryCallbacks[_loc4_] = previousCategoryCallback;
         mLayerNextCategoryCallbacks[_loc4_] = nextCategoryCallback;
      }
      
      public function pushNewLayer(layerConstant:String, layerExitCallback:Function, defaultObject:UIObject, focusedObject:UIObject = null, previousCategoryCallback:Function = null, nextCategoryCallback:Function = null) : void
      {
         if(mDefaultUIObjs[layerConstant] || mSelectedUIObjs[layerConstant] || mUILayerConstants.indexOf(layerConstant) != -1)
         {
            Logger.debugch("UI","Layer constant " + layerConstant + " already exists in the UI Manager");
            return;
         }
         Logger.debugch("UI","Pushing layer: " + layerConstant + " (Current Layers: " + getAllCurrentLayers() + ")");
         if(mFocusedUiObject)
         {
            mFocusedUiObject.setFocused(false);
         }
         mTopLayer = mTopLayer + 1;
         mUILayerConstants[mTopLayer] = layerConstant;
         mLayerExitCallbacks[layerConstant] = layerExitCallback;
         mLayerPreviousCategoryCallbacks[layerConstant] = previousCategoryCallback;
         mLayerNextCategoryCallbacks[layerConstant] = nextCategoryCallback;
         mDefaultUIObjs[layerConstant] = defaultObject;
         if(focusedObject != null && focusedObject.canBeFocused())
         {
            setFocusedUiObject(focusedObject);
         }
         else
         {
            setFocusedUiObject(defaultObject);
         }
         syncSteamInputActionSet();
      }
      
      public function popLayer(layerConstant:String) : void
      {
         if(layerConstant == null)
         {
            layerConstant = mUILayerConstants[mTopLayer];
         }
         if(mTopLayer == 0)
         {
            Logger.debugch("UI","No layers to pop");
            return;
         }
         if(mUILayerConstants[mTopLayer] != layerConstant)
         {
            Logger.debugch("UI","You tried to pop a layer that wasn\'t currently the top one. Layer attempted to be popped (Layerconstant): " + layerConstant + " Actual Current Top Layer: " + mUILayerConstants[mTopLayer]);
            return;
         }
         removeLayer(layerConstant);
      }
      
      public function removeLayer(layerConstant:String) : void
      {
         var _loc4_:int = mUILayerConstants.indexOf(layerConstant);
         if(_loc4_ < 1)
         {
            return;
         }
         var _loc3_:Boolean = _loc4_ == mTopLayer;
         Logger.debugch("UI",(_loc3_ ? "Popping layer: " : "Removing layer: ") + layerConstant + " (Current Layers: " + getAllCurrentLayers() + ")");
         var _loc2_:UIObject = mSelectedUIObjs[layerConstant];
         if(_loc2_)
         {
            _loc2_.setFocused(false);
         }
         delete mDefaultUIObjs[layerConstant];
         delete mSelectedUIObjs[layerConstant];
         delete mLayerExitCallbacks[layerConstant];
         delete mLayerPreviousCategoryCallbacks[layerConstant];
         delete mLayerNextCategoryCallbacks[layerConstant];
         mUILayerConstants.splice(_loc4_,1);
         mTopLayer = mTopLayer - 1;
         if(!_loc3_)
         {
            return;
         }
         syncSteamInputActionSet();
         if(mTopLayer == 0)
         {
            mFocusedUiObject = null;
            return;
         }
         if(mSelectedUIObjs[mUILayerConstants[mTopLayer]] != null)
         {
            setFocusedUiObject(mSelectedUIObjs[mUILayerConstants[mTopLayer]]);
         }
         else
         {
            setFocusedUiObject(mDefaultUIObjs[mUILayerConstants[mTopLayer]]);
         }
      }
      
      private function syncSteamInputActionSet() : void
      {
         if(mTopLayer > 0)
         {
            mSteamInputManager.activateMenuControlsActionLayer();
         }
         else
         {
            mSteamInputManager.activateInGameActionLayer();
         }
      }
      
      public function getAllCurrentLayers() : String
      {
         var _loc2_:int = 0;
         var _loc1_:String = "";
         _loc2_ = 1;
         while(_loc2_ < mUILayerConstants.length)
         {
            _loc1_ += mUILayerConstants[_loc2_] + ", ";
            _loc2_++;
         }
         return _loc1_;
      }
      
      public function get layerDepth() : uint
      {
         return mTopLayer;
      }
      
      public function get focusedUiObject() : UIObject
      {
         return mTopLayer == 0 ? null : mFocusedUiObject;
      }
      
      public function setFocusedUiObject(uiObject:UIObject, fromControllerNavigation:Boolean = false) : void
      {
         if(mTopLayer == 0)
         {
            Logger.debugch("UI","There\'s no UI Layer for you to set a Focused UIObject on because top layer is 0!");
            return;
         }
         if(uiObject == null)
         {
            Logger.debugch("UI","Cannot focus on a null UIObject");
            return;
         }
         if(mFocusedUiObject != uiObject)
         {
            if(mFocusedUiObject)
            {
               if(Boolean(mFocusedUiObject.navigationSetToUnselectedInteraction))
               {
                  mFocusedUiObject.navigationSetToUnselectedInteraction();
               }
               mFocusedUiObject.setFocused(false);
            }
            uiObject.setFocused(true);
            mFocusedUiObject = uiObject;
            if(fromControllerNavigation)
            {
               mSteamInputManager.playRumble(RumbleEffect.MENU_SELECTION);
            }
         }
         else if(!mFocusedUiObject.isFocused())
         {
            mFocusedUiObject.setFocused(true);
         }
      }
      
      private function onMouseRequestedFocus(uiObject:UIObject) : void
      {
         if(mTopLayer == 0 || uiObject == null || !uiObject.canBeFocused())
         {
            return;
         }
         if(!isInCurrentNavigationLayer(uiObject))
         {
            return;
         }
         mSteamInputManager.playRumble(RumbleEffect.MENU_SELECTION);
         if(mFocusedUiObject == uiObject)
         {
            return;
         }
         setFocusedUiObject(uiObject);
      }
      
      public function isInCurrentNavigationLayer(target:UIObject) : Boolean
      {
         return collectCurrentLayerObjects().indexOf(target) != -1;
      }
      
      public function collectCurrentLayerObjects() : Array
      {
         var _loc7_:UIObject = null;
         var _loc4_:UIObject = null;
         var _loc8_:Array = null;
         var _loc10_:Array = [];
         if(mTopLayer == 0)
         {
            return _loc10_;
         }
         var _loc2_:String = mUILayerConstants[mTopLayer];
         var _loc5_:Array = [mSelectedUIObjs[_loc2_],mDefaultUIObjs[_loc2_]];
         var _loc6_:Dictionary = new Dictionary(true);
         var _loc3_:Array = [];
         for each(_loc7_ in _loc5_)
         {
            if(_loc7_ != null && !_loc6_[_loc7_])
            {
               _loc6_[_loc7_] = true;
               _loc3_.push(_loc7_);
            }
         }
         var _loc9_:uint = 0;
         while(_loc3_.length > 0)
         {
            if(++_loc9_ >= 150)
            {
               Logger.debugch("UI","Menu navigation graph too large while walking layer: " + getTopUILayer() + " (Current Layers: " + getAllCurrentLayers() + ")");
               break;
            }
            _loc4_ = _loc3_.shift() as UIObject;
            _loc10_.push(_loc4_);
            _loc8_ = [_loc4_.leftNavigation,_loc4_.rightNavigation,_loc4_.upNavigation,_loc4_.downNavigation];
            for each(var _loc1_:UIObject in _loc8_)
            {
               if(_loc1_ != null && !_loc6_[_loc1_])
               {
                  _loc6_[_loc1_] = true;
                  _loc3_.push(_loc1_);
               }
            }
         }
         return _loc10_;
      }
      
      private function get mFocusedUiObject() : UIObject
      {
         return mSelectedUIObjs[mUILayerConstants[mTopLayer]];
      }
      
      private function set mFocusedUiObject(uiObject:UIObject) : void
      {
         mSelectedUIObjs[mUILayerConstants[mTopLayer]] = uiObject;
      }
      
      public function getNextAvailableNavLeftObject() : UIObject
      {
         var _loc1_:UIObject = mFocusedUiObject.leftNavigation;
         var _loc2_:uint = 0;
         while(_loc1_ != null && !_loc1_.canBeFocused())
         {
            if(++_loc2_ >= 150)
            {
               Logger.debugch("UI","Menu navigation infinite loop detected traversing LEFT from layer: " + getTopUILayer() + " (Current Layers: " + getAllCurrentLayers() + ")");
               return mFocusedUiObject;
            }
            _loc1_ = _loc1_.leftNavigation;
         }
         if(_loc1_)
         {
            return _loc1_;
         }
         return mFocusedUiObject;
      }
      
      public function getNextAvailableNavRightObject() : UIObject
      {
         var _loc1_:UIObject = mFocusedUiObject.rightNavigation;
         var _loc2_:uint = 0;
         while(_loc1_ != null && !_loc1_.canBeFocused())
         {
            if(++_loc2_ >= 150)
            {
               Logger.debugch("UI","Menu navigation infinite loop detected traversing RIGHT from layer: " + getTopUILayer() + " (Current Layers: " + getAllCurrentLayers() + ")");
               return mFocusedUiObject;
            }
            _loc1_ = _loc1_.rightNavigation;
         }
         if(_loc1_)
         {
            return _loc1_;
         }
         return mFocusedUiObject;
      }
      
      public function getNextAvailableNavUpObject() : UIObject
      {
         var _loc1_:UIObject = mFocusedUiObject.upNavigation;
         var _loc2_:uint = 0;
         while(_loc1_ != null && !_loc1_.canBeFocused())
         {
            if(++_loc2_ >= 150)
            {
               Logger.debugch("UI","Menu navigation infinite loop detected traversing UP from layer: " + getTopUILayer() + " (Current Layers: " + getAllCurrentLayers() + ")");
               return mFocusedUiObject;
            }
            _loc1_ = _loc1_.upNavigation;
         }
         if(_loc1_)
         {
            return _loc1_;
         }
         return mFocusedUiObject;
      }
      
      public function getNextAvailableNavDownObject() : UIObject
      {
         var _loc1_:UIObject = mFocusedUiObject.downNavigation;
         var _loc2_:uint = 0;
         while(_loc1_ != null && !_loc1_.canBeFocused())
         {
            if(++_loc2_ >= 150)
            {
               Logger.debugch("UI","Menu navigation infinite loop detected traversing DOWN from layer: " + getTopUILayer() + " (Current Layers: " + getAllCurrentLayers() + ")");
               return mFocusedUiObject;
            }
            _loc1_ = _loc1_.downNavigation;
         }
         if(_loc1_)
         {
            return _loc1_;
         }
         return mFocusedUiObject;
      }
      
      private function onSteamInputButtonPressed(eventData:OnSteamInputButtonPressedEvent) : void
      {
         for(var _loc2_:String in mSteamInputActionsToKeyCodes)
         {
            if(mSteamInputManager.pressedAction(_loc2_))
            {
               onKeyPressed(mSteamInputActionsToKeyCodes[_loc2_],true);
            }
         }
      }
      
      private function onSteamInputButtonReleased(eventData:OnSteamInputButtonReleasedEvent) : void
      {
         if(eventData.actionName != "menu_return")
         {
            return;
         }
         var _loc2_:String = mUILayerConstants[mTopLayer];
         if(RETURN_LAYERS.indexOf(_loc2_) != -1 && mLayerExitCallbacks[_loc2_])
         {
            mLayerExitCallbacks[_loc2_]();
         }
      }
      
      public function onKeyPressed(inputCode:int, fromController:Boolean = false) : void
      {
         var _loc4_:UIObject = null;
         var _loc3_:String = mUILayerConstants[mTopLayer];
         if(inputCode == 81)
         {
            if(mLayerPreviousCategoryCallbacks[_loc3_] != null)
            {
               mLayerPreviousCategoryCallbacks[_loc3_]();
            }
            return;
         }
         if(inputCode == 69)
         {
            if(mLayerNextCategoryCallbacks[_loc3_] != null)
            {
               mLayerNextCategoryCallbacks[_loc3_]();
            }
            return;
         }
         if(mFocusedUiObject != null)
         {
            _loc4_ = null;
            if(inputCode == 37)
            {
               _loc4_ = getNextAvailableNavLeftObject();
               if(_loc4_ != null)
               {
                  if(Boolean(mFocusedUiObject.leftNavigationAdditionalInteraction))
                  {
                     mFocusedUiObject.leftNavigationAdditionalInteraction();
                  }
                  setFocusedUiObject(_loc4_,fromController);
                  if(Boolean(mFocusedUiObject.navigationSelectedInteraction))
                  {
                     mFocusedUiObject.navigationSelectedInteraction();
                  }
               }
            }
            else if(inputCode == 39)
            {
               _loc4_ = getNextAvailableNavRightObject();
               if(_loc4_ != null)
               {
                  if(Boolean(mFocusedUiObject.rightNavigationAdditionalInteraction))
                  {
                     mFocusedUiObject.rightNavigationAdditionalInteraction();
                  }
                  setFocusedUiObject(_loc4_,fromController);
                  if(Boolean(mFocusedUiObject.navigationSelectedInteraction))
                  {
                     mFocusedUiObject.navigationSelectedInteraction();
                  }
               }
            }
            else if(inputCode == 38)
            {
               _loc4_ = getNextAvailableNavUpObject();
               if(_loc4_ != null)
               {
                  if(Boolean(mFocusedUiObject.upNavigationAdditionalInteraction))
                  {
                     mFocusedUiObject.upNavigationAdditionalInteraction();
                  }
                  setFocusedUiObject(_loc4_,fromController);
                  if(Boolean(mFocusedUiObject.navigationSelectedInteraction))
                  {
                     mFocusedUiObject.navigationSelectedInteraction();
                  }
               }
            }
            else if(inputCode == 40)
            {
               _loc4_ = getNextAvailableNavDownObject();
               if(_loc4_ != null)
               {
                  if(Boolean(mFocusedUiObject.downNavigationAdditionalInteraction))
                  {
                     mFocusedUiObject.downNavigationAdditionalInteraction();
                  }
                  setFocusedUiObject(_loc4_,fromController);
                  if(Boolean(mFocusedUiObject.navigationSelectedInteraction))
                  {
                     mFocusedUiObject.navigationSelectedInteraction();
                  }
               }
            }
            else if(inputCode == 13)
            {
               if(mFocusedUiObject.enabled && mFocusedUiObject.visible)
               {
                  mFocusedUiObject.onSelected(fromController);
               }
               else
               {
                  Logger.debugch("UI","Attempted to press UIObject when it was not enabled or visible (Enabled: " + mFocusedUiObject.enabled.toString() + " Visible: " + mFocusedUiObject.visible.toString() + ")");
               }
            }
            else if(inputCode == 27)
            {
               if(mLayerExitCallbacks[mUILayerConstants[mTopLayer]])
               {
                  mLayerExitCallbacks[mUILayerConstants[mTopLayer]]();
               }
            }
         }
      }
   }
}

