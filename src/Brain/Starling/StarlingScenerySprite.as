package Brain.Starling
{
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import starling.display.DisplayObject;
   import starling.display.Image;
   import starling.display.MaskRole;
   import starling.display.MeshBatch;
   import starling.display.Sprite;
   import starling.rendering.Painter;
   
   public class StarlingScenerySprite extends Sprite
   {
      
      public static const CULL_MARGIN:Number = 256;
      
      private static const sBounds:Rectangle = new Rectangle();
      
      private var mBoundsValid:Boolean = false;
      
      private var mLeft:Number = 0;
      
      private var mTop:Number = 0;
      
      private var mRight:Number = 0;
      
      private var mBottom:Number = 0;
      
      private var mShown:Boolean = true;
      
      private var mCulled:Boolean = false;
      
      private var mRun:StarlingBakedRun;
      
      private var mSlot:int = 0;
      
      private var mSlotImage:Image;
      
      private var mQuiet:Boolean = false;
      
      internal var bakeQueued:Boolean = false;
      
      internal var bakeShownOnly:Boolean = true;
      
      internal var slotShown:Boolean = false;
      
      public function StarlingScenerySprite()
      {
         super();
      }
      
      private static function nearZero(value:Number) : Boolean
      {
         return value != 0 && value < 0.001 && value > -0.001;
      }
      
      protected function get cullReach() : Number
      {
         return 0;
      }
      
      internal function overlaps(left:Number, top:Number, right:Number, bottom:Number) : Boolean
      {
         if(filter != null)
         {
            return true;
         }
         if(numChildren == 1 && getChildAt(0).filter != null)
         {
            return true;
         }
         if(isLead)
         {
            return mRun.right >= left && mRun.left <= right && mRun.bottom >= top && mRun.top <= bottom;
         }
         if(!mBoundsValid || !(numChildren == 1 && getChildAt(0) is StarlingSceneryImage))
         {
            cacheBounds();
         }
         return mRight >= left && mLeft <= right && mBottom >= top && mTop <= bottom;
      }
      
      internal function setCulled(value:Boolean) : void
      {
         if(mCulled == value)
         {
            return;
         }
         mCulled = value;
         applyVisible();
      }
      
      private function cacheBounds() : void
      {
         getBounds(parent,sBounds);
         var _loc1_:Number = cullReach * Math.max(Math.abs(scaleX),Math.abs(scaleY));
         mLeft = Math.min(sBounds.left,x - _loc1_) - 256;
         mTop = Math.min(sBounds.top,y - _loc1_) - 256;
         mRight = Math.max(sBounds.right,x + _loc1_) + 256;
         mBottom = Math.max(sBounds.bottom,y + _loc1_) + 256;
         mBoundsValid = true;
      }
      
      internal function get bakeImage() : Image
      {
         if(numChildren != 1 || filter != null || mask != null || MaskRole.isMask(this) || nearZero(scaleX) || nearZero(scaleY))
         {
            return null;
         }
         var _loc2_:Matrix = transformationMatrix;
         var _loc3_:Number = _loc2_.a * _loc2_.d - _loc2_.b * _loc2_.c;
         if(_loc3_ == 0 || !isFinite(_loc3_))
         {
            return null;
         }
         var _loc1_:Image = getChildAt(0) as StarlingSceneryImage;
         if(_loc1_ == null || _loc1_.filter != null || _loc1_.mask != null || MaskRole.isMask(_loc1_) || _loc1_.pixelSnapping)
         {
            return null;
         }
         return _loc1_.numVertices == 4 && _loc1_.numIndices == 6 ? _loc1_ : null;
      }
      
      internal function get hasMaskRole() : Boolean
      {
         return MaskRole.isMask(this) || numChildren == 1 && MaskRole.isMask(getChildAt(0));
      }
      
      internal function maskRoleCleared() : void
      {
         setRequiresRedraw();
         if(numChildren == 1)
         {
            getChildAt(0).setRequiresRedraw();
         }
      }
      
      internal function get bakeShown() : Boolean
      {
         return mShown && alpha != 0 && scaleX != 0 && scaleY != 0 && mSlotImage.visible && mSlotImage.alpha != 0;
      }
      
      internal function get canLead() : Boolean
      {
         return alpha != 0 && scaleX != 0 && scaleY != 0;
      }
      
      internal function get run() : StarlingBakedRun
      {
         return mRun;
      }
      
      internal function get slot() : int
      {
         return mSlot;
      }
      
      internal function get slotImage() : Image
      {
         return mSlotImage;
      }
      
      internal function get isLead() : Boolean
      {
         return mRun != null && mRun.lead == this;
      }
      
      internal function get isMember() : Boolean
      {
         return mRun != null;
      }
      
      internal function joinRun(run:StarlingBakedRun, slot:int, image:Image) : void
      {
         mRun = run;
         mSlot = slot;
         mSlotImage = image;
         slotShown = false;
         mCulled = false;
         if(!mBoundsValid)
         {
            cacheBounds();
         }
         if(run.lead == this)
         {
            run.left = mLeft;
            run.top = mTop;
            run.right = mRight;
            run.bottom = mBottom;
         }
         else
         {
            if(mLeft < run.left)
            {
               run.left = mLeft;
            }
            if(mTop < run.top)
            {
               run.top = mTop;
            }
            if(mRight > run.right)
            {
               run.right = mRight;
            }
            if(mBottom > run.bottom)
            {
               run.bottom = mBottom;
            }
         }
         applyVisible();
      }
      
      internal function leaveRun() : void
      {
         if(mRun == null)
         {
            return;
         }
         mRun = null;
         mSlotImage = null;
         mCulled = false;
         applyVisible();
      }
      
      private function queueBake(reason:int) : void
      {
         var _loc2_:StarlingLayer = parent as StarlingLayer;
         if(_loc2_ != null)
         {
            _loc2_.queueBake(this,reason);
         }
      }
      
      internal function imageChanged(shownOnly:Boolean) : void
      {
         mBoundsValid = false;
         queueBake(shownOnly ? 1 : 3);
      }
      
      private function applyVisible() : void
      {
         mQuiet = true;
         super.visible = mRun != null ? mRun.lead == this && !mCulled : mShown && !mCulled;
         setRequiresRedraw();
         mQuiet = false;
      }
      
      override public function setRequiresRedraw() : void
      {
         mBoundsValid = false;
         super.setRequiresRedraw();
         if(!mQuiet)
         {
            queueBake(3);
         }
      }
      
      override public function render(painter:Painter) : void
      {
         if(!isLead || MaskRole.isMask(this))
         {
            super.render(painter);
            return;
         }
         painter.excludeFromCache(this);
         if(mRun.shownCount == 0)
         {
            return;
         }
         var _loc2_:MeshBatch = mRun.batch;
         painter.state.blendMode = _loc2_.blendMode;
         if(alpha != 1)
         {
            painter.state.alpha /= alpha;
         }
         _loc2_.render(painter);
      }
      
      override public function dispose() : void
      {
         if(mRun != null || parent is StarlingLayer)
         {
            removeFromParent();
         }
         super.dispose();
      }
      
      override public function get visible() : Boolean
      {
         return mShown;
      }
      
      override public function set visible(value:Boolean) : void
      {
         if(mShown == value)
         {
            return;
         }
         mShown = value;
         applyVisible();
         queueBake(2);
      }
      
      override public function set x(value:Number) : void
      {
         super.x = value;
         mBoundsValid = false;
      }
      
      override public function set y(value:Number) : void
      {
         super.y = value;
         mBoundsValid = false;
      }
      
      override public function set scaleX(value:Number) : void
      {
         super.scaleX = value;
         mBoundsValid = false;
      }
      
      override public function set scaleY(value:Number) : void
      {
         super.scaleY = value;
         mBoundsValid = false;
      }
      
      override public function set skewX(value:Number) : void
      {
         super.skewX = value;
         mBoundsValid = false;
      }
      
      override public function set skewY(value:Number) : void
      {
         super.skewY = value;
         mBoundsValid = false;
      }
      
      override public function set rotation(value:Number) : void
      {
         super.rotation = value;
         mBoundsValid = false;
      }
      
      override public function set pivotX(value:Number) : void
      {
         super.pivotX = value;
         mBoundsValid = false;
      }
      
      override public function set pivotY(value:Number) : void
      {
         super.pivotY = value;
         mBoundsValid = false;
      }
      
      override public function set transformationMatrix(matrix:Matrix) : void
      {
         super.transformationMatrix = matrix;
         mBoundsValid = false;
      }
      
      override public function addChildAt(child:DisplayObject, index:int) : DisplayObject
      {
         mBoundsValid = false;
         var _loc3_:DisplayObject = super.addChildAt(child,index);
         queueBake(3);
         return _loc3_;
      }
      
      override public function removeChildAt(index:int, dispose:Boolean = false) : DisplayObject
      {
         mBoundsValid = false;
         var _loc3_:DisplayObject = super.removeChildAt(index,dispose);
         queueBake(3);
         return _loc3_;
      }
   }
}

