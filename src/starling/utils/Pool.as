package starling.utils
{
   import flash.geom.Matrix;
   import flash.geom.Matrix3D;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import starling.errors.AbstractClassError;
   
   public class Pool
   {
      
      private static var sPoints:Vector.<Point> = new Vector.<Point>(0);
      
      private static var sPoints3D:Vector.<Vector3D> = new Vector.<Vector3D>(0);
      
      private static var sMatrices:Vector.<Matrix> = new Vector.<Matrix>(0);
      
      private static var sMatrices3D:Vector.<Matrix3D> = new Vector.<Matrix3D>(0);
      
      private static var sRectangles:Vector.<Rectangle> = new Vector.<Rectangle>(0);
      
      private static var sArrays:Vector.<Array> = new Vector.<Array>(0);
      
      public function Pool()
      {
         super();
         throw new AbstractClassError();
      }
      
      public static function getPoint(x:Number = 0, y:Number = 0) : Point
      {
         var _loc3_:Point = null;
         if(sPoints.length == 0)
         {
            return new Point(x,y);
         }
         _loc3_ = sPoints.pop();
         _loc3_.x = x;
         _loc3_.y = y;
         return _loc3_;
      }
      
      public static function putPoint(point:Point) : void
      {
         if(point)
         {
            sPoints[sPoints.length] = point;
         }
      }
      
      public static function getPoint3D(x:Number = 0, y:Number = 0, z:Number = 0) : Vector3D
      {
         var _loc4_:Vector3D = null;
         if(sPoints3D.length == 0)
         {
            return new Vector3D(x,y,z);
         }
         _loc4_ = sPoints3D.pop();
         _loc4_.x = x;
         _loc4_.y = y;
         _loc4_.z = z;
         return _loc4_;
      }
      
      public static function putPoint3D(point:Vector3D) : void
      {
         if(point)
         {
            sPoints3D[sPoints3D.length] = point;
         }
      }
      
      public static function getMatrix(a:Number = 1, b:Number = 0, c:Number = 0, d:Number = 1, tx:Number = 0, ty:Number = 0) : Matrix
      {
         var _loc7_:Matrix = null;
         if(sMatrices.length == 0)
         {
            return new Matrix(a,b,c,d,tx,ty);
         }
         _loc7_ = sMatrices.pop();
         _loc7_.setTo(a,b,c,d,tx,ty);
         return _loc7_;
      }
      
      public static function putMatrix(matrix:Matrix) : void
      {
         if(matrix)
         {
            sMatrices[sMatrices.length] = matrix;
         }
      }
      
      public static function getMatrix3D(identity:Boolean = true) : Matrix3D
      {
         var _loc2_:Matrix3D = null;
         if(sMatrices3D.length == 0)
         {
            return new Matrix3D();
         }
         _loc2_ = sMatrices3D.pop();
         if(identity)
         {
            _loc2_.identity();
         }
         return _loc2_;
      }
      
      public static function putMatrix3D(matrix:Matrix3D) : void
      {
         if(matrix)
         {
            sMatrices3D[sMatrices3D.length] = matrix;
         }
      }
      
      public static function getRectangle(x:Number = 0, y:Number = 0, width:Number = 0, height:Number = 0) : Rectangle
      {
         var _loc5_:Rectangle = null;
         if(sRectangles.length == 0)
         {
            return new Rectangle(x,y,width,height);
         }
         _loc5_ = sRectangles.pop();
         _loc5_.setTo(x,y,width,height);
         return _loc5_;
      }
      
      public static function putRectangle(rectangle:Rectangle) : void
      {
         if(rectangle)
         {
            sRectangles[sRectangles.length] = rectangle;
         }
      }
      
      public static function getArray() : Array
      {
         if(sArrays.length == 0)
         {
            return [];
         }
         return sArrays.pop();
      }
      
      public static function putArray(array:Array) : void
      {
         array.length = 0;
         sArrays[sArrays.length] = array;
      }
   }
}

