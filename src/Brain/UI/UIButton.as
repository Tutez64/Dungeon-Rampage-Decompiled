package Brain.UI
{
   import Brain.Clock.GameClock;
   import Brain.Facade.Facade;
   import Brain.Render.MovieClipRenderController;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.filters.GlowFilter;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   
   public class UIButton extends UIObject
   {
      
      protected static const UP:uint = 0;
      
      protected static const DOWN:uint = 1;
      
      protected static const OVER:uint = 2;
      
      protected static const DISABLED:uint = 3;
      
      protected static const SELECTED:uint = 4;
      
      protected var mUpState:MovieClip;
      
      protected var mDownState:MovieClip;
      
      protected var mOverState:MovieClip;
      
      protected var mDisabledState:MovieClip;
      
      protected var mUpRenderer:MovieClipRenderController;
      
      protected var mDownRenderer:MovieClipRenderController;
      
      protected var mOverRenderer:MovieClipRenderController;
      
      protected var mDisabledRenderer:MovieClipRenderController;
      
      protected var mSelected:Boolean;
      
      protected var mSelectedState:MovieClip;
      
      protected var mSelectedRenderer:MovieClipRenderController;
      
      protected var mHitArea:MovieClip;
      
      protected var mLabel:TextField;
      
      protected var mDraggable:Boolean = false;
      
      private var mDragged:Boolean = false;
      
      protected var mDragStartParent:DisplayObjectContainer;
      
      protected var mDragStartPos:Point;
      
      protected var mStates:Array;
      
      protected var mRenderers:Array;
      
      protected var mRolloverFilter:GlowFilter;
      
      protected var mSelectedFilter:GlowFilter;
      
      protected var mFiltersBeforeRollover:Array;
      
      protected var mMouseDown:Boolean = false;
      
      protected var mPressCallback:Function;
      
      protected var mReleaseCallback:Function;
      
      protected var mDragReleaseCallback:Function;
      
      protected var mEnterCallback:Function;
      
      protected var mPressRollOutCallback:Function;
      
      protected var mRollOverCallback:Function;
      
      protected var mRollOutCallback:Function;
      
      protected var mRollOverCursor:String = "POINT";
      
      protected var mRollOverCursorKey:uint;
      
      protected var mDragBounds:Rectangle;
      
      private var mDisableEventPropogation:Boolean;
      
      public function UIButton(facade:Facade, root:MovieClip, tooltipDrawLayer:int = 0, disableEventPropogation:Boolean = true)
      {
         if(root.hasOwnProperty("theButton"))
         {
            root = root.theButton;
         }
         if(root.hasOwnProperty("up"))
         {
            mUpState = root.up;
            mUpState.mouseChildren = false;
            mUpRenderer = new MovieClipRenderController(facade,mUpState);
         }
         if(root.hasOwnProperty("down"))
         {
            mDownState = root.down;
            mDownState.mouseChildren = false;
            mDownRenderer = new MovieClipRenderController(facade,mDownState);
         }
         else
         {
            mDownState = mUpState;
            mDownRenderer = mUpRenderer;
         }
         if(root.hasOwnProperty("over"))
         {
            mOverState = root.over;
            mOverState.mouseChildren = false;
            mOverRenderer = new MovieClipRenderController(facade,mOverState);
         }
         else
         {
            mOverState = mUpState;
            mOverRenderer = mUpRenderer;
         }
         if(root.hasOwnProperty("disabled"))
         {
            mDisabledState = root.disabled;
            mDisabledState.mouseChildren = false;
            mDisabledRenderer = new MovieClipRenderController(facade,mDisabledState);
         }
         else
         {
            mDisabledState = mUpState;
            mDisabledRenderer = mUpRenderer;
         }
         if(root.hasOwnProperty("selected"))
         {
            mSelectedState = root.selected;
            mSelectedState.mouseChildren = false;
            mSelectedRenderer = new MovieClipRenderController(facade,mSelectedState);
         }
         else
         {
            mSelectedState = mUpState;
            mSelectedRenderer = mUpRenderer;
         }
         mStates = [mUpState,mDownState,mOverState,mDisabledState,mSelectedState];
         mRenderers = [mUpRenderer,mDownRenderer,mOverRenderer,mDisabledRenderer,mSelectedRenderer];
         if(root.hasOwnProperty("hit"))
         {
            mHitArea = root.hit;
            mHitArea.visible = false;
            mHitArea.mouseEnabled = false;
            root.hitArea = mHitArea;
         }
         if(root.hasOwnProperty("label"))
         {
            mLabel = root.label;
            mLabel.mouseEnabled = false;
         }
         super(facade,root,tooltipDrawLayer);
         mFiltersBeforeRollover = [];
         mDisableEventPropogation = disableEventPropogation;
      }
      
      public function allowEventPropogation() : void
      {
         mDisableEventPropogation = false;
      }
      
      public function get label() : TextField
      {
         return mLabel;
      }
      
      public function set label(value:TextField) : void
      {
         mLabel = value;
         mLabel.mouseEnabled = false;
      }
      
      public function flattenLabelToBitmap() : void
      {
         var _loc1_:BitmapData = new BitmapData(mLabel.width,mLabel.height,true,0);
         _loc1_.draw(mLabel);
         var _loc2_:Bitmap = new Bitmap(_loc1_,"auto",true);
         _loc2_.transform.matrix = mLabel.transform.matrix;
         mLabel.parent.addChild(_loc2_);
         mLabel.parent.removeChild(mLabel);
         mLabel = null;
      }
      
      public function get selected() : Boolean
      {
         return mSelected;
      }
      
      public function set selected(value:Boolean) : void
      {
         mSelected = value;
         if(mSelectedFilter)
         {
            mSelectedState.filters = value ? [mSelectedFilter] : [];
         }
         this.showState(upState);
      }
      
      public function set rolloverFilter(value:GlowFilter) : void
      {
         mRolloverFilter = value;
      }
      
      public function get rolloverFilter() : GlowFilter
      {
         return mRolloverFilter;
      }
      
      public function set selectedFilter(value:GlowFilter) : void
      {
         mSelectedFilter = value;
      }
      
      public function get selectedFilter() : GlowFilter
      {
         return mSelectedFilter;
      }
      
      public function set pressCallback(value:Function) : void
      {
         mPressCallback = value;
      }
      
      public function set pressCallbackThis(value:Function) : void
      {
         var _this:UIButton = this;
         mPressCallback = function():void
         {
            value(_this);
         };
      }
      
      public function set releaseCallback(value:Function) : void
      {
         mReleaseCallback = value;
      }
      
      public function set releaseCallbackThis(value:Function) : void
      {
         var _this:UIButton = this;
         mReleaseCallback = function():void
         {
            value(_this);
         };
      }
      
      public function get releaseCallback() : Function
      {
         return mReleaseCallback;
      }
      
      public function set dragReleaseCallback(value:Function) : void
      {
         mDragReleaseCallback = value;
      }
      
      public function get dragReleaseCallback() : Function
      {
         return mDragReleaseCallback;
      }
      
      public function set enterCallback(value:Function) : void
      {
         mEnterCallback = value;
      }
      
      public function set pressRollOutCallback(value:Function) : void
      {
         mPressRollOutCallback = value;
      }
      
      public function set rollOverCallback(value:Function) : void
      {
         mRollOverCallback = value;
      }
      
      public function set rollOutCallback(value:Function) : void
      {
         mRollOutCallback = value;
      }
      
      public function get draggable() : Boolean
      {
         return mDraggable;
      }
      
      public function set draggable(value:Boolean) : void
      {
         mDraggable = value;
      }
      
      public function set rollOverCursor(name:String) : void
      {
         mRollOverCursor = name;
      }
      
      public function click() : void
      {
         onRelease(new MouseEvent("click"));
      }
      
      override protected function addListeners() : void
      {
         super.addListeners();
         mRoot.addEventListener("mouseDown",onPress);
         mRoot.addEventListener("keyDown",onKey);
      }
      
      protected function popRollOverMouseCursor() : void
      {
         if(mRollOverCursor && mRollOverCursorKey > 0)
         {
            mFacade.mouseCursorManager.popMouseCursor(mRollOverCursorKey);
            mRollOverCursorKey = 0;
         }
      }
      
      override protected function removeListeners() : void
      {
         super.removeListeners();
         mRoot.removeEventListener("mouseDown",onPress);
         mRoot.removeEventListener("keyDown",onKey);
         mRoot.removeEventListener("mouseUp",onMouseUp);
         mFacade.stageRef.removeEventListener("mouseUp",onMouseUp);
         mFacade.stageRef.removeEventListener("mouseLeave",onStageMouseLeave);
      }
      
      override public function set enabled(value:Boolean) : void
      {
         super.enabled = value;
         mRoot.buttonMode = mEnabled;
         mRoot.tabEnabled = false;
         showState(mEnabled ? upState : 3);
         mMouseDown = false;
         if(!value)
         {
            if(mRolloverFilter)
            {
               mRoot.filters = mFiltersBeforeRollover;
               mFiltersBeforeRollover = null;
            }
            popRollOverMouseCursor();
         }
      }
      
      override public function destroy() : void
      {
         popRollOverMouseCursor();
         mStates = null;
         for each(var _loc1_:MovieClipRenderController in mRenderers)
         {
            if(_loc1_)
            {
               _loc1_.destroy();
            }
         }
         mRenderers = null;
         mPressCallback = null;
         mReleaseCallback = null;
         mLabel = null;
         mDisabledRenderer = null;
         mDisabledState = null;
         mDownRenderer = null;
         mDownState = null;
         mUpRenderer = null;
         mUpState = null;
         mOverRenderer = null;
         mOverState = null;
         mSelectedRenderer = null;
         mSelectedState = null;
         super.destroy();
      }
      
      protected function showState(i:uint) : void
      {
         for each(var _loc3_:MovieClip in mStates)
         {
            if(_loc3_)
            {
               _loc3_.visible = false;
            }
         }
         for each(var _loc2_:MovieClipRenderController in mRenderers)
         {
            if(_loc2_)
            {
               _loc2_.stop();
            }
         }
         if(mStates && mStates[i])
         {
            mStates[i].visible = true;
         }
         if(mRenderers && mRenderers[i])
         {
            mRenderers[i].play(0,true);
         }
      }
      
      protected function onKey(event:KeyboardEvent) : void
      {
         event.stopImmediatePropagation();
         if(event.keyCode == 13)
         {
            if(mEnterCallback != null)
            {
               mEnterCallback();
            }
         }
      }
      
      override protected function onFocused() : void
      {
         super.onFocused();
         showState(overState);
      }
      
      override protected function onUnfocused() : void
      {
         super.onUnfocused();
         showState(upState);
      }
      
      protected function onPress(event:MouseEvent) : void
      {
         if(mDisableEventPropogation)
         {
            event.stopImmediatePropagation();
         }
         mRoot.addEventListener("mouseUp",onMouseUp);
         mFacade.stageRef.addEventListener("mouseUp",onMouseUp);
         mFacade.stageRef.addEventListener("mouseLeave",onStageMouseLeave);
         if(mDraggable)
         {
            mFacade.stageRef.addEventListener("mouseMove",onMouseMove);
         }
         mMouseDown = true;
         showState(downState);
         if(mDraggable)
         {
            mDragged = false;
         }
         if(mPressCallback != null)
         {
            mPressCallback();
         }
      }
      
      protected function onMouseMove(event:MouseEvent) : void
      {
         if(mDraggable)
         {
            mFacade.stageRef.removeEventListener("mouseMove",onMouseMove);
            startDrag();
         }
      }
      
      override protected function showTooltip(gameClock:GameClock = null) : void
      {
         if(mDragged)
         {
            return;
         }
         super.showTooltip(gameClock);
      }
      
      protected function startDrag() : void
      {
         this.hideTooltip();
         mDragged = true;
         mDragStartPos = new Point(mRoot.x,mRoot.y);
         mDragStartParent = mRoot.parent;
         var _loc1_:Point = mRoot.localToGlobal(new Point(0,0));
         mFacade.sceneGraphManager.addChild(mRoot,75);
         mRoot.x = _loc1_.x;
         mRoot.y = _loc1_.y;
         mRoot.startDrag(false,mDragBounds);
      }
      
      public function set dragBounds(value:Rectangle) : void
      {
         mDragBounds = value;
      }
      
      protected function onMouseUp(event:MouseEvent) : void
      {
         var _loc2_:Boolean = false;
         var _loc4_:DisplayObject = null;
         var _loc5_:MovieClip = null;
         var _loc3_:DisplayObject = null;
         if(mDisableEventPropogation)
         {
            event.stopImmediatePropagation();
         }
         if(!mRoot)
         {
            return;
         }
         if(mDraggable)
         {
            mFacade.stageRef.removeEventListener("mouseMove",onMouseMove);
         }
         mRoot.removeEventListener("mouseUp",onMouseUp);
         mFacade.stageRef.removeEventListener("mouseUp",onMouseUp);
         mFacade.stageRef.removeEventListener("mouseLeave",onStageMouseLeave);
         if(!mEnabled || !mMouseDown)
         {
            return;
         }
         if(mDraggable && mDragged)
         {
            mDragged = false;
            _loc2_ = false;
            this.stopDrag();
            _loc4_ = mRoot.dropTarget;
            while(_loc4_ != null)
            {
               _loc5_ = _loc4_ as MovieClip;
               if(_loc5_ != null)
               {
                  if(!_loc5_.mouseEnabled)
                  {
                     _loc4_.visible = false;
                     mRoot.startDrag(true);
                     mRoot.stopDrag();
                     _loc4_.visible = true;
                     _loc4_ = mRoot.dropTarget;
                     continue;
                  }
                  if(_loc5_.hasOwnProperty("UIObject"))
                  {
                     if(UIObject(_loc5_.UIObject).handleDrop(this))
                     {
                        _loc2_ = true;
                        break;
                     }
                  }
               }
               _loc4_ = _loc4_.parent;
            }
            if(!_loc2_)
            {
               resetDrag();
            }
            onDragRelease(event);
         }
         else
         {
            _loc3_ = event.target as DisplayObject;
            while(_loc3_ != null)
            {
               if(_loc3_ == mRoot)
               {
                  onRelease(event);
                  return;
               }
               _loc3_ = _loc3_.parent;
            }
            onReleaseOutside(event);
         }
      }
      
      protected function stopDrag() : void
      {
         mRoot.stopDrag();
      }
      
      protected function resetDrag() : void
      {
         mDragStartParent.addChild(mRoot);
         this.bringToFront();
         mRoot.x = mDragStartPos.x;
         mRoot.y = mDragStartPos.y;
         mDragStartParent = null;
         mDragStartPos = null;
      }
      
      protected function onReleaseOutside(event:MouseEvent) : void
      {
         mMouseDown = false;
      }
      
      protected function onRelease(event:MouseEvent) : void
      {
         mMouseDown = false;
         showState(overState);
         if(mReleaseCallback != null)
         {
            mReleaseCallback();
         }
      }
      
      protected function onDragRelease(event:MouseEvent) : void
      {
         if(!mRoot)
         {
            return;
         }
         mMouseDown = false;
         showState(overState);
         if(mDragReleaseCallback != null)
         {
            mDragReleaseCallback();
         }
      }
      
      override protected function onRollOver(event:MouseEvent) : void
      {
         super.onRollOver(event);
         if(mMouseDown)
         {
            showState(downState);
         }
         else
         {
            showState(overState);
         }
         if(mRolloverFilter)
         {
            mFiltersBeforeRollover = mRoot.filters.slice();
            mRoot.filters = [mRolloverFilter];
         }
         if(mRollOverCallback != null)
         {
            mRollOverCallback();
         }
         if(mRollOverCursor)
         {
            mRollOverCursorKey = mFacade.mouseCursorManager.pushMouseCursor(mRollOverCursor,true);
         }
      }
      
      protected function get downState() : uint
      {
         return mSelected ? 4 : 1;
      }
      
      protected function get upState() : uint
      {
         return mSelected ? 4 : 0;
      }
      
      protected function get overState() : uint
      {
         return mSelected ? 4 : 2;
      }
      
      override protected function onRollOut(event:MouseEvent) : void
      {
         super.onRollOut(event);
         showState(upState);
         if(mMouseDown)
         {
            if(mPressRollOutCallback != null)
            {
               mPressRollOutCallback();
            }
         }
         if(mRolloverFilter)
         {
            if(mRoot)
            {
               mRoot.filters = mFiltersBeforeRollover;
            }
            mFiltersBeforeRollover = null;
         }
         if(mRollOutCallback != null)
         {
            mRollOutCallback();
         }
         popRollOverMouseCursor();
      }
      
      protected function onStageMouseLeave(event:Event) : void
      {
         hideTooltip();
         mRoot.removeEventListener("mouseUp",onMouseUp);
         mFacade.stageRef.removeEventListener("mouseUp",onMouseUp);
         mFacade.stageRef.removeEventListener("mouseLeave",onStageMouseLeave);
         showState(upState);
      }
      
      override public function onSelected() : void
      {
         if(Boolean(mReleaseCallback))
         {
            mReleaseCallback();
         }
      }
   }
}

