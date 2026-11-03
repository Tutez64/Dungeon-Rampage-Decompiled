package Actor
{
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SpriteSheetAsset;
   import Brain.AssetRepository.StarlingAssetMapper;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Clock.GameClock;
   import Brain.Logger.Logger;
   import Brain.Render.ActorSpriteSheetRenderer;
   import Brain.Render.IRenderer;
   import Brain.WorkLoop.LayerWorkComponent;
   import Brain.WorkLoop.PreRenderWorkComponent;
   import Collections.IMapIterator;
   import Collections.Map;
   import Combat.Weapon.WeaponRenderer;
   import DistributedObjects.NPCGameObject;
   import Dungeon.Tile;
   import Facade.DBFacade;
   import GameMasterDictionary.GMActor;
   import Starling.SwfFallbackDebug;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import flash.filesystem.File;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import starling.extensions.animate.Animation;
   import starling.textures.Texture;
   
   public class ActorRenderer extends Sprite
   {
      
      public static const IDLE_ANIM_NAME:String = "idle";
      
      public static const RUN_ANIM_NAME:String = "run";
      
      public static const SUFFER_ANIM_NAME:String = "suffer";
      
      public static const DEATH_ANIM_NAME:String = "death";
      
      public static const IDLE_CLIP_KEY_SUFFIX:String = "_idle";
      
      private static const PACKED_LIBRARY_SYMBOL_NAME:String = "__BTA_TEMP_SPRITEMAP_PACKED_SYMBOL";
      
      private static const CULL_MARGIN:Number = 256;
      
      private static const DEBUG_HEADING:Boolean = false;
      
      public static const mStandardAnimList:Array = ["idle","death"];
      
      protected var mDBFacade:DBFacade;
      
      protected var mAnims:Map;
      
      protected var mLoadingAnims:Map;
      
      protected var mTriggerState:Boolean;
      
      protected var mAssetLoadingComponent:AssetLoadingComponent;
      
      protected var mPreRenderWorkComponent:PreRenderWorkComponent;
      
      protected var mStarlingSyncComponent:LayerWorkComponent;
      
      private var mLayerSyncedStarlingRenderer:StarlingActorRenderer;
      
      protected var mCurrentRenderer:IRenderer;
      
      protected var mStarlingRenderer:StarlingActorRenderer;
      
      protected var mHighlightColor:uint;
      
      protected var mHighlightAlpha:Number = 8;
      
      protected var mHighlightBlur:Number = 2;
      
      protected var mHighlightActive:Boolean = false;
      
      protected var mPersistentGlowColor:uint;
      
      protected var mPersistentGlowAlpha:Number = 8;
      
      protected var mPersistentGlowBlur:Number = 2;
      
      protected var mPersistentGlowActive:Boolean = false;
      
      protected var mColorFilterMatrix:Array;
      
      protected var mStatusTintColor:uint;
      
      protected var mStatusTintAmount:Number = 0;
      
      protected var mActorGameObject:ActorGameObject;
      
      protected var mHeading:Number = 0;
      
      protected var mAnimName:String;
      
      protected var mLoop:Boolean;
      
      protected var mPendingLayer:int = 0;
      
      protected var mPendingVisible:Boolean = false;
      
      protected var mCulled:Boolean = false;
      
      private var mUnculledSinceLastFrame:Boolean = false;
      
      private var mSyncedRootX:Number = NaN;
      
      private var mSyncedRootY:Number = NaN;
      
      private var mSyncedRootRotation:Number = NaN;
      
      private var mSyncedRotation:Number = NaN;
      
      private var mSyncedRootScaleX:Number = NaN;
      
      private var mSyncedRootScaleY:Number = NaN;
      
      private var mSyncedRootAlpha:Number = NaN;
      
      private var mSyncedBodyScaleX:Number = NaN;
      
      private var mSyncedBodyScaleY:Number = NaN;
      
      private var mSyncedOffsetX:Number = NaN;
      
      private var mSyncedOffsetY:Number = NaN;
      
      private var mSyncedWorldX:Number = NaN;
      
      private var mSyncedWorldY:Number = NaN;
      
      private var mContentRadius:Number = 0;
      
      private var mContentRadiusStale:Boolean = true;
      
      private var mTileStretchPending:Boolean;
      
      private var mTileStretchClip:MovieClip;
      
      private var mTileStretchWork:LayerWorkComponent;
      
      private var mPreloadSprites:Boolean;
      
      protected var mIsStarlingBound:Boolean = false;
      
      private var mLoadCompleteCallbacks:Vector.<Function>;
      
      public function ActorRenderer(dbFacade:DBFacade, actorGameObject:ActorGameObject, triggerState:Boolean)
      {
         super();
         this.name = "ActorRenderer";
         mActorGameObject = actorGameObject;
         mDBFacade = dbFacade;
         mTriggerState = triggerState;
         mAnims = new Map();
         mLoop = false;
         mColorFilterMatrix = null;
         mLoadingAnims = new Map();
         mLoadCompleteCallbacks = new Vector.<Function>();
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mPreRenderWorkComponent = new PreRenderWorkComponent(mDBFacade,"ActorRenderer");
         mPreloadSprites = mDBFacade.dbConfigManager.getConfigBoolean("preload_sprites",false);
      }
      
      public static function npcAtlasClassNames(className:String) : Array
      {
         if(!className)
         {
            return [];
         }
         return [className,className + "_" + "run",className + "_" + "suffer",className + "_" + "death"];
      }
      
      public static function propAtlasClassNames(gmActor:GMActor, triggerState:Boolean) : Array
      {
         var _loc6_:String = gmActor.AssetClassName;
         var _loc3_:String = ActorData.offMovieClipClassName(_loc6_);
         var _loc4_:String = gmActor.Species;
         if(_loc4_ == "DOOR")
         {
            return [_loc3_];
         }
         if(_loc4_ == "TRIGGER")
         {
            return [triggerState ? _loc6_ : _loc3_];
         }
         var _loc5_:Array = _loc4_ == "TRAP" ? [_loc6_,_loc3_] : [_loc6_];
         if(gmActor.DefaultDestruct != null)
         {
            _loc5_.push(ActorData.deathMovieClipClassName(_loc6_));
         }
         return _loc5_;
      }
      
      public static function boundsThrough(local:Rectangle, matrix:Matrix) : Rectangle
      {
         var _loc6_:Number = NaN;
         var _loc3_:Vector.<Point> = new <Point>[matrix.transformPoint(local.topLeft),matrix.transformPoint(new Point(local.right,local.top)),matrix.transformPoint(new Point(local.left,local.bottom)),matrix.transformPoint(local.bottomRight)];
         var _loc8_:Number = _loc6_ = _loc3_[0].x;
         var _loc4_:Number;
         var _loc7_:Number = _loc4_ = _loc3_[0].y;
         for each(var _loc5_:Point in _loc3_)
         {
            _loc6_ = Math.min(_loc6_,_loc5_.x);
            _loc8_ = Math.max(_loc8_,_loc5_.x);
            _loc4_ = Math.min(_loc4_,_loc5_.y);
            _loc7_ = Math.max(_loc7_,_loc5_.y);
         }
         return new Rectangle(_loc6_,_loc4_,_loc8_ - _loc6_,_loc7_ - _loc4_);
      }
      
      public function get rendererType() : String
      {
         if(mStarlingRenderer != null)
         {
            return mStarlingRenderer.rendererType;
         }
         if(mCurrentRenderer == null)
         {
            return "null";
         }
         return mCurrentRenderer.rendererType;
      }
      
      public function destroy() : void
      {
         var _loc1_:IRenderer = null;
         if(this.parent)
         {
            this.parent.removeChild(this);
         }
         if(mStarlingRenderer != null)
         {
            mStarlingRenderer.destroy();
            mStarlingRenderer = null;
         }
         var _loc2_:IMapIterator = mAnims.iterator() as IMapIterator;
         while(_loc2_.hasNext())
         {
            _loc1_ = _loc2_.next();
            _loc1_.destroy();
         }
         mAnims.clear();
         mAnims = null;
         mLoadingAnims.clear();
         mLoadingAnims = null;
         if(mLoadCompleteCallbacks != null)
         {
            mLoadCompleteCallbacks.length = 0;
            mLoadCompleteCallbacks = null;
         }
         mAssetLoadingComponent.destroy();
         mPreRenderWorkComponent.destroy();
         stopTileStretchWork();
         if(mStarlingSyncComponent != null)
         {
            mStarlingSyncComponent.destroy();
            mStarlingSyncComponent = null;
         }
         mLayerSyncedStarlingRenderer = null;
         mActorGameObject = null;
         mDBFacade = null;
         mCurrentRenderer = null;
      }
      
      public function get isStarlingLoading() : Boolean
      {
         return mIsStarlingBound && mStarlingRenderer == null;
      }
      
      public function addLoadCompleteCallback(callback:Function) : void
      {
         if(mLoadCompleteCallbacks == null)
         {
            return;
         }
         mLoadCompleteCallbacks.push(callback);
      }
      
      public function removeLoadCompleteCallback(callback:Function) : void
      {
         if(mLoadCompleteCallbacks == null)
         {
            return;
         }
         var _loc2_:int = mLoadCompleteCallbacks.indexOf(callback);
         if(_loc2_ >= 0)
         {
            mLoadCompleteCallbacks.splice(_loc2_,1);
         }
      }
      
      protected function notifyLoadComplete() : void
      {
         if(mLoadCompleteCallbacks == null)
         {
            return;
         }
         var _loc1_:Vector.<Function> = mLoadCompleteCallbacks.concat();
         mLoadCompleteCallbacks.length = 0;
         for each(var _loc2_:Function in _loc1_)
         {
            _loc2_();
         }
      }
      
      protected function get swfFilePath() : String
      {
         return mActorGameObject.actorData.getSwfFilePath();
      }
      
      protected function get movieClipClassName() : String
      {
         if(mTriggerState)
         {
            return mActorGameObject.actorData.getMovieClipClassName();
         }
         return mActorGameObject.actorData.getOffMovieClipClassName();
      }
      
      protected function get spriteWidth() : Number
      {
         return mActorGameObject.actorData.spriteWidth;
      }
      
      protected function get spriteHeight() : Number
      {
         return mActorGameObject.actorData.spriteHeight;
      }
      
      protected function get assetType() : String
      {
         return mActorGameObject.actorData.assetType;
      }
      
      protected function get starlingAtlasName() : String
      {
         return StarlingAssetMapper.getActorAtlasKeyFromPath(this.swfFilePath);
      }
      
      protected function get isStarlingActor() : Boolean
      {
         return mActorGameObject != null && mActorGameObject.actorData != null && mActorGameObject.actorData.gMActor != null && !mActorGameObject.isProp && StarlingAssetMapper.getActorAtlasFile(this.swfFilePath) != null;
      }
      
      protected function getSpriteSheetClassName(animName:String) : String
      {
         if(mTriggerState || mActorGameObject.actorData.isMover)
         {
            return mActorGameObject.actorData.getSpriteSheetClassName(animName);
         }
         return mActorGameObject.actorData.getOffSpriteSheetClassName(animName);
      }
      
      protected function loadMovieClipAssets() : void
      {
         var onStarlingAssets:Function;
         var actorAtlasFile:File;
         var isBackground:Boolean;
         var swfPath:String = this.swfFilePath;
         var className:String = movieClipClassName;
         if(mActorGameObject != null && mActorGameObject.forceFlash)
         {
            reportSwfFallback("per-instance forceFlash override (LE tile placement)",this.assetType == "SPRITE_SHEET");
            loadMovieClipSwfAssets(swfPath,className);
            return;
         }
         if(!className || mDBFacade.assetLoadingComponent == null || mDBFacade.starlingLayerManager == null)
         {
            reportSwfFallback(!className ? "no AssetClassName" : (mDBFacade.assetLoadingComponent == null ? "no asset loading component" : "no Starling layer manager (Stage3D not up)"),this.assetType == "SPRITE_SHEET");
            loadMovieClipSwfAssets(swfPath,className);
            return;
         }
         onStarlingAssets = function():void
         {
            if(mAnims == null)
            {
               return;
            }
            var _loc1_:String = mActorGameObject.isProp ? null : starlingAtlasName;
            var _loc2_:String = _loc1_ != null && _loc1_ != "" ? _loc1_ : className;
            if(_loc2_ != className && mDBFacade.assetLoadingComponent.isPackedAtlasInAssetManager(_loc2_))
            {
               _loc2_ = className;
            }
            else if(_loc2_ != className && !mDBFacade.assetLoadingComponent.hasAnimationInAssetManager(_loc2_) && mDBFacade.assetLoadingComponent.hasAnimationInAssetManager(className))
            {
               _loc2_ = className;
            }
            if(!loadStarlingAnimations(_loc2_))
            {
               reportSwfFallback(!mDBFacade.assetLoadingComponent.isStarlingReady ? "Starling asset manager not initialized (Stage3D context failed?)" : "atlas \'" + _loc2_ + "\' has no idle animation",assetType == "SPRITE_SHEET");
               loadMovieClipSwfAssets(swfPath,className);
            }
         };
         actorAtlasFile = !mActorGameObject.isProp ? StarlingAssetMapper.getActorAtlasFile(swfPath,true) : null;
         isBackground = mActorGameObject.belongsToRemotePlayer;
         if(actorAtlasFile != null)
         {
            queueActorAtlas(actorAtlasFile,className,onStarlingAssets,isBackground);
         }
         else if(mActorGameObject.isProp)
         {
            mDBFacade.assetLoadingComponent.queueStarlingAssetsForProps(swfPath,getPropAtlasClassNames(),onStarlingAssets);
         }
         else if(StarlingAssetMapper.isPropLibraryPath(swfPath))
         {
            mDBFacade.assetLoadingComponent.queueStarlingAssetsForProps(swfPath,npcAtlasClassNames(className),onStarlingAssets,isBackground,backgroundLoadTier);
         }
         else
         {
            mDBFacade.assetLoadingComponent.queueStarlingAssetsForPath(swfPath,onStarlingAssets,false,isBackground,backgroundLoadTier);
         }
      }
      
      protected function get backgroundLoadTier() : int
      {
         return mActorGameObject is NPCGameObject ? 4 : 0;
      }
      
      private function getPropAtlasClassNames() : Array
      {
         return propAtlasClassNames(mActorGameObject.actorData.gMActor,mTriggerState);
      }
      
      private function get npcLibraryKey() : String
      {
         var _loc1_:String = this.swfFilePath;
         return StarlingAssetMapper.isPropLibraryPath(_loc1_) ? StarlingAssetMapper.getBiomeKeyFromPath(_loc1_) : null;
      }
      
      private function queueActorAtlas(actorAtlasFile:File, className:String, onStarlingAssets:Function, isBackground:Boolean) : void
      {
         var idleClipFile:File;
         var restClipFiles:Array;
         var clipFile:File;
         var remainingClassName:String;
         var isMultiClip:Boolean = !actorAtlasFile.resolvePath("Animation.json").exists;
         if(isMultiClip)
         {
            idleClipFile = null;
            restClipFiles = [];
            for each(clipFile in actorAtlasFile.getDirectoryListing())
            {
               if(clipFile.isDirectory && clipFile.name == className)
               {
                  idleClipFile = clipFile;
               }
               else
               {
                  restClipFiles.push(clipFile);
               }
            }
            if(idleClipFile != null && restClipFiles.length > 0)
            {
               remainingClassName = className;
               if(!mDBFacade.assetLoadingComponent.hasAnimationInAssetManager(className))
               {
                  mDBFacade.assetLoadingComponent.queueStarlingAssets(className + "_idle",onStarlingAssets,false,[idleClipFile],isBackground,backgroundLoadTier);
               }
               else
               {
                  onStarlingAssets();
               }
               mDBFacade.assetLoadingComponent.queueStarlingAssets(starlingAtlasName,function():void
               {
                  onRemainingClipsLoaded(remainingClassName);
               },false,restClipFiles,isBackground,backgroundLoadTier);
               return;
            }
         }
         mDBFacade.assetLoadingComponent.queueStarlingAssets(starlingAtlasName,onStarlingAssets,false,[actorAtlasFile],isBackground,backgroundLoadTier);
      }
      
      private function onRemainingClipsLoaded(className:String) : void
      {
         if(mStarlingRenderer == null)
         {
            return;
         }
         addStarlingAnimation("run",className);
         addStarlingAnimation("suffer",className);
         addStarlingAnimation("death",className);
      }
      
      protected function loadMovieClipSwfAssets(swfPath:String, className:String) : void
      {
         mIsStarlingBound = false;
         if(StarlingAssetMapper.isArt3DPath(swfPath))
         {
            reportSwfFallback("no usable ATF atlas - Art3D SWFs no longer ship, so this will not render. Pack its ATF atlas with TA_3DPipeline");
            notifyLoadComplete();
            return;
         }
         this.mAssetLoadingComponent.getSwfAsset(swfPath,function(param1:SwfAsset):void
         {
            movieClipSwfLoaded(className,param1);
         });
      }
      
      private function countResolvableRecipeParts(parts:Array, libraryKey:String) : int
      {
         var _loc4_:int = 0;
         for each(var _loc3_:Object in parts)
         {
            if(mDBFacade.assetLoadingComponent.getTextureFromAssetManager(_loc3_.tex as String,libraryKey) != null)
            {
               _loc4_++;
            }
         }
         return _loc4_;
      }
      
      private function clearFlashRenderer() : void
      {
         var _loc1_:IRenderer = null;
         if(mCurrentRenderer != null)
         {
            mCurrentRenderer.stop();
            if(this.contains(mCurrentRenderer.displayObject))
            {
               this.removeChild(mCurrentRenderer.displayObject);
            }
            mCurrentRenderer = null;
         }
         var _loc2_:IMapIterator = mAnims.iterator() as IMapIterator;
         while(_loc2_ != null && Boolean(_loc2_.hasNext()))
         {
            _loc1_ = _loc2_.next() as IRenderer;
            if(_loc1_ != null)
            {
               _loc1_.destroy();
            }
         }
         mAnims.clear();
         mLoadingAnims.clear();
      }
      
      protected function loadStarlingAnimations(movieClipClassName:String) : Boolean
      {
         var _loc22_:String = null;
         var _loc25_:String = null;
         var _loc14_:String = null;
         var _loc4_:Boolean = false;
         var _loc20_:String = null;
         var _loc7_:Animation = null;
         var _loc21_:String = null;
         var _loc28_:Array = null;
         var _loc26_:String = null;
         var _loc16_:Array = null;
         var _loc11_:Boolean = false;
         var _loc9_:Animation = null;
         var _loc3_:Animation = null;
         var _loc10_:Animation = null;
         var _loc19_:Texture = null;
         var _loc8_:Texture = null;
         var _loc15_:Boolean = false;
         var _loc24_:int = 0;
         var _loc27_:String = null;
         var _loc5_:Animation = null;
         var _loc17_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc13_:ActorData = null;
         var _loc6_:Boolean = mActorGameObject.actorData != null && mActorGameObject.actorData.gMActor != null && mActorGameObject.actorData.gMActor.CharType == "PROP";
         if(_loc6_)
         {
            _loc22_ = StarlingAssetMapper.getBiomeKeyFromPath(this.swfFilePath);
            _loc25_ = mActorGameObject.actorData.gMActor.Species;
            _loc14_ = mActorGameObject.actorData.getMovieClipClassName();
            _loc4_ = !mTriggerState;
            _loc7_ = null;
            if(_loc25_ == "DOOR")
            {
               _loc21_ = _loc14_;
               _loc28_ = mDBFacade.assetLoadingComponent.getPropRecipeParts(_loc21_,_loc22_);
               if(_loc4_ && mActorGameObject.actorData.gMActor.DefaultDestruct != null)
               {
                  _loc26_ = _loc14_ + "_off";
                  _loc16_ = mDBFacade.assetLoadingComponent.getPropRecipeParts(_loc26_,_loc22_);
                  if(_loc16_ != null && countResolvableRecipeParts(_loc16_,_loc22_) > 0)
                  {
                     _loc21_ = _loc26_;
                     _loc28_ = _loc16_;
                  }
                  else
                  {
                     _loc21_ = _loc26_;
                     _loc28_ = null;
                  }
               }
            }
            else if(_loc25_ == "TRAP" || _loc25_ == "TRIGGER")
            {
               _loc21_ = _loc4_ ? _loc14_ + "_off" : _loc14_;
               _loc28_ = mDBFacade.assetLoadingComponent.getPropRecipeParts(_loc21_,_loc22_);
            }
            else
            {
               _loc21_ = movieClipClassName;
               _loc28_ = mDBFacade.assetLoadingComponent.getPropRecipeParts(_loc21_,_loc22_);
            }
            if(_loc28_ != null && countResolvableRecipeParts(_loc28_,_loc22_) == 0)
            {
               Logger.warnch("Starling","Prop manifest recipe \'" + _loc21_ + "\' names no sprite present in the atlas; falling back to name-derived lookups");
               _loc28_ = null;
            }
            _loc11_ = _loc25_ == "TRIGGER" || _loc25_ == "TRAP" && _loc28_ != null;
            if(_loc11_)
            {
               _loc20_ = _loc4_ ? _loc14_ + "_off" : _loc14_;
            }
            else if(_loc25_ == "DOOR")
            {
               _loc20_ = _loc14_ + "_off";
            }
            else if(_loc25_ == "TRAP")
            {
               _loc9_ = resolveActorClip(_loc14_,_loc22_);
               _loc3_ = resolveActorClip(_loc14_ + "_off",_loc22_);
               if(_loc9_ != null || _loc3_ == null)
               {
                  _loc20_ = _loc4_ ? _loc14_ + "_off" : _loc14_;
                  _loc7_ = _loc4_ ? _loc3_ : _loc9_;
                  _loc10_ = _loc4_ ? _loc9_ : _loc3_;
                  if(_loc10_ != null)
                  {
                     _loc10_.dispose();
                  }
               }
               else
               {
                  _loc20_ = _loc14_ + "_off";
                  _loc7_ = _loc3_;
               }
            }
            else
            {
               _loc20_ = _loc14_;
            }
            _loc15_ = false;
            if(_loc28_ == null)
            {
               if(_loc25_ == "DOOR")
               {
                  _loc8_ = mDBFacade.assetLoadingComponent.getTextureFromAssetManager(_loc14_ + "_frame",_loc22_);
                  _loc19_ = mDBFacade.assetLoadingComponent.getTextureFromAssetManager(_loc14_ + "_door",_loc22_);
                  if(_loc8_ != null && _loc19_ != null)
                  {
                     _loc15_ = true;
                  }
                  else
                  {
                     _loc8_ = null;
                     _loc19_ = mDBFacade.assetLoadingComponent.getTextureFromAssetManager(movieClipClassName,_loc22_);
                     if(_loc19_ == null)
                     {
                        _loc19_ = mDBFacade.assetLoadingComponent.getTextureFromAssetManager(_loc20_,_loc22_);
                     }
                  }
               }
               else if(_loc11_)
               {
                  _loc19_ = mDBFacade.assetLoadingComponent.getTextureFromAssetManager(_loc20_,_loc22_);
               }
               else if(_loc25_ == "TRAP" && _loc4_)
               {
                  _loc19_ = mDBFacade.assetLoadingComponent.getTextureFromAssetManager(_loc20_,_loc22_);
               }
               else
               {
                  _loc19_ = mDBFacade.assetLoadingComponent.getTextureFromAssetManager(movieClipClassName,_loc22_);
                  if(_loc19_ == null)
                  {
                     _loc19_ = mDBFacade.assetLoadingComponent.getTextureFromAssetManager(_loc14_,_loc22_);
                  }
                  if(_loc19_ == null && _loc25_ == "TRAP")
                  {
                     _loc19_ = mDBFacade.assetLoadingComponent.getTextureFromAssetManager(_loc20_,_loc22_);
                  }
               }
            }
            if(_loc7_ == null)
            {
               _loc7_ = resolveActorClip(_loc20_,_loc22_);
            }
            if(_loc7_ != null && (mAnimName == null || mAnimName == "idle"))
            {
               mLoop = !_loc7_.hasFrameLabelNoClamp("noloop");
            }
            if(_loc28_ == null && _loc19_ == null && _loc7_ == null)
            {
               Logger.warn("No Starling asset for: " + movieClipClassName + " - BASE ASSET missing - no manifest recipe for \'" + _loc21_ + "\', no atlas texture named \'" + movieClipClassName + "\' and no animation named \'" + _loc20_ + "\'; falling back to SWF");
               return false;
            }
            if(_loc7_ == null && !_loc11_ && !_loc4_ && _loc19_ == null && _loc28_ == null)
            {
               Logger.warn("No Starling asset for: " + movieClipClassName + " - ANIMATION missing - no animation named \'" + _loc20_ + "\' for the active state; falling back to SWF");
               return false;
            }
            clearFlashRenderer();
            mIsStarlingBound = false;
            mStarlingRenderer = new StarlingActorRenderer(mDBFacade,movieClipClassName,20);
            resetContentRadius();
            if(_loc28_ != null)
            {
               _loc24_ = mStarlingRenderer.setStaticEnsemble(_loc28_,_loc22_);
               if(_loc24_ == 0)
               {
                  Logger.warn("No Starling asset for: " + movieClipClassName + " - RECIPE UNRESOLVED - manifest recipe \'" + _loc21_ + "\' names no sprite present in the atlas; falling back to SWF");
                  mStarlingRenderer.destroy();
                  mStarlingRenderer = null;
                  return false;
               }
            }
            else
            {
               if(_loc15_)
               {
                  mStarlingRenderer.setFrameImage(_loc8_);
               }
               mStarlingRenderer.setOffImage(_loc19_);
            }
            if(_loc11_)
            {
               if(_loc7_ != null)
               {
                  mStarlingRenderer.alignStaticImagesToAnimation(_loc7_);
               }
               if(_loc28_ == null && _loc19_ == null && _loc7_ != null)
               {
                  mStarlingRenderer.addAnimation("idle",_loc7_);
                  if(mAnimName == null)
                  {
                     mAnimName = "idle";
                  }
               }
            }
            else
            {
               if(_loc25_ == "DOOR")
               {
                  if(!mTriggerState)
                  {
                     mStarlingRenderer.addAnimation("idle",_loc7_);
                  }
                  mStarlingRenderer.addAnimation("death",_loc7_);
               }
               else if(mActorGameObject.actorData.gMActor.DefaultDestruct != null)
               {
                  mStarlingRenderer.addAnimation("idle",_loc7_);
                  _loc27_ = mActorGameObject.actorData.getDeathMovieClipClassName();
                  _loc5_ = resolveActorClip(_loc27_,_loc22_);
                  mStarlingRenderer.addAnimation("death",_loc5_);
               }
               else
               {
                  mStarlingRenderer.addAnimation("death",_loc7_);
                  mStarlingRenderer.addAnimation("idle",_loc7_);
               }
               if(_loc15_)
               {
                  mStarlingRenderer.alignStaticImagesToAnimation(_loc7_);
               }
            }
            syncStarlingTransform();
            mStarlingRenderer.showOffImage(true);
            updateStarlingHitArea();
            this.visible = mPendingVisible;
            mStarlingRenderer.setLayer(mPendingLayer);
            if(mAnimName != null)
            {
               this.play(mAnimName,0,true,mLoop);
            }
            else if(_loc28_ == null && _loc19_ == null && mStarlingRenderer.hasAnim("idle"))
            {
               mAnimName = "idle";
               this.play(mAnimName,0,true,mLoop);
            }
            if(mHighlightActive)
            {
               mStarlingRenderer.setHighlightFilter(mHighlightColor,mHighlightAlpha,mHighlightBlur);
            }
            if(mPersistentGlowActive)
            {
               mStarlingRenderer.setPersistentGlowFilter(mPersistentGlowColor,mPersistentGlowAlpha,mPersistentGlowBlur);
            }
            if(mColorFilterMatrix != null)
            {
               mStarlingRenderer.setColorFilter(mColorFilterMatrix);
            }
            if(mStatusTintAmount > 0)
            {
               mStarlingRenderer.setStatusTint(mStatusTintColor,mStatusTintAmount);
            }
            mTileStretchPending = stretchesTile;
            startStarlingSync();
            return true;
         }
         var _loc18_:Animation = resolveActorClip(movieClipClassName,npcLibraryKey);
         if(_loc18_ == null)
         {
            Logger.warnch("Starling","No Starling asset for: " + movieClipClassName + " - ANIMATION missing - no idle animation named \'" + movieClipClassName + "\'; falling back to SWF");
            return false;
         }
         if(isStarlingMultiDirectionAnim(_loc18_))
         {
            clearFlashRenderer();
            mIsStarlingBound = false;
            mStarlingRenderer = new StarlingActorRenderer(mDBFacade,movieClipClassName,20);
            resetContentRadius();
            mStarlingRenderer.enableMultiDirectionMode(_loc18_);
            _loc17_ = _loc18_.sourceWidth;
            _loc23_ = _loc18_.sourceHeight;
            _loc13_ = mActorGameObject.actorData;
            if(_loc17_ > 0 && _loc23_ > 0 && _loc13_.spriteWidth > 0 && _loc13_.spriteHeight > 0)
            {
               mStarlingRenderer.setContentScale(_loc13_.spriteWidth / _loc17_,_loc13_.spriteHeight / _loc23_);
            }
            syncStarlingTransform();
            if(mAnimName != null)
            {
               this.play(mAnimName,0,true,mLoop);
            }
            else
            {
               this.stop();
            }
            updateStarlingHitArea();
            this.visible = mPendingVisible;
            mStarlingRenderer.setLayer(mPendingLayer);
            if(mHighlightActive)
            {
               mStarlingRenderer.setHighlightFilter(mHighlightColor,mHighlightAlpha,mHighlightBlur);
            }
            if(mPersistentGlowActive)
            {
               mStarlingRenderer.setPersistentGlowFilter(mPersistentGlowColor,mPersistentGlowAlpha,mPersistentGlowBlur);
            }
            if(mColorFilterMatrix != null)
            {
               mStarlingRenderer.setColorFilter(mColorFilterMatrix);
            }
            if(mStatusTintAmount > 0)
            {
               mStarlingRenderer.setStatusTint(mStatusTintColor,mStatusTintAmount);
            }
            startStarlingSync();
            notifyLoadComplete();
            return true;
         }
         clearFlashRenderer();
         mIsStarlingBound = false;
         mStarlingRenderer = new StarlingActorRenderer(mDBFacade,movieClipClassName,20);
         resetContentRadius();
         mStarlingRenderer.addAnimation("idle",_loc18_);
         var _loc2_:Number = _loc18_.sourceWidth;
         var _loc12_:Number = _loc18_.sourceHeight;
         if(_loc2_ > 0 && _loc12_ > 0 && mActorGameObject.actorData.spriteWidth > 0 && mActorGameObject.actorData.spriteHeight > 0)
         {
            mStarlingRenderer.setContentScale(mActorGameObject.actorData.spriteWidth / _loc2_,mActorGameObject.actorData.spriteHeight / _loc12_);
         }
         addStarlingAnimation("run",movieClipClassName);
         addStarlingAnimation("suffer",movieClipClassName);
         addStarlingAnimation("death",movieClipClassName);
         syncStarlingTransform();
         if(mAnimName != null)
         {
            this.play(mAnimName,0,true,mLoop);
         }
         else
         {
            this.stop();
         }
         updateStarlingHitArea();
         this.visible = mPendingVisible;
         mStarlingRenderer.setLayer(mPendingLayer);
         if(mHighlightActive)
         {
            mStarlingRenderer.setHighlightFilter(mHighlightColor,mHighlightAlpha,mHighlightBlur);
         }
         if(mPersistentGlowActive)
         {
            mStarlingRenderer.setPersistentGlowFilter(mPersistentGlowColor,mPersistentGlowAlpha,mPersistentGlowBlur);
         }
         if(mColorFilterMatrix != null)
         {
            mStarlingRenderer.setColorFilter(mColorFilterMatrix);
         }
         if(mStatusTintAmount > 0)
         {
            mStarlingRenderer.setStatusTint(mStatusTintColor,mStatusTintAmount);
         }
         startStarlingSync();
         notifyLoadComplete();
         return true;
      }
      
      private function resolveActorClip(className:String, libraryKey:String = null) : Animation
      {
         if(className == null)
         {
            return null;
         }
         var _loc3_:Animation = mDBFacade.assetLoadingComponent.createAnimationFromAtlas(starlingAtlasName,className);
         if(_loc3_ == null)
         {
            _loc3_ = mDBFacade.assetLoadingComponent.createAnimationFromAssetManager(className,libraryKey);
         }
         if(_loc3_ != null && _loc3_.symbolName == "__BTA_TEMP_SPRITEMAP_PACKED_SYMBOL")
         {
            _loc3_.dispose();
            _loc3_ = null;
         }
         return _loc3_;
      }
      
      protected function isStarlingMultiDirectionAnim(animation:Animation) : Boolean
      {
         return animation.getFrame("idle_angE") >= 0 || animation.getFrame("idle_angB") >= 0 || animation.getFrame("idle_angD") >= 0;
      }
      
      private function addStarlingAnimation(animName:String, movieClipClassName:String) : void
      {
         var _loc3_:Animation = resolveActorClip(movieClipClassName + "_" + animName,npcLibraryKey);
         if(_loc3_ != null)
         {
            mStarlingRenderer.addAnimation(animName,_loc3_);
         }
      }
      
      protected function updateStarlingHitArea() : void
      {
         if(mStarlingRenderer == null || mActorGameObject == null)
         {
            return;
         }
         var _loc1_:ActorView = mActorGameObject.actorView;
         if(_loc1_ == null || _loc1_.fixedMouseHitRect != null)
         {
            return;
         }
         _loc1_.setStarlingHitArea(mStarlingRenderer.getLocalBounds());
      }
      
      protected function startStarlingSync() : void
      {
         if(mStarlingSyncComponent != null)
         {
            return;
         }
         mStarlingSyncComponent = new LayerWorkComponent(mDBFacade,"ActorRenderer");
         mStarlingSyncComponent.doEveryFrame(onStarlingSyncFrame);
      }
      
      private function onStarlingSyncFrame(clock:GameClock) : void
      {
         var _loc2_:ActorView = null;
         syncStarlingTransform(true);
         mLayerSyncedStarlingRenderer = mStarlingRenderer;
         if(mTileStretchPending)
         {
            stretchTileToStarlingArt();
         }
         if(mUnculledSinceLastFrame)
         {
            mUnculledSinceLastFrame = false;
            _loc2_ = mActorGameObject != null ? mActorGameObject.actorView : null;
            if(_loc2_ != null && _loc2_.bodyAnimRenderer == this)
            {
               mActorGameObject.refreshRunIdleAnim();
            }
         }
      }
      
      private function syncStarlingTransformUntilLayerSynced() : void
      {
         if(mLayerSyncedStarlingRenderer != mStarlingRenderer)
         {
            syncStarlingTransform();
         }
      }
      
      protected function syncStarlingTransform(updateCulling:Boolean = false) : void
      {
         var _loc19_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc22_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc15_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc2_:Boolean = false;
         var _loc26_:Boolean = false;
         if(mStarlingRenderer == null || mActorGameObject == null)
         {
            return;
         }
         var _loc14_:ActorView = mActorGameObject.actorView;
         if(_loc14_ == null || _loc14_.root == null)
         {
            return;
         }
         var _loc24_:Sprite = _loc14_.root;
         var _loc8_:Number = _loc24_.x;
         var _loc10_:Number = _loc24_.y;
         var _loc12_:Number = _loc24_.rotation;
         var _loc6_:Number = _loc24_.scaleX;
         var _loc7_:Number = _loc24_.scaleY;
         var _loc25_:Number = _loc24_.alpha;
         var _loc20_:Boolean = _loc24_.visible;
         var _loc16_:Number = _loc12_;
         var _loc21_:NPCGameObject = mActorGameObject as NPCGameObject;
         if(_loc21_ && _loc21_.gmNpc.UseFlashRotation)
         {
            _loc16_ += _loc21_.flip ? -mHeading + 180 : mHeading;
         }
         var _loc9_:Sprite = _loc14_.body;
         var _loc3_:Number = _loc9_ != null ? _loc9_.scaleX : _loc6_;
         var _loc4_:Number = _loc9_ != null ? _loc9_.scaleY : _loc7_;
         var _loc11_:Number = this.x;
         var _loc13_:Number = this.y;
         if(mStarlingRenderer.transformStale || _loc25_ > 1 || _loc25_ < 0 || _loc8_ != mSyncedRootX || _loc10_ != mSyncedRootY || _loc12_ != mSyncedRootRotation || _loc16_ != mSyncedRotation || _loc6_ != mSyncedRootScaleX || _loc7_ != mSyncedRootScaleY || _loc25_ != mSyncedRootAlpha || _loc3_ != mSyncedBodyScaleX || _loc4_ != mSyncedBodyScaleY || _loc11_ != mSyncedOffsetX || _loc13_ != mSyncedOffsetY)
         {
            _loc19_ = _loc11_ * _loc3_ * _loc6_;
            _loc17_ = _loc13_ * _loc4_ * _loc7_;
            if(_loc12_ == 0 && isFinite(_loc19_) && isFinite(_loc17_))
            {
               _loc22_ = _loc8_ + _loc19_;
               _loc23_ = _loc10_ + _loc17_;
            }
            else
            {
               _loc15_ = _loc12_ * 3.141592653589793 / 180;
               _loc5_ = Math.cos(_loc15_);
               _loc18_ = Math.sin(_loc15_);
               _loc22_ = _loc8_ + _loc19_ * _loc5_ - _loc17_ * _loc18_;
               _loc23_ = _loc10_ + _loc19_ * _loc18_ + _loc17_ * _loc5_;
            }
            mStarlingRenderer.setTransform(_loc22_,_loc23_,_loc16_ * 3.141592653589793 / 180,_loc6_ * _loc3_,_loc7_ * _loc4_,_loc25_,_loc8_,_loc10_);
            mSyncedRootX = _loc8_;
            mSyncedRootY = _loc10_;
            mSyncedRootRotation = _loc12_;
            mSyncedRotation = _loc16_;
            mSyncedRootScaleX = _loc6_;
            mSyncedRootScaleY = _loc7_;
            mSyncedRootAlpha = _loc25_;
            mSyncedBodyScaleX = _loc3_;
            mSyncedBodyScaleY = _loc4_;
            mSyncedOffsetX = _loc11_;
            mSyncedOffsetY = _loc13_;
            mSyncedWorldX = _loc22_;
            mSyncedWorldY = _loc23_;
         }
         else
         {
            mStarlingRenderer.markLayerDirty();
         }
         if(updateCulling)
         {
            _loc2_ = _loc20_ && testCulled(mSyncedWorldX,mSyncedWorldY,Math.max(Math.abs(_loc6_ * _loc3_),Math.abs(_loc7_ * _loc4_)));
            if(mCulled && !_loc2_)
            {
               mUnculledSinceLastFrame = true;
            }
            _loc26_ = mCulled != _loc2_;
            mCulled = _loc2_;
            if(_loc26_ && _loc9_ != null && _loc14_.bodyAnimRenderer == this)
            {
               updateWeaponCulling(_loc9_);
            }
         }
         mStarlingRenderer.setVisibility(_loc20_,mCulled);
         mPendingVisible = _loc20_;
      }
      
      protected function testCulled(drawX:Number, drawY:Number, scale:Number) : Boolean
      {
         return isOffScreen(drawX,drawY,scale);
      }
      
      private function updateWeaponCulling(body:Sprite) : void
      {
         var _loc3_:int = 0;
         var _loc2_:WeaponRenderer = null;
         _loc3_ = 0;
         while(_loc3_ < body.numChildren)
         {
            _loc2_ = body.getChildAt(_loc3_) as WeaponRenderer;
            if(_loc2_ != null)
            {
               _loc2_.followWielderCulling(mCulled);
            }
            _loc3_++;
         }
      }
      
      public function get isCulled() : Boolean
      {
         return mCulled;
      }
      
      public function get hasStarlingArt() : Boolean
      {
         return mStarlingRenderer != null;
      }
      
      private function isOffScreen(drawX:Number, drawY:Number, scale:Number) : Boolean
      {
         if(mActorGameObject.isOwner || mDBFacade.camera == null)
         {
            return false;
         }
         var _loc4_:Number = mStarlingRenderer.canvasReach;
         var _loc5_:ActorData = mActorGameObject.actorData;
         var _loc6_:Number = _loc5_ != null ? Math.max(_loc5_.spriteWidth,_loc5_.spriteHeight) : NaN;
         if(_loc6_ > 0)
         {
            _loc4_ = Math.max(_loc4_,_loc6_);
         }
         else
         {
            if(mContentRadiusStale)
            {
               mContentRadius = Math.max(mContentRadius,mStarlingRenderer.getContentRadius());
               mContentRadiusStale = false;
            }
            _loc4_ = Math.max(_loc4_,mContentRadius);
         }
         return !mDBFacade.camera.isInCullView(drawX,drawY,256 + _loc4_ * scale);
      }
      
      private function resetContentRadius() : void
      {
         mContentRadius = 0;
         mContentRadiusStale = true;
      }
      
      private function get stretchesTile() : Boolean
      {
         return mTriggerState && mActorGameObject is NPCGameObject && mActorGameObject.actorData != null && mActorGameObject.actorData.gMActor != null && mActorGameObject.isProp && !mActorGameObject.actorData.isMover;
      }
      
      private function stretchTileToStarlingArt() : void
      {
         var _loc1_:Tile = mActorGameObject != null ? mActorGameObject.tile : null;
         if(_loc1_ == null || mStarlingRenderer == null || isNaN(mSyncedWorldX))
         {
            return;
         }
         mTileStretchPending = false;
         if(mAnimName == "death")
         {
            return;
         }
         var _loc2_:Rectangle = mStarlingRenderer.getWorldBounds();
         if(!_loc2_.isEmpty())
         {
            _loc1_.expandBoundsRect(_loc2_);
         }
      }
      
      private function onTileStretchFrame(clock:GameClock) : void
      {
         if(stretchTileToFlashArt(mTileStretchClip))
         {
            stopTileStretchWork();
         }
      }
      
      private function stopTileStretchWork() : void
      {
         if(mTileStretchWork != null)
         {
            mTileStretchWork.destroy();
         }
         mTileStretchWork = null;
         mTileStretchClip = null;
      }
      
      private function stretchTileToFlashArt(idleClip:MovieClip) : Boolean
      {
         var _loc2_:DisplayObject = null;
         var _loc4_:Tile = mActorGameObject != null ? mActorGameObject.tile : null;
         var _loc3_:ActorView = mActorGameObject != null ? mActorGameObject.actorView : null;
         if(_loc4_ == null || _loc3_ == null || _loc3_.root == null)
         {
            return false;
         }
         var _loc6_:Matrix = idleClip.transform.matrix;
         _loc2_ = this;
         while(_loc2_ != _loc3_.root)
         {
            if(_loc2_ == null)
            {
               return false;
            }
            _loc6_.concat(_loc2_.transform.matrix);
            _loc2_ = _loc2_.parent;
         }
         if(mAnimName == "death")
         {
            return true;
         }
         _loc6_.concat(_loc3_.root.transform.matrix);
         var _loc5_:Rectangle = boundsThrough(idleClip.getBounds(idleClip),_loc6_);
         if(!_loc5_.isEmpty())
         {
            _loc4_.expandBoundsRect(_loc5_);
         }
         return true;
      }
      
      protected function movieClipSwfLoaded(movieClipClassName:String, swfAsset:SwfAsset) : void
      {
         var _loc9_:ActorMovieClipRenderer = null;
         var _loc7_:MovieClip = null;
         var _loc6_:MovieClip = null;
         var _loc10_:MovieClip = null;
         var _loc16_:MovieClip = null;
         if(!movieClipClassName)
         {
            notifyLoadComplete();
            return;
         }
         var _loc15_:String = movieClipClassName;
         var _loc12_:String = movieClipClassName + "_" + "run";
         var _loc3_:String = movieClipClassName + "_" + "suffer";
         var _loc13_:String = movieClipClassName + "_" + "death";
         var _loc4_:Class = swfAsset.getClass(_loc15_,false);
         var _loc14_:Class = swfAsset.getClass(_loc12_,true);
         var _loc5_:Class = swfAsset.getClass(_loc3_,true);
         var _loc11_:Class = swfAsset.getClass(_loc13_,true);
         var _loc8_:Boolean = isSwfFallbackDebug();
         if(_loc4_ != null)
         {
            _loc7_ = new _loc4_();
            if(_loc8_)
            {
               SwfFallbackDebug.applyOutline(mDBFacade,_loc7_);
            }
            _loc9_ = new ActorMovieClipRenderer(mDBFacade,_loc7_);
            setAnimInDictionary("idle",_loc9_);
            movieClipRendererLoaded(_loc7_);
            if(stretchesTile && mTileStretchWork == null)
            {
               mTileStretchClip = _loc7_;
               mTileStretchWork = new LayerWorkComponent(mDBFacade,"ActorRenderer.tileStretch");
               mTileStretchWork.doEveryFrame(onTileStretchFrame);
            }
         }
         if(_loc14_ != null)
         {
            _loc6_ = new _loc14_();
            if(_loc8_)
            {
               SwfFallbackDebug.applyOutline(mDBFacade,_loc6_);
            }
            _loc9_ = new ActorMovieClipRenderer(mDBFacade,_loc6_);
            setAnimInDictionary("run",_loc9_);
         }
         if(_loc5_ != null)
         {
            _loc10_ = new _loc5_();
            if(_loc8_)
            {
               SwfFallbackDebug.applyOutline(mDBFacade,_loc10_);
            }
            _loc9_ = new ActorMovieClipRenderer(mDBFacade,_loc10_);
            setAnimInDictionary("suffer",_loc9_);
         }
         if(_loc11_ != null)
         {
            _loc16_ = new _loc11_();
            if(_loc8_)
            {
               SwfFallbackDebug.applyOutline(mDBFacade,_loc16_);
            }
            _loc9_ = new ActorMovieClipRenderer(mDBFacade,_loc16_);
            setAnimInDictionary("death",_loc9_);
         }
         notifyLoadComplete();
      }
      
      protected function movieClipRendererLoaded(asset:MovieClip) : void
      {
      }
      
      protected function reportSwfFallback(reason:String, asError:Boolean = true) : void
      {
         var _loc6_:Boolean = mActorGameObject != null && mActorGameObject.actorData != null;
         var _loc4_:String = _loc6_ ? mActorGameObject.actorData.constant : "?";
         var _loc5_:String = _loc6_ ? movieClipClassName : null;
         var _loc3_:String = _loc6_ ? this.swfFilePath : null;
         SwfFallbackDebug.report(mDBFacade,fallbackCategory,_loc4_ + " (" + _loc5_ + ")",_loc3_,reason,asError);
      }
      
      protected function get fallbackCategory() : String
      {
         if(mActorGameObject == null || mActorGameObject.actorData == null || mActorGameObject.actorData.gMActor == null)
         {
            return "ACTOR";
         }
         var _loc1_:Object = mActorGameObject.actorData.gMActor;
         return "ACTOR:" + _loc1_.CharType + "/" + _loc1_.Species;
      }
      
      private function isSwfFallbackDebug() : Boolean
      {
         return SwfFallbackDebug.isEnabled(mDBFacade,fallbackCategory);
      }
      
      protected function loadErrorCallback() : void
      {
         Logger.error("loadAnimatedSpriteSheetRenderer error");
      }
      
      public function get currentAnimName() : String
      {
         return mAnimName;
      }
      
      public function setLayer(layerIndex:int) : void
      {
         mPendingLayer = layerIndex;
         if(mStarlingRenderer != null)
         {
            mStarlingRenderer.setLayer(layerIndex);
         }
      }
      
      public function setHighlightFilter(color:uint, alpha:Number = 8, blur:Number = 2) : void
      {
         mHighlightActive = true;
         mHighlightColor = color;
         mHighlightAlpha = alpha;
         mHighlightBlur = blur;
         if(mStarlingRenderer != null)
         {
            mStarlingRenderer.setHighlightFilter(color,alpha,blur);
         }
      }
      
      public function clearHighlightFilter() : void
      {
         mHighlightActive = false;
         if(mStarlingRenderer != null)
         {
            mStarlingRenderer.clearHighlightFilter();
         }
      }
      
      public function setPersistentGlowFilter(color:uint, alpha:Number = 8, blur:Number = 2) : void
      {
         mPersistentGlowActive = true;
         mPersistentGlowColor = color;
         mPersistentGlowAlpha = alpha;
         mPersistentGlowBlur = blur;
         if(mStarlingRenderer != null)
         {
            mStarlingRenderer.setPersistentGlowFilter(color,alpha,blur);
         }
      }
      
      public function clearPersistentGlowFilter() : void
      {
         mPersistentGlowActive = false;
         if(mStarlingRenderer != null)
         {
            mStarlingRenderer.clearPersistentGlowFilter();
         }
      }
      
      public function applyColorFilter(matrix:Array) : void
      {
         mColorFilterMatrix = matrix;
         if(mStarlingRenderer != null)
         {
            mStarlingRenderer.setColorFilter(matrix);
         }
      }
      
      public function clearColorFilter() : void
      {
         mColorFilterMatrix = null;
         if(mStarlingRenderer != null)
         {
            mStarlingRenderer.clearColorFilter();
         }
      }
      
      public function applyStatusTint(color:uint, amount:Number) : void
      {
         mStatusTintColor = color;
         mStatusTintAmount = amount;
         if(mStarlingRenderer != null)
         {
            mStarlingRenderer.setStatusTint(color,amount);
         }
      }
      
      public function clearStatusTint() : void
      {
         mStatusTintAmount = 0;
         if(mStarlingRenderer != null)
         {
            mStarlingRenderer.clearStatusTint();
         }
      }
      
      protected function setAnimInDictionary(animName:String, renderer:IRenderer) : void
      {
         if(mIsStarlingBound || mStarlingRenderer != null)
         {
            renderer.destroy();
            return;
         }
         mAnims.add(animName,renderer);
         if(mAnimName == animName)
         {
            this.play(mAnimName,0,true,mLoop);
         }
      }
      
      public function hasAnim(animName:String) : Boolean
      {
         if(mStarlingRenderer != null)
         {
            return mStarlingRenderer.hasAnim(animName);
         }
         if(mIsStarlingBound && (animName == "idle" || animName == "run" || animName == "suffer"))
         {
            return true;
         }
         var _loc2_:IRenderer = this.getRenderer(animName);
         return _loc2_ != null;
      }
      
      public function getAnimDurationInSeconds(animName:String) : Number
      {
         if(mStarlingRenderer != null)
         {
            return mStarlingRenderer.getAnimDurationInSeconds(animName);
         }
         var _loc2_:IRenderer = mAnims.itemFor(animName);
         return _loc2_ ? _loc2_.durationInSeconds : 0;
      }
      
      public function getAnimFrameCount(animName:String) : Number
      {
         if(mStarlingRenderer != null)
         {
            return mStarlingRenderer.getAnimFrameCount(animName);
         }
         var _loc2_:IRenderer = mAnims.itemFor(animName);
         return _loc2_ ? _loc2_.frameCount : 0;
      }
      
      public function loadAssets() : void
      {
         switch(this.assetType)
         {
            case "SPRITE_SHEET":
               if(isStarlingActor && !mActorGameObject.forceFlash)
               {
                  this.y = ActorView.BODY_Y_OFFSET;
                  mIsStarlingBound = true;
                  loadMovieClipAssets();
               }
               else
               {
                  reportSwfFallback(mActorGameObject != null && mActorGameObject.forceFlash ? "forceFlash is set" : (StarlingAssetMapper.getActorAtlasFile(swfFilePath) == null ? "no ATF atlas folder with Animation.json at " + swfFilePath.substring(0,swfFilePath.lastIndexOf(".")) : "actor is a prop or has no GameMaster actor row"));
                  this.y = ActorView.BODY_Y_OFFSET;
                  if(mPreloadSprites)
                  {
                     loadSpriteSheetAssets();
                  }
                  else
                  {
                     preloadStandardSpriteSheetAssets();
                  }
               }
               break;
            case "MOVIE_CLIP":
               loadMovieClipAssets();
               break;
            default:
               Logger.error("Unknown assetType: " + this.assetType);
         }
      }
      
      protected function loadSpriteSheetAsset(animName:String) : void
      {
         var spriteSheetSwfPath:String;
         var shClassName:String;
         if(mAnims.hasKey(animName))
         {
            return;
         }
         if(mLoadingAnims.itemFor(animName))
         {
            return;
         }
         mLoadingAnims.add(animName,true);
         spriteSheetSwfPath = this.swfFilePath;
         if(StarlingAssetMapper.isArt3DPath(spriteSheetSwfPath))
         {
            return;
         }
         shClassName = getSpriteSheetClassName(animName);
         mAssetLoadingComponent.getSpriteSheetAsset(spriteSheetSwfPath,shClassName,function(param1:SpriteSheetAsset):void
         {
            var _loc2_:ActorSpriteSheetRenderer = new ActorSpriteSheetRenderer(mPreRenderWorkComponent,param1,mActorGameObject.actorData.constant);
            if(isSwfFallbackDebug())
            {
               SwfFallbackDebug.applyOutline(mDBFacade,_loc2_.displayObject);
            }
            setAnimInDictionary(animName,_loc2_);
         },loadErrorCallback,true,null,shClassName);
      }
      
      protected function preloadStandardSpriteSheetAssets() : void
      {
         for each(var _loc1_:String in mStandardAnimList)
         {
            loadSpriteSheetAsset(_loc1_);
         }
      }
      
      protected function loadSpriteSheetAssets() : void
      {
         preloadStandardSpriteSheetAssets();
      }
      
      protected function getRenderer(animName:String) : IRenderer
      {
         var _loc2_:IRenderer = mAnims.itemFor(animName);
         if(_loc2_ == null && this.assetType == "SPRITE_SHEET" && !mIsStarlingBound)
         {
            loadSpriteSheetAsset(animName);
         }
         return _loc2_;
      }
      
      public function forceFrame(frameNumber:int) : void
      {
         if(mStarlingRenderer != null)
         {
            mStarlingRenderer.forceFrame(frameNumber);
            return;
         }
         if(mCurrentRenderer)
         {
            mCurrentRenderer.setFrame(frameNumber);
         }
      }
      
      public function setFrame(animName:String, frameNumber:int) : void
      {
         if(mStarlingRenderer != null)
         {
            mAnimName = animName;
            if(mStarlingRenderer.heading != mHeading)
            {
               mStarlingRenderer.heading = mHeading;
            }
            if(false && mActorGameObject != null)
            {
               Logger.debugch("heading","ActorRenderer setFrame id=" + mActorGameObject.id + " const=" + (mActorGameObject.actorData ? mActorGameObject.actorData.constant : "?") + " anim=" + animName + " heading=" + mHeading + " starlingLabel=" + mStarlingRenderer.currentDirectionLabel);
            }
            syncStarlingTransformUntilLayerSynced();
            mStarlingRenderer.setFrame(animName,frameNumber);
            updateStarlingHitArea();
            mContentRadiusStale = true;
            return;
         }
         stop();
         var _loc3_:IRenderer = this.getRenderer(animName);
         if(_loc3_)
         {
            mCurrentRenderer = _loc3_;
            this.heading = mHeading;
            this.addChild(mCurrentRenderer.displayObject);
            mCurrentRenderer.setFrame(frameNumber);
         }
      }
      
      public function play(animName:String, startingFrame:int = 0, restart:Boolean = false, loop:Boolean = true, playRate:Number = 1) : void
      {
         mAnimName = animName;
         mLoop = loop;
         if(mStarlingRenderer != null)
         {
            if(mStarlingRenderer.heading != mHeading)
            {
               mStarlingRenderer.heading = mHeading;
            }
            if(restart || mStarlingRenderer.currentAnimName != animName)
            {
               mStarlingRenderer.play(animName,startingFrame,mLoop,playRate);
               updateStarlingHitArea();
               mContentRadiusStale = true;
            }
            else
            {
               mStarlingRenderer.playRate = playRate;
               mStarlingRenderer.loop = loop;
            }
            if(false && mActorGameObject != null)
            {
               Logger.debugch("heading","ActorRenderer play id=" + mActorGameObject.id + " const=" + (mActorGameObject.actorData ? mActorGameObject.actorData.constant : "?") + " anim=" + animName + " heading=" + mHeading + " starlingAnim=" + mStarlingRenderer.currentAnimName + " starlingLabel=" + mStarlingRenderer.currentDirectionLabel);
            }
            syncStarlingTransformUntilLayerSynced();
            return;
         }
         var _loc6_:IRenderer = this.getRenderer(animName);
         if(_loc6_)
         {
            _loc6_.playRate = playRate;
            if(mCurrentRenderer == _loc6_)
            {
               if(restart)
               {
                  _loc6_.play(startingFrame,mLoop);
               }
            }
            else
            {
               stop();
               mAnimName = animName;
               mLoop = loop;
               mCurrentRenderer = _loc6_;
               this.heading = mHeading;
               _loc6_.play(startingFrame,mLoop);
               this.addChild(mCurrentRenderer.displayObject);
            }
         }
      }
      
      public function set heading(value:Number) : void
      {
         var _loc4_:String = null;
         var _loc2_:NPCGameObject = null;
         var _loc3_:Boolean = false;
         mHeading = value;
         if(false && mActorGameObject != null)
         {
            _loc4_ = mStarlingRenderer != null ? mStarlingRenderer.rendererType : (mCurrentRenderer != null ? mCurrentRenderer.rendererType : "null");
            Logger.debugch("heading","ActorRenderer set heading id=" + mActorGameObject.id + " const=" + (mActorGameObject.actorData ? mActorGameObject.actorData.constant : "?") + " heading=" + mHeading + " renderer=" + _loc4_ + " anim=" + mAnimName);
         }
         if(mStarlingRenderer != null)
         {
            mStarlingRenderer.heading = value;
            syncStarlingTransformUntilLayerSynced();
            return;
         }
         if(mCurrentRenderer)
         {
            mCurrentRenderer.heading = value;
            _loc2_ = mActorGameObject as NPCGameObject;
            if(_loc2_ && _loc2_.gmNpc.UseFlashRotation)
            {
               if(_loc2_.flip)
               {
                  mCurrentRenderer.displayObject.rotation = -mHeading + 180;
               }
               else
               {
                  mCurrentRenderer.displayObject.rotation = mHeading;
               }
            }
            if(mCurrentRenderer is ActorSpriteSheetRenderer)
            {
               _loc3_ = 90 > mHeading && mHeading > -90;
               this.scaleX = _loc3_ ? 1 : -1;
            }
         }
      }
      
      public function get currentFrame() : int
      {
         if(mStarlingRenderer != null)
         {
            return mStarlingRenderer.currentFrame;
         }
         if(mCurrentRenderer)
         {
            return mCurrentRenderer.currentFrame;
         }
         return 0;
      }
      
      public function get loop() : Boolean
      {
         return mLoop;
      }
      
      override public function set visible(value:Boolean) : void
      {
         mPendingVisible = value;
         if(mStarlingRenderer != null)
         {
            mStarlingRenderer.visible = value;
            super.visible = false;
         }
         else
         {
            super.visible = value;
         }
      }
      
      public function stop() : void
      {
         if(mStarlingRenderer != null)
         {
            mStarlingRenderer.stop();
            mAnimName = null;
            return;
         }
         if(mCurrentRenderer)
         {
            mCurrentRenderer.stop();
            if(this.contains(mCurrentRenderer.displayObject))
            {
               this.removeChild(mCurrentRenderer.displayObject);
            }
            mCurrentRenderer = null;
            mAnimName = null;
         }
      }
   }
}

