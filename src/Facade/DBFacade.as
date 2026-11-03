package Facade
{
   import Account.AccountBonus;
   import Account.DBAccountInfo;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.ImageAsset;
   import Brain.AssetRepository.JsonAsset;
   import Brain.AssetRepository.TestResourceLocator;
   import Brain.Clock.GameClock;
   import Brain.Event.EventListeners;
   import Brain.Facade.Facade;
   import Brain.Logger.Logger;
   import Brain.Render.MovieClipPool;
   import Brain.UI.UIProgressBar;
   import Brain.Utils.MemoryTracker;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Brain.WorkLoop.Task;
   import Brain.jsonRPC.JSONRPCService;
   import Collections.Map;
   import Combat.Attack.TimelineFactory;
   import Config.ConfigFileLoadedEvent;
   import Config.DBConfigManager;
   import Config.ServiceDiscoveryLoader;
   import Config.ServiceDiscoveryReadyEvent;
   import DistributedObjects.DistributedObjectManager;
   import Effects.CustomSkinVisualsOverrideHandler;
   import Effects.EffectPool;
   import Events.ManagersLoadedEvent;
   import GameMasterDictionary.GameMaster;
   import GeneratedCode.InfiniteMapNodeDetail;
   import Input.KeyBindings.KeyBindings;
   import Input.MenuNavigationController;
   import Json.JsonCodec;
   import MagicWords.MagicWordManager;
   import Metrics.FPSReadout;
   import Metrics.MetricsLogger;
   import NetworkCode.Transport.GameEndpoints;
   import NetworkCode.Transport.TransportSettings;
   import Settings.Model.DisplayTimingSettings;
   import Settings.Model.SettingsModel;
   import Settings.Model.SettingsStore;
   import Sound.DBSoundManager;
   import StateMachine.MainStateMachine.LoadingFinishedEvent;
   import StateMachine.MainStateMachine.LoadingScreenState;
   import StateMachine.MainStateMachine.LoadingState;
   import StateMachine.MainStateMachine.MainStateMachine;
   import SteamAchievements.SteamAchievementsHelper;
   import SteamAchievements.SteamAchievementsManager;
   import SteamInput.SteamInputManager;
   import UI.Cursor.UIMouseCursors;
   import UI.Hud.StarlingConverted.HudArt;
   import UI.Hud.StarlingConverted.IGameHud;
   import UI.Hud.StarlingConverted.StarlingHud;
   import UI.Hud.UIHud;
   import UI.Map.PlayerActivityCount;
   import UI.Popup.DBUIOneButtonPopup;
   import UI.UIHideToggle;
   import UI.UILevelUpPostController;
   import UI.UIReconnectingIndicator;
   import avmplus.getQualifiedClassName;
   import com.amanitadesign.steam.FRESteamWorks;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.KeyboardEvent;
   import flash.external.ExternalInterface;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.profiler.showRedrawRegions;
   import flash.system.Capabilities;
   import flash.system.Security;
   import flash.text.TextField;
   
   public class DBFacade extends Facade
   {
      
      private static const CLIENT_ERROR_EVENT:String = "CLIENT_ERROR_EVENT";
      
      public static const VALIDATION_REFRESH_TIME:Number = 3600;
      
      private static var mDownloadRoot:String = "";
      
      private var LoadingClass:Class = db_UI_game_loading_screen_swf;
      
      protected var mInitialLoadingClip:MovieClip;
      
      private var mLoadingBar:UIProgressBar;
      
      private var mLoadingBarIntStatus:Number = 0;
      
      private var mAltEnterDown:Boolean;
      
      private var mPlainEnterDown:Boolean;
      
      protected var mMainStateMachine:MainStateMachine;
      
      protected var mDBAccountInfo:DBAccountInfo;
      
      protected var mDBConfigManager:DBConfigManager;
      
      protected var mHud:IGameHud;
      
      protected var mEffectPool:EffectPool;
      
      protected var mMovieClipPool:MovieClipPool;
      
      protected var mMetricsLogger:MetricsLogger;
      
      protected var mFPSReadout:FPSReadout;
      
      private var mReconnectingIndicator:UIReconnectingIndicator;
      
      private var mReconnectFrozeInput:Boolean = false;
      
      private var mMainStateAtDrop:String;
      
      protected var mTileLibraryMap:Map;
      
      protected var mJsonAssets:Array;
      
      protected var mLibraryJsonLoaded:Boolean = false;
      
      protected var mTimelineFinishedLoading:Boolean = false;
      
      protected var mTimelineFactory:TimelineFactory;
      
      protected var mGameMasterJsonLoaded:Boolean = false;
      
      protected var mLibraryJson:Array;
      
      protected var mGameMasterJson:Object;
      
      protected var mUILevelUpPostController:UILevelUpPostController;
      
      protected var mAccountBonus:AccountBonus;
      
      protected var mMenuNavigationController:MenuNavigationController;
      
      protected var mCustomSkinVisualsOverrideHandler:CustomSkinVisualsOverrideHandler;
      
      protected var mSettingsModel:SettingsModel;
      
      private var mDisplayTimingSettings:DisplayTimingSettings;
      
      protected var mKeyBindings:KeyBindings;
      
      protected var mUIHideToggle:UIHideToggle;
      
      public var gameMaster:GameMaster;
      
      protected var mMagicWordManager:MagicWordManager;
      
      private var mWebServicesUrl:String;
      
      private var mGameSocketAddress:String;
      
      private var mGameSocketPort:int;
      
      private var mGameSocketTlsOffered:Boolean = false;
      
      private var mGameSocketWssPath:String = "";
      
      private var mWebAPIRoot:String;
      
      private var mPendingServiceDiscoveryEvent:ServiceDiscoveryReadyEvent;
      
      private var mRPCRoot:String;
      
      private var mSteamAPIRoot:String;
      
      private var mPlayerActivityCount:PlayerActivityCount;
      
      private var mAccountId:uint;
      
      private var mValidationToken:String;
      
      private var mDemographics:Object;
      
      private var mHiddenFocusText:TextField;
      
      public var mDistributedObjectManager:DistributedObjectManager;
      
      public var mCheckedDailyReward:Boolean;
      
      public var mInDailyReward:Boolean;
      
      protected var mTokenRegenTask:Task;
      
      private var mDelayErrors:Array;
      
      private var mLogicalWorkComponent:LogicalWorkComponent;
      
      private var mErrorTask:Task;
      
      private var mSecurityGM:int = 0;
      
      private var mSecurityTL:int = 0;
      
      private var mSecuritySL:int = 0;
      
      public var mSteamworks:FRESteamWorks = new FRESteamWorks();
      
      public var mSteamUserId:String;
      
      public var mSteamAppId:uint = 0;
      
      public var mSteamPersonaName:String;
      
      public var mSteamWebApiAuthTicket:String;
      
      public var mSteamAuthTicketHandle:uint;
      
      public var mSteamLoginFailure:String;
      
      private var mSteamAchievementsHelper:SteamAchievementsHelper;
      
      private var mSteamAchievementsManager:SteamAchievementsManager;
      
      public var mUseSteamLogin:Boolean;
      
      public var mSeenFlaggedPopup:Boolean;
      
      public var mSteamIsFlagged:Boolean;
      
      public var mSteamFlaggedUntilAfterDateString:String;
      
      public var mSteamIsFlaggedDueToFamilySharingOwnerIsFlagged:Boolean;
      
      public var mSteamIsFlaggedDueToFamilySharingOwnerName:String;
      
      public var mSteamAvatarUrl:String;
      
      private var mSteamInputManager:SteamInputManager;
      
      public var mAdditionalConfigFilesToLoad:Array = [];
      
      private var mShowCollisions:Boolean = false;
      
      public var NODE_RULES:uint = 0;
      
      private var stagetwo_init_call_count:uint = 0;
      
      public function DBFacade()
      {
         mWantFramerateEnforcement = true;
         super();
         mTileLibraryMap = new Map();
         mCheckedDailyReward = false;
         mInDailyReward = false;
         if(Capabilities.playerType == "Desktop")
         {
            return;
         }
         Security.loadPolicyFile("https://ak.ssl.dungeonbusters.com/crossdomain.xml");
         Security.allowDomain("http://ak.ssl.dungeonbusters.com");
         Security.allowInsecureDomain("https://ak.ssl.dungeonbusters.com");
         Security.allowDomain("www.youtube.com");
         killWebSecurity();
      }
      
      public static function get ROOT_DIR_old() : String
      {
         if(!mDownloadRoot)
         {
            Logger.error("Download root ROOT_DIR is not set yet.");
         }
         return mDownloadRoot;
      }
      
      public static function buildFullDownloadPath(rawAssetPath:String) : String
      {
         if(rawAssetPath == "" || rawAssetPath == "null")
         {
            Logger.error("Trying to create a path from an empty string");
            return "";
         }
         return TestResourceLocator.url(mDownloadRoot + rawAssetPath);
      }
      
      public function killWebSecurity() : void
      {
         Security.allowDomain("*");
      }
      
      public function get showCollisions() : Boolean
      {
         return mShowCollisions;
      }
      
      public function set showCollisions(showThem:Boolean) : void
      {
         mShowCollisions = showThem;
         mSceneGraphManager.getLayer(40).visible = mShowCollisions;
      }
      
      public function get steamAchievementsHelper() : SteamAchievementsHelper
      {
         return mSteamAchievementsHelper;
      }
      
      public function set steamAchievementsHelper(inSteamAchievementsHelper:SteamAchievementsHelper) : void
      {
         mSteamAchievementsHelper = inSteamAchievementsHelper;
      }
      
      public function get steamAchievementsManager() : SteamAchievementsManager
      {
         return mSteamAchievementsManager;
      }
      
      public function set steamAchievementsManager(inSteamAchievementsManager:SteamAchievementsManager) : void
      {
         mSteamAchievementsManager = inSteamAchievementsManager;
      }
      
      override public function logCheater(howICheat:String) : void
      {
         var requestFunc:Function = JSONRPCService.getFunction("LogCheater",rpcRoot + "store");
         requestFunc(dbAccountInfo.id,validationToken,howICheat,demographics,function():void
         {
         },function(param1:Error):void
         {
         });
      }
      
      private function loadBackground() : void
      {
         var countBackgroundImagesLoaded:int = 0;
         var startWindowed:Boolean = featureFlags.getFlagValue("start-windowed");
         mAssetLoadingComponent.getImageAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/background/left.jpg"),function(param1:ImageAsset):void
         {
            var _loc2_:DisplayObject = param1.image;
            var _loc3_:Number = viewHeight / _loc2_.height;
            _loc2_.scaleX = _loc3_;
            _loc2_.scaleY = _loc3_;
            _loc2_.x = -_loc2_.width;
            _loc2_.y = 0;
            addRootDisplayObject(_loc2_,1001);
            if(!startWindowed)
            {
               countBackgroundImagesLoaded = countBackgroundImagesLoaded + 1;
               if(countBackgroundImagesLoaded > 1)
               {
                  mStageRef.displayState = "fullScreenInteractive";
               }
            }
         });
         mAssetLoadingComponent.getImageAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/background/right.jpg"),function(param1:ImageAsset):void
         {
            var _loc2_:DisplayObject = param1.image;
            var _loc3_:Number = viewHeight / _loc2_.height;
            _loc2_.scaleX = _loc3_;
            _loc2_.scaleY = _loc3_;
            _loc2_.x = viewWidth;
            _loc2_.y = 0;
            addRootDisplayObject(_loc2_,1001);
            if(!startWindowed)
            {
               countBackgroundImagesLoaded = countBackgroundImagesLoaded + 1;
               if(countBackgroundImagesLoaded > 1)
               {
                  mStageRef.displayState = "fullScreenInteractive";
               }
            }
         });
      }
      
      private function loadLocale() : void
      {
         Locale.loadStrings(this,localeAvailable);
         GameMasterLocale.loadGameMasterStrings(this,localeAvailable);
         mMagicWordManager = new MagicWordManager(this);
      }
      
      public function createHUD() : void
      {
         if(mHud)
         {
            return;
         }
         mHud = featureFlags.getFlagValue("starling-hud") && HudArt.begun ? new StarlingHud(this) : new UIHud(this);
      }
      
      public function refreshHUD() : void
      {
         if(featureFlags.getFlagValue("want-hud-refresh-on-floor-transition"))
         {
            mHud.refreshHUD();
         }
      }
      
      private function computeServerTimeOffset() : void
      {
         var _loc1_:Date = null;
         var _loc2_:String = mDBConfigManager.getConfigString("server_time","");
         if(_loc2_)
         {
            _loc1_ = GameClock.parseW3CDTF(_loc2_);
            GameClock.computeServerTimeOffset(_loc1_);
         }
         Logger.info("server time offset (ms): " + GameClock.serverTimeOffset);
      }
      
      override public function buildEngines() : void
      {
         Logger.info("building engines 0");
         SettingsStore.applyStartupFlags(featureFlags);
         loadBackground();
         Logger.info("building engines 1");
         loadLocale();
         Logger.info("building engines 2");
         computeServerTimeOffset();
         super.buildEngines();
         UIMouseCursors.register(this);
         mKeyBindings = new KeyBindings(inputManager);
         mUIHideToggle = new UIHideToggle(this);
         mSteamInputManager = new SteamInputManager(this,mSteamworks,mStageRef,featureFlags.getFlagValue("experimental-use-steam-input"));
         Logger.info("building engines 3");
         mSoundManager = new DBSoundManager(this);
         var _loc1_:Boolean = mDBConfigManager.getConfigBoolean("show_colliders",false);
         mSceneGraphManager.getLayer(40).visible = _loc1_;
         if(mDBConfigManager.getConfigBoolean("show_redraw_regions",false))
         {
            showRedrawRegions(true,16711680);
         }
         Logger.info("building engines 4");
         this.accountId = mDBConfigManager.getConfigNumber("AccountId",0);
         if(mAccountId == 0)
         {
            Logger.error("AccountId is 0.  Cannot continue without a valid AccountId.");
         }
         Logger.info("building engines 5");
         mDemographics = mDBConfigManager.GetValueOrDefault("Demographics",{});
         Logger.info("building engines 5.1");
         Logger.info("building engines 6");
         this.validationToken = mDBConfigManager.getConfigString("API_ValidationToken","");
         Logger.info("building engines 7");
         if(mValidationToken == "")
         {
            Logger.error("ValidationToken is empty.  Cannot continue without a valid ValidationToken.");
         }
         Logger.info("building engines 8");
         Logger.info("DBFacade: accountId: " + mAccountId.toString());
         mUILevelUpPostController = new UILevelUpPostController(this);
         mAccountBonus = new AccountBonus(this);
         createTokenRegenTask();
         logSystemMetrics();
         NODE_RULES = uint(getSplitTestBoolean("NODE_UNLOCK_GLOBAL",false));
         environmentPrefix = dbConfigManager.getConfigString("EnvironmentPrefix","u");
         mMenuNavigationController = new MenuNavigationController(this);
         mCustomSkinVisualsOverrideHandler = new CustomSkinVisualsOverrideHandler(this);
      }
      
      private function localeAvailable() : void
      {
         var _loc1_:ServiceDiscoveryReadyEvent = null;
         Logger.debug("locale available");
         if(mPendingServiceDiscoveryEvent != null && Locale.isDefaultLoaded)
         {
            _loc1_ = mPendingServiceDiscoveryEvent;
            mPendingServiceDiscoveryEvent = null;
            mEventComponent.dispatchEvent(_loc1_);
         }
      }
      
      override public function mainLoop(event:Event) : void
      {
         mSteamInputManager.runFrame();
         super.mainLoop(event);
         if(mFPSReadout)
         {
            mFPSReadout.update(mTickCounter,mWallClockTimeElapsed,mFrameAccumulator,mRenderTickCounter,mTickAccumulator);
         }
      }
      
      override protected function flushInputs() : void
      {
         super.flushInputs();
         mSteamInputManager.flushInputs();
      }
      
      private function requestNewValidationToken(gameClock:GameClock) : void
      {
         var requestFunc:Function;
         var facade:DBFacade;
         Logger.info("DBFacade: requesting new validation token");
         requestFunc = JSONRPCService.getFunction("token",this.rpcRoot + "account");
         facade = this;
         requestFunc(this.dbAccountInfo.id,this.validationToken,function(param1:String):void
         {
            Logger.info("DBFacade: success - new validation token: [Redacted]");
            facade.validationToken = param1;
         },function(param1:Error):void
         {
            Logger.info("DBFacade: requesting new validation token: ERROR:" + param1.toString());
            if(mainStateMachine.currentStateName != "RunState")
            {
               enterSocketErrorState();
            }
            else
            {
               mEventComponent.addListener("CLIENT_EXIT_COMPLETE",enterSocketErrorState);
            }
            removeTokenRegenTask();
         });
      }
      
      private function enterSocketErrorState(event:Event = null) : void
      {
         mDistributedObjectManager.enterSocketErrorState(100,Locale.getString("FACEBOOK_LOGOUT"));
         mEventComponent.removeListener("CLIENT_EXIT_COMPLETE");
      }
      
      public function createTokenRegenTask() : void
      {
         removeTokenRegenTask();
         mTokenRegenTask = mRealClockWorkManager.doEverySeconds(3600,this.requestNewValidationToken,true,"DBFacade.tokenRegen");
      }
      
      public function removeTokenRegenTask() : void
      {
         if(mTokenRegenTask)
         {
            mTokenRegenTask.destroy();
            mTokenRegenTask = null;
         }
      }
      
      override public function init(stageRef:Stage) : void
      {
         super.init(stageRef);
         mDisplayTimingSettings = new DisplayTimingSettings(stageRef);
         MemoryTracker.stage = stageRef;
         this.stageRef.showDefaultContextMenu = false;
         EventListeners.add(this.stageRef,"keyDown",toggleFullscreen);
         EventListeners.add(this.stageRef,"keyDown",altEnterFullscreen,true);
         EventListeners.add(this.stageRef,"keyDown",altEnterFullscreen);
         EventListeners.add(this.stageRef,"keyUp",releaseAltEnter,true);
         EventListeners.add(this.stageRef,"keyUp",releaseAltEnter);
         EventListeners.add(this.stageRef,"deactivate",forgetPlainEnter);
         createLetterbox();
         mInitialLoadingClip = new LoadingClass();
         mInitialLoadingClip.addFrameScript(mInitialLoadingClip.totalFrames - 1,mInitialLoadingClip.stop);
         mLoadingBar = new UIProgressBar(this,mInitialLoadingClip.loadingBar.loadingBar);
         this.loadingBarTick();
         mFPSReadout = new FPSReadout(this);
         addRootDisplayObject(mInitialLoadingClip);
         mEventComponent.addListener("enterFrame",this.stagetwo_init);
      }
      
      private function toggleFullscreen(event:KeyboardEvent) : void
      {
         if(event.keyCode == 122)
         {
            stageRef.displayState = this.stageRef.displayState == "normal" ? "fullScreenInteractive" : "normal";
         }
         if(event.keyCode == 27)
         {
            event.preventDefault();
         }
      }
      
      private function altEnterFullscreen(event:KeyboardEvent) : void
      {
         if(event.keyCode != 13)
         {
            return;
         }
         if(!mAltEnterDown)
         {
            if(!event.altKey || mPlainEnterDown)
            {
               mPlainEnterDown = true;
               return;
            }
            mAltEnterDown = true;
            stageRef.displayState = this.stageRef.displayState == "normal" ? "fullScreenInteractive" : "normal";
         }
         event.stopImmediatePropagation();
      }
      
      private function releaseAltEnter(event:KeyboardEvent) : void
      {
         if(event.keyCode != 13)
         {
            return;
         }
         mPlainEnterDown = false;
         if(!mAltEnterDown)
         {
            return;
         }
         mAltEnterDown = false;
         event.stopImmediatePropagation();
      }
      
      private function forgetPlainEnter(event:Event) : void
      {
         mPlainEnterDown = false;
      }
      
      private function createLetterbox() : void
      {
         var _loc2_:Shape = new Shape();
         _loc2_.graphics.beginFill(1968136);
         var _loc1_:Number = 10000;
         _loc2_.graphics.drawRect(-_loc1_,-_loc1_,_loc1_ + viewWidth + _loc1_,_loc1_);
         _loc2_.graphics.drawRect(-_loc1_,viewHeight,_loc1_ + viewWidth + _loc1_,_loc1_);
         _loc2_.graphics.drawRect(-_loc1_,0,_loc1_,_loc1_);
         _loc2_.graphics.drawRect(viewWidth,0,_loc1_,_loc1_);
         _loc2_.graphics.endFill();
         _loc2_.name = "OutOufBoundLetterbox";
         addRootDisplayObject(_loc2_,1000);
      }
      
      public function stagetwo_init(event:Event) : void
      {
         stagetwo_init_call_count = stagetwo_init_call_count + 1;
         if(stagetwo_init_call_count >= 2)
         {
            this.loadingBarTick();
            mEventComponent.removeListener("enterFrame");
            if(mAssetLoadingComponent == null)
            {
               mAssetLoadingComponent = new AssetLoadingComponent(this);
            }
            mEventComponent.addListener("LoadingFinishedEvent",architectureLoaded);
            mEventComponent.addListener("ConfigFileLoadedEvent",configLoaded);
            mMainStateMachine = new MainStateMachine(this);
            mMainStateMachine.enterLoadingState();
         }
      }
      
      protected function configLoaded(event:ConfigFileLoadedEvent) : void
      {
         this.loadingBarTick();
         mDBConfigManager = event.dbConfigManager;
         initMetricsLogger();
         Logger.setDebugMessages(dbConfigManager.getConfigBoolean("want_debug_logging",true));
         Logger.setInfoMessages(dbConfigManager.getConfigBoolean("want_info_logging",true));
         mEventComponent.removeListener("ConfigFileLoadedEvent");
         Logger.CustomLoggerString = dbConfigManager.getConfigString("customLoggerString",null);
         var _loc2_:String = dbConfigManager.getConfigString("ServiceDiscoveryUrl","");
         if(_loc2_ == "")
         {
            Logger.fatal("ServiceDiscoveryUrl is empty. Unable to continue.");
         }
         new ServiceDiscoveryLoader(_loc2_,onServiceDiscoveryComplete);
         mUseSteamLogin = dbConfigManager.getConfigBoolean("UseSteamLogin",true);
         if(this.getUserAgent() == "Internet Explorer" && !mDBConfigManager.getConfigBoolean("turn_off_ie_input_hack",false))
         {
            this.setupFocusHack();
         }
         mDownloadRoot = dbConfigManager.getConfigString("download_root","./");
         cacheVersion = mDBConfigManager.getConfigString("CacheVersion","development");
         buildEngines();
      }
      
      private function onServiceDiscoveryComplete(result:Object, errorCode:int, errorText:String) : void
      {
         var _loc4_:ServiceDiscoveryReadyEvent = new ServiceDiscoveryReadyEvent(result,errorCode,errorText);
         if(Locale.isDefaultLoaded)
         {
            mEventComponent.dispatchEvent(_loc4_);
         }
         else
         {
            mPendingServiceDiscoveryEvent = _loc4_;
         }
      }
      
      public function applyServiceDiscoveryResult(result:Object) : void
      {
         mWebServicesUrl = result.webServicesUrl as String;
         mGameSocketAddress = result.gameSocketAddress as String;
         mGameSocketPort = result.gameSocketPort as int;
         mGameSocketTlsOffered = result.gameSocketTls == true;
         mGameSocketWssPath = result.gameSocketWssPath != null ? String(result.gameSocketWssPath) : "";
         mWebAPIRoot = mWebServicesUrl + "/api/";
         mRPCRoot = mWebServicesUrl + "/rpc/";
         mSteamAPIRoot = mWebServicesUrl + "/steam/";
      }
      
      private function initMetricsLogger() : void
      {
         mMetricsLogger = new MetricsLogger(this,dbConfigManager.getConfigString("metrics_logging_url",""));
         Logger.errorCallback = loggerErrorCall;
      }
      
      public function toggleFpsOverlay() : void
      {
         if(mFPSReadout)
         {
            mFPSReadout.toggleVisibility();
         }
      }
      
      public function get fpsReadout() : FPSReadout
      {
         return mFPSReadout;
      }
      
      public function preLoadJson() : void
      {
         this.loadingBarTick();
         var _loc3_:String = dbConfigManager.getConfigString("gameMasterPath","Resources/Levels/DB_GameMaster_C.json");
         var _loc4_:String = buildFullDownloadPath(_loc3_);
         var _loc1_:String = buildFullDownloadPath("Resources/Levels/library_server.json");
         var _loc2_:String = buildFullDownloadPath("Resources/Combat/AttackTimeline.json");
         mAssetLoadingComponent.getJsonAsset(_loc4_,gameMasterFinishedLoading,errorLoadingGameMaster);
         mAssetLoadingComponent.getJsonAsset(_loc1_,libraryFinishedLoading,errorLoadingLibrary);
         mAssetLoadingComponent.getJsonAsset(_loc2_,timelineFinishedLoading,errorLoadingAttackTimeline);
      }
      
      private function errorLoadingGameMaster() : void
      {
         Logger.fatal("Error loading Game Master json.");
      }
      
      private function errorLoadingLibrary() : void
      {
         Logger.fatal("Error loading Server Library json.");
      }
      
      private function errorLoadingAttackTimeline() : void
      {
         Logger.fatal("Error loading Attack Timeline json.");
      }
      
      public function ClearCachedTileLibraryJson() : void
      {
         var _loc2_:JsonAsset = null;
         mTileLibraryMap.clear();
         for each(var _loc1_:Object in mJsonAssets)
         {
            _loc2_ = _loc1_ as JsonAsset;
            _loc2_.destroy();
         }
         if(mJsonAssets)
         {
            mJsonAssets.length = 0;
         }
      }
      
      public function AddTileLibraryJson(path:String, tileLibraryJson:JsonAsset) : void
      {
         mTileLibraryMap.add(path,tileLibraryJson.json);
         if(mJsonAssets == null)
         {
            mJsonAssets = [];
         }
         mJsonAssets.push(tileLibraryJson);
      }
      
      public function getTileLibraryJson(path:String) : Object
      {
         return mTileLibraryMap.itemFor(path);
      }
      
      public function get libraryJson() : Array
      {
         return mLibraryJson;
      }
      
      protected function libraryFinishedLoading(libraryJson:JsonAsset) : void
      {
         Logger.info("libraryFinishedLoading");
         this.loadingBarTick();
         mLibraryJsonLoaded = true;
         var _loc5_:int = 0;
         var _loc4_:int = 0;
         mLibraryJson = libraryJson.json as Array;
         for each(var _loc3_:Object in libraryJson.json)
         {
            _loc4_ = 0;
            for each(var _loc2_:Object in _loc3_.navCollisions)
            {
               _loc4_ += GetSecurityValue(_loc2_);
            }
            _loc5_ += _loc4_ % 541;
         }
         mSecuritySL = _loc5_ % 1097;
         checkIfFactoryReadyToLoad();
      }
      
      public function GetSecurityValue(jsonAsset:Object) : int
      {
         var _loc2_:int = 0;
         for each(var _loc3_:Object in jsonAsset)
         {
            if(getQualifiedClassName(_loc3_) == "int")
            {
               _loc2_ += Math.abs(int(_loc3_)) % 17 + Math.abs(int(_loc3_)) / 19;
            }
         }
         return _loc2_;
      }
      
      public function get timelineFactory() : TimelineFactory
      {
         return mTimelineFactory;
      }
      
      protected function timelineFinishedLoading(jsonAsset:JsonAsset) : void
      {
         Logger.info("timelineFinishedLoading");
         this.loadingBarTick();
         mTimelineFinishedLoading = true;
         mTimelineFactory = new TimelineFactory(this,jsonAsset);
         MemoryTracker.track(mTimelineFactory,"TimelineFactory - created in DBFacade.timelineFinishedLoading()");
         mSecurityTL = mTimelineFactory.securityChecksum;
         checkIfFactoryReadyToLoad();
      }
      
      protected function gameMasterFinishedLoading(gameMasterJson:JsonAsset) : void
      {
         this.loadingBarTick();
         mGameMasterJson = gameMasterJson.json;
         gameMaster = new GameMaster(mGameMasterJson,this.splitTests);
         mSecurityGM = gameMaster.securityChecksum;
         mGameMasterJsonLoaded = true;
         var _loc3_:Boolean = false;
         for each(var _loc2_:Object in mGameMasterJson.Hero)
         {
            if(_loc2_.BaseMove > 250)
            {
               _loc3_ = true;
            }
         }
         if(_loc3_)
         {
            mGameMasterJsonLoaded = false;
            blockCheater();
         }
         checkIfFactoryReadyToLoad();
      }
      
      public function blockCheater() : void
      {
         mLoadingBar.displayErrorMessage("Loading Error: Broken files have been detected in your system. \nYou must verify the integrity of the game\'s files in order to load and play the game.\nPlease visit https://discord.gg/dungeonrampage for questions or assistance with this issue.");
      }
      
      public function regenerateGameMaster() : void
      {
         if(mGameMasterJsonLoaded)
         {
            gameMaster = new GameMaster(mGameMasterJson,this.splitTests);
         }
      }
      
      protected function checkIfFactoryReadyToLoad() : void
      {
         if(mTimelineFinishedLoading && this.mGameMasterJsonLoaded && this.mLibraryJsonLoaded)
         {
            mEventComponent.dispatchEvent(new ManagersLoadedEvent());
         }
      }
      
      public function get sCode() : int
      {
         return mSecurityGM + mSecurityTL + mSecuritySL;
      }
      
      public function loadingBarTick() : void
      {
         if(mLoadingBar)
         {
            mLoadingBar.value += 0.06666666666666667;
            mLoadingBarIntStatus = mLoadingBarIntStatus + 1;
            setLoadingBarText("LOADING " + String.fromCharCode(64 + mLoadingBarIntStatus) + "...");
         }
      }
      
      public function setLoadingBarText(message:String) : void
      {
         var _loc2_:MovieClip = mInitialLoadingClip ? mInitialLoadingClip.loadingBar as MovieClip : null;
         var _loc4_:TextField = _loc2_ ? _loc2_.loading_text as TextField : null;
         if(!_loc4_ || _loc4_.text == message)
         {
            return;
         }
         Logger.info("loadingBarTick at: " + message);
         _loc4_.text = message;
         var _loc3_:Number = _loc4_.textWidth + 4;
         if(_loc3_ > _loc4_.width)
         {
            _loc4_.x -= (_loc3_ - _loc4_.width) / 2;
            _loc4_.width = _loc3_;
         }
      }
      
      public function get loadingStateLeft() : Boolean
      {
         return mMainStateMachine != null && !(mMainStateMachine.currentState is LoadingState);
      }
      
      public function powerUpDistributedObjectManager() : void
      {
         var _loc2_:Boolean = false;
         var _loc1_:GameEndpoints = null;
         var _loc3_:Boolean = false;
         Logger.info("*****************Starting powerUpDistributedObjectManager");
         this.loadingBarTick();
         if(mDistributedObjectManager == null)
         {
            if(mGameSocketAddress == null || mGameSocketAddress == "")
            {
               Logger.fatal("GameSocketAddress is empty.  Unable to continue.");
               return;
            }
            TransportSettings.applyOverrides(dbConfigManager);
            _loc2_ = dbConfigManager.getConfigBoolean("EnforceServerCertificate",true);
            _loc1_ = new GameEndpoints(mGameSocketAddress,mGameSocketPort,mGameSocketWssPath,_loc2_,mGameSocketTlsOffered);
            _loc3_ = featureFlags.getFlagValue("experimental-websocket-reconnects");
            Logger.info("WorldServer endpoints: " + _loc1_ + " experimentalWebSocketReconnects=" + _loc3_);
            mDistributedObjectManager = new DistributedObjectManager(this);
            MemoryTracker.track(mDistributedObjectManager,"DistributedObjectManager - created in DBFacade.startGame()");
            mDistributedObjectManager.Initialize(_loc1_,_loc3_,validationToken,demographicsJson,accountId,dbConfigManager.networkId,NODE_RULES);
         }
      }
      
      public function onConnectionReconnecting(reason:String) : void
      {
         Logger.warn("WorldServer connection lost, resuming: " + reason);
         mMainStateAtDrop = mMainStateMachine?.currentStateName;
         showReconnectingIndicator();
         if(!mReconnectFrozeInput && inputManager != null)
         {
            inputManager.disableControls();
            mReconnectFrozeInput = true;
         }
      }
      
      public function onConnectionReconnectAttempt(attempt:int, elapsedMilliseconds:int, graceMilliseconds:int) : void
      {
         showReconnectingIndicator();
         mReconnectingIndicator.update(attempt,elapsedMilliseconds,graceMilliseconds);
      }
      
      public function onConnectionResumed() : void
      {
         Logger.info("WorldServer connection resumed.");
         if(reconnectChangedMainState)
         {
            Logger.warn("WorldServer connection resumed into " + mMainStateMachine.currentStateName + " after dropping in " + mMainStateAtDrop);
         }
         endReconnecting();
      }
      
      public function get reconnectChangedMainState() : Boolean
      {
         return mMainStateAtDrop != null && mMainStateMachine != null && mMainStateMachine.currentStateName != mMainStateAtDrop;
      }
      
      public function onConnectionReconnectFailed() : void
      {
         Logger.warn("WorldServer connection could not be resumed.");
         endReconnecting();
      }
      
      private function endReconnecting() : void
      {
         var _loc1_:UIReconnectingIndicator = null;
         mMainStateAtDrop = null;
         if(mReconnectingIndicator != null)
         {
            _loc1_ = mReconnectingIndicator;
            mReconnectingIndicator = null;
            _loc1_.destroy();
         }
         if(mReconnectFrozeInput)
         {
            mReconnectFrozeInput = false;
            if(inputManager != null)
            {
               inputManager.enableControls();
            }
         }
      }
      
      private function showReconnectingIndicator() : void
      {
         if(mReconnectingIndicator == null)
         {
            mReconnectingIndicator = new UIReconnectingIndicator(this);
         }
         mReconnectingIndicator.show();
      }
      
      public function warningPopup(title:String, message:String) : void
      {
         var _loc3_:DBUIOneButtonPopup = new DBUIOneButtonPopup(this,"WARNING_POPUP",title,message,Locale.getString("OK"),null);
         MemoryTracker.track(_loc3_,"DBUIOneButtonPopup - created in DBFacade.warningPopup()");
      }
      
      public function errorPopup(title:String, message:String, uiLayerName:String) : void
      {
         if(menuNavigationController && menuNavigationController.getAllCurrentLayers().indexOf(uiLayerName) >= 0)
         {
            return;
         }
         var _loc4_:DBUIOneButtonPopup = new DBUIOneButtonPopup(this,uiLayerName,title,message,Locale.getString("OK"),null);
         MemoryTracker.track(_loc4_,"DBUIOneButtonPopup - created in DBFacade.errorPopup()");
      }
      
      private function getUserAgent() : String
      {
         var _loc2_:String = null;
         var _loc1_:String = null;
         try
         {
            _loc2_ = ExternalInterface.call("window.navigator.userAgent.toString");
            _loc1_ = "[Unknown Browser]";
            if(_loc2_.indexOf("Safari") != -1)
            {
               _loc1_ = "Safari";
            }
            else if(_loc2_.indexOf("Firefox") != -1)
            {
               _loc1_ = "Firefox";
            }
            else if(_loc2_.indexOf("Chrome") != -1)
            {
               _loc1_ = "Chrome";
            }
            else if(_loc2_.indexOf("MSIE") != -1)
            {
               _loc1_ = "Internet Explorer";
            }
            else if(_loc2_.indexOf("Opera") != -1)
            {
               _loc1_ = "Opera";
            }
         }
         catch(e:Error)
         {
            return "[No ExternalInterface]";
         }
         return _loc1_;
      }
      
      private function logSystemMetrics() : void
      {
         var _loc1_:Object = {};
         _loc1_.language = Capabilities.language;
         _loc1_.os = Capabilities.os;
         _loc1_.screenResX = Capabilities.screenResolutionX;
         _loc1_.screenResY = Capabilities.screenResolutionY;
         _loc1_.flashVersion = Capabilities.version;
         _loc1_.browser = this.getUserAgent();
         mMetricsLogger.log("FlashCapabilities",_loc1_);
      }
      
      public function enteringSocketError() : void
      {
         if(mInitialLoadingClip != null)
         {
            removeRootDisplayObject(mInitialLoadingClip);
            mInitialLoadingClip = null;
         }
      }
      
      protected function architectureLoaded(event:LoadingFinishedEvent) : void
      {
         this.loadingBarTick();
         mDBAccountInfo = event.dbAccountInfo;
         mEventComponent.removeListener("LoadingFinishedEvent");
         mGameClock.initTime();
         this.run();
         mMainStateMachine.start();
         if(mInitialLoadingClip != null)
         {
            removeRootDisplayObject(mInitialLoadingClip);
            mInitialLoadingClip = null;
            mLoadingBar.destroy();
            mLoadingBar = null;
         }
         mMetricsLogger.log("ArchitectureLoaded",{});
      }
      
      public function get dbConfigManager() : DBConfigManager
      {
         return mDBConfigManager;
      }
      
      public function get dbAccountInfo() : DBAccountInfo
      {
         return mDBAccountInfo;
      }
      
      public function set dbAccountInfo(dbAccInfo:DBAccountInfo) : void
      {
         mDBAccountInfo = dbAccInfo;
      }
      
      public function get gameMasterJson() : Object
      {
         return mGameMasterJson;
      }
      
      public function get hud() : IGameHud
      {
         return mHud;
      }
      
      public function get effectPool() : EffectPool
      {
         if(!mEffectPool)
         {
            mEffectPool = new EffectPool();
            MemoryTracker.track(mEffectPool,"EffectPool - created in DBFacade.effectPool getter","pool");
         }
         return mEffectPool;
      }
      
      public function get movieClipPool() : MovieClipPool
      {
         if(!mMovieClipPool)
         {
            mMovieClipPool = new MovieClipPool();
            MemoryTracker.track(mMovieClipPool,"MovieClipPool - created in DBFacade.movieClipPool getter","pool");
         }
         return mMovieClipPool;
      }
      
      public function get mainStateMachine() : MainStateMachine
      {
         return mMainStateMachine;
      }
      
      public function get heroInputSuspended() : Boolean
      {
         return mMainStateMachine != null && mMainStateMachine.currentState is LoadingScreenState;
      }
      
      public function get accountBonus() : AccountBonus
      {
         return mAccountBonus;
      }
      
      public function get metrics() : MetricsLogger
      {
         return mMetricsLogger;
      }
      
      public function get webServiceAPIRoot() : String
      {
         return mWebAPIRoot;
      }
      
      public function get webServicesUrl() : String
      {
         return mWebServicesUrl;
      }
      
      public function get playerActivityCount() : PlayerActivityCount
      {
         return mPlayerActivityCount;
      }
      
      public function set playerActivityCount(inPlayerActivityCount:PlayerActivityCount) : void
      {
         mPlayerActivityCount = inPlayerActivityCount;
      }
      
      public function get rpcRoot() : String
      {
         return mRPCRoot;
      }
      
      public function get steamAPIRoot() : String
      {
         return mSteamAPIRoot;
      }
      
      public function get downloadRoot() : String
      {
         return mDownloadRoot;
      }
      
      public function set accountId(value:uint) : *
      {
         mAccountId = value;
         JSONRPCService.accountId = value.toString();
      }
      
      public function get accountId() : uint
      {
         return mAccountId;
      }
      
      public function set validationToken(value:String) : void
      {
         mValidationToken = value;
         JSONRPCService.validationToken = value;
      }
      
      public function get validationToken() : String
      {
         return mValidationToken;
      }
      
      public function get demographics() : Object
      {
         return mDemographics;
      }
      
      public function get demographicsJson() : String
      {
         return JsonCodec.encode(mDemographics);
      }
      
      public function get steamInputManager() : SteamInputManager
      {
         return mSteamInputManager;
      }
      
      private function _textFocus(e:FocusEvent) : void
      {
         if(mStageRef.focus)
         {
            if(!(mStageRef.focus is TextField && TextField(mStageRef.focus).type == "input"))
            {
               this.regainFocus();
            }
         }
         else
         {
            this.regainFocus();
         }
      }
      
      private function setupFocusHack() : void
      {
         mHiddenFocusText = new TextField();
         mHiddenFocusText.name = "DBFacade.hiddenFocusText";
         mHiddenFocusText.type = "input";
         mHiddenFocusText.width = 1;
         mHiddenFocusText.height = 1;
         mHiddenFocusText.alpha = 0;
         mHiddenFocusText.mouseEnabled = false;
         mHiddenFocusText.tabEnabled = false;
         addRootDisplayObject(mHiddenFocusText);
         EventListeners.add(mHiddenFocusText,"focusOut",_textFocus);
         this.regainFocus();
      }
      
      public function regainFocus() : void
      {
         mStageRef.focus = mHiddenFocusText ? mHiddenFocusText : mStageRef;
      }
      
      public function get textInputHasFocus() : Boolean
      {
         var _loc1_:TextField = mStageRef.focus as TextField;
         return _loc1_ != null && _loc1_.type == "input" && _loc1_ != mHiddenFocusText;
      }
      
      public function loggerErrorCall(logString:String) : void
      {
         var _loc2_:Object = null;
         if(this.metrics && logicalWorkManager != null)
         {
            _loc2_ = {};
            _loc2_.details = logString;
            if(mDelayErrors == null)
            {
               mDelayErrors = [];
            }
            mDelayErrors.push(_loc2_);
            if(mLogicalWorkComponent == null)
            {
               mLogicalWorkComponent = new LogicalWorkComponent(this,"DBFacade");
            }
            if(mErrorTask == null)
            {
               mErrorTask = mLogicalWorkComponent.doLater(2,sendErrors);
            }
         }
      }
      
      private function sendErrors(t:*) : void
      {
         var _loc2_:Array = null;
         mErrorTask = null;
         if(mDelayErrors != null)
         {
            _loc2_ = mDelayErrors;
            mDelayErrors = null;
            t = 0;
            while(t < _loc2_.length)
            {
               this.metrics.log("CLIENT_ERROR_EVENT",_loc2_[t]);
               t++;
            }
         }
      }
      
      public function get splitTests() : Object
      {
         return this.dbConfigManager.GetValueOrDefault("SplitTests",{});
      }
      
      public function getSplitTestNumber(key:String, defaultValue:Number) : Number
      {
         for each(var _loc3_:Object in this.splitTests)
         {
            if(_loc3_.name == key)
            {
               return Number(_loc3_.value);
            }
         }
         Logger.debug("splitTestValueFor test not found: " + key);
         return defaultValue;
      }
      
      public function getSplitTestBoolean(key:String, defaultValue:Boolean) : Boolean
      {
         for each(var _loc3_:Object in this.splitTests)
         {
            if(_loc3_.name == key)
            {
               Logger.debug("splitTestValueFor " + key + ": " + _loc3_.value);
               return _loc3_.value == "true";
            }
         }
         Logger.debug("splitTestValueFor test not found: " + key);
         return defaultValue;
      }
      
      public function getSplitTestString(key:String, defaultValue:String) : String
      {
         for each(var _loc3_:Object in this.splitTests)
         {
            if(_loc3_.name == key)
            {
               return _loc3_.value;
            }
         }
         Logger.debug("splitTestValueFor test not found: " + key);
         return defaultValue;
      }
      
      public function receiveDailyRewards() : void
      {
      }
      
      public function getInfiniteDungeonDetailForNodeId(nodeId:uint) : InfiniteMapNodeDetail
      {
         return mDistributedObjectManager.mMatchMaker.getInfiniteDungeonDetailForNodeId(nodeId);
      }
      
      public function overlaySteamwithURL(urlLink:String) : void
      {
         var _loc3_:URLRequest = null;
         var _loc2_:Boolean = Boolean(mSteamworks.isOverlayEnabled());
         var _loc4_:Boolean = stageRef.displayState == "fullScreenInteractive";
         if(_loc2_ && _loc4_)
         {
            Logger.debug("Using activateGameOverlayToStore to open steam page");
            mSteamworks.activateGameOverlayToWebPage(urlLink);
         }
         else
         {
            Logger.debug("Using navigateToURL to open steam page because isOverlayEnabled:" + _loc2_ + " isFullscreen:" + _loc4_);
            _loc3_ = new URLRequest(urlLink);
            navigateToURL(_loc3_,"_blank");
         }
      }
      
      public function overlaySteamBasedOnAppId(appId:uint) : void
      {
         overlaySteamwithURL("https://store.steampowered.com/app/" + appId + "/");
      }
      
      public function get menuNavigationController() : MenuNavigationController
      {
         return mMenuNavigationController;
      }
      
      public function get customSkinVisualsOverrideHandler() : CustomSkinVisualsOverrideHandler
      {
         return mCustomSkinVisualsOverrideHandler;
      }
      
      public function get keyBindings() : KeyBindings
      {
         return mKeyBindings;
      }
      
      public function get uiHideToggle() : UIHideToggle
      {
         return mUIHideToggle;
      }
      
      public function get settingsModel() : SettingsModel
      {
         if(mSettingsModel == null)
         {
            mSettingsModel = new SettingsModel(this);
            MemoryTracker.track(mSettingsModel,"SettingsModel - created in DBFacade.settingsModel");
         }
         return mSettingsModel;
      }
      
      public function get displayTimingSettings() : DisplayTimingSettings
      {
         return mDisplayTimingSettings;
      }
   }
}

