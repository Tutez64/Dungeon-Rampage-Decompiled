package Brain.Render
{
   import Brain.Facade.Facade;
   import Brain.Utils.IPoolable;
   import flash.display.FrameLabel;
   import flash.display.MovieClip;
   
   public class MovieClipRenderController implements IPoolable
   {
      
      protected var mClip:MovieClip;
      
      protected var mFacade:Facade;
      
      protected var mRenderer:MovieClipRenderer;
      
      protected var mStartScaleX:Number;
      
      protected var mStartScaleY:Number;
      
      public var swfPath:String = "";
      
      public var className:String = "";
      
      public function MovieClipRenderController(facade:Facade, clip:MovieClip, finishedCallback:Function = null, assetLabel:String = null)
      {
         super();
         mFacade = facade;
         mClip = clip;
         mStartScaleX = mClip.scaleX;
         mStartScaleY = mClip.scaleY;
         determineRenderer(finishedCallback,assetLabel);
      }
      
      public function postCheckout(isNewObject:Boolean) : void
      {
         if(!isNewObject)
         {
            mClip.scaleX = mStartScaleX;
            mClip.scaleY = mStartScaleY;
         }
      }
      
      public function postCheckin() : void
      {
         this.stop();
         if(mClip.parent)
         {
            mClip.parent.removeChild(mClip);
         }
      }
      
      public function getPoolKey() : String
      {
         return swfPath + ":" + className;
      }
      
      private function determineRenderer(finishedCallback:Function, assetLabel:String = null) : void
      {
         for each(var _loc3_:FrameLabel in mClip.currentLabels)
         {
            if(_loc3_.name.indexOf("random") >= 0)
            {
               mRenderer = new MovieClipRandomRenderer(mFacade,mClip,finishedCallback,assetLabel);
               return;
            }
            if(_loc3_.name == "pause")
            {
               mRenderer = new MovieClipCutsceneRenderer(mFacade,mClip,finishedCallback,assetLabel);
               return;
            }
         }
         mRenderer = new MovieClipRenderer(mFacade,mClip,finishedCallback,assetLabel);
      }
      
      public function destroy() : void
      {
         if(mRenderer)
         {
            mRenderer.destroy();
         }
         mRenderer = null;
         mFacade = null;
         mClip = null;
      }
      
      public function stop() : void
      {
         mRenderer.stop();
      }
      
      public function play(startingFrame:uint = 0, loop:Boolean = false, finishedCallback:Function = null) : void
      {
         mRenderer.play(startingFrame,loop,finishedCallback);
      }
      
      public function set finishedCallback(value:Function) : void
      {
         mRenderer.finishedCallback = value;
      }
      
      public function setFrame(frameNumber:uint) : void
      {
         mRenderer.setFrame(frameNumber);
      }
      
      public function get currentFrame() : uint
      {
         return mRenderer.currentFrame;
      }
      
      public function get clip() : MovieClip
      {
         return mRenderer.clip;
      }
      
      public function get durationInSeconds() : Number
      {
         return mRenderer.duration;
      }
      
      public function get frameCount() : Number
      {
         return mRenderer.numFrames;
      }
      
      public function get isPlaying() : Boolean
      {
         return mRenderer.isPlaying;
      }
      
      public function set frameRate(value:Number) : void
      {
         mRenderer.frameRate = value;
      }
      
      public function set startFrame(value:uint) : void
      {
         mRenderer.startFrame = value;
      }
      
      public function get loop() : Boolean
      {
         return mRenderer.loop;
      }
      
      public function set loop(value:Boolean) : void
      {
         mRenderer.loop = value;
      }
      
      public function get playRate() : Number
      {
         return mRenderer.playRate;
      }
      
      public function set playRate(value:Number) : void
      {
         mRenderer.playRate = value;
      }
   }
}

