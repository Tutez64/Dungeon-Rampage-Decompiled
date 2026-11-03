package Actor.StarlingConvertedOverlay
{
   import Actor.ActorNametag;
   import Brain.Camera.Camera;
   import Brain.Clock.GameClock;
   import Brain.Starling.StarlingLayer;
   import Brain.Starling.StarlingLayerManager;
   import Brain.Starling.SwfConverter.BakeBudget;
   import Brain.Starling.SwfConverter.BakedCell;
   import Brain.Starling.SwfConverter.BakedGlyphFont;
   import Brain.Starling.SwfConverter.BakedPages;
   import Brain.WorkLoop.LayerWorkComponent;
   import Facade.DBFacade;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.filters.BitmapFilter;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.utils.getTimer;
   import starling.display.Sprite;
   
   public class StarlingOverlays
   {
      
      internal static const CELL_READY:int = 0;
      
      internal static const CELL_BUSY:int = 1;
      
      internal static const CELL_REFUSED:int = 2;
      
      private static const BAKES_PER_FRAME:int = 4;
      
      internal static const SCALE_TOLERANCE:Number = 0.005;
      
      private static const ZOOM_EXACT:Number = 0.001;
      
      private static const SETTLE_FRAMES:int = 30;
      
      private static const SCALE_STEPS:Number = 1000;
      
      private static const CULL_MARGIN:Number = 300;
      
      private static const MAX_FLOATERS:int = 256;
      
      private static const FONT_RETRY_FRAMES:int = 60;
      
      private static const BIG_FONT_SCALE:Number = 1.8;
      
      private static const BIG_FONT_FROM:Number = 1.25;
      
      private static const FLOATER_CHARS:String = "0123456789+-!";
      
      private static const MAX_BLUR:Number = 255;
      
      private static var sInstance:StarlingOverlays;
      
      private static const COMPARE_TAGS:Function = TagSprite.compare;
      
      private var mFacade:DBFacade;
      
      private var mWork:LayerWorkComponent;
      
      private var mPages:BakedPages;
      
      private var mAboveFade:DisplayObject;
      
      private var mLayer:StarlingLayer;
      
      private var mRoot:StarlingOverlayRoot;
      
      private var mOn:Boolean = false;
      
      private var mFrame:int = 0;
      
      private var mZoom:Number = 0;
      
      private var mPendingZoom:Number = 0;
      
      private var mPendingFrames:int = 0;
      
      private var mBakesLeft:int = 0;
      
      private var mLastCell:BakedCell;
      
      private var mView:Rectangle;
      
      private const mTags:Vector.<StarlingNametag> = new Vector.<StarlingNametag>(0);
      
      private const mViewPool:Vector.<TagView> = new Vector.<TagView>(0);
      
      private const mKept:Vector.<BakedCell> = new Vector.<BakedCell>(0);
      
      private const mFloaters:Vector.<StarlingDamageFloater> = new Vector.<StarlingDamageFloater>(0);
      
      private const mFloaterPool:Vector.<StarlingDamageFloater> = new Vector.<StarlingDamageFloater>(0);
      
      private const mLayout:FloaterLayout = new FloaterLayout();
      
      private var mGlow:BakedGlyphFont;
      
      private var mFill:BakedGlyphFont;
      
      private var mBigGlow:BakedGlyphFont;
      
      private var mBigFill:BakedGlyphFont;
      
      private var mFontZoom:Number = 0;
      
      private var mCrit:BakedGlyphFont;
      
      private var mBigCrit:BakedGlyphFont;
      
      private var mFontRetry:int = 0;
      
      private var mLastTime:int = 0;
      
      private var mGlowKnockout:Boolean = false;
      
      public function StarlingOverlays(facade:DBFacade)
      {
         super();
         mFacade = facade;
         mPages = new BakedPages("world",1024,512);
         mAboveFade = facade.sceneGraphManager.getLayer(46);
         mWork = new LayerWorkComponent(facade,"StarlingOverlays");
         mWork.doEveryFrame(onFrame);
      }
      
      public static function wanted(facade:DBFacade) : Boolean
      {
         return facade != null && facade.featureFlags != null && facade.featureFlags.getFlagValue("starling-overlays");
      }
      
      public static function get(facade:DBFacade) : StarlingOverlays
      {
         if(sInstance == null)
         {
            sInstance = new StarlingOverlays(facade);
         }
         return sInstance;
      }
      
      public static function drawsFloaters(facade:DBFacade) : Boolean
      {
         return wanted(facade) && get(facade).floatersReady;
      }
      
      private static function scaledFilters(filters:Array, factor:Number) : Array
      {
         var _loc5_:BitmapFilter = null;
         var _loc3_:Array = [];
         for each(var _loc4_:BitmapFilter in filters)
         {
            _loc5_ = _loc4_.clone();
            if("blurX" in _loc5_)
            {
               _loc5_["blurX"] = Math.min(255,Number(_loc5_["blurX"]) * factor);
            }
            if("blurY" in _loc5_)
            {
               _loc5_["blurY"] = Math.min(255,Number(_loc5_["blurY"]) * factor);
            }
            if("distance" in _loc5_)
            {
               _loc5_["distance"] = Number(_loc5_["distance"]) * factor;
            }
            _loc3_.push(_loc5_);
         }
         return _loc3_;
      }
      
      public function addTag(nametag:ActorNametag, top:DisplayObject, art:DisplayObjectContainer, name:TextField, afk:TextField, hp:DisplayObjectContainer, fill:DisplayObject) : StarlingNametag
      {
         var _loc8_:StarlingNametag = new StarlingNametag(this,nametag,top,art,name,afk,hp,fill);
         mTags.push(_loc8_);
         return _loc8_;
      }
      
      public function spawnFloater(style:FloaterStyle, rootX:Number, topY:Number, holdTicks:uint, totalTicks:uint, scaleDampening:Number, speed:Number, buff:Boolean) : Boolean
      {
         if(!floatersReady || !hasGlyphs(style.text))
         {
            return false;
         }
         if(mFloaters.length >= 256)
         {
            recycle(mFloaters.shift());
         }
         var _loc9_:StarlingDamageFloater = newFloater(style);
         var _loc10_:Number = mFacade.gameClock.tickLength;
         _loc9_.start(rootX - mLayout.bitmapWidth * style.scale * 0.5,topY,style.scale,style.rotation,style.directionX,style.directionY,holdTicks * _loc10_,totalTicks * _loc10_,scaleDampening,speed,buff);
         mRoot.floaters.addChild(_loc9_);
         mFloaters.push(_loc9_);
         return true;
      }
      
      private function newFloater(style:FloaterStyle) : StarlingDamageFloater
      {
         var _loc2_:Boolean = style.scale > 1.25;
         var _loc3_:StarlingDamageFloater = mFloaterPool.length > 0 ? mFloaterPool.pop() : new StarlingDamageFloater();
         _loc3_.visible = true;
         _loc3_.big = _loc2_;
         _loc3_.crit = style.crit;
         _loc3_.setFonts(_loc2_ ? mBigGlow : mGlow,_loc2_ ? mBigFill : mFill,critFont(_loc3_));
         mLayout.place(_loc3_.setText(style.text,style.color));
         _loc3_.placeRows(mLayout.inkX - mLayout.left,mLayout.inkY - mLayout.top,mLayout.labelScaleX,mLayout.labelScaleY);
         return _loc3_;
      }
      
      private function hasGlyphs(text:String) : Boolean
      {
         var _loc2_:int = 0;
         if(text == null)
         {
            return false;
         }
         _loc2_ = 0;
         while(_loc2_ < text.length)
         {
            if(!mFill.hasGlyph(text.charCodeAt(_loc2_)))
            {
               return false;
            }
            _loc2_++;
         }
         return true;
      }
      
      private function get floatersReady() : Boolean
      {
         return mOn && mFill != null && mRoot != null;
      }
      
      internal function get aboveFadeLayer() : DisplayObject
      {
         return mAboveFade;
      }
      
      internal function get snapPixelsPerUnit() : Number
      {
         if(mLayer == null || mZoom <= 0)
         {
            return 0;
         }
         var _loc2_:Matrix = mLayer.transformationMatrix;
         var _loc1_:Number = Math.sqrt(_loc2_.a * _loc2_.a + _loc2_.b * _loc2_.b) * mFacade.starlingLayerManager.starlingInstance.contentScaleFactor;
         return isFinite(_loc1_) && Math.abs(_loc1_ / mZoom - 1) <= 0.005 ? _loc1_ : 0;
      }
      
      internal function get cameraOffsetX() : Number
      {
         return mFacade.starlingLayerManager.worldCameraOffsetX;
      }
      
      internal function get cameraOffsetY() : Number
      {
         return mFacade.starlingLayerManager.worldCameraOffsetY;
      }
      
      internal function get lastCell() : BakedCell
      {
         return mLastCell;
      }
      
      internal function bakeScale(chainScale:Number) : Number
      {
         return Math.max(1,Math.round(mZoom * chainScale * 1000)) / 1000;
      }
      
      internal function cellFor(key:String, source:DisplayObject, scale:Number, hide:Vector.<DisplayObject>, keep:Boolean) : int
      {
         var _loc6_:BakedCell = mPages.acquire(key);
         if(_loc6_ == null)
         {
            if(mBakesLeft <= 0)
            {
               return 1;
            }
            mBakesLeft = mBakesLeft - 1;
            _loc6_ = mPages.bake(key,source,scale,hide);
            if(_loc6_ == null)
            {
               return 2;
            }
            if(keep)
            {
               mKept.push(mPages.acquire(key));
            }
         }
         mLastCell = _loc6_;
         return 0;
      }
      
      internal function releaseCell(cell:BakedCell) : void
      {
         mPages.release(cell);
      }
      
      internal function isCulled(x:Number, y:Number) : Boolean
      {
         var _loc3_:Rectangle = mView;
         return _loc3_ != null && (x < _loc3_.left - 300 || x > _loc3_.right + 300 || y < _loc3_.top - 300 || y > _loc3_.bottom + 300);
      }
      
      internal function takeView() : TagView
      {
         var _loc1_:TagView = mViewPool.length > 0 ? mViewPool.pop() : new TagView();
         _loc1_.tag.visible = false;
         mRoot.tags.addChild(_loc1_.tag);
         return _loc1_;
      }
      
      internal function returnView(view:TagView) : void
      {
         if(mRoot == null || view.tag.parent != mRoot.tags)
         {
            return;
         }
         view.tag.removeFromParent();
         view.tag.owner = null;
         mViewPool.push(view);
      }
      
      internal function removeTag(tag:StarlingNametag) : void
      {
         var _loc2_:int = mTags.indexOf(tag);
         if(_loc2_ < 0)
         {
            return;
         }
         mTags[_loc2_] = mTags[mTags.length - 1];
         mTags.length--;
      }
      
      private function onFrame(clock:GameClock) : void
      {
         var _loc5_:int = 0;
         var _loc7_:Boolean = wanted(mFacade) && ensureRoot();
         if(_loc7_ != mOn)
         {
            mOn = _loc7_;
            if(!_loc7_)
            {
               switchToFlash();
            }
         }
         var _loc3_:int = getTimer();
         var _loc2_:Number = (_loc3_ - mLastTime) * 0.001 * mFacade.gameClock.timeScale;
         mLastTime = _loc3_;
         if(!_loc7_)
         {
            return;
         }
         mFrame = mFrame + 1;
         updateZoom();
         if(mZoom <= 0)
         {
            return;
         }
         if((mFill == null || mFontZoom != mZoom) && mFrame >= mFontRetry && BakeBudget.mayAllocate)
         {
            buildFonts();
         }
         mBakesLeft = 4;
         var _loc6_:Camera = mFacade.camera;
         var _loc4_:Boolean = _loc6_ != null && _loc6_.rotation == 0 && _loc6_._shakeRotation == 0;
         mView = _loc4_ && _loc6_.targetObject != null && _loc6_.targetObject.parent != null ? _loc6_.visibleRectangle : null;
         _loc5_ = 0;
         while(_loc5_ < mTags.length)
         {
            mTags[_loc5_].update(mFrame);
            _loc5_++;
         }
         if(!tagsInOrder())
         {
            mRoot.tags.sortChildren(COMPARE_TAGS);
         }
         advanceFloaters(_loc2_);
      }
      
      private function tagsInOrder() : Boolean
      {
         var _loc1_:int = 0;
         var _loc2_:Sprite = mRoot.tags;
         _loc1_ = 1;
         while(_loc1_ < _loc2_.numChildren)
         {
            if(COMPARE_TAGS(_loc2_.getChildAt(_loc1_ - 1),_loc2_.getChildAt(_loc1_)) > 0)
            {
               return false;
            }
            _loc1_++;
         }
         return true;
      }
      
      private function ensureRoot() : Boolean
      {
         var _loc1_:StarlingLayerManager = mFacade.starlingLayerManager;
         var _loc2_:StarlingLayer = _loc1_ != null && _loc1_.isReady() ? _loc1_.starlingOverlayLayer : null;
         if(_loc2_ == null)
         {
            return false;
         }
         if(mLayer != _loc2_)
         {
            mLayer = _loc2_;
            return false;
         }
         if(mRoot == null)
         {
            mRoot = new StarlingOverlayRoot();
         }
         if(mRoot.parent != _loc2_)
         {
            _loc2_.addChild(mRoot);
         }
         return true;
      }
      
      private function switchToFlash() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < mTags.length)
         {
            mTags[_loc1_].switchToFlash();
            _loc1_++;
         }
         _loc1_ = 0;
         while(_loc1_ < mFloaters.length)
         {
            recycle(mFloaters[_loc1_]);
            _loc1_++;
         }
         mFloaters.length = 0;
      }
      
      private function updateZoom() : void
      {
         var _loc2_:Matrix = mLayer.transformationMatrix;
         var _loc1_:Number = Math.sqrt(_loc2_.a * _loc2_.a + _loc2_.b * _loc2_.b) * mFacade.starlingLayerManager.starlingInstance.contentScaleFactor;
         if(_loc1_ <= 0 || !isFinite(_loc1_))
         {
            return;
         }
         if(mZoom > 0)
         {
            if(Math.abs(_loc1_ / mZoom - 1) <= 0.001)
            {
               mPendingFrames = 0;
               return;
            }
            if(mPendingFrames == 0 || Math.abs(_loc1_ / mPendingZoom - 1) > 0.001)
            {
               mPendingZoom = _loc1_;
               mPendingFrames = 0;
            }
            if(++mPendingFrames < 30)
            {
               return;
            }
            mPendingFrames = 0;
         }
         mZoom = _loc1_;
         rebakeAll();
      }
      
      private function rebakeAll() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < mKept.length)
         {
            mPages.release(mKept[_loc1_]);
            _loc1_++;
         }
         mKept.length = 0;
         _loc1_ = 0;
         while(_loc1_ < mTags.length)
         {
            mTags[_loc1_].rescale();
            _loc1_++;
         }
         mFontZoom = 0;
         mFontRetry = 0;
      }
      
      private function advanceFloaters(seconds:Number) : void
      {
         var _loc4_:int = 0;
         var _loc3_:StarlingDamageFloater = null;
         var _loc2_:int = int(mFloaters.length);
         var _loc5_:int = 0;
         _loc4_ = 0;
         while(_loc4_ < _loc2_)
         {
            _loc3_ = mFloaters[_loc4_];
            if(_loc3_.advance(seconds))
            {
               mFloaters[_loc5_++] = _loc3_;
            }
            else
            {
               recycle(_loc3_);
            }
            _loc4_++;
         }
         mFloaters.length = _loc5_;
      }
      
      private function recycle(floater:StarlingDamageFloater) : void
      {
         floater.removeFromParent();
         mFloaterPool.push(floater);
      }
      
      private function buildFonts() : void
      {
         var _loc6_:String = null;
         var _loc9_:int = 0;
         var _loc16_:StarlingDamageFloater = null;
         mFontRetry = mFrame + 60;
         var _loc17_:Class = mFacade.hud != null ? mFacade.hud.floaterTextClass : null;
         var _loc19_:MovieClip = _loc17_ != null ? new _loc17_() as MovieClip : null;
         var _loc10_:TextField = _loc19_ != null ? _loc19_.getChildByName("label") as TextField : null;
         if(_loc10_ == null)
         {
            return;
         }
         mLayout.measure(_loc19_,_loc10_);
         var _loc11_:Number = Math.abs(mLayout.labelScaleY) > 0 ? Math.abs(mLayout.labelScaleY) : 1;
         var _loc8_:Number = mZoom * _loc11_;
         var _loc1_:Array = _loc10_.filters ?? [];
         var _loc13_:Array = glowOnly(_loc1_);
         var _loc12_:BakedGlyphFont = BakedGlyphFont.build(mPages,"floater",_loc10_,_loc8_,"0123456789+-!",1);
         var _loc21_:BakedGlyphFont = BakedGlyphFont.build(mPages,"floater",_loc10_,_loc8_ * 1.8,"0123456789+-!",1);
         var _loc18_:BakedGlyphFont = null;
         var _loc14_:BakedGlyphFont = null;
         if(_loc13_ != null)
         {
            _loc6_ = mGlowKnockout ? "floaterGlow" : "floaterFull";
            _loc10_.filters = scaledFilters(_loc13_,mZoom);
            _loc18_ = BakedGlyphFont.build(mPages,_loc6_,_loc10_,_loc8_,"0123456789+-!",0);
            _loc10_.filters = scaledFilters(_loc13_,mZoom * 1.8);
            _loc14_ = BakedGlyphFont.build(mPages,_loc6_,_loc10_,_loc8_ * 1.8,"0123456789+-!",0);
         }
         var _loc2_:BitmapFilter = FloaterStyle.CRIT_GLOW.clone();
         _loc2_["knockout"] = true;
         _loc10_.filters = scaledFilters(_loc1_.concat(_loc2_),mZoom);
         var _loc15_:BakedGlyphFont = BakedGlyphFont.build(mPages,"floaterCrit",_loc10_,_loc8_,"0123456789+-!",0);
         _loc10_.filters = scaledFilters(_loc1_.concat(_loc2_),mZoom * 1.8);
         var _loc3_:BakedGlyphFont = BakedGlyphFont.build(mPages,"floaterCrit",_loc10_,_loc8_ * 1.8,"0123456789+-!",0);
         var _loc5_:Array = [_loc12_,_loc21_,_loc18_,_loc14_,_loc15_,_loc3_];
         if(_loc12_ == null || _loc21_ == null || _loc15_ == null || _loc3_ == null || _loc13_ != null && (_loc18_ == null || _loc14_ == null))
         {
            for each(var _loc4_:BakedGlyphFont in _loc5_)
            {
               if(_loc4_ != null)
               {
                  _loc4_.release();
               }
            }
            return;
         }
         var _loc7_:Array = [mFill,mBigFill,mGlow,mBigGlow,mCrit,mBigCrit];
         mFill = _loc12_;
         mBigFill = _loc21_;
         mGlow = _loc18_;
         mBigGlow = _loc14_;
         mCrit = _loc15_;
         mBigCrit = _loc3_;
         mFontZoom = mZoom;
         _loc9_ = 0;
         while(_loc9_ < mFloaters.length)
         {
            _loc16_ = mFloaters[_loc9_];
            _loc16_.setFonts(_loc16_.big ? _loc14_ : _loc18_,_loc16_.big ? _loc21_ : _loc12_,critFont(_loc16_));
            _loc9_++;
         }
         for each(var _loc20_:BakedGlyphFont in _loc7_)
         {
            if(_loc20_ != null)
            {
               _loc20_.release();
            }
         }
      }
      
      private function critFont(floater:StarlingDamageFloater) : BakedGlyphFont
      {
         return floater.crit ? (floater.big ? mBigCrit : mCrit) : null;
      }
      
      private function glowOnly(filters:Array) : Array
      {
         var _loc2_:BitmapFilter = null;
         mGlowKnockout = false;
         if(filters == null || filters.length == 0)
         {
            return null;
         }
         if(filters.length == 1 && "knockout" in filters[0])
         {
            _loc2_ = BitmapFilter(filters[0]).clone();
            _loc2_["knockout"] = true;
            mGlowKnockout = true;
            return [_loc2_];
         }
         return filters;
      }
   }
}

