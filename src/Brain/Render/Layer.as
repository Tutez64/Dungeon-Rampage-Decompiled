package Brain.Render
{
   import Brain.Utils.MemoryTracker;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import org.as3commons.collections.utils.ArrayUtils;
   
   public class Layer extends Sprite
   {
      
      private var mComparator:ChildComparator;
      
      private var mSortIndex:int;
      
      public function Layer(sortIndex:int = 0)
      {
         super();
         mComparator = new ChildComparator();
         this.mouseEnabled = false;
         mSortIndex = sortIndex;
         MemoryTracker.track(this,"Layer sortIndex=" + sortIndex + " - created in Layer()","brain");
      }
      
      public function get sortIndex() : int
      {
         return mSortIndex;
      }
      
      private function fixChildIndex(child:DisplayObject, i:int, children:Array) : void
      {
         if(this.getChildAt(i) != child)
         {
            this.setChildIndex(child,i);
         }
      }
      
      public function sortLayer() : void
      {
         var _loc2_:* = 0;
         if(this.numChildren == 0)
         {
            return;
         }
         var _loc1_:Array = new Array(this.numChildren);
         _loc2_ = 0;
         while(_loc2_ < this.numChildren)
         {
            _loc1_[_loc2_] = getChildAt(_loc2_);
            _loc2_++;
         }
         ArrayUtils.insertionSort(_loc1_,mComparator);
         _loc1_.map(fixChildIndex,this);
      }
      
      public function render() : void
      {
      }
      
      public function destroy() : void
      {
         mComparator = null;
         if(this.parent)
         {
            this.parent.removeChild(this);
         }
      }
   }
}

import org.as3commons.collections.framework.IComparator;

class ChildComparator implements IComparator
{
   
   public function ChildComparator()
   {
      super();
   }
   
   public function compare(a:*, b:*) : int
   {
      if(a.y == b.y)
      {
         if(a.x == b.x)
         {
            if(a.height == b.height)
            {
               return 0;
            }
            return a.height > b.height ? -1 : 1;
         }
         return b.x < a.x ? -1 : 1;
      }
      return a.y < b.y ? -1 : 1;
   }
}
