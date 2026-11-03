package Brain.AssetRepository
{
   import Brain.Facade.Facade;
   import flash.display.MovieClip;
   
   public class SwfAssetLoader extends AssetLoader
   {
      
      protected var mSwfAsset:SwfAsset;
      
      public function SwfAssetLoader(facade:Facade, assetLoaderInfo:AssetLoaderInfo, loadedCallback:Function, errorCallback:Function)
      {
         super(facade,assetLoaderInfo,loadedCallback,errorCallback,true);
      }
      
      override protected function buildAsset(loadedObject:Object) : Asset
      {
         var _loc2_:MovieClip = loadedObject as MovieClip;
         mSwfAsset = new SwfAsset(_loc2_,mAssetLoaderInfo.getRawAssetPath());
         return mSwfAsset;
      }
      
      override public function destroy() : void
      {
         mSwfAsset = null;
         super.destroy();
      }
   }
}

