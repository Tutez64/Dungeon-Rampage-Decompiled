package Settings.Model
{
   import Brain.Logger.Logger;
   import flash.desktop.NativeApplication;
   import flash.display.Screen;
   import flash.display.ScreenMode;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.VsyncStateChangeAvailabilityEvent;
   import flash.utils.getTimer;
   
   public class DisplayTimingSettings
   {
      
      private var mStage:Stage;
      
      private var mFrameRate:Number = 60;
      
      private var mVsync:Boolean = true;
      
      private var mVsyncAvailable:Boolean = false;
      
      private var mFrameRates:FrameRateOptions = new FrameRateOptions();
      
      private var mVsyncProbe:Function;
      
      public var changed:Function;
      
      public function DisplayTimingSettings(stage:Stage)
      {
         super();
         mStage = stage;
         mStage.addEventListener("vSyncStateChangeAvailability",onVsyncAvailability);
         NativeApplication.nativeApplication.addEventListener("exiting",onExit);
         var _loc2_:Object = new LocalSettingsFile().read();
         frameRate = _loc2_ != null && _loc2_.hasOwnProperty("fps") ? FrameRateOptions.coerce(_loc2_["fps"]) : 60;
         if(_loc2_ != null && _loc2_.hasOwnProperty("vsync"))
         {
            mVsync = _loc2_["vsync"] === true || String(_loc2_["vsync"]) == "true" || String(_loc2_["vsync"]) == "1";
         }
      }
      
      public function get frameRates() : FrameRateOptions
      {
         return mFrameRates;
      }
      
      public function get frameRate() : Number
      {
         return mFrameRate;
      }
      
      public function set frameRate(value:Number) : void
      {
         mFrameRate = FrameRateOptions.coerce(value);
         mStage.frameRate = mFrameRate;
         if(mFrameRates.remember(mFrameRate))
         {
            notify("fps");
         }
      }
      
      public function get vsync() : Boolean
      {
         return mVsync;
      }
      
      public function set vsync(value:Boolean) : void
      {
         mVsync = value;
         applyVsync();
      }
      
      public function vsyncDescriptionKey() : String
      {
         return mVsyncAvailable ? "SETTING_VSYNC_DESC" : "SETTING_VSYNC_UNAVAILABLE_DESC";
      }
      
      private function onVsyncAvailability(event:VsyncStateChangeAvailabilityEvent) : void
      {
         mVsyncAvailable = event.available;
         applyVsync();
         notify("vsync");
      }
      
      private function applyVsync() : void
      {
         if(!mVsyncAvailable)
         {
            return;
         }
         try
         {
            if(mStage.vsyncEnabled != mVsync)
            {
               mStage.vsyncEnabled = mVsync;
            }
         }
         catch(error:Error)
         {
            mVsyncAvailable = false;
            Logger.warn("Could not apply VSync preference: " + error.message);
            notify("vsync");
         }
      }
      
      public function refreshMonitors() : void
      {
         var _loc1_:ScreenMode = null;
         var _loc2_:Boolean = false;
         try
         {
            for each(var _loc3_:Screen in Screen.screens)
            {
               try
               {
                  _loc1_ = _loc3_.mode;
                  if(_loc1_ != null && mFrameRates.rememberMonitor(_loc1_.refreshRate))
                  {
                     _loc2_ = true;
                  }
               }
               catch(screenError:Error)
               {
               }
            }
         }
         catch(error:Error)
         {
         }
         if(_loc2_)
         {
            notify("fps");
         }
         measureVsyncRate();
      }
      
      private function measureVsyncRate() : void
      {
         var WARMUP:int;
         var FRAMES:int;
         var ATTEMPTS:int;
         var attempt:int;
         var times:Vector.<int>;
         if(!mVsyncAvailable || mVsyncProbe != null)
         {
            return;
         }
         try
         {
            mStage.vsyncEnabled = true;
         }
         catch(error:Error)
         {
            return;
         }
         attempt = 1;
         times = new Vector.<int>();
         mVsyncProbe = function(param1:Event):void
         {
            var _loc8_:int = 0;
            times.push(getTimer());
            if(times.length < 5 + 30 + 1)
            {
               return;
            }
            var _loc5_:Boolean = mVsyncAvailable && Boolean(mStage.vsyncEnabled) && mStage.frameRate == 1000;
            if(!_loc5_)
            {
               stopVsyncProbe();
               return;
            }
            var _loc3_:Array = [];
            _loc8_ = 6;
            while(_loc8_ < times.length)
            {
               _loc3_.push(times[_loc8_] - times[_loc8_ - 1]);
               _loc8_++;
            }
            _loc3_.sort(16);
            var _loc6_:Number = Number(_loc3_[_loc3_.length >> 1]);
            var _loc9_:Number = 0;
            var _loc7_:int = 0;
            for each(var _loc10_:int in _loc3_)
            {
               if(Math.abs(_loc10_ - _loc6_) <= 2)
               {
                  _loc9_ += _loc10_;
                  _loc7_++;
               }
            }
            if(_loc6_ <= 0 || _loc7_ < _loc3_.length * 2 / 3)
            {
               if(attempt++ < 3)
               {
                  times.length = 0;
               }
               else
               {
                  stopVsyncProbe();
               }
               return;
            }
            stopVsyncProbe();
            var _loc2_:Number = 1000 * _loc7_ / _loc9_;
            var _loc11_:Number = NaN;
            for each(var _loc4_:Number in [48,50,60,72,75,90,100,120,144,165,180,200,240,360])
            {
               if(isNaN(_loc11_) || Math.abs(_loc2_ - _loc4_) < Math.abs(_loc2_ - _loc11_))
               {
                  _loc11_ = _loc4_;
               }
            }
            if(Math.abs(_loc2_ - _loc11_) > _loc11_ * 0.015)
            {
               return;
            }
            if(mFrameRates.rememberMonitor(_loc11_))
            {
               notify("fps");
            }
         };
         mStage.frameRate = 1000;
         mStage.addEventListener("enterFrame",mVsyncProbe);
      }
      
      private function stopVsyncProbe() : void
      {
         if(mVsyncProbe == null)
         {
            return;
         }
         mStage.removeEventListener("enterFrame",mVsyncProbe);
         mVsyncProbe = null;
         mStage.frameRate = mFrameRate;
         try
         {
            if(mStage.vsyncEnabled != mVsync)
            {
               mStage.vsyncEnabled = mVsync;
            }
         }
         catch(error:Error)
         {
         }
      }
      
      private function notify(id:String) : void
      {
         if(changed != null)
         {
            changed(id);
         }
      }
      
      private function onExit(event:Event) : void
      {
         destroy();
      }
      
      public function destroy() : void
      {
         if(mStage == null)
         {
            return;
         }
         changed = null;
         stopVsyncProbe();
         mStage.removeEventListener("vSyncStateChangeAvailability",onVsyncAvailability);
         NativeApplication.nativeApplication.removeEventListener("exiting",onExit);
         mStage = null;
      }
   }
}

