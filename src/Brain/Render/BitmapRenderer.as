package Brain.Render
{
   import Brain.Clock.GameClock;
   import Brain.Utils.MemoryTracker;
   import Brain.WorkLoop.Task;
   import Brain.WorkLoop.WorkComponent;
   import flash.display.Bitmap;
   import flash.display.BitmapData;
   import flash.display.DisplayObject;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class BitmapRenderer
   {
      
      protected var mWorkComponent:WorkComponent;
      
      protected var mOnFrameTask:Task;
      
      protected var mBitmap:Bitmap = new Bitmap();
      
      protected var mSmoothing:Boolean = true;
      
      protected var mCenter:Point = new Point(0.5,0.5);
      
      public function BitmapRenderer(workComponent:WorkComponent)
      {
         super();
         mBitmap.smoothing = mSmoothing;
         mBitmap.pixelSnapping = "auto";
         mWorkComponent = workComponent;
         mBitmap.addEventListener("addedToStage",onAdd);
         mBitmap.addEventListener("removedFromStage",onRemove);
         MemoryTracker.track(this,"BitmapRenderer - created in BitmapRenderer()","brain");
      }
      
      public function destroy() : void
      {
         mBitmap.removeEventListener("addedToStage",onAdd);
         mBitmap.removeEventListener("removedFromStage",onRemove);
         onRemove();
         mWorkComponent.destroy();
         mWorkComponent = null;
         mBitmap = null;
      }
      
      protected function onAdd(event:Event = null) : void
      {
         if(mOnFrameTask != null)
         {
            mOnFrameTask.destroy();
         }
         mOnFrameTask = mWorkComponent.doEveryFrame(onFrame);
      }
      
      protected function onRemove(event:Event = null) : void
      {
         if(mOnFrameTask != null)
         {
            mOnFrameTask.destroy();
            mOnFrameTask = null;
         }
      }
      
      public function set center(value:Point) : void
      {
         mCenter = value;
         mBitmap.x = -mCenter.x;
         mBitmap.y = -mCenter.y;
      }
      
      public function get center() : Point
      {
         return mCenter;
      }
      
      public function set smoothing(value:Boolean) : void
      {
         mSmoothing = value;
         mBitmap.smoothing = mSmoothing;
      }
      
      public function get smoothing() : Boolean
      {
         return mSmoothing;
      }
      
      public function get displayObject() : DisplayObject
      {
         return mBitmap;
      }
      
      public function set bitmapData(value:BitmapData) : void
      {
         if(value == mBitmap.bitmapData)
         {
            return;
         }
         mBitmap.bitmapData = value;
         mBitmap.smoothing = mSmoothing;
         mBitmap.x = -mCenter.x;
         mBitmap.y = -mCenter.y;
      }
      
      protected function onFrame(gameClock:GameClock) : void
      {
      }
      
      public function get bitmapData() : BitmapData
      {
         return mBitmap.bitmapData;
      }
   }
}

