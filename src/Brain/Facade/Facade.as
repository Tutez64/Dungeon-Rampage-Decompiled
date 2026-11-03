package Brain.Facade
{
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.AssetRepository;
   import Brain.Camera.BackgroundFader;
   import Brain.Camera.Camera;
   import Brain.Camera.LetterboxEffect;
   import Brain.Clock.GameClock;
   import Brain.Clock.RenderClock;
   import Brain.Event.EventComponent;
   import Brain.Event.EventListeners;
   import Brain.Event.EventManager;
   import Brain.GameObject.GameObjectManager;
   import Brain.GameObject.View;
   import Brain.Input.InputManager;
   import Brain.Logger.Logger;
   import Brain.MouseCursor.MouseCursorManager;
   import Brain.Render.FlashRendererFactory;
   import Brain.Render.FlashRenderingBackend;
   import Brain.Render.IRenderingBackend;
   import Brain.Render.RendererFactorySelector;
   import Brain.Render.StarlingRendererFactory;
   import Brain.Render.StarlingRenderingBackend;
   import Brain.Render.Tweens.TweeningProxy;
   import Brain.SceneGraph.SceneGraphManager;
   import Brain.Sound.SoundManager;
   import Brain.Starling.StarlingLayerManager;
   import Brain.Starling.StarlingRollerProvider;
   import Brain.Utils.FeatureFlags;
   import Brain.Utils.TextUtil;
   import Brain.WorkLoop.WorkLoopManager;
   import Brain.jsonRPC.JSONRPCService;
   import Collections.Map;
   import flash.display.DisplayObject;
   import flash.display.Sprite;
   import flash.display.Stage;
   import flash.events.Event;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import flash.utils.Dictionary;
   
   public class Facade
   {
      
      public static const MAX_TICKS_PER_FRAME:int = 5;
      
      public static const FPS:uint = 24;
      
      public static const DESIGN_WIDTH:Number = 1920;
      
      public static const DESIGN_HEIGHT:Number = 1080;
      
      protected var mElapsedTime:Number = 0;
      
      protected var mStageRef:Stage;
      
      private var mSwfWidth:Number;
      
      private var mSwfHeight:Number;
      
      protected var mScalingRoot:Sprite;
      
      protected var mSceneGraphManager:SceneGraphManager;
      
      protected var mInputManager:InputManager;
      
      protected var mRealClockWorkManager:WorkLoopManager;
      
      protected var mLogicalWorkManager:WorkLoopManager;
      
      protected var mPhysicsWorkManager:WorkLoopManager;
      
      protected var mPreRenderWorkManager:WorkLoopManager;
      
      protected var mLayerRenderWorkManager:WorkLoopManager;
      
      protected var mGameObjectManager:GameObjectManager;
      
      protected var mEventManager:EventManager;
      
      protected var mSoundManager:SoundManager;
      
      protected var mCamera:Camera;
      
      protected var mAssetRepository:AssetRepository;
      
      protected var mMouseCursorManager:MouseCursorManager;
      
      protected var mStarlingLayerManager:StarlingLayerManager;
      
      protected var mFlashRenderingBackend:FlashRenderingBackend;
      
      protected var mStarlingRenderingBackend:StarlingRenderingBackend;
      
      protected var mRendererFactorySelector:RendererFactorySelector;
      
      protected var mAssetLoadingComponent:AssetLoadingComponent;
      
      public var mTween:TweeningProxy;
      
      protected var mGameClock:GameClock;
      
      protected var mRealClock:GameClock;
      
      public var featureFlags:FeatureFlags;
      
      private var mViewScale:Number = 1;
      
      protected var mEventComponent:EventComponent;
      
      public var cacheVersion:String = "";
      
      public var versions:Object = null;
      
      public var environmentPrefix:String = "u";
      
      protected var mAssetRepositoryClass:Class = AssetRepository;
      
      protected var mWantConsole:Boolean = false;
      
      protected var mWantFramerateEnforcement:Boolean = false;
      
      protected var mFrameTimes:Vector.<int>;
      
      protected var mCurrentTime:Number = 0;
      
      private var mSkippingFrame:Boolean = false;
      
      private var mSkippedFrames:int = 0;
      
      private var mCheaterLogMap:Map;
      
      protected var mWallClockTimeElapsed:Number = 0;
      
      private var mGameClockTimeElapsed:Number = 0;
      
      protected var mTickCounter:int = 0;
      
      private var mCheatCount:int = 0;
      
      protected var mRenderTickCounter:int = 0;
      
      private var mRenderClockTimeElapsed:Number = 0;
      
      private var mTickLength:Number = -1;
      
      protected var mFrameAccumulator:Number = 0;
      
      protected var mTickAccumulator:Number = 0;
      
      private var mInitialLoginTraceId:String;
      
      private var mSessionInfoString:String = "Loading...";
      
      private var mSessionIdTextField:TextField;
      
      private var mSessionIdVisible:Boolean = true;
      
      private var mChildLayer:Dictionary = new Dictionary(true);
      
      public function Facade()
      {
         super();
         mFrameTimes = new Vector.<int>();
         mCheaterLogMap = new Map();
      }
      
      public function fileVersion(filename:String) : String
      {
         if(versions == null)
         {
            return cacheVersion;
         }
         var _loc2_:String = filename.indexOf("../../..") == 0 ? filename.substr(8) : filename;
         return versions[_loc2_] == null ? cacheVersion : versions[_loc2_];
      }
      
      public function get stageRef() : Stage
      {
         return mStageRef;
      }
      
      public function get viewWidth() : Number
      {
         return 1920;
      }
      
      public function get viewHeight() : Number
      {
         return 1080;
      }
      
      public function get viewScale() : Number
      {
         return mViewScale;
      }
      
      public function get starlingLayerManager() : StarlingLayerManager
      {
         return mStarlingLayerManager;
      }
      
      public function get flashRenderingBackend() : IRenderingBackend
      {
         return mFlashRenderingBackend;
      }
      
      public function get starlingRenderingBackend() : IRenderingBackend
      {
         return mStarlingRenderingBackend;
      }
      
      public function get rendererFactorySelector() : RendererFactorySelector
      {
         return mRendererFactorySelector;
      }
      
      public function get scalingRoot() : Sprite
      {
         return mScalingRoot;
      }
      
      public function set scalingRoot(inSprite:Sprite) : void
      {
         mScalingRoot = inSprite;
      }
      
      public function designLocalToGlobal(other:DisplayObject, point:Point) : Point
      {
         var _loc3_:Point = other.localToGlobal(point);
         return mScalingRoot.globalToLocal(_loc3_);
      }
      
      public function designGlobalToLocal(point:Point) : Point
      {
         var _loc2_:Point = mScalingRoot.localToGlobal(point);
         return mStageRef.globalToLocal(_loc2_);
      }
      
      protected function updateScaling(event:Event = null) : void
      {
         var _loc3_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc4_:Number = Math.min(mStageRef.stageWidth / viewWidth,mStageRef.stageHeight / viewHeight);
         mScalingRoot.scaleX = _loc4_;
         mScalingRoot.scaleY = _loc4_;
         mViewScale = _loc4_;
         mScalingRoot.x = (mStageRef.stageWidth - viewWidth * _loc4_) * 0.5;
         mScalingRoot.y = (mStageRef.stageHeight - viewHeight * _loc4_) * 0.5;
         if(mStarlingRenderingBackend != null)
         {
            _loc3_ = 1920 * _loc4_;
            _loc2_ = 1080 * _loc4_;
            mStarlingRenderingBackend.updateViewPort(new Rectangle((mStageRef.stageWidth - _loc3_) * 0.5,(mStageRef.stageHeight - _loc2_) * 0.5,_loc3_,_loc2_));
         }
      }
      
      public function addRootDisplayObject(child:DisplayObject, layer:Number = 0) : DisplayObject
      {
         var _loc3_:DisplayObject = null;
         var _loc4_:Number = NaN;
         var _loc5_:Number = mScalingRoot.numChildren - 1;
         while(_loc5_ >= 0)
         {
            _loc3_ = mScalingRoot.getChildAt(_loc5_);
            _loc4_ = Number(_loc3_ in mChildLayer ? mChildLayer[_loc3_] : 0);
            if(layer >= _loc4_)
            {
               break;
            }
            _loc5_--;
         }
         mChildLayer[child] = layer;
         return mScalingRoot.addChildAt(child,_loc5_ + 1);
      }
      
      public function removeRootDisplayObject(child:DisplayObject) : DisplayObject
      {
         delete mChildLayer[child];
         return mScalingRoot.removeChild(child);
      }
      
      public function get camera() : Camera
      {
         return mCamera;
      }
      
      public function get popupCurtainBlockMouse() : Boolean
      {
         return true;
      }
      
      public function buildEngines() : void
      {
         mSceneGraphManager = new SceneGraphManager(this);
         mGameObjectManager = new GameObjectManager(this);
         mInputManager = new InputManager(this);
         mSoundManager = new SoundManager(this);
         mMouseCursorManager = new MouseCursorManager(this);
         mFlashRenderingBackend = new FlashRenderingBackend(this);
         mRendererFactorySelector = new RendererFactorySelector(this);
         mRendererFactorySelector.registerFlashFactory(new FlashRendererFactory(this,mFlashRenderingBackend));
      }
      
      public function initStarlingRendering() : void
      {
         var starlingFactory:StarlingRendererFactory;
         mStarlingRenderingBackend = new StarlingRenderingBackend(this);
         if(mAssetLoadingComponent == null)
         {
            mAssetLoadingComponent = new AssetLoadingComponent(this);
         }
         mStarlingRenderingBackend.onContextReady = function():void
         {
            mStarlingRenderingBackend.contextReady = true;
            mAssetLoadingComponent.initializeStarlingAssetManager();
         };
         mStarlingRenderingBackend.init(this,mStageRef,1920,1080);
         mStarlingLayerManager = StarlingRenderingBackend(mStarlingRenderingBackend).starlingLayerManager;
         starlingFactory = new StarlingRendererFactory(this,mStarlingRenderingBackend);
         starlingFactory.sourceCache = mStarlingLayerManager.sourceCache;
         mRendererFactorySelector.registerStarlingFactory(starlingFactory);
         mRendererFactorySelector.setLayerBackend(5,"starling");
         StarlingRollerProvider.install(mStarlingLayerManager);
         updateScaling();
      }
      
      public function syncStarlingWorld(clock:GameClock) : void
      {
         if(mStarlingRenderingBackend != null && mSceneGraphManager != null)
         {
            mStarlingRenderingBackend.syncWorldTransform(mSceneGraphManager.worldTransformNode);
         }
      }
      
      public function mainLoop(event:Event) : void
      {
         var _loc9_:Number = NaN;
         var _loc10_:Number = NaN;
         if(mTickLength == -1)
         {
            mTickLength = mGameClock.tickLength;
         }
         var _loc11_:Number = mGameClock.update();
         var _loc8_:Number = mRealClock.update();
         mElapsedTime += _loc11_;
         var _loc5_:uint = 0;
         mRealClock.gameTime = mRealClock.realTime;
         mRealClockWorkManager.update(mRealClock);
         var _loc7_:Boolean = false;
         mSkippingFrame = false;
         var _loc2_:Number = mCurrentTime;
         mCurrentTime = new Date().time;
         var _loc6_:int = mCurrentTime - _loc2_;
         _loc6_ = Math.max(0,_loc6_);
         mWallClockTimeElapsed += _loc6_;
         mGameClockTimeElapsed += _loc11_;
         mRenderClockTimeElapsed += _loc8_;
         if(mWallClockTimeElapsed > 1000)
         {
            _loc9_ = mGameClockTimeElapsed * 1000;
            _loc10_ = _loc9_ / mWallClockTimeElapsed;
            if(_loc10_ > 1.1)
            {
               mTickLength = mGameClock.tickLength * _loc10_;
               mCheatCount = mCheatCount + 1;
               if(mCheatCount > 60)
               {
                  iamaCheater("testing_speed_hack_definite");
               }
               else if(mCheatCount > 3)
               {
                  iamaCheater("testing_speed_hack_probable");
               }
            }
            else
            {
               mTickLength = mGameClock.tickLength;
               mCheatCount = 0;
            }
            mGameClockTimeElapsed = 0;
            mRenderClockTimeElapsed = 0;
            mWallClockTimeElapsed = 0;
            mTickCounter = 0;
            mRenderTickCounter = 0;
         }
         while(mElapsedTime >= mTickLength && _loc5_ < 5)
         {
            mCamera.beginTick();
            View.beginTickAll();
            mTickCounter = mTickCounter + 1;
            mTickAccumulator = mTickAccumulator + 1;
            mLogicalWorkManager.update(mGameClock);
            mPhysicsWorkManager.update(mGameClock);
            mPreRenderWorkManager.update(mGameClock);
            flushInputs();
            mElapsedTime -= mTickLength;
            mGameClock.gameTime += mTickLength * 1000;
            _loc5_++;
         }
         var _loc3_:Number = Math.min(1,mElapsedTime / mTickLength);
         var _loc4_:Number = mRealClock.tickLength;
         mRenderTickCounter = mRenderTickCounter + 1;
         mFrameAccumulator = mFrameAccumulator + 1;
         mCamera.renderInterpolated(_loc3_);
         View.renderInterpolatedAll(_loc3_);
         mLayerRenderWorkManager.update(mRealClock);
         syncStarlingWorld(mRealClock);
         mRealClock.gameTime += _loc4_ * 1000;
         if(_loc5_ >= 5)
         {
            mElapsedTime = 0;
            _loc3_ = 0;
         }
      }
      
      protected function flushInputs() : void
      {
         mInputManager.flush();
      }
      
      public function iamaCheater(reason:String) : void
      {
         if(!mCheaterLogMap.hasKey(reason))
         {
            mCheaterLogMap.add(reason,true);
            logCheater(reason);
         }
      }
      
      public function logCheater(reason:String) : void
      {
      }
      
      public function get skippingFrame() : Boolean
      {
         return mSkippingFrame;
      }
      
      public function init(stageRef:Stage) : void
      {
         mStageRef = stageRef;
         mSwfWidth = viewWidth;
         mSwfHeight = viewHeight;
         mScalingRoot = new Sprite();
         mScalingRoot.name = "scalingRoot";
         mStageRef.addChild(mScalingRoot);
         EventListeners.add(mStageRef,"resize",updateScaling);
         updateScaling();
         Logger.init(mStageRef,true);
         mGameClock = new GameClock(1 / 24);
         mRealClock = new RenderClock();
         mEventManager = new EventManager(this);
         mAssetRepository = new mAssetRepositoryClass(this);
         featureFlags = new FeatureFlags();
         TextUtil.featureFlags = featureFlags;
         mRealClockWorkManager = new WorkLoopManager(mRealClock);
         mLogicalWorkManager = new WorkLoopManager(mGameClock);
         mPhysicsWorkManager = new WorkLoopManager(mGameClock);
         mPreRenderWorkManager = new WorkLoopManager(mGameClock);
         mLayerRenderWorkManager = new WorkLoopManager(mRealClock);
         mTween = new TweeningProxy(this);
         mCamera = new Camera(this,new BackgroundFader(this),new LetterboxEffect(this));
         mEventComponent = new EventComponent(this);
      }
      
      public function run() : void
      {
         mEventComponent.addListener("enterFrame",this.mainLoop);
      }
      
      public function get inputManager() : InputManager
      {
         return mInputManager;
      }
      
      public function get gameClock() : GameClock
      {
         return mGameClock;
      }
      
      public function get realClock() : GameClock
      {
         return mRealClock;
      }
      
      public function get initialLoginTraceId() : String
      {
         return mInitialLoginTraceId;
      }
      
      public function set initialLoginTraceId(value:String) : void
      {
         mInitialLoginTraceId = value;
         JSONRPCService.initialLoginTraceId = value;
         displaySessionId();
      }
      
      public function get sessionInfoString() : String
      {
         return mSessionInfoString;
      }
      
      public function displaySessionId() : void
      {
         var _loc2_:Array = null;
         var _loc4_:String = "";
         if(mInitialLoginTraceId == null || mInitialLoginTraceId == "")
         {
            _loc4_ = "Loading...";
         }
         else
         {
            _loc2_ = mInitialLoginTraceId.split("-");
            if(_loc2_.length >= 2)
            {
               _loc4_ = _loc2_[1].substr(-16);
            }
            else
            {
               _loc4_ = mInitialLoginTraceId;
            }
         }
         mSessionInfoString = environmentPrefix + ":" + _loc4_;
         var _loc1_:TextField = new TextField();
         _loc1_.text = mSessionInfoString;
         _loc1_.selectable = false;
         _loc1_.autoSize = "left";
         _loc1_.y = -2;
         var _loc3_:TextFormat = new TextFormat();
         _loc3_.bold = true;
         _loc3_.font = "Verdana";
         _loc3_.color = 15660015;
         _loc3_.size = 18;
         _loc1_.setTextFormat(_loc3_);
         _loc1_.alpha = 0.65;
         _loc1_.cacheAsBitmap = true;
         _loc1_.name = "SessionIdTextField";
         _loc1_.visible = mSessionIdVisible;
         if(mSessionIdTextField != null && mSessionIdTextField.parent == mScalingRoot)
         {
            removeRootDisplayObject(mSessionIdTextField);
         }
         mSessionIdTextField = _loc1_;
         addRootDisplayObject(_loc1_,1002);
      }
      
      public function set sessionIdVisible(value:Boolean) : void
      {
         mSessionIdVisible = value;
         if(mSessionIdTextField != null)
         {
            mSessionIdTextField.visible = value;
         }
      }
      
      public function get eventManager() : EventManager
      {
         return mEventManager;
      }
      
      public function get gameObjectManager() : GameObjectManager
      {
         return mGameObjectManager;
      }
      
      public function get sceneGraphManager() : SceneGraphManager
      {
         return mSceneGraphManager;
      }
      
      public function get logicalWorkManager() : WorkLoopManager
      {
         return mLogicalWorkManager;
      }
      
      public function get realClockWorkManager() : WorkLoopManager
      {
         return mRealClockWorkManager;
      }
      
      public function get preRenderWorkManager() : WorkLoopManager
      {
         return mPreRenderWorkManager;
      }
      
      public function get physicsWorkManager() : WorkLoopManager
      {
         return mPhysicsWorkManager;
      }
      
      public function get layerRenderWorkManager() : WorkLoopManager
      {
         return mLayerRenderWorkManager;
      }
      
      public function get assetRepository() : AssetRepository
      {
         return mAssetRepository;
      }
      
      public function get assetLoadingComponent() : AssetLoadingComponent
      {
         return mAssetLoadingComponent;
      }
      
      public function get soundManager() : SoundManager
      {
         return mSoundManager;
      }
      
      public function get mouseCursorManager() : MouseCursorManager
      {
         return mMouseCursorManager;
      }
      
      public function getWorldCoordinateFromMouse() : Vector3D
      {
         return camera.getWorldCoordinateFromMouse(inputManager.mouseX,inputManager.mouseY);
      }
   }
}

