package Brain.Sound
{
   import Brain.AssetRepository.Asset;
   import flash.media.Sound;
   
   public class SoundAsset extends Asset
   {
      
      protected var mSound:Sound;
      
      public function SoundAsset(sound:Sound)
      {
         super();
         mSound = sound;
      }
      
      public function get sound() : Sound
      {
         return mSound;
      }
      
      override public function destroy() : void
      {
         mSound = null;
         super.destroy();
      }
   }
}

