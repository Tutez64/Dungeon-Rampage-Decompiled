package Actor.StarlingConvertedOverlay
{
   import Actor.ActorNametag;
   import Brain.Starling.SwfConverter.BakeBudget;
   import Brain.Starling.SwfConverter.BakedCell;
   import Brain.Starling.SwfConverter.BakedImage;
   import Brain.Starling.SwfConverter.BakedPages;
   import flash.display.Bitmap;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.display.Shape;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import starling.display.Sprite;
   
   public class StarlingNametag
   {
      
      private static const DEG_TO_RAD:Number = 0.017453292519943295;
      
      private static const SLOW_EVERY:int = 15;
      
      private static const RETRY_FRAMES:int = 60;
      
      private static const MAX_RETRY_FRAMES:int = 1920;
      
      private var mOverlays:StarlingOverlays;
      
      private var mNametag:ActorNametag;
      
      private var mTop:DisplayObject;
      
      private var mArt:DisplayObjectContainer;
      
      private var mName:TextField;
      
      private var mAfk:TextField;
      
      private var mHp:DisplayObjectContainer;
      
      private var mFill:DisplayObject;
      
      private var mNamePart:TagPart;
      
      private var mAfkPart:TagPart;
      
      private var mUnderPart:TagPart;
      
      private var mFillPart:TagPart;
      
      private var mOverPart:TagPart;
      
      private var mParts:Vector.<TagPart>;
      
      private var mOrder:Vector.<int>;
      
      private var mView:TagView;
      
      private var mFlashHidden:Boolean = false;
      
      private var mTextDirty:Boolean = true;
      
      private var mBarShown:Boolean = false;
      
      private var mSlowCountdown:int = 0;
      
      private var mArtCountdown:int;
      
      private var mOverArt:Boolean = false;
      
      private var mNextRetry:int = 0;
      
      private var mRetryFrames:int = 60;
      
      private var mWaitForAllocation:Boolean = false;
      
      private var mCellsChanged:Boolean = true;
      
      private var mNameShiftX:Number = 0;
      
      private var mNameShiftY:Number = 0;
      
      private var mAfkShiftX:Number = 0;
      
      private var mAfkShiftY:Number = 0;
      
      private var mNameX:Number = 0;
      
      private var mNameY:Number = 0;
      
      private var mAfkX:Number = 0;
      
      private var mAfkY:Number = 0;
      
      private var mArtX:Number = 0;
      
      private var mArtY:Number = 0;
      
      public function StarlingNametag(overlays:StarlingOverlays, nametag:ActorNametag, top:DisplayObject, art:DisplayObjectContainer, name:TextField, afk:TextField, hp:DisplayObjectContainer, fill:DisplayObject)
      {
         var before:Vector.<DisplayObject>;
         var after:Vector.<DisplayObject>;
         var depth:Vector.<int>;
         mArtCountdown = Math.random() * 15;
         super();
         mOverlays = overlays;
         mNametag = nametag;
         mTop = top;
         mArt = art;
         mName = name;
         mAfk = afk;
         mHp = hp;
         mFill = fill;
         before = new Vector.<DisplayObject>(0);
         after = new Vector.<DisplayObject>(0);
         splitAround(hp,fill,before,after,false);
         mNamePart = new TagPart(name);
         mAfkPart = new TagPart(afk);
         mUnderPart = new TagPart(hp,new <DisplayObject>[fill].concat(after),true);
         mFillPart = new TagPart(fill,null,true);
         mOverPart = after.length > 0 ? new TagPart(hp,new <DisplayObject>[fill].concat(before),true) : null;
         mParts = new <TagPart>[mNamePart,mAfkPart,mUnderPart,mFillPart];
         if(mOverPart != null)
         {
            mParts.push(mOverPart);
         }
         mOrder = new <int>[0,1,2];
         if(hp.parent == art && name.parent == art && afk.parent == art)
         {
            depth = new <int>[art.getChildIndex(hp),art.getChildIndex(name),art.getChildIndex(afk)];
            mOrder.sort(function(param1:int, param2:int):int
            {
               return depth[param1] - depth[param2];
            });
         }
      }
      
      private static function apply(image:BakedImage, part:TagPart) : void
      {
         var _loc3_:Boolean = part.drawn;
         image.cell = _loc3_ ? part.cell : null;
         image.visible = _loc3_;
      }
      
      private static function placeImage(target:BakedImage, source:DisplayObject, x:Number, y:Number) : void
      {
         target.x = x;
         target.y = y;
         target.scaleX = source.scaleX;
         target.scaleY = source.scaleY;
         target.alpha = source.alpha;
      }
      
      private static function textContent(prefix:String, field:TextField) : String
      {
         var _loc3_:String = field.text;
         if(_loc3_ == null || _loc3_.length == 0)
         {
            return null;
         }
         return prefix + _loc3_ + "|" + field.textColor.toString(16) + "|" + Math.round(field.textWidth * 4) + "x" + Math.round(field.textHeight * 4) + "|" + Math.round(field.width * 4);
      }
      
      private static function splitAround(container:DisplayObjectContainer, target:DisplayObject, before:Vector.<DisplayObject>, after:Vector.<DisplayObject>, found:Boolean) : Boolean
      {
         var _loc6_:int = 0;
         var _loc7_:DisplayObject = null;
         _loc6_ = 0;
         while(_loc6_ < container.numChildren)
         {
            _loc7_ = container.getChildAt(_loc6_);
            if(_loc7_ == target)
            {
               found = true;
            }
            else if(_loc7_ is DisplayObjectContainer && Boolean(DisplayObjectContainer(_loc7_).contains(target)))
            {
               found = splitAround(DisplayObjectContainer(_loc7_),target,before,after,found);
            }
            else
            {
               (found ? after : before).push(_loc7_);
            }
            _loc6_++;
         }
         return found;
      }
      
      public function contentChanged() : void
      {
         mTextDirty = true;
      }
      
      internal function update(frame:int) : void
      {
         var _loc3_:DisplayObjectContainer = null;
         var _loc2_:DisplayObject = mNametag.parent;
         if(_loc2_ == null || _loc2_.parent == null)
         {
            if(mView != null)
            {
               mView.tag.visible = false;
            }
            return;
         }
         if(_loc2_.parent == mOverlays.aboveFadeLayer)
         {
            showFlash();
            return;
         }
         if(--mArtCountdown <= 0)
         {
            mArtCountdown = 15;
            _loc3_ = _loc2_ as DisplayObjectContainer;
            mOverArt = _loc3_ != null && hasFlashArt(_loc3_,_loc3_,mHp.getBounds(_loc3_).union(mName.getBounds(_loc3_)));
         }
         if(mOverArt)
         {
            showFlash();
            return;
         }
         if(!prepare(frame))
         {
            showFlash();
            return;
         }
         if(mView == null)
         {
            mView = mOverlays.takeView();
            mView.tag.owner = this;
            mView.order(mOrder[0],mOrder[1],mOrder[2]);
            mCellsChanged = true;
         }
         if(!mFlashHidden)
         {
            mName.visible = false;
            mAfk.visible = false;
            mHp.visible = false;
            mFlashHidden = true;
         }
         sync(_loc2_);
      }
      
      internal function switchToFlash() : void
      {
         showFlash();
         if(mView != null)
         {
            mOverlays.returnView(mView);
            mView = null;
         }
      }
      
      internal function compareInFlash(other:StarlingNametag) : int
      {
         var _loc3_:DisplayObject = mNametag != null ? mNametag.parent : null;
         var _loc2_:DisplayObject = other.mNametag != null ? other.mNametag.parent : null;
         if(_loc3_ == _loc2_)
         {
            return 0;
         }
         if(_loc3_ == null || _loc2_ == null)
         {
            return _loc3_ == null ? -1 : 1;
         }
         if(_loc3_.y != _loc2_.y)
         {
            return _loc3_.y < _loc2_.y ? -1 : 1;
         }
         if(_loc3_.x != _loc2_.x)
         {
            return _loc2_.x < _loc3_.x ? -1 : 1;
         }
         if(_loc3_.parent == null || _loc3_.parent != _loc2_.parent)
         {
            return 0;
         }
         return _loc3_.parent.getChildIndex(_loc3_) < _loc3_.parent.getChildIndex(_loc2_) ? -1 : 1;
      }
      
      public function destroy() : void
      {
         if(mOverlays == null)
         {
            return;
         }
         if(mView != null)
         {
            mOverlays.returnView(mView);
         }
         mView = null;
         for each(var _loc1_:TagPart in mParts)
         {
            setCell(_loc1_,null,null,0);
         }
         mOverlays.removeTag(this);
         mOverlays = null;
         mNametag = null;
      }
      
      internal function rescale() : void
      {
         mSlowCountdown = 0;
         mTextDirty = true;
         for each(var _loc1_:TagPart in mParts)
         {
            _loc1_.cellScale = -1;
         }
         mNextRetry = 0;
         mRetryFrames = 60;
      }
      
      private function hasFlashArt(node:DisplayObjectContainer, root:DisplayObject, box:Rectangle) : Boolean
      {
         var _loc4_:int = 0;
         var _loc5_:DisplayObject = null;
         _loc4_ = 0;
         while(_loc4_ < node.numChildren)
         {
            _loc5_ = node.getChildAt(_loc4_);
            if(!(_loc5_ == mNametag || !_loc5_.visible || _loc5_.alpha <= 0))
            {
               if(_loc5_ is MovieClip || _loc5_ is Bitmap || _loc5_ is Shape)
               {
                  if(_loc5_.width > 0 && _loc5_.getBounds(root).intersects(box))
                  {
                     return true;
                  }
               }
               else if(_loc5_ is DisplayObjectContainer && hasFlashArt(DisplayObjectContainer(_loc5_),root,box))
               {
                  return true;
               }
            }
            _loc4_++;
         }
         return false;
      }
      
      private function showFlash() : void
      {
         if(mFlashHidden)
         {
            mName.visible = true;
            mAfk.visible = true;
            mHp.visible = true;
            mFlashHidden = false;
         }
         if(mView != null)
         {
            mView.tag.visible = false;
         }
      }
      
      private function prepare(frame:int) : Boolean
      {
         var _loc2_:Boolean = mNametag.hpBarVisible;
         var _loc3_:Boolean = --mSlowCountdown <= 0 || mTextDirty || _loc2_ != mBarShown;
         if(_loc3_)
         {
            mSlowCountdown = 15;
            if(mTextDirty)
            {
               mTextDirty = false;
               mNamePart.wantContent = textContent("name|",mName);
               mAfkPart.wantContent = textContent("afk|",mAfk);
               measureShift(mName,true);
               measureShift(mAfk,false);
            }
            mBarShown = _loc2_;
            mUnderPart.wantContent = _loc2_ ? "hpUnder" : null;
            mFillPart.wantContent = _loc2_ ? "hpFill" : null;
            if(mOverPart != null)
            {
               mOverPart.wantContent = _loc2_ ? "hpOver" : null;
            }
            for each(var _loc5_:TagPart in mParts)
            {
               if(_loc5_.wantContent != null)
               {
                  _loc5_.wantScale = mOverlays.bakeScale(chainScale(_loc5_.source));
               }
            }
         }
         var _loc4_:Boolean = true;
         for each(_loc5_ in mParts)
         {
            if(!_loc5_.current)
            {
               prepareOne(_loc5_,frame);
            }
            if(!_loc5_.usable)
            {
               _loc4_ = false;
            }
         }
         return _loc4_;
      }
      
      private function prepareOne(part:TagPart, frame:int) : void
      {
         if(part.wantContent == null)
         {
            setCell(part,null,null,0);
            return;
         }
         if(mWaitForAllocation)
         {
            if(!BakeBudget.admitting)
            {
               return;
            }
            mWaitForAllocation = false;
            mNextRetry = 0;
         }
         if(frame < mNextRetry)
         {
            return;
         }
         var _loc3_:int = mOverlays.cellFor(part.wantContent + "|" + BakedPages.scaleKey(part.wantScale),part.source,part.wantScale,part.hide,part.shared);
         if(_loc3_ == 0)
         {
            setCell(part,mOverlays.lastCell,part.wantContent,part.wantScale);
            mRetryFrames = 60;
         }
         else if(_loc3_ == 2)
         {
            mWaitForAllocation = !BakeBudget.admitting;
            mNextRetry = frame + mRetryFrames;
            if(!mWaitForAllocation)
            {
               mRetryFrames = Math.min(1920,mRetryFrames * 2);
            }
         }
      }
      
      private function setCell(part:TagPart, cell:BakedCell, content:String, scale:Number) : void
      {
         var _loc5_:BakedCell = part.cell;
         part.cell = cell;
         part.cellContent = content;
         part.cellScale = scale;
         mCellsChanged = true;
         if(mView != null)
         {
            applyCells();
         }
         if(_loc5_ != null)
         {
            mOverlays.releaseCell(_loc5_);
         }
      }
      
      private function applyCells() : void
      {
         mCellsChanged = false;
         apply(mView.name,mNamePart);
         apply(mView.afk,mAfkPart);
         apply(mView.under,mUnderPart);
         apply(mView.fill,mFillPart);
         if(mOverPart != null)
         {
            apply(mView.over,mOverPart);
         }
         else
         {
            mView.over.visible = false;
         }
      }
      
      private function sync(root:DisplayObject) : void
      {
         var _loc17_:Number = NaN;
         var _loc12_:DisplayObjectContainer = null;
         var _loc7_:BakedImage = null;
         var _loc13_:TagView = mView;
         if(mCellsChanged)
         {
            applyCells();
            layoutSlow(_loc13_);
         }
         var _loc15_:Boolean = root.visible && mNametag.shownOnScreen && mTop.visible && mArt.visible;
         var _loc14_:Number = mNametag.scaleX;
         var _loc10_:Number = mNametag.scaleY;
         var _loc2_:Number = mTop.scaleX;
         var _loc4_:Number = mTop.scaleY;
         var _loc16_:Number = mNametag.x + _loc14_ * (mTop.x + _loc2_ * mArt.x);
         var _loc19_:Number = mNametag.y + _loc10_ * (mTop.y + _loc4_ * mArt.y);
         var _loc6_:Number = root.x;
         var _loc8_:Number = root.y;
         var _loc5_:Number = root.scaleY;
         if(_loc15_ && mOverlays.isCulled(_loc6_,_loc8_ + _loc19_ * _loc5_))
         {
            _loc15_ = false;
         }
         _loc13_.tag.visible = _loc15_;
         if(!_loc15_)
         {
            return;
         }
         var _loc20_:Sprite = _loc13_.tag;
         _loc20_.x = _loc6_;
         _loc20_.y = _loc8_;
         _loc20_.scaleX = root.scaleX;
         _loc20_.scaleY = _loc5_;
         _loc20_.rotation = root.rotation * 0.017453292519943295;
         _loc20_.alpha = root.alpha * mNametag.alpha * mTop.alpha * mArt.alpha;
         var _loc3_:Sprite = _loc13_.art;
         _loc3_.x = _loc16_;
         _loc3_.y = _loc19_;
         _loc3_.scaleX = _loc14_ * _loc2_ * mArt.scaleX;
         _loc3_.scaleY = _loc10_ * _loc4_ * mArt.scaleY;
         if(mSlowCountdown == 15)
         {
            layoutSlow(_loc13_);
         }
         mArtX = _loc16_;
         mArtY = _loc19_;
         _loc13_.bar.visible = mBarShown && (mUnderPart.drawn || mFillPart.drawn);
         if(_loc13_.bar.visible && mFillPart.drawn)
         {
            _loc17_ = mFill.x;
            var _loc18_:Number = mFill.y;
            var _loc9_:Number = mFill.scaleX;
            var _loc11_:Number = mFill.scaleY;
            _loc12_ = mFill.parent;
            while(_loc12_ != null && _loc12_ != mHp)
            {
               _loc17_ = _loc12_.x + _loc12_.scaleX * _loc17_;
               _loc18_ = _loc12_.y + _loc12_.scaleY * _loc18_;
               _loc9_ *= _loc12_.scaleX;
               _loc11_ *= _loc12_.scaleY;
               _loc12_ = _loc12_.parent;
            }
            _loc7_ = _loc13_.fill;
            _loc7_.x = _loc17_;
            _loc7_.y = _loc18_;
            _loc7_.scaleX = _loc9_;
            _loc7_.scaleY = _loc11_;
         }
      }
      
      internal function snapToScreen(pixelSize:Number) : void
      {
         var _loc2_:BakedImage = mView.name.visible && mNamePart.current ? mView.name : (mView.afk.visible && mAfkPart.current ? mView.afk : null);
         mView.snapToScreen(mOverlays.snapPixelsPerUnit > 0 ? _loc2_ : null,pixelSize,mArtX,mArtY,mOverlays.cameraOffsetX,mOverlays.cameraOffsetY);
      }
      
      private function layoutSlow(view:TagView) : void
      {
         mNameX = mName.x - mNameShiftX * mName.scaleX;
         mNameY = mName.y - mNameShiftY * mName.scaleY;
         mAfkX = mAfk.x - mAfkShiftX * mAfk.scaleX;
         mAfkY = mAfk.y - mAfkShiftY * mAfk.scaleY;
         placeImage(view.name,mName,mNameX,mNameY);
         placeImage(view.afk,mAfk,mAfkX,mAfkY);
         var _loc2_:Sprite = view.bar;
         _loc2_.x = mHp.x;
         _loc2_.y = mHp.y;
         _loc2_.scaleX = mHp.scaleX;
         _loc2_.scaleY = mHp.scaleY;
         _loc2_.alpha = mHp.alpha;
      }
      
      private function measureShift(field:TextField, isName:Boolean) : void
      {
         var _loc4_:Rectangle = null;
         var _loc3_:Rectangle = field.getBounds(field);
         var _loc5_:Number = 0;
         var _loc6_:Number = 0;
         if(field.parent != null && field.scaleX != 0 && field.scaleY != 0)
         {
            _loc4_ = field.getBounds(field.parent);
            _loc5_ = _loc3_.x - (_loc4_.x - field.x) / field.scaleX;
            _loc6_ = _loc3_.y - (_loc4_.y - field.y) / field.scaleY;
         }
         if(isName)
         {
            mNameShiftX = _loc5_;
            mNameShiftY = _loc6_;
         }
         else
         {
            mAfkShiftX = _loc5_;
            mAfkShiftY = _loc6_;
         }
      }
      
      private function chainScale(node:DisplayObject) : Number
      {
         var _loc4_:DisplayObject = null;
         var _loc2_:DisplayObject = mNametag.parent;
         var _loc3_:Number = 1;
         _loc4_ = node;
         while(_loc4_ != null)
         {
            _loc3_ *= Math.abs(_loc4_.scaleY);
            if(_loc4_ == _loc2_)
            {
               break;
            }
            _loc4_ = _loc4_.parent;
         }
         return _loc3_;
      }
   }
}

