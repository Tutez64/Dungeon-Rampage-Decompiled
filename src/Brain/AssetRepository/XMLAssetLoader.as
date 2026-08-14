package Brain.AssetRepository
{
   import Brain.Facade.Facade;
   import Brain.Utils.MemoryTracker;
   
   public class XMLAssetLoader extends AssetLoader
   {
      
      protected var mXMLAsset:XMLAsset;
      
      public function XMLAssetLoader(facade:Facade, assetLoaderInfo:AssetLoaderInfo, loadedCallback:Function, errorCallback:Function = null)
      {
         super(facade,assetLoaderInfo,loadedCallback,errorCallback);
      }
      
      override protected function buildAsset(loadedObject:Object) : Asset
      {
         mXMLAsset = new XMLAsset(new XML(loadedObject));
         MemoryTracker.track(mXMLAsset,"XMLAsset - created in XMLAssetLoader.buildAsset()","brain");
         return mXMLAsset;
      }
   }
}

