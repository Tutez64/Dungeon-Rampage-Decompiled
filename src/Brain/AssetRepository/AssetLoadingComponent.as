package Brain.AssetRepository
{
   import Brain.Component.Component;
   import Brain.Facade.Facade;
   import Brain.Utils.MemoryTracker;
   import org.as3commons.collections.Set;
   import org.as3commons.collections.framework.ISetIterator;
   
   public class AssetLoadingComponent extends Component
   {
      
      public var mPendingDownloads:Set;
      
      protected var mTransitionToEmptyFunction:Function;
      
      protected var mAssetRepository:AssetRepository;
      
      public function AssetLoadingComponent(facade:Facade)
      {
         super(facade);
         mAssetRepository = facade.assetRepository;
         mPendingDownloads = new Set();
      }
      
      public function getJsonAsset(assetPath:String, loadedCallback:Function, errorCallback:Function, useCache:Boolean = true) : void
      {
         var _loc5_:AssetLoaderInfo = new AssetLoaderInfo(assetPath,useCache);
         MemoryTracker.track(_loc5_,"AssetLoaderInfo - JSON asset: " + assetPath,"brain");
         if(useCache)
         {
            if(mAssetRepository.tryCache(_loc5_,loadedCallback))
            {
               return;
            }
         }
         var _loc6_:AssetLoadingTracker = new AssetLoadingTracker(assetPath,this,loadedCallback,errorCallback);
         MemoryTracker.track(_loc6_,"AssetLoadingTracker - JSON asset: " + assetPath,"brain");
         mAssetRepository.getJsonAsset(_loc5_,_loc6_.successCallback,_loc6_.errorCallback);
      }
      
      public function getXMLAsset(assetPath:String, loadedCallback:Function, errorCallback:Function = null, useCache:Boolean = true) : void
      {
         var _loc5_:AssetLoaderInfo = new AssetLoaderInfo(assetPath,useCache);
         MemoryTracker.track(_loc5_,"AssetLoaderInfo - XML asset: " + assetPath,"brain");
         if(useCache)
         {
            if(mAssetRepository.tryCache(_loc5_,loadedCallback))
            {
               return;
            }
         }
         var _loc6_:AssetLoadingTracker = new AssetLoadingTracker(assetPath,this,loadedCallback,errorCallback);
         MemoryTracker.track(_loc6_,"AssetLoadingTracker - XML asset: " + assetPath,"brain");
         mAssetRepository.getXMLAsset(_loc5_,_loc6_.successCallback,_loc6_.errorCallback);
      }
      
      public function getByteArrayAsset(assetPath:String, loadedCallback:Function, errorCallback:Function = null, useCache:Boolean = true) : void
      {
         var _loc5_:AssetLoaderInfo = new AssetLoaderInfo(assetPath,useCache);
         MemoryTracker.track(_loc5_,"AssetLoaderInfo - ByteArray asset: " + assetPath,"brain");
         if(useCache)
         {
            if(mAssetRepository.tryCache(_loc5_,loadedCallback))
            {
               return;
            }
         }
         var _loc6_:AssetLoadingTracker = new AssetLoadingTracker(assetPath,this,loadedCallback,errorCallback);
         MemoryTracker.track(_loc6_,"AssetLoadingTracker - ByteArray asset: " + assetPath,"brain");
         mAssetRepository.getByteArrayAsset(_loc5_,_loc6_.successCallback,_loc6_.errorCallback);
      }
      
      public function getSwfAsset(assetPath:String, loadedCallback:Function, errorCallback:Function = null, useCache:Boolean = true) : void
      {
         var _loc5_:AssetLoaderInfo = new AssetLoaderInfo(assetPath,useCache);
         MemoryTracker.track(_loc5_,"AssetLoaderInfo - SWF asset: " + assetPath,"brain");
         if(useCache)
         {
            if(mAssetRepository.tryCache(_loc5_,loadedCallback))
            {
               return;
            }
         }
         var _loc6_:AssetLoadingTracker = new AssetLoadingTracker(assetPath,this,loadedCallback,errorCallback);
         MemoryTracker.track(_loc6_,"AssetLoadingTracker - SWF asset: " + assetPath,"brain");
         mAssetRepository.getSwfAsset(_loc5_,_loc6_.successCallback,_loc6_.errorCallback);
      }
      
      public function getSpriteSheetAsset(SwfPath:String, bitmapDataName:String, loadedCallback:Function, errorCallback:Function, useCache:Boolean, trickelloadCallback:Function, shClassName:String) : void
      {
         var _loc8_:SpriteSheetAssetLoaderInfo = new SpriteSheetAssetLoaderInfo(SwfPath,bitmapDataName,shClassName,useCache);
         MemoryTracker.track(_loc8_,"SpriteSheetAssetLoaderInfo - " + bitmapDataName + " from: " + SwfPath,"brain");
         if(useCache)
         {
            if(mAssetRepository.tryCache(_loc8_,loadedCallback))
            {
               return;
            }
         }
         var _loc9_:AssetLoadingTracker = new AssetLoadingTracker(_loc8_.getKey(),this,loadedCallback,errorCallback);
         MemoryTracker.track(_loc9_,"AssetLoadingTracker - SpriteSheet: " + bitmapDataName,"brain");
         mAssetRepository.getSpriteSheetAsset(mFacade,_loc8_,bitmapDataName,_loc9_.successCallback,_loc9_.errorCallback,trickelloadCallback,shClassName,this);
      }
      
      public function getSoundAsset(SwfPath:String, soundName:String, loadedCallback:Function, errorCallback:Function = null, useCache:Boolean = true) : void
      {
         if(soundName == null)
         {
            return;
         }
         var _loc6_:SoundAssetLoaderInfo = new SoundAssetLoaderInfo(SwfPath,soundName,useCache);
         MemoryTracker.track(_loc6_,"SoundAssetLoaderInfo - sound: " + soundName + " from: " + SwfPath,"brain");
         if(useCache)
         {
            if(mAssetRepository.tryCache(_loc6_,loadedCallback))
            {
               return;
            }
         }
         var _loc7_:AssetLoadingTracker = new AssetLoadingTracker(SwfPath,this,loadedCallback,errorCallback);
         MemoryTracker.track(_loc7_,"AssetLoadingTracker - Sound: " + soundName,"brain");
         mAssetRepository.getSoundAsset(_loc6_,soundName,_loc7_.successCallback,_loc7_.errorCallback);
      }
      
      public function getURLSoundAsset(path:String, loadedCallback:Function, errorCallback:Function = null, useCache:Boolean = true) : void
      {
         var _loc5_:SoundAssetLoaderInfo = new SoundAssetLoaderInfo(path,"",useCache);
         MemoryTracker.track(_loc5_,"SoundAssetLoaderInfo - URL sound: " + path,"brain");
         if(useCache)
         {
            if(mAssetRepository.tryCache(_loc5_,loadedCallback))
            {
               return;
            }
         }
         var _loc6_:AssetLoadingTracker = new AssetLoadingTracker(path,this,loadedCallback,errorCallback);
         MemoryTracker.track(_loc6_,"AssetLoadingTracker - URL Sound: " + path,"brain");
         mAssetRepository.getURLSoundAsset(_loc5_,_loc6_.successCallback,_loc6_.errorCallback);
      }
      
      public function getImageAsset(assetPath:String, loadedCallback:Function, errorCallback:Function = null, useCache:Boolean = true) : void
      {
         var _loc5_:AssetLoaderInfo = new AssetLoaderInfo(assetPath,useCache);
         MemoryTracker.track(_loc5_,"AssetLoaderInfo - Image asset: " + assetPath,"brain");
         if(useCache)
         {
            if(mAssetRepository.tryCache(_loc5_,loadedCallback))
            {
               return;
            }
         }
         var _loc6_:AssetLoadingTracker = new AssetLoadingTracker(assetPath,this,loadedCallback,errorCallback);
         MemoryTracker.track(_loc6_,"AssetLoadingTracker - Image: " + assetPath,"brain");
         mAssetRepository.getImageAsset(_loc5_,_loc6_.successCallback,_loc6_.errorCallback);
      }
      
      override public function destroy() : void
      {
         var _loc1_:ISetIterator = null;
         mTransitionToEmptyFunction = null;
         _loc1_ = mPendingDownloads.iterator() as ISetIterator;
         while(_loc1_.hasNext())
         {
            RemoveLoader(_loc1_.next() as AssetLoadingTracker);
            _loc1_ = mPendingDownloads.iterator() as ISetIterator;
         }
         mPendingDownloads = null;
         super.destroy();
      }
      
      public function clearAllActive() : void
      {
         var _loc1_:ISetIterator = null;
         mTransitionToEmptyFunction = null;
         _loc1_ = mPendingDownloads.iterator() as ISetIterator;
         while(_loc1_.hasNext())
         {
            RemoveLoader(_loc1_.next() as AssetLoadingTracker);
            _loc1_ = mPendingDownloads.iterator() as ISetIterator;
         }
      }
      
      public function RemoveLoader(assetLoadingTracker:AssetLoadingTracker) : void
      {
         mAssetRepository.removeCallbackFromPendingDownload(assetLoadingTracker.assetKey,assetLoadingTracker.successCallback);
         mAssetRepository.removeErrorCallbackFromPendingDownload(assetLoadingTracker.assetKey,assetLoadingTracker.errorCallback);
         assetLoadingTracker.destroy();
         var _loc2_:Boolean = mPendingDownloads.remove(assetLoadingTracker);
         if(_loc2_ && mPendingDownloads.size == 0 && mTransitionToEmptyFunction != null)
         {
            mTransitionToEmptyFunction();
            mTransitionToEmptyFunction = null;
         }
      }
      
      public function setTransitionToEmptyCallback(fun:Function) : void
      {
         if(mPendingDownloads.size == 0 && fun != null)
         {
            fun();
            mTransitionToEmptyFunction = null;
         }
         else
         {
            mTransitionToEmptyFunction = fun;
         }
      }
   }
}

