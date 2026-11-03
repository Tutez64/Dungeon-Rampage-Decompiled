package UI.Hud.StarlingConverted
{
   import Facade.DBFacade;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Matrix;
   
   public class StarlingInput
   {
      
      private static var sTypes:Vector.<String>;
      
      private var mFacade:DBFacade;
      
      private var mWidgets:Vector.<StarlingButton> = new Vector.<StarlingButton>(0);
      
      private var mCursors:Vector.<Boolean> = new Vector.<Boolean>(0);
      
      private var mHoverOnly:Vector.<Boolean> = new Vector.<Boolean>(0);
      
      private var mGroups:Vector.<DisplayObjectContainer>;
      
      private var mInverse:Matrix = new Matrix();
      
      private var mHover:StarlingButton;
      
      private var mPress:StarlingButton;
      
      private var mAttached:Boolean;
      
      private var mLeft:Boolean;
      
      private var mGamePress:Boolean;
      
      private var mRight:Boolean;
      
      private var mMiddle:Boolean;
      
      private var mClick:Boolean;
      
      private var mRightClick:Boolean;
      
      private var mMiddleClick:Boolean;
      
      private var mCursorKey:uint;
      
      private var mPointCursor:Boolean;
      
      public var onError:Function;
      
      public var boundsChanged:Function;
      
      public function StarlingInput(facade:DBFacade)
      {
         super();
         if(sTypes == null)
         {
            sTypes = new <String>["mouseMove","mouseDown","mouseUp","click","rightMouseDown","rightMouseUp","rightClick","middleMouseDown","middleMouseUp","middleClick"];
         }
         mFacade = facade;
         mGroups = new <DisplayObjectContainer>[facade.sceneGraphManager.UILayerGroup];
         var _loc2_:DisplayObjectContainer = mGroups[0].parent != null ? mGroups[0].parent.getChildByName("SceneGraphManager.UILayerGroupT") as DisplayObjectContainer : null;
         if(_loc2_ != null)
         {
            mGroups.push(_loc2_);
         }
      }
      
      public function add(widget:StarlingButton, pointCursor:Boolean = true, hoverOnly:Boolean = false) : void
      {
         mWidgets.push(widget);
         mCursors.push(pointCursor);
         mHoverOnly.push(hoverOnly);
      }
      
      public function remove(widget:StarlingButton) : void
      {
         var _loc2_:int = mWidgets.indexOf(widget);
         if(_loc2_ < 0)
         {
            return;
         }
         if(mHover == widget)
         {
            setHover(null,false);
         }
         if(mPress == widget)
         {
            if(widget.pressHandedToGame)
            {
               mGamePress = true;
            }
            mPress = null;
         }
         mWidgets.removeAt(_loc2_);
         mCursors.removeAt(_loc2_);
         mHoverOnly.removeAt(_loc2_);
      }
      
      public function attach() : void
      {
         var _loc1_:String = null;
         if(mAttached)
         {
            return;
         }
         mAttached = true;
         for each(_loc1_ in sTypes)
         {
            mFacade.stageRef.addEventListener(_loc1_,capture,true,1000);
            mFacade.stageRef.addEventListener(_loc1_,target,false,1000);
         }
         mFacade.stageRef.addEventListener("mouseLeave",leave,false,1000);
      }
      
      private function capture(event:MouseEvent) : void
      {
         if(event.eventPhase == 1)
         {
            routeSafely(event);
         }
      }
      
      private function target(event:MouseEvent) : void
      {
         if(event.eventPhase == 2)
         {
            routeSafely(event);
         }
      }
      
      private function routeSafely(event:MouseEvent) : void
      {
         try
         {
            route(event);
         }
         catch(error:Error)
         {
            if(onError != null)
            {
               onError(error);
            }
         }
      }
      
      private function overFlash(target:DisplayObject) : Boolean
      {
         var _loc2_:DisplayObjectContainer = null;
         for each(_loc2_ in mGroups)
         {
            if(target != null && _loc2_.contains(target))
            {
               return true;
            }
         }
         return false;
      }
      
      private function route(event:MouseEvent) : void
      {
         var _loc2_:StarlingButton = null;
         var _loc6_:int = 0;
         var _loc4_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc3_:StarlingButton = null;
         HudTransform.inverse(mFacade,mInverse);
         if(overFlash(event.target as DisplayObject))
         {
            leave();
            return;
         }
         var _loc5_:* = -1;
         if(mFacade.stageRef.mouseChildren)
         {
            _loc4_ = mInverse.a * event.stageX + mInverse.c * event.stageY + mInverse.tx;
            _loc7_ = mInverse.b * event.stageX + mInverse.d * event.stageY + mInverse.ty;
            _loc6_ = mWidgets.length - 1;
            while(_loc6_ >= 0)
            {
               if(mWidgets[_loc6_].hitTest(_loc4_,_loc7_))
               {
                  _loc5_ = _loc6_;
                  break;
               }
               _loc6_--;
            }
         }
         _loc2_ = _loc5_ >= 0 ? mWidgets[_loc5_] : null;
         setHover(_loc2_,_loc5_ >= 0 && mCursors[_loc5_]);
         if(_loc5_ >= 0 && mHoverOnly[_loc5_])
         {
            _loc2_ = null;
         }
         switch(event.type)
         {
            case "mouseDown":
               mClick = false;
               mGamePress = false;
               if(_loc2_ != null)
               {
                  event.stopImmediatePropagation();
                  mLeft = true;
                  mPress = _loc2_;
                  _loc2_.onMouseDown();
                  if(boundsChanged != null)
                  {
                     boundsChanged();
                  }
               }
               break;
            case "mouseUp":
               if(mLeft)
               {
                  if(!mGamePress)
                  {
                     event.stopImmediatePropagation();
                  }
                  mLeft = false;
                  mClick = true;
                  _loc3_ = mPress;
                  mPress = null;
                  if(_loc3_ != null)
                  {
                     _loc3_.onMouseUp(_loc3_ == _loc2_);
                  }
                  mGamePress = false;
                  if(boundsChanged != null)
                  {
                     boundsChanged();
                  }
               }
               break;
            case "click":
               if(mClick || _loc2_ != null)
               {
                  event.stopImmediatePropagation();
               }
               mClick = false;
               break;
            case "rightMouseDown":
               mRightClick = false;
               if(_loc2_ != null)
               {
                  mRight = true;
                  event.stopImmediatePropagation();
               }
               break;
            case "rightMouseUp":
               if(mRight)
               {
                  mRight = false;
                  mRightClick = true;
                  event.stopImmediatePropagation();
               }
               break;
            case "rightClick":
               if(mRightClick || _loc2_ != null)
               {
                  event.stopImmediatePropagation();
               }
               mRightClick = false;
               break;
            case "middleMouseDown":
               mMiddleClick = false;
               if(_loc2_ != null)
               {
                  mMiddle = true;
                  event.stopImmediatePropagation();
               }
               break;
            case "middleMouseUp":
               if(mMiddle)
               {
                  mMiddle = false;
                  mMiddleClick = true;
                  event.stopImmediatePropagation();
               }
               break;
            case "middleClick":
               if(mMiddleClick || _loc2_ != null)
               {
                  event.stopImmediatePropagation();
               }
               mMiddleClick = false;
         }
      }
      
      private function setHover(widget:StarlingButton, pointCursor:Boolean) : void
      {
         if(widget != mHover)
         {
            if(mHover != null)
            {
               mHover.onRollOut();
            }
            if(mLeft && mPress != null && mPress.pressHandedToGame)
            {
               mGamePress = true;
            }
            mHover = widget;
            if(mHover != null)
            {
               mHover.onRollOver();
            }
            if(boundsChanged != null)
            {
               boundsChanged();
            }
         }
         if(pointCursor == mPointCursor)
         {
            return;
         }
         mPointCursor = pointCursor;
         if(pointCursor)
         {
            mCursorKey = mFacade.mouseCursorManager.pushMouseCursor("POINT",true);
         }
         else if(mCursorKey > 0)
         {
            mFacade.mouseCursorManager.popMouseCursor(mCursorKey);
            mCursorKey = 0;
         }
      }
      
      private function leave(event:Event = null) : void
      {
         try
         {
            setHover(null,false);
            if(mPress != null)
            {
               mPress.onMouseUp(false);
            }
            if(mGamePress)
            {
               mFacade.inputManager.onMouseUp(null);
            }
            mPress = null;
            mLeft = mRight = mMiddle = mClick = mRightClick = mMiddleClick = mGamePress = false;
         }
         catch(error:Error)
         {
            if(onError != null)
            {
               onError(error);
            }
         }
      }
      
      public function detach() : void
      {
         var _loc1_:String = null;
         if(!mAttached)
         {
            return;
         }
         mAttached = false;
         leave();
         for each(_loc1_ in sTypes)
         {
            mFacade.stageRef.removeEventListener(_loc1_,capture,true);
            mFacade.stageRef.removeEventListener(_loc1_,target,false);
         }
         mFacade.stageRef.removeEventListener("mouseLeave",leave);
      }
      
      public function dispose() : void
      {
         var _loc1_:StarlingButton = null;
         detach();
         for each(_loc1_ in mWidgets)
         {
            try
            {
               _loc1_.dispose();
            }
            catch(error:Error)
            {
               if(onError != null)
               {
                  onError(error);
               }
            }
         }
         mWidgets.length = mCursors.length = mHoverOnly.length = 0;
         onError = null;
         boundsChanged = null;
         mFacade = null;
      }
   }
}

