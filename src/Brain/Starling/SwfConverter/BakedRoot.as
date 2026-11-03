package Brain.Starling.SwfConverter
{
   import starling.display.Sprite;
   import starling.rendering.Painter;
   
   public class BakedRoot extends Sprite
   {
      
      public function BakedRoot()
      {
         super();
         touchable = false;
      }
      
      override public function render(painter:Painter) : void
      {
         painter.excludeFromCache(this);
         var _loc2_:Boolean = painter.cacheEnabled;
         painter.cacheEnabled = false;
         try
         {
            super.render(painter);
         }
         finally
         {
            painter.cacheEnabled = _loc2_;
         }
      }
   }
}

