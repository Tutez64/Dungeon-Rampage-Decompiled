package Brain.AssetRepository
{
   import Brain.Component.Component;
   import Brain.Facade.Facade;
   import Brain.Logger.Logger;
   import Brain.Utils.MemoryTracker;
   import Collections.ISetIterator;
   import Collections.Set;
   import flash.desktop.NativeApplication;
   import flash.events.Event;
   import flash.filesystem.File;
   import flash.filesystem.FileStream;
   import starling.assets.AssetFactory;
   import starling.assets.AssetReference;
   import starling.core.Starling;
   import starling.extensions.animate.AnimAssetManager;
   import starling.extensions.animate.Animation;
   import starling.extensions.animate.AnimationAtlas;
   import starling.textures.Texture;
   import starling.textures.TextureOptions;
   
   public class AssetLoadingComponent extends Component
   {
      
      public static const STARLING_ASSETS_QUEUED:String = "StarlingAssetsQueued";
      
      public static const STARLING_ASSETS_READY:String = "StarlingAssetsReady";
      
      public static const OUT_OF_GRAPHICS_RESOURCES:String = "Out of graphics resources. Please restart the game.";
      
      private static const AIR32_TEXTURE_BUDGET_MIB:int = 1792;
      
      private static const PROP_KEY_PREFIX:String = "prop:";
      
      private static const MAX_CONCURRENT_BUNDLE_LOADS:int = 3;
      
      private static const MAX_TOTAL_CONNECTIONS:int = 3;
      
      public static const TIER_BODY:int = 0;
      
      public static const TIER_WEAPON:int = 1;
      
      public static const TIER_EFFECT:int = 2;
      
      public static const TIER_UNCLASSIFIED:int = 3;
      
      public static const TIER_PET:int = 4;
      
      private static const sRootClipLabels:Object = {};
      
      private static const sFolderScales:Object = {};
      
      public var mPendingDownloads:Set;
      
      public var mStarlingAssetManager:AnimAssetManager;
      
      protected var mBundleManagers:Object = {};
      
      protected var mLoadedBiomeKeys:Object = {};
      
      protected var mPendingBiomeKeys:Vector.<String> = new Vector.<String>();
      
      protected var mBiomeKeyCallbacks:Object = {};
      
      private var mCallbackKeyOrder:Vector.<String> = new Vector.<String>();
      
      protected var mLoadingBiomeKeys:Vector.<String> = new Vector.<String>();
      
      protected var mBackgroundKeys:Object = {};
      
      protected var mBackgroundTiers:Object = {};
      
      protected var mLoadingAssetFiles:Object = {};
      
      protected var mIsStartingLoads:Boolean;
      
      protected var mFloorRequestKeys:Object = {};
      
      protected var mKeptResidentKeys:Object = {};
      
      protected var mFloorKeysLoading:Object = {};
      
      protected var mCurrentFloorBiome:String;
      
      protected var mRequestedFloorBiome:String;
      
      protected var mFloorGeneration:int = 1;
      
      protected var mEntryBegun:Boolean;
      
      protected var mKeyLastUsed:Object = {};
      
      protected var mStarlingLoadActive:Boolean;
      
      protected var mLoadingProgress:Object = {};
      
      protected var mStarlingBundlesLoaded:uint = 0;
      
      protected var mIsDrainingCompletion:Boolean;
      
      protected var mPropManifests:Object = {};
      
      protected var mAnimationOwners:Object = {};
      
      protected var mBundleAnimationNames:Object = {};
      
      protected var mLabelOwners:Object = {};
      
      protected var mBundleLabelNames:Object = {};
      
      protected var mAtlasOwners:Object = {};
      
      protected var mBundleAtlasNames:Object = {};
      
      protected var mTransitionToEmptyFunction:Function;
      
      protected var mAssetRepository:AssetRepository;
      
      protected var mStarlingPurgeCount:int;
      
      protected var mOverrideAssetFiles:Object = {};
      
      private var mStartedBundles:Array = [];
      
      private var mBundleConnections:Object = {};
      
      protected var mConnectionsInUse:int;
      
      private var mBundleFactories:Array = [];
      
      public function AssetLoadingComponent(facade:Facade)
      {
         super(facade);
         mAssetRepository = facade.assetRepository;
         mPendingDownloads = new Set();
      }
      
      private static function getPropKey(libraryKey:String, assetClassName:String) : String
      {
         return "prop:" + libraryKey + "/" + assetClassName;
      }
      
      private static function rootClipLabels(folder:File) : Object
      {
         var _loc9_:Object = null;
         var _loc5_:File = null;
         var _loc4_:FileStream = null;
         var _loc3_:Object = null;
         var _loc10_:Object = null;
         var _loc6_:Object = null;
         var _loc7_:String = null;
         var _loc2_:String = folder.nativePath;
         if(!sRootClipLabels.hasOwnProperty(_loc2_))
         {
            _loc9_ = {};
            _loc5_ = folder.resolvePath("Animation.json");
            if(_loc5_.exists)
            {
               try
               {
                  _loc4_ = new FileStream();
                  _loc4_.open(_loc5_,"read");
                  try
                  {
                     _loc3_ = JSON.parse(_loc4_.readUTFBytes(_loc4_.bytesAvailable));
                  }
                  finally
                  {
                     _loc4_.close();
                  }
                  _loc10_ = _loc3_.AN || _loc3_.ANIMATION;
                  _loc6_ = _loc10_ != null ? _loc10_.TL || _loc10_.TIMELINE : null;
                  for each(var _loc8_:Object in _loc6_ != null ? _loc6_.L || _loc6_.LAYERS : null)
                  {
                     for each(var _loc11_:Object in _loc8_.FR || _loc8_.Frames)
                     {
                        _loc7_ = _loc11_.N || _loc11_.name;
                        if(_loc7_)
                        {
                           _loc9_[_loc7_] = true;
                        }
                     }
                  }
               }
               catch(e:Error)
               {
                  Logger.error("AssetLoadingComponent.rootClipLabels: could not read " + _loc5_.nativePath + ": " + e.message);
               }
            }
            sRootClipLabels[_loc2_] = _loc9_;
         }
         return sRootClipLabels[_loc2_];
      }
      
      private static function scaleForFolder(folder:File) : Number
      {
         var _loc3_:StarlingPropManifest = null;
         if(folder == null)
         {
            return 1;
         }
         var _loc2_:String = folder.nativePath;
         if(!sFolderScales.hasOwnProperty(_loc2_))
         {
            _loc3_ = new StarlingPropManifest();
            _loc3_.load(folder.resolvePath("flattened_registration.json"));
            sFolderScales[_loc2_] = _loc3_.scaleForFolder(folder);
         }
         return sFolderScales[_loc2_];
      }
      
      private static function withThousands(value:Number) : String
      {
         var _loc2_:int = 0;
         var _loc3_:String = String(value);
         _loc2_ = _loc3_.length - 3;
         while(_loc2_ > 0)
         {
            _loc3_ = _loc3_.substr(0,_loc2_) + "," + _loc3_.substr(_loc2_);
            _loc2_ -= 3;
         }
         return _loc3_;
      }
      
      private static function addOwner(owners:Object, names:Vector.<String>, bundleKey:String) : void
      {
         var _loc4_:Vector.<String> = undefined;
         for each(var _loc5_:String in names)
         {
            _loc4_ = owners[_loc5_];
            if(_loc4_ == null)
            {
               _loc4_ = new Vector.<String>();
               owners[_loc5_] = _loc4_;
            }
            if(_loc4_.indexOf(bundleKey) == -1)
            {
               _loc4_.push(bundleKey);
            }
         }
      }
      
      private static function removeOwner(owners:Object, names:Vector.<String>, bundleKey:String) : void
      {
         var _loc4_:Vector.<String> = undefined;
         var _loc6_:int = 0;
         for each(var _loc5_:String in names)
         {
            _loc4_ = owners[_loc5_];
            _loc6_ = _loc4_ != null ? _loc4_.indexOf(bundleKey) : -1;
            if(_loc6_ != -1)
            {
               _loc4_.splice(_loc6_,1);
               if(_loc4_.length == 0)
               {
                  delete owners[_loc5_];
               }
            }
         }
      }
      
      private static function findLibraryOwner(owners:Vector.<String>, libraryKey:String) : String
      {
         var _loc4_:String = getPropKey(libraryKey,"");
         var _loc5_:String = StarlingAssetMapper.getPropsOnlyKey(libraryKey);
         for each(var _loc3_:String in owners)
         {
            if(_loc3_ == libraryKey || _loc3_ == _loc5_ || _loc3_.indexOf(_loc4_) == 0)
            {
               return _loc3_;
            }
         }
         return null;
      }
      
      public function get starlingPurgeCount() : int
      {
         return mStarlingPurgeCount;
      }
      
      public function initializeStarlingAssetManager() : void
      {
         if(mStarlingAssetManager != null)
         {
            return;
         }
         mStarlingAssetManager = new AnimAssetManager();
         mStarlingAssetManager.verbose = false;
         registerStarlingFactory(new SafeAtfTextureFactory(),1);
         registerStarlingFactory(new SafeXmlFactory(),1);
      }
      
      public function registerStarlingFactory(factory:AssetFactory, priority:int) : void
      {
         mStarlingAssetManager.registerFactory(factory,priority);
         mBundleFactories.push({
            "factory":factory,
            "priority":priority
         });
      }
      
      private function newBundleManager() : AnimAssetManager
      {
         var _loc2_:AnimAssetManager = new AnimAssetManager();
         _loc2_.verbose = false;
         for each(var _loc1_:Object in mBundleFactories)
         {
            _loc2_.registerFactory(_loc1_.factory,_loc1_.priority);
         }
         return _loc2_;
      }
      
      public function get isStarlingReady() : Boolean
      {
         return mStarlingAssetManager != null;
      }
      
      public function get isStarlingLoadPending() : Boolean
      {
         return mStarlingLoadActive;
      }
      
      public function get currentFloorBiome() : String
      {
         return mCurrentFloorBiome;
      }
      
      public function get requestedFloorBiome() : String
      {
         return mRequestedFloorBiome;
      }
      
      public function isStarlingKeyResident(biomeKey:String) : Boolean
      {
         return mStarlingAssetManager != null && mLoadedBiomeKeys[biomeKey] == true;
      }
      
      public function queueStarlingAssetsForPath(assetPath:String, onComplete:Function = null, isFloorRequest:Boolean = false, isBackground:Boolean = false, backgroundTier:int = 3) : void
      {
         var _loc6_:String = null;
         var _loc7_:File = StarlingAssetMapper.getActorAtlasFile(assetPath);
         if(_loc7_ != null)
         {
            _loc6_ = StarlingAssetMapper.getActorAtlasKeyFromPath(assetPath);
            queueStarlingAssets(_loc6_,onComplete,false,[_loc7_],isBackground,backgroundTier);
            return;
         }
         var _loc8_:String = isFloorRequest ? StarlingAssetMapper.getBiomeKeyFromPath(assetPath) : StarlingAssetMapper.getPropLibraryKey(assetPath,mRequestedFloorBiome);
         queueStarlingAssets(_loc8_,onComplete,isFloorRequest,null,isBackground,backgroundTier);
      }
      
      public function queueStarlingAssetsForProps(assetPath:String, animatedClassNames:Array, onComplete:Function = null, isBackground:Boolean = false, backgroundTier:int = 3) : void
      {
         if(mStarlingAssetManager == null || animatedClassNames == null || animatedClassNames.length == 0)
         {
            queueStarlingAssetsForPath(assetPath,onComplete,false,isBackground,backgroundTier);
            return;
         }
         queueStarlingAssetsForPath(assetPath,function():void
         {
            var className:String;
            var libraryKey:String;
            var atlasFolder:File;
            var biomeKey:String = StarlingAssetMapper.getBiomeKeyFromPath(assetPath);
            var remaining:int = 1;
            var onPropComplete:Function = function():void
            {
               if(--remaining == 0 && onComplete != null)
               {
                  onComplete();
               }
            };
            for each(className in animatedClassNames)
            {
               for each(libraryKey in [biomeKey,"shared"])
               {
                  atlasFolder = StarlingAssetMapper.getPropAtlasFile(libraryKey,className);
                  if(atlasFolder != null)
                  {
                     remaining = remaining + 1;
                     queueStarlingAssets(getPropKey(libraryKey,className),onPropComplete,false,[atlasFolder],isBackground,backgroundTier);
                     break;
                  }
               }
            }
            onPropComplete();
         },false,isBackground,backgroundTier);
      }
      
      private function isStalePropKey(biomeKey:String) : Boolean
      {
         return biomeKey.indexOf("prop:") == 0 && mKeyLastUsed[biomeKey] < mFloorGeneration;
      }
      
      private function isSharedUnresolved() : Boolean
      {
         var _loc1_:String = "shared";
         return mPendingBiomeKeys.indexOf(_loc1_) != -1 || mLoadingBiomeKeys.indexOf(_loc1_) != -1;
      }
      
      public function queueStarlingAssets(biomeKey:String, onComplete:Function = null, isFloorRequest:Boolean = false, assetFiles:Array = null, isBackground:Boolean = false, backgroundTier:int = 3) : void
      {
         var _loc8_:Vector.<Function> = undefined;
         var _loc11_:Boolean = false;
         if(mStarlingAssetManager == null)
         {
            if(onComplete != null)
            {
               onComplete();
            }
            return;
         }
         isBackground = isBackground && !isFloorRequest && biomeKey != "shared";
         var _loc10_:Boolean = isFloorRequest && mCurrentFloorBiome != null && mCurrentFloorBiome != biomeKey;
         if(isFloorRequest)
         {
            mRequestedFloorBiome = biomeKey;
         }
         if(_loc10_ && !mFloorRequestKeys[biomeKey] && !mEntryBegun)
         {
            mFloorGeneration = mFloorGeneration + 1;
         }
         if(isFloorRequest)
         {
            mEntryBegun = false;
         }
         mKeyLastUsed[biomeKey] = mFloorGeneration;
         var _loc9_:Boolean = biomeKey != "shared" && isSharedUnresolved();
         if(mLoadedBiomeKeys[biomeKey] && !_loc9_)
         {
            if(!isFloorRequest || mCurrentFloorBiome == biomeKey)
            {
               if(onComplete != null)
               {
                  onComplete();
               }
               return;
            }
            if(mCurrentFloorBiome == null)
            {
               mCurrentFloorBiome = biomeKey;
               if(onComplete != null)
               {
                  onComplete();
               }
               return;
            }
         }
         if(isFloorRequest)
         {
            for each(var _loc12_:String in mPendingBiomeKeys)
            {
               if(_loc12_ != biomeKey && mFloorRequestKeys[_loc12_])
               {
                  delete mFloorRequestKeys[_loc12_];
               }
            }
         }
         if(isFloorRequest && mCurrentFloorBiome != biomeKey)
         {
            mFloorRequestKeys[biomeKey] = mFloorGeneration;
         }
         if(onComplete != null)
         {
            _loc8_ = mBiomeKeyCallbacks[biomeKey];
            if(_loc8_ == null)
            {
               _loc8_ = new Vector.<Function>();
               mBiomeKeyCallbacks[biomeKey] = _loc8_;
               mCallbackKeyOrder.push(biomeKey);
            }
            _loc8_.push(onComplete);
         }
         if(mLoadedBiomeKeys[biomeKey] && !mFloorRequestKeys[biomeKey])
         {
            return;
         }
         if(mLoadingBiomeKeys.indexOf(biomeKey) != -1)
         {
            if(!isBackground && mBackgroundKeys[biomeKey])
            {
               dropBackground(biomeKey);
               startPendingLoads();
            }
            return;
         }
         var _loc13_:int = mPendingBiomeKeys.indexOf(biomeKey);
         if(_loc13_ != -1)
         {
            _loc11_ = isFloorRequest && mFloorRequestKeys[biomeKey];
            if(mBackgroundKeys[biomeKey] && (!isBackground || isFloorRequest))
            {
               dropBackground(biomeKey);
               _loc11_ = true;
            }
            else if(isBackground && mBackgroundKeys[biomeKey] && backgroundTier < int(mBackgroundTiers[biomeKey]))
            {
               mBackgroundTiers[biomeKey] = backgroundTier;
               _loc11_ = true;
            }
            if(_loc11_)
            {
               mPendingBiomeKeys.splice(_loc13_,1);
               enqueuePendingKey(biomeKey);
               startPendingLoads();
            }
            return;
         }
         if(assetFiles != null && assetFiles.length > 0)
         {
            mOverrideAssetFiles[biomeKey] = assetFiles;
         }
         else if(!StarlingAssetMapper.isKnownBiome(biomeKey))
         {
            mLoadedBiomeKeys[biomeKey] = true;
            flushBiomeKeyCallbacks(biomeKey);
            return;
         }
         var _loc7_:String = "shared";
         if((assetFiles == null || assetFiles.length == 0) && biomeKey != _loc7_ && !mLoadedBiomeKeys[_loc7_] && mPendingBiomeKeys.indexOf(_loc7_) == -1 && mLoadingBiomeKeys.indexOf(_loc7_) == -1)
         {
            mKeyLastUsed[_loc7_] = mFloorGeneration;
            enqueuePendingKey(_loc7_);
         }
         if(isBackground)
         {
            mBackgroundKeys[biomeKey] = true;
            mBackgroundTiers[biomeKey] = backgroundTier;
         }
         enqueuePendingKey(biomeKey);
         startPendingLoads();
      }
      
      private function enqueuePendingKey(biomeKey:String) : void
      {
         var _loc2_:int = 0;
         if(mFloorRequestKeys[biomeKey])
         {
            mPendingBiomeKeys.unshift(biomeKey);
            return;
         }
         if(biomeKey == "shared")
         {
            _loc2_ = 0;
            while(_loc2_ < mPendingBiomeKeys.length && mFloorRequestKeys[mPendingBiomeKeys[_loc2_]])
            {
               _loc2_++;
            }
            mPendingBiomeKeys.splice(_loc2_,0,biomeKey);
            return;
         }
         _loc2_ = int(mPendingBiomeKeys.length);
         var _loc3_:Boolean = Boolean(mBackgroundKeys[biomeKey]);
         while(_loc2_ > 0 && mBackgroundKeys[mPendingBiomeKeys[_loc2_ - 1]] && (!_loc3_ || int(mBackgroundTiers[mPendingBiomeKeys[_loc2_ - 1]]) > int(mBackgroundTiers[biomeKey])))
         {
            _loc2_--;
         }
         mPendingBiomeKeys.splice(_loc2_,0,biomeKey);
      }
      
      private function dropBackground(biomeKey:String) : void
      {
         delete mBackgroundKeys[biomeKey];
         delete mBackgroundTiers[biomeKey];
      }
      
      private function get isFloorSlotReserved() : Boolean
      {
         return mEntryBegun;
      }
      
      private function startPendingLoads() : void
      {
         var _loc1_:String = null;
         var _loc2_:Array = null;
         if(mIsStartingLoads || mIsDrainingCompletion)
         {
            return;
         }
         mIsStartingLoads = true;
         try
         {
            while(mPendingBiomeKeys.length > 0 && mLoadingBiomeKeys.length < 3)
            {
               _loc1_ = mPendingBiomeKeys[0];
               if(mBackgroundKeys[_loc1_] && loadingBackgroundCount() > 0)
               {
                  break;
               }
               if(isSwitchWaitingOnLoads(_loc1_))
               {
                  break;
               }
               if(!mFloorRequestKeys[_loc1_] && isFloorSlotReserved && mLoadingBiomeKeys.length >= 3 - 1)
               {
                  break;
               }
               _loc2_ = mOverrideAssetFiles[_loc1_] as Array;
               if(_loc2_ == null)
               {
                  _loc2_ = StarlingAssetMapper.getAssetFilesForBiome(_loc1_,false);
               }
               if(overlapsActiveFiles(_loc2_))
               {
                  break;
               }
               startBiomeLoad(mPendingBiomeKeys.shift());
            }
         }
         finally
         {
            mIsStartingLoads = false;
            loadStartedBundles();
         }
         updateBlockingLoadState();
      }
      
      private function updateBlockingLoadState() : void
      {
         if(mIsDrainingCompletion || mIsStartingLoads)
         {
            return;
         }
         var _loc1_:Boolean = loadingBlockingCount() > 0 || pendingBlockingCount() > 0;
         if(_loc1_ == mStarlingLoadActive)
         {
            return;
         }
         mStarlingLoadActive = _loc1_;
         mFacade.eventManager.dispatchEvent(new Event(_loc1_ ? "StarlingAssetsQueued" : "StarlingAssetsReady"));
      }
      
      private function loadingBlockingCount() : int
      {
         var _loc1_:int = 0;
         for each(var _loc2_:String in mLoadingBiomeKeys)
         {
            if(!mBackgroundKeys[_loc2_])
            {
               _loc1_++;
            }
         }
         return _loc1_;
      }
      
      private function pendingBlockingCount() : int
      {
         var _loc1_:int = 0;
         for each(var _loc2_:String in mPendingBiomeKeys)
         {
            if(!mBackgroundKeys[_loc2_])
            {
               _loc1_++;
            }
         }
         return _loc1_;
      }
      
      private function loadingBackgroundCount() : int
      {
         return mLoadingBiomeKeys.length - loadingBlockingCount();
      }
      
      private function isSwitchWaitingOnLoads(biomeKey:String) : Boolean
      {
         var _loc4_:int = int(mFloorRequestKeys[biomeKey]);
         if(!_loc4_)
         {
            return false;
         }
         for(var _loc2_:String in mFloorKeysLoading)
         {
            if(_loc2_ != biomeKey)
            {
               return true;
            }
         }
         if(mCurrentFloorBiome == null || mCurrentFloorBiome == biomeKey)
         {
            return false;
         }
         for each(var _loc3_:String in mLoadingBiomeKeys)
         {
            if(!mBackgroundKeys[_loc3_] && isStaleAtSwitch(_loc3_,_loc4_))
            {
               return true;
            }
         }
         return false;
      }
      
      private function loadStartedBundles() : void
      {
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         if(mStartedBundles.length == 0)
         {
            return;
         }
         var _loc2_:Array = mStartedBundles;
         mStartedBundles = [];
         var _loc6_:int = Math.max(0,3 - mConnectionsInUse);
         var _loc1_:Array = [];
         _loc4_ = 0;
         while(_loc4_ < _loc2_.length)
         {
            _loc1_.push(0);
            _loc4_++;
         }
         var _loc3_:Boolean = true;
         while(_loc6_ > 0 && _loc3_)
         {
            _loc3_ = false;
            _loc4_ = 0;
            while(_loc4_ < _loc2_.length && _loc6_ > 0)
            {
               if(_loc1_[_loc4_] < queuedAssetCount(_loc2_[_loc4_].bundle))
               {
                  ++_loc1_[_loc4_];
                  _loc6_--;
                  _loc3_ = true;
               }
               _loc4_++;
            }
         }
         _loc4_ = 0;
         while(_loc4_ < _loc2_.length)
         {
            _loc5_ = Math.max(1,_loc1_[_loc4_]);
            _loc2_[_loc4_].bundle.numConnections = _loc5_;
            mBundleConnections[_loc2_[_loc4_].key] = _loc5_;
            mConnectionsInUse += _loc5_;
            _loc4_++;
         }
         _loc4_ = 0;
         while(_loc4_ < _loc2_.length)
         {
            loadBundle(_loc2_[_loc4_].key,_loc2_[_loc4_].bundle);
            _loc4_++;
         }
      }
      
      private function overlapsActiveFiles(files:Array) : Boolean
      {
         var _loc4_:String = null;
         var _loc6_:String = null;
         for each(var _loc2_:Array in mLoadingAssetFiles)
         {
            for each(var _loc3_:File in files)
            {
               _loc4_ = _loc3_.nativePath.replace(new RegExp("\\\\","g"),"/") + "/";
               for each(var _loc5_:File in _loc2_)
               {
                  _loc6_ = _loc5_.nativePath.replace(new RegExp("\\\\","g"),"/") + "/";
                  if(_loc4_.indexOf(_loc6_) == 0 || _loc6_.indexOf(_loc4_) == 0)
                  {
                     return true;
                  }
               }
            }
         }
         return false;
      }
      
      protected function startBiomeLoad(biomeKey:String) : void
      {
         var _loc6_:int = 0;
         var _loc2_:StarlingPropManifest = null;
         var _loc11_:Array = null;
         var _loc13_:Array = null;
         var _loc3_:Object = null;
         if(isStalePropKey(biomeKey))
         {
            delete mOverrideAssetFiles[biomeKey];
            delete mKeyLastUsed[biomeKey];
            dropBackground(biomeKey);
            flushBiomeKeyCallbacks(biomeKey);
            return;
         }
         mLoadingBiomeKeys.push(biomeKey);
         if(mFloorRequestKeys[biomeKey])
         {
            _loc6_ = int(mFloorRequestKeys[biomeKey]);
            delete mFloorRequestKeys[biomeKey];
            if(mCurrentFloorBiome != null && mCurrentFloorBiome != biomeKey)
            {
               evictStaleBundles(biomeKey,_loc6_);
            }
            mCurrentFloorBiome = biomeKey;
            mFloorKeysLoading[biomeKey] = true;
         }
         if(mLoadedBiomeKeys[biomeKey] || mStarlingAssetManager.getAssetManager(biomeKey) != null)
         {
            if(mBundleManagers[biomeKey] == null)
            {
               mBundleManagers[biomeKey] = mStarlingAssetManager.getAssetManager(biomeKey) as AnimAssetManager;
            }
            delete mOverrideAssetFiles[biomeKey];
            onBiomeLoadComplete(biomeKey);
            return;
         }
         if(Texture.asyncBitmapUploadEnabled)
         {
            reportLoadFailure(biomeKey,null,"async bitmap texture uploads are on; their failures would be reported as loaded textures");
         }
         var _loc4_:Array = mOverrideAssetFiles[biomeKey] as Array;
         var _loc10_:Boolean = _loc4_ != null;
         if(_loc10_)
         {
            delete mOverrideAssetFiles[biomeKey];
         }
         else
         {
            _loc4_ = StarlingAssetMapper.getAssetFilesForBiome(biomeKey,false);
         }
         mLoadingAssetFiles[biomeKey] = _loc4_;
         var _loc12_:AnimAssetManager = newBundleManager();
         mBundleManagers[biomeKey] = _loc12_;
         var _loc5_:Array = StarlingAssetMapper.getPropManifestFilesForBiome(biomeKey,false);
         if(_loc5_.length > 0)
         {
            _loc2_ = new StarlingPropManifest();
            for each(var _loc7_:File in _loc5_)
            {
               _loc2_.load(_loc7_);
            }
            mPropManifests[biomeKey] = _loc2_;
         }
         for each(var _loc8_:File in _loc4_)
         {
            if(!_loc8_.exists)
            {
               reportLoadFailure(biomeKey,null,"missing file " + _loc8_.nativePath);
            }
            else if(_loc8_.isDirectory)
            {
               _loc11_ = _loc8_.getDirectoryListing();
               _loc13_ = [];
               _loc3_ = _loc10_ && skipsRootLabelledClipFolders ? rootClipLabels(_loc8_) : null;
               for each(var _loc9_:File in _loc11_)
               {
                  if(!(_loc3_ != null && Boolean(_loc9_.isDirectory) && _loc3_[_loc9_.name]))
                  {
                     if(_loc9_.name != "flattened_registration.json" && (_loc10_ || !_loc9_.isDirectory))
                     {
                        _loc13_.push(_loc9_);
                     }
                  }
               }
               if(_loc13_.length > 0)
               {
                  enqueueAtScale(_loc13_,_loc10_ ? 1 : scaleForFolder(_loc8_),_loc12_);
               }
            }
            else
            {
               _loc12_.enqueue(_loc8_);
            }
         }
         mStartedBundles.push({
            "key":biomeKey,
            "bundle":_loc12_
         });
      }
      
      protected function queuedAssetCount(bundle:AnimAssetManager) : int
      {
         return bundle.numQueuedAssets;
      }
      
      protected function loadBundle(biomeKey:String, bundle:AnimAssetManager) : void
      {
         mLoadingProgress[biomeKey] = 0;
         bundle.loadQueue(function():void
         {
            onBundleLoaded(biomeKey);
         },function(param1:String, param2:AssetReference):void
         {
            reportLoadFailure(biomeKey,param2,param1);
         },function(param1:Number):void
         {
            if(mLoadingProgress[biomeKey] != null)
            {
               mLoadingProgress[biomeKey] = param1;
            }
         });
      }
      
      private function get skipsRootLabelledClipFolders() : Boolean
      {
         return mFacade.featureFlags != null && mFacade.featureFlags.getFlagValue("skip-root-labelled-clip-folders");
      }
      
      private function reportLoadFailure(biomeKey:String, asset:AssetReference, error:String) : void
      {
         var _loc5_:Error = null;
         var _loc6_:String = "Starling bundle " + biomeKey + " failed to load";
         if(asset == null && error != null && (error.indexOf(_loc6_) == 0 || error.indexOf("Out of graphics resources. Please restart the game.") == 0))
         {
            _loc5_ = new Error(error);
            _loc5_.name = "LOGGED Error";
            throw _loc5_;
         }
         var _loc4_:String = asset == null ? "" : " asset " + asset.name + (asset.url ? " (" + asset.url + ")" : "");
         var _loc7_:String = _loc6_ + _loc4_ + ": " + error;
         if(error != null && error.indexOf("#3691") != -1)
         {
            Logger.warn(_loc7_);
            Logger.fatal("Out of graphics resources. Please restart the game." + describeGraphicsResources() + "\n" + _loc7_);
         }
         else
         {
            Logger.error(_loc7_);
         }
      }
      
      private function describeGraphicsResources() : String
      {
         var _loc4_:Number = NaN;
         var _loc1_:Number = NaN;
         var _loc2_:Number = NaN;
         try
         {
            _loc4_ = Math.round(videoMemoryBytes() / 1048576);
         }
         catch(e:*)
         {
         }
         try
         {
            _loc1_ = textureBudgetMiB();
         }
         catch(e:*)
         {
         }
         try
         {
            _loc2_ = loadedTextureCount();
         }
         catch(e:*)
         {
         }
         var _loc3_:Array = [];
         if(_loc4_ > 0)
         {
            _loc3_.push("video memory: " + withThousands(_loc4_) + (_loc1_ > 0 ? " / " + withThousands(_loc1_) + " MiB" : " MiB in use"));
         }
         if(_loc2_ >= 0)
         {
            _loc3_.push("textures: " + withThousands(_loc2_) + " loaded");
         }
         return _loc3_.length > 0 ? " (" + _loc3_.join("; ") + ")" : "";
      }
      
      protected function videoMemoryBytes() : Number
      {
         var _loc1_:Object = Starling.context;
         return _loc1_ != null && "totalGPUMemory" in _loc1_ ? Number(_loc1_["totalGPUMemory"]) : NaN;
      }
      
      protected function textureBudgetMiB() : Number
      {
         return NativeApplication.nativeApplication.runtimeVersion.indexOf("32.") == 0 ? 1792 : NaN;
      }
      
      protected function loadedTextureCount() : int
      {
         if(mStarlingAssetManager == null)
         {
            return -1;
         }
         var _loc1_:int = int(mStarlingAssetManager.getAssetNames("texture","",false).length);
         for each(var _loc2_:AnimAssetManager in mBundleManagers)
         {
            _loc1_ += _loc2_.getAssetNames("texture","",false).length;
         }
         return _loc1_;
      }
      
      private function isStaleAtSwitch(key:String, switchGeneration:int) : Boolean
      {
         if(isKeptResident(key))
         {
            return false;
         }
         var _loc3_:Boolean = key == mCurrentFloorBiome || key.indexOf(getPropKey(mCurrentFloorBiome,"")) == 0;
         return mKeyLastUsed[key] < (_loc3_ ? switchGeneration : switchGeneration - 1);
      }
      
      private function evictStaleBundles(newFloorBiome:String, switchGeneration:int) : void
      {
         var _loc3_:Boolean = false;
         var _loc4_:Array = [];
         for(var _loc5_:String in mLoadedBiomeKeys)
         {
            _loc3_ = _loc5_ == StarlingAssetMapper.getPropsOnlyKey(newFloorBiome) && mKeyLastUsed[_loc5_] < switchGeneration;
            if(_loc5_ != newFloorBiome && mPendingBiomeKeys.indexOf(_loc5_) == -1 && (_loc3_ || isStaleAtSwitch(_loc5_,switchGeneration)))
            {
               _loc4_.push(_loc5_);
            }
         }
         disposeBundles(_loc4_);
      }
      
      public function queueResidentStarlingAssetsForPath(assetPath:String, onComplete:Function = null) : void
      {
         var _loc3_:String = StarlingAssetMapper.getActorAtlasFile(assetPath) != null ? StarlingAssetMapper.getActorAtlasKeyFromPath(assetPath) : StarlingAssetMapper.getPropLibraryKey(assetPath,mRequestedFloorBiome);
         keepStarlingKeyResident(_loc3_);
         queueStarlingAssetsForPath(assetPath,onComplete);
      }
      
      public function keepStarlingKeyResident(key:String) : void
      {
         mKeptResidentKeys[key] = true;
      }
      
      private function isKeptResident(key:String) : Boolean
      {
         return key == "shared" || mKeptResidentKeys[key];
      }
      
      public function markStarlingKeyUsed(key:String) : void
      {
         if(mLoadedBiomeKeys[key])
         {
            mKeyLastUsed[key] = mFloorGeneration;
         }
      }
      
      public function beginEntry() : void
      {
         mFloorGeneration = mFloorGeneration + 1;
         mEntryBegun = true;
         var _loc2_:Array = [];
         for each(var _loc3_:String in mPendingBiomeKeys)
         {
            if(mBackgroundKeys[_loc3_] && mKeyLastUsed[_loc3_] < mFloorGeneration)
            {
               _loc2_.push(_loc3_);
            }
         }
         for each(var _loc1_:String in _loc2_)
         {
            mPendingBiomeKeys.splice(mPendingBiomeKeys.indexOf(_loc1_),1);
            dropBackground(_loc1_);
            delete mOverrideAssetFiles[_loc1_];
            delete mKeyLastUsed[_loc1_];
            flushBiomeKeyCallbacks(_loc1_);
         }
      }
      
      public function endEntry() : void
      {
         mEntryBegun = false;
      }
      
      public function get isEntryFloorPending() : Boolean
      {
         return mEntryBegun;
      }
      
      public function get floorGeneration() : int
      {
         return mFloorGeneration;
      }
      
      public function releaseBundlesUnusedSince(generation:int) : void
      {
         if(mRequestedFloorBiome != mCurrentFloorBiome)
         {
            return;
         }
         var _loc2_:Array = [];
         for(var _loc3_:String in mLoadedBiomeKeys)
         {
            if(_loc3_ != mCurrentFloorBiome && !isKeptResident(_loc3_) && mBundleManagers[_loc3_] != null && _loc3_ in mKeyLastUsed && mKeyLastUsed[_loc3_] < generation && !mFloorRequestKeys[_loc3_] && mPendingBiomeKeys.indexOf(_loc3_) == -1 && mLoadingBiomeKeys.indexOf(_loc3_) == -1)
            {
               _loc2_.push(_loc3_);
            }
         }
         disposeBundles(_loc2_);
      }
      
      private function disposeBundles(keys:Array) : void
      {
         for each(var _loc2_:String in keys)
         {
            disposeBundle(_loc2_);
         }
         for each(var _loc3_:String in mCallbackKeyOrder.concat())
         {
            if(keys.indexOf(_loc3_) != -1)
            {
               flushBiomeKeyCallbacks(_loc3_);
            }
         }
      }
      
      private function disposeBundle(biomeKey:String) : void
      {
         if(mBundleManagers[biomeKey] != null)
         {
            unindexBundleAnimations(biomeKey);
            mStarlingAssetManager.removeAssetManager(biomeKey);
            mStarlingPurgeCount = mStarlingPurgeCount + 1;
         }
         delete mBundleManagers[biomeKey];
         delete mLoadedBiomeKeys[biomeKey];
         delete mPropManifests[biomeKey];
         delete mKeyLastUsed[biomeKey];
      }
      
      private function publishBundle(biomeKey:String) : void
      {
         var _loc2_:AnimAssetManager = mBundleManagers[biomeKey];
         if(_loc2_ == null)
         {
            return;
         }
         mStarlingAssetManager.addAsset(biomeKey,_loc2_);
         indexBundleAnimations(biomeKey,_loc2_);
      }
      
      private function indexBundleAnimations(bundleKey:String, bundle:AnimAssetManager) : void
      {
         var _loc5_:AnimationAtlas = null;
         var _loc6_:Vector.<String> = bundle.getAnimationAtlasNames();
         var _loc4_:Vector.<String> = new Vector.<String>();
         var _loc7_:Vector.<String> = new Vector.<String>();
         for each(var _loc3_:String in _loc6_)
         {
            _loc5_ = bundle.getAnimationAtlas(_loc3_);
            _loc5_.getAnimationNames("",_loc4_);
            _loc5_.getClipLabels(_loc7_);
         }
         addOwner(mAnimationOwners,_loc4_,bundleKey);
         mBundleAnimationNames[bundleKey] = _loc4_;
         addOwner(mLabelOwners,_loc7_,bundleKey);
         mBundleLabelNames[bundleKey] = _loc7_;
         addOwner(mAtlasOwners,_loc6_,bundleKey);
         mBundleAtlasNames[bundleKey] = _loc6_;
      }
      
      private function unindexBundleAnimations(bundleKey:String) : void
      {
         removeOwner(mAnimationOwners,mBundleAnimationNames[bundleKey],bundleKey);
         delete mBundleAnimationNames[bundleKey];
         removeOwner(mLabelOwners,mBundleLabelNames[bundleKey],bundleKey);
         delete mBundleLabelNames[bundleKey];
         removeOwner(mAtlasOwners,mBundleAtlasNames[bundleKey],bundleKey);
         delete mBundleAtlasNames[bundleKey];
      }
      
      protected function onBundleLoaded(biomeKey:String) : void
      {
         publishBundle(biomeKey);
         onBiomeLoadComplete(biomeKey);
      }
      
      protected function onBiomeLoadComplete(biomeKey:String) : void
      {
         var _loc6_:int = 0;
         if(!mBackgroundKeys[biomeKey])
         {
            mStarlingBundlesLoaded = mStarlingBundlesLoaded + 1;
         }
         dropBackground(biomeKey);
         delete mLoadingProgress[biomeKey];
         delete mFloorKeysLoading[biomeKey];
         if(biomeKey in mBundleConnections)
         {
            mConnectionsInUse -= mBundleConnections[biomeKey];
            delete mBundleConnections[biomeKey];
         }
         mLoadedBiomeKeys[biomeKey] = true;
         delete mLoadingAssetFiles[biomeKey];
         var _loc4_:int = mLoadingBiomeKeys.indexOf(biomeKey);
         if(_loc4_ != -1)
         {
            mLoadingBiomeKeys.splice(_loc4_,1);
         }
         if(mFloorRequestKeys[biomeKey] && mPendingBiomeKeys.indexOf(biomeKey) == -1)
         {
            enqueuePendingKey(biomeKey);
         }
         mIsDrainingCompletion = true;
         var _loc2_:String = "shared";
         var _loc7_:Boolean = isSharedUnresolved();
         var _loc5_:Array = [];
         for each(var _loc8_:String in mCallbackKeyOrder)
         {
            if(mLoadedBiomeKeys[_loc8_] && !mFloorRequestKeys[_loc8_] && (_loc8_ == _loc2_ || !_loc7_))
            {
               _loc5_.push(_loc8_);
            }
         }
         for each(var _loc3_:String in _loc5_)
         {
            if(!mFloorRequestKeys[_loc3_])
            {
               _loc6_ = mPendingBiomeKeys.indexOf(_loc3_);
               if(_loc6_ != -1)
               {
                  mPendingBiomeKeys.splice(_loc6_,1);
               }
               flushBiomeKeyCallbacks(_loc3_);
            }
         }
         mIsDrainingCompletion = false;
         startPendingLoads();
      }
      
      private function flushBiomeKeyCallbacks(biomeKey:String) : void
      {
         var _loc2_:Vector.<Function> = mBiomeKeyCallbacks[biomeKey];
         if(_loc2_ == null)
         {
            return;
         }
         delete mBiomeKeyCallbacks[biomeKey];
         mCallbackKeyOrder.splice(mCallbackKeyOrder.indexOf(biomeKey),1);
         for each(var _loc3_:Function in _loc2_)
         {
            try
            {
               _loc3_();
            }
            catch(e:Error)
            {
               Logger.error("AssetLoadingComponent.flushBiomeKeyCallbacks: ready callback threw: " + e.message);
            }
         }
      }
      
      public function get starlingLoadProgress() : Number
      {
         var _loc1_:Number = 0;
         for(var _loc2_:String in mLoadingProgress)
         {
            if(!mBackgroundKeys[_loc2_])
            {
               _loc1_ += mLoadingProgress[_loc2_];
            }
         }
         return _loc1_;
      }
      
      public function get activeStarlingBundleCount() : uint
      {
         return loadingBlockingCount();
      }
      
      public function get pendingStarlingBundleCount() : uint
      {
         return pendingBlockingCount();
      }
      
      public function get starlingBundlesLoaded() : uint
      {
         return mStarlingBundlesLoaded;
      }
      
      public function getTextureFromAssetManager(textureName:String, libraryKey:String = null) : Texture
      {
         if(mStarlingAssetManager == null)
         {
            return null;
         }
         var _loc3_:Texture = null;
         if(libraryKey != null)
         {
            _loc3_ = getBundleTexture(libraryKey,textureName);
            if(_loc3_ == null)
            {
               _loc3_ = getBundleTexture(StarlingAssetMapper.getPropsOnlyKey(libraryKey),textureName);
            }
            if(_loc3_ == null && libraryKey != "shared")
            {
               _loc3_ = getBundleTexture("shared",textureName);
            }
         }
         if(_loc3_ == null)
         {
            _loc3_ = getPublishedTexture(textureName);
         }
         if(_loc3_ != null && !MemoryTracker.isTracked(_loc3_))
         {
            MemoryTracker.track(_loc3_,"AssetLoadingComponent - Texture: " + textureName,"starling");
         }
         return _loc3_;
      }
      
      private function getBundleTexture(bundleKey:String, textureName:String) : Texture
      {
         var _loc4_:AnimAssetManager = mLoadedBiomeKeys[bundleKey] ? mBundleManagers[bundleKey] : null;
         var _loc3_:Texture = _loc4_ != null ? _loc4_.getTexture(textureName) : null;
         if(_loc3_ != null)
         {
            markStarlingKeyUsed(bundleKey);
         }
         return _loc3_;
      }
      
      private function getPublishedTexture(textureName:String) : Texture
      {
         var _loc2_:Texture = null;
         for(var _loc3_:String in mBundleManagers)
         {
            _loc2_ = getBundleTexture(_loc3_,textureName);
            if(_loc2_ != null)
            {
               return _loc2_;
            }
         }
         return mStarlingAssetManager.getTexture(textureName);
      }
      
      private function enqueueAtScale(files:Array, scale:Number, bundle:AnimAssetManager) : void
      {
         if(scale <= 0 || scale == 1)
         {
            bundle.enqueue(files);
            return;
         }
         for each(var _loc4_:File in files)
         {
            if(!_loc4_.isHidden)
            {
               if(_loc4_.isDirectory)
               {
                  bundle.enqueue(_loc4_);
               }
               else
               {
                  bundle.enqueueSingle(_loc4_,null,new TextureOptions(scale));
               }
            }
         }
      }
      
      public function getPropRecipeParts(assetClassName:String, libraryKey:String = null) : Array
      {
         var _loc3_:Array = null;
         if(libraryKey != null)
         {
            _loc3_ = getManifestParts(libraryKey,assetClassName);
            if(_loc3_ == null)
            {
               _loc3_ = getManifestParts(StarlingAssetMapper.getPropsOnlyKey(libraryKey),assetClassName);
            }
            if(_loc3_ == null && libraryKey != "shared")
            {
               _loc3_ = getManifestParts("shared",assetClassName);
            }
         }
         for(var _loc4_:String in mPropManifests)
         {
            if(_loc3_ != null)
            {
               break;
            }
            _loc3_ = getManifestParts(_loc4_,assetClassName);
         }
         return _loc3_;
      }
      
      private function getManifestParts(bundleKey:String, assetClassName:String) : Array
      {
         var _loc3_:StarlingPropManifest = mLoadedBiomeKeys[bundleKey] ? mPropManifests[bundleKey] : null;
         return _loc3_ != null ? _loc3_.getParts(assetClassName) : null;
      }
      
      public function createAnimationFromAssetManager(animationName:String, libraryKey:String = null) : Animation
      {
         var _loc3_:AnimAssetManager = findAnimationBundle(animationName,libraryKey,true);
         if(_loc3_ == null)
         {
            return null;
         }
         var _loc4_:Animation = _loc3_.createAnimation(animationName);
         if(_loc4_ != null)
         {
            MemoryTracker.track(_loc4_,"AssetLoadingComponent - Animation: " + animationName,"starling");
         }
         return _loc4_;
      }
      
      private function findAnimationBundle(animationName:String, libraryKey:String, binds:Boolean = false) : AnimAssetManager
      {
         if(mStarlingAssetManager == null)
         {
            return null;
         }
         var _loc6_:Array = [mAnimationOwners[animationName],mLabelOwners[animationName],mAtlasOwners[animationName]];
         var _loc9_:Vector.<String> = _loc6_[0] || _loc6_[1] || _loc6_[2];
         if(_loc9_ == null)
         {
            return null;
         }
         var _loc10_:String = _loc9_[0];
         var _loc5_:String = null;
         if(libraryKey != null)
         {
            for each(var _loc8_:String in [libraryKey,"shared"])
            {
               for each(var _loc7_:Vector.<String> in _loc6_)
               {
                  _loc5_ = _loc7_ != null ? findLibraryOwner(_loc7_,_loc8_) : null;
                  if(_loc5_ != null)
                  {
                     break;
                  }
               }
               if(_loc5_ != null)
               {
                  _loc10_ = _loc5_;
                  break;
               }
            }
         }
         if(_loc5_ == null)
         {
            for each(var _loc4_:String in _loc9_)
            {
               if(mKeyLastUsed[_loc4_] > mKeyLastUsed[_loc10_])
               {
                  _loc10_ = _loc4_;
               }
            }
         }
         if(binds)
         {
            markStarlingKeyUsed(_loc10_);
         }
         return mBundleManagers[_loc10_];
      }
      
      public function createAnimationFromAtlas(atlasName:String, animationName:String) : Animation
      {
         var _loc3_:String = findAtlasOwner(atlasName);
         var _loc4_:Animation = _loc3_ != null ? AnimAssetManager(mBundleManagers[_loc3_]).createAnimationInAtlas(atlasName,animationName) : null;
         if(_loc4_ != null)
         {
            markStarlingKeyUsed(_loc3_);
            MemoryTracker.track(_loc4_,"AssetLoadingComponent - Animation: " + animationName + " @ " + atlasName,"starling");
         }
         return _loc4_;
      }
      
      private function findAtlasOwner(atlasName:String) : String
      {
         var _loc4_:AnimAssetManager = null;
         if(mStarlingAssetManager == null || atlasName == null)
         {
            return null;
         }
         var _loc3_:String = null;
         for each(var _loc2_:String in mAtlasOwners[atlasName])
         {
            _loc4_ = mBundleManagers[_loc2_];
            if(_loc4_ != null && _loc4_.getAnimationAtlas(atlasName) != null && (_loc3_ == null || mKeyLastUsed[_loc2_] > mKeyLastUsed[_loc3_]))
            {
               _loc3_ = _loc2_;
            }
         }
         return _loc3_;
      }
      
      public function hasAnimationInAssetManager(animationName:String) : Boolean
      {
         return findAnimationBundle(animationName,null) != null;
      }
      
      public function isPackedAtlasInAssetManager(atlasName:String) : Boolean
      {
         var _loc2_:String = findAtlasOwner(atlasName);
         return _loc2_ != null && Boolean(AnimAssetManager(mBundleManagers[_loc2_]).isPackedAtlas(atlasName));
      }
      
      public function getAvailableAnimations() : Vector.<String>
      {
         var _loc1_:Vector.<String> = new Vector.<String>();
         if(mStarlingAssetManager != null)
         {
            mStarlingAssetManager.getAnimationAtlasNames("",_loc1_);
         }
         return _loc1_;
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
         if(mPendingDownloads != null)
         {
            _loc1_ = mPendingDownloads.iterator() as ISetIterator;
            while(_loc1_.hasNext())
            {
               removeLoader(_loc1_.next() as AssetLoadingTracker);
               _loc1_ = mPendingDownloads.iterator() as ISetIterator;
            }
            mPendingDownloads = null;
         }
         super.destroy();
      }
      
      public function clearAllActive() : void
      {
         var _loc1_:ISetIterator = null;
         mTransitionToEmptyFunction = null;
         if(mPendingDownloads != null)
         {
            _loc1_ = mPendingDownloads.iterator() as ISetIterator;
            while(_loc1_.hasNext())
            {
               removeLoader(_loc1_.next() as AssetLoadingTracker);
               _loc1_ = mPendingDownloads.iterator() as ISetIterator;
            }
         }
      }
      
      public function removeLoader(assetLoadingTracker:AssetLoadingTracker) : void
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

