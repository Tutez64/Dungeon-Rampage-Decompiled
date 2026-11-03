package Settings.Model.Bindings
{
   import Settings.Model.DisplayTimingSettings;
   
   public class DisplayTimingBinding implements ISettingBinding
   {
      
      private var mTiming:DisplayTimingSettings;
      
      private var mIsFrameRate:Boolean;
      
      public function DisplayTimingBinding(timing:DisplayTimingSettings, isFrameRate:Boolean)
      {
         super();
         mTiming = timing;
         mIsFrameRate = isFrameRate;
      }
      
      public function read() : *
      {
         if(mIsFrameRate)
         {
            return mTiming.frameRate;
         }
         return mTiming.vsync;
      }
      
      public function write(value:*) : void
      {
         if(mIsFrameRate)
         {
            mTiming.frameRate = value;
         }
         else
         {
            mTiming.vsync = value;
         }
      }
      
      public function writeInitial(value:*) : void
      {
         write(value);
      }
      
      public function destroy() : void
      {
         mTiming = null;
      }
   }
}

