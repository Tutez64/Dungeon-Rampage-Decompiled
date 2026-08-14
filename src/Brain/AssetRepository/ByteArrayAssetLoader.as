package Brain.AssetRepository
{
   import Brain.Facade.Facade;
   import Brain.Utils.MemoryTracker;
   import flash.utils.ByteArray;
   
   public class ByteArrayAssetLoader extends AssetLoader
   {
      
      protected var mByteArrayAsset:ByteArrayAsset;
      
      public function ByteArrayAssetLoader(facade:Facade, assetLoaderInfo:AssetLoaderInfo, loadedCallback:Function, errorCallback:Function = null)
      {
         super(facade,assetLoaderInfo,loadedCallback,errorCallback,false,"binary");
      }
      
      override protected function buildAsset(loadedObject:Object) : Asset
      {
         mByteArrayAsset = new ByteArrayAsset(loadedObject as ByteArray);
         MemoryTracker.track(mByteArrayAsset,"ByteArrayAsset - created in ByteArrayAssetLoader.buildAsset()","brain");
         return mByteArrayAsset;
      }
   }
}

