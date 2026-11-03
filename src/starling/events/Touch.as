package starling.events
{
   import flash.geom.Point;
   import starling.display.DisplayObject;
   import starling.utils.Pool;
   import starling.utils.StringUtil;
   
   public class Touch
   {
      
      private static var sHelperPoint:Point = new Point();
      
      private var _id:int;
      
      private var _globalX:Number;
      
      private var _globalY:Number;
      
      private var _previousGlobalX:Number;
      
      private var _previousGlobalY:Number;
      
      private var _startGlobalX:Number;
      
      private var _startGlobalY:Number;
      
      private var _startTimestamp:Number;
      
      private var _tapCount:int;
      
      private var _phase:String;
      
      private var _target:DisplayObject;
      
      private var _timestamp:Number;
      
      private var _pressure:Number;
      
      private var _width:Number;
      
      private var _height:Number;
      
      private var _cancelled:Boolean;
      
      private var _bubbleChain:Vector.<EventDispatcher>;
      
      public function Touch(id:int)
      {
         super();
         _id = id;
         _tapCount = 0;
         _phase = "hover";
         _pressure = _width = _height = 1;
         _bubbleChain = new Vector.<EventDispatcher>(0);
         _timestamp = _startTimestamp = -1;
      }
      
      private static function getMovementBetween(startX:Number, startY:Number, endX:Number, endY:Number, space:DisplayObject, out:Point = null) : Point
      {
         if(out == null)
         {
            out = new Point();
         }
         var _loc7_:Point = Pool.getPoint(startX,startY);
         var _loc8_:Point = Pool.getPoint(endX,endY);
         space.globalToLocal(_loc7_,_loc7_);
         space.globalToLocal(_loc8_,_loc8_);
         out.setTo(_loc8_.x - _loc7_.x,_loc8_.y - _loc7_.y);
         Pool.putPoint(_loc7_);
         Pool.putPoint(_loc8_);
         return out;
      }
      
      public function getLocation(space:DisplayObject, out:Point = null) : Point
      {
         sHelperPoint.setTo(_globalX,_globalY);
         return space.globalToLocal(sHelperPoint,out);
      }
      
      public function getPreviousLocation(space:DisplayObject, out:Point = null) : Point
      {
         sHelperPoint.setTo(_previousGlobalX,_previousGlobalY);
         return space.globalToLocal(sHelperPoint,out);
      }
      
      public function getStartLocation(space:DisplayObject, out:Point = null) : Point
      {
         sHelperPoint.setTo(_startGlobalX,_startGlobalY);
         return space.globalToLocal(sHelperPoint,out);
      }
      
      public function getMovement(space:DisplayObject, out:Point = null) : Point
      {
         return getMovementBetween(_previousGlobalX,_previousGlobalY,_globalX,_globalY,space,out);
      }
      
      public function getMovementSinceStart(space:DisplayObject, out:Point = null) : Point
      {
         return getMovementBetween(_startGlobalX,_startGlobalY,_globalX,_globalY,space,out);
      }
      
      public function isTouching(target:DisplayObject) : Boolean
      {
         return _bubbleChain.indexOf(target) != -1;
      }
      
      public function toString() : String
      {
         return StringUtil.format("[Touch {0}: globalX={1}, globalY={2}, phase={3}]",_id,_globalX,_globalY,_phase);
      }
      
      public function clone() : Touch
      {
         var _loc1_:Touch = new Touch(_id);
         _loc1_._globalX = _globalX;
         _loc1_._globalY = _globalY;
         _loc1_._previousGlobalX = _previousGlobalX;
         _loc1_._previousGlobalY = _previousGlobalY;
         _loc1_._startGlobalX = _startGlobalX;
         _loc1_._startGlobalY = _startGlobalY;
         _loc1_._startTimestamp = _startTimestamp;
         _loc1_._phase = _phase;
         _loc1_._tapCount = _tapCount;
         _loc1_._timestamp = _timestamp;
         _loc1_._pressure = _pressure;
         _loc1_._width = _width;
         _loc1_._height = _height;
         _loc1_._cancelled = _cancelled;
         _loc1_.target = _target;
         return _loc1_;
      }
      
      private function updateBubbleChain() : void
      {
         var _loc1_:int = 0;
         var _loc2_:DisplayObject = null;
         if(_target)
         {
            _loc1_ = 1;
            _loc2_ = _target;
            _bubbleChain.length = 1;
            _bubbleChain[0] = _loc2_;
            while(true)
            {
               _loc2_ = _loc2_.parent;
               if(_loc2_ == null)
               {
                  break;
               }
               _bubbleChain[_loc1_++] = _loc2_;
            }
         }
         else
         {
            _bubbleChain.length = 0;
         }
      }
      
      public function get id() : int
      {
         return _id;
      }
      
      public function get previousGlobalX() : Number
      {
         return _previousGlobalX;
      }
      
      public function get previousGlobalY() : Number
      {
         return _previousGlobalY;
      }
      
      public function get startGlobalX() : Number
      {
         return _startGlobalX;
      }
      
      public function get startGlobalY() : Number
      {
         return _startGlobalY;
      }
      
      public function get globalX() : Number
      {
         return _globalX;
      }
      
      public function set globalX(value:Number) : void
      {
         if(_globalX != _globalX)
         {
            _previousGlobalX = _startGlobalX = value;
         }
         else
         {
            _previousGlobalX = _globalX;
         }
         _globalX = value;
      }
      
      public function get globalY() : Number
      {
         return _globalY;
      }
      
      public function set globalY(value:Number) : void
      {
         if(_globalY != _globalY)
         {
            _previousGlobalY = _startGlobalY = value;
         }
         else
         {
            _previousGlobalY = _globalY;
         }
         _globalY = value;
      }
      
      public function get tapCount() : int
      {
         return _tapCount;
      }
      
      public function set tapCount(value:int) : void
      {
         _tapCount = value;
      }
      
      public function get phase() : String
      {
         return _phase;
      }
      
      public function set phase(value:String) : void
      {
         _phase = value;
         if(value == "began")
         {
            _startGlobalX = _globalX;
            _startGlobalY = _globalY;
            _startTimestamp = _timestamp;
         }
      }
      
      public function get target() : DisplayObject
      {
         return _target;
      }
      
      public function set target(value:DisplayObject) : void
      {
         if(_target != value)
         {
            _target = value;
            updateBubbleChain();
         }
      }
      
      public function get timestamp() : Number
      {
         return _timestamp;
      }
      
      public function set timestamp(value:Number) : void
      {
         if(_startTimestamp < 0)
         {
            _startTimestamp = value;
         }
         _timestamp = value;
      }
      
      public function get pressure() : Number
      {
         return _pressure;
      }
      
      public function set pressure(value:Number) : void
      {
         _pressure = value;
      }
      
      public function get width() : Number
      {
         return _width;
      }
      
      public function set width(value:Number) : void
      {
         _width = value;
      }
      
      public function get height() : Number
      {
         return _height;
      }
      
      public function set height(value:Number) : void
      {
         _height = value;
      }
      
      public function get cancelled() : Boolean
      {
         return _cancelled;
      }
      
      public function set cancelled(value:Boolean) : void
      {
         _cancelled = value;
      }
      
      public function get duration() : Number
      {
         if(_timestamp < 0 || _startTimestamp < 0 || _startTimestamp > _timestamp)
         {
            return -1;
         }
         return _timestamp - _startTimestamp;
      }
      
      internal function update(timestamp:Number, phase:String, globalX:Number, globalY:Number, pressure:Number = 1, width:Number = 1, height:Number = 1) : void
      {
         _pressure = pressure;
         _width = width;
         _height = height;
         this.timestamp = timestamp;
         this.globalX = globalX;
         this.globalY = globalY;
         this.phase = phase;
      }
      
      internal function dispatchEvent(event:TouchEvent) : void
      {
         if(_target)
         {
            event.dispatch(_bubbleChain);
         }
      }
      
      internal function get bubbleChain() : Vector.<EventDispatcher>
      {
         return _bubbleChain.concat();
      }
   }
}

