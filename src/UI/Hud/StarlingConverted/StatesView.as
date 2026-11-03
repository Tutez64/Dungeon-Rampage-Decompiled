package UI.Hud.StarlingConverted
{
   public class StatesView extends ArtDisplay
   {
      
      protected var mFrame:int = -1;
      
      public function StatesView(art:ArtNode)
      {
         super(art);
      }
      
      public function gotoAndStop(frame:Object) : void
      {
         var _loc2_:int = frame is String ? int(mArt.labels[String(frame)]) : int(frame);
         showFrame(Math.max(0,Math.min(mArt.totalFrames - 1,_loc2_)));
      }
      
      protected function showFrame(index:int) : void
      {
         var _loc2_:int = 0;
         var _loc3_:ArtChildState = null;
         var _loc5_:ArtDisplay = null;
         if(index == mFrame || index < 0 || index >= mArt.frames.length)
         {
            return;
         }
         mFrame = index;
         var _loc4_:ArtFrame = mArt.frames[index];
         _loc2_ = 0;
         while(_loc2_ < mChildren.length)
         {
            mChildren[_loc2_].authoredVisibility(false);
            _loc2_++;
         }
         if(mImage != null)
         {
            showCells(_loc4_ != null ? _loc4_.cell : null);
         }
         if(_loc4_ == null)
         {
            return;
         }
         applyFilters(_loc4_.filterState);
         _loc2_ = 0;
         while(_loc2_ < _loc4_.children.length)
         {
            _loc3_ = _loc4_.children[_loc2_];
            if(!(_loc3_.child < 0 || _loc3_.child >= mChildren.length))
            {
               _loc5_ = mChildren[_loc3_.child];
               setChildIndex(_loc5_,_loc2_);
               _loc5_.authoredMatrix(_loc3_.matrix);
               _loc5_.alpha = _loc3_.alpha;
               _loc5_.authoredVisibility(_loc3_.visible);
               _loc5_.blendMode = _loc3_.blendMode;
               _loc5_.setLocalColor(_loc3_.colorTransform);
               _loc5_.applyClip(_loc3_.parentClip);
               _loc5_.applyFilters(_loc3_.filterState);
               applyChildFrame(_loc5_,_loc3_.frame);
            }
            _loc2_++;
         }
      }
      
      protected function applyChildFrame(child:ArtDisplay, frame:int) : void
      {
         if(child is StatesView)
         {
            StatesView(child).gotoAndStop(frame);
         }
      }
      
      public function get currentFrame() : int
      {
         return mFrame;
      }
   }
}

