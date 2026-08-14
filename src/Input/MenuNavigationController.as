package Input
{
   import Brain.Event.EventComponent;
   import Brain.Input.*;
   import Brain.Logger.Logger;
   import Brain.UI.UIObject;
   import Facade.DBFacade;
   import SteamInput.OnSteamInputButtonPressedEvent;
   import SteamInput.SteamInputManager;
   import flash.utils.Dictionary;
   
   public class MenuNavigationController
   {
      
      private static const MAX_NAVIGATION_ITERATIONS:uint = 100;
      
      private var mTopLayer:uint = 0;
      
      private var mUILayerConstants:Array = [];
      
      private var mSelectedUIObjs:Dictionary = new Dictionary();
      
      private var mDefaultUIObjs:Dictionary = new Dictionary();
      
      private var mLayerExitCallbacks:Dictionary = new Dictionary();
      
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
         mSteamInputActionsToKeyCodes["menu_left"] = 37;
         mSteamInputActionsToKeyCodes["menu_right"] = 39;
         mSteamInputActionsToKeyCodes["menu_up"] = 38;
         mSteamInputActionsToKeyCodes["menu_down"] = 40;
         mSteamInputActionsToKeyCodes["menu_select"] = 13;
         mSteamInputActionsToKeyCodes["menu_cancel"] = 27;
      }
      
      public function getTopUILayer() : String
      {
         return mUILayerConstants[mTopLayer];
      }
      
      public function pushNewLayer(layerConstant:String, layerExitCallback:Function, defaultObject:UIObject, focusedObject:UIObject = null) : void
      {
         if(mDefaultUIObjs[layerConstant] || mSelectedUIObjs[layerConstant] || mUILayerConstants.indexOf(layerConstant) != -1)
         {
            Logger.warn("Layer constant " + layerConstant + " already exists in the UI Manager");
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
         mDefaultUIObjs[layerConstant] = defaultObject;
         if(focusedObject != null)
         {
            setFocusedUiObject(focusedObject);
         }
         else
         {
            setFocusedUiObject(defaultObject);
         }
         mDBFacade.steamInputManager.activateMenuControlsActionLayer();
      }
      
      public function popLayer(layerConstant:String) : void
      {
         if(layerConstant == null)
         {
            layerConstant = mUILayerConstants[mTopLayer];
         }
         Logger.debugch("UI","Popping layer: " + layerConstant + "(Current Layers: " + getAllCurrentLayers() + ")");
         if(mTopLayer == 0)
         {
            Logger.warn("No layers to pop");
            return;
         }
         if(mUILayerConstants[mTopLayer] != layerConstant)
         {
            Logger.warn("You tried to pop a layer that wasn\'t currently the top one. Layer attempted to be popped (Layerconstant): " + layerConstant + " Actual Current Top Layer: " + mUILayerConstants[mTopLayer]);
            return;
         }
         delete mDefaultUIObjs[layerConstant];
         delete mSelectedUIObjs[layerConstant];
         delete mLayerExitCallbacks[layerConstant];
         mUILayerConstants.pop();
         mTopLayer = mTopLayer - 1;
         if(mTopLayer == 0)
         {
            mFocusedUiObject = null;
            mDBFacade.steamInputManager.activateInGameActionLayer();
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
      
      public function setFocusedUiObject(uiObject:UIObject) : void
      {
         if(mTopLayer == 0)
         {
            Logger.warn("There\'s no UI Layer for you to set a Focused UIObject on because top layer is 0!");
            return;
         }
         if(uiObject == null)
         {
            Logger.warn("Cannot focus on a null UIObject");
            return;
         }
         if(mFocusedUiObject != uiObject)
         {
            if(mFocusedUiObject)
            {
               mFocusedUiObject.setFocused(false);
            }
            uiObject.setFocused(true);
            mFocusedUiObject = uiObject;
         }
         else if(!mFocusedUiObject.isFocused())
         {
            mFocusedUiObject.setFocused(true);
         }
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
            if(++_loc2_ >= 100)
            {
               Logger.warn("Menu navigation infinite loop detected traversing LEFT from layer: " + getTopUILayer() + " (Current Layers: " + getAllCurrentLayers() + ")");
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
            if(++_loc2_ >= 100)
            {
               Logger.warn("Menu navigation infinite loop detected traversing RIGHT from layer: " + getTopUILayer() + " (Current Layers: " + getAllCurrentLayers() + ")");
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
            if(++_loc2_ >= 100)
            {
               Logger.warn("Menu navigation infinite loop detected traversing UP from layer: " + getTopUILayer() + " (Current Layers: " + getAllCurrentLayers() + ")");
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
            if(++_loc2_ >= 100)
            {
               Logger.warn("Menu navigation infinite loop detected traversing DOWN from layer: " + getTopUILayer() + " (Current Layers: " + getAllCurrentLayers() + ")");
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
               onKeyPressed(mSteamInputActionsToKeyCodes[_loc2_]);
            }
         }
      }
      
      public function onKeyPressed(inputCode:int) : void
      {
         var _loc2_:UIObject = null;
         if(mFocusedUiObject != null)
         {
            _loc2_ = null;
            if(inputCode == 37)
            {
               _loc2_ = getNextAvailableNavLeftObject();
               if(_loc2_ != null)
               {
                  if(Boolean(mFocusedUiObject.leftNavigationAdditionalInteraction))
                  {
                     mFocusedUiObject.leftNavigationAdditionalInteraction();
                  }
                  if(Boolean(mFocusedUiObject.navigationSetToUnselectedInteraction))
                  {
                     mFocusedUiObject.navigationSetToUnselectedInteraction();
                  }
                  setFocusedUiObject(_loc2_);
                  if(Boolean(mFocusedUiObject.navigationSelectedInteraction))
                  {
                     mFocusedUiObject.navigationSelectedInteraction();
                  }
               }
            }
            else if(inputCode == 39)
            {
               _loc2_ = getNextAvailableNavRightObject();
               if(_loc2_ != null)
               {
                  if(Boolean(mFocusedUiObject.rightNavigationAdditionalInteraction))
                  {
                     mFocusedUiObject.rightNavigationAdditionalInteraction();
                  }
                  if(Boolean(mFocusedUiObject.navigationSetToUnselectedInteraction))
                  {
                     mFocusedUiObject.navigationSetToUnselectedInteraction();
                  }
                  setFocusedUiObject(_loc2_);
                  if(Boolean(mFocusedUiObject.navigationSelectedInteraction))
                  {
                     mFocusedUiObject.navigationSelectedInteraction();
                  }
               }
            }
            else if(inputCode == 38)
            {
               _loc2_ = getNextAvailableNavUpObject();
               if(_loc2_ != null)
               {
                  if(Boolean(mFocusedUiObject.upNavigationAdditionalInteraction))
                  {
                     mFocusedUiObject.upNavigationAdditionalInteraction();
                  }
                  if(Boolean(mFocusedUiObject.navigationSetToUnselectedInteraction))
                  {
                     mFocusedUiObject.navigationSetToUnselectedInteraction();
                  }
                  setFocusedUiObject(_loc2_);
                  if(Boolean(mFocusedUiObject.navigationSelectedInteraction))
                  {
                     mFocusedUiObject.navigationSelectedInteraction();
                  }
               }
            }
            else if(inputCode == 40)
            {
               _loc2_ = getNextAvailableNavDownObject();
               if(_loc2_ != null)
               {
                  if(Boolean(mFocusedUiObject.downNavigationAdditionalInteraction))
                  {
                     mFocusedUiObject.downNavigationAdditionalInteraction();
                  }
                  if(Boolean(mFocusedUiObject.navigationSetToUnselectedInteraction))
                  {
                     mFocusedUiObject.navigationSetToUnselectedInteraction();
                  }
                  setFocusedUiObject(_loc2_);
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
                  mFocusedUiObject.onSelected();
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

