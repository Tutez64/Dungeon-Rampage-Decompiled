package UI.Hud.StarlingConverted
{
   import Brain.Starling.SwfConverter.BakedCell;
   import Brain.Starling.SwfConverter.BakedImage;
   import Brain.Starling.SwfConverter.BakedPages;
   import Brain.Starling.SwfConverter.BakedPicture;
   import Brain.Starling.SwfConverter.FlashBaker;
   import Brain.Utils.TextUtil;
   import flash.filters.BitmapFilter;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.text.TextField;
   import flash.text.TextFormat;
   import starling.core.Starling;
   import starling.display.DisplayObject;
   
   public class StarlingText extends ArtDisplay
   {
      
      public static const AUTO:String = "auto";
      
      public static const GLYPHS:String = "glyphs";
      
      public static const BAKED:String = "baked";
      
      private static const CHARS:String = "0123456789+-x.,%/:";
      
      private static var sGlyphOrigins:Object;
      
      private var mPages:BakedPages;
      
      private var mScale:Number;
      
      private var mMode:String;
      
      private var mText:String;
      
      private var mColor:uint;
      
      private var mFull:StarlingGlyphFont;
      
      private var mFill:StarlingGlyphFont;
      
      private var mWhiteFont:StarlingGlyphFont;
      
      private var mFullText:StarlingGlyphText;
      
      private var mFillText:StarlingGlyphText;
      
      private var mWhiteText:StarlingGlyphText;
      
      private var mCell:BakedCell;
      
      private var mDisposed:Boolean = false;
      
      private var mNeedsBake:Boolean = false;
      
      private var mBox:Rectangle;
      
      private var mFontSize:Number = NaN;
      
      private var mGlyphX:Number;
      
      private var mGlyphY:Number;
      
      private var mFittedFormat:TextFormat;
      
      private var mFitModel:TextField;
      
      private var mFontAvailable:Boolean = false;
      
      private var mBoundsMatrix:Matrix = new Matrix();
      
      private var mImageMatrix:Matrix = new Matrix();
      
      private var mFilterAncestors:Vector.<ArtDisplay>;
      
      private var mFilterCells:Vector.<BakedCell> = new Vector.<BakedCell>(0);
      
      private var mFilterPlacements:Vector.<Matrix> = new Vector.<Matrix>(0);
      
      private var mBakingVariant:int = -1;
      
      private var mSingleFilterVariant:Boolean;
      
      private var mTicker:HudTicker;
      
      private var mContextRetry:Function;
      
      public function StarlingText(art:ArtNode, pages:BakedPages, scale:Number, mode:String = "auto", ticker:HudTicker = null)
      {
         super(art);
         mTicker = ticker;
         mContextRetry = retryAfterContext;
         if(sGlyphOrigins == null)
         {
            sGlyphOrigins = {};
         }
         mPages = pages;
         mScale = scale;
         mMode = mode;
         mBox = art.textBounds != null ? art.textBounds.clone() : art.model.getBounds(art.model);
         mColor = art.model.textColor;
         touchable = false;
         mImage = new BakedImage();
         mImage.name = "@baked";
         mImage.visible = false;
         addChild(mImage);
         try
         {
            mFontAvailable = buildFont("0123456789+-x.,%/:");
            if(!mFontAvailable && mMode == "glyphs")
            {
               throw new Error("HUD numeric font unavailable: " + art.key);
            }
            setText(art.initialText);
         }
         catch(error:Error)
         {
            dispose();
            throw error;
         }
      }
      
      private static function restoreBox(model:TextField, matrix:Matrix, box:Rectangle) : void
      {
         model.transform.matrix = new Matrix();
         model.width = box.width;
         model.height = box.height;
         model.transform.matrix = matrix;
      }
      
      private function buildFont(chars:String, grayscale:Boolean = false) : Boolean
      {
         var _loc14_:StarlingGlyphFont = null;
         var _loc6_:StarlingGlyphFont = null;
         var _loc11_:StarlingGlyphFont = null;
         var _loc12_:TextFormat = null;
         var _loc13_:TextField = mArt.model;
         var _loc10_:Boolean = _loc13_.filters.length > 0;
         var _loc4_:Vector.<String> = grayscale ? mArt.grayFontKeys : mArt.textFontKeys;
         mFontSize = mArt.textFontSize;
         if(_loc4_ != null && _loc4_[0] != null)
         {
            _loc14_ = StarlingGlyphFont.acquire(mPages,_loc4_[0]);
            _loc6_ = _loc4_[1] != null ? StarlingGlyphFont.acquire(mPages,_loc4_[1]) : null;
            _loc11_ = _loc4_[2] != null ? StarlingGlyphFont.acquire(mPages,_loc4_[2]) : null;
            if(_loc14_ != null && (_loc4_[1] == null || _loc6_ != null) && (_loc4_[2] == null || _loc11_ != null))
            {
               return useFonts(_loc14_,_loc6_,_loc11_);
            }
            if(_loc14_ != null)
            {
               _loc14_.release();
            }
            if(_loc6_ != null)
            {
               _loc6_.release();
            }
            if(_loc11_ != null)
            {
               _loc11_.release();
            }
         }
         _loc4_ = new Vector.<String>(3,true);
         if(grayscale)
         {
            mArt.grayFontKeys = _loc4_;
         }
         else
         {
            mArt.textFontKeys = _loc4_;
         }
         mFontSize = Number(_loc13_.length > 0 ? _loc13_.getTextFormat().size : _loc13_.defaultTextFormat.size);
         mArt.textFontSize = mFontSize;
         var _loc8_:uint = _loc13_.textColor;
         var _loc3_:TextFormat = _loc13_.defaultTextFormat;
         var _loc9_:String = _loc13_.htmlText;
         var _loc7_:Matrix = _loc13_.transform.matrix;
         var _loc5_:Rectangle = _loc13_.getBounds(_loc13_);
         try
         {
            if(!_loc10_)
            {
               _loc12_ = _loc13_.length > 0 ? _loc13_.getTextFormat() : _loc13_.defaultTextFormat;
               _loc12_.color = 16777215;
               _loc13_.defaultTextFormat = _loc12_;
               _loc13_.setTextFormat(_loc12_);
               _loc13_.textColor = 16777215;
            }
            _loc14_ = HudArt.buildFont(mPages,"hudStarling",_loc13_,mScale,chars,0);
         }
         finally
         {
            _loc13_.defaultTextFormat = _loc3_;
            _loc13_.textColor = _loc8_;
            _loc13_.htmlText = _loc9_;
            restoreBox(_loc13_,_loc7_,_loc5_);
         }
         if(_loc14_ == null)
         {
            return false;
         }
         try
         {
            _loc6_ = _loc10_ ? HudArt.buildFont(mPages,"hudStarling",_loc13_,mScale,chars,1) : null;
         }
         finally
         {
            _loc13_.defaultTextFormat = _loc3_;
            _loc13_.textColor = _loc8_;
            _loc13_.htmlText = _loc9_;
            restoreBox(_loc13_,_loc7_,_loc5_);
         }
         if(_loc10_ && mArt.wantsSilhouette)
         {
            _loc11_ = buildWhiteFont(chars);
         }
         if(_loc10_ && (_loc6_ == null || mArt.wantsSilhouette && _loc11_ == null))
         {
            _loc14_.release();
            if(_loc6_ != null)
            {
               _loc6_.release();
            }
            if(_loc11_ != null)
            {
               _loc11_.release();
            }
            return false;
         }
         _loc4_[0] = _loc14_.cell.key;
         _loc4_[1] = _loc6_ != null ? _loc6_.cell.key : null;
         _loc4_[2] = _loc11_ != null ? _loc11_.cell.key : null;
         return useFonts(_loc14_,_loc6_,_loc11_);
      }
      
      private function useFonts(full:StarlingGlyphFont, fill:StarlingGlyphFont, white:StarlingGlyphFont) : Boolean
      {
         var _loc4_:Boolean = mArt.model.filters.length > 0;
         if(mFull != null)
         {
            mFull.release();
         }
         if(mFill != null)
         {
            mFill.release();
         }
         if(mWhiteFont != null)
         {
            mWhiteFont.release();
         }
         mFull = full;
         mFill = fill;
         mWhiteFont = white;
         var _loc7_:int = mArt.alignment == "right" ? 2 : (mArt.alignment == "center" ? 1 : 0);
         if(mFullText == null)
         {
            mFullText = new StarlingGlyphText(full,_loc7_);
            mFullText.name = "@glyph";
            mFullText.visible = false;
            addChild(mFullText);
         }
         else
         {
            mFullText.font = full;
         }
         if(mFillText == null && fill != null)
         {
            mFillText = new StarlingGlyphText(fill,_loc7_);
            mFillText.name = "@fill";
            mFillText.visible = false;
            addChild(mFillText);
         }
         else if(mFillText != null)
         {
            mFillText.font = fill;
         }
         if(mArt.wantsSilhouette)
         {
            if(mWhiteText == null)
            {
               mWhiteText = new StarlingGlyphText(_loc4_ ? white : full,_loc7_);
               mWhiteText.name = "@white";
               mWhiteText.visible = false;
               addChild(mWhiteText);
            }
            else
            {
               mWhiteText.font = _loc4_ ? white : full;
            }
         }
         var _loc6_:StarlingGlyphFont = full;
         mFullText.layoutFont = _loc6_;
         if(mFillText != null)
         {
            mFillText.layoutFont = _loc6_;
         }
         if(mWhiteText != null)
         {
            mWhiteText.layoutFont = _loc6_;
         }
         var _loc5_:Point = glyphOrigin();
         mGlyphX = _loc5_.x;
         mGlyphY = _loc5_.y;
         mFullText.x = _loc5_.x;
         mFullText.y = _loc5_.y;
         if(mFillText != null)
         {
            mFillText.x = _loc5_.x;
            mFillText.y = _loc5_.y;
         }
         if(mWhiteText != null)
         {
            mWhiteText.x = _loc5_.x;
            mWhiteText.y = _loc5_.y;
         }
         refresh();
         return true;
      }
      
      private function glyphOrigin() : Point
      {
         var _loc4_:BakedPicture = null;
         var _loc7_:TextFormat = null;
         var _loc11_:String = mArt.key + "|" + mFull.cell.key;
         if(sGlyphOrigins[_loc11_] != null)
         {
            return sGlyphOrigins[_loc11_] as Point;
         }
         var _loc8_:TextField = mArt.model;
         var _loc1_:String = _loc8_.htmlText;
         var _loc3_:TextFormat = _loc8_.defaultTextFormat;
         var _loc10_:Matrix = _loc8_.transform.matrix;
         var _loc9_:Rectangle = _loc8_.getBounds(_loc8_);
         var _loc6_:Rectangle = new Rectangle();
         var _loc12_:StarlingGlyphText = new StarlingGlyphText(mFull,mArt.alignment == "right" ? 2 : (mArt.alignment == "center" ? 1 : 0));
         _loc12_.layoutFont = mFull;
         _loc12_.visible = false;
         var _loc5_:Point = new Point(mBox.x + 2,mBox.y + 2);
         var _loc2_:String = _loc8_.autoSize;
         try
         {
            _loc7_ = _loc8_.length > 0 ? _loc8_.getTextFormat() : _loc3_;
            _loc7_.align = mArt.alignment;
            _loc8_.defaultTextFormat = _loc7_;
            _loc8_.autoSize = "none";
            restoreBox(_loc8_,_loc10_,mBox);
            _loc8_.text = "0";
            _loc8_.setTextFormat(_loc7_);
            _loc4_ = HudArt.bakePixels(_loc8_,mScale);
            _loc12_.setText("0");
            _loc12_.getBounds(_loc12_,_loc6_);
            if(_loc4_ != null && !_loc4_.empty)
            {
               _loc5_.setTo(-_loc4_.originX / mScale - _loc6_.x,-_loc4_.originY / mScale - _loc6_.y);
            }
         }
         finally
         {
            _loc12_.dispose();
            if(_loc4_ != null)
            {
               _loc4_.dispose();
            }
            _loc8_.defaultTextFormat = _loc3_;
            _loc8_.autoSize = _loc2_;
            _loc8_.htmlText = _loc1_;
            restoreBox(_loc8_,_loc10_,_loc9_);
         }
         sGlyphOrigins[_loc11_] = _loc5_;
         return _loc5_;
      }
      
      private function buildWhiteFont(chars:String) : StarlingGlyphFont
      {
         var _loc4_:BitmapFilter = null;
         var _loc7_:Object = null;
         var _loc9_:TextField = mArt.model;
         var _loc2_:String = _loc9_.htmlText;
         var _loc3_:uint = _loc9_.textColor;
         var _loc6_:TextFormat = _loc9_.defaultTextFormat;
         var _loc5_:Array = _loc9_.filters;
         var _loc11_:Array = [];
         var _loc8_:TextFormat = _loc9_.length > 0 ? _loc9_.getTextFormat() : _loc9_.defaultTextFormat;
         var _loc12_:Matrix = _loc9_.transform.matrix;
         var _loc10_:Rectangle = _loc9_.getBounds(_loc9_);
         for each(_loc4_ in _loc5_)
         {
            _loc7_ = _loc4_.clone();
            if("color" in _loc7_)
            {
               _loc7_.color = 16777215;
            }
            _loc11_.push(_loc7_);
         }
         try
         {
            _loc8_.color = 16777215;
            _loc9_.defaultTextFormat = _loc8_;
            _loc9_.setTextFormat(_loc8_);
            _loc9_.textColor = 16777215;
            _loc9_.filters = _loc11_;
            return HudArt.buildFont(mPages,"hudStarlingWhite",_loc9_,mScale,chars,0);
         }
         finally
         {
            _loc9_.filters = _loc5_;
            _loc9_.defaultTextFormat = _loc6_;
            _loc9_.textColor = _loc3_;
            _loc9_.htmlText = _loc2_;
            restoreBox(_loc9_,_loc12_,_loc10_);
         }
         return null;
      }
      
      private function covers(text:String) : Boolean
      {
         var _loc3_:int = 0;
         var _loc2_:int = 0;
         if(!mFontAvailable || mFull == null || !mFull.alive)
         {
            return false;
         }
         _loc3_ = 0;
         while(_loc3_ < text.length)
         {
            _loc2_ = text.charCodeAt(_loc3_);
            if(_loc2_ != 32 && !mFull.hasGlyph(_loc2_))
            {
               return false;
            }
            _loc3_++;
         }
         return true;
      }
      
      internal function setContent(value:String, mode:String) : void
      {
         if(mode != mMode)
         {
            mMode = mode;
            mText = null;
         }
         setFittedText(value,1);
      }
      
      public function setText(value:String) : void
      {
         if(mDisposed)
         {
            return;
         }
         if(value == null)
         {
            value = "";
         }
         if(value == mText)
         {
            return;
         }
         mText = value;
         renderSafely();
         if(contentBoundsChanged != null)
         {
            contentBoundsChanged();
         }
      }
      
      internal function setFittedText(value:String, sizeModifier:Number, shrinkModifier:Number = NaN) : void
      {
         var _loc4_:TextField = null;
         if(mDisposed)
         {
            return;
         }
         if(value == null)
         {
            value = "";
         }
         if(value == mText)
         {
            return;
         }
         if(mFitModel == null)
         {
            _loc4_ = mArt.model;
            mFitModel = FlashBaker.textCopy(_loc4_);
            mFitModel.autoSize = _loc4_.autoSize;
            mFitModel.multiline = _loc4_.multiline;
            mFitModel.wordWrap = _loc4_.wordWrap;
            restoreBox(mFitModel,_loc4_.transform.matrix,mBox);
         }
         TextUtil.setText(mFitModel,value,sizeModifier);
         if(shrinkModifier > 0)
         {
            TextUtil.fitToField(mFitModel,shrinkModifier);
         }
         mFittedFormat = mFitModel.getTextFormat();
         setText(value);
      }
      
      private function renderText() : void
      {
         mNeedsBake = false;
         if(mFilterAncestors == null && mMode == "glyphs" && (!mFontAvailable || mFull == null || !mFull.alive))
         {
            throw new Error("HUD numeric font unavailable: " + mArt.key);
         }
         var _loc1_:Boolean = mFilterAncestors == null && mText.length > 0 && mMode != "baked" && !mArt.model.wordWrap && !mArt.model.multiline && covers(mText);
         if(mFullText != null)
         {
            mFullText.visible = _loc1_;
            if(mFillText != null)
            {
               mFillText.visible = _loc1_;
            }
         }
         mImage.visible = !_loc1_ && mText.length > 0;
         if(mCell != null)
         {
            mPages.release(mCell);
            mCell = null;
         }
         mImage.cell = null;
         if(mWhiteText != null)
         {
            mWhiteText.visible = false;
         }
         if(_loc1_)
         {
            fitGlyphs(mFittedFormat != null ? Number(mFittedFormat.size) : mFontSize);
            mFullText.setText(mText);
            if(mFillText != null)
            {
               mFillText.setText(mText);
            }
            if(mWhiteText != null)
            {
               mWhiteText.setText(mText);
            }
         }
         else if(mText.length > 0)
         {
            clearGlyphs();
            if(mFilterAncestors != null)
            {
               bakeFilterVariants();
            }
            else
            {
               bakeString();
            }
         }
         else
         {
            clearGlyphs();
         }
         refresh();
      }
      
      private function renderSafely() : void
      {
         try
         {
            renderText();
         }
         catch(error:Error)
         {
            releaseFilterVariants();
            if(mCell != null)
            {
               mPages.release(mCell);
            }
            mCell = null;
            mImage.cell = null;
            mImage.visible = false;
            if(mFullText != null)
            {
               mFullText.visible = false;
            }
            if(mFillText != null)
            {
               mFillText.visible = false;
            }
            if(mWhiteText != null)
            {
               mWhiteText.visible = false;
            }
            if(error is HudFatalError || !HudArt.ready)
            {
               throw error;
            }
            StarlingHud.reportError(error);
            if(mTicker != null && (Starling.current == null || !Starling.current.contextValid))
            {
               mTicker.deferBake(mContextRetry);
            }
         }
      }
      
      private function retryAfterContext() : Boolean
      {
         if(Starling.current == null || !Starling.current.contextValid)
         {
            return false;
         }
         renderSafely();
         return true;
      }
      
      override internal function prepareTextFilters() : void
      {
         var _loc3_:Array = null;
         var _loc2_:ArtDisplay = parent as ArtDisplay;
         var _loc4_:Vector.<ArtDisplay> = new Vector.<ArtDisplay>(0);
         var _loc1_:Boolean = false;
         while(_loc2_ != null)
         {
            _loc4_.push(_loc2_);
            for each(_loc3_ in _loc2_.art.filterStates)
            {
               if(_loc3_.length > 0)
               {
                  _loc1_ = true;
               }
            }
            if(_loc2_ is StatesView)
            {
               break;
            }
            _loc2_ = _loc2_.parent as ArtDisplay;
         }
         if(!_loc1_)
         {
            return;
         }
         mFilterAncestors = _loc4_;
         mMode = "baked";
         renderSafely();
      }
      
      private function releaseFilterVariants() : void
      {
         var _loc1_:BakedCell = null;
         for each(_loc1_ in mFilterCells)
         {
            if(_loc1_ != null)
            {
               mPages.release(_loc1_);
            }
         }
         mFilterCells.length = 0;
         mFilterPlacements.length = 0;
      }
      
      private function bakeFilterVariants() : void
      {
         var _loc1_:ArtDisplay = null;
         var _loc3_:int = 0;
         releaseFilterVariants();
         var _loc2_:int = 1;
         mSingleFilterVariant = false;
         for each(_loc1_ in mFilterAncestors)
         {
            _loc2_ *= Math.max(1,_loc1_.art.filterStates.length);
            if(_loc2_ > 16)
            {
               _loc2_ = 1;
               mSingleFilterVariant = true;
               break;
            }
         }
         try
         {
            _loc3_ = 0;
            while(_loc3_ < _loc2_)
            {
               mBakingVariant = _loc3_;
               bakeString();
               mFilterCells.push(mPages.acquire(mCell.key));
               mFilterPlacements.push(mImage.transformationMatrix.clone());
               mPages.release(mCell);
               mCell = null;
               _loc3_++;
            }
         }
         finally
         {
            mBakingVariant = -1;
         }
         refreshTextFilters();
      }
      
      override internal function refreshTextFilters() : void
      {
         var _loc1_:ArtDisplay = null;
         if(mFilterAncestors == null || mFilterCells.length == 0)
         {
            return;
         }
         var _loc2_:int = 0;
         var _loc3_:int = 1;
         for each(_loc1_ in mFilterAncestors)
         {
            _loc2_ += _loc3_ * _loc1_.filterIndex;
            _loc3_ *= _loc1_.art.filterStates.length;
         }
         if(mSingleFilterVariant)
         {
            _loc2_ = 0;
         }
         if(_loc2_ < 0 || _loc2_ >= mFilterCells.length || _loc2_ >= mFilterPlacements.length)
         {
            mImage.cell = null;
            mImage.visible = false;
            return;
         }
         mImage.cell = mFilterCells[_loc2_];
         mImage.visible = mImage.cell != null;
         mImage.transformationMatrix = mFilterPlacements[_loc2_];
      }
      
      private function clearGlyphs() : void
      {
         if(mFullText != null)
         {
            mFullText.setText(null);
         }
         if(mFillText != null)
         {
            mFillText.setText(null);
         }
         if(mWhiteText != null)
         {
            mWhiteText.setText(null);
         }
      }
      
      private function fitGlyphs(size:Number) : void
      {
         var _loc5_:Number = mFontSize > 0 && size > 0 ? size / mFontSize : 1;
         var _loc2_:Number = mArt.alignment == "right" ? mBox.right : (mArt.alignment == "center" ? mBox.x + mBox.width * 0.5 : mBox.x);
         var _loc3_:Number = _loc2_ + (mGlyphX - _loc2_) * _loc5_;
         var _loc4_:Number = mBox.y + (mGlyphY - mBox.y) * _loc5_;
         mFullText.scaleX = mFullText.scaleY = _loc5_;
         mFullText.x = _loc3_;
         mFullText.y = _loc4_;
         if(mFillText != null)
         {
            mFillText.scaleX = mFillText.scaleY = _loc5_;
            mFillText.x = _loc3_;
            mFillText.y = _loc4_;
         }
         if(mWhiteText != null)
         {
            mWhiteText.scaleX = mWhiteText.scaleY = _loc5_;
            mWhiteText.x = _loc3_;
            mWhiteText.y = _loc4_;
         }
      }
      
      private function bakeString() : void
      {
         var _loc8_:String = null;
         var _loc9_:uint = 0;
         var _loc3_:TextFormat = null;
         var _loc1_:Array = null;
         var _loc4_:TextFormat = null;
         var _loc7_:Matrix = null;
         var _loc6_:Rectangle = null;
         var _loc15_:Matrix = null;
         var _loc2_:Matrix = null;
         var _loc10_:BakedPicture = null;
         var _loc5_:Error = null;
         var _loc14_:TextField = mArt.model;
         var _loc11_:TextFormat = mFittedFormat ?? (_loc14_.length > 0 ? _loc14_.getTextFormat() : _loc14_.defaultTextFormat);
         var _loc16_:String = mArt.key + "|text|" + mColor + "|" + mText + "|" + _loc11_.size + "|" + _loc11_.align + "|" + BakedPages.scaleKey(mScale) + "|" + _loc14_.multiline + "|" + _loc14_.wordWrap + "|" + _loc14_.autoSize + "|" + mBox.x + "|" + mBox.y + "|" + mBox.width + "|" + mBox.height + (mGrayscale ? "|gray" : "");
         if(mBakingVariant >= 0)
         {
            _loc16_ += "|ancestorFilters|" + mBakingVariant;
         }
         var _loc12_:ArtNode = HudArt.content(_loc16_,mPages);
         var _loc13_:BakedCell = _loc12_ != null ? _loc12_.cell : null;
         var _loc17_:Boolean = _loc13_ != null && _loc13_.alive;
         if(_loc13_ == null || !_loc13_.alive)
         {
            _loc8_ = _loc14_.htmlText;
            _loc9_ = _loc14_.textColor;
            _loc3_ = _loc14_.defaultTextFormat;
            _loc1_ = _loc14_.filters;
            _loc4_ = mFittedFormat ?? (_loc14_.length > 0 ? _loc14_.getTextFormat() : _loc3_);
            _loc7_ = _loc14_.transform.matrix;
            _loc6_ = _loc14_.getBounds(_loc14_);
            try
            {
               _loc14_.defaultTextFormat = _loc4_;
               restoreBox(_loc14_,_loc7_,mBox);
               _loc14_.text = mText;
               _loc14_.textColor = mColor;
               if(mGrayscale)
               {
                  _loc14_.filters = _loc1_.concat(HudArtConverter.grayscaleFilter());
               }
               _loc15_ = _loc14_.transform.matrix;
               _loc2_ = _loc7_.clone();
               _loc2_.invert();
               _loc15_.concat(_loc2_);
               try
               {
                  if(mBakingVariant >= 0)
                  {
                     _loc10_ = TextFilterBake.bake(_loc14_,mFilterAncestors,mBakingVariant,mScale,_loc15_);
                     _loc13_ = _loc10_ != null ? mPages.add(_loc16_,_loc10_,true) : null;
                  }
                  else
                  {
                     _loc13_ = HudArt.bakeOn(mPages,_loc16_,_loc14_,mScale,false);
                  }
               }
               catch(error:Error)
               {
                  StarlingHud.reportError(error);
                  _loc13_ = null;
               }
            }
            finally
            {
               _loc14_.filters = _loc1_;
               _loc14_.defaultTextFormat = _loc3_;
               _loc14_.textColor = _loc9_;
               _loc14_.htmlText = _loc8_;
               restoreBox(_loc14_,_loc7_,_loc6_);
            }
            if(_loc13_ != null)
            {
               _loc12_ = new ArtNode();
               _loc12_.cell = _loc12_.hold(_loc13_,mPages);
               _loc12_.matrix = _loc15_;
               HudArt.storeContent(_loc16_,_loc12_,mPages);
            }
         }
         mCell = _loc13_ != null ? mPages.acquire(_loc16_) : null;
         mImage.cell = mCell;
         mImage.visible = mCell != null;
         mNeedsBake = mCell == null;
         if(mNeedsBake)
         {
            _loc5_ = new Error("HUD text rasterisation refused: " + mArt.key);
            throw _loc5_;
         }
         if(mCell != null)
         {
            mImageMatrix.copyFrom(_loc12_.matrix);
            mImageMatrix.tx -= mImageMatrix.a * mCell.pivotX + mImageMatrix.c * mCell.pivotY;
            mImageMatrix.ty -= mImageMatrix.b * mCell.pivotX + mImageMatrix.d * mCell.pivotY;
            mImage.transformationMatrix = mImageMatrix;
         }
      }
      
      override protected function applyContentColor(red:Number, green:Number, blue:Number, offsetRed:Number, offsetGreen:Number, offsetBlue:Number) : void
      {
         var _loc7_:Number = NaN;
         var _loc8_:uint = rgb((mColor >> 16 & 0xFF) / 255 * red,(mColor >> 8 & 0xFF) / 255 * green,(mColor & 0xFF) / 255 * blue);
         if(mFillText != null)
         {
            mFillText.color = _loc8_;
         }
         if(mFullText != null)
         {
            mFullText.color = mArt.model.filters.length > 0 ? rgb(red,green,blue) : _loc8_;
         }
         if(mWhiteText != null)
         {
            _loc7_ = Math.max(0,offsetRed,offsetGreen,offsetBlue);
            mWhiteText.visible = mFullText.visible && _loc7_ > 0;
            mWhiteText.alpha = Math.min(1,_loc7_ / 255);
            mWhiteText.color = _loc7_ > 0 ? rgb(offsetRed / _loc7_,offsetGreen / _loc7_,offsetBlue / _loc7_) : 16777215;
         }
      }
      
      public function get text() : String
      {
         return mText;
      }
      
      public function set text(value:String) : void
      {
         setText(value);
      }
      
      public function get color() : uint
      {
         return mColor;
      }
      
      public function set color(value:uint) : void
      {
         if(value == mColor)
         {
            return;
         }
         mColor = value;
         refresh();
         if(mImage.visible || mNeedsBake)
         {
            renderSafely();
         }
      }
      
      public function get mode() : String
      {
         return mMode;
      }
      
      override public function getBounds(targetSpace:DisplayObject, resultRect:Rectangle = null) : Rectangle
      {
         if(mFullText != null && mFullText.visible)
         {
            return mFullText.getBounds(targetSpace,resultRect);
         }
         if(mImage != null && mImage.visible && mImage.cell != null && !mImage.cell.isEmpty)
         {
            return mImage.getBounds(targetSpace,resultRect);
         }
         if(resultRect == null)
         {
            resultRect = new Rectangle();
         }
         getTransformationMatrix(targetSpace,mBoundsMatrix);
         resultRect.setTo(mBoundsMatrix.tx,mBoundsMatrix.ty,0,0);
         return resultRect;
      }
      
      public function set mode(value:String) : void
      {
         if(value == mMode)
         {
            return;
         }
         mMode = value;
         renderSafely();
      }
      
      override internal function setGrayscale(value:Boolean) : Boolean
      {
         if(value == mGrayscale)
         {
            return true;
         }
         var _loc4_:Array = mArt.model.filters;
         var _loc2_:uint = mColor;
         var _loc3_:uint = uint(int((_loc2_ >> 16 & 0xFF) * 0.3086 + (_loc2_ >> 8 & 0xFF) * 0.6094 + (_loc2_ & 0xFF) * 0.082));
         try
         {
            if(value)
            {
               mArt.model.filters = _loc4_.concat(HudArtConverter.grayscaleFilter());
               mColor = _loc3_ << 16 | _loc3_ << 8 | _loc3_;
            }
            else
            {
               mColor = mArt.model.textColor;
            }
            mFontAvailable = buildFont("0123456789+-x.,%/:",value);
            mGrayscale = value;
         }
         finally
         {
            mArt.model.filters = _loc4_;
         }
         renderSafely();
         return true;
      }
      
      override public function dispose() : void
      {
         var _loc1_:* = null;
         if(mDisposed)
         {
            return;
         }
         mDisposed = true;
         if(mTicker != null)
         {
            mTicker.cancelBake(mContextRetry);
         }
         mTicker = null;
         mContextRetry = null;
         if(mCell != null)
         {
            mPages.release(mCell);
         }
         releaseFilterVariants();
         if(mFull != null)
         {
            mFull.release();
         }
         if(mFill != null)
         {
            mFill.release();
         }
         if(mWhiteFont != null)
         {
            mWhiteFont.release();
         }
         super.dispose();
      }
   }
}

