package StateMachine.MainStateMachine
{
   import Brain.AssetRepository.AssetLoader;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Clock.GameClock;
   import Brain.Event.EventComponent;
   import Brain.Logger.Logger;
   import Brain.SceneGraph.SceneGraphComponent;
   import Brain.StateMachine.State;
   import Brain.UI.UIProgressBar;
   import Brain.Utils.MemoryTracker;
   import Brain.Utils.MemoryUtil;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Brain.WorkLoop.Task;
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
   import com.greensock.TweenMax;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.KeyboardEvent;
   import flash.events.MouseEvent;
   import flash.text.TextField;
   
   public class LoadingScreenState extends State
   {
      
      public static const NAME:String = "LoadingScreenState";
      
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
      
      private static const MINIMUM_LOADING_SECONDS:Number = 3;
      
      private static const LOADING_SCREEN_PATH:String = "Resources/Art2D/UI/db_UI_loading_screen.swf";
      
      public const ERROR_NONE_PARSABLE_MESSAGE:uint = 101;
      
      private var mMinimumLoadingSeconds:Number = 3;
      
      private var mFinishLoadingCallback:Function;
      
      private var mHasCalledFinishLoadingCallback:Boolean = false;
      
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
      }
      
      public function heroOwnerReady(e:Event) : void
      {
         mDBFacade.metrics.log("DungeonLoadHeroReady",{});
         mHeroOwnerReady = true;
         checkIfReadyToMoveOn();
      }
      
      private function floorInterestClosureEventCallback(e:Event) : void
      {
         AssetLoader.stopTrackingLoads();
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
         mEventComponent.addListener("FLOOR_INTEREST_CLOSURE",floorInterestClosureEventCallback);
         mEventComponent.addListener(HeroGameObjectOwner.HERO_OWNER_READY,heroOwnerReady);
         mEventComponent.addListener("REQUEST_ENTRY_FAILED",failedRequestEntry);
         mEventComponent.addListener("CLIENT_EXIT_COMPLETE",GraceFullClientExited);
         mEventComponent.addListener("Busterncpccahche_event",TickleCacheWithEvent);
         mAssetLoadingComponent.getSwfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_loading_screen.swf"),setUpLoadingScreen);
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
         var _loc2_:DBUIOneButtonPopup = new DBUIOneButtonPopup(mDBFacade,Locale.getString("MATCHMAKER_REFUSES_TITLE"),Locale.getError(_loc3_),Locale.getString("OK"),failedRequestEntryDialogClose,true,failedRequestEntryDialogClose);
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
         if(nodeType == "DUNGEON" || nodeType == "")
         {
            _loc2_ = swfAsset.getClass("loading_gate_random");
            _loc3_ = Locale.getString("LOADING_SCREEN_RANDOM_LABEL");
         }
         else if(nodeType == "INFINITE")
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
         mLoadingScreenLabel.text = _loc3_;
         mLoadingBarClip = mLoadingScreenRoot.loading_gate_text_hint.UI_loadingBar;
         mLoadingBarClip.visible = true;
         mLoadingBarClip.scaleX = mLoadingBarClip.scaleY = 1.8;
         mLoadingBarClip.x = 548.7;
         mLoadingBarClip.y = 1000;
         mHint = new UIHints(mDBFacade,mLoadingScreenRoot.loading_gate_text_hint.hint);
         mLoadingBar = new UIProgressBar(mDBFacade,mLoadingBarClip.loadingBar);
         mProgressTarget = 0;
         mLoadingBar.value = 0;
         mScreenLoaded = true;
         mDBFacade.stageRef.addEventListener("keyDown",keyCall);
         mDBFacade.stageRef.addEventListener("mouseDown",handleMouseDown);
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
         if(!mScreenLoaded)
         {
            return;
         }
         AssetLoader.updateTrackedLoads();
         if(mLoadingBar != null && AssetLoader.pendingBytesTotal > 0)
         {
            _loc2_ = AssetLoader.pendingBytesLoaded / AssetLoader.pendingBytesTotal;
            mProgressTarget = Math.max(mLoadingBar.value,_loc2_);
            mLoadingBar.value += (mProgressTarget - mLoadingBar.value) * 0.04;
         }
      }
      
      private function TickleCacheWithEvent(event:CacheLoadRequestNpcEvent) : void
      {
         var _loc2_:* = 0;
         mDBFacade.metrics.log("DungeonLoadCacheStarted",{});
         _loc2_ = 0;
         while(_loc2_ < event.tilelibraryname.length)
         {
            TrickleCacheLoader.tilelibrary(event.tilelibraryname[_loc2_],mDBFacade);
            _loc2_++;
         }
         TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_HUD.swf"),mDBFacade);
         TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/FX/db_fx_library.swf"),mDBFacade);
         TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Doobers/db_items_doobers.swf"),mDBFacade);
         TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Audio/soundEffects.swf"),mDBFacade);
         TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/UI/db_UI_nametag.swf"),mDBFacade);
         TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Icons/Weapons/db_icons_weapon_axes.swf"),mDBFacade);
         TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Icons/Weapons/db_icons_weapon_hammers.swf"),mDBFacade);
         TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Icons/Weapons/db_icons_weapon_throwingweapons.swf"),mDBFacade);
         TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/Icons/Charge/db_icons_charge.swf"),mDBFacade);
         TrickleCacheLoader.swfAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/projectiles/db_projectiles_library.swf"),mDBFacade);
         TrickleCacheLoader.loadHero(mDBFacade,mDBFacade.dbAccountInfo.activeAvatarInfo.skinId);
         TrickleCacheLoader.npcVector(event.cacheNpc,mDBFacade);
         TrickleCacheLoader.swfVector(event.cacheSwf,mDBFacade);
         AssetLoader.stopTrackingLoads();
      }
      
      private function checkIfReadyToMoveOn() : void
      {
         var _loc1_:Number = NaN;
         if(mTask == null && mHeroOwnerReady)
         {
            _loc1_ = (mDBFacade.gameClock.realTime - mLoadingStartTime) / 1000;
            mDBFacade.metrics.log("DungeonLoaded",{"timeSpentSeconds":_loc1_});
            mFinishedCallback();
         }
      }
      
      private function finishedLoading() : void
      {
         var timeTakenToLoadSoFar:Number;
         var timeLeftToLoad:Number;
         mDBFacade.metrics.log("DungeonLoadCacheFinished",{});
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
            mDBFacade.createHUD();
            mEventComponent.dispatchEvent(new Event("REQUEST_ENTRY_PLAYER_FLOOR"));
            mTask.destroy();
            mTask = null;
            checkIfReadyToMoveOn();
         };
         TweenMax.delayedCall(timeLeftToLoad,mFinishLoadingCallback);
      }
      
      private function forceFinishLoading() : void
      {
         mMinimumLoadingSeconds = 0;
         if(Boolean(mFinishLoadingCallback))
         {
            TweenMax.killDelayedCallsTo(mFinishLoadingCallback);
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
         AssetLoader.abortTrackingLoads();
         mSceneGraphComponent.removeChild(mLoadingScreenRoot);
         mSceneGraphComponent.removeChild(mLoadingBarClip);
         mEventComponent.removeAllListeners();
         mDBFacade.stageRef.removeEventListener("keyDown",keyCall);
         mDBFacade.stageRef.removeEventListener("mouseDown",handleMouseDown);
         if(mTask)
         {
            mTask.destroy();
            mTask = null;
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

import Brain.SceneGraph.SceneGraphComponent;
import Brain.UI.UIButton;
import Facade.DBFacade;
import flash.display.MovieClip;
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
   
   private var mUIButton:UIButton;
   
   private var mSceneGraphComponent:SceneGraphComponent;
   
   private var mDBFacade:DBFacade;
   
   private var mcallback:Function;
   
   private var mNetConnection:NetConnection;
   
   private var mNetStream:NetStream;
   
   private var skipButton:Class = db_UI_skip_button_swf;
   
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
      cleanup();
      mcallback();
   }
   
   public function cleanup() : void
   {
      mDBFacade.metrics.log("IntroVideoCleanup",{});
      mNetStream.removeEventListener("netStatus",detectEnd);
      mDBFacade.stageRef.removeEventListener("keyDown",KeyCall);
      mSceneGraphComponent.removeChild(mCutVideoBackGround);
      mSceneGraphComponent.removeChild(mCutVideo);
      mSceneGraphComponent.removeChild(mUIButton.root);
      mUIButton.destroy();
      mNetStream.close();
      mNetStream = null;
      mCutVideo = null;
      mCutVideoBackGround = null;
      mUIButton = null;
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
      var tempmovie:MovieClip;
      var cuePointHandler:* = function(param1:Object):void
      {
      };
      var metaDataHandler:* = function(param1:Object):void
      {
         mCutVideo.y = (600 - param1.height) / 2;
         mCutVideo.x = 0;
         mCutVideo.width = 1920;
         mCutVideo.height = 1080;
         mSceneGraphComponent.addChild(mCutVideo,50);
         SceneGraphComponent.bringToFront(mUIButton.root);
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
      mNetStream.addEventListener("netStatus",detectEnd);
      mCutVideoBackGround = new Shape();
      mCutVideoBackGround.graphics.beginFill(0);
      mCutVideoBackGround.graphics.drawRect(0,0,mDBFacade.viewWidth,mDBFacade.viewHeight);
      mCutVideoBackGround.graphics.endFill();
      mSceneGraphComponent.addChildAt(mCutVideoBackGround,50,0);
      tempmovie = new skipButton() as MovieClip;
      mUIButton = new UIButton(this.mDBFacade,tempmovie);
      tempmovie = null;
      mUIButton.root.x = 1850;
      mUIButton.root.y = 20;
      mUIButton.releaseCallback = cleanupAndTransition;
      mSceneGraphComponent.addChild(mUIButton.root,50);
      mDBFacade.stageRef.addEventListener("keyDown",KeyCall);
      mCutVideo.attachNetStream(mNetStream);
      mNetStream.play(DBFacade.buildFullDownloadPath(clname));
      mNetStream.soundTransform = new SoundTransform(mDBFacade.soundManager.getDampenedVolumeScaleForCategory("sfx"));
   }
}
