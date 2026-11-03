package Actor
{
   import Brain.Logger.Logger;
   import Brain.Starling.StarlingLayer;
   import Brain.Utils.MemoryTracker;
   import Collections.IMapIterator;
   import Collections.Map;
   import Facade.DBFacade;
   import Starling.StatusTintFilter;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import starling.display.DisplayObject;
   import starling.display.DisplayObjectContainer;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.events.Event;
   import starling.extensions.animate.Animation;
   import starling.extensions.animate.styles.ColorTransformStyle;
   import starling.filters.FilterChain;
   import starling.filters.FragmentFilter;
   import starling.filters.GlowFilter;
   import starling.textures.Texture;
   
   public class StarlingActorRenderer
   {
      
      public static const STARLING_ACTOR_RENDERER_TYPE:String = "StarlingActorRenderer";
      
      private static const NO_LOOP_LABEL:String = "noloop";
      
      private static const SUFFIX_A:String = "_angA";
      
      private static const SUFFIX_B:String = "_angB";
      
      private static const SUFFIX_C:String = "_angC";
      
      private static const SUFFIX_D:String = "_angD";
      
      private static const SUFFIX_E:String = "_angE";
      
      private static const DEBUG_HEADING:Boolean = false;
      
      private static const FACING_HYSTERESIS:Number = 10;
      
      private static const DIRECTION_LABELS:Array = ["_angE","_angD","_angB"];
      
      private static const FIVE_DIRECTION_LABELS:Array = ["_angE","_angD","_angC","_angB","_angA"];
      
      private static const sWarnedMissingLabels:Object = {};
      
      protected var mDBFacade:DBFacade;
      
      protected var mHolderName:String;
      
      protected var mContainer:Sprite;
      
      protected var mContent:Sprite;
      
      protected var mLayerIndex:int;
      
      protected var mContentScaleX:Number = 1;
      
      protected var mContentScaleY:Number = 1;
      
      private var mCanvasReach:Number = NaN;
      
      protected var mAnimations:Map;
      
      protected var mBaseFrameRates:Map;
      
      protected var mCurrentAnimation:Animation;
      
      protected var mAnimName:String;
      
      protected var mLoop:Boolean;
      
      protected var mPlayRate:Number = 1;
      
      protected var mStartingFrame:Number = 0;
      
      protected var mVisible:Boolean = true;
      
      protected var mCulled:Boolean = false;
      
      protected var mOffImage:Image;
      
      protected var mFrameImage:Image;
      
      protected var mStaticEnsemble:Sprite;
      
      protected var mHighlightFilter:GlowFilter;
      
      protected var mPersistentGlowFilter:GlowFilter;
      
      protected var mColorMatrix:Vector.<Number>;
      
      protected var mStatusTint:StatusTintFilter = new StatusTintFilter();
      
      protected var mFilterChain:FilterChain;
      
      protected var mMultiDirectionMode:Boolean = false;
      
      protected var mMultiDirectionAnimation:Animation;
      
      protected var mMultiDirectionBaseFrameRate:Number = 0;
      
      protected var mDirectionLabels:Array;
      
      protected var mHeading:Number = 0;
      
      protected var mCurrentDirectionLabel:String;
      
      protected var mFlipX:Number = 1;
      
      private var mBuiltLabelAnim:String;
      
      private var mBuiltLabelSuffix:String;
      
      private var mBuiltLabel:String;
      
      private var mHasMultiDirectionAnimCache:Object;
      
      protected var mDrawOrderOffsetY:Number = 0;
      
      protected var mTransformStale:Boolean = true;
      
      public function StarlingActorRenderer(dbFacade:DBFacade, holderName:String, layerIndex:int)
      {
         super();
         mDBFacade = dbFacade;
         mHolderName = holderName;
         mLayerIndex = layerIndex;
         mAnimations = new Map();
         mBaseFrameRates = new Map();
         mDirectionLabels = DIRECTION_LABELS;
         mContainer = new Sprite();
         mContainer.touchable = false;
         mContainer.name = "StarlingActorRenderer_" + holderName;
         mContent = new Sprite();
         mContent.touchable = false;
         mContainer.addChild(mContent);
         MemoryTracker.track(mContainer,"StarlingActorRenderer - holder: " + holderName,"starling");
         var _loc4_:StarlingLayer = mDBFacade.starlingLayerManager.getLayer(mLayerIndex);
         if(_loc4_ == null)
         {
            Logger.warn("StarlingActorRenderer: no Starling layer for index " + mLayerIndex + ", falling back to SORTED");
            mLayerIndex = 20;
            _loc4_ = mDBFacade.starlingLayerManager.getLayer(mLayerIndex);
         }
         if(_loc4_ != null)
         {
            _loc4_.addChild(mContainer);
            mDBFacade.starlingLayerManager.markLayerDirty(mLayerIndex);
         }
      }
      
      public function get rendererType() : String
      {
         return "StarlingActorRenderer";
      }
      
      public function addAnimation(animName:String, animation:Animation) : void
      {
         if(animation == null)
         {
            return;
         }
         animation.touchable = false;
         animation.stop();
         animation.setColorMatrix(currentColorMatrix());
         mAnimations.add(animName,animation);
         mBaseFrameRates.add(animName,animation.frameRate);
         mCanvasReach = NaN;
      }
      
      public function hasAnim(animName:String) : Boolean
      {
         if(mMultiDirectionMode)
         {
            return hasMultiDirectionAnim(animName);
         }
         return mAnimations.hasKey(animName);
      }
      
      public function get currentAnimName() : String
      {
         return mAnimName;
      }
      
      public function get currentDirectionLabel() : String
      {
         return mCurrentDirectionLabel;
      }
      
      public function getLocalBounds() : Rectangle
      {
         if(mContainer == null)
         {
            return new Rectangle();
         }
         return mContainer.getBounds(mContainer);
      }
      
      public function getWorldBounds() : Rectangle
      {
         var _loc1_:Rectangle = getLocalBounds();
         if(mContainer != null)
         {
            _loc1_.offset(mContainer.x,mContainer.y);
         }
         return _loc1_;
      }
      
      public function getAnimDurationInSeconds(animName:String) : Number
      {
         if(mMultiDirectionMode && mMultiDirectionAnimation != null)
         {
            return getMultiDirectionSegmentDuration(animName);
         }
         var _loc2_:Animation = mAnimations.itemFor(animName) as Animation;
         return _loc2_ ? _loc2_.deepestFrames / _loc2_.frameRate : 0;
      }
      
      public function getAnimFrameCount(animName:String) : Number
      {
         if(mMultiDirectionMode && mMultiDirectionAnimation != null)
         {
            return getMultiDirectionSegmentFrames(animName);
         }
         var _loc2_:Animation = mAnimations.itemFor(animName) as Animation;
         return _loc2_ ? _loc2_.deepestFrames : 0;
      }
      
      private function clampFrame(frameNumber:int, animation:Animation) : int
      {
         if(animation == null)
         {
            return frameNumber;
         }
         var _loc3_:int = animation.numFrames - 1;
         if(frameNumber < 0)
         {
            return 0;
         }
         if(frameNumber > _loc3_)
         {
            return _loc3_;
         }
         return frameNumber;
      }
      
      public function play(animName:String, startingFrame:int = 0, loop:Boolean = true, playRate:Number = 1) : Boolean
      {
         if(mMultiDirectionMode)
         {
            return playMultiDirection(animName,startingFrame,loop,playRate);
         }
         var _loc5_:Animation = mAnimations.itemFor(animName) as Animation;
         if(_loc5_ == null)
         {
            return false;
         }
         showOffImage(false);
         showFrameImage(false);
         if(mCurrentAnimation != null)
         {
            mCurrentAnimation.removeEventListener("complete",onAnimationComplete);
         }
         if(mCurrentAnimation != _loc5_)
         {
            deactivateCurrent();
            mCurrentAnimation = _loc5_;
            mContent.addChild(mCurrentAnimation);
         }
         mAnimName = animName;
         mLoop = loop;
         mCurrentAnimation.loop = loop;
         if(mCurrentAnimation.hasFrameLabel("noloop"))
         {
            mCurrentAnimation.loop = false;
            mCurrentAnimation.setMovieClipsPlayOnce();
            mCurrentAnimation.resetMovieClips();
            mCurrentAnimation.addEventListener("complete",onAnimationComplete);
         }
         else if(!mCurrentAnimation.loop)
         {
            mCurrentAnimation.setMovieClipsPlayOnce();
            mCurrentAnimation.resetMovieClips();
            mCurrentAnimation.addEventListener("complete",onAnimationComplete);
         }
         else
         {
            mCurrentAnimation.clearMovieClipsPlayOnce();
         }
         mCurrentAnimation.currentFrame = clampFrame(startingFrame,_loc5_);
         this.playRate = playRate;
         mCurrentAnimation.play();
         joinJuggler();
         return true;
      }
      
      public function setFrame(animName:String, frameNumber:int) : void
      {
         if(mMultiDirectionMode)
         {
            setFrameMultiDirection(animName,frameNumber);
            return;
         }
         var _loc3_:Animation = mAnimations.itemFor(animName) as Animation;
         if(_loc3_ == null)
         {
            stop();
            return;
         }
         if(mCurrentAnimation != _loc3_)
         {
            deactivateCurrent();
            mCurrentAnimation = _loc3_;
            mContent.addChild(mCurrentAnimation);
         }
         mAnimName = animName;
         mCurrentAnimation.currentFrame = clampFrame(frameNumber,_loc3_);
         mCurrentAnimation.pause();
         leaveJuggler();
         showOffImage(true);
         showFrameImage(true);
      }
      
      public function forceFrame(frameNumber:int) : void
      {
         if(mCurrentAnimation != null)
         {
            mCurrentAnimation.currentFrame = clampFrame(frameNumber,mCurrentAnimation);
         }
      }
      
      public function stop() : void
      {
         deactivateCurrent();
         mAnimName = null;
         mLoop = false;
         showOffImage(true);
         showFrameImage(true);
      }
      
      public function enableMultiDirectionMode(singleAnimation:Animation) : void
      {
         if(singleAnimation == null)
         {
            return;
         }
         mMultiDirectionMode = true;
         mMultiDirectionAnimation = singleAnimation;
         mMultiDirectionBaseFrameRate = singleAnimation.frameRate;
         singleAnimation.setColorMatrix(currentColorMatrix());
         mHasMultiDirectionAnimCache = {};
         mCanvasReach = NaN;
         if(singleAnimation.hasFrameLabelSuffix("_angA") || singleAnimation.hasFrameLabelSuffix("_angC"))
         {
            mDirectionLabels = FIVE_DIRECTION_LABELS;
         }
         else
         {
            mDirectionLabels = DIRECTION_LABELS;
         }
      }
      
      public function get heading() : Number
      {
         return mHeading;
      }
      
      public function set heading(value:Number) : void
      {
         var _loc11_:String = null;
         var _loc12_:Point = null;
         var _loc5_:int = 0;
         var _loc2_:int = 0;
         var _loc8_:Point = null;
         if(!mMultiDirectionMode || mMultiDirectionAnimation == null)
         {
            return;
         }
         mHeading = value;
         if(mAnimName == null || mCurrentAnimation != mMultiDirectionAnimation)
         {
            return;
         }
         var _loc7_:String = buildDirectionLabel(mAnimName,value);
         if(_loc7_ != mCurrentDirectionLabel && mCurrentDirectionLabel != null && mDBFacade.featureFlags.getFlagValue("smooth-run-and-direction-states") && (buildDirectionLabel(mAnimName,value + 10) == mCurrentDirectionLabel || buildDirectionLabel(mAnimName,value - 10) == mCurrentDirectionLabel))
         {
            _loc7_ = mCurrentDirectionLabel;
         }
         if(_loc7_ == mCurrentDirectionLabel)
         {
            updateFlipForHeading(value);
            return;
         }
         var _loc10_:int = mMultiDirectionAnimation.getFrame(_loc7_);
         if(_loc10_ < 0)
         {
            for each(var _loc9_:String in mDirectionLabels)
            {
               _loc11_ = mAnimName + _loc9_;
               if(_loc11_ != _loc7_)
               {
                  _loc10_ = mMultiDirectionAnimation.getFrame(_loc11_);
                  if(_loc10_ >= 0)
                  {
                     _loc7_ = _loc11_;
                     break;
                  }
               }
            }
         }
         if(_loc10_ < 0)
         {
            return;
         }
         if(_loc7_ == mCurrentDirectionLabel)
         {
            updateFlipForHeading(value);
            return;
         }
         var _loc6_:Point = getRangeForLabel(_loc7_,_loc10_);
         if(_loc6_.x < 0)
         {
            return;
         }
         var _loc3_:int = 0;
         if(mCurrentDirectionLabel != null)
         {
            _loc5_ = mMultiDirectionAnimation.getFrame(mCurrentDirectionLabel);
            if(_loc5_ >= 0)
            {
               _loc12_ = getRangeForLabel(mCurrentDirectionLabel,_loc5_);
               _loc3_ = mMultiDirectionAnimation.currentFrame - _loc12_.x;
               if(_loc3_ < 0)
               {
                  _loc3_ = 0;
               }
               _loc2_ = _loc12_.y - _loc12_.x;
               if(_loc3_ > _loc2_)
               {
                  _loc3_ = _loc2_;
               }
               if(!mLoop && !mMultiDirectionAnimation.isPlaying && mMultiDirectionAnimation.currentFrame >= _loc12_.y)
               {
                  _loc3_ = _loc6_.y - _loc6_.x;
               }
            }
         }
         var _loc4_:int = _loc6_.x + _loc3_;
         if(_loc4_ < _loc6_.x)
         {
            _loc4_ = _loc6_.x;
         }
         if(_loc4_ > _loc6_.y)
         {
            _loc4_ = _loc6_.y;
         }
         if(mMultiDirectionAnimation.isPlaying)
         {
            _loc8_ = mMultiDirectionAnimation.gotoLabel(_loc7_,mLoop,_loc4_);
            if(_loc8_.x >= 0)
            {
               mCurrentDirectionLabel = _loc7_;
               updateFlipForHeading(value);
               joinJuggler();
            }
         }
         else
         {
            mMultiDirectionAnimation.clearLabel();
            mMultiDirectionAnimation.currentFrame = _loc4_;
            mMultiDirectionAnimation.pause();
            mCurrentDirectionLabel = _loc7_;
            updateFlipForHeading(value);
         }
      }
      
      public function get currentFrame() : int
      {
         var _loc1_:int = 0;
         if(mCurrentAnimation == null)
         {
            return 0;
         }
         if(mMultiDirectionMode && mCurrentDirectionLabel != null)
         {
            _loc1_ = mMultiDirectionAnimation.getKeyframeIndex(mCurrentDirectionLabel,mMultiDirectionAnimation.currentFrame);
            if(_loc1_ >= 0)
            {
               return _loc1_;
            }
         }
         return mCurrentAnimation.currentFrame;
      }
      
      public function get loop() : Boolean
      {
         return mLoop;
      }
      
      public function set loop(value:Boolean) : void
      {
         var _loc3_:Point = null;
         if(mLoop == value || mCurrentAnimation == null)
         {
            mLoop = value;
            return;
         }
         mLoop = value;
         if(mMultiDirectionMode)
         {
            if(mCurrentDirectionLabel != null)
            {
               _loc3_ = mMultiDirectionAnimation.gotoLabel(mCurrentDirectionLabel,value);
               if(_loc3_.x >= 0)
               {
                  if(value)
                  {
                     mMultiDirectionAnimation.removeEventListener("complete",onAnimationComplete);
                  }
                  else
                  {
                     mMultiDirectionAnimation.addEventListener("complete",onAnimationComplete);
                  }
                  joinJuggler();
               }
            }
            return;
         }
         var _loc2_:Boolean = value && !mCurrentAnimation.hasFrameLabel("noloop");
         var _loc4_:Boolean = _loc2_ && mCurrentAnimation.isFinished;
         mCurrentAnimation.loop = _loc2_;
         if(_loc2_)
         {
            mCurrentAnimation.clearMovieClipsPlayOnce();
            mCurrentAnimation.removeEventListener("complete",onAnimationComplete);
         }
         else
         {
            mCurrentAnimation.setMovieClipsPlayOnce();
            mCurrentAnimation.addEventListener("complete",onAnimationComplete);
         }
         if(_loc4_)
         {
            mCurrentAnimation.play();
         }
         joinJuggler();
      }
      
      public function get isPlaying() : Boolean
      {
         return mCurrentAnimation != null && mCurrentAnimation.isPlaying;
      }
      
      public function get playRate() : Number
      {
         return mPlayRate;
      }
      
      public function set playRate(value:Number) : void
      {
         mPlayRate = value > 0 ? value : 1;
         if(mCurrentAnimation == null)
         {
            return;
         }
         var _loc2_:Number = mMultiDirectionMode ? mMultiDirectionBaseFrameRate : Number(mBaseFrameRates.itemFor(mAnimName));
         if(_loc2_ > 0)
         {
            mCurrentAnimation.frameRate = _loc2_ * mPlayRate;
         }
      }
      
      public function set startingFrame(value:int) : void
      {
         mStartingFrame = value;
         if(mCurrentAnimation != null)
         {
            mCurrentAnimation.currentFrame = clampFrame(value,mCurrentAnimation);
         }
      }
      
      public function get visible() : Boolean
      {
         return mVisible;
      }
      
      public function set visible(value:Boolean) : void
      {
         if(mVisible == value)
         {
            return;
         }
         mVisible = value;
         mContainer.visible = value && !mCulled;
         if(value)
         {
            joinJuggler();
         }
         else
         {
            leaveJuggler();
         }
      }
      
      public function setVisibility(visible:Boolean, culled:Boolean) : void
      {
         if(mCulled != culled)
         {
            mCulled = culled;
            if(mVisible == visible)
            {
               joinJuggler();
            }
         }
         this.visible = visible;
         mContainer.visible = mVisible && !mCulled;
      }
      
      public function getContentRadius() : Number
      {
         if(mContent == null)
         {
            return 0;
         }
         var _loc3_:Rectangle = mContent.getBounds(mContent);
         var _loc1_:Number = Math.max(Math.abs(_loc3_.left),Math.abs(_loc3_.right)) * Math.abs(mContentScaleX);
         var _loc2_:Number = Math.max(Math.abs(_loc3_.top),Math.abs(_loc3_.bottom)) * Math.abs(mContentScaleY);
         return Math.sqrt(_loc1_ * _loc1_ + _loc2_ * _loc2_);
      }
      
      public function get canvasReach() : Number
      {
         var _loc4_:Number = NaN;
         var _loc1_:Number = NaN;
         var _loc2_:Array = null;
         var _loc3_:IMapIterator = null;
         if(isNaN(mCanvasReach))
         {
            _loc4_ = 0;
            _loc1_ = 0;
            _loc2_ = [mMultiDirectionAnimation];
            _loc3_ = mAnimations.iterator() as IMapIterator;
            while(_loc3_.hasNext())
            {
               _loc2_.push(_loc3_.next());
            }
            for each(var _loc5_:Animation in _loc2_)
            {
               if(_loc5_ != null)
               {
                  if(_loc5_.sourceWidth > _loc4_)
                  {
                     _loc4_ = _loc5_.sourceWidth;
                  }
                  if(_loc5_.sourceHeight > _loc1_)
                  {
                     _loc1_ = _loc5_.sourceHeight;
                  }
               }
            }
            mCanvasReach = Math.max(_loc4_ * Math.abs(mContentScaleX),_loc1_ * Math.abs(mContentScaleY));
         }
         return mCanvasReach;
      }
      
      public function setLayer(layerIndex:int) : void
      {
         if(mContainer == null || mDBFacade == null)
         {
            return;
         }
         if(mLayerIndex == layerIndex && (layerIndex == 0 || mContainer.parent != null))
         {
            return;
         }
         if(mContainer.parent != null)
         {
            mContainer.removeFromParent();
         }
         if(layerIndex == 0)
         {
            mLayerIndex = 0;
            return;
         }
         mLayerIndex = layerIndex;
         var _loc2_:StarlingLayer = mDBFacade.starlingLayerManager.getLayer(mLayerIndex);
         if(_loc2_ == null)
         {
            Logger.warn("StarlingActorRenderer: no Starling layer for index " + mLayerIndex + ", falling back to SORTED");
            mLayerIndex = 20;
            _loc2_ = mDBFacade.starlingLayerManager.getLayer(mLayerIndex);
         }
         if(_loc2_ != null)
         {
            _loc2_.addChild(mContainer);
            mDBFacade.starlingLayerManager.markLayerDirty(mLayerIndex);
         }
      }
      
      public function setTransform(x:Number, y:Number, rotationRadians:Number, scaleX:Number, scaleY:Number, alpha:Number = 1, sortX:Number = NaN, sortY:Number = NaN) : void
      {
         if(isNaN(sortX))
         {
            sortX = x;
         }
         if(isNaN(sortY))
         {
            sortY = y;
         }
         sortY += mDrawOrderOffsetY;
         mContainer.x = sortX;
         mContainer.y = sortY;
         mContainer.alpha = alpha;
         var _loc9_:Number = x - sortX;
         var _loc12_:Number = y - sortY;
         var _loc10_:Number = scaleX * mContentScaleX * mFlipX;
         var _loc11_:Number = scaleY * mContentScaleY;
         mContent.x = _loc9_;
         mContent.y = _loc12_;
         mContent.rotation = rotationRadians;
         mContent.scaleX = _loc10_;
         mContent.scaleY = _loc11_;
         mTransformStale = _loc9_ != _loc9_ || _loc12_ != _loc12_ || _loc10_ != _loc10_ || _loc11_ != _loc11_ || !isFinite(rotationRadians);
         markLayerDirty();
      }
      
      public function get transformStale() : Boolean
      {
         return mTransformStale;
      }
      
      public function markLayerDirty() : void
      {
         mDBFacade.starlingLayerManager.markLayerDirty(mLayerIndex);
      }
      
      public function setContentScale(contentScaleX:Number, contentScaleY:Number) : void
      {
         if(mContentScaleX != contentScaleX || mContentScaleY != contentScaleY)
         {
            mTransformStale = true;
         }
         mContentScaleX = contentScaleX;
         mContentScaleY = contentScaleY;
         mCanvasReach = NaN;
      }
      
      public function get drawOrderOffsetY() : Number
      {
         return mDrawOrderOffsetY;
      }
      
      public function set drawOrderOffsetY(value:Number) : void
      {
         if(mDrawOrderOffsetY != value)
         {
            mTransformStale = true;
         }
         mDrawOrderOffsetY = value;
      }
      
      private function playMultiDirection(animName:String, startingFrame:int, loop:Boolean, playRate:Number) : Boolean
      {
         var _loc7_:String = null;
         if(mMultiDirectionAnimation == null)
         {
            return false;
         }
         var _loc6_:String = resolveMultiDirectionLabel(animName,mHeading);
         if(_loc6_ == null && animName == "run")
         {
            _loc6_ = resolveMultiDirectionLabel("idle",mHeading);
            if(_loc6_ != null)
            {
               animName = "idle";
            }
         }
         if(_loc6_ == null)
         {
            _loc7_ = mContainer.name + "/" + animName;
            if(!sWarnedMissingLabels[_loc7_])
            {
               sWarnedMissingLabels[_loc7_] = true;
               Logger.warnch("Starling","Multi-direction animation for " + mContainer.name + " has no usable label for: " + animName);
            }
            return false;
         }
         showOffImage(false);
         showFrameImage(false);
         if(mCurrentAnimation != null)
         {
            mCurrentAnimation.removeEventListener("complete",onAnimationComplete);
         }
         if(mCurrentAnimation != mMultiDirectionAnimation)
         {
            deactivateCurrent();
            mCurrentAnimation = mMultiDirectionAnimation;
            mContent.addChild(mCurrentAnimation);
         }
         mAnimName = animName;
         mLoop = loop;
         if(!mLoop)
         {
            mMultiDirectionAnimation.addEventListener("complete",onAnimationComplete);
         }
         var _loc5_:Point = mMultiDirectionAnimation.gotoLabel(_loc6_,mLoop);
         if(_loc5_.x < 0)
         {
            Logger.warnch("Starling","Multi-direction animation for " + mContainer.name + " failed to seek label: " + _loc6_);
            mMultiDirectionAnimation.removeEventListener("complete",onAnimationComplete);
            return false;
         }
         mCurrentDirectionLabel = _loc6_;
         updateFlipForHeading(mHeading);
         if(startingFrame > 0)
         {
            mMultiDirectionAnimation.currentFrame = mMultiDirectionAnimation.getKeyframe(_loc6_,startingFrame);
         }
         this.playRate = playRate;
         if(!mLoop && mMultiDirectionAnimation.hasFrameLabel("noloop"))
         {
            mMultiDirectionAnimation.loop = false;
         }
         joinJuggler();
         return true;
      }
      
      private function resolveMultiDirectionLabel(animName:String, heading:Number) : String
      {
         var _loc5_:String = null;
         var _loc3_:String = buildDirectionLabel(animName,heading);
         if(mMultiDirectionAnimation.getFrame(_loc3_) >= 0)
         {
            return _loc3_;
         }
         for each(var _loc4_:String in mDirectionLabels)
         {
            _loc5_ = animName + _loc4_;
            if(_loc5_ != _loc3_)
            {
               if(mMultiDirectionAnimation.getFrame(_loc5_) >= 0)
               {
                  return _loc5_;
               }
            }
         }
         return null;
      }
      
      private function setFrameMultiDirection(animName:String, frameNumber:int) : void
      {
         var _loc6_:String = null;
         if(mMultiDirectionAnimation == null)
         {
            return;
         }
         var _loc4_:String = buildDirectionLabel(animName,mHeading);
         var _loc3_:int = mMultiDirectionAnimation.getFrame(_loc4_);
         if(_loc3_ < 0)
         {
            for each(var _loc5_:String in mDirectionLabels)
            {
               _loc6_ = animName + _loc5_;
               if(_loc6_ != _loc4_)
               {
                  _loc3_ = mMultiDirectionAnimation.getFrame(_loc6_);
                  if(_loc3_ >= 0)
                  {
                     _loc4_ = _loc6_;
                     break;
                  }
               }
            }
         }
         if(_loc3_ < 0)
         {
            stop();
            return;
         }
         if(mCurrentAnimation != mMultiDirectionAnimation)
         {
            deactivateCurrent();
            mCurrentAnimation = mMultiDirectionAnimation;
            mContent.addChild(mCurrentAnimation);
         }
         mAnimName = animName;
         mCurrentDirectionLabel = _loc4_;
         updateFlipForHeading(mHeading);
         mMultiDirectionAnimation.gotoFrame(mMultiDirectionAnimation.getKeyframe(_loc4_,frameNumber));
         mMultiDirectionAnimation.pause();
         leaveJuggler();
         showOffImage(true);
         showFrameImage(true);
      }
      
      private function buildDirectionLabel(animName:String, heading:Number) : String
      {
         var _loc3_:String = directionSuffix(heading);
         if(_loc3_ != mBuiltLabelSuffix || animName != mBuiltLabelAnim)
         {
            mBuiltLabelAnim = animName;
            mBuiltLabelSuffix = _loc3_;
            mBuiltLabel = animName + _loc3_;
         }
         return mBuiltLabel;
      }
      
      private function directionSuffix(heading:Number) : String
      {
         var _loc2_:String = null;
         while(heading > 180)
         {
            heading -= 360;
         }
         while(heading <= -180)
         {
            heading += 360;
         }
         if(mDirectionLabels.length >= 5)
         {
            if(heading > 90)
            {
               heading = 180 - heading;
            }
            else if(heading < -90)
            {
               heading = -heading - 180;
            }
            if(heading >= 60 && heading <= 120)
            {
               _loc2_ = "_angE";
            }
            else if(heading >= 30 && heading < 60)
            {
               _loc2_ = "_angD";
            }
            else if(heading >= -30 && heading < 30)
            {
               _loc2_ = "_angC";
            }
            else if(heading >= -60 && heading < -30)
            {
               _loc2_ = "_angB";
            }
            else
            {
               _loc2_ = "_angA";
            }
         }
         else
         {
            if(heading > 90)
            {
               heading = 180 - heading;
            }
            else if(heading < -90)
            {
               heading = -heading - 180;
            }
            if(heading >= 60 && heading <= 90)
            {
               _loc2_ = "_angE";
            }
            else if(heading >= 0 && heading < 60)
            {
               _loc2_ = "_angD";
            }
            else if(heading >= -90 && heading < 0)
            {
               _loc2_ = "_angB";
            }
            else
            {
               _loc2_ = "_angE";
            }
         }
         return _loc2_;
      }
      
      private function updateFlipForHeading(heading:Number) : void
      {
         var _loc3_:Number = mFlipX;
         var _loc2_:Number = Math.abs(heading);
         if(mDirectionLabels.length >= 5)
         {
            mFlipX = _loc2_ >= 90 ? -1 : 1;
         }
         else
         {
            mFlipX = _loc2_ >= 90 ? -1 : 1;
         }
         if(mFlipX != _loc3_)
         {
            mTransformStale = true;
         }
      }
      
      private function hasMultiDirectionAnim(animName:String) : Boolean
      {
         if(mMultiDirectionAnimation == null)
         {
            return false;
         }
         var _loc3_:* = mHasMultiDirectionAnimCache[animName];
         if(_loc3_ is Boolean)
         {
            return _loc3_;
         }
         var _loc2_:Boolean = false;
         for each(var _loc4_:String in mDirectionLabels)
         {
            if(mMultiDirectionAnimation.getFrame(animName + _loc4_) >= 0)
            {
               _loc2_ = true;
               break;
            }
         }
         mHasMultiDirectionAnimCache[animName] = _loc2_;
         return _loc2_;
      }
      
      private function getMultiDirectionSegmentDuration(animName:String) : Number
      {
         var _loc2_:Point = getMultiDirectionSegmentRange(animName);
         if(_loc2_.x < 0 || mMultiDirectionAnimation == null || mMultiDirectionAnimation.frameRate <= 0)
         {
            return 0;
         }
         return (_loc2_.y - _loc2_.x + 1) / mMultiDirectionAnimation.frameRate;
      }
      
      private function getMultiDirectionSegmentFrames(animName:String) : Number
      {
         var _loc2_:Point = getMultiDirectionSegmentRange(animName);
         if(_loc2_.x < 0)
         {
            return 0;
         }
         return _loc2_.y - _loc2_.x + 1;
      }
      
      private function getMultiDirectionSegmentRange(animName:String) : Point
      {
         var _loc5_:String = null;
         if(mMultiDirectionAnimation == null)
         {
            return new Point(-1,-1);
         }
         var _loc3_:String = buildDirectionLabel(animName,mHeading);
         var _loc2_:int = mMultiDirectionAnimation.getFrame(_loc3_);
         if(_loc2_ >= 0)
         {
            return getRangeForLabel(_loc3_,_loc2_);
         }
         for each(var _loc4_:String in mDirectionLabels)
         {
            _loc5_ = animName + _loc4_;
            if(_loc5_ != _loc3_)
            {
               _loc2_ = mMultiDirectionAnimation.getFrame(_loc5_);
               if(_loc2_ >= 0)
               {
                  return getRangeForLabel(_loc5_,_loc2_);
               }
            }
         }
         return new Point(-1,-1);
      }
      
      private function getRangeForLabel(label:String, start:int) : Point
      {
         var _loc3_:String = mMultiDirectionAnimation.getNextLabel(label);
         var _loc5_:int = int(_loc3_ != null ? mMultiDirectionAnimation.getFrame(_loc3_) : -1);
         var _loc4_:int = (_loc5_ > start ? _loc5_ : mMultiDirectionAnimation.numFrames) - 1;
         return new Point(start,_loc4_);
      }
      
      public function setFrameImage(texture:Texture) : void
      {
         if(mFrameImage != null)
         {
            mFrameImage.removeFromParent();
            mFrameImage = null;
         }
         if(texture == null)
         {
            return;
         }
         mFrameImage = new Image(texture);
         mFrameImage.touchable = false;
         mFrameImage.pixelSnapping = false;
         if(texture.frame != null)
         {
            mFrameImage.pivotX = -texture.frame.x + texture.width * 0.5;
            mFrameImage.pivotY = -texture.frame.y + texture.height;
         }
         mContent.addChild(mFrameImage);
         ColorTransformStyle.setColorTransform(mFrameImage,currentColorMatrix());
      }
      
      public function setOffImage(texture:Texture) : void
      {
         if(mOffImage != null)
         {
            mOffImage.removeFromParent();
            mOffImage = null;
         }
         if(texture == null)
         {
            return;
         }
         mOffImage = new Image(texture);
         mOffImage.touchable = false;
         mOffImage.pixelSnapping = false;
         if(texture.frame != null)
         {
            mOffImage.pivotX = -texture.frame.x + texture.width * 0.5;
            mOffImage.pivotY = -texture.frame.y + texture.height;
         }
         else
         {
            mOffImage.pivotX = texture.width * 0.5;
            mOffImage.pivotY = texture.height;
         }
         mContent.addChild(mOffImage);
         ColorTransformStyle.setColorTransform(mOffImage,currentColorMatrix());
      }
      
      public function setStaticEnsemble(parts:Array, libraryKey:String = null) : int
      {
         var _loc8_:String = null;
         var _loc5_:Texture = null;
         var _loc3_:Image = null;
         var _loc10_:Array = null;
         if(mStaticEnsemble != null)
         {
            mStaticEnsemble.removeFromParent(true);
            mStaticEnsemble = null;
         }
         if(parts == null || parts.length == 0)
         {
            return 0;
         }
         var _loc7_:Sprite = new Sprite();
         _loc7_.touchable = false;
         var _loc9_:Matrix = new Matrix();
         var _loc4_:int = 0;
         for each(var _loc6_:Object in parts)
         {
            _loc8_ = _loc6_.tex as String;
            _loc5_ = mDBFacade.assetLoadingComponent.getTextureFromAssetManager(_loc8_,libraryKey);
            if(_loc5_ == null)
            {
               Logger.warnch("Starling","StarlingActorRenderer.setStaticEnsemble: no atlas entry \'" + _loc8_ + "\'; part skipped");
            }
            else
            {
               _loc3_ = new Image(_loc5_);
               _loc3_.touchable = false;
               _loc3_.pixelSnapping = false;
               _loc10_ = _loc6_.m as Array;
               if(_loc10_ != null && _loc10_.length == 6)
               {
                  _loc9_.setTo(_loc10_[0],_loc10_[1],_loc10_[2],_loc10_[3],_loc10_[4],_loc10_[5]);
                  _loc3_.transformationMatrix = _loc9_;
               }
               if(_loc6_.a != undefined)
               {
                  _loc3_.alpha = Number(_loc6_.a);
               }
               _loc7_.addChild(_loc3_);
               _loc4_++;
            }
         }
         if(_loc4_ == 0)
         {
            _loc7_.dispose();
            return 0;
         }
         mStaticEnsemble = _loc7_;
         mContent.addChildAt(mStaticEnsemble,0);
         ColorTransformStyle.applyTo(mStaticEnsemble,currentColorMatrix());
         return _loc4_;
      }
      
      public function showOffImage(value:Boolean) : void
      {
         if(mOffImage != null)
         {
            mOffImage.visible = value;
         }
         if(mStaticEnsemble != null)
         {
            mStaticEnsemble.visible = value;
         }
      }
      
      private function showFrameImage(value:Boolean) : void
      {
         if(mFrameImage != null)
         {
            mFrameImage.visible = value;
         }
      }
      
      public function alignStaticImagesToAnimation(reference:Animation) : void
      {
         if(reference == null)
         {
            return;
         }
         reference.currentFrame = 0;
         if(mFrameImage != null)
         {
            alignStaticImageToAnimationPart(mFrameImage,"frame",reference);
         }
         if(mOffImage != null)
         {
            alignStaticImageToAnimationPart(mOffImage,"static",reference);
         }
      }
      
      private function alignStaticImageToAnimationPart(image:Image, role:String, reference:Animation) : void
      {
         var _loc4_:Number = image.texture.frameWidth;
         var _loc7_:Number = image.texture.frameHeight;
         var _loc5_:DisplayObject = findAnimationPartByCanvasSize(reference,_loc4_,_loc7_);
         if(_loc5_ == null)
         {
            Logger.debugch("Starling","StarlingActorRenderer.alignStaticImagesToAnimation: \'" + mHolderName + "\' " + role + " image (" + _loc4_ + "x" + _loc7_ + ") matches no part on the animation\'s first frame (parts: " + collectAnimationPartSizes(reference) + "); keeping its default pivot");
            return;
         }
         var _loc14_:Rectangle = _loc5_.getBounds(reference);
         image.pivotX = 0;
         image.pivotY = 0;
         var _loc8_:Rectangle = getPartTextureFrame(_loc5_);
         var _loc6_:Rectangle = image.texture.frame;
         var _loc12_:Number = _loc8_ ? _loc8_.x : 0;
         var _loc9_:Number = _loc8_ ? _loc8_.y : 0;
         var _loc10_:Number = _loc6_ ? _loc6_.x : 0;
         var _loc13_:Number = _loc6_ ? _loc6_.y : 0;
         var _loc11_:Number = (_loc14_.width - _loc4_) * 0.5;
         var _loc15_:Number = (_loc14_.height - _loc7_) * 0.5;
         if(_loc8_ == null)
         {
            image.x = _loc14_.x + _loc11_;
            image.y = _loc14_.y + _loc15_;
         }
         else
         {
            image.x = _loc14_.x + _loc11_ - _loc12_ + _loc10_;
            image.y = _loc14_.y + _loc15_ - _loc9_ + _loc13_;
         }
      }
      
      private function getPartTextureFrame(part:DisplayObject) : Rectangle
      {
         var _loc2_:DisplayObjectContainer = null;
         var _loc3_:int = 0;
         var _loc4_:DisplayObject = null;
         var _loc5_:Rectangle = null;
         if(part is Image)
         {
            return Image(part).texture.frame;
         }
         if(part is DisplayObjectContainer)
         {
            _loc2_ = part as DisplayObjectContainer;
            _loc3_ = 0;
            while(_loc3_ < _loc2_.numChildren)
            {
               _loc4_ = _loc2_.getChildAt(_loc3_);
               if(_loc4_ is Image)
               {
                  return Image(_loc4_).texture.frame;
               }
               _loc5_ = getPartTextureFrame(_loc4_);
               if(_loc5_ != null)
               {
                  return _loc5_;
               }
               _loc3_++;
            }
         }
         return null;
      }
      
      private function findAnimationPartByCanvasSize(root:DisplayObjectContainer, canvasWidth:Number, canvasHeight:Number) : DisplayObject
      {
         var _loc5_:DisplayObject = null;
         var _loc4_:DisplayObjectContainer = null;
         var _loc7_:int = 0;
         var _loc6_:DisplayObject = null;
         var _loc8_:Array = [root];
         while(_loc8_.length > 0)
         {
            _loc5_ = _loc8_.shift() as DisplayObject;
            if(_loc5_ != root && boundsMatchCanvasSize(_loc5_,root,canvasWidth,canvasHeight))
            {
               _loc6_ = _loc5_;
            }
            _loc4_ = _loc5_ as DisplayObjectContainer;
            if(_loc4_ != null)
            {
               _loc7_ = 0;
               while(_loc7_ < _loc4_.numChildren)
               {
                  _loc8_.push(_loc4_.getChildAt(_loc7_));
                  _loc7_++;
               }
            }
         }
         return _loc6_;
      }
      
      private function boundsMatchCanvasSize(node:DisplayObject, space:DisplayObject, canvasWidth:Number, canvasHeight:Number) : Boolean
      {
         var _loc7_:Rectangle = node.getBounds(space);
         var _loc5_:Number = _loc7_.width - canvasWidth;
         var _loc6_:Number = _loc7_.height - canvasHeight;
         return _loc5_ >= -0.5 && _loc5_ <= 2.5 && _loc6_ >= -0.5 && _loc6_ <= 2.5;
      }
      
      private function collectAnimationPartSizes(root:DisplayObjectContainer) : String
      {
         var _loc3_:DisplayObject = null;
         var _loc2_:DisplayObjectContainer = null;
         var _loc5_:Rectangle = null;
         var _loc6_:int = 0;
         var _loc4_:Array = [];
         var _loc7_:Array = [root];
         while(_loc7_.length > 0)
         {
            _loc3_ = _loc7_.shift() as DisplayObject;
            _loc2_ = _loc3_ as DisplayObjectContainer;
            if(_loc2_ == null)
            {
               _loc5_ = _loc3_.getBounds(root);
               _loc4_.push(int(_loc5_.width) + "x" + int(_loc5_.height));
            }
            else
            {
               _loc6_ = 0;
               while(_loc6_ < _loc2_.numChildren)
               {
                  _loc7_.push(_loc2_.getChildAt(_loc6_));
                  _loc6_++;
               }
            }
         }
         return _loc4_.join(", ");
      }
      
      public function setHighlightFilter(color:uint, alpha:Number = 8, blur:Number = 2, quality:Number = 1) : void
      {
         if(mContainer == null)
         {
            return;
         }
         if(mHighlightFilter == null)
         {
            mHighlightFilter = new GlowFilter(color,alpha,blur,quality);
         }
         else
         {
            mHighlightFilter.color = color;
            mHighlightFilter.alpha = alpha;
            mHighlightFilter.blur = blur;
            mHighlightFilter.quality = quality;
         }
         updateFilters();
      }
      
      public function clearHighlightFilter() : void
      {
         var _loc1_:GlowFilter = null;
         if(mHighlightFilter != null)
         {
            _loc1_ = mHighlightFilter;
            mHighlightFilter = null;
            updateFilters();
            _loc1_.dispose();
         }
         else
         {
            updateFilters();
         }
      }
      
      public function setPersistentGlowFilter(color:uint, alpha:Number = 8, blur:Number = 2, quality:Number = 1) : void
      {
         if(mContainer == null)
         {
            return;
         }
         if(mPersistentGlowFilter == null)
         {
            mPersistentGlowFilter = new GlowFilter(color,alpha,blur,quality);
         }
         else
         {
            mPersistentGlowFilter.color = color;
            mPersistentGlowFilter.alpha = alpha;
            mPersistentGlowFilter.blur = blur;
            mPersistentGlowFilter.quality = quality;
         }
         updateFilters();
      }
      
      public function clearPersistentGlowFilter() : void
      {
         var _loc1_:GlowFilter = null;
         if(mPersistentGlowFilter != null)
         {
            _loc1_ = mPersistentGlowFilter;
            mPersistentGlowFilter = null;
            updateFilters();
            _loc1_.dispose();
         }
         else
         {
            updateFilters();
         }
      }
      
      public function setColorFilter(matrix:Array) : void
      {
         var _loc2_:int = 0;
         if(mContainer == null || matrix == null || matrix.length != 20)
         {
            return;
         }
         if(mColorMatrix == null)
         {
            mColorMatrix = new Vector.<Number>(20,true);
         }
         _loc2_ = 0;
         while(_loc2_ < 20)
         {
            mColorMatrix[_loc2_] = Number(matrix[_loc2_]);
            _loc2_++;
         }
         applyColorTransformToContent();
      }
      
      public function clearColorFilter() : void
      {
         if(mColorMatrix != null)
         {
            mColorMatrix = null;
            applyColorTransformToContent();
         }
      }
      
      public function setStatusTint(color:uint, amount:Number) : void
      {
         if(mContainer == null)
         {
            return;
         }
         mStatusTint.set(color,amount);
         applyColorTransformToContent();
      }
      
      public function clearStatusTint() : void
      {
         mStatusTint.clear();
         applyColorTransformToContent();
      }
      
      private function currentColorMatrix() : Vector.<Number>
      {
         var _loc1_:Vector.<Number> = mStatusTint.matrix;
         if(mColorMatrix == null)
         {
            return _loc1_;
         }
         if(_loc1_ == null)
         {
            return mColorMatrix;
         }
         return ColorTransformStyle.concat(mColorMatrix,_loc1_);
      }
      
      private function applyColorTransformToContent() : void
      {
         if(mContainer == null)
         {
            return;
         }
         var _loc2_:Vector.<Number> = currentColorMatrix();
         var _loc1_:IMapIterator = mAnimations.iterator() as IMapIterator;
         while(_loc1_.hasNext())
         {
            (_loc1_.next() as Animation).setColorMatrix(_loc2_);
         }
         if(mMultiDirectionAnimation != null)
         {
            mMultiDirectionAnimation.setColorMatrix(_loc2_);
         }
         if(mOffImage != null)
         {
            ColorTransformStyle.setColorTransform(mOffImage,_loc2_);
         }
         if(mFrameImage != null)
         {
            ColorTransformStyle.setColorTransform(mFrameImage,_loc2_);
         }
         if(mStaticEnsemble != null)
         {
            ColorTransformStyle.applyTo(mStaticEnsemble,_loc2_);
         }
      }
      
      private function updateFilters() : void
      {
         if(mContainer == null)
         {
            return;
         }
         var _loc2_:Array = [];
         if(mPersistentGlowFilter != null)
         {
            _loc2_.push(mPersistentGlowFilter);
         }
         if(mHighlightFilter != null)
         {
            _loc2_.push(mHighlightFilter);
         }
         if(mFilterChain != null)
         {
            while(mFilterChain.numFilters > 0)
            {
               mFilterChain.removeFilterAt(0,false);
            }
         }
         if(_loc2_.length == 0)
         {
            mContainer.filter = null;
         }
         else if(_loc2_.length == 1)
         {
            mContainer.filter = _loc2_[0];
         }
         else
         {
            if(mFilterChain == null)
            {
               mFilterChain = new FilterChain();
            }
            for each(var _loc1_:FragmentFilter in _loc2_)
            {
               mFilterChain.addFilter(_loc1_);
            }
            mContainer.filter = mFilterChain;
         }
      }
      
      public function destroy() : void
      {
         var _loc2_:Animation = null;
         leaveJuggler();
         mCurrentAnimation = null;
         var _loc1_:IMapIterator = mAnimations.iterator() as IMapIterator;
         while(_loc1_.hasNext())
         {
            _loc2_ = _loc1_.next() as Animation;
            _loc2_.stop();
            _loc2_.removeFromParent(true);
         }
         mAnimations.clear();
         mAnimations = null;
         mBaseFrameRates.clear();
         mBaseFrameRates = null;
         if(mOffImage != null)
         {
            mOffImage.removeFromParent();
            mOffImage = null;
         }
         if(mFrameImage != null)
         {
            mFrameImage.removeFromParent();
            mFrameImage = null;
         }
         if(mStaticEnsemble != null)
         {
            mStaticEnsemble.removeFromParent(true);
            mStaticEnsemble = null;
         }
         mContainer.filter = null;
         if(mFilterChain != null)
         {
            while(mFilterChain.numFilters > 0)
            {
               mFilterChain.removeFilterAt(0,false);
            }
            mFilterChain.dispose();
            mFilterChain = null;
         }
         mColorMatrix = null;
         mStatusTint.dispose();
         if(mHighlightFilter != null)
         {
            mHighlightFilter.dispose();
            mHighlightFilter = null;
         }
         if(mPersistentGlowFilter != null)
         {
            mPersistentGlowFilter.dispose();
            mPersistentGlowFilter = null;
         }
         mContainer.removeFromParent(true);
         mContainer = null;
         mContent = null;
         mDBFacade = null;
      }
      
      private function deactivateCurrent() : void
      {
         if(mCurrentAnimation == null)
         {
            return;
         }
         mCurrentAnimation.removeEventListener("complete",onAnimationComplete);
         leaveJuggler();
         mCurrentAnimation.stop();
         mContent.removeChild(mCurrentAnimation);
         mCurrentAnimation = null;
      }
      
      private function onAnimationComplete(event:Event) : void
      {
         var _loc2_:Animation = event.target as Animation;
         if(_loc2_ != null)
         {
            _loc2_.removeEventListener("complete",onAnimationComplete);
            if(_loc2_ == mCurrentAnimation)
            {
               leaveJuggler();
            }
         }
      }
      
      private function joinJuggler() : void
      {
         if(mCurrentAnimation == null || !mVisible || !mCurrentAnimation.isAnimating)
         {
            return;
         }
         if(mCulled && isLooping)
         {
            leaveJuggler();
            return;
         }
         if(!mDBFacade.starlingLayerManager.juggler.contains(mCurrentAnimation))
         {
            mDBFacade.starlingLayerManager.juggler.add(mCurrentAnimation);
         }
      }
      
      private function get isLooping() : Boolean
      {
         return mLoop && (mMultiDirectionMode || mCurrentAnimation.loop);
      }
      
      private function leaveJuggler() : void
      {
         if(mCurrentAnimation == null || mDBFacade == null)
         {
            return;
         }
         mDBFacade.starlingLayerManager.juggler.remove(mCurrentAnimation);
      }
   }
}

