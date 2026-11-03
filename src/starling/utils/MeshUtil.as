package starling.utils
{
   import flash.geom.Matrix;
   import flash.geom.Matrix3D;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import starling.display.DisplayObject;
   import starling.display.Stage;
   import starling.errors.AbstractClassError;
   import starling.rendering.IndexData;
   import starling.rendering.VertexData;
   
   public class MeshUtil
   {
      
      private static var sPoint3D:Vector3D = new Vector3D();
      
      private static var sMatrix:Matrix = new Matrix();
      
      private static var sMatrix3D:Matrix3D = new Matrix3D();
      
      public function MeshUtil()
      {
         super();
         throw new AbstractClassError();
      }
      
      public static function containsPoint(vertexData:VertexData, indexData:IndexData, point:Point) : Boolean
      {
         var _loc9_:int = 0;
         var _loc4_:Boolean = false;
         var _loc7_:int = indexData.numIndices;
         var _loc5_:Point = Pool.getPoint();
         var _loc6_:Point = Pool.getPoint();
         var _loc8_:Point = Pool.getPoint();
         _loc9_ = 0;
         while(_loc9_ < _loc7_)
         {
            vertexData.getPoint(indexData.getIndex(_loc9_),"position",_loc5_);
            vertexData.getPoint(indexData.getIndex(_loc9_ + 1),"position",_loc6_);
            vertexData.getPoint(indexData.getIndex(_loc9_ + 2),"position",_loc8_);
            if(MathUtil.isPointInTriangle(point,_loc5_,_loc6_,_loc8_))
            {
               _loc4_ = true;
               break;
            }
            _loc9_ += 3;
         }
         Pool.putPoint(_loc5_);
         Pool.putPoint(_loc6_);
         Pool.putPoint(_loc8_);
         return _loc4_;
      }
      
      public static function calculateBounds(vertexData:VertexData, sourceSpace:DisplayObject, targetSpace:DisplayObject, out:Rectangle = null) : Rectangle
      {
         if(out == null)
         {
            out = new Rectangle();
         }
         var _loc5_:Stage = sourceSpace.stage;
         if(sourceSpace.is3D && _loc5_)
         {
            _loc5_.getCameraPosition(targetSpace,sPoint3D);
            sourceSpace.getTransformationMatrix3D(targetSpace,sMatrix3D);
            vertexData.getBoundsProjected("position",sMatrix3D,sPoint3D,0,-1,out);
         }
         else
         {
            sourceSpace.getTransformationMatrix(targetSpace,sMatrix);
            vertexData.getBounds("position",sMatrix,0,-1,out);
         }
         return out;
      }
   }
}

