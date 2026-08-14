package Brain.Render
{
   import Brain.Clock.GameClock;
   import Brain.Facade.Facade;
   import Brain.Logger.Logger;
   import flash.display.MovieClip;
   import org.as3commons.collections.Map;
   
   public class MovieClipRandomRenderer extends MovieClipRenderer
   {
      
      private static const RANDOM_SUBSTRING_LABEL:String = "random";
      
      protected var mRandomLabels:Map = new Map();
      
      protected var mCurrentRandomLabel:RandomLabelObject;
      
      public function MovieClipRandomRenderer(facade:Facade, clip:MovieClip, finishedCallback:Function = null, assetLabel:String = null)
      {
         super(facade,clip,finishedCallback,assetLabel);
      }
      
      override public function destroy() : void
      {
         mRandomLabels.clear();
         mCurrentRandomLabel = null;
         super.destroy();
      }
      
      override public function onFrame(gameClock:GameClock) : void
      {
         if(!mClip)
         {
            return;
         }
         mIsPlaying = true;
         if(mClip.stage == null)
         {
            Logger.warn("Animating MovieClipRenderer that is not on stage");
         }
         if(!mIsPlaying)
         {
            return;
         }
         mPlayHead += mFrameRate * gameClock.tickLength * mPlayRate;
         if(mPlayHead >= mCurrentRandomLabel.endFrameNumber)
         {
            playNewRandomLabel();
         }
         this.updateClip(mClip);
      }
      
      protected function playNewRandomLabel() : void
      {
         var _loc2_:Array = mRandomLabels.keysToArray();
         var _loc1_:Number = Math.floor(Math.random() * _loc2_.length);
         mCurrentRandomLabel = mRandomLabels.itemFor(_loc2_[_loc1_]);
         mPlayHead = mCurrentRandomLabel.startFrameNumber;
      }
      
      override protected function determineFrames(clip:MovieClip) : void
      {
         var _loc2_:RandomLabelObject = null;
         var _loc3_:* = 0;
         if(clip.currentLabels.length > 0)
         {
            _loc3_ = 1;
            while(_loc3_ <= clip.totalFrames)
            {
               clip.gotoAndStop(_loc3_);
               if(clip.currentFrameLabel && clip.currentFrameLabel.indexOf("random") >= 0)
               {
                  if(_loc2_ && _loc2_.endFrameNumber == 0)
                  {
                     _loc2_.endFrameNumber = _loc3_ - 1;
                  }
                  _loc2_ = new RandomLabelObject();
                  _loc2_.startFrameNumber = _loc3_;
                  _loc2_.labelName = clip.currentFrameLabel;
                  mRandomLabels.add(clip.currentFrameLabel,_loc2_);
               }
               _loc3_++;
            }
            if(_loc2_ && _loc2_.endFrameNumber == 0)
            {
               _loc2_.endFrameNumber = _loc3_ - 1;
            }
         }
         playNewRandomLabel();
      }
   }
}

class RandomLabelObject
{
   
   public var labelName:String;
   
   public var startFrameNumber:uint;
   
   public var endFrameNumber:uint;
   
   public function RandomLabelObject()
   {
      super();
   }
}
