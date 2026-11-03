package starling.events
{
   public class TouchData
   {
      
      private static var sPool:Vector.<TouchData> = new Vector.<TouchData>(0);
      
      private var _id:int;
      
      private var _phase:String;
      
      private var _globalX:Number;
      
      private var _globalY:Number;
      
      private var _pressure:Number;
      
      private var _width:Number;
      
      private var _height:Number;
      
      public function TouchData()
      {
         super();
      }
      
      public static function fromPool(touchID:int, phase:String, globalX:Number, globalY:Number, pressure:Number = 1, width:Number = 1, height:Number = 1) : TouchData
      {
         var _loc8_:TouchData = sPool.length > 0 ? sPool.pop() : new TouchData();
         _loc8_.setTo(touchID,phase,globalX,globalY,pressure,width,height);
         return _loc8_;
      }
      
      public static function toPool(rawTouch:TouchData) : void
      {
         sPool[sPool.length] = rawTouch;
      }
      
      private function setTo(touchID:int, phase:String, globalX:Number, globalY:Number, pressure:Number = 1, width:Number = 1, height:Number = 1) : void
      {
         _id = touchID;
         _phase = phase;
         _globalX = globalX;
         _globalY = globalY;
         _pressure = pressure;
         _width = width;
         _height = height;
      }
      
      public function get id() : int
      {
         return _id;
      }
      
      public function get phase() : String
      {
         return _phase;
      }
      
      public function get globalX() : Number
      {
         return _globalX;
      }
      
      public function get globalY() : Number
      {
         return _globalY;
      }
      
      public function get pressure() : Number
      {
         return _pressure;
      }
      
      public function get width() : Number
      {
         return _width;
      }
      
      public function get height() : Number
      {
         return _height;
      }
   }
}

