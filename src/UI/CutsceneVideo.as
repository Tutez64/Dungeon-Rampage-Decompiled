package UI
{
   import Brain.Event.EventListeners;
   import Brain.Logger.Logger;
   import flash.display.MovieClip;
   import flash.display.Stage;
   import flash.events.AsyncErrorEvent;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.NetStatusEvent;
   import flash.media.SoundTransform;
   import flash.media.Video;
   import flash.net.NetConnection;
   import flash.net.NetStream;
   import flash.utils.getTimer;
   
   public class CutsceneVideo
   {
      
      private static const START_TIMEOUT_MS:int = 5000;
      
      private var mStage:Stage;
      
      private var mStageFrameRate:Number;
      
      private var mClip:MovieClip;
      
      private var mClipFrameRate:Number;
      
      private var mClipStarted:Boolean = false;
      
      private var mVideo:Video;
      
      private var mNetConnection:NetConnection;
      
      private var mNetStream:NetStream;
      
      private var mUrl:String;
      
      private var mRequestedAt:int;
      
      public function CutsceneVideo(stage:Stage, clip:MovieClip, clipFrameRate:Number, url:String, volume:SoundTransform)
      {
         super();
         mStage = stage;
         mStageFrameRate = stage.frameRate;
         stage.frameRate = clipFrameRate;
         mClip = clip;
         mClipFrameRate = clipFrameRate;
         mClip.gotoAndStop(1);
         mUrl = url;
         mVideo = new Video(1920,1080);
         mVideo.smoothing = true;
         mNetConnection = new NetConnection();
         mNetConnection.connect(null);
         mNetStream = new NetStream(mNetConnection);
         mNetStream.soundTransform = volume;
         mNetStream.client = {"onMetaData":function(param1:Object):void
         {
         }};
         EventListeners.add(mNetStream,"netStatus",onNetStatus);
         EventListeners.add(mNetStream,"asyncError",onAsyncError);
         EventListeners.add(mNetStream,"ioError",onIOError);
         EventListeners.add(mClip,"enterFrame",onClipFrame);
         mVideo.attachNetStream(mNetStream);
         mRequestedAt = getTimer();
         mNetStream.play(url);
      }
      
      public function get display() : Video
      {
         return mVideo;
      }
      
      private function onClipFrame(event:Event) : void
      {
         if(mNetStream.time > 0)
         {
            startClip(int(mNetStream.time * mClipFrameRate) + 1);
         }
         else if(getTimer() - mRequestedAt > 5000)
         {
            Logger.warn("CutsceneVideo: " + mUrl + " did not start within " + 5000 + " ms; playing the clip alone");
            dropVideo();
         }
      }
      
      private function onNetStatus(event:NetStatusEvent) : void
      {
         var _loc2_:String = event.info.code;
         if(event.info.level == "error" || _loc2_ == "NetStream.Play.Failed" || _loc2_ == "NetStream.Play.Stop" && !mClipStarted)
         {
            Logger.warn("CutsceneVideo: " + mUrl + " failed with " + _loc2_ + "; playing the clip alone");
            dropVideo();
         }
      }
      
      private function onIOError(event:IOErrorEvent) : void
      {
         Logger.warn("CutsceneVideo: " + mUrl + " IO error " + event.text + "; playing the clip alone");
         dropVideo();
      }
      
      private function onAsyncError(event:AsyncErrorEvent) : void
      {
         Logger.debug("CutsceneVideo: " + mUrl + " async error " + event.text);
      }
      
      private function startClip(frame:int) : void
      {
         if(mClip == null || mClipStarted)
         {
            return;
         }
         mClipStarted = true;
         EventListeners.remove(mClip,"enterFrame",onClipFrame);
         mClip.gotoAndPlay(Math.min(frame,mClip.totalFrames));
      }
      
      private function dropVideo() : void
      {
         if(mNetStream == null)
         {
            return;
         }
         closeStream();
         mVideo.clear();
         mVideo.visible = false;
         startClip(1);
      }
      
      private function closeStream() : void
      {
         EventListeners.remove(mNetStream,"netStatus",onNetStatus);
         EventListeners.remove(mNetStream,"asyncError",onAsyncError);
         EventListeners.remove(mNetStream,"ioError",onIOError);
         mVideo.attachNetStream(null);
         mNetStream.close();
         mNetStream = null;
         mNetConnection.close();
         mNetConnection = null;
      }
      
      public function destroy() : void
      {
         if(mClip == null)
         {
            return;
         }
         if(!mClipStarted)
         {
            EventListeners.remove(mClip,"enterFrame",onClipFrame);
         }
         if(mNetStream != null)
         {
            closeStream();
         }
         mStage.frameRate = mStageFrameRate;
         mStage = null;
         mClip = null;
         mVideo = null;
      }
   }
}

