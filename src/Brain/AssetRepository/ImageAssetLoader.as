package Brain.AssetRepository
{
   import Brain.Facade.Facade;
   import Brain.Utils.MemoryTracker;
   import flash.display.Bitmap;
   
   public class ImageAssetLoader extends AssetLoader
   {
      
      protected var mImageAsset:ImageAsset;
      
      public function ImageAssetLoader(facade:Facade, assetLoaderInfo:AssetLoaderInfo, loadedCallback:Function, errorCallback:Function = null)
      {
         super(facade,assetLoaderInfo,loadedCallback,errorCallback,true);
      }
      
      override protected function buildAsset(loadedObject:Object) : Asset
      {
         var _loc2_:Bitmap = loadedObject as Bitmap;
         mImageAsset = new ImageAsset(_loc2_);
         MemoryTracker.track(mImageAsset,"ImageAsset - created in ImageAssetLoader.buildAsset()","brain");
         return mImageAsset;
      }
   }
}

