package StateMachine.MainStateMachine
{
   import Brain.AssetRepository.AssetLoader;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Clock.GameClock;
   import Brain.Event.EventComponent;
   import Brain.Event.EventListeners;
   import Brain.Logger.Logger;
   import Brain.SceneGraph.SceneGraphComponent;
   import Brain.StateMachine.State;
   import Brain.UI.UIProgressBar;
   import Brain.Utils.MemoryTracker;
   import Brain.Utils.MemoryUtil;
   import Brain.Utils.TextUtil;
   import Brain.WorkLoop.DoLater;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Brain.WorkLoop.Task;
   import DBGlobals.DBGlobal;
   import DistributedObjects.HeroGameObjectOwner;
   import Events.CacheLoadRequestNpcEvent;
   import Events.ClientExitCompleteEvent;
   import Events.RequestEntryFailedEvent;
   import Facade.DBFacade;
   import Facade.Locale;
   import Facade.TrickleCacheLoader;
   import GameMasterDictionary.GMMapNode;
   import UI.Popup.DBUIOneButtonPopup;
   import UI.UIHints;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class LoadingScreenState extends State
   {
      
      public static const NAME:String = "LoadingScreenState";
      
      public static const HERO_ENTRY_RELEASED:String = "LOADING_SCREEN_HERO_ENTRY_RELEASED";
      
      public static const ERROR_NONE_PARSABLE_DEMOGRAPHICS:uint = 102;
      
      public static const ERROR_ENTRY_REQUEST_MALFORMED:uint = 103;
      
      public static const ERROR_ENTRY_REQUEST_BADMAPNODE:uint = 104;
      
      public static const ERROR_INTERNAL:uint = 105;
      
      public static const ERROR_INTERNAL_NOT_SUPPORTED:uint = 106;
      
      public static const ERROR_MAPNODE_NODE_NOTAUTHORIZED:uint = 201;
      
      public static const WARNING_FRIEND_NOT_FOUND:uint = 500;
      
      public static const WARNING_FRIEND_GAME_NOT_FOUND:uint = 501;
      
      public static const WARNING_GAME_IS_FULL:uint = 502;
      
      private static const LERP_RATE:Number = 0.04;
      
      private static const LEGACY_PROGRESS_WEIGHT:Number = 0.5;
      
      private static const FLOOR_PROGRESS_WEIGHT:Number = 0.1;
      
      private static const STARLING_PROGRESS_WEIGHT:Number = 0.4;
      
      private static const NETWORK_WAIT_EASE_RATE:Number = 0.005;
      
      private static const MINIMUM_LOADING_SECONDS:Number = 3;
      
      private static const LOADING_SCREEN_PATH:String = "Resources/Art2D/UI/db_UI_loading_screen.swf";
      
      public const ERROR_NONE_PARSABLE_MESSAGE:uint = 101;
      
      private var mMinimumLoadingSeconds:Number = 3;
      
      private var mFloorDetails:FloorDetailsWait;
      
      private var mFinishLoadingCallback:Function;
      
      private var mHasCalledFinishLoadingCallback:Boolean = false;
      
      private var mHeroEntryHeld:Boolean = false;
      
      private var mDBFacade:DBFacade;
      
      private var mWorkComponent:LogicalWorkComponent;
      
      private var mTask:Task;
      
      private var mGoToSplashScreenCallback:Function;
      
      protected var mAssetLoadingComponent:AssetLoadingComponent;
      
      protected var mSceneGraphComponent:SceneGraphComponent;
      
      protected var mEventComponent:EventComponent;
      
      protected var mLoadingScreenRoot:MovieClip;
      
      protected var mLoadingBarClip:MovieClip;
      
      private var mLoadingBar:UIProgressBar;
      
      private var mProgressTarget:Number;
      
      private var mScreenLoaded:Boolean;
      
      protected var mHeroOwnerReady:Boolean;
      
      private var mStarlingAssetsPending:Boolean;
      
      private var mLegacyAssetsReady:Boolean;
      
      private var mFloorRequested:Boolean;
      
      private var mFloorReady:Boolean;
      
      private var mStarlingBundlesLoadedAtStart:uint;
      
      private var mMapNodeID:uint;
      
      public var mNodeType:String;
      
      private var mFriendID:uint;
      
      private var mMapID:uint;
      
      private var mJumpToMapState:Boolean = false;
      
      private var mLoadingStartTime:uint;
      
      private var mHint:UIHints;
      
      private var mFriendOnly:Boolean;
      
      private var mLoadingScreenLabel:TextField;
      
      private var mVideoPlayer:videoPlayer;
      
      public function LoadingScreenState(dbFacade:DBFacade, finishedCallback:Function = null)
      {
         super("LoadingScreenState",finishedCallback);
         mDBFacade = dbFacade;
         mWorkComponent = new LogicalWorkComponent(mDBFacade,"LoadingScreenState");
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mSceneGraphComponent = new SceneGraphComponent(mDBFacade,"LoadingScreenState");
         mEventComponent = new EventComponent(mDBFacade);
         mScreenLoaded = false;
         mHeroOwnerReady = false;
         mFriendOnly = false;
         mFloorDetails = new FloorDetailsWait(function(param1:Number, param2:Function):Object
         {
            return mDBFacade.realClockWorkManager.doLater(param1,param2,false,"LoadingScreenState");
         },function(param1:Object):void
         {
            mDBFacade.realClockWorkManager.removeDoLater(param1 as DoLater);
         },floorDetailsDone);
      }
      
      public function get holdsHeroEntry() : Boolean
      {
         return mHeroEntryHeld;
      }
      
      public function heroOwnerReady(e:Event) : void
      {
         mDBFacade.metrics.log("DungeonLoadHeroReady",{});
         mHeroOwnerReady = true;
         mFloorDetails.heroReady();
         checkIfReadyToMoveOn();
      }
      
      private function floorInterestClosureEventCallback(e:Event) : void
      {
         AssetLoader.stopTrackingLoads();
         mFloorReady = true;
         mFloorDetails.closureArrived();
      }
      
      private function floorDetailsDone(timedOut:Boolean) : void
      {
         var _loc2_:Number = NaN;
         if(timedOut)
         {
            _loc2_ = (mDBFacade.gameClock.realTime - mLoadingStartTime) / 1000;
            mDBFacade.metrics.log("DungeonLoadFloorDetailsTimeout",{"timeSpentSeconds":_loc2_});
         }
         checkIfReadyToMoveOn();
      }
      
      private function ponderPlayMovie() : Boolean
      {
         var _loc2_:GMMapNode = null;
         var _loc1_:Number = mDBFacade.getSplitTestNumber("SkipVideo",0);
         if(mMapNodeID != 0 && _loc1_ != 1)
         {
            _loc2_ = mDBFacade.gameMaster.mapNodeById.itemFor(mMapNodeID);
            if(_loc2_ != null && _loc2_.StorySwfPath)
            {
               mVideoPlayer = new videoPlayer(mDBFacade,mSceneGraphComponent,enterLoadingState);
               mVideoPlayer.process(_loc2_.StorySwfPath);
               return false;
            }
         }
         enterLoadingState();
         return true;
      }
      
      override public function enterState() : void
      {
         mDBFacade.metrics.log("DungeonLoadingScreen",{});
         super.enterState();
         Logger.debug("MAIN STATE MACHINE TRANSITION -- ENTERING LOADING SCREEN STATE");
         ponderPlayMovie();
      }
      
      private function enterLoadingState() : void
      {
         MemoryTracker.nextGeneration();
         mLoadingStartTime = mDBFacade.gameClock.realTime;
         mHeroOwnerReady = false;
         mFloorDetails.begin();
         mStarlingAssetsPending = false;
         mLegacyAssetsReady = false;
         mFloorRequested = false;
         mFloorReady = false;
         mStarlingBundlesLoadedAtStart = mDBFacade.assetLoadingComponent.starlingBundlesLoaded;
         mHeroEntryHeld = true;
         mEventComponent.addListener("StarlingAssetsQueued",starlingAssetsQueued);
         mEventComponent.addListener("StarlingAssetsReady",starlingAssetsReady);
         mEventComponent.addListener("FLOOR_INTEREST_CLOSURE",floorInterestClosureEventCallback);
         mEventComponent.addListener(HeroGameObjectOwner.HERO_OWNER_READY,heroOwnerReady);
         mEventComponent.addListener("REQUEST_ENTRY_FAILED",failedRequestEntry);
         mEventComponent.addListener("CLIENT_EXIT_COMPLETE",GraceFullClientExited);
         mEventComponent.addListener("Busterncpccahche_event",TickleCacheWithEvent);
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_loading_screen.swf"),setUpLoadingScreen);
         if(mDBFacade.assetLoadingComponent != null)
         {
            mDBFacade.assetLoadingComponent.beginEntry();
            TrickleCacheLoader.queueCommonStarlingAtlases(mDBFacade);
            TrickleCacheLoader.queueHeroKitStarlingAtlases(mDBFacade);
            mStarlingAssetsPending = mDBFacade.assetLoadingComponent.isStarlingLoadPending;
         }
         AssetLoader.startTrackingLoads(finishedLoading);
         var _loc1_:uint = 0;
         if(mFriendOnly)
         {
            _loc1_ = 1;
         }
         var _loc2_:String = mDBFacade.dbConfigManager.getConfigString("MatchMakerGroup","");
         mDBFacade.mDistributedObjectManager.mMatchMaker.RequestEntry(mapNodeID,friendID,mapID,_loc1_,_loc2_);
         mTask = mWorkComponent.doEveryFrame(updateProgress);
         MemoryUtil.pauseForGCWithLogging("LoadingScreen: ");
      }
      
      private function GraceFullClientExited(event:ClientExitCompleteEvent) : void
      {
         gracefullExit();
      }
      
      private function failedRequestEntry(event:RequestEntryFailedEvent) : void
      {
         var _loc3_:uint = event.errorCode;
         var _loc2_:DBUIOneButtonPopup = new DBUIOneButtonPopup(mDBFacade,"MATCHMAKER_REFUSED_POPUP",Locale.getString("MATCHMAKER_REFUSES_TITLE"),Locale.getError(_loc3_),Locale.getString("OK"),failedRequestEntryDialogClose,true,failedRequestEntryDialogClose);
         MemoryTracker.track(_loc2_,"DBUIOneButtonPopup - created in LoadingScreenState.failedRequestEntry()");
         var _loc4_:Number = (mDBFacade.gameClock.realTime - mLoadingStartTime) / 1000;
         mDBFacade.metrics.log("DungeonLoadFailed",{
            "errorCode":_loc3_,
            "timeSpentSeconds":_loc4_
         });
      }
      
      private function failedRequestEntryDialogClose() : void
      {
         mDBFacade.mainStateMachine.enterReloadTownState(true);
      }
      
      private function gracefullExit() : void
      {
         mDBFacade.mainStateMachine.enterReloadTownState();
      }
      
      private function goBackToTown() : void
      {
         mDBFacade.mainStateMachine.enterTownState(mJumpToMapState);
         mJumpToMapState = false;
      }
      
      private function setUpLoadingScreen(swfAsset:SwfAsset) : void
      {
         var _loc2_:Class = null;
         var _loc3_:String = null;
         if(nodeType == GMMapNode.DUNGEON_NODE_TYPE || nodeType == "")
         {
            _loc2_ = swfAsset.getClass("loading_gate_random");
            _loc3_ = Locale.getString("LOADING_SCREEN_RANDOM_LABEL");
         }
         else if(nodeType == GMMapNode.INFINITE_NODE_TYPE)
         {
            _loc2_ = swfAsset.getClass("loading_gate_ultimate_random");
            _loc3_ = Locale.getString("LOADING_SCREEN_RANDOM_LABEL");
         }
         else
         {
            _loc2_ = swfAsset.getClass("loading_gateboss_random");
            _loc3_ = Locale.getString("LOADING_SCREEN_CHALLENGE_LABEL");
         }
         mLoadingScreenRoot = new _loc2_();
         mLoadingScreenLabel = mLoadingScreenRoot.loading_gate_text_hint.label;
         TextUtil.setText(mLoadingScreenLabel,_loc3_);
         mLoadingBarClip = mLoadingScreenRoot.loading_gate_text_hint.UI_loadingBar;
         mLoadingBarClip.visible = true;
         mLoadingBarClip.scaleX = mLoadingBarClip.scaleY = DBGlobal.UI_16_TO_9_PORT_OBJECT_SCALE;
         mLoadingBarClip.x = 548.7;
         mLoadingBarClip.y = 1000;
         mHint = new UIHints(mDBFacade,mLoadingScreenRoot.loading_gate_text_hint.hint);
         mLoadingBar = new UIProgressBar(mDBFacade,mLoadingBarClip.loadingBar);
         mProgressTarget = 0;
         mLoadingBar.value = 0;
         mScreenLoaded = true;
         EventListeners.add(mDBFacade.stageRef,"keyDown",keyCall);
         EventListeners.add(mDBFacade.stageRef,"mouseDown",handleMouseDown);
         mMinimumLoadingSeconds = 3;
         if(mScreenLoaded && mDBFacade.mainStateMachine.currentStateName == "LoadingScreenState")
         {
            mSceneGraphComponent.addChild(mLoadingScreenRoot,100);
            mSceneGraphComponent.addChild(mLoadingBarClip,100);
         }
      }
      
      private function updateProgress(clock:GameClock) : void
      {
         var _loc2_:Number = NaN;
         var _loc3_:Number = NaN;
         if(!mScreenLoaded)
         {
            return;
         }
         if(!mFloorRequested)
         {
            AssetLoader.updateTrackedLoads();
         }
         if(mLoadingBar != null)
         {
            _loc2_ = 0.5 * legacyProgress(clock) + (mFloorReady ? 0.1 : 0) + 0.4 * starlingProgress();
            mProgressTarget = Math.max(mProgressTarget,_loc2_);
            if(waitingOnNetwork())
            {
               _loc3_ = nextMilestone(_loc2_);
               if(mProgressTarget < _loc3_)
               {
                  mProgressTarget += (_loc3_ - mProgressTarget) * 0.005;
               }
            }
            mLoadingBar.value += (mProgressTarget - mLoadingBar.value) * 0.04;
         }
      }
      
      private function waitingOnNetwork() : Boolean
      {
         if(mStarlingAssetsPending)
         {
            return false;
         }
         if(!mFloorRequested)
         {
            return !mLegacyAssetsReady && AssetLoader.pendingBytesTotal == 0;
         }
         return !mHeroOwnerReady || mFloorDetails.pending;
      }
      
      private function nextMilestone(earned:Number) : Number
      {
         if(!mFloorRequested)
         {
            return 0.5;
         }
         if(!mFloorReady)
         {
            return earned + 0.1;
         }
         var _loc2_:uint = mDBFacade.assetLoadingComponent.starlingBundlesLoaded - mStarlingBundlesLoadedAtStart;
         return 0.5 + 0.1 + 0.4 * (_loc2_ + 1) / (_loc2_ + 2);
      }
      
      private function legacyProgress(clock:GameClock) : Number
      {
         if(!mHeroEntryHeld)
         {
            return 1;
         }
         var _loc2_:Number = mLegacyAssetsReady ? 1 : (AssetLoader.pendingBytesTotal > 0 ? AssetLoader.pendingBytesLoaded / AssetLoader.pendingBytesTotal : 0);
         var _loc3_:Number = mMinimumLoadingSeconds > 0 ? (clock.realTime - mLoadingStartTime) / (1000 * mMinimumLoadingSeconds) : 1;
         return Math.min(_loc2_,_loc3_);
      }
      
      private function starlingProgress() : Number
      {
         var _loc1_:AssetLoadingComponent = mDBFacade.assetLoadingComponent;
         var _loc2_:uint = _loc1_.starlingBundlesLoaded - mStarlingBundlesLoadedAtStart;
         var _loc4_:uint = _loc1_.activeStarlingBundleCount;
         var _loc3_:uint = _loc2_ + _loc4_ + _loc1_.pendingStarlingBundleCount + (mHeroOwnerReady ? 0 : 1);
         if(_loc3_ == 0)
         {
            return 1;
         }
         return (_loc2_ + _loc1_.starlingLoadProgress) / _loc3_;
      }
      
      private function TickleCacheWithEvent(event:CacheLoadRequestNpcEvent) : void
      {
         var _loc2_:uint = 0;
         mDBFacade.metrics.log("DungeonLoadCacheStarted",{});
         _loc2_ = 0;
         while(_loc2_ < event.tileLibraryName.length)
         {
            TrickleCacheLoader.tileLibrary(event.tileLibraryName[_loc2_],mDBFacade);
            _loc2_++;
         }
         TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_HUD.swf"),mDBFacade);
         TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/FX/db_fx_library.swf"),mDBFacade);
         TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Doobers/db_items_doobers.swf"),mDBFacade);
         TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath(DBGlobal.SFX_PATH),mDBFacade);
         TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_nametag.swf"),mDBFacade);
         TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Icons/Weapons/db_icons_weapon_axes.swf"),mDBFacade);
         TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Icons/Weapons/db_icons_weapon_hammers.swf"),mDBFacade);
         TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Icons/Weapons/db_icons_weapon_throwingweapons.swf"),mDBFacade);
         TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Icons/Charge/db_icons_charge.swf"),mDBFacade);
         TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/projectiles/db_projectiles_library.swf"),mDBFacade);
         TrickleCacheLoader.swfVector(event.cacheSwf,mDBFacade);
         AssetLoader.stopTrackingLoads();
      }
      
      private function starlingAssetsQueued(e:Event) : void
      {
         mStarlingAssetsPending = true;
      }
      
      private function starlingAssetsReady(e:Event) : void
      {
         mStarlingAssetsPending = false;
         checkIfReadyToMoveOn();
      }
      
      private function checkIfReadyToMoveOn() : void
      {
         var _loc1_:Number = NaN;
         if(!mHeroEntryHeld && mHeroOwnerReady && !mFloorDetails.pending && !mStarlingAssetsPending)
         {
            _loc1_ = (mDBFacade.gameClock.realTime - mLoadingStartTime) / 1000;
            mDBFacade.metrics.log("DungeonLoaded",{"timeSpentSeconds":_loc1_});
            mFinishedCallback();
            mEventComponent.dispatchEvent(new Event("FLOOR_REVEALED"));
         }
      }
      
      private function finishedLoading() : void
      {
         var timeTakenToLoadSoFar:Number;
         var timeLeftToLoad:Number;
         mLegacyAssetsReady = true;
         mDBFacade.metrics.log("DungeonLoadCacheFinished",{});
         mDBFacade.createHUD();
         mFloorRequested = true;
         mEventComponent.dispatchEvent(new Event("REQUEST_ENTRY_PLAYER_FLOOR"));
         timeTakenToLoadSoFar = (mDBFacade.gameClock.realTime - mLoadingStartTime) / 1000;
         timeLeftToLoad = Number.max(0,mMinimumLoadingSeconds - timeTakenToLoadSoFar);
         mHasCalledFinishLoadingCallback = false;
         mFinishLoadingCallback = function():void
         {
            if(mHasCalledFinishLoadingCallback)
            {
               return;
            }
            mHasCalledFinishLoadingCallback = true;
            mFinishLoadingCallback = null;
            mHeroEntryHeld = false;
            mEventComponent.dispatchEvent(new Event("LOADING_SCREEN_HERO_ENTRY_RELEASED"));
            checkIfReadyToMoveOn();
         };
         mDBFacade.mTween.delayedCall(timeLeftToLoad,mFinishLoadingCallback);
      }
      
      private function forceFinishLoading() : void
      {
         mMinimumLoadingSeconds = 0;
         if(Boolean(mFinishLoadingCallback))
         {
            mDBFacade.mTween.killDelayedCallsTo(mFinishLoadingCallback);
            mFinishLoadingCallback();
         }
      }
      
      private function keyCall(event:KeyboardEvent) : void
      {
         switch(int(event.keyCode) - 27)
         {
            case 0:
               forceFinishLoading();
         }
      }
      
      private function handleMouseDown(event:MouseEvent) : void
      {
         forceFinishLoading();
      }
      
      override public function exitState() : void
      {
         if(mHint)
         {
            mHint.destroy();
         }
         mHint = null;
         if(mFinishLoadingCallback != null)
         {
            mDBFacade.mTween.killDelayedCallsTo(mFinishLoadingCallback);
            mFinishLoadingCallback = null;
         }
         AssetLoader.abortTrackingLoads();
         mSceneGraphComponent.removeChild(mLoadingScreenRoot);
         mSceneGraphComponent.removeChild(mLoadingBarClip);
         mEventComponent.removeAllListeners();
         EventListeners.remove(mDBFacade.stageRef,"keyDown",keyCall);
         EventListeners.remove(mDBFacade.stageRef,"mouseDown",handleMouseDown);
         if(mTask)
         {
            mTask.destroy();
            mTask = null;
         }
         mFloorDetails.stop();
         if(mFinishLoadingCallback != null)
         {
            mDBFacade.mTween.killDelayedCallsTo(mFinishLoadingCallback);
            mFinishLoadingCallback = null;
         }
         if(mDBFacade.assetLoadingComponent != null)
         {
            mDBFacade.assetLoadingComponent.endEntry();
         }
         super.exitState();
      }
      
      public function get mapNodeID() : uint
      {
         return mMapNodeID;
      }
      
      public function set mapNodeID(value:uint) : void
      {
         mMapNodeID = value;
         mFriendID = 0;
         mMapID = 0;
      }
      
      public function get mapID() : uint
      {
         return mMapID;
      }
      
      public function set mapID(value:uint) : void
      {
         mMapNodeID = 0;
         mFriendID = 0;
         mMapID = value;
      }
      
      public function get friendID() : uint
      {
         return mFriendID;
      }
      
      public function set friendID(value:uint) : void
      {
         mMapNodeID = 0;
         mFriendID = value;
         mMapID = 0;
      }
      
      public function get friendsOnly() : Boolean
      {
         return mFriendOnly;
      }
      
      public function set friendsOnly(value:Boolean) : void
      {
         mFriendOnly = value;
      }
      
      public function set jumpToMapState(value:Boolean) : void
      {
         mJumpToMapState = value;
      }
      
      public function get nodeType() : String
      {
         return mNodeType;
      }
      
      public function set nodeType(value:String) : void
      {
         mNodeType = value;
      }
   }
}

import Brain.Event.EventListeners;
import Brain.SceneGraph.SceneGraphComponent;
import Facade.DBFacade;
import Sound.DBSoundManager;
import UI.CutsceneOverlay;
import flash.display.Shape;
import flash.events.KeyboardEvent;
import flash.events.NetStatusEvent;
import flash.media.SoundTransform;
import flash.media.Video;
import flash.net.NetConnection;
import flash.net.NetStream;

class videoPlayer
{
   
   private var mCutVideo:Video;
   
   private var mCutVideoBackGround:Shape;
   
   private var mOverlay:CutsceneOverlay;
   
   private var mSceneGraphComponent:SceneGraphComponent;
   
   private var mDBFacade:DBFacade;
   
   private var mcallback:Function;
   
   private var mNetConnection:NetConnection;
   
   private var mNetStream:NetStream;
   
   private var mIsCleanedUp:Boolean = false;
   
   public function videoPlayer(dbFacade:DBFacade, sceneGraphComponent:SceneGraphComponent, callback:Function)
   {
      super();
      mcallback = callback;
      mSceneGraphComponent = sceneGraphComponent;
      mDBFacade = dbFacade;
   }
   
   public function destroy() : void
   {
      cleanup();
   }
   
   private function cleanupAndTransition() : void
   {
      if(mIsCleanedUp)
      {
         return;
      }
      cleanup();
      mcallback();
   }
   
   public function cleanup() : void
   {
      if(mIsCleanedUp)
      {
         return;
      }
      mIsCleanedUp = true;
      mDBFacade.metrics.log("IntroVideoCleanup",{});
      EventListeners.remove(mNetStream,"netStatus",detectEnd);
      EventListeners.remove(mDBFacade.stageRef,"keyDown",KeyCall);
      mDBFacade.menuNavigationController.popLayer("INTRO_CINEMATIC");
      mSceneGraphComponent.removeChild(mCutVideoBackGround);
      mSceneGraphComponent.removeChild(mCutVideo);
      mSceneGraphComponent.removeChild(mOverlay.skipButton.root);
      mSceneGraphComponent.removeChild(mOverlay.coliseumAdvert);
      mOverlay.destroy();
      mNetStream.close();
      mNetStream = null;
      mCutVideo = null;
      mCutVideoBackGround = null;
      mOverlay = null;
   }
   
   public function KeyCall(event:KeyboardEvent) : void
   {
      switch(int(event.keyCode) - 27)
      {
         case 0:
            mDBFacade.metrics.log("IntroVideoSkip",{});
            cleanupAndTransition();
      }
   }
   
   public function detectEnd(myevent:NetStatusEvent) : void
   {
      switch(myevent.info.code)
      {
         case "NetStream.Play.Start":
            mDBFacade.metrics.log("IntroVideoStart",{});
            break;
         case "NetStream.Play.Stop":
            cleanupAndTransition();
            break;
         case "NetStream.Play.StreamNotFound":
            cleanupAndTransition();
      }
   }
   
   public function process(clname:String) : void
   {
      var customClient:Object;
      var dbSoundManager:DBSoundManager;
      var cuePointHandler:* = function(param1:Object):void
      {
      };
      var metaDataHandler:* = function(param1:Object):void
      {
         mCutVideo.y = 0;
         mCutVideo.x = 0;
         mCutVideo.width = 1920;
         mCutVideo.height = 1080;
         mSceneGraphComponent.addChild(mCutVideo,50);
         SceneGraphComponent.bringToFront(mOverlay.skipButton.root);
         SceneGraphComponent.bringToFront(mOverlay.coliseumAdvert);
      };
      mDBFacade.metrics.log("IntroVideoCreated",{});
      mCutVideo = new Video(1,1);
      mNetConnection = new NetConnection();
      mNetConnection.connect(null);
      mNetStream = new NetStream(mNetConnection);
      customClient = {};
      customClient.onCuePoint = cuePointHandler;
      customClient.onMetaData = metaDataHandler;
      mNetStream.client = customClient;
      EventListeners.add(mNetStream,"netStatus",detectEnd);
      mCutVideoBackGround = new Shape();
      mCutVideoBackGround.graphics.beginFill(0);
      mCutVideoBackGround.graphics.drawRect(0,0,mDBFacade.viewWidth,mDBFacade.viewHeight);
      mCutVideoBackGround.graphics.endFill();
      mSceneGraphComponent.addChildAt(mCutVideoBackGround,50,0);
      mOverlay = new CutsceneOverlay(mDBFacade,cleanupAndTransition);
      mSceneGraphComponent.addChild(mOverlay.skipButton.root,50);
      mSceneGraphComponent.addChild(mOverlay.coliseumAdvert,50);
      mDBFacade.menuNavigationController.pushNewLayer("INTRO_CINEMATIC",cleanupAndTransition,mOverlay.skipButton);
      EventListeners.add(mDBFacade.stageRef,"keyDown",KeyCall);
      mCutVideo.attachNetStream(mNetStream);
      mNetStream.play(DBFacade.buildFullDownloadPath(clname));
      dbSoundManager = mDBFacade.soundManager as DBSoundManager;
      dbSoundManager.applyStoredVolumeSettings();
      mNetStream.soundTransform = new SoundTransform(dbSoundManager.getDampenedVolumeScaleForCategory("music"));
   }
}
