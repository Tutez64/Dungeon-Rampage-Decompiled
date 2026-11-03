package Brain.Camera
{
   import Brain.Clock.GameClock;
   import Brain.Facade.Facade;
   import Brain.Render.Tweens.TweenHandle;
   import flash.display.DisplayObject;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   
   public class Camera
   {
      
      private static const sInverse:Matrix = new Matrix();
      
      private var mTargetObject:DisplayObject;
      
      private var mBounds:Rectangle;
      
      private var mMaxZoom:Number = 10;
      
      private var mMinZoom:Number = 0.01;
      
      private var mZoom:Number = 1;
      
      private var mRotation:Number = 0;
      
      private var mTransformDirty:Boolean = false;
      
      private var mRootPosition:Vector3D = new Vector3D();
      
      private var mPrevRootPosition:Vector3D = new Vector3D();
      
      private var mRootTransform:Matrix = new Matrix();
      
      private var mApplied:Matrix = new Matrix(0,0,0,0);
      
      private var mShakePosition:Vector3D = new Vector3D();
      
      private var mShakeRotation:Number = 0;
      
      private var mBackgroundFader:BackgroundFader;
      
      private var mLetterboxEffect:LetterboxEffect;
      
      private var mVisibleRect:Rectangle;
      
      private var mCullRect:Rectangle = new Rectangle();
      
      private var mHasCullRect:Boolean = false;
      
      private var mDefaultZoom:Number;
      
      private var mTweenZoom:TweenHandle;
      
      private var mTweenRotation:TweenHandle;
      
      private var mOffset:Point;
      
      private var mYClippingFromBottom:uint;
      
      private var mWantScrollRectCulling:Boolean = false;
      
      private var mFacade:Facade;
      
      public function Camera(facade:Facade, backgroundFader:BackgroundFader, letterboxEffect:LetterboxEffect)
      {
         super();
         mFacade = facade;
         mOffset = new Point();
         mBackgroundFader = backgroundFader;
         mLetterboxEffect = letterboxEffect;
      }
      
      public static function viewBoundsInWorld(cameraMatrix:Matrix, parentX:Number, parentY:Number, viewWidth:Number, viewHeight:Number, out:Rectangle) : void
      {
         var _loc14_:int = 0;
         var _loc9_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc7_:Number = NaN;
         var _loc8_:Number = NaN;
         sInverse.copyFrom(cameraMatrix);
         sInverse.invert();
         var _loc15_:Number = Infinity;
         var _loc13_:Number = Infinity;
         var _loc12_:Number = -Infinity;
         var _loc10_:Number = -Infinity;
         _loc14_ = 0;
         while(_loc14_ < 4)
         {
            _loc9_ = (_loc14_ & 1 ? viewWidth : 0) - parentX;
            _loc11_ = (_loc14_ & 2 ? viewHeight : 0) - parentY;
            _loc7_ = sInverse.a * _loc9_ + sInverse.c * _loc11_ + sInverse.tx;
            _loc8_ = sInverse.b * _loc9_ + sInverse.d * _loc11_ + sInverse.ty;
            if(_loc7_ < _loc15_)
            {
               _loc15_ = _loc7_;
            }
            if(_loc7_ > _loc12_)
            {
               _loc12_ = _loc7_;
            }
            if(_loc8_ < _loc13_)
            {
               _loc13_ = _loc8_;
            }
            if(_loc8_ > _loc10_)
            {
               _loc10_ = _loc8_;
            }
            _loc14_++;
         }
         out.setTo(_loc15_,_loc13_,_loc12_ - _loc15_,_loc10_ - _loc13_);
      }
      
      public function destroy() : void
      {
         if(mTweenZoom)
         {
            mFacade.mTween.killTween(mTweenZoom);
         }
         if(mTweenRotation)
         {
            mFacade.mTween.killTween(mTweenRotation);
         }
         if(mBackgroundFader)
         {
            mBackgroundFader.forceStop();
            mBackgroundFader = null;
         }
         if(mLetterboxEffect)
         {
            mLetterboxEffect.forceStop();
            mLetterboxEffect = null;
         }
         if(mVisibleRect)
         {
            mVisibleRect = null;
         }
         mTargetObject = null;
      }
      
      public function removeShakes() : void
      {
         mShakePosition.x = mShakePosition.y = 0;
         mTransformDirty = false;
      }
      
      public function set bounds(bounds:Rectangle) : void
      {
         mBounds = bounds;
      }
      
      public function get bounds() : Rectangle
      {
         return mBounds;
      }
      
      public function getDeltaToPoint(targetX:Number, targetY:Number) : Vector3D
      {
         if(mWantScrollRectCulling)
         {
            return new Vector3D((-targetX - mRootPosition.x) / mZoom,(-targetY - mRootPosition.y) / mZoom);
         }
         return new Vector3D(-targetX - mRootPosition.x,-targetY - mRootPosition.y);
      }
      
      public function centerCameraOnPoint(focusPoint:Vector3D) : void
      {
         var _loc2_:Vector3D = getDeltaToPoint(focusPoint.x,focusPoint.y);
         if(!_loc2_.equals(mRootPosition))
         {
            mRootPosition = _loc2_;
            mPrevRootPosition.x = mRootPosition.x;
            mPrevRootPosition.y = mRootPosition.y;
            mTransformDirty = true;
         }
      }
      
      public function update(gameClock:GameClock = null) : void
      {
         var _loc4_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc3_:Number = NaN;
         if(mTransformDirty && mTargetObject)
         {
            mRootTransform.identity();
            if(mWantScrollRectCulling)
            {
               mRootTransform.scale(mZoom,mZoom);
               mRootTransform.rotate((mRotation + _shakeRotation) * 3.141592653589793 / 180);
               mTargetObject.transform.matrix = mRootTransform;
               mTargetObject.x = -mFacade.viewWidth * 0.5;
               mTargetObject.y = -mFacade.viewHeight * 0.5;
               _loc4_ = Math.round(-mRootPosition.x - mFacade.viewWidth / mZoom * 0.5);
               _loc2_ = Math.round(-mRootPosition.y - mFacade.viewHeight / mZoom * 0.5 + mOffset.y / mZoom);
               _loc5_ = Math.round(mFacade.viewWidth / mZoom);
               _loc3_ = Math.round(mFacade.viewHeight / mZoom - mYClippingFromBottom / mZoom);
               mTargetObject.scrollRect = new Rectangle(_loc4_,_loc2_,_loc5_,_loc3_);
            }
            else
            {
               mRootTransform.translate(mRootPosition.x + mOffset.x + mShakePosition.x,mRootPosition.y + mOffset.y + mShakePosition.y);
               mRootTransform.scale(mZoom,mZoom);
               mRootTransform.rotate((mRotation + _shakeRotation) * 3.141592653589793 / 180);
               mTargetObject.transform.matrix = mRootTransform;
            }
            mTransformDirty = false;
            mApplied.setTo(0,0,0,0,0,0);
         }
      }
      
      public function beginTick() : void
      {
         mPrevRootPosition.x = mRootPosition.x;
         mPrevRootPosition.y = mRootPosition.y;
      }
      
      public function renderInterpolated(alpha:Number) : void
      {
         var _loc7_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc6_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc5_:Number = NaN;
         if(!mTargetObject)
         {
            return;
         }
         var _loc2_:Number = mPrevRootPosition.x + (mRootPosition.x - mPrevRootPosition.x) * alpha;
         var _loc3_:Number = mPrevRootPosition.y + (mRootPosition.y - mPrevRootPosition.y) * alpha;
         mRootTransform.identity();
         if(mWantScrollRectCulling)
         {
            mRootTransform.scale(mZoom,mZoom);
            mRootTransform.rotate((mRotation + _shakeRotation) * 3.141592653589793 / 180);
            mTargetObject.transform.matrix = mRootTransform;
            mTargetObject.x = -mFacade.viewWidth * 0.5;
            mTargetObject.y = -mFacade.viewHeight * 0.5;
            _loc7_ = Math.round(-_loc2_ - mFacade.viewWidth / mZoom * 0.5);
            _loc4_ = Math.round(-_loc3_ - mFacade.viewHeight / mZoom * 0.5 + mOffset.y / mZoom);
            _loc9_ = Math.round(mFacade.viewWidth / mZoom);
            _loc6_ = Math.round(mFacade.viewHeight / mZoom - mYClippingFromBottom / mZoom);
            mTargetObject.scrollRect = new Rectangle(_loc7_,_loc4_,_loc9_,_loc6_);
            mApplied.setTo(0,0,0,0,0,0);
         }
         else
         {
            mRootTransform.translate(_loc2_ + mOffset.x + mShakePosition.x,_loc3_ + mOffset.y + mShakePosition.y);
            mRootTransform.scale(mZoom,mZoom);
            mRootTransform.rotate((mRotation + _shakeRotation) * 3.141592653589793 / 180);
            if(!sameAsApplied())
            {
               mTargetObject.transform.matrix = mRootTransform;
               mApplied.copyFrom(mRootTransform);
            }
         }
         mTransformDirty = false;
         mHasCullRect = mWantScrollRectCulling || mTargetObject.parent != null;
         if(!mHasCullRect)
         {
            return;
         }
         if(mWantScrollRectCulling)
         {
            mCullRect.copyFrom(visibleRectangle);
            _loc8_ = Math.abs(Math.sin((mRotation + mShakeRotation) * 3.141592653589793 / 180));
            if(_loc8_ > 0)
            {
               _loc5_ = 0.5 * (mCullRect.width + mCullRect.height) * _loc8_;
               mCullRect.inflate(_loc5_,_loc5_);
            }
         }
         else
         {
            viewBoundsInWorld(mRootTransform,mTargetObject.parent.x,mTargetObject.parent.y,mFacade.viewWidth,mFacade.viewHeight,mCullRect);
         }
      }
      
      public function isInCullView(x:Number, y:Number, margin:Number) : Boolean
      {
         if(!mHasCullRect)
         {
            return true;
         }
         return x >= mCullRect.x - margin && x <= mCullRect.x + mCullRect.width + margin && y >= mCullRect.y - margin && y <= mCullRect.y + mCullRect.height + margin;
      }
      
      private function sameAsApplied() : Boolean
      {
         return mApplied.a == mRootTransform.a && mApplied.b == mRootTransform.b && mApplied.c == mRootTransform.c && mApplied.d == mRootTransform.d && mApplied.tx == mRootTransform.tx && mApplied.ty == mRootTransform.ty;
      }
      
      public function translateTo(point:Vector3D) : void
      {
         mRootPosition = point;
         mPrevRootPosition.x = mRootPosition.x;
         mPrevRootPosition.y = mRootPosition.y;
         mTransformDirty = true;
      }
      
      public function translateBy(dx:Number, dy:Number) : void
      {
         mRootPosition.x += dx;
         mRootPosition.y += dy;
         mTransformDirty = true;
      }
      
      public function set targetObject(target:DisplayObject) : void
      {
         mTargetObject = target;
         mHasCullRect = false;
         mApplied.setTo(0,0,0,0,0,0);
      }
      
      public function get targetObject() : DisplayObject
      {
         return mTargetObject;
      }
      
      public function set rotation(value:Number) : void
      {
         mRotation = value;
         mTransformDirty = true;
      }
      
      public function get rotation() : Number
      {
         return mRotation;
      }
      
      public function set _shakeRotation(value:Number) : void
      {
         mShakeRotation = value;
         mTransformDirty = true;
      }
      
      public function get _shakeRotation() : Number
      {
         return mShakeRotation;
      }
      
      public function set _shakeX(value:Number) : void
      {
         mShakePosition.x = value;
         mTransformDirty = true;
      }
      
      public function set _shakeY(value:Number) : void
      {
         mShakePosition.y = value;
         mTransformDirty = true;
      }
      
      public function get _shakeX() : Number
      {
         return mShakePosition.x;
      }
      
      public function get _shakeY() : Number
      {
         return mShakePosition.y;
      }
      
      public function tweenRotation(duration:Number, value:Number) : void
      {
         if(mTweenRotation)
         {
            mFacade.mTween.killTween(mTweenRotation);
         }
         if(mFacade.featureFlags.getFlagValue("want-zoom"))
         {
            mTweenRotation = mFacade.mTween.tweenLiteTo(this,duration,{"rotation":value});
         }
      }
      
      public function set zoom(value:Number) : void
      {
         if(mFacade.featureFlags.getFlagValue("want-zoom"))
         {
            value = Math.min(mMaxZoom,Math.max(mMinZoom,value));
            if(mZoom == value)
            {
               return;
            }
            mZoom = value;
            mTransformDirty = true;
         }
      }
      
      public function get zoom() : Number
      {
         return mZoom;
      }
      
      public function killTweenZooms() : void
      {
         if(mTweenZoom)
         {
            mFacade.mTween.killTween(mTweenZoom);
            mTweenZoom = null;
         }
      }
      
      private function shakeFunction(createTween:Function, duration:Number, strength:Number, numShakes:uint) : TweenHandle
      {
         var _loc6_:Number = NaN;
         var _loc8_:uint = 0;
         var _loc7_:TweenHandle = mFacade.mTween.createTimeline();
         var _loc5_:Number = duration / numShakes;
         _loc8_ = 0;
         while(_loc8_ < numShakes)
         {
            strength = -strength;
            _loc6_ = _loc8_ == 0 ? _loc5_ * 0.5 : _loc5_;
            mFacade.mTween.appendTween(_loc7_,createTween(_loc6_,strength));
            _loc8_++;
         }
         mFacade.mTween.appendTween(_loc7_,createTween(_loc5_ * 0.5,0));
         return _loc7_;
      }
      
      public function shakeRotation(duration:Number, strength:Number, numShakes:uint) : TweenHandle
      {
         var self:Camera = this;
         var createTween:Function = function(param1:Number, param2:Number):TweenHandle
         {
            return mFacade.mTween.tweenMaxTo(self,param1,{
               "_shakeRotation":param2,
               "onUpdate":update
            });
         };
         return this.shakeFunction(createTween,duration,strength,numShakes);
      }
      
      public function shakeX(duration:Number, strength:Number, numShakes:uint) : TweenHandle
      {
         var self:Camera = this;
         var createTween:Function = function(param1:Number, param2:Number):TweenHandle
         {
            return mFacade.mTween.tweenMaxTo(self,param1,{
               "_shakeX":param2,
               "onUpdate":update
            });
         };
         return this.shakeFunction(createTween,duration,strength,numShakes);
      }
      
      public function shakeY(duration:Number, strength:Number, numShakes:uint) : TweenHandle
      {
         var self:Camera = this;
         var createTween:Function = function(param1:Number, param2:Number):TweenHandle
         {
            return mFacade.mTween.tweenMaxTo(self,param1,{
               "_shakeY":param2,
               "onUpdate":update
            });
         };
         return this.shakeFunction(createTween,duration,strength,numShakes);
      }
      
      public function set defaultZoom(defaultZoom:Number) : void
      {
         mDefaultZoom = defaultZoom;
      }
      
      public function get defaultZoom() : Number
      {
         return mDefaultZoom;
      }
      
      public function tweenToDefaultZoom(duration:Number) : TweenHandle
      {
         return tweenZoom(duration,defaultZoom);
      }
      
      public function tweenZoom(duration:Number, value:Number, setAsDefault:Boolean = false) : TweenHandle
      {
         if(setAsDefault)
         {
            mDefaultZoom = value;
         }
         killTweenZooms();
         mTweenZoom = mFacade.mTween.tweenMaxTo(this,duration,{
            "zoom":value,
            "onUpdate":update
         });
         return mTweenZoom;
      }
      
      public function fadeBackground(excludes:Array, duration:uint, transitionDur:Number, color:Vector3D, alpha:Number) : void
      {
         mBackgroundFader.doFade(excludes,duration,transitionDur,color,alpha);
      }
      
      public function doLetterboxEffect(duration:uint, transitionDur:Number, color:Vector3D, alpha:Number) : void
      {
         mLetterboxEffect.doFade(duration,transitionDur,color,alpha);
      }
      
      public function get backgroundFadeAlpha() : Number
      {
         return mBackgroundFader ? mBackgroundFader.alpha : 0;
      }
      
      public function get backgroundFadeColor() : uint
      {
         return mBackgroundFader ? mBackgroundFader.color : 0;
      }
      
      public function killBackgroundFader() : void
      {
         mBackgroundFader.forceStop();
      }
      
      public function killLetterboxEffect() : void
      {
         mLetterboxEffect.forceStop();
      }
      
      public function get rootPosition() : Vector3D
      {
         return mRootPosition;
      }
      
      public function get visibleRectangle() : Rectangle
      {
         var _loc3_:Number = NaN;
         var _loc4_:Number = NaN;
         var _loc2_:Number = NaN;
         var _loc1_:Number = NaN;
         if(mWantScrollRectCulling)
         {
            _loc3_ = mFacade.viewWidth / mZoom;
            _loc4_ = mFacade.viewHeight / mZoom;
            _loc2_ = -mRootPosition.x - _loc3_ * 0.5 + mOffset.x / mZoom;
            _loc1_ = -mRootPosition.y - _loc4_ * 0.5 + mOffset.y / mZoom;
         }
         else
         {
            _loc2_ = (-mTargetObject.x - mTargetObject.parent.x) / mZoom;
            _loc1_ = (-mTargetObject.y - mTargetObject.parent.y) / mZoom;
            _loc3_ = mFacade.viewWidth / mZoom;
            _loc4_ = mFacade.viewHeight / mZoom;
         }
         if(!mVisibleRect)
         {
            mVisibleRect = new Rectangle(_loc2_,_loc1_,_loc3_,_loc4_);
         }
         else
         {
            mVisibleRect.setTo(_loc2_,_loc1_,_loc3_,_loc4_);
         }
         return mVisibleRect;
      }
      
      public function isPointOnScreen(position:Vector3D) : Boolean
      {
         return this.visibleRectangle.contains(position.x,position.y);
      }
      
      public function get offset() : Point
      {
         return mOffset;
      }
      
      public function set offset(val:Point) : void
      {
         mOffset = val;
      }
      
      public function get yCilppingFromBottom() : Number
      {
         return mYClippingFromBottom;
      }
      
      public function set yCilppingFromBottom(val:Number) : void
      {
         mYClippingFromBottom = val;
      }
      
      public function forceRedraw() : void
      {
         mPrevRootPosition.x = mRootPosition.x;
         mPrevRootPosition.y = mRootPosition.y;
         mTransformDirty = true;
         update(null);
      }
      
      public function getWorldCoordinateFromMouse(mouseX:Number, mouseY:Number) : Vector3D
      {
         return new Vector3D(mouseX / zoom + visibleRectangle.x,mouseY / zoom + visibleRectangle.y);
      }
   }
}

