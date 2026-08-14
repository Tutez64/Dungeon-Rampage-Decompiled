package Brain.AssetRepository
{
   import Brain.Facade.Facade;
   import Brain.Logger.Logger;
   import flash.display.MovieClip;
   import flash.filesystem.File;
   
   public class SwfAssetLoader extends AssetLoader
   {
      
      protected var mSwfAsset:SwfAsset;
      
      private var mOriginalLoadedCallback:Function;
      
      private var mHdAssetLoader:AssetLoader;
      
      private var mIsHdLoader:Boolean;
      
      public function SwfAssetLoader(facade:Facade, assetLoaderInfo:AssetLoaderInfo, loadedCallback:Function, errorCallback:Function, isHdLoader:Boolean = false)
      {
         mIsHdLoader = isHdLoader;
         if(!mIsHdLoader)
         {
            mOriginalLoadedCallback = loadedCallback;
         }
         var _loc6_:Function = loadedCallback;
         if(!mIsHdLoader && facade.featureFlags.getFlagValue("use-hd-assets"))
         {
            _loc6_ = hdAwareLoadedCallback;
         }
         super(facade,assetLoaderInfo,_loc6_,errorCallback,true);
      }
      
      override protected function buildAsset(loadedObject:Object) : Asset
      {
         var _loc2_:MovieClip = loadedObject as MovieClip;
         mSwfAsset = new SwfAsset(_loc2_,mAssetLoaderInfo.getRawAssetPath());
         return mSwfAsset;
      }
      
      private function hdAwareLoadedCallback(assetLoaderInfo:AssetLoaderInfo, asset:Asset) : void
      {
         var _loc3_:AssetLoaderInfo = null;
         mSwfAsset = asset as SwfAsset;
         var _loc4_:String = assetLoaderInfo.getRawAssetPath();
         var _loc5_:String = getHdPath(_loc4_);
         if(_loc5_ != null && hdFileExists(_loc5_))
         {
            Logger.info("SwfAssetLoader: HD file exists, loading: " + _loc5_);
            _loc3_ = new AssetLoaderInfo(_loc5_,assetLoaderInfo.useCache);
            mHdAssetLoader = new SwfAssetLoader(mFacade,_loc3_,hdLoadedCallback,hdErrorCallback,true);
         }
         else
         {
            mOriginalLoadedCallback(assetLoaderInfo,asset);
         }
      }
      
      private function hdLoadedCallback(hdAssetLoaderInfo:AssetLoaderInfo, hdAsset:Asset) : void
      {
         var _loc3_:SwfAsset = hdAsset as SwfAsset;
         mSwfAsset.setHdAsset(_loc3_.root,hdAssetLoaderInfo.getRawAssetPath());
         Logger.info("SwfAssetLoader: HD version loaded successfully: " + hdAssetLoaderInfo.getRawAssetPath());
         mHdAssetLoader = null;
         mOriginalLoadedCallback(mAssetLoaderInfo,mSwfAsset);
      }
      
      private function hdErrorCallback(hdAssetLoaderInfo:AssetLoaderInfo) : void
      {
         Logger.info("SwfAssetLoader: HD version not found or failed to load: " + hdAssetLoaderInfo.getRawAssetPath());
         mHdAssetLoader = null;
         mOriginalLoadedCallback(mAssetLoaderInfo,mSwfAsset);
      }
      
      private function hdFileExists(hdPath:String) : Boolean
      {
         var _loc4_:String = null;
         var _loc3_:String = null;
         var _loc2_:File = null;
         try
         {
            _loc4_ = hdPath;
            if(_loc4_.indexOf("./") == 0)
            {
               _loc4_ = _loc4_.substring(2);
               _loc3_ = "app:/" + _loc4_;
               _loc2_ = new File(_loc3_);
               return _loc2_.exists;
            }
            Logger.info("SwfAssetLoader: Failed to strip prefix ./ when detecting HD asset: " + hdPath);
            return false;
         }
         catch(error:Error)
         {
            Logger.info("SwfAssetLoader: Error checking HD file existence: " + hdPath + " - " + error.message);
            var _loc8_:Boolean = false;
         }
         return _loc8_;
      }
      
      private function getHdPath(basePath:String) : String
      {
         var _loc3_:int = basePath.lastIndexOf(".");
         if(_loc3_ == -1)
         {
            return null;
         }
         var _loc2_:String = basePath.substring(_loc3_);
         if(_loc2_.toLowerCase() != ".swf")
         {
            return null;
         }
         var _loc4_:String = basePath.substring(0,_loc3_);
         return _loc4_ + ".HD.swf";
      }
      
      override public function destroy() : void
      {
         mSwfAsset = null;
         mOriginalLoadedCallback = null;
         mHdAssetLoader = null;
         super.destroy();
      }
   }
}

