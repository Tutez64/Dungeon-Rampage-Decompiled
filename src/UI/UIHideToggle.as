package UI
{
   import Brain.Event.EventComponent;
   import Brain.Event.EventListeners;
   import Brain.Starling.StarlingLayer;
   import Brain.Starling.StarlingLayerManager;
   import Facade.DBFacade;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   
   public class UIHideToggle
   {
      
      public static const CHANGED_EVENT:String = "UI_HIDE_TOGGLE_CHANGED";
      
      public static const TOGGLE_KEY:int = 119;
      
      private static const KEY_LISTENER_PRIORITY:int = 500;
      
      private static const HIDDEN_LAYERS:Vector.<int> = new <int>[50,51,53,52,54,55,56,57,59,58,60,63,61,62,162,163,75,104,105,106,107,200];
      
      private var mDBFacade:DBFacade;
      
      private var mEventComponent:EventComponent;
      
      private var mHidden:Boolean;
      
      private var mTogglePressHeld:Boolean;
      
      private var mHiddenLayers:Vector.<DisplayObject> = new Vector.<DisplayObject>();
      
      private var mHiddenLayersWereVisible:Vector.<Boolean> = new Vector.<Boolean>();
      
      private var mHiddenStarlingLayers:Vector.<StarlingLayer> = new Vector.<StarlingLayer>();
      
      private var mHiddenStarlingLayersWereVisible:Vector.<Boolean> = new Vector.<Boolean>();
      
      public function UIHideToggle(dbFacade:DBFacade)
      {
         super();
         mDBFacade = dbFacade;
         mEventComponent = new EventComponent(mDBFacade);
         EventListeners.add(mDBFacade.stageRef,"keyDown",onKeyDown,false,500);
         EventListeners.add(mDBFacade.stageRef,"keyUp",onKeyUp,true);
         EventListeners.add(mDBFacade.stageRef,"keyUp",onKeyUp);
         EventListeners.add(mDBFacade.stageRef,"deactivate",onDeactivate);
         EventListeners.add(mDBFacade.stageRef,"focusIn",onFocusIn,true);
      }
      
      public function destroy() : void
      {
         reveal();
         EventListeners.remove(mDBFacade.stageRef,"keyDown",onKeyDown);
         EventListeners.remove(mDBFacade.stageRef,"keyUp",onKeyUp,true);
         EventListeners.remove(mDBFacade.stageRef,"keyUp",onKeyUp);
         EventListeners.remove(mDBFacade.stageRef,"deactivate",onDeactivate);
         EventListeners.remove(mDBFacade.stageRef,"focusIn",onFocusIn,true);
         mEventComponent.destroy();
         mEventComponent = null;
         mDBFacade = null;
      }
      
      public function get hidden() : Boolean
      {
         return mHidden;
      }
      
      public function reveal() : void
      {
         setHidden(false);
      }
      
      private function onKeyDown(event:KeyboardEvent) : void
      {
         if(event.keyCode != 119)
         {
            return;
         }
         if(!mTogglePressHeld)
         {
            if(!mHidden && !canHide())
            {
               return;
            }
            mTogglePressHeld = true;
            setHidden(!mHidden);
         }
         event.stopImmediatePropagation();
      }
      
      private function onKeyUp(event:KeyboardEvent) : void
      {
         if(event.keyCode == 119)
         {
            mTogglePressHeld = false;
         }
      }
      
      private function onDeactivate(event:Event) : void
      {
         mTogglePressHeld = false;
      }
      
      private function canHide() : Boolean
      {
         if(mDBFacade.mainStateMachine == null || mDBFacade.mainStateMachine.currentStateName != "RunState")
         {
            return false;
         }
         return !mDBFacade.sceneGraphManager.popupCurtainShown;
      }
      
      private function onFocusIn(event:FocusEvent) : void
      {
         if(mHidden && mDBFacade.textInputHasFocus)
         {
            reveal();
         }
      }
      
      private function setHidden(value:Boolean) : void
      {
         if(mHidden == value)
         {
            return;
         }
         mHidden = value;
         if(mHidden)
         {
            hideLayers();
         }
         else
         {
            restoreLayers();
         }
         mDBFacade.sessionIdVisible = !mHidden;
         if(mDBFacade.fpsReadout)
         {
            mDBFacade.fpsReadout.suppressed = mHidden;
         }
         mEventComponent.dispatchEvent(new Event("UI_HIDE_TOGGLE_CHANGED"));
      }
      
      private function hideLayers() : void
      {
         var _loc3_:DisplayObject = null;
         for each(var _loc1_:int in HIDDEN_LAYERS)
         {
            _loc3_ = mDBFacade.sceneGraphManager.getLayer(_loc1_);
            if(_loc3_ != null)
            {
               mHiddenLayers.push(_loc3_);
               mHiddenLayersWereVisible.push(_loc3_.visible);
               _loc3_.visible = false;
            }
         }
         var _loc2_:StarlingLayerManager = mDBFacade.starlingLayerManager;
         if(_loc2_ != null)
         {
            hideStarlingLayer(_loc2_.getLayer(50));
            hideStarlingLayer(_loc2_.getLayer(36));
         }
      }
      
      private function hideStarlingLayer(layer:StarlingLayer) : void
      {
         if(layer == null)
         {
            return;
         }
         mHiddenStarlingLayers.push(layer);
         mHiddenStarlingLayersWereVisible.push(layer.visible);
         layer.visible = false;
      }
      
      private function restoreLayers() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < mHiddenLayers.length)
         {
            mHiddenLayers[_loc1_].visible = mHiddenLayersWereVisible[_loc1_];
            _loc1_++;
         }
         mHiddenLayers.length = 0;
         mHiddenLayersWereVisible.length = 0;
         _loc1_ = 0;
         while(_loc1_ < mHiddenStarlingLayers.length)
         {
            mHiddenStarlingLayers[_loc1_].visible = mHiddenStarlingLayersWereVisible[_loc1_];
            _loc1_++;
         }
         mHiddenStarlingLayers.length = 0;
         mHiddenStarlingLayersWereVisible.length = 0;
      }
   }
}

