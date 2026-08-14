package Brain.Render
{
   import Brain.AssetRepository.SpriteSheetAsset;
   import Brain.Clock.GameClock;
   import Brain.Utils.MemoryTracker;
   import Brain.WorkLoop.WorkComponent;
   import flash.display.BitmapData;
   import flash.geom.Point;
   
   public class SpriteSheetRenderer extends BitmapRenderer
   {
      
      protected var mSpriteSheet:SpriteSheetAsset;
      
      protected var mXIndex:uint = 0;
      
      protected var mYIndex:uint = 0;
      
      public function SpriteSheetRenderer(workComponent:WorkComponent, sheet:SpriteSheetAsset)
      {
         super(workComponent);
         mSpriteSheet = sheet;
         MemoryTracker.track(this,"SpriteSheetRenderer - created in SpriteSheetRenderer()","brain");
      }
      
      override public function destroy() : void
      {
         mSpriteSheet = null;
         super.destroy();
      }
      
      public function set spriteSheet(value:SpriteSheetAsset) : void
      {
         mSpriteSheet = value;
      }
      
      public function setFrameIndexes(x:uint, y:uint) : void
      {
         mXIndex = x;
         mYIndex = y;
      }
      
      protected function getCurrentFrame() : BitmapData
      {
         return mSpriteSheet.getFrame(mXIndex,mYIndex);
      }
      
      protected function getCurrentCenter() : Point
      {
         return mSpriteSheet.getCenter(mXIndex,mYIndex);
      }
      
      public function updateToCurrentFrame() : void
      {
         this.center = getCurrentCenter();
         this.bitmapData = getCurrentFrame();
      }
      
      override protected function onFrame(gameClock:GameClock) : void
      {
         super.onFrame(gameClock);
         this.updateToCurrentFrame();
      }
      
      public function play(startingFrame:uint = 0, loop:Boolean = true, finishedCallback:Function = null) : void
      {
         setFrame(startingFrame);
      }
      
      public function stop() : void
      {
      }
      
      public function get currentFrame() : uint
      {
         return mXIndex;
      }
      
      public function set heading(value:Number) : void
      {
      }
      
      public function get loop() : Boolean
      {
         return false;
      }
      
      public function setFrame(frameNumber:uint) : void
      {
         this.mXIndex = frameNumber;
      }
   }
}

