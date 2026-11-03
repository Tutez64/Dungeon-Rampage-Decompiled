package UI.Hud.StarlingConverted
{
   import Brain.Starling.SwfConverter.BakedImage;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import starling.display.DisplayObject;
   import starling.display.DisplayObjectContainer;
   import starling.display.Mesh;
   
   public class StarlingButton
   {
      
      private var mRoot:DisplayObject;
      
      private var mSpace:DisplayObject;
      
      private var mStates:Vector.<DisplayObject> = new Vector.<DisplayObject>(0);
      
      private var mHit:DisplayObject;
      
      private var mLabel:DisplayObject;
      
      private var mEnabled:Boolean = true;
      
      private var mHovered:Boolean = false;
      
      private var mPressed:Boolean = false;
      
      private var mPressHandedToGame:Boolean;
      
      private var mUpOnly:Boolean;
      
      private var mPressCallback:Function;
      
      private var mReleaseCallback:Function;
      
      private var mRollOverCallback:Function;
      
      private var mRollOutCallback:Function;
      
      private var mPressRollOutCallback:Function;
      
      private var mMatrix:Matrix = new Matrix();
      
      private var mLeafBounds:Rectangle = new Rectangle();
      
      public function StarlingButton(view:ArtView, path:String = "", designSpace:DisplayObject = null)
      {
         super();
         mRoot = view.node(path);
         var _loc4_:String = path.length > 0 ? path + "." : "";
         var _loc6_:DisplayObject = view.node(_loc4_ + "theButton");
         if(_loc6_ != null)
         {
            mRoot = _loc6_;
            _loc4_ += "theButton.";
         }
         mSpace = designSpace;
         var _loc5_:DisplayObject = view.node(_loc4_ + "up");
         mStates.push(_loc5_);
         mStates.push(view.node(_loc4_ + "over") || _loc5_);
         mStates.push(view.node(_loc4_ + "down") || _loc5_);
         mStates.push(view.node(_loc4_ + "disabled") || _loc5_);
         mStates.push(view.node(_loc4_ + "selected") || _loc5_);
         mHit = view.node(_loc4_ + "hit");
         mLabel = view.node(_loc4_ + "label");
         if(mHit is ArtDisplay)
         {
            ArtDisplay(mHit).setHudVisibility(false);
         }
         else if(mHit != null)
         {
            mHit.visible = false;
         }
         refresh();
      }
      
      private function refresh() : void
      {
         var _loc2_:int = 0;
         var _loc3_:int = mUpOnly ? 0 : (!mEnabled ? 3 : (mPressed && mHovered ? 2 : (mHovered ? 1 : 0)));
         var _loc1_:DisplayObject = mStates[_loc3_];
         _loc2_ = 0;
         while(_loc2_ < mStates.length)
         {
            if(mStates[_loc2_] != null)
            {
               if(mStates[_loc2_] is ArtDisplay)
               {
                  ArtDisplay(mStates[_loc2_]).setHudVisibility(false);
               }
               else
               {
                  mStates[_loc2_].visible = false;
               }
               animate(mStates[_loc2_],false);
            }
            _loc2_++;
         }
         if(_loc1_ != null)
         {
            if(_loc1_ is ArtDisplay)
            {
               ArtDisplay(_loc1_).setHudVisibility(true);
            }
            else
            {
               _loc1_.visible = true;
            }
            animate(_loc1_,true);
         }
      }
      
      private function animate(display:DisplayObject, play:Boolean) : void
      {
         var _loc4_:int = 0;
         var _loc3_:DisplayObjectContainer = display as DisplayObjectContainer;
         if(display is TimelineView)
         {
            if(play)
            {
               TimelineView(display).play(0,true);
            }
            else
            {
               TimelineView(display).stop();
            }
            return;
         }
         if(_loc3_ != null)
         {
            _loc4_ = 0;
            while(_loc4_ < _loc3_.numChildren)
            {
               animate(_loc3_.getChildAt(_loc4_),play);
               _loc4_++;
            }
         }
      }
      
      public function hitTest(designX:Number, designY:Number) : Boolean
      {
         if(!mEnabled || !showing)
         {
            return false;
         }
         return hit(mHit ?? mRoot,designX,designY,mHit != null);
      }
      
      internal function get showing() : Boolean
      {
         var _loc1_:DisplayObject = mRoot;
         while(_loc1_ != null)
         {
            if(!_loc1_.visible || _loc1_.scaleX == 0 || _loc1_.scaleY == 0)
            {
               return false;
            }
            _loc1_ = _loc1_.parent;
         }
         return mRoot != null && mRoot.stage != null;
      }
      
      private function hit(display:DisplayObject, x:Number, y:Number, ignoreVisibility:Boolean) : Boolean
      {
         var _loc8_:int = 0;
         if(!ignoreVisibility && !display.visible)
         {
            return false;
         }
         if(display == mLabel)
         {
            return false;
         }
         var _loc7_:ArtDisplay = display as ArtDisplay;
         if(_loc7_ != null && _loc7_.art.hitCell != null && !_loc7_.art.hitCell.isEmpty)
         {
            display.getTransformationMatrix(mSpace,mMatrix);
            mMatrix.invert();
            return _loc7_.art.hitCell.opaqueAt(mMatrix.a * x + mMatrix.c * y + mMatrix.tx + _loc7_.art.hitCell.pivotX,mMatrix.b * x + mMatrix.d * y + mMatrix.ty + _loc7_.art.hitCell.pivotY,0);
         }
         if(_loc7_ != null && _loc7_.art.kind == "text")
         {
            display.getTransformationMatrix(mSpace,mMatrix);
            mMatrix.invert();
            return _loc7_.art.textBounds.contains(mMatrix.a * x + mMatrix.c * y + mMatrix.tx,mMatrix.b * x + mMatrix.d * y + mMatrix.ty);
         }
         var _loc6_:BakedImage = display as BakedImage;
         var _loc5_:DisplayObjectContainer = display as DisplayObjectContainer;
         if(_loc6_ != null && _loc6_.cell != null)
         {
            display.getTransformationMatrix(mSpace,mMatrix);
            mMatrix.invert();
            return _loc6_.cell.opaqueAt(mMatrix.a * x + mMatrix.c * y + mMatrix.tx,mMatrix.b * x + mMatrix.d * y + mMatrix.ty,0);
         }
         var _loc9_:Mesh = display as Mesh;
         if(_loc6_ == null && _loc9_ != null && _loc9_.texture != null)
         {
            display.getTransformationMatrix(mSpace,mMatrix);
            mMatrix.invert();
            _loc9_.getBounds(_loc9_,mLeafBounds);
            return mLeafBounds.contains(mMatrix.a * x + mMatrix.c * y + mMatrix.tx,mMatrix.b * x + mMatrix.d * y + mMatrix.ty);
         }
         if(_loc5_ != null)
         {
            _loc8_ = _loc5_.numChildren - 1;
            while(_loc8_ >= 0)
            {
               if(hit(_loc5_.getChildAt(_loc8_),x,y,ignoreVisibility))
               {
                  return true;
               }
               _loc8_--;
            }
         }
         return false;
      }
      
      public function setHover(value:Boolean) : void
      {
         mHovered = value;
         refresh();
      }
      
      public function setPressed(value:Boolean) : void
      {
         mPressed = value;
         refresh();
      }
      
      internal function restartState() : void
      {
         refresh();
      }
      
      public function onMouseDown() : void
      {
         if(!mEnabled || !visible)
         {
            return;
         }
         mPressHandedToGame = false;
         if(!mHovered)
         {
            onRollOver();
         }
         setPressed(true);
         if(mPressCallback != null)
         {
            mPressCallback();
         }
      }
      
      public function onMouseUp(inside:Boolean) : void
      {
         var _loc2_:Boolean = mPressed;
         mHovered = inside;
         setPressed(false);
         if(_loc2_ && mEnabled && inside && mReleaseCallback != null)
         {
            mReleaseCallback();
         }
      }
      
      public function onRollOver() : void
      {
         if(!mEnabled || mHovered)
         {
            return;
         }
         setHover(true);
         if(mRollOverCallback != null)
         {
            mRollOverCallback();
         }
      }
      
      public function onRollOut() : void
      {
         if(!mHovered)
         {
            return;
         }
         if(mPressed && mPressRollOutCallback != null)
         {
            mPressRollOutCallback();
         }
         setHover(false);
         if(mRollOutCallback != null)
         {
            mRollOutCallback();
         }
      }
      
      public function get enabled() : Boolean
      {
         return mEnabled;
      }
      
      public function set upOnly(value:Boolean) : void
      {
         mUpOnly = value;
         refresh();
      }
      
      public function clearStateArt() : void
      {
         var _loc1_:DisplayObject = null;
         for each(_loc1_ in mStates)
         {
            if(_loc1_ != null)
            {
               animate(_loc1_,false);
               if(_loc1_ is ArtDisplay)
               {
                  ArtDisplay(_loc1_).setHudVisibility(false);
               }
               else
               {
                  _loc1_.visible = false;
               }
            }
         }
         mStates.length = 0;
         mStates.length = 5;
         mHit = null;
      }
      
      public function set enabled(value:Boolean) : void
      {
         mEnabled = value;
         if(!value)
         {
            mPressed = false;
            mHovered = false;
         }
         refresh();
      }
      
      public function get visible() : Boolean
      {
         return mRoot.visible;
      }
      
      public function set visible(value:Boolean) : void
      {
         mRoot.visible = value;
      }
      
      public function get root() : DisplayObject
      {
         return mRoot;
      }
      
      internal function handPressToGame() : void
      {
         mPressHandedToGame = true;
      }
      
      internal function get pressHandedToGame() : Boolean
      {
         return mPressHandedToGame;
      }
      
      public function set pressCallback(value:Function) : void
      {
         mPressCallback = value;
      }
      
      public function set releaseCallback(value:Function) : void
      {
         mReleaseCallback = value;
      }
      
      public function set rollOverCallback(value:Function) : void
      {
         mRollOverCallback = value;
      }
      
      public function set rollOutCallback(value:Function) : void
      {
         mRollOutCallback = value;
      }
      
      public function set pressRollOutCallback(value:Function) : void
      {
         mPressRollOutCallback = value;
      }
      
      public function dispose() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < mStates.length)
         {
            if(mStates[_loc1_] != null)
            {
               animate(mStates[_loc1_],false);
            }
            _loc1_++;
         }
         mPressCallback = mReleaseCallback = mRollOverCallback = mRollOutCallback = mPressRollOutCallback = null;
      }
   }
}

