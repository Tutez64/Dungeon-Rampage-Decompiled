package Brain.Render
{
   import Brain.Utils.MemoryTracker;
   import flash.display.DisplayObject;
   
   public class SortOnAddLayer extends Layer
   {
      
      private var mNeedsSort:Boolean = false;
      
      public function SortOnAddLayer(sortIndex:int = 0)
      {
         super(sortIndex);
         MemoryTracker.track(this,"SortOnAddLayer sortIndex=" + sortIndex + " - created in SortOnAddLayer()","brain");
      }
      
      override public function addChild(child:DisplayObject) : DisplayObject
      {
         super.addChild(child);
         mNeedsSort = true;
         return child;
      }
      
      override public function addChildAt(child:DisplayObject, index:int) : DisplayObject
      {
         super.addChildAt(child,index);
         mNeedsSort = true;
         return child;
      }
      
      override public function render() : void
      {
         if(mNeedsSort)
         {
            this.sortLayer();
            mNeedsSort = false;
         }
      }
   }
}

