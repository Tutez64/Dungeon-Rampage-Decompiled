package UI.Hud.StarlingConverted
{
   import Brain.Starling.SwfConverter.BakedCell;
   import Brain.Starling.SwfConverter.BakedImage;
   import starling.rendering.Painter;
   
   public class StarlingBarImage extends BakedImage
   {
      
      private var mLeft:Number = -Infinity;
      
      private var mRight:Number = Infinity;
      
      private var mDirty:Boolean = true;
      
      private var mEmpty:Boolean;
      
      public function StarlingBarImage(cell:BakedCell = null)
      {
         super(cell);
      }
      
      override public function set cell(value:BakedCell) : void
      {
         super.cell = value;
         mDirty = true;
      }
      
      public function setCut(left:Number, right:Number) : void
      {
         if(left == mLeft && right == mRight)
         {
            return;
         }
         mLeft = left;
         mRight = right;
         mDirty = true;
         setRequiresRedraw();
      }
      
      override public function render(painter:Painter) : void
      {
         if(cell == null || !cell.alive)
         {
            return;
         }
         if(mDirty)
         {
            applyCut();
         }
         if(mEmpty)
         {
            return;
         }
         super.render(painter);
      }
      
      private function applyCut() : void
      {
         mDirty = false;
         var _loc2_:Number = texture.width;
         var _loc3_:Number = texture.height;
         var _loc4_:Number = mLeft + pivotX;
         var _loc1_:Number = mRight + pivotX;
         if(_loc4_ < 0)
         {
            _loc4_ = 0;
         }
         if(_loc1_ > _loc2_)
         {
            _loc1_ = _loc2_;
         }
         mEmpty = _loc1_ <= _loc4_;
         if(mEmpty)
         {
            return;
         }
         setVertexPosition(0,_loc4_,0);
         setVertexPosition(1,_loc1_,0);
         setVertexPosition(2,_loc4_,_loc3_);
         setVertexPosition(3,_loc1_,_loc3_);
         setTexCoords(0,_loc4_ / _loc2_,0);
         setTexCoords(1,_loc1_ / _loc2_,0);
         setTexCoords(2,_loc4_ / _loc2_,1);
         setTexCoords(3,_loc1_ / _loc2_,1);
      }
   }
}

