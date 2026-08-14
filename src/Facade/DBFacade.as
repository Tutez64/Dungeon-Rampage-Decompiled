package Facade
{
   import Account.AccountBonus;
   import Account.DBAccountInfo;
   import Account.FacebookAccountInfo;
   import Account.StoreServices;
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.ImageAsset;
   import Brain.AssetRepository.JsonAsset;
   import Brain.Clock.GameClock;
   import Brain.Facade.Facade;
   import Brain.Logger.Logger;
   import Brain.Render.MovieClipPool;
   import Brain.UI.UIProgressBar;
   import Brain.Utils.MemoryTracker;
   import Brain.WorkLoop.LogicalWorkComponent;
   import Brain.WorkLoop.Task;
   import Brain.jsonRPC.JSONRPCService;
   import Combat.Attack.TimelineFactory;
   import Config.ConfigFileLoadedEvent;
   import Config.DBConfigManager;
   import Config.ServiceDiscoveryLoader;
   import Config.ServiceDiscoveryReadyEvent;
   import DistributedObjects.DistributedObjectManager;
   import Effects.CustomSkinVisualsOverrideHandler;
   import Effects.EffectPool;
   import Events.ManagersLoadedEvent;
   import FacebookAPI.DBFacebookAPIController;
   import GameMasterDictionary.GameMaster;
   import GeneratedCode.InfiniteMapNodeDetail;
   import Input.MenuNavigationController;
   import MagicWords.MagicWordManager;
   import Metrics.MetricsLogger;
   import Metrics.PixelTracker;
   import Sound.DBSoundManager;
   import StateMachine.MainStateMachine.LoadingFinishedEvent;
   import StateMachine.MainStateMachine.MainStateMachine;
   import SteamAchievements.SteamAchievementsManager;
   import SteamInput.SteamInputManager;
   import Town.AdManager;
   import UI.Hud.UIHud;
   import UI.Map.PlayerActivityCount;
   import UI.Popup.DBUIOneButtonPopup;
   import avmplus.getQualifiedClassName;
   import com.amanitadesign.steam.FRESteamWorks;
   import com.maccherone.json.JSON;
   import flash.display.DisplayObject;
   import flash.display.Loader;
   import flash.display.LoaderInfo;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.events.FocusEvent;
   import flash.events.IOErrorEvent;
   import flash.events.KeyboardEvent;
   import flash.events.SecurityErrorEvent;
   import flash.external.ExternalInterface;
   import flash.net.URLRequest;
   import flash.net.navigateToURL;
   import flash.profiler.showRedrawRegions;
   import flash.system.Capabilities;
   import flash.system.LoaderContext;
   import flash.system.Security;
   import flash.text.TextField;
   import org.as3commons.collections.Map;
   
   public class DBFacade extends Facade
   {
      
      private static const CLIENT_ERROR_EVENT:String = "CLIENT_ERROR_EVENT";
      
      public static const VALIDATION_REFRESH_TIME:Number = 3600;
      
      private static const ORDER_COMPLETE_EXTERNAL_INTERFACE:String = "orderComplete";
      
      private static var mDownloadRoot:String = "";
      
      public static const NETWORK_FACEBOOK:uint = 1;
      
      public static const NETWORK_KONGREGATE:uint = 2;
      
      public static const NETWORK_DRCOM:uint = 3;
      
      private var LoadingClass:Class = loading_screen_swf;
      
      private var mInitialLoadingClip:MovieClip;
      
      private var mLoadingBar:UIProgressBar;
      
      private var mLoadingBarIntStatus:Number = 0;
      
      protected var mMainStateMachine:MainStateMachine;
      
      protected var mDBAccountInfo:DBAccountInfo;
      
      protected var mFacebookAccountInfo:FacebookAccountInfo;
      
      protected var mDBConfigManager:DBConfigManager;
      
      protected var mHud:UIHud;
      
      protected var mEffectPool:EffectPool;
      
      protected var mMovieClipPool:MovieClipPool;
      
      protected var mMetricsLogger:MetricsLogger;
      
      protected var mTileLibraryMap:Map;
      
      protected var mJsonAssets:Array;
      
      protected var mLibraryJsonLoaded:Boolean = false;
      
      protected var mTimelineFinishedLoading:Boolean = false;
      
      protected var mTimelineFactory:TimelineFactory;
      
      protected var mGameMasterJsonLoaded:Boolean = false;
      
      protected var mLibraryJson:Array;
      
      protected var mGameMasterJson:Object;
      
      protected var mDBFaceBookAPIController:DBFacebookAPIController;
      
      protected var mAccountBonus:AccountBonus;
      
      protected var mMenuNavigationController:MenuNavigationController;
      
      protected var mCustomSkinVisualsOverrideHandler:CustomSkinVisualsOverrideHandler;
      
      public var gameMaster:GameMaster;
      
      protected var mAssetLoader:AssetLoadingComponent;
      
      protected var mMagicWordManager:MagicWordManager;
      
      public var steamAchievementsManager:SteamAchievementsManager;
      
      private var mWebServicesUrl:String;
      
      private var mGameSocketAddress:String;
      
      private var mGameSocketPort:int;
      
      private var mGameSocketFallbackPort:int = 0;
      
      private var mWebAPIRoot:String;
      
      private var mPendingServiceDiscoveryEvent:ServiceDiscoveryReadyEvent;
      
      private var mRPCRoot:String;
      
      private var mSteamAPIRoot:String;
      
      private var mPlayerActivityCount:PlayerActivityCount;
      
      private var mAccountId:uint;
      
      private var mFacebookId:String;
      
      private var mFacebookPlayerId:String;
      
      private var mFacebookThirdPartyId:String;
      
      private var mFacebookApplication:String;
      
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
      
      private var mKongregate:*;
      
      private var mKongregatePlayerId:String;
      
      private var mSecurityGM:int = 0;
      
      private var mSecurityTL:int = 0;
      
      private var mSecuritySL:int = 0;
      
      protected var mAdManager:AdManager;
      
      public var mSteamworks:FRESteamWorks = new FRESteamWorks();
      
      public var mSteamUserId:String;
      
      public var mSteamAppId:uint = 0;
      
      public var mSteamPersonaName:String;
      
      public var mSteamWebApiAuthTicket:String;
      
      public var mSteamAuthTicketHandle:uint;
      
      public var mUseSteamLogin:Boolean;
      
      public var mSeenFlaggedPopup:Boolean;
      
      public var mSteamIsFlagged:Boolean;
      
      public var mSteamFlaggedUntilAfterDateString:String;
      
      public var mSteamIsFlaggedDueToFamilySharingOwnerIsFlagged:Boolean;
      
      public var mSteamIsFlaggedDueToFamilySharingOwnerName:String;
      
      private var mSteamInputManager:SteamInputManager;
      
      public var mAdditionalConfigFilesToLoad:Array = [];
      
      private var mShowCollisions:Boolean = false;
      
      public var NODE_RULES:uint = 0;
      
      private var tKongregateLoader:Loader;
      
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
         Security.loadPolicyFile("http://profile.ak.fbcdn.net/crossdomain.xml");
         Security.loadPolicyFile("https://fbstatic-a.akamaihd.net/crossdomain.xml");
         Security.loadPolicyFile("https://fbcdn-profile-a.akamaihd.net/crossdomain.xml");
         Security.loadPolicyFile("https://profile-a.xx.fbcdn.net/crossdomain.xml");
         Security.loadPolicyFile("https://profile-b.xx.fbcdn.net/crossdomain.xml");
         Security.allowDomain("http://profile.ak.fbcdn.net");
         Security.allowInsecureDomain("https://profile.ak.fbcdn.net");
         Security.allowDomain("http://profile-a.xx.fbcdn.net");
         Security.allowInsecureDomain("https://profile-a.xx.fbcdn.net");
         Security.allowDomain("http://profile-a.xx.fbcdn.net/hprofile-snc6/");
         Security.allowInsecureDomain("https://profile-a.xx.fbcdn.net/hprofile-snc6/");
         Security.allowDomain("http://fbcdn-profile-a.akamaihd.net");
         Security.allowInsecureDomain("https://fbcdn-profile-a.akamaihd.net");
         Security.allowDomain("http://fbcdn-profile-a.akamaihd.net/hprofile-ak-snc4/");
         Security.allowInsecureDomain("https://fbcdn-profile-a.akamaihd.net/hprofile-ak-snc4/");
         Security.allowDomain("http://fbcdn-profile-a.akamaihd.net/hprofile-ash4/");
         Security.allowInsecureDomain("https://fbcdn-profile-a.akamaihd.net/hprofile-ash4/");
         Security.allowDomain("http://fbcdn-profile-a.akamaihd.net/hprofile-ak-ash4/");
         Security.allowInsecureDomain("https://fbcdn-profile-a.akamaihd.net/hprofile-ak-ash4/");
         Security.allowDomain("http://fbstatic-a.akamaihd.net");
         Security.allowInsecureDomain("https://fbstatic-a.akamaihd.net");
         Security.allowDomain("http://s-static.ak.facebook.com");
         Security.allowInsecureDomain("https://s-static.ak.facebook.com");
         Security.loadPolicyFile("https://ads.sele.co/crossdomain.xml");
         Security.allowDomain("http://ads.sele.co");
         Security.allowInsecureDomain("https://ads.sele.co");
         Security.loadPolicyFile("https://dungionbusters.webfetti.com/crossdomain.xml");
         Security.allowDomain("https://dungionbusters.webfetti.com");
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
         return mDownloadRoot + rawAssetPath;
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
         mAssetLoader.getImageAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/background/left.jpg"),function(param1:ImageAsset):void
         {
            var _loc2_:DisplayObject = param1.image;
            var _loc3_:Number = viewHeight / _loc2_.height;
            _loc2_.scaleX = _loc3_;
            _loc2_.scaleY = _loc3_;
            _loc2_.x = -_loc2_.width;
            _loc2_.y = 0;
            addRootDisplayObject(_loc2_,1001);
            countBackgroundImagesLoaded = countBackgroundImagesLoaded + 1;
            if(countBackgroundImagesLoaded > 1)
            {
               mStageRef.displayState = "fullScreenInteractive";
            }
         });
         mAssetLoader.getImageAsset(DBFacade.buildFullDownloadPath("Resources/Art2D/background/right.jpg"),function(param1:ImageAsset):void
         {
            var _loc2_:DisplayObject = param1.image;
            var _loc3_:Number = viewHeight / _loc2_.height;
            _loc2_.scaleX = _loc3_;
            _loc2_.scaleY = _loc3_;
            _loc2_.x = viewWidth;
            _loc2_.y = 0;
            addRootDisplayObject(_loc2_,1001);
            countBackgroundImagesLoaded = countBackgroundImagesLoaded + 1;
            if(countBackgroundImagesLoaded > 1)
            {
               mStageRef.displayState = "fullScreenInteractive";
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
         mHud = new UIHud(this);
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
         loadBackground();
         Logger.info("building engines 1");
         loadLocale();
         Logger.info("building engines 2");
         computeServerTimeOffset();
         super.buildEngines();
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
         mFacebookId = mDBConfigManager.getConfigString("FacebookAppId","");
         mFacebookPlayerId = mDBConfigManager.getConfigString("FacebookPlayerId","");
         mKongregatePlayerId = mDBConfigManager.getConfigString("KongregatePlayerId","");
         Logger.info("building engines 5.1");
         mFacebookThirdPartyId = mDBConfigManager.getConfigString("FacebookThirdPartyId","0");
         mFacebookApplication = mDBConfigManager.getConfigString("FacebookApplication","");
         Logger.info("building engines 6");
         this.validationToken = mDBConfigManager.getConfigString("API_ValidationToken","");
         Logger.info("building engines 7" + mValidationToken);
         if(mValidationToken == "")
         {
            Logger.error("ValidationToken is empty.  Cannot continue without a valid ValidationToken.");
         }
         Logger.info("building engines 8");
         Logger.info("DBFacade: accountId: " + mAccountId.toString() + " facebookId: " + mFacebookId.toString() + " Facebook Player Id:" + mFacebookPlayerId.toString() + " Facebook Application:" + mFacebookApplication.toString());
         mDBFaceBookAPIController = new DBFacebookAPIController(this);
         mFacebookAccountInfo = new FacebookAccountInfo(this);
         mAccountBonus = new AccountBonus(this);
         createTokenRegenTask();
         if(isKongregatePlayer)
         {
            kongregateInit();
         }
         logSystemMetrics();
         NODE_RULES = uint(getSplitTestBoolean("NODE_UNLOCK_GLOBAL",false));
         environmentPrefix = dbConfigManager.getConfigString("EnvironmentPrefix","u");
         mMenuNavigationController = new MenuNavigationController(this);
         mCustomSkinVisualsOverrideHandler = new CustomSkinVisualsOverrideHandler(this);
      }
      
      private function kongregateInit() : void
      {
         var request:URLRequest;
         var context:LoaderContext;
         var paramObj:Object = LoaderInfo(stageRef.root.loaderInfo).parameters;
         var apiPath:String = paramObj.kongregate_api_path || "http://www.kongregate.com/flash/API_AS3_Local.swf";
         Security.allowDomain(apiPath);
         Logger.info("Loading Kongregate swf " + apiPath);
         request = new URLRequest(apiPath);
         context = new LoaderContext();
         context.checkPolicyFile = true;
         tKongregateLoader = new Loader();
         tKongregateLoader.contentLoaderInfo.addEventListener("complete",kongregateLoaded);
         tKongregateLoader.contentLoaderInfo.addEventListener("ioError",function(param1:IOErrorEvent):void
         {
            Logger.error("IOErrorEvent: " + param1.toString() + " Data:" + request.data.toString() + " URL:" + apiPath.toString());
         });
         tKongregateLoader.contentLoaderInfo.addEventListener("securityError",function(param1:SecurityErrorEvent):void
         {
            Logger.error("SecurityErrorEvent: " + param1.toString() + " Data:" + request.data.toString() + " URL:" + apiPath.toString());
         });
         tKongregateLoader.load(request,context);
         addRootDisplayObject(tKongregateLoader);
      }
      
      public function kongregateLoaded(event:Event) : void
      {
         Logger.info("Kongregate swf loaded");
         mKongregate = event.target.content;
         Logger.info("Connecting to Kongregate");
         if(mKongregate.services == null)
         {
            Logger.info("Kongregate services is null!");
         }
         else
         {
            mKongregate.services.connect();
         }
         removeRootDisplayObject(tKongregateLoader);
         tKongregateLoader = null;
         mKongregate.stats.submit("initialized",1);
      }
      
      public function get kongregateAPI() : *
      {
         return mKongregate;
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
         MemoryTracker.stage = stageRef;
         this.setupExternalInterfaces();
         this.stageRef.showDefaultContextMenu = false;
         this.stageRef.addEventListener("keyDown",toggleFullscreen);
         createLetterbox();
         mInitialLoadingClip = new LoadingClass();
         mLoadingBar = new UIProgressBar(this,mInitialLoadingClip.loadingBar.loadingBar);
         this.loadingBarTick();
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
            mAssetLoader = new AssetLoadingComponent(this);
            mEventComponent.addListener("LoadingFinishedEvent",architectureLoaded);
            mEventComponent.addListener("ConfigFileLoadedEvent",configLoaded);
            mMainStateMachine = new MainStateMachine(this);
            mMainStateMachine.enterLoadingState();
         }
      }
      
      private function setupExternalInterfaces() : void
      {
         if(ExternalInterface.available)
         {
            ExternalInterface.addCallback("orderComplete",function(param1:String, param2:uint):void
            {
               StoreServices.orderCompleteCallback(this as DBFacade,param1,param2);
            });
            ExternalInterface.addCallback("earnCurrencyCallback",function(param1:Object):void
            {
               if(param1 && param1.vc_amount > 0)
               {
                  mDBAccountInfo.getUsersFullAccountInfo();
               }
               mMetricsLogger.log("FacebookEarnCallback");
            });
            Logger.debug("ExternalInterface setup complete");
         }
         else
         {
            trace("ExternalInterface not available");
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
         mGameSocketFallbackPort = result.gameSocketFallbackPort != null ? int(result.gameSocketFallbackPort) : 0;
         mWebAPIRoot = mWebServicesUrl + "/api/";
         mRPCRoot = mWebServicesUrl + "/rpc/";
         mSteamAPIRoot = mWebServicesUrl + "/steam/";
      }
      
      private function initMetricsLogger() : void
      {
         mMetricsLogger = new MetricsLogger(this,dbConfigManager.getConfigString("metrics_logging_url",""));
         Logger.errorCallback = loggerErrorCall;
      }
      
      public function preLoadJson() : void
      {
         this.loadingBarTick();
         var _loc3_:String = dbConfigManager.getConfigString("gameMasterPath","Resources/Levels/DB_GameMaster.json");
         var _loc4_:String = buildFullDownloadPath(_loc3_);
         var _loc1_:String = buildFullDownloadPath("Resources/Levels/library_server.json");
         var _loc2_:String = buildFullDownloadPath("Resources/Combat/AttackTimeline.json");
         mAssetLoader.getJsonAsset(_loc4_,gameMasterFinishedLoading,errorLoadingGameMaster);
         mAssetLoader.getJsonAsset(_loc1_,libraryFinishedLoading,errorLoadingLibrary);
         mAssetLoader.getJsonAsset(_loc2_,timelineFinishedLoading,errorLoadingAttackTimeline);
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
      
      public function get facebookAccountInfo() : FacebookAccountInfo
      {
         return mFacebookAccountInfo;
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
         var _loc2_:TextField = null;
         var _loc1_:String = null;
         if(mLoadingBar)
         {
            mLoadingBar.value += 0.06666666666666667;
            mLoadingBarIntStatus = mLoadingBarIntStatus + 1;
            if(mLoadingBar.root.parent as MovieClip && (mLoadingBar.root.parent as MovieClip).loading_text)
            {
               _loc2_ = (mLoadingBar.root.parent as MovieClip).loading_text as TextField;
               _loc1_ = "LOADING " + String.fromCharCode(64 + mLoadingBarIntStatus) + "...";
               Logger.info("loadingBarTick at: " + _loc1_);
               _loc2_.text = _loc1_;
            }
         }
      }
      
      public function powerUpDistributedObjectManager() : void
      {
         var _loc1_:Boolean = false;
         var _loc2_:int = 0;
         Logger.info("*****************Starting powerUpDistributedObjectManager");
         this.loadingBarTick();
         if(mDistributedObjectManager == null)
         {
            if(mGameSocketAddress == null || mGameSocketAddress == "")
            {
               Logger.fatal("GameSocketAddress is empty.  Unable to continue.");
               return;
            }
            _loc1_ = featureFlags.getFlagValue("use-fallback-socket-port");
            _loc2_ = _loc1_ ? mGameSocketFallbackPort : mGameSocketPort;
            if(_loc2_ == 0)
            {
               Logger.fatal("GameSocketPort is empty (useFallback=" + _loc1_ + ").  Unable to continue.");
               return;
            }
            Security.loadPolicyFile("xmlsocket://" + mGameSocketAddress + ":843");
            mDistributedObjectManager = new DistributedObjectManager(this);
            MemoryTracker.track(mDistributedObjectManager,"DistributedObjectManager - created in DBFacade.startGame()");
            mDistributedObjectManager.Initialize(mGameSocketAddress,_loc2_,validationToken,demographicsJson,accountId,dbConfigManager.networkId,NODE_RULES);
         }
      }
      
      public function warningPopup(title:String, message:String) : void
      {
         var _loc3_:DBUIOneButtonPopup = new DBUIOneButtonPopup(this,title,message,Locale.getString("OK"),null);
         MemoryTracker.track(_loc3_,"DBUIOneButtonPopup - created in DBFacade.warningPopup()");
      }
      
      public function errorPopup(title:String, message:String, UILayerName:String = "") : void
      {
         var _loc4_:DBUIOneButtonPopup = new DBUIOneButtonPopup(this,title,message,Locale.getString("OK"),null,true,null,null,null,UILayerName);
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
         mDBAccountInfo.checkFriendsHash();
         PixelTracker.returnDAU(this);
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
      
      public function get hud() : UIHud
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
      
      public function get facebookController() : DBFacebookAPIController
      {
         return mDBFaceBookAPIController;
      }
      
      public function get isFacebookPlayer() : Boolean
      {
         return dbConfigManager.networkId == 1;
      }
      
      public function get isKongregatePlayer() : Boolean
      {
         return dbConfigManager.networkId == 2;
      }
      
      public function get isDRPlayer() : Boolean
      {
         return dbConfigManager.networkId == 3;
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
      
      public function get facebookId() : String
      {
         return mFacebookId;
      }
      
      public function get kongregatePlayerId() : String
      {
         return mKongregatePlayerId;
      }
      
      public function get facebookPlayerId() : String
      {
         return mFacebookPlayerId;
      }
      
      public function get facebookThirdPartyId() : String
      {
         return mFacebookThirdPartyId;
      }
      
      public function set facebookThirdPartyId(value:String) : void
      {
         mFacebookThirdPartyId = value;
      }
      
      public function get facebookApplication() : String
      {
         return mFacebookApplication;
      }
      
      public function get demographics() : Object
      {
         return mDemographics;
      }
      
      public function get demographicsJson() : String
      {
         return com.maccherone.json.JSON.encode(mDemographics);
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
         mHiddenFocusText.addEventListener("focusOut",_textFocus);
         this.regainFocus();
      }
      
      public function regainFocus() : void
      {
         mStageRef.focus = mHiddenFocusText ? mHiddenFocusText : mStageRef;
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
      
      public function get adManager() : AdManager
      {
         return mAdManager;
      }
      
      public function set adManager(manager:AdManager) : void
      {
         mAdManager = manager;
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
   }
}

