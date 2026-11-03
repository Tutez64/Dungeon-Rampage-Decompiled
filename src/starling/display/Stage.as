package starling.display
{
   import flash.errors.IllegalOperationError;
   import flash.geom.Matrix;
   import flash.geom.Matrix3D;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import starling.core.Starling;
   import starling.core.starling_internal;
   import starling.events.EnterFrameEvent;
   import starling.filters.FragmentFilter;
   import starling.utils.MatrixUtil;
   import starling.utils.RectangleUtil;
   
   use namespace starling_internal;
   
   public class Stage extends DisplayObjectContainer
   {
      
      private static var sMatrix:Matrix = new Matrix();
      
      private static var sMatrix3D:Matrix3D = new Matrix3D();
      
      private var _width:int;
      
      private var _height:int;
      
      private var _color:uint;
      
      private var _fieldOfView:Number;
      
      private var _projectionOffset:Point;
      
      private var _cameraPosition:Vector3D;
      
      private var _enterFrameEvent:EnterFrameEvent;
      
      private var _enterFrameListeners:Vector.<DisplayObject>;
      
      public function Stage(width:int, height:int, color:uint = 0)
      {
         super();
         _width = width;
         _height = height;
         _color = color;
         _fieldOfView = 1;
         _projectionOffset = new Point();
         _cameraPosition = new Vector3D();
         _enterFrameEvent = new EnterFrameEvent("enterFrame",0);
         _enterFrameListeners = new Vector.<DisplayObject>(0);
      }
      
      public function advanceTime(passedTime:Number) : void
      {
         _enterFrameEvent.reset("enterFrame",false,passedTime);
         broadcastEvent(_enterFrameEvent);
      }
      
      override public function hitTest(localPoint:Point) : DisplayObject
      {
         if(!visible || !touchable)
         {
            return null;
         }
         if(localPoint.x < 0 || localPoint.x > _width || localPoint.y < 0 || localPoint.y > _height)
         {
            return null;
         }
         var _loc2_:DisplayObject = super.hitTest(localPoint);
         return _loc2_ ? _loc2_ : this;
      }
      
      public function getStageBounds(targetSpace:DisplayObject, out:Rectangle = null) : Rectangle
      {
         if(out == null)
         {
            out = new Rectangle();
         }
         out.setTo(0,0,_width,_height);
         getTransformationMatrix(targetSpace,sMatrix);
         return RectangleUtil.getBounds(out,sMatrix,out);
      }
      
      public function getScreenBounds(targetSpace:DisplayObject, out:Rectangle = null) : Rectangle
      {
         var _loc9_:Starling = this.starling;
         if(_loc9_ == null)
         {
            return getStageBounds(targetSpace,out);
         }
         if(out == null)
         {
            out = new Rectangle();
         }
         var _loc4_:Object = _loc9_.nativeStage;
         var _loc6_:Rectangle = _loc9_.viewPort;
         var _loc3_:Number = _width / _loc6_.width;
         var _loc5_:Number = _height / _loc6_.height;
         var _loc7_:Number = -_loc6_.x * _loc3_;
         var _loc8_:Number = -_loc6_.y * _loc5_;
         out.setTo(_loc7_,_loc8_,_loc4_.stageWidth * _loc3_,_loc4_.stageHeight * _loc5_);
         getTransformationMatrix(targetSpace,sMatrix);
         return RectangleUtil.getBounds(out,sMatrix,out);
      }
      
      public function getCameraPosition(space:DisplayObject = null, out:Vector3D = null) : Vector3D
      {
         getTransformationMatrix3D(space,sMatrix3D);
         return MatrixUtil.transformCoords3D(sMatrix3D,_width / 2 + _projectionOffset.x,_height / 2 + _projectionOffset.y,-focalLength,out);
      }
      
      internal function addEnterFrameListener(listener:DisplayObject) : void
      {
         var _loc2_:int = _enterFrameListeners.indexOf(listener);
         if(_loc2_ < 0)
         {
            _enterFrameListeners[_enterFrameListeners.length] = listener;
         }
      }
      
      internal function removeEnterFrameListener(listener:DisplayObject) : void
      {
         var _loc2_:int = _enterFrameListeners.indexOf(listener);
         if(_loc2_ >= 0)
         {
            _enterFrameListeners.removeAt(_loc2_);
         }
      }
      
      override internal function getChildEventListeners(object:DisplayObject, eventType:String, listeners:Vector.<DisplayObject>) : void
      {
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         if(eventType == "enterFrame" && object == this)
         {
            _loc5_ = 0;
            _loc4_ = int(_enterFrameListeners.length);
            while(_loc5_ < _loc4_)
            {
               listeners[listeners.length] = _enterFrameListeners[_loc5_];
               _loc5_++;
            }
         }
         else
         {
            super.getChildEventListeners(object,eventType,listeners);
         }
      }
      
      override public function set width(value:Number) : void
      {
         throw new IllegalOperationError("Cannot set width of stage");
      }
      
      override public function set height(value:Number) : void
      {
         throw new IllegalOperationError("Cannot set height of stage");
      }
      
      override public function set x(value:Number) : void
      {
         throw new IllegalOperationError("Cannot set x-coordinate of stage");
      }
      
      override public function set y(value:Number) : void
      {
         throw new IllegalOperationError("Cannot set y-coordinate of stage");
      }
      
      override public function set scaleX(value:Number) : void
      {
         throw new IllegalOperationError("Cannot scale stage");
      }
      
      override public function set scaleY(value:Number) : void
      {
         throw new IllegalOperationError("Cannot scale stage");
      }
      
      override public function set rotation(value:Number) : void
      {
         throw new IllegalOperationError("Cannot rotate stage");
      }
      
      override public function set skewX(value:Number) : void
      {
         throw new IllegalOperationError("Cannot skew stage");
      }
      
      override public function set skewY(value:Number) : void
      {
         throw new IllegalOperationError("Cannot skew stage");
      }
      
      override public function set filter(value:FragmentFilter) : void
      {
         throw new IllegalOperationError("Cannot add filter to stage. Add it to \'root\' instead!");
      }
      
      public function get color() : uint
      {
         return _color;
      }
      
      public function set color(value:uint) : void
      {
         if(_color != value)
         {
            _color = value;
            setRequiresRedraw();
         }
      }
      
      public function get stageWidth() : int
      {
         return _width;
      }
      
      public function set stageWidth(value:int) : void
      {
         if(_width != value)
         {
            _width = value;
            setRequiresRedraw();
         }
      }
      
      public function get stageHeight() : int
      {
         return _height;
      }
      
      public function set stageHeight(value:int) : void
      {
         if(_height != value)
         {
            _height = value;
            setRequiresRedraw();
         }
      }
      
      public function get starling() : Starling
      {
         var _loc3_:int = 0;
         var _loc1_:Vector.<Starling> = Starling.all;
         var _loc2_:int = int(_loc1_.length);
         _loc3_ = 0;
         while(_loc3_ < _loc2_)
         {
            if(_loc1_[_loc3_].stage == this)
            {
               return _loc1_[_loc3_];
            }
            _loc3_++;
         }
         return null;
      }
      
      public function get focalLength() : Number
      {
         return _width / (2 * Math.tan(_fieldOfView / 2));
      }
      
      public function set focalLength(value:Number) : void
      {
         _fieldOfView = 2 * Math.atan(stageWidth / (2 * value));
         setRequiresRedraw();
      }
      
      public function get fieldOfView() : Number
      {
         return _fieldOfView;
      }
      
      public function set fieldOfView(value:Number) : void
      {
         _fieldOfView = value;
         setRequiresRedraw();
      }
      
      public function get projectionOffset() : Point
      {
         return _projectionOffset;
      }
      
      public function set projectionOffset(value:Point) : void
      {
         _projectionOffset.setTo(value.x,value.y);
         setRequiresRedraw();
      }
      
      public function get cameraPosition() : Vector3D
      {
         return getCameraPosition(null,_cameraPosition);
      }
   }
}

