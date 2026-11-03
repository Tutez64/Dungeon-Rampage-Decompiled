package Brain.Starling
{
   import flash.geom.Matrix;
   import starling.display.DisplayObject;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.rendering.Painter;
   import starling.utils.MeshSubset;
   
   public class StarlingLayer extends Sprite
   {
      
      public static var propsCulledLastFrame:int = 0;
      
      public static var bakedMeshes:int = 0;
      
      public static var bakedBatches:int = 0;
      
      public static var bakeRebuilds:int = 0;
      
      internal static const BAKE_IMAGE_SHOWN:int = 1;
      
      internal static const BAKE_VIEW_SHOWN:int = 2;
      
      internal static const BAKE_SPRITE_CHANGED:int = 3;
      
      public static var bakeWhyImageShown:int = 0;
      
      public static var bakeWhyViewShown:int = 0;
      
      public static var bakeWhySpriteChange:int = 0;
      
      public static var bakeWhyOrder:int = 0;
      
      public static var bakeWhyRemove:int = 0;
      
      public static var bakeWhyMerge:int = 0;
      
      public static var bakeWhyAdd:int = 0;
      
      public static var bakeWhyConsolidate:int = 0;
      
      public static var bakeFull:int = 0;
      
      public static var bakeRunsRebuilt:int = 0;
      
      public static var bakeSlotWrites:int = 0;
      
      private static const CONSOLIDATE_FRAMES:int = 30;
      
      private static const sViewMatrix:Matrix = new Matrix();
      
      private static const sMeshMatrix:Matrix = new Matrix();
      
      private static const sZeroMatrix:Matrix = new Matrix(0,0,0,0,0,0);
      
      private static const sImageSubset:MeshSubset = new MeshSubset();
      
      protected var sortEveryFrame:Boolean = false;
      
      protected var ignoreDirtyFlag:Boolean = true;
      
      protected var dirty:Boolean = false;
      
      protected var sortFunction:Function;
      
      protected var mSortIndex:int;
      
      protected var mScreenSpace:Boolean = false;
      
      private var mBakeStaticImages:Boolean = false;
      
      private var mBaked:Boolean = false;
      
      private var mFullBakeDue:Boolean = false;
      
      private var mOrderChanged:Boolean = false;
      
      private var mAnyViolated:Boolean = false;
      
      private var mNewStatics:Boolean = false;
      
      private var mQuietFrames:int = 0;
      
      private var mLayerBlend:String = "normal";
      
      private const mRuns:Vector.<StarlingBakedRun> = new Vector.<StarlingBakedRun>(0);
      
      private const mRunPool:Vector.<StarlingBakedRun> = new Vector.<StarlingBakedRun>(0);
      
      private const mQueue:Vector.<StarlingScenerySprite> = new Vector.<StarlingScenerySprite>(0);
      
      private const mRanges:Vector.<int> = new Vector.<int>(0);
      
      private const mMaskCandidates:Vector.<StarlingScenerySprite> = new Vector.<StarlingScenerySprite>(0);
      
      public function StarlingLayer(inSortIndex:int, inName:String, inBlendMode:String, inSortEveryFrame:Boolean = false, inCustomSortFunction:Function = null, inScreenSpace:Boolean = false)
      {
         super();
         mSortIndex = inSortIndex;
         mScreenSpace = inScreenSpace;
         blendMode = inBlendMode;
         if(inCustomSortFunction == null)
         {
            ignoreDirtyFlag = false;
            sortFunction = StarlingLayer.compareByY;
         }
         else
         {
            sortFunction = inCustomSortFunction;
         }
         sortEveryFrame = inSortEveryFrame;
         touchable = false;
         name = "StarlingLayer_" + inName;
      }
      
      public static function bakeStats() : Object
      {
         return {
            "meshes":bakedMeshes,
            "batches":bakedBatches,
            "passes":bakeRebuilds,
            "full":bakeFull,
            "runsRebuilt":bakeRunsRebuilt,
            "slotWrites":bakeSlotWrites,
            "imageShown":bakeWhyImageShown,
            "viewShown":bakeWhyViewShown,
            "spriteChange":bakeWhySpriteChange,
            "order":bakeWhyOrder,
            "remove":bakeWhyRemove,
            "merge":bakeWhyMerge,
            "add":bakeWhyAdd,
            "consolidate":bakeWhyConsolidate
         };
      }
      
      public static function compareByY(a:DisplayObject, b:DisplayObject) : int
      {
         if(a.y < b.y)
         {
            return -1;
         }
         if(a.y > b.y)
         {
            return 1;
         }
         if(a.x > b.x)
         {
            return -1;
         }
         if(a.x < b.x)
         {
            return 1;
         }
         if(a.height > b.height)
         {
            return -1;
         }
         if(a.height < b.height)
         {
            return 1;
         }
         return 0;
      }
      
      public function get bakeStaticImages() : Boolean
      {
         return mBakeStaticImages;
      }
      
      public function set bakeStaticImages(value:Boolean) : void
      {
         if(mBakeStaticImages == value)
         {
            return;
         }
         mBakeStaticImages = value;
         if(!value)
         {
            unbake();
         }
         setRequiresRedraw();
      }
      
      public function markDirty() : void
      {
         if(ignoreDirtyFlag)
         {
            dirty = true;
         }
      }
      
      public function clean() : void
      {
         unbake();
         removeChildren(0,numChildren - 1,true);
      }
      
      public function evaluateFrameLayerUpdate(inMatrix:Matrix) : void
      {
         if(!mScreenSpace)
         {
            transformationMatrix = inMatrix;
         }
         if(sortEveryFrame || dirty)
         {
            sortLayer(sortFunction);
            dirty = false;
         }
      }
      
      private function cullScenerySprites() : void
      {
         var _loc13_:int = 0;
         var _loc3_:Number = NaN;
         var _loc5_:Number = NaN;
         var _loc10_:Number = NaN;
         var _loc11_:Number = NaN;
         var _loc8_:int = 0;
         var _loc16_:StarlingScenerySprite = null;
         var _loc1_:Boolean = false;
         var _loc6_:int = numChildren;
         if(_loc6_ == 0)
         {
            return;
         }
         getTransformationMatrix(stage,sViewMatrix);
         sViewMatrix.invert();
         var _loc15_:Number = stage.stageWidth;
         var _loc7_:Number = stage.stageHeight;
         var _loc14_:Number = Infinity;
         var _loc12_:Number = Infinity;
         var _loc9_:Number = -Infinity;
         var _loc4_:Number = -Infinity;
         _loc13_ = 0;
         while(_loc13_ < 4)
         {
            _loc3_ = _loc13_ & 1 ? _loc15_ : 0;
            _loc5_ = _loc13_ & 2 ? _loc7_ : 0;
            _loc10_ = sViewMatrix.a * _loc3_ + sViewMatrix.c * _loc5_ + sViewMatrix.tx;
            _loc11_ = sViewMatrix.b * _loc3_ + sViewMatrix.d * _loc5_ + sViewMatrix.ty;
            if(_loc10_ < _loc14_)
            {
               _loc14_ = _loc10_;
            }
            if(_loc10_ > _loc9_)
            {
               _loc9_ = _loc10_;
            }
            if(_loc11_ < _loc12_)
            {
               _loc12_ = _loc11_;
            }
            if(_loc11_ > _loc4_)
            {
               _loc4_ = _loc11_;
            }
            _loc13_++;
         }
         var _loc2_:int = 0;
         _loc8_ = 0;
         while(_loc8_ < _loc6_)
         {
            _loc16_ = getChildAt(_loc8_) as StarlingScenerySprite;
            if(!(_loc16_ == null || _loc16_.isMember && !_loc16_.isLead))
            {
               _loc1_ = !_loc16_.overlaps(_loc14_,_loc12_,_loc9_,_loc4_);
               _loc16_.setCulled(_loc1_);
               if(_loc1_)
               {
                  _loc2_++;
               }
            }
            _loc8_++;
         }
         propsCulledLastFrame += _loc2_;
      }
      
      override public function render(painter:Painter) : void
      {
         if(bakeStaticImages || !mScreenSpace)
         {
            painter.excludeFromCache(this);
         }
         if(bakeStaticImages)
         {
            updateBake(painter);
         }
         if(!mScreenSpace && stage != null)
         {
            cullScenerySprites();
         }
         super.render(painter);
      }
      
      private function updateBake(painter:Painter) : void
      {
         var _loc2_:int = 0;
         var _loc4_:StarlingBakedRun = null;
         var _loc5_:int = 0;
         var _loc3_:StarlingScenerySprite = null;
         recheckMaskCandidates();
         _loc2_ = 0;
         while(_loc2_ < mRuns.length)
         {
            _loc4_ = mRuns[_loc2_];
            _loc5_ = 0;
            while(_loc5_ < _loc4_.members.length)
            {
               _loc3_ = _loc4_.members[_loc5_];
               if(_loc3_.run == _loc4_)
               {
                  if(_loc3_.bakeImage != _loc3_.slotImage || !_loc4_.batch.style.canBatchWith(_loc3_.slotImage.style))
                  {
                     trackMaskCandidate(_loc3_);
                     violate(_loc4_);
                  }
               }
               _loc5_++;
            }
            _loc2_++;
         }
         if(mLayerBlend != painter.state.blendMode)
         {
            mFullBakeDue = true;
         }
         mLayerBlend = painter.state.blendMode;
         if(!mBaked || mFullBakeDue)
         {
            fullBake();
            return;
         }
         if(mQueue.length > 0)
         {
            applyQueue();
         }
         if(mOrderChanged || mAnyViolated)
         {
            checkOrder();
         }
         if(mAnyViolated)
         {
            rebuildViolated();
            mQuietFrames = 0;
         }
         else if(mNewStatics && ++mQuietFrames >= 30)
         {
            bakeWhyConsolidate = bakeWhyConsolidate + 1;
            fullBake();
         }
      }
      
      private function trackMaskCandidate(sprite:StarlingScenerySprite) : void
      {
         if(sprite != null && sprite.hasMaskRole && mMaskCandidates.indexOf(sprite) < 0)
         {
            mMaskCandidates.push(sprite);
         }
      }
      
      private function recheckMaskCandidates() : void
      {
         var _loc2_:int = 0;
         var _loc1_:StarlingScenerySprite = null;
         _loc2_ = mMaskCandidates.length - 1;
         while(_loc2_ >= 0)
         {
            _loc1_ = mMaskCandidates[_loc2_];
            if(!(_loc1_.parent == this && _loc1_.hasMaskRole))
            {
               mMaskCandidates.splice(_loc2_,1);
               if(_loc1_.parent == this)
               {
                  _loc1_.maskRoleCleared();
               }
            }
            _loc2_--;
         }
      }
      
      private function fullBake() : void
      {
         releaseRuns();
         clearQueue();
         mMaskCandidates.length = 0;
         bakeSpan(0,numChildren - 1);
         mBaked = true;
         mFullBakeDue = false;
         mOrderChanged = false;
         mAnyViolated = false;
         mNewStatics = false;
         mQuietFrames = 0;
         bakeFull = bakeFull + 1;
         bakeRebuilds = bakeRebuilds + 1;
      }
      
      private function bakeSpan(first:int, last:int) : void
      {
         var _loc6_:int = 0;
         var _loc5_:StarlingScenerySprite = null;
         var _loc3_:Image = null;
         var _loc4_:String = null;
         var _loc7_:StarlingBakedRun = null;
         _loc6_ = first;
         for(; _loc6_ <= last; _loc6_++)
         {
            _loc5_ = getChildAt(_loc6_) as StarlingScenerySprite;
            _loc3_ = _loc5_ != null && !_loc5_.isMember ? _loc5_.bakeImage : null;
            if(_loc3_ == null)
            {
               trackMaskCandidate(_loc5_);
               _loc7_ = closeRun(_loc7_);
            }
            else
            {
               _loc4_ = _loc3_.blendMode != "auto" ? _loc3_.blendMode : (_loc5_.blendMode != "auto" ? _loc5_.blendMode : mLayerBlend);
               if(_loc7_ == null || _loc4_ != _loc7_.batch.blendMode || !_loc7_.batch.canAddMesh(_loc3_))
               {
                  _loc7_ = closeRun(_loc7_);
                  if(!_loc5_.canLead)
                  {
                     continue;
                  }
                  _loc7_ = openRun(_loc5_,_loc4_);
               }
               _loc5_.joinRun(_loc7_,_loc7_.members.length,_loc3_);
               _loc7_.members.push(_loc5_);
               writeSlot(_loc7_,_loc5_);
            }
         }
         closeRun(_loc7_);
      }
      
      private function openRun(lead:StarlingScenerySprite, blend:String) : StarlingBakedRun
      {
         var _loc3_:StarlingBakedRun = mRunPool.length > 0 ? mRunPool.pop() : new StarlingBakedRun();
         _loc3_.lead = lead;
         _loc3_.batch.blendMode = blend;
         _loc3_.leadInverse.copyFrom(lead.transformationMatrix);
         _loc3_.leadInverse.invert();
         mRuns.push(_loc3_);
         return _loc3_;
      }
      
      private function closeRun(run:StarlingBakedRun) : StarlingBakedRun
      {
         if(run == null)
         {
            return null;
         }
         if(run.members.length == 1)
         {
            releaseRun(run,mRuns.lastIndexOf(run));
         }
         else
         {
            bakedBatches = bakedBatches + 1;
            bakedMeshes += run.members.length;
         }
         return null;
      }
      
      private function releaseRun(run:StarlingBakedRun, index:int) : void
      {
         var _loc4_:int = 0;
         var _loc3_:StarlingScenerySprite = null;
         _loc4_ = 0;
         while(_loc4_ < run.members.length)
         {
            _loc3_ = run.members[_loc4_];
            if(_loc3_.run == run)
            {
               _loc3_.leaveRun();
            }
            _loc4_++;
         }
         if(run.members.length > 1)
         {
            bakedBatches = bakedBatches - 1;
            bakedMeshes -= run.members.length;
         }
         run.clear();
         mRuns[index] = mRuns[mRuns.length - 1];
         mRuns.length--;
         mRunPool.push(run);
      }
      
      private function releaseRuns() : void
      {
         var _loc1_:int = 0;
         _loc1_ = mRuns.length - 1;
         while(_loc1_ >= 0)
         {
            releaseRun(mRuns[_loc1_],_loc1_);
            _loc1_--;
         }
      }
      
      private function writeSlot(run:StarlingBakedRun, sprite:StarlingScenerySprite) : void
      {
         var _loc3_:Image = sprite.slotImage;
         var _loc5_:int = sprite.slot * 4;
         var _loc7_:int = sprite.slot * 6;
         var _loc4_:Boolean = sprite.bakeShown;
         if(_loc4_ != sprite.slotShown)
         {
            run.shownCount += _loc4_ ? 1 : -1;
            sprite.slotShown = _loc4_;
         }
         sImageSubset.setTo(0,_loc3_.numVertices,0,_loc3_.numIndices);
         if(!_loc4_)
         {
            run.batch.addMeshAt(_loc3_,_loc7_,_loc5_,sZeroMatrix,1,sImageSubset);
            return;
         }
         sMeshMatrix.copyFrom(_loc3_.transformationMatrix);
         sMeshMatrix.concat(sprite.transformationMatrix);
         sMeshMatrix.concat(run.leadInverse);
         var _loc6_:Number = sprite.alpha * _loc3_.alpha;
         run.batch.addMeshAt(_loc3_,_loc7_,_loc5_,sMeshMatrix,_loc6_,sImageSubset);
      }
      
      internal function queueBake(sprite:StarlingScenerySprite, reason:int) : void
      {
         if(!bakeStaticImages)
         {
            return;
         }
         if(!sprite.isMember)
         {
            if(sprite.bakeImage != null)
            {
               mNewStatics = true;
            }
            return;
         }
         if(reason == 1)
         {
            bakeWhyImageShown = bakeWhyImageShown + 1;
         }
         else if(reason == 2)
         {
            bakeWhyViewShown = bakeWhyViewShown + 1;
         }
         else
         {
            sprite.bakeShownOnly = false;
         }
         if(sprite.bakeQueued)
         {
            return;
         }
         sprite.bakeQueued = true;
         mQueue.push(sprite);
      }
      
      private function applyQueue() : void
      {
         var _loc2_:int = 0;
         var _loc1_:StarlingScenerySprite = null;
         var _loc3_:StarlingBakedRun = null;
         var _loc4_:Boolean = false;
         _loc2_ = 0;
         while(_loc2_ < mQueue.length)
         {
            _loc1_ = mQueue[_loc2_];
            _loc3_ = _loc1_.run;
            _loc4_ = _loc1_.bakeShownOnly;
            _loc1_.bakeQueued = false;
            _loc1_.bakeShownOnly = true;
            if(!(_loc3_ == null || _loc3_.violated || _loc1_.parent != this))
            {
               if(_loc4_ && _loc1_.bakeImage == _loc1_.slotImage && (!_loc1_.isLead || _loc1_.canLead))
               {
                  writeSlot(_loc3_,_loc1_);
                  bakeSlotWrites = bakeSlotWrites + 1;
               }
               else
               {
                  bakeWhySpriteChange = bakeWhySpriteChange + 1;
                  violate(_loc3_);
               }
            }
            _loc2_++;
         }
         mQueue.length = 0;
      }
      
      private function clearQueue() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < mQueue.length)
         {
            mQueue[_loc1_].bakeQueued = false;
            mQueue[_loc1_].bakeShownOnly = true;
            _loc1_++;
         }
         mQueue.length = 0;
      }
      
      private function violate(run:StarlingBakedRun) : void
      {
         run.violated = true;
         mAnyViolated = true;
      }
      
      private function checkOrder() : void
      {
         var _loc5_:StarlingBakedRun = null;
         var _loc1_:int = 0;
         var _loc4_:int = 0;
         var _loc3_:StarlingScenerySprite = null;
         var _loc6_:int = int(mRuns.length);
         _loc1_ = 0;
         while(_loc1_ < _loc6_)
         {
            _loc5_ = mRuns[_loc1_];
            _loc5_.first = -1;
            _loc5_.last = -1;
            _loc5_.seen = 0;
            _loc1_++;
         }
         var _loc8_:StarlingBakedRun = null;
         var _loc7_:StarlingBakedRun = null;
         var _loc2_:int = numChildren;
         _loc4_ = 0;
         while(_loc4_ < _loc2_)
         {
            _loc3_ = getChildAt(_loc4_) as StarlingScenerySprite;
            _loc5_ = _loc3_ != null ? _loc3_.run : null;
            if(_loc5_ != null)
            {
               if(_loc5_.first < 0)
               {
                  _loc5_.first = _loc4_;
               }
               _loc5_.last = _loc4_;
               if(_loc3_.slot != _loc5_.seen)
               {
                  violateByOrder(_loc5_);
               }
               if(_loc7_ != null && _loc3_.slot == 0)
               {
                  violateToMerge(_loc7_,_loc5_,_loc3_);
               }
               _loc5_.seen++;
               if(_loc8_ != null && _loc8_ != _loc5_)
               {
                  violateByOrder(_loc8_);
               }
               _loc8_ = _loc5_.seen < _loc5_.members.length ? _loc5_ : null;
               _loc7_ = _loc8_ == null ? _loc5_ : null;
            }
            else
            {
               if(_loc8_ != null)
               {
                  violateByOrder(_loc8_);
               }
               _loc7_ = null;
            }
            _loc4_++;
         }
         _loc1_ = 0;
         while(_loc1_ < _loc6_)
         {
            _loc5_ = mRuns[_loc1_];
            if(_loc5_.seen != _loc5_.members.length)
            {
               violateByOrder(_loc5_);
            }
            _loc1_++;
         }
         mOrderChanged = false;
      }
      
      private function violateToMerge(before:StarlingBakedRun, after:StarlingBakedRun, afterLead:StarlingScenerySprite) : void
      {
         if(before == after || before.violated || after.violated)
         {
            return;
         }
         if(before.batch.blendMode != after.batch.blendMode || !before.batch.canAddMesh(afterLead.slotImage))
         {
            return;
         }
         bakeWhyMerge = bakeWhyMerge + 1;
         violate(before);
         violate(after);
      }
      
      private function violateByOrder(run:StarlingBakedRun) : void
      {
         if(run.violated)
         {
            return;
         }
         bakeWhyOrder = bakeWhyOrder + 1;
         violate(run);
      }
      
      private function rebuildViolated() : void
      {
         var _loc2_:int = 0;
         var _loc3_:StarlingBakedRun = null;
         var _loc5_:int = 0;
         mRanges.length = 0;
         _loc2_ = mRuns.length - 1;
         while(_loc2_ >= 0)
         {
            _loc3_ = mRuns[_loc2_];
            if(_loc3_.violated)
            {
               if(_loc3_.first >= 0)
               {
                  addRange(_loc3_.first,_loc3_.last);
               }
               releaseRun(_loc3_,_loc2_);
               bakeRunsRebuilt = bakeRunsRebuilt + 1;
            }
            _loc2_--;
         }
         var _loc1_:int = -1;
         var _loc4_:int = -1;
         _loc5_ = 0;
         while(_loc5_ < mRanges.length)
         {
            if(_loc1_ < 0 || mRanges[_loc5_] > _loc4_ + 1)
            {
               if(_loc4_ >= 0)
               {
                  bakeSpan(_loc1_,_loc4_);
               }
               _loc1_ = mRanges[_loc5_];
               _loc4_ = mRanges[_loc5_ + 1];
            }
            else if(mRanges[_loc5_ + 1] > _loc4_)
            {
               _loc4_ = mRanges[_loc5_ + 1];
            }
            _loc5_ += 2;
         }
         if(_loc4_ >= 0)
         {
            bakeSpan(_loc1_,_loc4_);
         }
         mAnyViolated = false;
         bakeRebuilds = bakeRebuilds + 1;
      }
      
      private function addRange(first:int, last:int) : void
      {
         var _loc3_:int = int(mRanges.length);
         mRanges.length = _loc3_ + 2;
         while(_loc3_ > 0 && mRanges[_loc3_ - 2] > first)
         {
            mRanges[_loc3_] = mRanges[_loc3_ - 2];
            mRanges[_loc3_ + 1] = mRanges[_loc3_ - 1];
            _loc3_ -= 2;
         }
         mRanges[_loc3_] = first;
         mRanges[_loc3_ + 1] = last;
      }
      
      private function unbake() : void
      {
         var _loc1_:int = 0;
         recheckMaskCandidates();
         releaseRuns();
         clearQueue();
         _loc1_ = 0;
         while(_loc1_ < mRunPool.length)
         {
            mRunPool[_loc1_].dispose();
            _loc1_++;
         }
         mRunPool.length = 0;
         mMaskCandidates.length = 0;
         mBaked = false;
      }
      
      override public function dispose() : void
      {
         unbake();
         super.dispose();
      }
      
      private function sortLayer(compare:Function) : void
      {
         var _loc6_:DisplayObject = null;
         var _loc4_:* = 0;
         var _loc2_:int = numChildren;
         var _loc3_:int = 1;
         while(_loc3_ < _loc2_ && compare(getChildAt(_loc3_ - 1),getChildAt(_loc3_)) <= 0)
         {
            _loc3_++;
         }
         if(_loc3_ >= _loc2_)
         {
            return;
         }
         var _loc5_:int = _loc2_ * 2;
         while(_loc3_ < _loc2_)
         {
            _loc6_ = getChildAt(_loc3_);
            _loc4_ = _loc3_;
            while(_loc4_ > 0 && compare(getChildAt(_loc4_ - 1),_loc6_) > 0)
            {
               if(--_loc5_ < 0)
               {
                  sortChildren(compare);
                  return;
               }
               _loc4_--;
            }
            if(_loc4_ != _loc3_)
            {
               _loc5_ -= _loc2_;
               if(_loc5_ < 0)
               {
                  sortChildren(compare);
                  return;
               }
               setChildIndex(_loc6_,_loc4_);
            }
            _loc3_++;
         }
      }
      
      public function get sortIndex() : int
      {
         return mSortIndex;
      }
      
      public function get screenSpace() : Boolean
      {
         return mScreenSpace;
      }
      
      override public function addChild(child:DisplayObject) : DisplayObject
      {
         if(sortEveryFrame || ignoreDirtyFlag)
         {
            dirty = true;
         }
         return super.addChild(child);
      }
      
      override public function addChildAt(child:DisplayObject, index:int) : DisplayObject
      {
         var _loc4_:StarlingScenerySprite = null;
         if(sortEveryFrame || ignoreDirtyFlag)
         {
            dirty = true;
         }
         if(bakeStaticImages && child.parent != this)
         {
            bakeWhyAdd = bakeWhyAdd + 1;
            _loc4_ = child as StarlingScenerySprite;
            if(_loc4_ != null && _loc4_.bakeImage != null)
            {
               mNewStatics = true;
            }
            mQuietFrames = 0;
         }
         mOrderChanged = true;
         var _loc3_:DisplayObject = super.addChildAt(child,index);
         if(bakeStaticImages)
         {
            trackMaskCandidate(_loc3_ as StarlingScenerySprite);
         }
         return _loc3_;
      }
      
      override public function removeChildAt(index:int, dispose:Boolean = false) : DisplayObject
      {
         var _loc3_:int = 0;
         var _loc5_:StarlingScenerySprite = index >= 0 && index < numChildren ? getChildAt(index) as StarlingScenerySprite : null;
         var _loc4_:int = _loc5_ != null ? mMaskCandidates.indexOf(_loc5_) : -1;
         if(_loc4_ >= 0)
         {
            if(!_loc5_.hasMaskRole)
            {
               _loc5_.maskRoleCleared();
            }
            mMaskCandidates.splice(_loc4_,1);
         }
         if(_loc5_ != null && _loc5_.bakeQueued)
         {
            _loc3_ = mQueue.indexOf(_loc5_);
            if(_loc3_ >= 0)
            {
               mQueue.splice(_loc3_,1);
            }
            _loc5_.bakeQueued = false;
            _loc5_.bakeShownOnly = true;
         }
         if(_loc5_ != null && _loc5_.run != null)
         {
            if(!_loc5_.run.violated)
            {
               bakeWhyRemove = bakeWhyRemove + 1;
            }
            violate(_loc5_.run);
            _loc5_.leaveRun();
         }
         if(_loc5_ != null)
         {
            _loc5_.setCulled(false);
         }
         mQuietFrames = 0;
         mOrderChanged = true;
         return super.removeChildAt(index,dispose);
      }
      
      override public function setChildIndex(child:DisplayObject, index:int) : void
      {
         mOrderChanged = true;
         super.setChildIndex(child,index);
      }
      
      override public function swapChildrenAt(index1:int, index2:int) : void
      {
         mOrderChanged = true;
         super.swapChildrenAt(index1,index2);
      }
      
      override public function sortChildren(compareFunction:Function) : void
      {
         mOrderChanged = true;
         super.sortChildren(compareFunction);
      }
      
      public function destroy() : void
      {
         clean();
         parent.removeChild(this);
      }
   }
}

