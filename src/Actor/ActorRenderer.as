package Actor
{
   import Brain.AssetRepository.AssetLoadingComponent;
   import Brain.AssetRepository.SpriteSheetAsset;
   import Brain.AssetRepository.SwfAsset;
   import Brain.Logger.Logger;
   import Brain.Render.ActorSpriteSheetRenderer;
   import Brain.Render.IRenderer;
   import Brain.WorkLoop.PreRenderWorkComponent;
   import DistributedObjects.NPCGameObject;
   import Facade.DBFacade;
   import flash.display.MovieClip;
   import flash.display.Sprite;
   import org.as3commons.collections.Map;
   import org.as3commons.collections.framework.IMapIterator;
   
   public class ActorRenderer extends Sprite
   {
      
      public static const IDLE_ANIM_NAME:String = "idle";
      
      public static const RUN_ANIM_NAME:String = "run";
      
      public static const SUFFER_ANIM_NAME:String = "suffer";
      
      public static const DEATH_ANIM_NAME:String = "death";
      
      public static const mStandardAnimList:Array = new Array("idle","death");
      
      protected var mDBFacade:DBFacade;
      
      protected var mAnims:Map;
      
      protected var mLoadingAnims:Map;
      
      protected var mTriggerState:Boolean;
      
      protected var mAssetLoadingComponent:AssetLoadingComponent;
      
      protected var mPreRenderWorkComponent:PreRenderWorkComponent;
      
      protected var mCurrentRenderer:IRenderer;
      
      protected var mActorGameObject:ActorGameObject;
      
      protected var mHeading:Number = 0;
      
      protected var mAnimName:String;
      
      protected var mLoop:Boolean;
      
      private var mPreloadSprites:Boolean;
      
      public function ActorRenderer(dbFacade:DBFacade, actorGameObject:ActorGameObject, triggerState:Boolean)
      {
         super();
         this.name = "ActorRenderer";
         mActorGameObject = actorGameObject;
         mDBFacade = dbFacade;
         mTriggerState = triggerState;
         mAnims = new Map();
         mLoadingAnims = new Map();
         mAssetLoadingComponent = new AssetLoadingComponent(mDBFacade);
         mPreRenderWorkComponent = new PreRenderWorkComponent(mDBFacade,"ActorRenderer");
         mPreloadSprites = mDBFacade.dbConfigManager.getConfigBoolean("preload_sprites",false);
      }
      
      public static function cache_loadSpriteSheetAsset(dbFacade:DBFacade, spriteSheetSwfPath:String, spriteHeight:uint, spriteWidth:uint, assetType:String, weaponsNamesIn:Vector.<String>) : void
      {
         var trash_AssetLoadingComponent:AssetLoadingComponent = new AssetLoadingComponent(dbFacade);
         if(assetType)
         {
            trash_AssetLoadingComponent.getSwfAsset(spriteSheetSwfPath,function(param1:SwfAsset):void
            {
            });
         }
         else
         {
            trash_AssetLoadingComponent.getSwfAsset(spriteSheetSwfPath,function(param1:SwfAsset):void
            {
            });
         }
      }
      
      public function get rendererType() : String
      {
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
         mAssetLoadingComponent.destroy();
         mPreRenderWorkComponent.destroy();
         mActorGameObject = null;
         mDBFacade = null;
         mCurrentRenderer = null;
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
         var swfPath:String = this.swfFilePath;
         var className:String = movieClipClassName;
         this.mAssetLoadingComponent.getSwfAsset(swfPath,function(param1:SwfAsset):void
         {
            movieClipSwfLoaded(className,param1);
         });
      }
      
      protected function movieClipSwfLoaded(movieClipClassName:String, swfAsset:SwfAsset) : void
      {
         var _loc8_:ActorMovieClipRenderer = null;
         var _loc6_:MovieClip = null;
         if(!movieClipClassName)
         {
            return;
         }
         var _loc12_:String = movieClipClassName;
         var _loc7_:String = movieClipClassName + "_" + "run";
         var _loc3_:String = movieClipClassName + "_" + "suffer";
         var _loc9_:String = movieClipClassName + "_" + "death";
         var _loc4_:Class = swfAsset.getClass(_loc12_,false);
         var _loc10_:Class = swfAsset.getClass(_loc7_,true);
         var _loc5_:Class = swfAsset.getClass(_loc3_,true);
         var _loc11_:Class = swfAsset.getClass(_loc9_,true);
         if(_loc4_ != null)
         {
            _loc6_ = new _loc4_();
            _loc8_ = new ActorMovieClipRenderer(mDBFacade,_loc6_);
            setAnimInDictionary("idle",_loc8_);
            movieClipRendererLoaded(_loc6_);
         }
         if(_loc10_ != null)
         {
            _loc8_ = new ActorMovieClipRenderer(mDBFacade,new _loc10_());
            setAnimInDictionary("run",_loc8_);
         }
         if(_loc5_ != null)
         {
            _loc8_ = new ActorMovieClipRenderer(mDBFacade,new _loc5_());
            setAnimInDictionary("suffer",_loc8_);
         }
         if(_loc11_ != null)
         {
            _loc8_ = new ActorMovieClipRenderer(mDBFacade,new _loc11_());
            setAnimInDictionary("death",_loc8_);
         }
      }
      
      protected function movieClipRendererLoaded(asset:MovieClip) : void
      {
      }
      
      protected function loadErrorCallback() : void
      {
         Logger.error("loadAnimatedSpriteSheetRenderer error");
      }
      
      public function get currentAnimName() : String
      {
         return mAnimName;
      }
      
      protected function setAnimInDictionary(animName:String, renderer:IRenderer) : void
      {
         mAnims.add(animName,renderer);
         if(mAnimName == animName)
         {
            this.play(mAnimName,0,true,mLoop);
         }
      }
      
      public function hasAnim(animName:String) : Boolean
      {
         var _loc2_:IRenderer = this.getRenderer(animName);
         return _loc2_ != null;
      }
      
      public function getAnimDurationInSeconds(animName:String) : Number
      {
         var _loc2_:IRenderer = mAnims.itemFor(animName);
         return _loc2_ ? _loc2_.durationInSeconds : 0;
      }
      
      public function getAnimFrameCount(animName:String) : Number
      {
         var _loc2_:IRenderer = mAnims.itemFor(animName);
         return _loc2_ ? _loc2_.frameCount : 0;
      }
      
      public function loadAssets() : void
      {
         switch(this.assetType)
         {
            case "SPRITE_SHEET":
               this.y = ActorView.BODY_Y_OFFSET * (1 / mActorGameObject.actorData.scale3DModel);
               if(mPreloadSprites)
               {
                  loadSpriteSheetAssets();
               }
               else
               {
                  preloadStandardSpriteSheetAssets();
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
         shClassName = getSpriteSheetClassName(animName);
         mAssetLoadingComponent.getSpriteSheetAsset(spriteSheetSwfPath,shClassName,function(param1:SpriteSheetAsset):void
         {
            var _loc2_:ActorSpriteSheetRenderer = new ActorSpriteSheetRenderer(mPreRenderWorkComponent,param1,mActorGameObject.actorData.constant);
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
         if(_loc2_ == null && this.assetType == "SPRITE_SHEET")
         {
            loadSpriteSheetAsset(animName);
         }
         return _loc2_;
      }
      
      public function forceFrame(frameNumber:int) : void
      {
         if(mCurrentRenderer)
         {
            mCurrentRenderer.setFrame(frameNumber);
         }
      }
      
      public function setFrame(animName:String, frameNumber:int) : void
      {
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
         var _loc2_:NPCGameObject = null;
         var _loc3_:Boolean = false;
         mHeading = value;
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
      
      public function stop() : void
      {
         if(mCurrentRenderer)
         {
            mCurrentRenderer.stop();
            if(this.contains(mCurrentRenderer.displayObject))
            {
               this.removeChild(mCurrentRenderer.displayObject);
            }
            mCurrentRenderer = null;
            mLoop = false;
            mAnimName = null;
         }
      }
   }
}

