package Brain.UI
{
   import Brain.Clock.GameClock;
   import Brain.Facade.Facade;
   import Brain.Logger.Logger;
   import Brain.WorkLoop.DoLater;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.utils.Dictionary;
   
   public class UIObject
   {
      
      private static const DEFAULT_TOOLTIP_DELAY:Number = 0;
      
      private static const DEFAULT_TOOLTIP_LAYER:int = 107;
      
      private static const NAVIGATION_UP:String = "UP";
      
      private static const NAVIGATION_DOWN:String = "DOWN";
      
      private static const NAVIGATION_LEFT:String = "LEFT";
      
      private static const NAVIGATION_RIGHT:String = "RIGHT";
      
      private static const NAVIGATION_SELECTED:String = "SELECTED";
      
      private static const NAVIGATION_SET_TO_UNSELECTED:String = "SET_TO_UNSELECTED";
      
      protected var mEnabled:Boolean = true;
      
      protected var mFacade:Facade;
      
      protected var mRoot:MovieClip;
      
      protected var mTooltip:MovieClip;
      
      protected var mTooltipLabel:TextField;
      
      protected var mTooltipPos:Point = new Point();
      
      protected var mTooltipDelay:Number = 0;
      
      protected var mTooltipTask:DoLater;
      
      protected var mTooltipLayer:Number = 107;
      
      protected var mDontKillMyChildren:Boolean;
      
      protected var mIsParentedToStage:Boolean;
      
      private var mNavigationDictionary:Dictionary = new Dictionary(true);
      
      private var mNavigationAdditionalInteraction:Dictionary = new Dictionary(true);
      
      protected var mIsFocused:Boolean = false;
      
      public function UIObject(facade:Facade, root:MovieClip, tooltipDrawLayer:int = 0, dontKillChildren:Boolean = false)
      {
         super();
         mFacade = facade;
         mRoot = root;
         if(mRoot.hasOwnProperty("tooltip"))
         {
            if(tooltipDrawLayer != 0)
            {
               mTooltipLayer = tooltipDrawLayer;
            }
            this.tooltip = mRoot.tooltip;
         }
         try
         {
            mRoot.UIObject = this;
         }
         catch(errObject:Error)
         {
         }
         this.enabled = true;
         mDontKillMyChildren = dontKillChildren;
         mIsParentedToStage = false;
      }
      
      public static function scaleToFit(icon:DisplayObject, pixelSize:Number) : void
      {
         icon.scaleX = icon.scaleY = 1;
         var _loc4_:Number = icon.height > icon.width ? icon.height : icon.width;
         var _loc5_:Number = pixelSize / _loc4_;
         icon.scaleX = icon.scaleY = _loc5_;
         var _loc3_:Rectangle = icon.getBounds(icon);
         icon.x = -(_loc3_.left + _loc3_.width * 0.5);
         icon.y = -(_loc3_.top + _loc3_.height * 0.5);
      }
      
      public function handleDrop(dropObject:UIObject) : Boolean
      {
         return false;
      }
      
      public function set visible(value:Boolean) : void
      {
         mRoot.visible = value;
      }
      
      public function get visible() : Boolean
      {
         return mRoot.visible;
      }
      
      public function get enabled() : Boolean
      {
         return mEnabled;
      }
      
      public function set enabled(value:Boolean) : void
      {
         mEnabled = value;
         hideTooltip();
         removeListeners();
         if(mEnabled)
         {
            addListeners();
         }
      }
      
      protected function addListeners() : void
      {
         mRoot.addEventListener("rollOver",onRollOver);
         mRoot.addEventListener("rollOut",onRollOut);
      }
      
      public function setFocused(focused:Boolean) : void
      {
         if(mIsFocused != focused)
         {
            mIsFocused = focused;
            if(mIsFocused)
            {
               onFocused();
            }
            else
            {
               onUnfocused();
            }
         }
      }
      
      protected function onFocused() : void
      {
         onRollOver(null);
      }
      
      protected function onUnfocused() : void
      {
         onRollOut(null);
      }
      
      public function onSelected() : void
      {
      }
      
      protected function removeListeners() : void
      {
         mRoot.removeEventListener("rollOver",onRollOver);
         mRoot.removeEventListener("rollOut",onRollOut);
      }
      
      protected function onRollOver(event:MouseEvent) : void
      {
         hideTooltip();
         if(mTooltip)
         {
            if(mTooltipDelay == 0)
            {
               showTooltip();
            }
            else
            {
               mTooltipTask = mFacade.preRenderWorkManager.doLater(mTooltipDelay,showTooltip,false,"UIObject.tooltip");
            }
         }
      }
      
      protected function onRollOut(event:MouseEvent) : void
      {
         hideTooltip();
      }
      
      public function bringToFront() : void
      {
         mRoot.parent.setChildIndex(mRoot,mRoot.parent.numChildren - 1);
      }
      
      public function sendToBack() : void
      {
         mRoot.parent.setChildIndex(mRoot,0);
      }
      
      public function detach() : void
      {
         if(mRoot.parent)
         {
            mRoot.parent.removeChild(mRoot);
         }
      }
      
      public function get root() : MovieClip
      {
         return mRoot;
      }
      
      public function set tooltipPos(value:Point) : void
      {
         mTooltipPos = value;
      }
      
      public function setTooltipToBeParentedToStage() : void
      {
         mIsParentedToStage = true;
      }
      
      public function get tooltip() : MovieClip
      {
         return mTooltip;
      }
      
      public function get tooltipLabel() : TextField
      {
         return mTooltipLabel;
      }
      
      public function set tooltip(value:MovieClip) : void
      {
         setTooltip(value);
      }
      
      public function setTooltip(value:*) : void
      {
         hideTooltip();
         if(value is MovieClip)
         {
            mTooltip = value as MovieClip;
            mTooltipLabel = null;
         }
         else if(value is TextField)
         {
            mTooltip = new MovieClip();
            mTooltipLabel = value as TextField;
            mTooltip.addChild(mTooltipLabel);
         }
         else if(value is String)
         {
            mTooltip = new MovieClip();
            mTooltipLabel = new TextField();
            mTooltipLabel.text = value as String;
            mTooltipLabel.autoSize = "center";
            mTooltipLabel.background = true;
            mTooltipLabel.backgroundColor = 0;
            mTooltipLabel.textColor = 16777215;
            mTooltip.addChild(mTooltipLabel);
         }
         else if(value == null)
         {
            if(mTooltip && mTooltip.parent)
            {
               mTooltip.parent.removeChild(mTooltip);
            }
            if(mTooltipLabel && mTooltipLabel.parent)
            {
               mTooltipLabel.parent.removeChild(mTooltipLabel);
            }
            mTooltipLabel = null;
            mTooltip = null;
         }
         else
         {
            Logger.error("invalid tooltip type: " + value.toString());
         }
         if(mTooltip)
         {
            mTooltip.mouseChildren = false;
            mTooltip.mouseEnabled = false;
            this.tooltipPos = new Point(mTooltip.x,mTooltip.y);
            if(mTooltip.parent)
            {
               mTooltip.parent.removeChild(mTooltip);
            }
         }
      }
      
      public function set tooltipDelay(value:Number) : void
      {
         mTooltipDelay = value;
      }
      
      protected function hideTooltip() : void
      {
         if(mTooltipTask)
         {
            mTooltipTask.destroy();
         }
         if(mTooltip && mTooltip.parent)
         {
            mTooltip.parent.removeChild(mTooltip);
         }
      }
      
      protected function showTooltip(gameClock:GameClock = null) : void
      {
         var _loc2_:Point = null;
         if(mTooltip)
         {
            if(!mIsParentedToStage)
            {
               _loc2_ = root.localToGlobal(mTooltipPos);
               mTooltip.x = _loc2_.x;
               mTooltip.y = _loc2_.y;
            }
            else
            {
               mTooltip.x = mTooltipPos.x;
               mTooltip.y = mTooltipPos.y;
            }
            mFacade.sceneGraphManager.addChild(mTooltip,mTooltipLayer);
         }
      }
      
      public function set dontKillMyChildren(haveMercy:Boolean) : void
      {
         mDontKillMyChildren = haveMercy;
      }
      
      public function destroy() : void
      {
         if(mRoot != null)
         {
            if(mRoot.hasOwnProperty("UIObject"))
            {
               mRoot.UIObject = null;
            }
            hideTooltip();
            removeListeners();
            if(!mDontKillMyChildren)
            {
               while(mRoot.numChildren > 0)
               {
                  mRoot.removeChildAt(0);
               }
            }
            mNavigationDictionary = null;
            mRoot = null;
            mFacade = null;
         }
      }
      
      public function canBeFocused() : Boolean
      {
         return enabled && visible;
      }
      
      public function isFocused() : Boolean
      {
         return mIsFocused;
      }
      
      public function setRootMovieClipAsBitMap() : void
      {
         mRoot.cacheAsBitmap = true;
      }
      
      public function isToTheLeftOf(rightUiObject:UIObject) : void
      {
         this.rightNavigation = rightUiObject;
         rightUiObject.leftNavigation = this;
      }
      
      public function isAbove(bottomUiObject:UIObject) : void
      {
         this.downNavigation = bottomUiObject;
         bottomUiObject.upNavigation = this;
      }
      
      public function get leftNavigation() : UIObject
      {
         return mNavigationDictionary["LEFT"];
      }
      
      public function get rightNavigation() : UIObject
      {
         return mNavigationDictionary["RIGHT"];
      }
      
      public function get upNavigation() : UIObject
      {
         return mNavigationDictionary["UP"];
      }
      
      public function get downNavigation() : UIObject
      {
         return mNavigationDictionary["DOWN"];
      }
      
      public function set leftNavigation(leftUiObject:UIObject) : void
      {
         if(mNavigationDictionary["LEFT"] == leftUiObject)
         {
            Logger.warnch("UI","Navigation left already set to same target on: " + this.mRoot.name);
            return;
         }
         if(mNavigationDictionary["LEFT"] != null)
         {
            throw new Error("This UIObject (" + this.mRoot.name + ") can already navigate left towards: " + mNavigationDictionary["LEFT"].mRoot.name);
         }
         mNavigationDictionary["LEFT"] = leftUiObject;
      }
      
      public function set rightNavigation(rightUiObject:UIObject) : void
      {
         if(mNavigationDictionary["RIGHT"] == rightUiObject)
         {
            Logger.warnch("UI","Navigation right already set to same target on: " + this.mRoot.name);
            return;
         }
         if(mNavigationDictionary["RIGHT"] != null)
         {
            throw new Error("This UIObject (" + this.mRoot.name + ") can already navigate right towards: " + mNavigationDictionary["RIGHT"].mRoot.name);
         }
         mNavigationDictionary["RIGHT"] = rightUiObject;
      }
      
      public function set upNavigation(upUiObject:UIObject) : void
      {
         if(mNavigationDictionary["UP"] == upUiObject)
         {
            Logger.warnch("UI","Navigation up already set to same target on: " + this.mRoot.name);
            return;
         }
         if(mNavigationDictionary["UP"] != null)
         {
            throw new Error("This UIObject (" + this.mRoot.name + ") can already navigate up towards: " + mNavigationDictionary["UP"].mRoot.name);
         }
         mNavigationDictionary["UP"] = upUiObject;
      }
      
      public function set downNavigation(downUiObject:UIObject) : void
      {
         if(mNavigationDictionary["DOWN"] == downUiObject)
         {
            Logger.warnch("UI","Navigation down already set to same target on: " + this.mRoot.name);
            return;
         }
         if(mNavigationDictionary["DOWN"] != null)
         {
            throw new Error("This UIObject (" + this.mRoot.name + ") can already navigate down towards: " + mNavigationDictionary["DOWN"].mRoot.name);
         }
         mNavigationDictionary["DOWN"] = downUiObject;
      }
      
      public function clearLeftNavigation() : void
      {
         mNavigationDictionary["LEFT"] = null;
      }
      
      public function clearRightNavigation() : void
      {
         mNavigationDictionary["RIGHT"] = null;
      }
      
      public function clearUpNavigation() : void
      {
         mNavigationDictionary["UP"] = null;
      }
      
      public function clearDownNavigation() : void
      {
         mNavigationDictionary["DOWN"] = null;
      }
      
      public function clearNavigationAndInteractions() : void
      {
         mNavigationDictionary["LEFT"] = null;
         mNavigationDictionary["RIGHT"] = null;
         mNavigationDictionary["UP"] = null;
         mNavigationDictionary["DOWN"] = null;
         mNavigationAdditionalInteraction["LEFT"] = null;
         mNavigationAdditionalInteraction["RIGHT"] = null;
         mNavigationAdditionalInteraction["UP"] = null;
         mNavigationAdditionalInteraction["DOWN"] = null;
         mNavigationAdditionalInteraction["SELECTED"] = null;
         mNavigationAdditionalInteraction["SET_TO_UNSELECTED"] = null;
      }
      
      public function get leftNavigationAdditionalInteraction() : Function
      {
         return mNavigationAdditionalInteraction["LEFT"];
      }
      
      public function get rightNavigationAdditionalInteraction() : Function
      {
         return mNavigationAdditionalInteraction["RIGHT"];
      }
      
      public function get upNavigationAdditionalInteraction() : Function
      {
         return mNavigationAdditionalInteraction["UP"];
      }
      
      public function get downNavigationAdditionalInteraction() : Function
      {
         return mNavigationAdditionalInteraction["DOWN"];
      }
      
      public function get navigationSelectedInteraction() : Function
      {
         return mNavigationAdditionalInteraction["SELECTED"];
      }
      
      public function get navigationSetToUnselectedInteraction() : Function
      {
         return mNavigationAdditionalInteraction["SET_TO_UNSELECTED"];
      }
      
      public function set leftNavigationAdditionalInteraction(leftUiObjectInteraction:Function) : void
      {
         if(mNavigationAdditionalInteraction["LEFT"] != null)
         {
            throw new Error("This UIObject (" + this.mRoot.name + ") already has an additional interaction:  " + mNavigationAdditionalInteraction["LEFT"].mRoot.name);
         }
         mNavigationAdditionalInteraction["LEFT"] = leftUiObjectInteraction;
      }
      
      public function set rightNavigationAdditionalInteraction(rightUiObjectInteraction:Function) : void
      {
         if(mNavigationAdditionalInteraction["RIGHT"] != null)
         {
            throw new Error("This UIObject (" + this.mRoot.name + ") already has an additional interaction:  " + mNavigationAdditionalInteraction["RIGHT"].mRoot.name);
         }
         mNavigationAdditionalInteraction["RIGHT"] = rightUiObjectInteraction;
      }
      
      public function set upNavigationAdditionalInteraction(upUiObjectInteraction:Function) : void
      {
         if(mNavigationAdditionalInteraction["UP"] != null)
         {
            throw new Error("This UIObject (" + this.mRoot.name + ") already has an additional interaction:  " + mNavigationAdditionalInteraction["UP"].mRoot.name);
         }
         mNavigationAdditionalInteraction["UP"] = upUiObjectInteraction;
      }
      
      public function set downNavigationAdditionalInteraction(downUiObjectInteraction:Function) : void
      {
         if(mNavigationAdditionalInteraction["DOWN"] != null)
         {
            throw new Error("This UIObject (" + this.mRoot.name + ") already has an additional interaction: " + mNavigationAdditionalInteraction["DOWN"].mRoot.name);
         }
         mNavigationAdditionalInteraction["DOWN"] = downUiObjectInteraction;
      }
      
      public function set navigationSelectedInteraction(selectedUiObjectInteraction:Function) : void
      {
         if(mNavigationAdditionalInteraction["SELECTED"] != null)
         {
            throw new Error("This UIObject (" + this.mRoot.name + ") already has a selected interaction: " + mNavigationAdditionalInteraction["SELECTED"].mRoot.name);
         }
         mNavigationAdditionalInteraction["SELECTED"] = selectedUiObjectInteraction;
      }
      
      public function set navigationSetToUnselectedInteraction(selectedUiObjectInteraction:Function) : void
      {
         if(mNavigationAdditionalInteraction["SET_TO_UNSELECTED"] != null)
         {
            throw new Error("This UIObject (" + this.mRoot.name + ") already has an unselected interaction: " + mNavigationAdditionalInteraction["SET_TO_UNSELECTED"].mRoot.name);
         }
         mNavigationAdditionalInteraction["SET_TO_UNSELECTED"] = selectedUiObjectInteraction;
      }
   }
}

