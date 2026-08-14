package Sound
{
   import Brain.Logger.Logger;
   import Brain.Sound.SoundHandle;
   import Brain.Sound.SoundManager;
   import DBGlobals.DBGlobal;
   import Facade.DBFacade;
   import org.as3commons.collections.Set;
   
   public class DBSoundManager extends SoundManager
   {
      
      public static const MUSIC_MIXER_CATEGORY:String = "music";
      
      public static const SFX_MIXER_CATEGORY:String = "sfx";
      
      protected var mCurrentMusic:SoundHandle;
      
      public function DBSoundManager(dbFacade:DBFacade)
      {
         super(dbFacade);
         setVolumeScaleForCategory("music",DBGlobal.MUSIC_VOLUME);
         setVolumeScaleForCategory("sfx",DBGlobal.SFX_VOLUME);
      }
      
      public function set musicVolumeScale(musicScale:Number) : void
      {
         this.setVolumeScaleForCategory("music",musicScale);
      }
      
      public function get musicVolumeScale() : Number
      {
         return getVolumeScaleForCategory("music");
      }
      
      public function set sfxVolumeScale(soundScale:Number) : void
      {
         this.setVolumeScaleForCategory("sfx",soundScale);
      }
      
      public function get sfxVolumeScale() : Number
      {
         return getVolumeScaleForCategory("sfx");
      }
      
      override public function registerSoundPlaying(soundHandle:SoundHandle) : void
      {
         if(soundHandle.category == "music")
         {
            registerMusicPlaying(soundHandle);
         }
         else
         {
            super.registerSoundPlaying(soundHandle);
         }
      }
      
      protected function registerMusicPlaying(musicSoundHandle:SoundHandle) : void
      {
         if(mCurrentMusic == null)
         {
            mCurrentMusic = musicSoundHandle;
            super.registerSoundPlaying(musicSoundHandle);
            return;
         }
         var _loc2_:Set = mSoundsDictionary.itemFor("music") as Set;
         if(!_loc2_.has(mCurrentMusic))
         {
            Logger.error("CurrentMusicHandle in DBSoundManager is not registered.");
            return;
         }
         mCurrentMusic.stop();
         mCurrentMusic = null;
         mCurrentMusic = musicSoundHandle;
         super.registerSoundPlaying(mCurrentMusic);
      }
      
      override public function unregisterSoundPlaying(soundHandle:SoundHandle) : void
      {
         if(soundHandle.category == "music")
         {
            unregisterMusicPlaying(soundHandle);
         }
         else
         {
            super.unregisterSoundPlaying(soundHandle);
         }
      }
      
      protected function unregisterMusicPlaying(soundHandle:SoundHandle) : void
      {
         if(mCurrentMusic == null)
         {
            Logger.error("Trying to unregister music playing but mCurrentMusic is null");
            return;
         }
         mCurrentMusic = null;
         super.unregisterSoundPlaying(soundHandle);
      }
   }
}

