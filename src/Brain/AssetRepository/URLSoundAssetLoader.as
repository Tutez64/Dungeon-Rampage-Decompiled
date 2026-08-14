package Brain.AssetRepository
{
   import Brain.Clock.GameClock;
   import Brain.Facade.Facade;
   import Brain.Logger.Logger;
   import Brain.Sound.SoundAsset;
   import Brain.Utils.MemoryTracker;
   import flash.events.Event;
   import flash.events.IOErrorEvent;
   import flash.events.SecurityErrorEvent;
   import flash.media.Sound;
   import flash.net.URLRequest;
   
   public class URLSoundAssetLoader extends AssetLoader
   {
      
      protected var mSoundAsset:SoundAsset;
      
      private var mSound:Sound;
      
      public function URLSoundAssetLoader(facade:Facade, assetLoaderInfo:AssetLoaderInfo, loadedCallback:Function, errorCallback:Function = null)
      {
         super(facade,assetLoaderInfo,loadedCallback,errorCallback,false);
      }
      
      override protected function loadAsset(facade:Facade, assetPath:String, useCache:Boolean = true) : void
      {
         var _loc4_:URLRequest = new URLRequest(assetPath);
         if(useCache)
         {
            _loc4_.url += "?v=" + facade.fileVersion(assetPath);
         }
         else
         {
            _loc4_.url += "?t=" + new Date().getTime().toString();
         }
         mSound = new Sound();
         mSound.load(_loc4_);
         mSound.addEventListener("complete",soundLoadComplete);
         mSound.addEventListener("ioError",soundLoadIOError);
         mSound.addEventListener("securityError",soundLoadSecurityError);
         if(mCollectingTrackLoads)
         {
            mTrackedLoads.add(mAssetLoaderInfo.getRawAssetPath());
         }
      }
      
      protected function soundLoadComplete(event:Event) : void
      {
         Logger.info("Loader.loadComplete: " + event.target.url);
         mSoundAsset = new SoundAsset(mSound);
         MemoryTracker.track(mSoundAsset,"SoundAsset - URL: " + event.target.url,"brain");
         var _loc2_:Asset = mSoundAsset;
         var _loc3_:AssetLoaderInfo = mAssetLoaderInfo;
         mAssetCreatedCallback(mAssetLoaderInfo,_loc2_);
         updateTrackingLoad(_loc3_.getRawAssetPath());
      }
      
      protected function soundLoadIOError(evt:IOErrorEvent) : void
      {
         updateTrackingLoad(mAssetLoaderInfo.getRawAssetPath());
         if(mFacade.gameClock.frame > 1)
         {
            mFacade.logicalWorkManager.doLater(0.1,function(param1:GameClock):void
            {
               if(mAssetLoaderInfo)
               {
                  Logger.error("Loader.handleIOErrorUrl from path: " + mAssetLoaderInfo.getRawAssetPath());
                  if(mErrorCallback != null)
                  {
                     mErrorCallback(mAssetLoaderInfo);
                  }
               }
            },false,"URLSoundAssetLoader.handleIOError");
         }
         else
         {
            Logger.error("Loader.handleIOErrorUrl from path: " + mAssetLoaderInfo.getRawAssetPath());
            if(mErrorCallback != null)
            {
               mErrorCallback(mAssetLoaderInfo);
            }
         }
      }
      
      protected function soundLoadSecurityError(evt:SecurityErrorEvent) : void
      {
         Logger.error("Loader.handleSecurityError from path: " + mAssetLoaderInfo.getRawAssetPath() + ".   " + evt.text);
         var _loc2_:AssetLoaderInfo = mAssetLoaderInfo;
         if(mErrorCallback != null)
         {
            mErrorCallback(mAssetLoaderInfo);
         }
         updateTrackingLoad(_loc2_.getRawAssetPath());
      }
   }
}

