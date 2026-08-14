package Brain.Camera
{
   import Brain.Clock.GameClock;
   import Brain.Facade.Facade;
   import com.greensock.TimelineMax;
   import com.greensock.TweenLite;
   import com.greensock.TweenMax;
   import flash.display.DisplayObject;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.geom.Vector3D;
   
   public class Camera
   {
      
      private var mTargetObject:DisplayObject;
      
      private var mBounds:Rectangle;
      
      private var mMaxZoom:Number = 10;
      
      private var mMinZoom:Number = 0.01;
      
      private var mZoom:Number = 1;
      
      private var mRotation:Number = 0;
      
      private var mTransformDirty:Boolean = false;
      
      private var mRootPosition:Vector3D = new Vector3D();
      
      private var mRootTransform:Matrix = new Matrix();
      
      private var mShakePosition:Vector3D = new Vector3D();
      
      private var mShakeRotation:Number = 0;
      
      private var mBackgroundFader:BackgroundFader;
      
      private var mLetterboxEffect:LetterboxEffect;
      
      private var mVisibleRect:Rectangle;
      
      private var mDefaultZoom:Number;
      
      private var mTweenZoom:TweenLite;
      
      private var mTweenRotation:TweenLite;
      
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
      
      public function destroy() : void
      {
         if(mTweenZoom)
         {
            mTweenZoom.kill();
         }
         if(mTweenRotation)
         {
            mTweenRotation.kill();
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
         }
      }
      
      public function translateTo(point:Vector3D) : void
      {
         mRootPosition = point;
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
            mTweenRotation.kill();
         }
         if(mFacade.featureFlags.getFlagValue("want-zoom"))
         {
            mTweenRotation = TweenLite.to(this,duration,{"rotation":value});
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
            mTweenZoom.kill();
            mTweenZoom = null;
         }
      }
      
      private function shakeFunction(createTween:Function, duration:Number, strength:Number, numShakes:uint) : TimelineMax
      {
         var _loc6_:Number = NaN;
         var _loc8_:* = 0;
         var _loc7_:TimelineMax = new TimelineMax();
         var _loc5_:Number = duration / numShakes;
         _loc8_ = 0;
         while(_loc8_ < numShakes)
         {
            strength = -strength;
            _loc6_ = _loc8_ == 0 ? _loc5_ * 0.5 : _loc5_;
            _loc7_.append(createTween(_loc6_,strength));
            _loc8_++;
         }
         _loc7_.append(createTween(_loc5_ * 0.5,0));
         return _loc7_;
      }
      
      public function shakeRotation(duration:Number, strength:Number, numShakes:uint) : TimelineMax
      {
         var self:Camera = this;
         var createTween:Function = function(param1:Number, param2:Number):TweenMax
         {
            return new TweenMax(self,param1,{
               "_shakeRotation":param2,
               "onUpdate":update
            });
         };
         return this.shakeFunction(createTween,duration,strength,numShakes);
      }
      
      public function shakeX(duration:Number, strength:Number, numShakes:uint) : TimelineMax
      {
         var self:Camera = this;
         var createTween:Function = function(param1:Number, param2:Number):TweenMax
         {
            return new TweenMax(self,param1,{
               "_shakeX":param2,
               "onUpdate":update
            });
         };
         return this.shakeFunction(createTween,duration,strength,numShakes);
      }
      
      public function shakeY(duration:Number, strength:Number, numShakes:uint) : TimelineMax
      {
         var self:Camera = this;
         var createTween:Function = function(param1:Number, param2:Number):TweenMax
         {
            return new TweenMax(self,param1,{
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
      
      public function tweenToDefaultZoom(duration:Number) : TweenLite
      {
         return tweenZoom(duration,defaultZoom);
      }
      
      public function tweenZoom(duration:Number, value:Number, setAsDefault:Boolean = false) : TweenLite
      {
         if(setAsDefault)
         {
            mDefaultZoom = value;
         }
         killTweenZooms();
         mTweenZoom = TweenMax.to(this,duration,{
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
         mTransformDirty = true;
         update(null);
      }
      
      public function getWorldCoordinateFromMouse(mouseX:Number, mouseY:Number) : Vector3D
      {
         return new Vector3D(mouseX / zoom + visibleRectangle.x,mouseY / zoom + visibleRectangle.y);
      }
   }
}

