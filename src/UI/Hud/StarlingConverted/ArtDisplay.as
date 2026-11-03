package UI.Hud.StarlingConverted
{
   import Brain.Starling.SwfConverter.BakedCell;
   import Brain.Starling.SwfConverter.BakedImage;
   import Brain.Starling.SwfConverter.BakedPages;
   import flash.geom.ColorTransform;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   import starling.core.starling_internal;
   import starling.display.DisplayObject;
   import starling.display.Quad;
   import starling.display.Sprite;
   import starling.styles.MeshStyle;
   
   use namespace starling_internal;
   
   public class ArtDisplay extends Sprite
   {
      
      private static var sClips:Dictionary = new Dictionary(true);
      
      protected var mArt:ArtNode;
      
      protected var mImage:BakedImage;
      
      protected var mChildren:Vector.<ArtDisplay> = new Vector.<ArtDisplay>(0);
      
      private var mRed:Number = 1;
      
      private var mGreen:Number = 1;
      
      private var mBlue:Number = 1;
      
      private var mOffsetRed:Number = 0;
      
      private var mOffsetGreen:Number = 0;
      
      private var mOffsetBlue:Number = 0;
      
      private var mLocalColor:ColorTransform;
      
      private var mHudVisibility:int = -1;
      
      protected var mGrayscale:Boolean;
      
      private var mCell:BakedCell;
      
      private var mHudOffsetX:Number = 0;
      
      private var mHudOffsetY:Number = 0;
      
      private var mColorStyle:StarlingColorStyle;
      
      private var mDefaultStyle:MeshStyle;
      
      internal var contentBoundsChanged:Function;
      
      private var mClip:Quad;
      
      internal var filterIndex:int = 0;
      
      public function ArtDisplay(art:ArtNode)
      {
         super();
         mArt = art;
         mLocalColor = art.colorTransform;
         name = art.name;
         transformationMatrix = art.matrix;
         alpha = art.alpha;
         visible = art.visible;
         blendMode = art.blendMode;
         touchable = false;
      }
      
      internal static function isClipMask(node:DisplayObject) : Boolean
      {
         return sClips[node] === true;
      }
      
      protected static function rgb(red:Number, green:Number, blue:Number) : uint
      {
         return int(Math.max(0,Math.min(1,red)) * 255) << 16 | int(Math.max(0,Math.min(1,green)) * 255) << 8 | int(Math.max(0,Math.min(1,blue)) * 255);
      }
      
      public function setHudVisibility(value:*) : void
      {
         mHudVisibility = value == null ? -1 : (value ? 1 : 0);
         if(mHudVisibility >= 0)
         {
            visible = mHudVisibility == 1;
         }
      }
      
      public function setHudOffset(x:Number, y:Number) : void
      {
         if(x == mHudOffsetX && y == mHudOffsetY)
         {
            return;
         }
         this.x += x - mHudOffsetX;
         this.y += y - mHudOffsetY;
         mHudOffsetX = x;
         mHudOffsetY = y;
         if(contentBoundsChanged != null)
         {
            contentBoundsChanged();
         }
      }
      
      internal function authoredMatrix(matrix:Matrix) : void
      {
         transformationMatrix = matrix;
         x += mHudOffsetX;
         y += mHudOffsetY;
      }
      
      internal function authoredVisibility(value:Boolean) : void
      {
         visible = mHudVisibility >= 0 ? mHudVisibility == 1 : value;
      }
      
      internal function addArt(child:ArtDisplay) : void
      {
         mChildren.push(child);
         addChild(child);
         if(contentBoundsChanged != null)
         {
            contentBoundsChanged();
         }
      }
      
      internal function prepareClip() : void
      {
         if(mClip != null || parent == null)
         {
            return;
         }
         mClip = new Quad(1,1);
         sClips[mClip] = true;
         mClip.touchable = false;
         parent.addChild(mClip);
         applyClip(mArt.parentClip);
      }
      
      internal function applyClip(rect:Rectangle) : void
      {
         if(mClip == null)
         {
            return;
         }
         if(rect == null)
         {
            mask = null;
            mClip.visible = false;
            return;
         }
         mClip.x = rect.x;
         mClip.y = rect.y;
         mClip.width = Math.max(0.001,rect.width);
         mClip.height = Math.max(0.001,rect.height);
         mClip.visible = true;
         mask = mClip;
      }
      
      internal function applyFilters(index:int) : void
      {
         if(index == filterIndex)
         {
            return;
         }
         filterIndex = index;
         refreshTextFilters();
      }
      
      internal function refreshTextFilters() : void
      {
         var _loc1_:ArtDisplay = null;
         for each(_loc1_ in mChildren)
         {
            _loc1_.refreshTextFilters();
         }
      }
      
      internal function prepareTextFilters() : void
      {
         var _loc1_:ArtDisplay = null;
         for each(_loc1_ in mChildren)
         {
            _loc1_.prepareTextFilters();
         }
      }
      
      internal function addArtAt(child:ArtDisplay, index:int) : void
      {
         mChildren.push(child);
         addChildAt(child,index);
         refreshColor();
         if(contentBoundsChanged != null)
         {
            contentBoundsChanged();
         }
      }
      
      internal function flashChild(index:int) : ArtDisplay
      {
         var _loc3_:ArtDisplay = null;
         var _loc2_:int = 0;
         _loc2_ = 0;
         while(_loc2_ < numChildren)
         {
            _loc3_ = getChildAt(_loc2_) as ArtDisplay;
            if(_loc3_ != null && _loc3_.art.name != "@graphics" && index-- == 0)
            {
               return _loc3_;
            }
            _loc2_++;
         }
         return null;
      }
      
      internal function addAtFlashDepth(child:DisplayObject, depth:int, track:Boolean = false) : void
      {
         var _loc5_:ArtDisplay = flashChild(depth);
         var _loc4_:int = _loc5_ != null ? getChildIndex(_loc5_) : numChildren;
         if(track)
         {
            addArtAt(child as ArtDisplay,_loc4_);
         }
         else
         {
            addChildAt(child,_loc4_);
         }
      }
      
      internal function removeArt(child:ArtDisplay) : void
      {
         var _loc2_:int = mChildren.indexOf(child);
         if(_loc2_ >= 0)
         {
            mChildren.removeAt(_loc2_);
         }
         child.removeFromParent();
         if(contentBoundsChanged != null)
         {
            contentBoundsChanged();
         }
      }
      
      internal function buildImages() : void
      {
         mImage = mArt.barFill && mArt.masked ? new StarlingBarImage() : new BakedImage();
         mColorStyle = new StarlingColorStyle();
         mDefaultStyle = mImage.style;
         addChild(mImage);
         showCells(mArt.cell);
      }
      
      protected function showCells(cell:BakedCell) : void
      {
         mCell = cell;
         mImage.cell = mGrayscale ? HudArtConverter.grayCell(cell) : cell;
         mImage.visible = cell != null && !cell.isEmpty;
         refreshColor();
      }
      
      internal function setGrayscale(value:Boolean) : Boolean
      {
         var _loc4_:ArtFrame = null;
         var _loc5_:ArtDisplay = null;
         var _loc3_:Boolean = true;
         var _loc2_:BakedPages = mArt.lease != null ? mArt.lease.pages : HudArt.pages;
         if(value)
         {
            if(mArt.cell != null && HudArtConverter.grayscale(mArt.cell,_loc2_) == null)
            {
               _loc3_ = false;
            }
            for each(_loc4_ in mArt.frames)
            {
               if(_loc4_ != null && _loc4_.cell != null && HudArtConverter.grayscale(_loc4_.cell,_loc2_) == null)
               {
                  _loc3_ = false;
               }
            }
         }
         mGrayscale = value;
         if(mImage != null && mCell != null)
         {
            mImage.cell = value ? HudArtConverter.grayCell(mCell) : mCell;
         }
         for each(_loc5_ in mChildren)
         {
            if(!_loc5_.setGrayscale(value))
            {
               _loc3_ = false;
            }
         }
         return _loc3_;
      }
      
      internal function setLocalColor(value:ColorTransform) : void
      {
         mLocalColor = value;
         refreshColor();
      }
      
      internal function tint(red:Number, green:Number, blue:Number, offsetRed:Number, offsetGreen:Number, offsetBlue:Number) : void
      {
         mRed = red;
         mGreen = green;
         mBlue = blue;
         mOffsetRed = offsetRed;
         mOffsetGreen = offsetGreen;
         mOffsetBlue = offsetBlue;
         refreshColor();
      }
      
      private function refreshColor() : void
      {
         var _loc9_:ArtDisplay = null;
         var _loc5_:Boolean = false;
         var _loc6_:MeshStyle = null;
         var _loc1_:Number = mRed * mLocalColor.redMultiplier;
         var _loc3_:Number = mGreen * mLocalColor.greenMultiplier;
         var _loc4_:Number = mBlue * mLocalColor.blueMultiplier;
         var _loc7_:Number = mOffsetRed + mRed * mLocalColor.redOffset;
         var _loc8_:Number = mOffsetGreen + mGreen * mLocalColor.greenOffset;
         var _loc2_:Number = mOffsetBlue + mBlue * mLocalColor.blueOffset;
         if(mImage != null)
         {
            if(mColorStyle != null)
            {
               _loc5_ = _loc1_ == 1 && _loc3_ == 1 && _loc4_ == 1 && _loc7_ == 0 && _loc8_ == 0 && _loc2_ == 0;
               _loc6_ = _loc5_ ? mDefaultStyle : mColorStyle;
               if(mImage.style != _loc6_)
               {
                  mImage.style = _loc6_;
               }
               if(!_loc5_)
               {
                  mColorStyle.setTransform(_loc1_,_loc3_,_loc4_,_loc7_,_loc8_,_loc2_);
               }
            }
            else
            {
               mImage.color = rgb(_loc1_,_loc3_,_loc4_);
            }
         }
         applyContentColor(_loc1_,_loc3_,_loc4_,_loc7_,_loc8_,_loc2_);
         for each(_loc9_ in mChildren)
         {
            _loc9_.tint(_loc1_,_loc3_,_loc4_,_loc7_,_loc8_,_loc2_);
         }
      }
      
      protected function applyContentColor(red:Number, green:Number, blue:Number, offsetRed:Number, offsetGreen:Number, offsetBlue:Number) : void
      {
      }
      
      internal function refresh() : void
      {
         refreshColor();
      }
      
      internal function driveChildren(head:Number) : void
      {
         var _loc2_:ArtDisplay = null;
         for each(_loc2_ in mChildren)
         {
            if(_loc2_.visible)
            {
               if(!(_loc2_ is TimelineView && Boolean(TimelineView(_loc2_).stageRate)))
               {
                  if(_loc2_ is TimelineView)
                  {
                     TimelineView(_loc2_).driveHead(head);
                  }
                  else
                  {
                     _loc2_.driveChildren(head);
                  }
               }
            }
         }
      }
      
      internal function resetChildren() : void
      {
         var _loc1_:ArtDisplay = null;
         for each(_loc1_ in mChildren)
         {
            if(!(_loc1_ is TimelineView && Boolean(TimelineView(_loc1_).stageRate)))
            {
               if(_loc1_ is TimelineView)
               {
                  TimelineView(_loc1_).resetIntro();
               }
               _loc1_.resetChildren();
            }
         }
      }
      
      internal function setStageRate(value:Boolean) : void
      {
         var _loc2_:ArtDisplay = null;
         for each(_loc2_ in mChildren)
         {
            if(_loc2_ is TimelineView)
            {
               TimelineView(_loc2_).stageRate = value;
               if(value)
               {
                  TimelineView(_loc2_).play(0,true);
               }
               else
               {
                  TimelineView(_loc2_).stop();
               }
            }
            else
            {
               _loc2_.setStageRate(value);
            }
         }
      }
      
      internal function advanceHiddenTimelines(value:Boolean) : void
      {
         var _loc2_:ArtDisplay = null;
         if(this is TimelineView)
         {
            TimelineView(this).advanceWhileHidden = value;
         }
         for each(_loc2_ in mChildren)
         {
            _loc2_.advanceHiddenTimelines(value);
         }
      }
      
      public function get art() : ArtNode
      {
         return mArt;
      }
      
      override public function dispose() : void
      {
         var _loc1_:DisplayObject = null;
         contentBoundsChanged = null;
         mask = null;
         if(mClip != null)
         {
            delete sClips[mClip];
         }
         if(mClip != null)
         {
            mClip.removeFromParent(true);
         }
         mClip = null;
         while(numChildren > 0)
         {
            _loc1_ = removeChildAt(numChildren - 1);
            try
            {
               _loc1_.dispose();
            }
            catch(error:Error)
            {
               StarlingHud.reportError(error);
            }
         }
         mChildren.length = 0;
         super.dispose();
      }
   }
}

