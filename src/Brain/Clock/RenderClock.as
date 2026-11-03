package Brain.Clock
{
   public class RenderClock extends GameClock
   {
      
      private var mHasBaseline:Boolean = false;
      
      public function RenderClock()
      {
         super(0);
      }
      
      override public function update() : Number
      {
         if(!mHasBaseline)
         {
            initTime();
         }
         var _loc1_:Number = Math.max(0,super.update());
         mTickLength = _loc1_ / timeScale;
         return _loc1_;
      }
      
      override public function initTime() : void
      {
         super.initTime();
         mHasBaseline = true;
         mTickLength = 0;
      }
   }
}

