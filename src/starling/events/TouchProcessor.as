package starling.events
{
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.getDefinitionByName;
   import starling.core.Starling;
   import starling.display.DisplayObject;
   import starling.display.Stage;
   import starling.utils.Pool;
   
   public class TouchProcessor
   {
      
      private static const TOP:int = 0;
      
      private static const BOTTOM:int = 1;
      
      private static const LEFT:int = 2;
      
      private static const RIGHT:int = 3;
      
      private static var sUpdatedTouches:Vector.<Touch> = new Vector.<Touch>(0);
      
      private static var sHoveringTouchData:Vector.<Object> = new Vector.<Object>(0);
      
      private static var sHelperPoint:Point = new Point();
      
      private var _stage:Stage;
      
      private var _root:DisplayObject;
      
      private var _elapsedTime:Number;
      
      private var _lastTaps:Vector.<Touch>;
      
      private var _shiftDown:Boolean = false;
      
      private var _ctrlDown:Boolean = false;
      
      private var _multitapTime:Number = 0.3;
      
      private var _multitapDistance:Number = 25;
      
      private var _touchEvent:TouchEvent;
      
      private var _isProcessing:Boolean;
      
      private var _cancelRequested:Boolean;
      
      private var _touchMarker:TouchMarker;
      
      private var _simulateMultitouch:Boolean;
      
      private var _occlusionTest:Function;
      
      private var _discardSystemGestures:Boolean;
      
      private var _systemGestureTouchID:int = -1;
      
      private var _systemGestureMargins:Array = [15,15,15,0];
      
      protected var _queue:Vector.<TouchData>;
      
      protected var _currentTouches:Vector.<Touch>;
      
      public function TouchProcessor(stage:Stage)
      {
         super();
         _root = _stage = stage;
         _elapsedTime = 0;
         _currentTouches = new Vector.<Touch>(0);
         _queue = new Vector.<TouchData>(0);
         _lastTaps = new Vector.<Touch>(0);
         _touchEvent = new TouchEvent("touch");
         _stage.addEventListener("keyDown",onKey);
         _stage.addEventListener("keyUp",onKey);
         monitorInterruptions(true);
      }
      
      public function dispose() : void
      {
         monitorInterruptions(false);
         _stage.removeEventListener("keyDown",onKey);
         _stage.removeEventListener("keyUp",onKey);
         if(_touchMarker)
         {
            _touchMarker.dispose();
         }
      }
      
      public function advanceTime(passedTime:Number) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Touch = null;
         var _loc5_:TouchData = null;
         if(_isProcessing)
         {
            return;
         }
         _isProcessing = true;
         var _loc2_:int = 0;
         _elapsedTime += passedTime;
         sUpdatedTouches.length = 0;
         if(_lastTaps.length > 0)
         {
            _loc3_ = _lastTaps.length - 1;
            while(_loc3_ >= 0)
            {
               if(_elapsedTime - _lastTaps[_loc3_].timestamp > _multitapTime)
               {
                  _lastTaps.removeAt(_loc3_);
               }
               _loc3_--;
            }
         }
         while(_queue.length > 0 || _loc2_ == 0)
         {
            _loc2_++;
            for each(_loc4_ in _currentTouches)
            {
               if(_loc4_.phase == "began" || _loc4_.phase == "moved")
               {
                  _loc4_.phase = "stationary";
               }
            }
            while(_queue.length > 0 && !containsTouchWithID(sUpdatedTouches,_queue[_queue.length - 1].id))
            {
               _loc5_ = _queue.pop();
               _loc4_ = createOrUpdateTouch(_loc5_);
               sUpdatedTouches[sUpdatedTouches.length] = _loc4_;
               TouchData.toPool(_loc5_);
            }
            _loc3_ = _currentTouches.length - 1;
            while(_loc3_ >= 0)
            {
               _loc4_ = _currentTouches[_loc3_];
               if(_loc4_.phase == "hover" && !containsTouchWithID(sUpdatedTouches,_loc4_.id))
               {
                  sHelperPoint.setTo(_loc4_.globalX,_loc4_.globalY);
                  if(_loc4_.target != _root.hitTest(sHelperPoint))
                  {
                     sUpdatedTouches[sUpdatedTouches.length] = _loc4_;
                  }
               }
               _loc3_--;
            }
            if(sUpdatedTouches.length)
            {
               processTouches(sUpdatedTouches,_shiftDown,_ctrlDown);
            }
            _loc3_ = _currentTouches.length - 1;
            while(_loc3_ >= 0)
            {
               if(_currentTouches[_loc3_].phase == "ended")
               {
                  _currentTouches.removeAt(_loc3_);
               }
               _loc3_--;
            }
            sUpdatedTouches.length = 0;
         }
         _isProcessing = false;
         if(_cancelRequested)
         {
            cancelTouches();
         }
      }
      
      protected function processTouches(touches:Vector.<Touch>, shiftDown:Boolean, ctrlDown:Boolean) : void
      {
         var _loc4_:Touch = null;
         sHoveringTouchData.length = 0;
         _touchEvent.resetTo("touch",_currentTouches,shiftDown,ctrlDown);
         for each(_loc4_ in touches)
         {
            if(_loc4_.phase == "hover" && _loc4_.target)
            {
               sHoveringTouchData[sHoveringTouchData.length] = {
                  "touch":_loc4_,
                  "target":_loc4_.target,
                  "bubbleChain":_loc4_.bubbleChain
               };
            }
            if(_loc4_.phase == "hover" || _loc4_.phase == "began")
            {
               sHelperPoint.setTo(_loc4_.globalX,_loc4_.globalY);
               if(_occlusionTest != null && _occlusionTest(_loc4_.globalX,_loc4_.globalY))
               {
                  _loc4_.target = null;
               }
               else
               {
                  _loc4_.target = _root.hitTest(sHelperPoint);
               }
            }
         }
         for each(var _loc5_:Object in sHoveringTouchData)
         {
            if(_loc5_.touch.target != _loc5_.target)
            {
               _touchEvent.dispatch(_loc5_.bubbleChain);
            }
         }
         for each(_loc4_ in touches)
         {
            _loc4_.dispatchEvent(_touchEvent);
         }
         _touchEvent.resetTo("touch");
      }
      
      private function checkForSystemGesture(touchID:int, phase:String, globalX:Number, globalY:Number) : Boolean
      {
         var _loc5_:Boolean = false;
         var _loc6_:Rectangle = null;
         if(!_discardSystemGestures || phase == "hover")
         {
            return false;
         }
         if(_systemGestureTouchID == touchID)
         {
            if(phase == "ended")
            {
               _systemGestureTouchID = -1;
            }
            return true;
         }
         if(_systemGestureTouchID >= 0)
         {
            return false;
         }
         if(phase == "began")
         {
            _loc6_ = _stage.getScreenBounds(_stage,Pool.getRectangle());
            _loc5_ = globalX < _loc6_.left + _systemGestureMargins[2] || globalX > _loc6_.right - _systemGestureMargins[3] || globalY < _loc6_.top + _systemGestureMargins[0] || globalY > _loc6_.bottom - _systemGestureMargins[1];
            Pool.putRectangle(_loc6_);
            if(_loc5_)
            {
               _systemGestureTouchID = touchID;
            }
            return _loc5_;
         }
         return false;
      }
      
      public function enqueue(touchID:int, phase:String, globalX:Number, globalY:Number, pressure:Number = 1, width:Number = 1, height:Number = 1) : void
      {
         if(checkForSystemGesture(touchID,phase,globalX,globalY))
         {
            return;
         }
         queue_unshift(touchID,phase,globalX,globalY,pressure,width,height);
         if(_ctrlDown && _touchMarker && touchID == 0)
         {
            _touchMarker.moveMarker(globalX,globalY,_shiftDown);
            queue_unshift(1,phase,_touchMarker.mockX,_touchMarker.mockY);
         }
      }
      
      private function queue_unshift(touchID:int, phase:String, globalX:Number, globalY:Number, pressure:Number = 1, width:Number = 1, height:Number = 1) : void
      {
         _queue.unshift(TouchData.fromPool(touchID,phase,globalX,globalY,pressure,width,height));
      }
      
      public function enqueueMouseLeftStage() : void
      {
         var _loc1_:Touch = getCurrentTouch(0);
         if(_loc1_ == null || _loc1_.phase != "hover")
         {
            return;
         }
         var _loc2_:int = 1;
         var _loc8_:Number = _loc1_.globalX;
         var _loc6_:Number = _loc1_.globalY;
         var _loc4_:Number = _loc1_.globalX;
         var _loc7_:Number = _stage.stageWidth - _loc4_;
         var _loc3_:Number = _loc1_.globalY;
         var _loc9_:Number = _stage.stageHeight - _loc3_;
         var _loc5_:Number = Math.min(_loc4_,_loc7_,_loc3_,_loc9_);
         if(_loc5_ == _loc4_)
         {
            _loc8_ = -_loc2_;
         }
         else if(_loc5_ == _loc7_)
         {
            _loc8_ = _stage.stageWidth + _loc2_;
         }
         else if(_loc5_ == _loc3_)
         {
            _loc6_ = -_loc2_;
         }
         else
         {
            _loc6_ = _stage.stageHeight + _loc2_;
         }
         enqueue(0,"hover",_loc8_,_loc6_);
      }
      
      public function cancelTouches() : void
      {
         if(_isProcessing)
         {
            _cancelRequested = true;
            return;
         }
         _cancelRequested = false;
         if(_currentTouches.length > 0)
         {
            for each(var _loc1_:Touch in _currentTouches)
            {
               if(_loc1_.phase == "began" || _loc1_.phase == "moved" || _loc1_.phase == "stationary")
               {
                  _loc1_.phase = "ended";
                  _loc1_.cancelled = true;
               }
            }
            processTouches(_currentTouches,_shiftDown,_ctrlDown);
         }
         _currentTouches.length = 0;
         _systemGestureTouchID = -1;
         while(_queue.length)
         {
            TouchData.toPool(_queue.pop());
         }
      }
      
      private function createOrUpdateTouch(touchData:TouchData) : Touch
      {
         var _loc2_:Touch = getCurrentTouch(touchData.id);
         if(_loc2_ == null)
         {
            _loc2_ = new Touch(touchData.id);
            addCurrentTouch(_loc2_);
         }
         _loc2_.update(_elapsedTime,touchData.phase,touchData.globalX,touchData.globalY,touchData.pressure,touchData.width,touchData.height);
         if(touchData.phase == "began")
         {
            updateTapCount(_loc2_);
         }
         return _loc2_;
      }
      
      private function updateTapCount(touch:Touch) : void
      {
         var _loc4_:Number = NaN;
         var _loc5_:Touch = null;
         var _loc2_:Number = _multitapDistance * _multitapDistance;
         for each(var _loc3_:Touch in _lastTaps)
         {
            _loc4_ = Math.pow(_loc3_.globalX - touch.globalX,2) + Math.pow(_loc3_.globalY - touch.globalY,2);
            if(_loc4_ <= _loc2_)
            {
               _loc5_ = _loc3_;
               break;
            }
         }
         if(_loc5_)
         {
            touch.tapCount = _loc5_.tapCount + 1;
            _lastTaps.removeAt(_lastTaps.indexOf(_loc5_));
         }
         else
         {
            touch.tapCount = 1;
         }
         _lastTaps[_lastTaps.length] = touch.clone();
      }
      
      private function addCurrentTouch(touch:Touch) : void
      {
         var _loc2_:int = 0;
         _loc2_ = _currentTouches.length - 1;
         while(_loc2_ >= 0)
         {
            if(_currentTouches[_loc2_].id == touch.id)
            {
               _currentTouches.removeAt(_loc2_);
            }
            _loc2_--;
         }
         _currentTouches[_currentTouches.length] = touch;
      }
      
      private function getCurrentTouch(touchID:int) : Touch
      {
         for each(var _loc2_:Touch in _currentTouches)
         {
            if(_loc2_.id == touchID)
            {
               return _loc2_;
            }
         }
         return null;
      }
      
      private function containsTouchWithID(touches:Vector.<Touch>, touchID:int) : Boolean
      {
         for each(var _loc3_:Touch in touches)
         {
            if(_loc3_.id == touchID)
            {
               return true;
            }
         }
         return false;
      }
      
      public function setSystemGestureMargins(topMargin:Number = 10, bottomMargin:Number = 10, leftMargin:Number = 0, rightMargin:Number = 0) : void
      {
         _systemGestureMargins[0] = topMargin;
         _systemGestureMargins[1] = bottomMargin;
         _systemGestureMargins[2] = leftMargin;
         _systemGestureMargins[3] = rightMargin;
      }
      
      public function get simulateMultitouch() : Boolean
      {
         return _simulateMultitouch;
      }
      
      public function set simulateMultitouch(value:Boolean) : void
      {
         var target:Starling;
         var createTouchMarker:* = function():void
         {
            target.removeEventListener("context3DCreate",createTouchMarker);
            if(_touchMarker == null)
            {
               _touchMarker = new TouchMarker();
               _touchMarker.visible = false;
               _stage.addChild(_touchMarker);
            }
         };
         if(simulateMultitouch == value)
         {
            return;
         }
         _simulateMultitouch = value;
         target = Starling.current;
         if(value && _touchMarker == null)
         {
            if(Starling.current.contextValid)
            {
               createTouchMarker();
            }
            else
            {
               target.addEventListener("context3DCreate",createTouchMarker);
            }
         }
         else if(!value && _touchMarker)
         {
            _touchMarker.removeFromParent(true);
            _touchMarker = null;
         }
      }
      
      public function get multitapTime() : Number
      {
         return _multitapTime;
      }
      
      public function set multitapTime(value:Number) : void
      {
         _multitapTime = value;
      }
      
      public function get multitapDistance() : Number
      {
         return _multitapDistance;
      }
      
      public function set multitapDistance(value:Number) : void
      {
         _multitapDistance = value;
      }
      
      public function get root() : DisplayObject
      {
         return _root;
      }
      
      public function set root(value:DisplayObject) : void
      {
         _root = value;
      }
      
      public function get stage() : Stage
      {
         return _stage;
      }
      
      public function get numCurrentTouches() : int
      {
         return _currentTouches.length;
      }
      
      public function set occlusionTest(value:Function) : void
      {
         _occlusionTest = value;
      }
      
      public function get occlusionTest() : Function
      {
         return _occlusionTest;
      }
      
      public function get discardSystemGestures() : Boolean
      {
         return _discardSystemGestures;
      }
      
      public function set discardSystemGestures(value:Boolean) : void
      {
         if(_discardSystemGestures != value)
         {
            _discardSystemGestures = value;
            _systemGestureTouchID = -1;
         }
      }
      
      private function onKey(event:KeyboardEvent) : void
      {
         var _loc2_:Boolean = false;
         var _loc4_:Touch = null;
         var _loc3_:Touch = null;
         if(event.keyCode == 17 || event.keyCode == 15)
         {
            _loc2_ = _ctrlDown;
            _ctrlDown = event.type == "keyDown";
            if(_touchMarker && _loc2_ != _ctrlDown)
            {
               _touchMarker.visible = _ctrlDown;
               _touchMarker.moveCenter(_stage.stageWidth / 2,_stage.stageHeight / 2);
               _loc4_ = getCurrentTouch(0);
               _loc3_ = getCurrentTouch(1);
               if(_loc4_)
               {
                  _touchMarker.moveMarker(_loc4_.globalX,_loc4_.globalY);
               }
               if(_loc2_ && _loc3_ && _loc3_.phase != "ended")
               {
                  queue_unshift(1,"ended",_loc3_.globalX,_loc3_.globalY);
               }
               else if(_ctrlDown && _loc4_)
               {
                  if(_loc4_.phase == "hover" || _loc4_.phase == "ended")
                  {
                     queue_unshift(1,"hover",_touchMarker.mockX,_touchMarker.mockY);
                  }
                  else
                  {
                     queue_unshift(1,"began",_touchMarker.mockX,_touchMarker.mockY);
                  }
               }
            }
         }
         else if(event.keyCode == 16)
         {
            _shiftDown = event.type == "keyDown";
         }
      }
      
      private function monitorInterruptions(enable:Boolean) : void
      {
         var _loc3_:Object = null;
         var _loc2_:Object = null;
         try
         {
            _loc3_ = getDefinitionByName("flash.desktop::NativeApplication");
            _loc2_ = _loc3_["nativeApplication"];
            if(enable)
            {
               _loc2_.addEventListener("deactivate",onInterruption,false,0,true);
            }
            else
            {
               _loc2_.removeEventListener("deactivate",onInterruption);
            }
         }
         catch(e:Error)
         {
         }
      }
      
      private function onInterruption(event:Object) : void
      {
         cancelTouches();
      }
   }
}

