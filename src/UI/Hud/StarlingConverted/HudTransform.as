package UI.Hud.StarlingConverted
{
   import Facade.DBFacade;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import starling.core.Starling;
   import starling.display.DisplayObject;
   
   internal class HudTransform
   {
      
      public function HudTransform()
      {
         super();
      }
      
      internal static function sync(facade:DBFacade, root:DisplayObject) : Boolean
      {
         var _loc4_:Starling = Starling.current;
         if(_loc4_ == null || root == null)
         {
            return false;
         }
         var _loc6_:Rectangle = _loc4_.viewPort;
         var _loc7_:Number = _loc6_.width / _loc4_.stage.stageWidth;
         var _loc8_:Number = _loc6_.height / _loc4_.stage.stageHeight;
         if(!(_loc7_ > 0 && _loc8_ > 0))
         {
            return false;
         }
         var _loc3_:Number = facade.scalingRoot.scaleX / _loc7_;
         var _loc5_:Number = facade.scalingRoot.scaleY / _loc8_;
         var _loc9_:Number = (facade.scalingRoot.x - _loc4_.stage3D.x) / _loc7_;
         var _loc10_:Number = (facade.scalingRoot.y - _loc4_.stage3D.y) / _loc8_;
         if(root.x == _loc9_ && root.y == _loc10_ && root.scaleX == _loc3_ && root.scaleY == _loc5_)
         {
            return false;
         }
         root.x = _loc9_;
         root.y = _loc10_;
         root.scaleX = _loc3_;
         root.scaleY = _loc5_;
         return true;
      }
      
      internal static function inverse(facade:DBFacade, matrix:Matrix) : void
      {
         matrix.setTo(1 / facade.scalingRoot.scaleX,0,0,1 / facade.scalingRoot.scaleY,-facade.scalingRoot.x / facade.scalingRoot.scaleX,-facade.scalingRoot.y / facade.scalingRoot.scaleY);
      }
   }
}

