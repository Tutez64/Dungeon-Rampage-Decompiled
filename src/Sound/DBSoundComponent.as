package Sound
{
   import Brain.Sound.SoundAsset;
   import Brain.Sound.SoundComponent;
   import Brain.Sound.SoundHandle;
   import Facade.DBFacade;
   import flash.geom.Vector3D;
   import flash.media.Sound;
   
   public class DBSoundComponent extends SoundComponent
   {
      
      private var MIN_DISTANCE_FOR_SOUND:Number = 690;
      
      protected var mDBFacade:DBFacade;
      
      protected var mDBSoundManager:DBSoundManager;
      
      public function DBSoundComponent(dbFacade:DBFacade)
      {
         super(dbFacade);
         mDBFacade = dbFacade;
         mDBSoundManager = mDBFacade.soundManager as DBSoundManager;
         MIN_DISTANCE_FOR_SOUND = mDBFacade.dbConfigManager.getConfigNumber("min_sound_distance",690);
      }
      
      override public function destroy() : void
      {
         super.destroy();
         mDBFacade = null;
         mDBSoundManager = null;
      }
      
      public function playSfxOneShot(sfxSoundAsset:SoundAsset, soundPosition:Vector3D = null, loopCount:int = 0, volume:Number = 1, panning:Number = 0, startPosition:Number = 0) : void
      {
         var _loc7_:Vector3D = new Vector3D();
         _loc7_.x = -mDBFacade.camera.rootPosition.x;
         _loc7_.y = -mDBFacade.camera.rootPosition.y;
         if(soundPosition != null && Vector3D.distance(soundPosition,_loc7_) > MIN_DISTANCE_FOR_SOUND)
         {
            return;
         }
         this.playOneShot(sfxSoundAsset,"sfx",loopCount,volume,panning,startPosition);
      }
      
      public function playSfxManaged(sfxSoundAsset:SoundAsset, volume:Number = 1, panning:Number = 0) : SoundHandle
      {
         return this.playManagedSound(sfxSoundAsset,"sfx",volume,panning);
      }
      
      public function playMusic(musicSoundAsset:SoundAsset, volume:Number = 1, panning:Number = 0, startTime:Number = 0) : SoundHandle
      {
         return playStreamingMusic(musicSoundAsset.sound,volume,panning,startTime);
      }
      
      public function playStreamingMusic(sound:Sound, volume:Number = 1, panning:Number = 0, startTime:Number = 0) : SoundHandle
      {
         var _loc5_:SoundHandle = new SoundHandle(mDBSoundManager,mDBFacade,sound,"music",unregisterSoundHandle,true,volume,panning);
         mSoundHandles.add(_loc5_);
         _loc5_.play(2147483647);
         return _loc5_;
      }
   }
}

