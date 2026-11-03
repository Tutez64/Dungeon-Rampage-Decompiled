package starling.display
{
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.system.Capabilities;
   import flash.utils.getQualifiedClassName;
   import starling.core.starling_internal;
   import starling.errors.AbstractClassError;
   import starling.events.Event;
   import starling.filters.FragmentFilter;
   import starling.rendering.BatchToken;
   import starling.rendering.Painter;
   import starling.utils.MatrixUtil;
   import starling.utils.Pool;
   
   use namespace starling_internal;
   
   public class DisplayObjectContainer extends DisplayObject
   {
      
      private static var sHitTestMatrix:Matrix = new Matrix();
      
      private static var sBoundsMatrix:Matrix = new Matrix();
      
      private static var sBoundsPoint:Point = new Point();
      
      private static var sBroadcastListeners:Vector.<DisplayObject> = new Vector.<DisplayObject>(0);
      
      private static var sSortBuffer:Vector.<DisplayObject> = new Vector.<DisplayObject>(0);
      
      private static var sCacheToken:BatchToken = new BatchToken();
      
      private var _children:Vector.<DisplayObject>;
      
      private var _touchGroup:Boolean;
      
      public function DisplayObjectContainer()
      {
         super();
         if(Capabilities.isDebugger && getQualifiedClassName(this) == "starling.display::DisplayObjectContainer")
         {
            throw new AbstractClassError();
         }
         _children = new Vector.<DisplayObject>(0);
      }
      
      private static function mergeSort(input:Vector.<DisplayObject>, compareFunc:Function, startIndex:int, length:int, buffer:Vector.<DisplayObject>) : void
      {
         var _loc9_:int = 0;
         var _loc7_:int = 0;
         var _loc8_:int = 0;
         var _loc10_:int = 0;
         var _loc6_:int = 0;
         if(length > 1)
         {
            _loc7_ = startIndex + length;
            _loc8_ = length / 2;
            _loc10_ = startIndex;
            _loc6_ = startIndex + _loc8_;
            mergeSort(input,compareFunc,startIndex,_loc8_,buffer);
            mergeSort(input,compareFunc,startIndex + _loc8_,length - _loc8_,buffer);
            _loc9_ = 0;
            while(_loc9_ < length)
            {
               if(_loc10_ < startIndex + _loc8_ && (_loc6_ == _loc7_ || compareFunc(input[_loc10_],input[_loc6_]) <= 0))
               {
                  buffer[_loc9_] = input[_loc10_];
                  _loc10_++;
               }
               else
               {
                  buffer[_loc9_] = input[_loc6_];
                  _loc6_++;
               }
               _loc9_++;
            }
            _loc9_ = startIndex;
            while(_loc9_ < _loc7_)
            {
               input[_loc9_] = buffer[int(_loc9_ - startIndex)];
               _loc9_++;
            }
         }
      }
      
      override public function dispose() : void
      {
         var _loc1_:int = 0;
         _loc1_ = _children.length - 1;
         while(_loc1_ >= 0)
         {
            _children[_loc1_].dispose();
            _loc1_--;
         }
         super.dispose();
      }
      
      public function addChild(child:DisplayObject) : DisplayObject
      {
         return addChildAt(child,_children.length);
      }
      
      public function addChildAt(child:DisplayObject, index:int) : DisplayObject
      {
         var _loc3_:DisplayObjectContainer = null;
         var _loc4_:int = int(_children.length);
         if(index >= 0 && index <= _loc4_)
         {
            setRequiresRedraw();
            if(child.parent == this)
            {
               setChildIndex(child,index);
            }
            else
            {
               _children.insertAt(index,child);
               child.removeFromParent();
               child.setParent(this);
               child.dispatchEventWith("added",true);
               if(stage)
               {
                  _loc3_ = child as DisplayObjectContainer;
                  if(_loc3_)
                  {
                     _loc3_.broadcastEventWith("addedToStage");
                  }
                  else
                  {
                     child.dispatchEventWith("addedToStage");
                  }
               }
            }
            return child;
         }
         throw new RangeError("Invalid child index");
      }
      
      public function removeChild(child:DisplayObject, dispose:Boolean = false) : DisplayObject
      {
         var _loc3_:int = getChildIndex(child);
         if(_loc3_ != -1)
         {
            return removeChildAt(_loc3_,dispose);
         }
         return null;
      }
      
      public function removeChildAt(index:int, dispose:Boolean = false) : DisplayObject
      {
         var _loc4_:DisplayObject = null;
         var _loc3_:DisplayObjectContainer = null;
         if(index >= 0 && index < _children.length)
         {
            setRequiresRedraw();
            _loc4_ = _children[index];
            _loc4_.dispatchEventWith("removed",true);
            if(stage)
            {
               _loc3_ = _loc4_ as DisplayObjectContainer;
               if(_loc3_)
               {
                  _loc3_.broadcastEventWith("removedFromStage");
               }
               else
               {
                  _loc4_.dispatchEventWith("removedFromStage");
               }
            }
            _loc4_.setParent(null);
            if(index >= _children.length || _children[index] != _loc4_)
            {
               index = _children.indexOf(_loc4_);
            }
            if(index >= 0)
            {
               _children.removeAt(index);
            }
            if(dispose)
            {
               _loc4_.dispose();
            }
            return _loc4_;
         }
         throw new RangeError("Invalid child index");
      }
      
      public function removeChildren(beginIndex:int = 0, endIndex:int = -1, dispose:Boolean = false) : void
      {
         var _loc4_:int = 0;
         if(endIndex < 0 || endIndex >= numChildren)
         {
            endIndex = numChildren - 1;
         }
         _loc4_ = beginIndex;
         while(_loc4_ <= endIndex)
         {
            removeChildAt(beginIndex,dispose);
            _loc4_++;
         }
      }
      
      public function getChildAt(index:int) : DisplayObject
      {
         var _loc2_:int = int(_children.length);
         if(index < 0)
         {
            index = _loc2_ + index;
         }
         if(index >= 0 && index < _loc2_)
         {
            return _children[index];
         }
         throw new RangeError("Invalid child index");
      }
      
      public function getChildByName(name:String) : DisplayObject
      {
         var _loc3_:int = 0;
         var _loc2_:int = int(_children.length);
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            if(_children[_loc3_].name == name)
            {
               return _children[_loc3_];
            }
            _loc3_++;
         }
         return null;
      }
      
      public function getChildIndex(child:DisplayObject) : int
      {
         return _children.indexOf(child);
      }
      
      public function setChildIndex(child:DisplayObject, index:int) : void
      {
         var _loc3_:int = getChildIndex(child);
         if(_loc3_ == index)
         {
            return;
         }
         if(_loc3_ == -1)
         {
            throw new ArgumentError("Not a child of this container");
         }
         _children.removeAt(_loc3_);
         _children.insertAt(index,child);
         setRequiresRedraw();
      }
      
      public function swapChildren(child1:DisplayObject, child2:DisplayObject) : void
      {
         var _loc3_:int = getChildIndex(child1);
         var _loc4_:int = getChildIndex(child2);
         if(_loc3_ == -1 || _loc4_ == -1)
         {
            throw new ArgumentError("Not a child of this container");
         }
         swapChildrenAt(_loc3_,_loc4_);
      }
      
      public function swapChildrenAt(index1:int, index2:int) : void
      {
         var _loc4_:DisplayObject = getChildAt(index1);
         var _loc3_:DisplayObject = getChildAt(index2);
         _children[index1] = _loc3_;
         _children[index2] = _loc4_;
         setRequiresRedraw();
      }
      
      public function sortChildren(compareFunction:Function) : void
      {
         sSortBuffer.length = _children.length;
         mergeSort(_children,compareFunction,0,_children.length,sSortBuffer);
         sSortBuffer.length = 0;
         setRequiresRedraw();
      }
      
      public function contains(child:DisplayObject) : Boolean
      {
         while(child)
         {
            if(child == this)
            {
               return true;
            }
            child = child.parent;
         }
         return false;
      }
      
      override public function getBounds(targetSpace:DisplayObject, out:Rectangle = null) : Rectangle
      {
         var _loc5_:uint = 0;
         var _loc4_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc9_:int = 0;
         if(out == null)
         {
            out = new Rectangle();
         }
         var _loc8_:int = int(_children.length);
         if(_loc8_ == 0)
         {
            getTransformationMatrix(targetSpace,sBoundsMatrix);
            MatrixUtil.transformCoords(sBoundsMatrix,0,0,sBoundsPoint);
            out.setTo(sBoundsPoint.x,sBoundsPoint.y,0,0);
         }
         else if(_loc8_ == 1)
         {
            _children[0].getBounds(targetSpace,out);
         }
         else
         {
            _loc5_ = 0;
            _loc4_ = 1.7976931348623157e+308;
            var _loc7_:Number = -1.7976931348623157e+308;
            _loc3_ = 1.7976931348623157e+308;
            var _loc6_:Number = -1.7976931348623157e+308;
            _loc9_ = 0;
            while(_loc9_ < _loc8_)
            {
               _children[_loc9_].getBounds(targetSpace,out);
               if(!(out.width == 0 && out.height == 0))
               {
                  _loc5_++;
                  if(_loc4_ > out.x)
                  {
                     _loc4_ = out.x;
                  }
                  if(_loc7_ < out.right)
                  {
                     _loc7_ = out.right;
                  }
                  if(_loc3_ > out.y)
                  {
                     _loc3_ = out.y;
                  }
                  if(_loc6_ < out.bottom)
                  {
                     _loc6_ = out.bottom;
                  }
               }
               _loc9_++;
            }
            if(_loc5_ == 0)
            {
               getTransformationMatrix(targetSpace,sBoundsMatrix);
               MatrixUtil.transformCoords(sBoundsMatrix,0,0,sBoundsPoint);
               out.setTo(sBoundsPoint.x,sBoundsPoint.y,0,0);
            }
            else
            {
               out.setTo(_loc4_,_loc3_,_loc7_ - _loc4_,_loc6_ - _loc3_);
            }
         }
         return out;
      }
      
      override public function hitTest(localPoint:Point) : DisplayObject
      {
         var _loc5_:int = 0;
         var _loc8_:DisplayObject = null;
         var _loc2_:Point = null;
         if(!visible || !touchable || !hitTestMask(localPoint))
         {
            return null;
         }
         var _loc7_:DisplayObject = null;
         var _loc6_:Number = localPoint.x;
         var _loc3_:Number = localPoint.y;
         var _loc4_:int = int(_children.length);
         _loc5_ = _loc4_ - 1;
         while(_loc5_ >= 0)
         {
            _loc8_ = _children[_loc5_];
            if(!_loc8_.isMask)
            {
               sHitTestMatrix.copyFrom(_loc8_.transformationMatrix);
               sHitTestMatrix.invert();
               _loc2_ = Pool.getPoint();
               MatrixUtil.transformCoords(sHitTestMatrix,_loc6_,_loc3_,_loc2_);
               _loc7_ = _loc8_.hitTest(_loc2_);
               Pool.putPoint(_loc2_);
               if(_loc7_)
               {
                  return _touchGroup ? this : _loc7_;
               }
            }
            _loc5_--;
         }
         return null;
      }
      
      override public function render(painter:Painter) : void
      {
         var _loc5_:int = 0;
         var _loc12_:DisplayObject = null;
         var _loc6_:BatchToken = null;
         var _loc2_:BatchToken = null;
         var _loc7_:FragmentFilter = null;
         var _loc13_:DisplayObject = null;
         var _loc9_:DisplayObject = null;
         var _loc10_:int = int(_children.length);
         var _loc4_:uint = painter.frameID;
         var _loc8_:Boolean = _loc4_ != 0;
         var _loc11_:Boolean = _lastParentOrSelfChangeFrameID == _loc4_;
         var _loc3_:Boolean = false;
         painter.pushState();
         _loc5_ = 0;
         while(_loc5_ < _loc10_)
         {
            _loc12_ = _children[_loc5_];
            if(_loc12_._hasVisibleArea)
            {
               if(_loc5_ != 0)
               {
                  painter.restoreState();
               }
               if(_loc11_)
               {
                  _loc12_._lastParentOrSelfChangeFrameID = _loc4_;
               }
               if(_loc12_._lastParentOrSelfChangeFrameID != _loc4_ && _loc12_._lastChildChangeFrameID != _loc4_ && _loc12_._tokenFrameID == _loc4_ - 1 && _loc8_)
               {
                  painter.fillToken(sCacheToken);
                  painter.drawFromCache(_loc12_._pushToken,_loc12_._popToken);
                  painter.fillToken(_loc12_._popToken);
                  _loc12_._pushToken.copyFrom(sCacheToken);
               }
               else
               {
                  _loc6_ = _loc8_ ? _loc12_._pushToken : null;
                  _loc2_ = _loc8_ ? _loc12_._popToken : null;
                  _loc7_ = _loc12_._filter;
                  _loc13_ = _loc12_._mask;
                  painter.fillToken(_loc6_);
                  painter.setStateTo(_loc12_.transformationMatrix,_loc12_.alpha,_loc12_.blendMode);
                  if(_loc13_)
                  {
                     if(_loc3_)
                     {
                        painter.excludeFromCache(_loc12_);
                     }
                     else
                     {
                        painter.drawMask(_loc13_,_loc12_);
                     }
                  }
                  if(_loc7_)
                  {
                     _loc7_.render(painter);
                  }
                  else
                  {
                     _loc12_.render(painter);
                  }
                  if(_loc13_)
                  {
                     _loc9_ = _loc5_ >= _loc10_ - 1 ? null : _children[_loc5_ + 1];
                     if(_loc9_ != null && _loc9_._mask == _loc13_ && _loc9_.maskInverted == _loc12_.maskInverted && _loc9_._hasVisibleArea)
                     {
                        _loc3_ = true;
                     }
                     else
                     {
                        _loc3_ = false;
                        painter.eraseMask(_loc13_,_loc12_);
                     }
                  }
                  painter.fillToken(_loc2_);
               }
               if(_loc8_)
               {
                  _loc12_._tokenFrameID = _loc4_;
               }
            }
            _loc5_++;
         }
         painter.popState();
      }
      
      public function broadcastEvent(event:Event) : void
      {
         var _loc3_:int = 0;
         if(event.bubbles)
         {
            throw new ArgumentError("Broadcast of bubbling events is prohibited");
         }
         var _loc4_:int = int(sBroadcastListeners.length);
         getChildEventListeners(this,event.type,sBroadcastListeners);
         var _loc2_:int = int(sBroadcastListeners.length);
         _loc3_ = _loc4_;
         while(_loc3_ < _loc2_)
         {
            sBroadcastListeners[_loc3_].dispatchEvent(event);
            _loc3_++;
         }
         sBroadcastListeners.length = _loc4_;
      }
      
      public function broadcastEventWith(eventType:String, data:Object = null) : void
      {
         var _loc3_:Event = Event.fromPool(eventType,false,data);
         broadcastEvent(_loc3_);
         Event.toPool(_loc3_);
      }
      
      public function get numChildren() : int
      {
         return _children.length;
      }
      
      public function get touchGroup() : Boolean
      {
         return _touchGroup;
      }
      
      public function set touchGroup(value:Boolean) : void
      {
         _touchGroup = value;
      }
      
      internal function getChildEventListeners(object:DisplayObject, eventType:String, listeners:Vector.<DisplayObject>) : void
      {
         var _loc5_:Vector.<DisplayObject> = undefined;
         var _loc6_:int = 0;
         var _loc7_:int = 0;
         var _loc4_:DisplayObjectContainer = object as DisplayObjectContainer;
         if(object.hasEventListener(eventType))
         {
            listeners[listeners.length] = object;
         }
         if(_loc4_)
         {
            _loc5_ = _loc4_._children;
            _loc6_ = int(_loc5_.length);
            _loc7_ = 0;
            while(_loc7_ < _loc6_)
            {
               getChildEventListeners(_loc5_[_loc7_],eventType,listeners);
               _loc7_++;
            }
         }
      }
   }
}

