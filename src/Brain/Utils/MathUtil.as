package Brain.Utils
{
   import flash.display.DisplayObject;
   import flash.geom.Point;
   
   public class MathUtil
   {
      
      private static var spare:Number;
      
      private static var spareReady:Boolean = false;
      
      public function MathUtil()
      {
         super();
      }
      
      public static function rand(min:Number, max:Number) : Number
      {
         return min + (max - min) * Math.random();
      }
      
      public static function rad2deg(rad:Number) : Number
      {
         return rad * 180 / 3.141592653589793;
      }
      
      public static function deg2rad(deg:Number) : Number
      {
         return deg * 3.141592653589793 / 180;
      }
      
      public static function degreesBetweenPoints(fromPoint:Point, toPoint:Point) : Number
      {
         return Math.atan2(toPoint.y - fromPoint.y,toPoint.x - fromPoint.x) * 180 / 3.141592653589793;
      }
      
      public static function degreesToFaceObject(fromObj:DisplayObject, toObj:DisplayObject) : Number
      {
         return Math.atan2(toObj.y - fromObj.y,toObj.x - fromObj.x) * 180 / 3.141592653589793;
      }
      
      public static function getGaussian(mean:Number, stdDev:Number) : Number
      {
         var _loc4_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc3_:Number = NaN;
         if(spareReady)
         {
            spareReady = false;
            return spare * stdDev + mean;
         }
         do
         {
            _loc4_ = Math.random() * 2 - 1;
            _loc5_ = Math.random() * 2 - 1;
            _loc3_ = _loc4_ * _loc4_ + _loc5_ * _loc5_;
         }
         while(_loc3_ >= 1 || _loc3_ == 0);
         spare = _loc5_ * Math.sqrt(-2 * Math.log(_loc3_) / _loc3_);
         spareReady = true;
         return mean + stdDev * _loc4_ * Math.sqrt(-2 * Math.log(_loc3_) / _loc3_);
      }
   }
}

