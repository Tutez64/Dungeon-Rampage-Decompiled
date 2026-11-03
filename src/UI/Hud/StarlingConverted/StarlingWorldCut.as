package UI.Hud.StarlingConverted
{
   import Actor.ChatBalloonOverlay;
   import Brain.Starling.SwfConverter.BakedCell;
   import Brain.Starling.SwfConverter.BakedImage;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.Graphics;
   import flash.display.Shape;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   import starling.display.DisplayObject;
   import starling.display.DisplayObjectContainer;
   import starling.display.Mesh;
   
   public class StarlingWorldCut
   {
      
      private static const FAR:Number = 100000;
      
      private static const GRID:Number = 4;
      
      private const mBounds:Rectangle = new Rectangle();
      
      private const mMatrix:Matrix = new Matrix();
      
      private var mChatOverlay:ChatBalloonOverlay;
      
      private var mWorld:flash.display.DisplayObject;
      
      private var mHud:starling.display.DisplayObject;
      
      private var mMask:Shape;
      
      private var mOn:Boolean;
      
      private var mDirty:Boolean = true;
      
      private var mDynamicDirty:Boolean = true;
      
      private var mStaticRects:Vector.<Number> = new Vector.<Number>(0);
      
      private var mStaticCount:int;
      
      private var mDynamic:Vector.<starling.display.DisplayObject> = new Vector.<starling.display.DisplayObject>(0);
      
      private var mDynamicSet:Dictionary = new Dictionary(true);
      
      private var mRects:Vector.<Number> = new Vector.<Number>(0);
      
      private var mDrawn:Vector.<Number> = new Vector.<Number>(0);
      
      private var mCount:int;
      
      private var mDrawnCount:int = -1;
      
      private var mYs:Vector.<Number> = new Vector.<Number>(0);
      
      private var mSpans:Vector.<Number> = new Vector.<Number>(0);
      
      private const mFade:HudCutFade = new HudCutFade();
      
      private const mPixels:Vector.<Number> = new Vector.<Number>(0);
      
      private const mDevice:Matrix = new Matrix();
      
      public function StarlingWorldCut(world:flash.display.DisplayObject, designSpace:flash.display.DisplayObjectContainer, hud:starling.display.DisplayObject, fadeLayer:flash.display.DisplayObject = null)
      {
         super();
         mWorld = world;
         mHud = hud;
         mMask = new Shape();
         mMask.name = "StarlingWorldCut";
         mMask.visible = false;
         designSpace.addChildAt(mMask,0);
         mChatOverlay = new ChatBalloonOverlay(world as flash.display.DisplayObjectContainer,designSpace,fadeLayer);
      }
      
      public function set enabled(on:Boolean) : void
      {
         if(on == mOn)
         {
            return;
         }
         mOn = on;
         mDrawnCount = -1;
         mDirty = true;
         if(!on)
         {
            mChatOverlay.update(false);
            useMask(false);
            mMask.graphics.clear();
            mFade.clear();
            mFade.hide();
            return;
         }
         update();
      }
      
      private function useMask(on:Boolean) : void
      {
         var _loc2_:Shape = on ? mMask : null;
         if(mWorld.mask == _loc2_)
         {
            return;
         }
         mWorld.mask = _loc2_;
         mMask.visible = on;
      }
      
      public function get enabled() : Boolean
      {
         return mOn;
      }
      
      public function invalidate() : void
      {
         mDirty = true;
      }
      
      internal function invalidateDynamic() : void
      {
         mDynamicDirty = true;
      }
      
      internal function addDynamic(node:starling.display.DisplayObject) : void
      {
         mDynamic.push(node);
         mDynamicSet[node] = true;
         mDirty = mDynamicDirty = true;
      }
      
      internal function removeDynamic(node:starling.display.DisplayObject) : void
      {
         var _loc2_:int = mDynamic.indexOf(node);
         if(_loc2_ >= 0)
         {
            mDynamic.removeAt(_loc2_);
         }
         delete mDynamicSet[node];
         mDirty = mDynamicDirty = true;
      }
      
      public function update() : void
      {
         var _loc4_:int = 0;
         var _loc5_:starling.display.DisplayObject = null;
         var _loc3_:starling.display.DisplayObject = null;
         var _loc6_:Boolean = false;
         var _loc2_:Boolean = mFade.designMoved(mMask);
         if(!mDirty && !mDynamicDirty && !_loc2_)
         {
            return;
         }
         if(!mOn || mHud.stage == null)
         {
            return;
         }
         if(mDirty)
         {
            mCount = 0;
            collect(mHud);
            mStaticCount = mCount;
            _loc4_ = 0;
            while(_loc4_ < mCount)
            {
               mStaticRects[_loc4_] = mRects[_loc4_];
               _loc4_++;
            }
            mDirty = false;
         }
         mDynamicDirty = false;
         mCount = mStaticCount;
         _loc4_ = 0;
         while(_loc4_ < mCount)
         {
            mRects[_loc4_] = mStaticRects[_loc4_];
            _loc4_++;
         }
         for each(_loc5_ in mDynamic)
         {
            _loc6_ = true;
            _loc3_ = _loc5_;
            while(_loc3_ != null)
            {
               if(!_loc3_.visible || _loc3_.alpha <= 0)
               {
                  _loc6_ = false;
                  break;
               }
               _loc3_ = _loc3_.parent;
            }
            if(_loc6_)
            {
               collectLive(_loc5_);
            }
         }
         if(!_loc2_ && same())
         {
            return;
         }
         draw();
         useMask(mCount > 0);
         var _loc1_:Vector.<Number> = mDrawn;
         mDrawn = mRects;
         mRects = _loc1_;
         mDrawnCount = mCount;
      }
      
      public function syncChatOverlay(fadeAlpha:Number = 0, fadeColor:uint = 0) : void
      {
         if(mChatOverlay != null)
         {
            mChatOverlay.update(mOn && mHud.stage != null && mWorld.mask == mMask,fadeAlpha,fadeColor);
         }
      }
      
      public function fade(alpha:Number, color:uint) : void
      {
         if(mOn && mHud != null)
         {
            mFade.sync(mHud,mHud,alpha,color);
         }
         else
         {
            mFade.hide();
         }
      }
      
      public function dispose() : void
      {
         if(mChatOverlay != null)
         {
            mChatOverlay.dispose();
         }
         mChatOverlay = null;
         mFade.dispose();
         if(mWorld != null && mWorld.mask == mMask)
         {
            mWorld.mask = null;
         }
         if(mMask != null && mMask.parent != null)
         {
            mMask.parent.removeChild(mMask);
         }
         mMask = null;
         mWorld = null;
         mHud = null;
         mOn = false;
      }
      
      private function collect(node:starling.display.DisplayObject) : void
      {
         var _loc6_:Rectangle = null;
         var _loc5_:int = 0;
         var _loc7_:BakedCell = null;
         if(!node.visible || ArtDisplay.isClipMask(node) || node.alpha <= 0 || mDynamicSet[node])
         {
            return;
         }
         var _loc3_:ArtDisplay = node as ArtDisplay;
         if(_loc3_ != null && _loc3_.mask != null && !ArtDisplay.isClipMask(_loc3_.mask))
         {
            _loc3_.mask.getBounds(mHud,mBounds);
            appendBounds();
            return;
         }
         if(_loc3_ != null && _loc3_.art.kind == "text")
         {
            collectLive(_loc3_);
            return;
         }
         if(_loc3_ != null && _loc3_.art.kind != "container" && _loc3_.art.maximalBounds != null)
         {
            _loc6_ = _loc3_.art.maximalBounds;
            _loc3_.getTransformationMatrix(mHud,mMatrix);
            boundsOf(_loc6_.left,_loc6_.top,_loc6_.right,_loc6_.bottom);
            appendBounds();
            collectLive(_loc3_);
            return;
         }
         var _loc4_:starling.display.DisplayObjectContainer = node as starling.display.DisplayObjectContainer;
         if(_loc4_ != null)
         {
            _loc5_ = 0;
            while(_loc5_ < _loc4_.numChildren)
            {
               collect(_loc4_.getChildAt(_loc5_));
               _loc5_++;
            }
            return;
         }
         var _loc8_:Mesh = node as Mesh;
         if(_loc8_ == null || _loc8_.texture == null || _loc8_.numVertices == 0)
         {
            return;
         }
         var _loc2_:BakedImage = node as BakedImage;
         if(_loc2_ != null)
         {
            _loc7_ = _loc2_.cell;
            if(_loc7_ == null || !_loc7_.alive || _loc7_.isEmpty)
            {
               return;
            }
            _loc2_.getTransformationMatrix(mHud,mMatrix);
            boundsOf(0,0,_loc7_.pixelWidth / _loc7_.pixelScale,_loc7_.pixelHeight / _loc7_.pixelScale);
         }
         else
         {
            _loc8_.getBounds(mHud,mBounds);
         }
         appendBounds();
      }
      
      private function collectLive(node:starling.display.DisplayObject) : void
      {
         var _loc4_:int = 0;
         if(!node.visible || ArtDisplay.isClipMask(node) || node.alpha <= 0 || node.scaleX == 0 || node.scaleY == 0)
         {
            return;
         }
         if(node.mask != null && !ArtDisplay.isClipMask(node.mask))
         {
            node.mask.getBounds(mHud,mBounds);
            appendBounds();
            return;
         }
         var _loc2_:starling.display.DisplayObjectContainer = node as starling.display.DisplayObjectContainer;
         if(_loc2_ != null)
         {
            _loc4_ = 0;
            while(_loc4_ < _loc2_.numChildren)
            {
               collectLive(_loc2_.getChildAt(_loc4_));
               _loc4_++;
            }
            return;
         }
         var _loc5_:Mesh = node as Mesh;
         var _loc3_:BakedImage = node as BakedImage;
         if(_loc5_ == null || _loc5_.texture == null || _loc5_.numVertices == 0)
         {
            return;
         }
         if(_loc3_ != null && (_loc3_.cell == null || !_loc3_.cell.alive || _loc3_.cell.isEmpty))
         {
            return;
         }
         _loc5_.getBounds(mHud,mBounds);
         appendBounds();
      }
      
      private function appendBounds() : void
      {
         if(!(mBounds.width > 0 && mBounds.height > 0))
         {
            return;
         }
         mRects[mCount++] = Math.floor(mBounds.left / 4) * 4;
         mRects[mCount++] = Math.floor(mBounds.top / 4) * 4;
         mRects[mCount++] = Math.ceil(mBounds.right / 4) * 4;
         mRects[mCount++] = Math.ceil(mBounds.bottom / 4) * 4;
      }
      
      private function boundsOf(left:Number, top:Number, right:Number, bottom:Number) : void
      {
         var _loc5_:Matrix = mMatrix;
         var _loc9_:Number = _loc5_.a * left + _loc5_.c * top + _loc5_.tx;
         var _loc8_:Number = _loc5_.b * left + _loc5_.d * top + _loc5_.ty;
         var _loc11_:Number = _loc5_.a * right + _loc5_.c * top + _loc5_.tx;
         var _loc10_:Number = _loc5_.b * right + _loc5_.d * top + _loc5_.ty;
         var _loc13_:Number = _loc5_.a * left + _loc5_.c * bottom + _loc5_.tx;
         var _loc12_:Number = _loc5_.b * left + _loc5_.d * bottom + _loc5_.ty;
         var _loc15_:Number = _loc5_.a * right + _loc5_.c * bottom + _loc5_.tx;
         var _loc14_:Number = _loc5_.b * right + _loc5_.d * bottom + _loc5_.ty;
         var _loc7_:Number = Math.min(Math.min(_loc9_,_loc11_),Math.min(_loc13_,_loc15_));
         var _loc6_:Number = Math.min(Math.min(_loc8_,_loc10_),Math.min(_loc12_,_loc14_));
         mBounds.setTo(_loc7_,_loc6_,Math.max(Math.max(_loc9_,_loc11_),Math.max(_loc13_,_loc15_)) - _loc7_,Math.max(Math.max(_loc8_,_loc10_),Math.max(_loc12_,_loc14_)) - _loc6_);
      }
      
      private function same() : Boolean
      {
         var _loc1_:int = 0;
         if(mCount != mDrawnCount)
         {
            return false;
         }
         _loc1_ = 0;
         while(_loc1_ < mCount)
         {
            if(mRects[_loc1_] != mDrawn[_loc1_])
            {
               return false;
            }
            _loc1_++;
         }
         return true;
      }
      
      private function draw() : void
      {
         var _loc8_:int = 0;
         var _loc2_:int = 0;
         var _loc3_:Number = NaN;
         var _loc1_:int = 0;
         var _loc7_:Number = NaN;
         var _loc10_:Number = NaN;
         mFade.remember(mMask);
         var _loc5_:Graphics = mMask.graphics;
         _loc5_.clear();
         _loc5_.beginFill(0);
         mFade.clear();
         var _loc6_:Vector.<Number> = HudCutFade.toDevicePixels(mRects,mCount,mPixels,HudCutFade.stageMatrix(mMask,mDevice));
         var _loc9_:int = 0;
         _loc8_ = 0;
         while(_loc8_ < mCount)
         {
            mYs[_loc9_++] = _loc6_[_loc8_ + 1];
            mYs[_loc9_++] = _loc6_[_loc8_ + 3];
            _loc8_ += 4;
         }
         mYs[_loc9_++] = -100000;
         mYs[_loc9_++] = 100000;
         mYs.length = _loc9_;
         sortYs();
         _loc2_ = 0;
         while(_loc2_ + 1 < _loc9_)
         {
            _loc3_ = mYs[_loc2_];
            var _loc4_:Number = mYs[_loc2_ + 1];
            if(_loc4_ > _loc3_)
            {
               _loc1_ = 0;
               _loc8_ = 0;
               while(_loc8_ < mCount)
               {
                  if(_loc6_[_loc8_ + 1] <= _loc3_ && _loc6_[_loc8_ + 3] >= _loc4_)
                  {
                     mSpans[_loc1_++] = _loc6_[_loc8_];
                     mSpans[_loc1_++] = _loc6_[_loc8_ + 2];
                  }
                  _loc8_ += 4;
               }
               sortSpans(_loc1_);
               _loc7_ = -100000;
               _loc10_ = -100000;
               _loc8_ = 0;
               while(_loc8_ < _loc1_)
               {
                  if(mSpans[_loc8_] > _loc7_)
                  {
                     if(_loc10_ > -100000)
                     {
                        mFade.add(_loc10_,_loc3_,_loc7_,_loc4_);
                     }
                     _loc5_.drawRect(_loc7_,_loc3_,mSpans[_loc8_] - _loc7_,_loc4_ - _loc3_);
                     _loc10_ = mSpans[_loc8_];
                  }
                  if(mSpans[_loc8_ + 1] > _loc7_)
                  {
                     _loc7_ = mSpans[_loc8_ + 1];
                  }
                  _loc8_ += 2;
               }
               if(_loc10_ > -100000)
               {
                  mFade.add(_loc10_,_loc3_,_loc7_,_loc4_);
               }
               _loc5_.drawRect(_loc7_,_loc3_,100000 - _loc7_,_loc4_ - _loc3_);
            }
            _loc2_++;
         }
         _loc5_.endFill();
      }
      
      private function sortYs() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Number = NaN;
         var _loc3_:int = 0;
         _loc1_ = 1;
         while(_loc1_ < mYs.length)
         {
            _loc2_ = mYs[_loc1_];
            _loc3_ = _loc1_ - 1;
            while(_loc3_ >= 0 && mYs[_loc3_] > _loc2_)
            {
               mYs[_loc3_ + 1] = mYs[_loc3_];
               _loc3_--;
            }
            mYs[_loc3_ + 1] = _loc2_;
            _loc1_++;
         }
      }
      
      private function sortSpans(count:int) : void
      {
         var _loc3_:int = 0;
         var _loc5_:Number = NaN;
         var _loc4_:int = 0;
         _loc3_ = 2;
         while(_loc3_ < count)
         {
            _loc5_ = mSpans[_loc3_];
            var _loc2_:Number = mSpans[_loc3_ + 1];
            _loc4_ = _loc3_ - 2;
            while(_loc4_ >= 0 && mSpans[_loc4_] > _loc5_)
            {
               mSpans[_loc4_ + 2] = mSpans[_loc4_];
               mSpans[_loc4_ + 3] = mSpans[_loc4_ + 1];
               _loc4_ -= 2;
            }
            mSpans[_loc4_ + 2] = _loc5_;
            mSpans[_loc4_ + 3] = _loc2_;
            _loc3_ += 2;
         }
      }
   }
}

