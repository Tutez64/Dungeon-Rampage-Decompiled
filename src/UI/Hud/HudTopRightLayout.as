package UI.Hud
{
   import flash.geom.Point;
   import flash.geom.Rectangle;
   
   public class HudTopRightLayout
   {
      
      private static const CENTRE_X:Number = 1872.475;
      
      private static const CENTRE_Y:Number = 57;
      
      private static const GEAR_SCALE:Number = 0.9;
      
      private static const GLYPH_SIZE:Number = 39.47715759277344;
      
      public function HudTopRightLayout()
      {
         super();
      }
      
      private static function core(gear:Boolean) : Rectangle
      {
         return gear ? new Rectangle(-29.5,-32.75,65.55,63.85) : new Rectangle(-12.4,-13.35,27.55,27.45);
      }
      
      public static function closePosition(scaleX:Number, scaleY:Number) : Point
      {
         var _loc3_:Rectangle = core(false);
         return new Point(1872.475 - (_loc3_.x + _loc3_.width / 2) * scaleX,57 - (_loc3_.y + _loc3_.height / 2) * scaleY);
      }
      
      public static function gearPosition() : Point
      {
         var _loc1_:Rectangle = core(true);
         return new Point(1872.475 - (_loc1_.x + _loc1_.width / 2) * 0.9,143.5);
      }
      
      public static function glyphSize(scaleX:Number, scaleY:Number) : Point
      {
         return new Point(39.47715759277344 / scaleX,39.47715759277344 / scaleY);
      }
      
      public static function glyphPosition(gear:Boolean, scaleX:Number, scaleY:Number) : Point
      {
         var _loc5_:Rectangle = core(gear);
         var _loc4_:Point = glyphSize(scaleX,scaleY);
         return new Point(_loc5_.right - _loc4_.x / 2,_loc5_.top - _loc4_.y / 2);
      }
   }
}

