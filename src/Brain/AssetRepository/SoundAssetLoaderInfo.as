package Brain.AssetRepository
{
   public class SoundAssetLoaderInfo extends AssetLoaderInfo
   {
      
      protected var mSoundName:String;
      
      public function SoundAssetLoaderInfo(path:String, soundName:String, useCache:Boolean)
      {
         super(path,useCache);
         mSoundName = soundName;
      }
      
      override public function getKey() : String
      {
         return getRawAssetPath() + "_" + mSoundName;
      }
   }
}

