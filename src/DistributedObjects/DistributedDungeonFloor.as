package DistributedObjects
{
   import Account.ItemInfo;
   import Actor.ActorGameObject;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Event.EventComponent;
   import Brain.Event.EventListeners;
   import Brain.GameObject.GameObject;
   import Brain.Logger.Logger;
   import Brain.Sound.SoundAsset;
   import Brain.Sound.SoundHandle;
   import Brain.Starling.SwfConverter.BakeScheduler;
   import Brain.Utils.MemoryTracker;
   import Brain.WorkLoop.DoLater;
   import Collections.IIterator;
   import Collections.IMapIterator;
   import Collections.ISetIterator;
   import Collections.Map;
   import Collections.Set;
   import DBGlobals.DBGlobal;
   import Doobers.DooberGameObject;
   import Dungeon.DungeonFloorFactory;
   import Dungeon.RectangleNavCollider;
   import Dungeon.Tile;
   import Dungeon.TileGrid;
   import Effects.EffectManager;
   import Events.ActorLifetimeEvent;
   import Facade.DBFacade;
   import Facade.LoadingPrewarm;
   import Facade.TrickleCacheLoader;
   import Floor.FloorMessageView;
   import Floor.FloorObject;
   import GameMasterDictionary.GMColiseumTier;
   import GameMasterDictionary.GMMapNode;
   import GeneratedCode.DistributedDungeonFloorNetworkComponent;
   import GeneratedCode.DungeonTileUsage;
   import GeneratedCode.IDistributedDungeonFloor;
   import Projectile.ProjectileGameObject;
   import Sound.DBSoundComponent;
   import Sound.DBSoundManager;
   import StateMachine.MainStateMachine.LoadingScreenState;
   import SteamAchievements.SteamAPINames;
   import UI.CutsceneOverlay;
   import UI.CutsceneVideo;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import flash.media.Sound;
   import flash.media.SoundLoaderContext;
   import flash.media.SoundTransform;
   import flash.net.URLRequest;
   import flash.utils.Dictionary;
   
   public class DistributedDungeonFloor extends Floor implements IDistributedDungeonFloor
   {
      
      private static const MUSIC_BUFFER:Number = 1000;
      
      protected var mTileNetworkComponents:Vector.<DungeonTileUsage>;
      
      protected var mTileLibraryPath:String = "uninitialized";
      
      protected var mDungeonFloorFactory:DungeonFloorFactory;
      
      protected var mTileGrid:TileGrid;
      
      private var mActiveOwnerAvatar:HeroGameObjectOwner;
      
      private var mRemoteHeroes:Map;
      
      private var mRemoteActors:Map;
      
      private var mDoobers:Dictionary;
      
      private var mProjectiles:Dictionary;
      
      private var mBuildPropReady:Boolean = false;
      
      private var mPostGenerate:Boolean;
      
      private var mFloorObjectsAwaitingDungeonFloor:Set;
      
      private var mColiseumTierConstant:String;
      
      private var mCurrentMapNodeId:uint;
      
      private var mMapNode:GMMapNode;
      
      private var mEffectManager:EffectManager;
      
      private var mBaseLining:uint;
      
      private var mIntroMovieSwfFilePath:String;
      
      private var mIntroMovieAssetClassName:String;
      
      private var mAssetLoadingComponent:AssetLoadingComponent;
      
      private var mCurrentFloorNum:uint;
      
      private var mEntryAtlasesQueued:Boolean = false;
      
      private var mEntryPropAtlasesQueued:Boolean = false;
      
      private var mEntryGeneration:int;
      
      private var mEntryReleaseChecked:Boolean = false;
      
      private var mPrewarm:LoadingPrewarm;
      
      private var mEntryReleaseEvents:EventComponent;
      
      private var mFloorTilesRequested:Boolean = false;
      
      private var mHeroEntryWanted:Boolean = false;
      
      private var mAwaitingStarlingAssets:Boolean = false;
      
      private var mEntryStarted:Boolean = false;
      
      private var mIntroMovieAsset:SwfAsset;
      
      private var mIntroOverlay:CutsceneOverlay;
      
      private var mIntroVideo:CutsceneVideo;
      
      private var mViewHold:FloorViewHold;
      
      protected var mDBSoundComponent:DBSoundComponent;
      
      private var mMusicTestSoundHandle:SoundHandle;
      
      private var mBgMusic:Sound;
      
      public function DistributedDungeonFloor(dbFacade:DBFacade, remoteId:uint)
      {
         Logger.debug("New  DistributedDungeonFloor******************************");
         mPostGenerate = false;
         super(dbFacade,remoteId);
         mRemoteHeroes = new Map();
         mRemoteActors = new Map();
         mDoobers = new Dictionary(true);
         mProjectiles = new Dictionary(true);
         mFloorObjectsAwaitingDungeonFloor = new Set();
         mEffectManager = new EffectManager(mDBFacade);
         MemoryTracker.track(mEffectManager,"EffectManager - created in DistributedDungeonFloor.constructor()");
         mBaseLining = 0;
         mDBSoundComponent = new DBSoundComponent(mDBFacade);
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
      }
      
      public function set coliseumTierConstant(val:String) : void
      {
         mColiseumTierConstant = val;
      }
      
      public function set mapNodeId(val:uint) : void
      {
         mCurrentMapNodeId = val;
      }
      
      override public function get isInfiniteDungeon() : Boolean
      {
         return mMapNode.IsInfiniteDungeon;
      }
      
      public function getActor(id:uint) : ActorGameObject
      {
         if(mActiveOwnerAvatar && mActiveOwnerAvatar.id == id)
         {
            return mActiveOwnerAvatar;
         }
         var _loc2_:ActorGameObject = mRemoteActors.itemFor(id);
         if(_loc2_)
         {
            return _loc2_;
         }
         _loc2_ = mRemoteHeroes.itemFor(id);
         if(_loc2_)
         {
            return _loc2_;
         }
         return null;
      }
      
      public function get effectManager() : EffectManager
      {
         return mEffectManager;
      }
      
      public function registerProjectile(projectile:ProjectileGameObject) : void
      {
         if(mProjectiles)
         {
            mProjectiles[projectile] = true;
         }
      }
      
      public function unregisterProjectile(projectile:ProjectileGameObject) : void
      {
         if(mProjectiles)
         {
            delete mProjectiles[projectile];
         }
      }
      
      public function get numHeroes() : uint
      {
         return 1 + mRemoteHeroes.size;
      }
      
      public function get remoteHeroes() : Map
      {
         return mRemoteHeroes;
      }
      
      public function get remoteActors() : Map
      {
         return mRemoteActors;
      }
      
      public function set remoteHeroes(value:Map) : void
      {
         mRemoteHeroes = value;
      }
      
      public function get activeOwnerAvatar() : HeroGameObjectOwner
      {
         return mActiveOwnerAvatar;
      }
      
      public function set activeOwnerAvatar(value:HeroGameObjectOwner) : void
      {
         mActiveOwnerAvatar = value;
      }
      
      override public function getCurrentFloorNum() : uint
      {
         return mCurrentFloorNum % 1000 + 1;
      }
      
      override public function getMaxFloorNum() : uint
      {
         return uint(mCurrentFloorNum / 1000);
      }
      
      public function get tileGrid() : TileGrid
      {
         return mTileGrid;
      }
      
      public function setNetworkComponentDistributedDungeonFloor(iface:DistributedDungeonFloorNetworkComponent) : void
      {
      }
      
      public function get dungeonFloorFactory() : DungeonFloorFactory
      {
         return mDungeonFloorFactory;
      }
      
      public function postGenerate() : void
      {
         mPostGenerate = true;
         BakeScheduler.floorLoadStarted();
         mDungeonFloorFactory = new DungeonFloorFactory(this,initGridCallback,mDBFacade,mTileLibraryPath);
         MemoryTracker.track(mDungeonFloorFactory,"DungeonFloorFactory - created in DistributedDungeonFloor.postGenerate()");
         buildTiles(mTileNetworkComponents,true);
         mMapNode = mDBFacade.gameMaster.getMapNode(mCurrentMapNodeId);
         if(mMapNode != null)
         {
            mDBFacade.steamAchievementsHelper.checkHighestUltimateRampageFloorAchieved(mMapNode,getCurrentFloorNum());
            mDBFacade.steamAchievementsHelper.updateMapsAtFloor25Stat(mMapNode);
         }
         buildFloorEndingGui();
         loadIntroMovie();
         var _loc1_:LoadingScreenState = mDBFacade.mainStateMachine.currentState as LoadingScreenState;
         if(_loc1_ != null && _loc1_.holdsHeroEntry)
         {
            mEventComponent.addListener("LOADING_SCREEN_HERO_ENTRY_RELEASED",onHeroEntryReleased);
         }
         else
         {
            if(_loc1_ == null)
            {
               holdViewForFloorChange();
            }
            startEntry();
         }
      }
      
      private function holdViewForFloorChange() : void
      {
         mViewHold = new FloorViewHold(function(param1:Number, param2:Function):Object
         {
            return mDBFacade.realClockWorkManager.doLater(param1,param2,false,"DistributedDungeonFloor.viewHold");
         },function(param1:Object):void
         {
            mDBFacade.realClockWorkManager.removeDoLater(param1 as DoLater);
         },onViewHoldReleased);
         mViewHold.begin();
         mSceneGraphComponent.fadeOut(0);
      }
      
      private function onViewHoldReleased(timedOut:Boolean) : void
      {
         if(timedOut)
         {
            Logger.warn("DistributedDungeonFloor: floor change view hold timed out after 15 s (heroReady=" + mViewHold.heroIsReady + " closure=" + mViewHold.closureHasArrived + "); fading in anyway");
         }
         mSceneGraphComponent.fadeIn(1);
         revealFloor();
      }
      
      override protected function heroOwnerReady() : void
      {
         if(mViewHold != null && mViewHold.holding)
         {
            mViewHold.heroReady();
         }
         else
         {
            super.heroOwnerReady();
         }
      }
      
      override public function InterestClosure() : void
      {
         super.InterestClosure();
         if(mViewHold)
         {
            mViewHold.closureArrived();
         }
      }
      
      private function onHeroEntryReleased(e:Event) : void
      {
         mEventComponent.removeListener("LOADING_SCREEN_HERO_ENTRY_RELEASED");
         startEntry();
      }
      
      private function startEntry() : void
      {
         mEntryStarted = true;
         if(mViewHold == null || !mViewHold.holding)
         {
            mSceneGraphComponent.fadeIn(1);
         }
         playMusic();
         if(mIntroMovieSwfFilePath && mIntroMovieAssetClassName)
         {
            playIntroMovie();
         }
         else
         {
            requestEntryHero();
         }
      }
      
      override public function victory() : void
      {
         logDungeonCompletion();
         super.victory();
         var _loc1_:String = mDBFacade.dbAccountInfo.activeAvatarInfo.gmHero.Constant;
         var _loc2_:Vector.<ItemInfo> = mDBFacade.dbAccountInfo.inventoryInfo.getEquipedItemsOnAvatar(mDBFacade.dbAccountInfo.activeAvatarInfo.id);
         mDBFacade.steamAchievementsHelper.unlockBossChallengeWithUncommonWeapon(mMapNode,_loc1_,_loc2_);
         mDBFacade.steamAchievementsHelper.unlockDarkBarrowsAsVampireHunter(_loc1_,mMapNode.Constant);
         if(mMapNode.NodeType == GMMapNode.BOSS_NODE_TYPE)
         {
            mDBFacade.steamAchievementsHelper.unlockAchievement(SteamAPINames.getUnlockFloorCompletedAPIName(mMapNode.Constant));
         }
         mDBFacade.steamAchievementsHelper.unlockFinishFloorWithThreeTeammatesDowned(mRemoteHeroes);
         mDBFacade.steamAchievementsHelper.addValueToStatInt(1,"DUNGEONS_COMPLETED");
         var _loc3_:Map = mDBFacade.dbAccountInfo.friendInfos;
         mDBFacade.steamAchievementsHelper.finishDungeonWithFriends(mRemoteHeroes,_loc3_);
      }
      
      override public function defeat() : void
      {
         logDungeonCompletion();
         super.defeat();
      }
      
      private function formatHeroInfo(hero:HeroGameObject) : String
      {
         return "\"" + hero.screenName + "\" AccountId=" + hero.playerID + " Avatar=\"" + hero.gMHero.Name + "\" Skin=\"" + hero.gmSkin.Name + "\"";
      }
      
      private function formatFellowPlayers(prefix:String) : String
      {
         if(mRemoteHeroes.size == 0)
         {
            return "";
         }
         var _loc2_:String = prefix;
         var _loc3_:IIterator = mRemoteHeroes.iterator();
         var _loc4_:Boolean = true;
         while(_loc3_.hasNext())
         {
            if(!_loc4_)
            {
               _loc2_ += ", ";
            }
            _loc2_ += formatHeroInfo(_loc3_.next() as HeroGameObject);
            _loc4_ = false;
         }
         return _loc2_;
      }
      
      private function getFloorString() : String
      {
         var _loc1_:GMColiseumTier = mDBFacade.gameMaster.coliseumTierByConstant.itemFor(mMapNode.TierRank);
         return "floor " + getCurrentFloorNum() + "/" + _loc1_.TotalFloors;
      }
      
      private function logWelcomeMessage() : void
      {
         if(!mActiveOwnerAvatar || !mMapNode)
         {
            return;
         }
         Logger.debugch("PlayerInfo","Welcome (" + mActiveOwnerAvatar.playerID + ") to the dungeon \"" + mMapNode.Name + "\" (" + mCurrentMapNodeId + ") " + getFloorString() + " SessionId=" + mDBFacade.sessionInfoString);
      }
      
      private function logPlayerJoined(hero:HeroGameObject) : void
      {
         Logger.debugch("PlayerInfo",formatHeroInfo(hero) + " joined floor " + getCurrentFloorNum() + ".");
      }
      
      private function logPlayerLeft(hero:HeroGameObject) : void
      {
         if(!isAlive())
         {
            return;
         }
         Logger.debugch("PlayerInfo",formatHeroInfo(hero) + " left floor " + getCurrentFloorNum() + ".");
      }
      
      private function logDungeonCompletion() : void
      {
         if(!mActiveOwnerAvatar || !mMapNode)
         {
            return;
         }
         Logger.debugch("PlayerInfo","You (" + mActiveOwnerAvatar.playerID + ") finished the dungeon \"" + mMapNode.Name + "\" (" + mCurrentMapNodeId + ") " + getFloorString() + " SessionId=" + mDBFacade.sessionInfoString + formatFellowPlayers(", you were playing with "));
      }
      
      private function playMusic() : void
      {
         var _loc3_:URLRequest = null;
         var _loc2_:SoundLoaderContext = null;
         var _loc1_:GMColiseumTier = mDBFacade.gameMaster.coliseumTierByConstant.itemFor(mColiseumTierConstant);
         if(_loc1_ && _loc1_.MusicFilepath)
         {
            mBgMusic = new Sound();
            _loc3_ = new URLRequest(DBFacade.buildFullDownloadPath(_loc1_.MusicFilepath));
            _loc2_ = new SoundLoaderContext(1000,true);
            _loc2_.checkPolicyFile = true;
            mBgMusic.load(_loc3_,_loc2_);
            EventListeners.add(mBgMusic,"complete",onBgMusicLoaded);
            EventListeners.add(mBgMusic,"ioError",onBgMusicError);
            EventListeners.add(mBgMusic,"securityError",onBgMusicError);
         }
      }
      
      private function onBgMusicLoaded(e:Event) : void
      {
         if(mDBSoundComponent)
         {
            mDBSoundComponent.playStreamingMusic(mBgMusic);
         }
      }
      
      private function onBgMusicError(evt:Event) : void
      {
         Logger.error("BgMusic load error: " + evt.toString());
      }
      
      public function get coliseumTier() : GMColiseumTier
      {
         return mDBFacade.gameMaster.coliseumTierByConstant.itemFor(mColiseumTierConstant);
      }
      
      public function get completionXp() : uint
      {
         return mMapNode.CompletionXPBonus;
      }
      
      private function initGridCallback(tileGrid:TileGrid) : void
      {
         mTileGrid = tileGrid;
      }
      
      public function tileLibrary(tilegrp:String) : void
      {
         mTileLibraryPath = tilegrp;
      }
      
      public function set introMovieSwfFilePath(value:String) : void
      {
         Logger.debug("introMovie: swfFilePath: " + value);
         mIntroMovieSwfFilePath = value;
      }
      
      public function set introMovieAssetClassName(value:String) : void
      {
         Logger.debug("introMovie: assetClassName: " + value);
         mIntroMovieAssetClassName = value;
      }
      
      public function get currentFloorNum() : uint
      {
         return mCurrentFloorNum;
      }
      
      public function set currentFloorNum(value:uint) : void
      {
         Logger.debug("introMovie: assetClassName: " + value);
         mCurrentFloorNum = value;
      }
      
      private function loadIntroMovie() : void
      {
         if(mIntroMovieSwfFilePath && mIntroMovieAssetClassName)
         {
            mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath(mIntroMovieSwfFilePath),function(param1:SwfAsset):void
            {
               mIntroMovieAsset = param1;
               if(mEntryStarted)
               {
                  playIntroMovie();
               }
            });
         }
      }
      
      private function playIntroMovie() : void
      {
         var movieClass:Class;
         var movie:MovieClip;
         var dbSoundManager:DBSoundManager;
         var volume:SoundTransform;
         var stopMovie:Function;
         var onKeyDown:Function;
         var asset:SwfAsset = mIntroMovieAsset;
         if(asset == null)
         {
            return;
         }
         mIntroMovieAsset = null;
         movieClass = asset.getClass(mIntroMovieAssetClassName);
         movie = new movieClass();
         dbSoundManager = mDBFacade.soundManager as DBSoundManager;
         dbSoundManager.applyStoredVolumeSettings();
         volume = new SoundTransform(dbSoundManager.getDampenedVolumeScaleForCategory("music"));
         stopMovie = function(param1:Event = null):void
         {
            if(movie == null)
            {
               return;
            }
            if(movie.currentFrame == movie.totalFrames || param1 == null)
            {
               EventListeners.remove(mDBFacade.stageRef,"keyDown",onKeyDown);
               mDBFacade.removeRootDisplayObject(movie);
               EventListeners.remove(movie,"enterFrame",stopMovie);
               destroyIntroOverlay();
               destroyIntroVideo();
               if(mViewHold)
               {
                  mViewHold.introEnded();
               }
               requestEntryHero();
               movie.stop();
               mDBFacade.assetRepository.removeFromCache(asset);
               movie = null;
            }
         };
         mIntroVideo = new CutsceneVideo(mDBFacade.stageRef,movie,asset.root.loaderInfo.frameRate,DBFacade.buildFullDownloadPath(mIntroMovieSwfFilePath.replace(/\.swf$/i,"_1920x1080.mp4")),volume);
         mDBFacade.addRootDisplayObject(mIntroVideo.display);
         mDBFacade.addRootDisplayObject(movie);
         if(mViewHold)
         {
            mViewHold.introStarted();
         }
         EventListeners.add(movie,"enterFrame",stopMovie);
         movie.x = 972.5;
         movie.y = 320;
         mIntroOverlay = new CutsceneOverlay(mDBFacade,stopMovie,false);
         mDBFacade.addRootDisplayObject(mIntroOverlay.skipButton.root);
         mDBFacade.menuNavigationController.pushNewLayer("BOSS_INTRO_CINEMATIC",stopMovie,mIntroOverlay.skipButton);
         onKeyDown = function(param1:KeyboardEvent):void
         {
            if(param1.keyCode == 27)
            {
               stopMovie();
            }
         };
         EventListeners.add(mDBFacade.stageRef,"keyDown",onKeyDown);
      }
      
      private function destroyIntroOverlay() : void
      {
         if(mIntroOverlay == null)
         {
            return;
         }
         mDBFacade.menuNavigationController.removeLayer("BOSS_INTRO_CINEMATIC");
         mDBFacade.removeRootDisplayObject(mIntroOverlay.skipButton.root);
         mIntroOverlay.destroy();
         mIntroOverlay = null;
      }
      
      private function destroyIntroVideo() : void
      {
         if(mIntroVideo == null)
         {
            return;
         }
         mDBFacade.removeRootDisplayObject(mIntroVideo.display);
         mIntroVideo.destroy();
         mIntroVideo = null;
      }
      
      private function queueEntryAtlases() : void
      {
         var _loc2_:AssetLoadingComponent = mDBFacade.assetLoadingComponent;
         if(mEntryAtlasesQueued || _loc2_ == null)
         {
            return;
         }
         mEntryAtlasesQueued = true;
         mEntryGeneration = _loc2_.floorGeneration;
         var _loc1_:DistributedDungionArea = parentArea as DistributedDungionArea;
         for each(var _loc3_:String in TrickleCacheLoader.starlingAtlasPaths(mDBFacade,_loc1_ ? _loc1_.mCacheNpc : null))
         {
            _loc2_.queueStarlingAssetsForPath(_loc3_);
         }
         TrickleCacheLoader.queueBossAtlases(mDBFacade,_loc1_ ? _loc1_.mCacheNpc : null);
         queueEntryPropAtlases();
      }
      
      private function queueEntryPropAtlases() : void
      {
         var _loc3_:AssetLoadingComponent = mDBFacade.assetLoadingComponent;
         if(mEntryPropAtlasesQueued || !mEntryAtlasesQueued || !mFloorTilesRequested || _loc3_ == null)
         {
            return;
         }
         mEntryPropAtlasesQueued = true;
         var _loc1_:DistributedDungionArea = parentArea as DistributedDungionArea;
         var _loc4_:String = _loc3_.isEntryFloorPending ? null : _loc3_.requestedFloorBiome;
         var _loc2_:Object = TrickleCacheLoader.starlingPropAtlasClassNames(mDBFacade,_loc1_ ? _loc1_.mCacheNpc : null,_loc4_);
         for(var _loc5_:String in _loc2_)
         {
            _loc3_.queueStarlingAssetsForProps(_loc5_,_loc2_[_loc5_]);
         }
         releaseLastDungeonAtlases();
      }
      
      private function releaseLastDungeonAtlases() : void
      {
         var _loc1_:DistributedDungionArea = null;
         var _loc2_:AssetLoadingComponent = mDBFacade.assetLoadingComponent;
         if(mEntryReleaseChecked || !mEntryPropAtlasesQueued || _loc2_ == null)
         {
            return;
         }
         if(_loc2_.isStarlingLoadPending)
         {
            if(mEntryReleaseEvents == null)
            {
               mEntryReleaseEvents = new EventComponent(mDBFacade);
               mEntryReleaseEvents.addListener("StarlingAssetsReady",onEntryReleaseAssetsReady);
            }
            return;
         }
         mEntryReleaseChecked = true;
         stopEntryReleaseEvents();
         if(mDBFacade.mainStateMachine.currentState is LoadingScreenState)
         {
            _loc1_ = parentArea as DistributedDungionArea;
            mPrewarm = LoadingPrewarm.startLoadingAndRelease(mDBFacade,_loc1_ != null ? _loc1_.mCacheNpc : null,mEntryGeneration);
         }
      }
      
      private function onEntryReleaseAssetsReady(e:Event) : void
      {
         releaseLastDungeonAtlases();
      }
      
      private function stopEntryReleaseEvents() : void
      {
         if(mEntryReleaseEvents != null)
         {
            mEntryReleaseEvents.destroy();
            mEntryReleaseEvents = null;
         }
      }
      
      private function requestEntryHero() : void
      {
         mHeroEntryWanted = true;
         if(parentArea == null)
         {
            return;
         }
         if(!mFloorTilesRequested)
         {
            return;
         }
         var _loc1_:AssetLoadingComponent = mDBFacade.assetLoadingComponent;
         if(_loc1_ != null && _loc1_.isStarlingLoadPending)
         {
            if(!mAwaitingStarlingAssets)
            {
               mAwaitingStarlingAssets = true;
               mEventComponent.addListener("StarlingAssetsReady",onStarlingAssetsReady);
            }
            return;
         }
         releaseLastDungeonAtlases();
         if(mPrewarm != null && mPrewarm.running)
         {
            mPrewarm.hold(requestEntryHero);
            return;
         }
         mHeroEntryWanted = false;
         BakeScheduler.floorLoaded();
         mEventComponent.dispatchEvent(new Event("REQUEST_ENTRY_PLAYER_HERO"));
      }
      
      private function onStarlingAssetsReady(e:Event) : void
      {
         mAwaitingStarlingAssets = false;
         mEventComponent.removeListener("StarlingAssetsReady");
         requestEntryHero();
      }
      
      override public function SetParentArea(area:Area) : void
      {
         super.SetParentArea(area);
         queueEntryAtlases();
         if(mHeroEntryWanted)
         {
            requestEntryHero();
         }
      }
      
      public function show_text(textkey:String) : void
      {
         var _loc2_:FloorMessageView = new FloorMessageView(mDBFacade,textkey);
         MemoryTracker.track(_loc2_,"FloorMessageView - created in DistributedDungeonFloor.show_text()");
      }
      
      public function play_sound(sound:String) : void
      {
         mAssetLoadingComponent.getSoundAsset(DBFacade.buildFullDownloadPath(DBGlobal.SFX_PATH),sound,function(param1:SoundAsset):void
         {
            mDBSoundComponent.playOneShot(param1,"sfx");
         });
      }
      
      public function trigger_camera_zoom(zoom:Number) : void
      {
         mDBFacade.camera.tweenZoom(1,zoom,true);
      }
      
      public function trigger_camera_shake(shakeDuration:Number, shakeStrength:Number, shakeCount:uint) : void
      {
         mDBFacade.camera.shakeY(shakeDuration / 24,shakeStrength,shakeCount);
      }
      
      public function tiles(tiles:Vector.<DungeonTileUsage>) : void
      {
         var _loc3_:Vector.<DungeonTileUsage> = undefined;
         var _loc4_:uint = 0;
         var _loc2_:Boolean = false;
         var _loc5_:uint = 0;
         if(mPostGenerate)
         {
            _loc3_ = new Vector.<DungeonTileUsage>();
            _loc4_ = 0;
            while(_loc4_ < tiles.length)
            {
               _loc2_ = false;
               _loc5_ = 0;
               while(_loc5_ < mTileNetworkComponents.length)
               {
                  if(tiles[_loc4_].x == mTileNetworkComponents[_loc5_].x && tiles[_loc4_].y == mTileNetworkComponents[_loc5_].y)
                  {
                     _loc2_ = true;
                  }
                  _loc5_++;
               }
               if(!_loc2_)
               {
                  _loc3_.push(tiles[_loc4_]);
               }
               _loc4_++;
            }
            buildTiles(_loc3_,false);
         }
         mTileNetworkComponents = tiles;
      }
      
      protected function finishedBuildingTiles(tileGrid:TileGrid) : void
      {
         var _loc3_:FloorObject = null;
         mTileGrid = tileGrid;
         mBuildPropReady = true;
         var _loc2_:ISetIterator = mFloorObjectsAwaitingDungeonFloor.iterator() as ISetIterator;
         while(_loc2_.hasNext())
         {
            _loc3_ = _loc2_.next() as FloorObject;
            _loc3_.distributedDungeonFloor = this;
         }
         mFloorObjectsAwaitingDungeonFloor.clear();
         fillInEmptyTilesWithCollisionVolumes();
      }
      
      private function buildTiles(tiles:Vector.<DungeonTileUsage>, clearGroundLayer:Boolean) : void
      {
         mDungeonFloorFactory.buildDungeonFloor(tiles,finishedBuildingTiles,clearGroundLayer);
         if(tiles != null && tiles.length > 0)
         {
            onFloorTilesRequested();
         }
      }
      
      private function onFloorTilesRequested() : void
      {
         mFloorTilesRequested = true;
         queueEntryPropAtlases();
         if(mHeroEntryWanted)
         {
            requestEntryHero();
         }
      }
      
      private function fillInEmptyTilesWithCollisionVolumes() : void
      {
         var _loc9_:uint = 0;
         var _loc5_:uint = 0;
         var _loc6_:Tile = null;
         var _loc2_:Number = NaN;
         var _loc1_:Number = NaN;
         var _loc7_:Vector3D = null;
         var _loc11_:Number = NaN;
         var _loc3_:Number = NaN;
         var _loc4_:Vector3D = null;
         var _loc10_:Number = NaN;
         var _loc8_:RectangleNavCollider = null;
         _loc9_ = 0;
         while(_loc9_ < 12)
         {
            _loc5_ = 0;
            while(_loc5_ < 12)
            {
               _loc6_ = mTileGrid.getTileAtIndex(_loc5_,_loc9_);
               if(_loc6_ == null || _loc6_.isGeneratedFiller)
               {
                  if(mTileGrid.getEmptyColliderAtIndex(_loc5_,_loc9_) == null)
                  {
                     _loc2_ = 0;
                     _loc1_ = 0;
                     _loc7_ = new Vector3D(_loc2_,_loc1_);
                     _loc11_ = 900 * _loc5_ - 900 * 0.5;
                     _loc3_ = 900 * _loc9_ - 900 * 0.5;
                     _loc4_ = new Vector3D(_loc11_,_loc3_);
                     _loc10_ = 0;
                     _loc8_ = new RectangleNavCollider(mDBFacade,null,_loc7_,_loc10_,mB2World,900 * 0.5,900 * 0.5);
                     _loc8_.position = _loc4_;
                     mTileGrid.SetEmptyColliderAtIndex(_loc5_,_loc9_,_loc8_);
                  }
               }
               _loc5_++;
            }
            _loc9_++;
         }
      }
      
      override public function destroy() : void
      {
         var _loc3_:DooberGameObject = null;
         Logger.debug("destroy DistributedDungeonFloor " + id.toString());
         if(mViewHold)
         {
            mViewHold.stop();
            mViewHold = null;
         }
         mEventComponent.dispatchEvent(new Event("DUNGEON_FLOOR_DESTROY"));
         BakeScheduler.floorPurged();
         stopEntryReleaseEvents();
         LoadingPrewarm.cancelLoading();
         mPrewarm = null;
         mActiveOwnerAvatar = null;
         if(mBgMusic)
         {
            EventListeners.remove(mBgMusic,"complete",onBgMusicLoaded);
            EventListeners.remove(mBgMusic,"ioError",onBgMusicError);
            EventListeners.remove(mBgMusic,"securityError",onBgMusicError);
            try
            {
               mBgMusic.close();
            }
            catch(e:Error)
            {
            }
            mBgMusic = null;
         }
         if(mDBSoundComponent)
         {
            mDBSoundComponent.destroy();
            mDBSoundComponent = null;
         }
         if(mIntroMovieAsset)
         {
            mDBFacade.assetRepository.removeFromCache(mIntroMovieAsset);
            mIntroMovieAsset = null;
         }
         destroyIntroOverlay();
         destroyIntroVideo();
         if(mAssetLoadingComponent)
         {
            mAssetLoadingComponent.destroy();
            mAssetLoadingComponent = null;
         }
         mDungeonFloorFactory.destroy();
         mDungeonFloorFactory = null;
         var _loc7_:Array = [];
         var _loc4_:IMapIterator = mRemoteHeroes.iterator() as IMapIterator;
         while(_loc4_.hasNext())
         {
            _loc7_.push(_loc4_.next());
         }
         for each(var _loc8_:HeroGameObject in _loc7_)
         {
            if(_loc8_)
            {
               _loc8_.destroy();
            }
         }
         mRemoteHeroes.clear();
         mRemoteHeroes = null;
         var _loc6_:Array = [];
         var _loc5_:IMapIterator = mRemoteActors.iterator() as IMapIterator;
         while(_loc5_.hasNext())
         {
            _loc6_.push(_loc5_.next());
         }
         for each(var _loc1_:ActorGameObject in _loc6_)
         {
            if(_loc1_)
            {
               _loc1_.destroy();
            }
         }
         mRemoteActors.clear();
         mRemoteActors = null;
         for(var _loc11_:Object in mDoobers)
         {
            _loc3_ = _loc11_ as DooberGameObject;
            if(_loc3_ && !_loc3_.isDestroyed)
            {
               _loc3_.destroy();
            }
         }
         mDoobers = null;
         var _loc2_:Array = [];
         for(var _loc9_:Object in mProjectiles)
         {
            _loc2_.push(_loc9_);
         }
         for each(var _loc10_:ProjectileGameObject in _loc2_)
         {
            if(_loc10_ && !_loc10_.isDestroyed)
            {
               _loc10_.destroyForFloorShutdown();
            }
         }
         mProjectiles = null;
         mFloorObjectsAwaitingDungeonFloor.clear();
         mFloorObjectsAwaitingDungeonFloor = null;
         mTileGrid.destroy();
         mTileGrid = null;
         mEffectManager.destroy();
         mEffectManager = null;
         super.destroy();
      }
      
      public function isAlive() : Boolean
      {
         return mTileGrid != null;
      }
      
      override public function newNetworkChild(child:GameObject) : void
      {
         var _loc2_:HeroGameObject = null;
         var _loc3_:FloorObject = null;
         if(child is HeroGameObjectOwner)
         {
            activeOwnerAvatar = child as HeroGameObjectOwner;
            logWelcomeMessage();
         }
         else if(child is HeroGameObject)
         {
            _loc2_ = child as HeroGameObject;
            remoteHeroes.add(child.id,_loc2_);
            logPlayerJoined(_loc2_);
         }
         else if(child is ActorGameObject)
         {
            remoteActors.add(child.id,child as ActorGameObject);
            mEventComponent.dispatchEvent(new ActorLifetimeEvent("ACTOR_CREATED",child.id));
         }
         else if(child is DooberGameObject)
         {
            mDoobers[child] = true;
         }
         if(child is FloorObject)
         {
            _loc3_ = child as FloorObject;
            if(mBuildPropReady)
            {
               _loc3_.distributedDungeonFloor = this;
            }
            else
            {
               mFloorObjectsAwaitingDungeonFloor.add(_loc3_);
            }
         }
      }
      
      public function RemoveNetworkChild(child:GameObject) : void
      {
         var _loc2_:HeroGameObject = null;
         var _loc3_:FloorObject = null;
         if(child is HeroGameObjectOwner)
         {
            activeOwnerAvatar = null;
         }
         else if(child is HeroGameObject)
         {
            _loc2_ = child as HeroGameObject;
            logPlayerLeft(_loc2_);
            remoteHeroes.removeKey(child.id);
         }
         else if(child is ActorGameObject)
         {
            mRemoteActors.removeKey(child.id);
            mEventComponent.dispatchEvent(new ActorLifetimeEvent("ACTOR_DESTROYED",child.id));
         }
         if(child is FloorObject)
         {
            _loc3_ = child as FloorObject;
            _loc3_.distributedDungeonFloor = null;
         }
      }
      
      public function GetTilesAroundAvatar(range:Number) : Vector.<Tile>
      {
         var _loc2_:Rectangle = null;
         if(mActiveOwnerAvatar)
         {
            _loc2_ = new Rectangle(mActiveOwnerAvatar.position.x - range,mActiveOwnerAvatar.position.y - range,range * 2,range * 2);
            return mActiveOwnerAvatar.distributedDungeonFloor.tileGrid.getVisibleTiles(_loc2_);
         }
         return new Vector.<Tile>();
      }
      
      public function GetTileIdWhichAvatarIsOn() : String
      {
         var _loc4_:uint = 0;
         if(mTileNetworkComponents.length == 0)
         {
            Logger.error("Invalid tile location in getTileNetworkComponentAtLocation");
            return null;
         }
         var _loc2_:int = mActiveOwnerAvatar.position.x;
         var _loc3_:int = mActiveOwnerAvatar.position.y;
         var _loc5_:DungeonTileUsage = mTileNetworkComponents[0];
         var _loc1_:int = getDistanceFromTileUsage(_loc2_,_loc3_,_loc5_);
         var _loc6_:int = 0;
         _loc4_ = 1;
         while(_loc4_ < mTileNetworkComponents.length)
         {
            _loc6_ = getDistanceFromTileUsage(_loc2_,_loc3_,mTileNetworkComponents[_loc4_]);
            if(_loc6_ < _loc1_)
            {
               _loc1_ = _loc6_;
               _loc5_ = mTileNetworkComponents[_loc4_];
            }
            _loc4_++;
         }
         return _loc5_.tileId;
      }
      
      private function getDistanceFromTileUsage(x:int, y:int, dtu:DungeonTileUsage) : int
      {
         var _loc4_:Point = new Point(x,y);
         var _loc5_:Point = new Point(dtu.x + 450,dtu.y + 450);
         return Point.distance(_loc4_,_loc5_);
      }
      
      public function set baseLining(val:uint) : void
      {
         mBaseLining = val;
      }
      
      public function get baseLining() : uint
      {
         return mBaseLining;
      }
      
      override public function get gmMapNode() : GMMapNode
      {
         return mMapNode;
      }
      
      public function isTavern() : Boolean
      {
         return mMapNode.NodeType == GMMapNode.TAVERN_NODE_TYPE;
      }
   }
}

