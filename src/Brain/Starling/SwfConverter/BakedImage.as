package Brain.Starling.SwfConverter
{
   import starling.display.Image;
   import starling.rendering.Painter;
   
   public class BakedImage extends Image
   {
      
      private var mCell:BakedCell;
      
      public function BakedImage(cell:BakedCell = null)
      {
         super(cell != null ? cell.texture : null);
         touchable = false;
         this.cell = cell;
      }
      
      public function get cell() : BakedCell
      {
         return mCell;
      }
      
      public function set cell(value:BakedCell) : void
      {
         mCell = value;
         if(value == null || !value.alive)
         {
            return;
         }
         texture = value.texture;
         readjustSize();
         pivotX = value.pivotX;
         pivotY = value.pivotY;
      }
      
      override public function render(painter:Painter) : void
      {
         if(mCell == null || !mCell.alive)
         {
            return;
         }
         super.render(painter);
      }
   }
}

