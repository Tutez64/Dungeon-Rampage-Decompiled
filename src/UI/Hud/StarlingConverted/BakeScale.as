package UI.Hud.StarlingConverted
{
   import flash.geom.Matrix;
   import starling.core.Starling;
   import starling.display.DisplayObject;
   
   internal class BakeScale
   {
      
      public function BakeScale()
      {
         super();
      }
      
      internal static function magnitude(matrix:Matrix) : Number
      {
         return Math.max(Math.sqrt(matrix.a * matrix.a + matrix.b * matrix.b),Math.sqrt(matrix.c * matrix.c + matrix.d * matrix.d));
      }
      
      internal static function forDisplay(node:DisplayObject) : Number
      {
         return magnitude(node.getTransformationMatrix(Starling.current.stage)) * HudArt.pixelScale;
      }
      
      internal static function forArt(node:ArtNode, path:String) : Number
      {
         var _loc7_:ArtNode = null;
         var _loc6_:Matrix = null;
         var _loc3_:String = null;
         var _loc4_:Array = path.length > 0 ? path.split(".") : [];
         var _loc5_:Matrix = node.matrix.clone();
         for each(_loc3_ in _loc4_)
         {
            _loc7_ = node.find(_loc3_);
            if(_loc7_ == null)
            {
               return 1;
            }
            _loc6_ = _loc7_.matrix.clone();
            _loc6_.concat(_loc5_);
            _loc5_ = _loc6_;
            node = _loc7_;
         }
         return magnitude(_loc5_);
      }
   }
}

