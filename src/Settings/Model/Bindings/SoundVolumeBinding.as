package Settings.Model.Bindings
{
   import Facade.DBFacade;
   import Sound.DBSoundManager;
   
   public class SoundVolumeBinding implements ISettingBinding
   {
      
      public static const MUSIC:String = "music";
      
      public static const SFX:String = "sfx";
      
      private var mSoundManager:DBSoundManager;
      
      private var mChannel:String;
      
      public function SoundVolumeBinding(dbFacade:DBFacade, channel:String)
      {
         super();
         mSoundManager = dbFacade.soundManager as DBSoundManager;
         mChannel = channel;
      }
      
      public function read() : *
      {
         if(mSoundManager == null)
         {
            return 0;
         }
         return mChannel == "music" ? mSoundManager.musicVolumeScale : mSoundManager.sfxVolumeScale;
      }
      
      public function write(value:*) : void
      {
         if(mSoundManager == null)
         {
            return;
         }
         if(mChannel == "music")
         {
            mSoundManager.musicVolumeScale = value;
         }
         else
         {
            mSoundManager.sfxVolumeScale = value;
         }
      }
      
      public function writeInitial(value:*) : void
      {
         write(value);
      }
      
      public function destroy() : void
      {
         mSoundManager = null;
      }
   }
}

