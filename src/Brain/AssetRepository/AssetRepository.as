package Brain.AssetRepository
{
   import Brain.Facade.Facade;
   import Brain.Sound.SoundAsset;
   import Brain.Utils.MemoryTracker;
   import flash.media.Sound;
   import org.as3commons.collections.Map;
   
   public class AssetRepository
   {
      
      protected static var mAssetCache:AssetCache = new AssetCache();
      
      protected var mPendingLoads:Map = new Map();
      
      protected var mFacade:Facade;
      
      public function AssetRepository(facade:Facade)
      {
         super();
         mFacade = facade;
      }
      
      public function tryCache(Info:AssetLoaderInfo, loadedCallback:Function) : Boolean
      {
         var _loc3_:Asset = mAssetCache.itemFor(Info);
         if(_loc3_)
         {
            if(loadedCallback != null)
            {
               loadedCallback(_loc3_);
            }
            return true;
         }
         return false;
      }
      
      protected function getAsset(assetLoaderInfo:AssetLoaderInfo, loadedCallback:Function, errorCallback:Function, assetLoaderClass:Class) : Boolean
      {
         var _loc5_:AssetLoader = null;
         var _loc7_:String = assetLoaderInfo.getKey();
         if(tryCache(assetLoaderInfo,loadedCallback))
         {
            return true;
         }
         var _loc6_:ActiveLoadBase = mPendingLoads.itemFor(_loc7_);
         if(_loc6_ == null)
         {
            _loc5_ = new assetLoaderClass(mFacade,assetLoaderInfo,this.executeSuccessCallbacks,this.executeErrorCallbacks);
            MemoryTracker.track(_loc5_,"AssetLoader - loading: " + _loc7_,"brain");
            _loc6_ = new ActiveLoaderWithLoader(_loc5_,this,assetLoaderInfo);
            MemoryTracker.track(_loc6_,"ActiveLoaderWithLoader - loading: " + _loc7_,"brain");
            mPendingLoads.add(_loc7_,_loc6_);
         }
         _loc6_.AddCallback(loadedCallback,errorCallback);
         return false;
      }
      
      public function getJsonAsset(assetLoaderInfo:AssetLoaderInfo, loadedCallback:Function, errorCallback:Function = null) : AssetLoaderInfo
      {
         var _loc4_:Boolean = getAsset(assetLoaderInfo,loadedCallback,errorCallback,JsonAssetLoader);
         return _loc4_ ? null : assetLoaderInfo;
      }
      
      public function getXMLAsset(assetLoaderInfo:AssetLoaderInfo, loadedCallback:Function, errorCallback:Function = null) : AssetLoaderInfo
      {
         var _loc4_:Boolean = getAsset(assetLoaderInfo,loadedCallback,errorCallback,XMLAssetLoader);
         return _loc4_ ? null : assetLoaderInfo;
      }
      
      public function getByteArrayAsset(assetLoaderInfo:AssetLoaderInfo, loadedCallback:Function, errorCallback:Function = null) : AssetLoaderInfo
      {
         var _loc4_:Boolean = getAsset(assetLoaderInfo,loadedCallback,errorCallback,ByteArrayAssetLoader);
         return _loc4_ ? null : assetLoaderInfo;
      }
      
      public function getSwfAsset(assetLoaderInfo:AssetLoaderInfo, loadedCallback:Function, errorCallback:Function = null) : AssetLoaderInfo
      {
         var _loc4_:Boolean = getAsset(assetLoaderInfo,loadedCallback,errorCallback,SwfAssetLoader);
         return _loc4_ ? null : assetLoaderInfo;
      }
      
      public function getImageAsset(assetLoaderInfo:AssetLoaderInfo, loadedCallback:Function, errorCallback:Function = null) : AssetLoaderInfo
      {
         var _loc4_:Boolean = getAsset(assetLoaderInfo,loadedCallback,errorCallback,ImageAssetLoader);
         return _loc4_ ? null : assetLoaderInfo;
      }
      
      public function getSpriteSheetAsset(facade:Facade, sheetLoaderInfo:SpriteSheetAssetLoaderInfo, bitmapDataName:String, loadedCallback:Function, errorCallback:Function, trickelLoaderCallback:Function, shClassName:String, assetLoadingComponent:AssetLoadingComponent = null) : void
      {
         var activeLoad:ActiveLoadBase;
         var swfLoaderInfo:AssetLoaderInfo;
         var loadSpriteSheetFromCache:Function;
         var loadSpriteSheet:Function;
         var trackLoad:ActiveLoaderDependent;
         if(tryCache(sheetLoaderInfo,loadedCallback))
         {
            return;
         }
         activeLoad = mPendingLoads.itemFor(sheetLoaderInfo.getKey());
         if(activeLoad != null)
         {
            activeLoad.AddCallback(loadedCallback,errorCallback);
            return;
         }
         swfLoaderInfo = new AssetLoaderInfo(sheetLoaderInfo.getRawAssetPath(),sheetLoaderInfo.useCache);
         MemoryTracker.track(swfLoaderInfo,"AssetLoaderInfo - SpriteSheet SWF: " + sheetLoaderInfo.getRawAssetPath(),"brain");
         loadSpriteSheetFromCache = function(param1:SwfAsset):void
         {
            var _loc2_:SpriteSheetAsset = null;
            if(param1.root.JsonObject && param1.root.JsonObject[shClassName])
            {
               _loc2_ = new SpriteSheetAsset(facade);
               _loc2_.FactoryFromSWf(bitmapDataName.replace(".png",""),param1.root.JsonObject[shClassName],param1);
               MemoryTracker.track(_loc2_,"SpriteSheetAsset - " + bitmapDataName + " (from cache)","brain");
               mAssetCache.add(sheetLoaderInfo,_loc2_);
               if(loadedCallback != null)
               {
                  loadedCallback(_loc2_);
               }
            }
         };
         if(tryCache(swfLoaderInfo,loadSpriteSheetFromCache))
         {
            return;
         }
         loadSpriteSheet = function(param1:SwfAsset):void
         {
            var _loc2_:SpriteSheetAsset = null;
            if(param1.root.JsonObject && param1.root.JsonObject[shClassName])
            {
               _loc2_ = new SpriteSheetAsset(facade);
               _loc2_.FactoryFromSWf(bitmapDataName.replace(".png",""),param1.root.JsonObject[shClassName],param1);
               MemoryTracker.track(_loc2_,"SpriteSheetAsset - " + bitmapDataName + " (new load)","brain");
               mAssetCache.add(sheetLoaderInfo,_loc2_);
               executeSuccessCallbacks(sheetLoaderInfo,_loc2_);
            }
         };
         trackLoad = new ActiveLoaderDependent(this,loadSpriteSheet,sheetLoaderInfo);
         MemoryTracker.track(trackLoad,"ActiveLoaderDependent - SpriteSheet: " + bitmapDataName,"brain");
         mPendingLoads.add(sheetLoaderInfo.getKey(),trackLoad);
         trackLoad.AddCallback(loadedCallback,errorCallback);
         if(assetLoadingComponent)
         {
            assetLoadingComponent.getSwfAsset(swfLoaderInfo.getRawAssetPath(),trackLoad.successCallback,trackLoad.errorCallback);
         }
         else
         {
            getSwfAsset(swfLoaderInfo,trackLoad.successCallback,trackLoad.errorCallback);
         }
      }
      
      public function getSoundAsset(assetLoaderInfo:SoundAssetLoaderInfo, soundName:String, loadedCallback:Function, errorCallback:Function = null) : void
      {
         var activeLoad:ActiveLoadBase;
         var swfLoaderInfo:AssetLoaderInfo;
         var loadSoundFromCache:Function;
         var loadSound:Function;
         var trackLoad:ActiveLoaderDependent;
         var cacheKey:String = assetLoaderInfo.getKey();
         if(tryCache(assetLoaderInfo,loadedCallback))
         {
            return;
         }
         activeLoad = mPendingLoads.itemFor(cacheKey);
         if(activeLoad != null)
         {
            activeLoad.AddCallback(loadedCallback,errorCallback);
            return;
         }
         swfLoaderInfo = new AssetLoaderInfo(assetLoaderInfo.getRawAssetPath(),assetLoaderInfo.useCache);
         MemoryTracker.track(swfLoaderInfo,"AssetLoaderInfo - Sound SWF: " + assetLoaderInfo.getRawAssetPath(),"brain");
         loadSoundFromCache = function(param1:SwfAsset):void
         {
            var _loc3_:Sound = null;
            var _loc4_:SoundAsset = null;
            var _loc2_:Class = param1.getClass(soundName);
            if(_loc2_)
            {
               _loc3_ = new _loc2_() as Sound;
               _loc4_ = new SoundAsset(_loc3_);
               MemoryTracker.track(_loc4_,"SoundAsset - " + soundName + " (from cache)","brain");
               mAssetCache.add(assetLoaderInfo,_loc4_);
               loadedCallback(_loc4_);
            }
            else if(errorCallback != null)
            {
               errorCallback();
            }
         };
         if(tryCache(swfLoaderInfo,loadSoundFromCache))
         {
            return;
         }
         loadSound = function(param1:SwfAsset):void
         {
            var _loc3_:Sound = null;
            var _loc4_:SoundAsset = null;
            var _loc2_:Class = param1.getClass(soundName);
            if(_loc2_)
            {
               _loc3_ = new _loc2_() as Sound;
               _loc4_ = new SoundAsset(_loc3_);
               MemoryTracker.track(_loc4_,"SoundAsset - " + soundName + " (new load)","brain");
               executeSuccessCallbacks(assetLoaderInfo,_loc4_);
            }
            else
            {
               executeErrorCallbacks(assetLoaderInfo);
            }
         };
         trackLoad = new ActiveLoaderDependent(this,loadSound,assetLoaderInfo);
         MemoryTracker.track(trackLoad,"ActiveLoaderDependent - Sound: " + soundName,"brain");
         mPendingLoads.add(cacheKey,trackLoad);
         trackLoad.AddCallback(loadedCallback,errorCallback);
         getSwfAsset(swfLoaderInfo,trackLoad.successCallback,trackLoad.errorCallback);
      }
      
      public function getURLSoundAsset(assetLoaderInfo:SoundAssetLoaderInfo, loadedCallback:Function, errorCallback:Function = null) : AssetLoaderInfo
      {
         var _loc4_:Boolean = getAsset(assetLoaderInfo,loadedCallback,errorCallback,URLSoundAssetLoader);
         return _loc4_ ? null : assetLoaderInfo;
      }
      
      public function removeCallbackFromPendingDownload(assetKey:String, loadedCallback:Function) : Boolean
      {
         var _loc3_:Boolean = false;
         var _loc4_:ActiveLoadBase = mPendingLoads.itemFor(assetKey);
         if(_loc4_ != null)
         {
            _loc3_ = _loc4_.removeCallback(loadedCallback,null);
            if(_loc4_.hasNoCallbacks())
            {
               mPendingLoads.removeKey(assetKey);
               _loc4_.destroy();
            }
         }
         return _loc3_;
      }
      
      public function removeErrorCallbackFromPendingDownload(assetKey:String, errorCallback:Function) : Boolean
      {
         var _loc3_:Boolean = false;
         var _loc4_:ActiveLoadBase = mPendingLoads.itemFor(assetKey);
         if(_loc4_ != null)
         {
            _loc3_ = _loc4_.removeCallback(null,errorCallback);
            if(_loc4_.hasNoCallbacks())
            {
               mPendingLoads.removeKey(assetKey);
               _loc4_.destroy();
            }
         }
         return _loc3_;
      }
      
      protected function executeSuccessCallbacks(assetLoaderInfo:AssetLoaderInfo, asset:Asset) : void
      {
         var _loc4_:String = assetLoaderInfo.getKey();
         mAssetCache.add(assetLoaderInfo,asset);
         var _loc3_:ActiveLoadBase = mPendingLoads.removeKey(_loc4_);
         if(_loc3_ != null)
         {
            _loc3_.executeSucessCallbacks(assetLoaderInfo,asset);
            _loc3_.destroy();
         }
      }
      
      public function executeErrorCallbacks(assetLoaderInfo:AssetLoaderInfo) : void
      {
         var _loc2_:ActiveLoadBase = null;
         var _loc3_:String = assetLoaderInfo.getKey();
         if(mPendingLoads.hasKey(_loc3_))
         {
            _loc2_ = mPendingLoads.removeKey(_loc3_);
            if(_loc2_ != null)
            {
               _loc2_.executeErrorCallbacks(assetLoaderInfo);
               _loc2_.destroy();
            }
         }
      }
      
      public function removeCacheForAllSpriteSheetAssets() : void
      {
         mAssetCache.removeCacheForSpriteSheetAssets();
      }
      
      public function removeFromCache(asset:Asset) : Boolean
      {
         return mAssetCache.remove(asset);
      }
      
      public function destroy() : void
      {
      }
   }
}

import Brain.AssetRepository.ActiveLoadBase;
import Brain.AssetRepository.Asset;
import Brain.AssetRepository.AssetLoader;
import Brain.AssetRepository.AssetLoaderInfo;
import Brain.AssetRepository.AssetRepository;

final class ActiveLoaderWithLoader extends ActiveLoadBase
{
   
   public var mAssetLoader:AssetLoader;
   
   public function ActiveLoaderWithLoader(assetLoader:AssetLoader, assetRepository:AssetRepository, info:AssetLoaderInfo)
   {
      super(assetRepository,info);
      this.mAssetLoader = assetLoader;
   }
   
   override public function destroy() : void
   {
      super.destroy();
      mAssetLoader.destroy();
      mAssetLoader = null;
   }
   
   override public function executeSucessCallbacks(assetLoaderInfo:AssetLoaderInfo, asset:Asset) : void
   {
      super.executeSucessCallbacks(assetLoaderInfo,asset);
   }
}

final class ActiveLoaderDependent extends ActiveLoadBase
{
   
   public var mSuccess:Function;
   
   public function ActiveLoaderDependent(assetRepository:AssetRepository, callback:Function, info:AssetLoaderInfo)
   {
      super(assetRepository,info);
      mSuccess = callback;
   }
   
   public function successCallback(asset:Object) : void
   {
      mSuccess(asset);
   }
   
   public function errorCallback() : void
   {
      mAssetRepository.executeErrorCallbacks(mInfo);
   }
   
   override public function destroy() : void
   {
      mSuccess = null;
      mAssetRepository.removeCallbackFromPendingDownload(mInfo.getKey(),successCallback);
      mAssetRepository.removeErrorCallbackFromPendingDownload(mInfo.getKey(),errorCallback);
      super.destroy();
   }
}
