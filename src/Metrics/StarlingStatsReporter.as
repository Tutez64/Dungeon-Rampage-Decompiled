package Metrics
{
   import Brain.Event.EventListeners;
   import Brain.Logger.Logger;
   import flash.events.Event;
   import flash.filesystem.File;
   import flash.filesystem.FileStream;
   import flash.system.System;
   import flash.utils.getTimer;
   import starling.core.Starling;
   import starling.events.Event;
   
   public class StarlingStatsReporter
   {
      
      private static const B_TO_MB:Number = 9.5367431640625e-7;
      
      private static const FPS_WINDOW_MS:int = 1000;
      
      private static const WRITE_INTERVAL_MS:int = 5000;
      
      private var mStarling:Starling;
      
      private var mRunning:Boolean = false;
      
      private var mStartDate:Date;
      
      private var mStartTime:Number;
      
      private var mLastWriteTime:Number;
      
      private var mFrameCount:int;
      
      private var mWindowFrames:int;
      
      private var mWindowStartTime:Number;
      
      private var mPeakFps:Number;
      
      private var mDrawCallSum:Number;
      
      private var mPeakDrawCalls:int;
      
      private var mMemorySum:Number;
      
      private var mPeakMemory:Number;
      
      private var mGpuMemorySum:Number;
      
      private var mPeakGpuMemory:Number;
      
      private var mSampleCount:int;
      
      public function StarlingStatsReporter(starling:Starling)
      {
         super();
         mStarling = starling;
      }
      
      private static function pad(value:String, width:int = 15) : String
      {
         var _loc3_:String = value;
         while(_loc3_.length < width)
         {
            _loc3_ += " ";
         }
         return _loc3_;
      }
      
      public function get isRunning() : Boolean
      {
         return mRunning;
      }
      
      public function toggle() : void
      {
         if(mRunning)
         {
            stop();
         }
         else
         {
            start();
         }
      }
      
      public function start() : void
      {
         if(mRunning)
         {
            return;
         }
         mRunning = true;
         mStartDate = new Date();
         mStartTime = getTimer();
         mWindowStartTime = mStartTime;
         mLastWriteTime = mStartTime;
         mFrameCount = 0;
         mWindowFrames = 0;
         mPeakFps = 1.7976931348623157e+308;
         mDrawCallSum = 0;
         mPeakDrawCalls = 0;
         mMemorySum = 0;
         mPeakMemory = 0;
         mGpuMemorySum = 0;
         mPeakGpuMemory = 0;
         mSampleCount = 0;
         mStarling.addEventListener("renderComplete",onRenderComplete);
         EventListeners.add(mStarling.nativeStage,"enterFrame",onNativeFrame);
         Logger.log("StarlingStatsReporter: watching Starling stats. Report: " + resolveReportFile().nativePath);
      }
      
      public function stop() : void
      {
         if(!mRunning)
         {
            return;
         }
         mRunning = false;
         mStarling.removeEventListener("renderComplete",onRenderComplete);
         EventListeners.remove(mStarling.nativeStage,"enterFrame",onNativeFrame);
         writeReport();
         Logger.log("StarlingStatsReporter: stopped. Report written to " + resolveReportFile().nativePath);
      }
      
      private function onRenderComplete(event:starling.events.Event) : void
      {
         var _loc4_:int = mStarling.painter.drawCount;
         mDrawCallSum += _loc4_;
         if(_loc4_ > mPeakDrawCalls)
         {
            mPeakDrawCalls = _loc4_;
         }
         var _loc3_:Number = System.totalMemory * 9.5367431640625e-7;
         mMemorySum += _loc3_;
         if(_loc3_ > mPeakMemory)
         {
            mPeakMemory = _loc3_;
         }
         var _loc2_:Number = supportsGpuMem ? mStarling.context["totalGPUMemory"] * 9.5367431640625e-7 : -1;
         if(_loc2_ >= 0)
         {
            mGpuMemorySum += _loc2_;
            if(_loc2_ > mPeakGpuMemory)
            {
               mPeakGpuMemory = _loc2_;
            }
         }
         mSampleCount = mSampleCount + 1;
      }
      
      private function onNativeFrame(event:flash.events.Event) : void
      {
         countFrame();
      }
      
      private function countFrame() : void
      {
         var _loc2_:Number = NaN;
         mFrameCount = mFrameCount + 1;
         mWindowFrames = mWindowFrames + 1;
         var _loc1_:Number = getTimer();
         var _loc3_:Number = _loc1_ - mWindowStartTime;
         if(_loc3_ >= 1000)
         {
            _loc2_ = mWindowFrames * 1000 / _loc3_;
            if(_loc2_ < mPeakFps && _loc2_ > 0)
            {
               mPeakFps = _loc2_;
            }
            mWindowFrames = 0;
            mWindowStartTime = _loc1_;
         }
         if(_loc1_ - mLastWriteTime >= 5000)
         {
            mLastWriteTime = _loc1_;
            writeReport();
         }
      }
      
      private function writeReport() : void
      {
         var _loc6_:Number = (getTimer() - mStartTime) / 1000;
         var _loc1_:Number = _loc6_ > 0 ? mFrameCount / _loc6_ : 0;
         var _loc4_:Number = mSampleCount > 0 ? mDrawCallSum / mSampleCount : 0;
         var _loc2_:Number = mSampleCount > 0 ? mMemorySum / mSampleCount : 0;
         var _loc7_:Number = mSampleCount > 0 ? mGpuMemorySum / mSampleCount : 0;
         var _loc5_:Array = ["Starling Performance Report","Started:  " + mStartDate.toString(),"Duration: " + _loc6_.toFixed(1) + " s (" + mFrameCount + " frames, " + mSampleCount + " rendered)","Status:   " + (mRunning ? "running (refreshed every 5 s)" : "stopped"),"","                 average        peak","frames/sec:      " + pad(_loc1_.toFixed(1)) + pad(mPeakFps == 1.7976931348623157e+308 ? "n/a" : mPeakFps.toFixed(1)) + "(\"peak\" is lowest)","std memory (MB): " + pad(_loc2_.toFixed(1)) + pad(mPeakMemory.toFixed(1)),"gpu memory (MB): " + (supportsGpuMem ? pad(_loc7_.toFixed(1)) + pad(mPeakGpuMemory.toFixed(1)) : "n/a (runtime does not support totalGPUMemory)"),"draw calls:      " + pad(_loc4_.toFixed(1)) + pad(String(mPeakDrawCalls))];
         var _loc3_:FileStream = new FileStream();
         try
         {
            _loc3_.open(resolveReportFile(),"write");
            _loc3_.writeUTFBytes(_loc5_.join("\n") + "\n");
         }
         catch(e:Error)
         {
            Logger.error("StarlingStatsReporter: failed to write report: " + e.message);
         }
         finally
         {
            _loc3_.close();
         }
      }
      
      private function resolveReportFile() : File
      {
         return File.applicationStorageDirectory.resolvePath("StarlingReport.txt");
      }
      
      private function get supportsGpuMem() : Boolean
      {
         return mStarling.context != null && "totalGPUMemory" in mStarling.context;
      }
   }
}

