package Brain.Render
{
   import Brain.Utils.MemoryTracker;
   
   public class SortedLayer extends Layer
   {
      
      public function SortedLayer(sortIndex:int = 0)
      {
         super(sortIndex);
         MemoryTracker.track(this,"SortedLayer sortIndex=" + sortIndex + " - created in SortedLayer()","brain");
      }
      
      override public function render() : void
      {
         this.sortLayer();
      }
   }
}

