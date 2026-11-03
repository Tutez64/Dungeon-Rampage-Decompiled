package Actor
{
   import Brain.Event.EventListeners;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Facade.DBFacade;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.getTimer;
   
   public class ActorMousePicker
   {
      
      private static var sInstance:ActorMousePicker;
      
      private static var sPointerOnStage:Boolean = true;
      
      private static var sWorldUnderPointer:Boolean = true;
      
      private var mStage:Stage;
      
      private var mWorld:DisplayObject;
      
      private var mWork:LogicalWorkComponent;
      
      private var mHandlers:Vector.<MouseEventHandler> = new Vector.<MouseEventHandler>(0);
      
      private var mViews:Vector.<ActorView> = new Vector.<ActorView>(0);
      
      private var mRoots:Vector.<Sprite> = new Vector.<Sprite>(0);
      
      private var mParents:Vector.<DisplayObjectContainer> = new Vector.<DisplayObjectContainer>(0);
      
      private var mParentX:Vector.<Number> = new Vector.<Number>(0);
      
      private var mParentY:Vector.<Number> = new Vector.<Number>(0);
      
      private var mParentOpen:Vector.<Boolean> = new Vector.<Boolean>(0);
      
      private var mCandidates:Vector.<MouseEventHandler> = new Vector.<MouseEventHandler>(0);
      
      private var mRects:Vector.<Number> = new Vector.<Number>(0);
      
      private var mPoint:Point = new Point();
      
      private var mHovered:MouseEventHandler;
      
      private var mHistory:Array;
      
      public var pointerOverride:Point;
      
      public function ActorMousePicker(facade:DBFacade)
      {
         super();
         mStage = facade.stageRef;
         mWorld = facade.sceneGraphManager.worldLayerGroup;
         mWork = new LogicalWorkComponent(facade,"ActorMousePicker");
         EventListeners.add(mStage,"mouseMove",onMouseMove);
         EventListeners.add(mStage,"mouseDown",onMouseDown);
         EventListeners.add(mStage,"mouseUp",onMouseUp);
         EventListeners.add(mStage,"mouseLeave",onMouseLeave);
         EventListeners.add(mStage,"mouseOver",onMouseOver);
         EventListeners.add(mStage,"mouseOut",onMouseOut);
         mWork.doEveryFrame(onFrame);
      }
      
      public static function register(handler:MouseEventHandler, facade:DBFacade) : void
      {
         if(!sInstance)
         {
            sInstance = new ActorMousePicker(facade);
         }
         sInstance.add(handler);
      }
      
      public static function unregister(handler:MouseEventHandler) : void
      {
         if(sInstance)
         {
            sInstance.remove(handler);
         }
      }
      
      public static function get instance() : ActorMousePicker
      {
         return sInstance;
      }
      
      private static function isOpenToMouse(parent:DisplayObjectContainer) : Boolean
      {
         var _loc2_:DisplayObjectContainer = null;
         _loc2_ = parent;
         while(_loc2_ != null)
         {
            if(!_loc2_.visible || !_loc2_.mouseChildren)
            {
               return false;
            }
            _loc2_ = _loc2_.parent;
         }
         return true;
      }
      
      private function add(handler:MouseEventHandler) : void
      {
         if(mHandlers.indexOf(handler) >= 0 || !handler.actorView || !handler.actorView.root)
         {
            return;
         }
         mHandlers.push(handler);
         mViews.push(handler.actorView);
         mRoots.push(handler.actorView.root);
      }
      
      private function remove(handler:MouseEventHandler) : void
      {
         var _loc2_:int = mHandlers.indexOf(handler);
         if(_loc2_ >= 0)
         {
            mHandlers.splice(_loc2_,1);
            mViews.splice(_loc2_,1);
            mRoots.splice(_loc2_,1);
         }
         if(mHovered == handler)
         {
            setHovered(null);
         }
         if(mHandlers.length == 0)
         {
            destroy();
         }
      }
      
      private function destroy() : void
      {
         EventListeners.remove(mStage,"mouseMove",onMouseMove);
         EventListeners.remove(mStage,"mouseDown",onMouseDown);
         EventListeners.remove(mStage,"mouseUp",onMouseUp);
         EventListeners.remove(mStage,"mouseLeave",onMouseLeave);
         EventListeners.remove(mStage,"mouseOver",onMouseOver);
         EventListeners.remove(mStage,"mouseOut",onMouseOut);
         mWork.destroy();
         mWork = null;
         mHovered = null;
         if(sInstance == this)
         {
            sInstance = null;
         }
      }
      
      public function get handlerCount() : int
      {
         return mHandlers.length;
      }
      
      public function get hovered() : MouseEventHandler
      {
         return mHovered;
      }
      
      private function onMouseMove(event:MouseEvent) : void
      {
         track(event);
      }
      
      private function onMouseDown(event:MouseEvent) : void
      {
         track(event);
         pickAt(event.stageX,event.stageY);
         if(mHovered && mHovered.wantsClicks)
         {
            note("down",mHovered);
            mHovered.onMouseDown(event);
         }
      }
      
      private function onMouseUp(event:MouseEvent) : void
      {
         track(event);
         pickAt(event.stageX,event.stageY);
         if(mHovered && mHovered.wantsClicks)
         {
            note("up",mHovered);
            mHovered.onMouseUp(event);
         }
      }
      
      private function onMouseLeave(event:Event) : void
      {
         sPointerOnStage = false;
         setHovered(null);
      }
      
      private function onMouseOver(event:MouseEvent) : void
      {
         sPointerOnStage = true;
         sWorldUnderPointer = isWorld(event.target as DisplayObject);
      }
      
      private function onMouseOut(event:MouseEvent) : void
      {
         sWorldUnderPointer = isWorld(event.relatedObject);
      }
      
      private function onFrame(... rest) : void
      {
         if(!sPointerOnStage)
         {
            return;
         }
         if(pointerOverride)
         {
            pickAt(pointerOverride.x,pointerOverride.y);
            return;
         }
         pickAt(mStage.mouseX,mStage.mouseY);
      }
      
      private function track(event:MouseEvent) : void
      {
         sPointerOnStage = true;
         sWorldUnderPointer = isWorld(event.target as DisplayObject);
      }
      
      private function isWorld(target:DisplayObject) : Boolean
      {
         var _loc2_:DisplayObject = null;
         if(target == null || target == mStage)
         {
            return true;
         }
         _loc2_ = target;
         while(_loc2_ != null)
         {
            if(_loc2_ == mWorld)
            {
               return true;
            }
            _loc2_ = _loc2_.parent;
         }
         return false;
      }
      
      public function pickAt(stageX:Number, stageY:Number) : void
      {
         setHovered(sWorldUnderPointer ? pick(stageX,stageY) : null);
      }
      
      public function pick(stageX:Number, stageY:Number) : MouseEventHandler
      {
         var _loc21_:int = 0;
         var _loc14_:Sprite = null;
         var _loc3_:DisplayObjectContainer = null;
         var _loc10_:ActorView = null;
         var _loc23_:int = 0;
         var _loc8_:Point = null;
         var _loc9_:Rectangle = null;
         var _loc17_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc28_:Number = NaN;
         var _loc29_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc16_:Number = NaN;
         var _loc26_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc12_:Number = NaN;
         var _loc19_:Number = NaN;
         var _loc4_:MouseEventHandler = null;
         var _loc25_:int = 0;
         var _loc20_:int = 0;
         var _loc27_:int = -1;
         var _loc11_:DisplayObjectContainer = null;
         var _loc5_:Number = 0;
         var _loc6_:Number = 0;
         var _loc24_:int = 0;
         var _loc31_:Boolean = false;
         var _loc30_:int = int(mViews.length);
         _loc21_ = 0;
         for(; _loc21_ < _loc30_; _loc21_++)
         {
            _loc14_ = mRoots[_loc21_];
            _loc3_ = _loc14_.parent;
            if(_loc3_ != null)
            {
               _loc10_ = mViews[_loc21_];
               if(_loc3_ != _loc11_)
               {
                  _loc23_ = mParents.indexOf(_loc3_);
                  if(_loc23_ < 0 || _loc23_ >= _loc24_)
                  {
                     mPoint.x = stageX;
                     mPoint.y = stageY;
                     _loc8_ = _loc3_.globalToLocal(mPoint);
                     _loc23_ = _loc24_++;
                     mParents[_loc23_] = _loc3_;
                     mParentX[_loc23_] = _loc8_.x;
                     mParentY[_loc23_] = _loc8_.y;
                     mParentOpen[_loc23_] = isOpenToMouse(_loc3_);
                  }
                  _loc31_ = mParentOpen[_loc23_];
                  _loc5_ = mParentX[_loc23_];
                  _loc6_ = mParentY[_loc23_];
                  _loc11_ = _loc3_;
               }
               if(_loc31_)
               {
                  _loc9_ = _loc10_.fixedMouseHitRect;
                  if(_loc9_ == null)
                  {
                     if(!_loc10_.mousePickable || !_loc14_.visible || _loc14_.stage == null)
                     {
                        continue;
                     }
                     _loc9_ = _loc10_.mouseHitRect;
                     if(_loc9_ == null)
                     {
                        continue;
                     }
                  }
                  _loc17_ = _loc14_.scaleX;
                  _loc18_ = _loc14_.scaleY;
                  _loc28_ = _loc14_.x + _loc9_.x * _loc17_ - _loc5_;
                  _loc29_ = _loc28_ + _loc9_.width * _loc17_;
                  _loc15_ = _loc14_.y + _loc9_.y * _loc18_ - _loc6_;
                  _loc16_ = _loc15_ + _loc9_.height * _loc18_;
                  _loc26_ = _loc28_ < _loc29_ ? _loc28_ : _loc29_;
                  _loc22_ = _loc28_ < _loc29_ ? _loc29_ : _loc28_;
                  _loc12_ = _loc15_ < _loc16_ ? _loc15_ : _loc16_;
                  _loc19_ = _loc15_ < _loc16_ ? _loc16_ : _loc15_;
                  if(!(_loc26_ > 0 || _loc22_ < 0 || _loc12_ > 0 || _loc19_ < 0))
                  {
                     if(!(!_loc10_.mousePickable || !_loc14_.visible || _loc14_.stage == null))
                     {
                        _loc4_ = mHandlers[_loc21_];
                        _loc25_ = _loc20_ * 4;
                        mRects[_loc25_] = _loc26_;
                        mRects[_loc25_ + 1] = _loc12_;
                        mRects[_loc25_ + 2] = _loc22_;
                        mRects[_loc25_ + 3] = _loc19_;
                        mCandidates[_loc20_] = _loc4_;
                        if(_loc4_ == mHovered)
                        {
                           _loc27_ = _loc20_;
                        }
                        _loc20_++;
                     }
                  }
               }
            }
         }
         var _loc7_:int = ActorMousePick.nearest(0,0,mRects,_loc20_,_loc27_);
         var _loc13_:MouseEventHandler = _loc7_ >= 0 ? mCandidates[_loc7_] : null;
         _loc21_ = 0;
         while(_loc21_ < _loc20_)
         {
            mCandidates[_loc21_] = null;
            _loc21_++;
         }
         _loc21_ = 0;
         while(_loc21_ < _loc24_)
         {
            mParents[_loc21_] = null;
            _loc21_++;
         }
         return _loc13_;
      }
      
      public function census() : Object
      {
         var _loc5_:int = 0;
         var _loc2_:int = 0;
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         var _loc6_:int = 0;
         for each(var _loc1_:ActorView in mViews)
         {
            if(!_loc1_.root || !_loc1_.root.parent)
            {
               _loc5_++;
            }
            else
            {
               if(_loc1_.root.stage)
               {
                  _loc6_++;
               }
               if(_loc1_.fixedMouseHitRect)
               {
                  _loc2_++;
               }
               else if(_loc1_.mouseHitRect)
               {
                  _loc4_++;
               }
               else
               {
                  _loc3_++;
               }
            }
         }
         return {
            "handlers":mViews.length,
            "offList":_loc5_,
            "onStage":_loc6_,
            "fixed":_loc2_,
            "bodyFallback":_loc4_,
            "noRect":_loc3_
         };
      }
      
      private function setHovered(handler:MouseEventHandler) : void
      {
         if(handler == mHovered)
         {
            return;
         }
         var _loc2_:MouseEventHandler = mHovered;
         mHovered = handler;
         if(_loc2_)
         {
            note("out",_loc2_);
            _loc2_.onMouseOut(null);
         }
         if(handler)
         {
            note("over",handler);
            handler.onMouseOver(null);
         }
      }
      
      private function note(kind:String, handler:MouseEventHandler) : void
      {
         if(!mHistory)
         {
            return;
         }
         mHistory.push({
            "kind":kind,
            "id":handler.actorId,
            "ms":getTimer(),
            "x":mStage.mouseX,
            "y":mStage.mouseY
         });
         if(mHistory.length > 64)
         {
            mHistory.shift();
         }
      }
      
      public function takeHistory(clear:Boolean) : Array
      {
         if(!mHistory)
         {
            mHistory = [];
         }
         var _loc2_:Array = mHistory.concat();
         if(clear)
         {
            mHistory.length = 0;
         }
         return _loc2_;
      }
   }
}

