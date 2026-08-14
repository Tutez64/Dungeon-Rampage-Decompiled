package Brain.AssetRepository
{
   import Brain.Facade.Facade;
   
   public class JsonAssetLoader extends AssetLoader
   {
      
      public function JsonAssetLoader(facade:Facade, assetLoaderInfo:AssetLoaderInfo, loadedCallback:Function, errorCallback:Function)
      {
         super(facade,assetLoaderInfo,loadedCallback,errorCallback);
      }
      
      override protected function buildAsset(loadedObject:Object) : Asset
      {
         return new JsonAsset(loadedObject);
      }
   }
}

