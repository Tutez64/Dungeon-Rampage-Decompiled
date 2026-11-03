package starling.extensions.animate
{
   import flash.geom.Matrix;
   import flash.utils.Dictionary;
   import starling.display.DisplayObjectContainer;
   import starling.display.Image;
   import starling.display.Sprite;
   import starling.extensions.animate.styles.ColorTransformStyle;
   import starling.extensions.animate.styles.MaskColorTransformStyle;
   import starling.extensions.animate.styles.MaskStyle;
   import starling.filters.BlurFilter;
   import starling.filters.ColorMatrixFilter;
   import starling.filters.DropShadowFilter;
   import starling.filters.FilterChain;
   import starling.filters.FragmentFilter;
   import starling.filters.GlowFilter;
   import starling.rendering.Painter;
   import starling.textures.Texture;
   import starling.utils.MathUtil;
   
   internal class Symbol extends DisplayObjectContainer
   {
      
      public static const BITMAP_SYMBOL_NAME:String = "___atlas_sprite___";
      
      private static const QUALITY:Number = 1;
      
      private static const sMatrix:Matrix = new Matrix();
      
      private static const sUnsupportedBlends:Object = {};
      
      private static const NO_KEYFRAMES:Vector.<Object> = new Vector.<Object>(0,true);
      
      private static const sHoldsMovieClips:Dictionary = new Dictionary(true);
      
      private var _data:Object;
      
      private var _atlas:AnimationAtlas;
      
      private var _symbolName:String;
      
      private var _type:String;
      
      private var _loopMode:String;
      
      private var _currentFrame:int;
      
      private var _composedFrame:int;
      
      private var _bitmap:Image;
      
      private var _numFrames:int;
      
      private var _numLayers:int;
      
      private var _frameCursors:Vector.<int>;
      
      private var _frameLabels:Array;
      
      private var _labels:LabelTable;
      
      private var _loopStart:int = -1;
      
      private var _forcePlayOnce:Boolean = false;
      
      private var _subtreeClamped:Boolean = false;
      
      private var _bitmapTexture:Texture;
      
      private var _bitmapData:Object;
      
      private var _isClipper:Vector.<Boolean>;
      
      private var _maskContent:Boolean = false;
      
      private var _pixelSnapping:Boolean = false;
      
      private var _ownColorMatrix:Vector.<Number>;
      
      private var _ownColorAlpha:Number = 1;
      
      private var _parentColorMatrix:Vector.<Number>;
      
      private var _composedColorMatrix:Vector.<Number>;
      
      private var _elementFilters:Array;
      
      private var _filterChain:FilterChain;
      
      private var _acfColorMatrix:Vector.<Number>;
      
      private var _acfScratch:Vector.<Number>;
      
      private var _ownFolded:Vector.<Number>;
      
      private var _alphaFoldMatrix:Vector.<Number>;
      
      private var _boundaryLeading:Vector.<Number>;
      
      private var _boundaryTrailing:Vector.<Number>;
      
      private var _boundaryTrailingRgb:Vector.<Number>;
      
      private var _leadingColorFilter:ColorMatrixFilter;
      
      private var _trailingColorFilter:ColorMatrixFilter;
      
      private var _lastColorData:Object;
      
      private var _lastFilterData:Object;
      
      private var _lastMatrixData:Object;
      
      private var _composedKeyframes:Vector.<Object>;
      
      private var _holdsMovieClips:int = -1;
      
      private var _deepestFrameCount:int = -1;
      
      public function Symbol(data:Object, atlas:AnimationAtlas)
      {
         super();
         _data = data;
         _atlas = atlas;
         _composedFrame = -1;
         _numLayers = data.timeline.layers.length;
         _frameCursors = createFrameCursors();
         _numFrames = getNumFrames();
         _labels = atlas.getLabelTable(data);
         _frameLabels = _labels.frameLabels;
         _loopStart = _labels.loopStart;
         _symbolName = data.symbolName;
         _type = "graphic";
         _loopMode = "loop";
         _composedKeyframes = _numLayers ? new Vector.<Object>(_numLayers,true) : NO_KEYFRAMES;
         createLayers();
      }
      
      private static function hasAlphaRowTransform(matrix:Vector.<Number>) : Boolean
      {
         return matrix[15] != 0 || matrix[16] != 0 || matrix[17] != 0 || matrix[18] != 1 || matrix[19] != 0;
      }
      
      private static function alphaRowOnly(source:Vector.<Number>, out:Vector.<Number>) : Vector.<Number>
      {
         out = ColorTransformStyle.copyMatrix(null,out);
         out[15] = source[15];
         out[16] = source[16];
         out[17] = source[17];
         out[18] = source[18];
         out[19] = source[19];
         return out;
      }
      
      private static function num(value:*, fallback:Number) : Number
      {
         var _loc3_:Number = value;
         return isNaN(_loc3_) ? fallback : _loc3_;
      }
      
      private static function parseColor(value:*) : uint
      {
         var _loc2_:String = null;
         if(value is String)
         {
            _loc2_ = String(value);
            if(_loc2_.charAt(0) == "#")
            {
               _loc2_ = "0x" + _loc2_.substr(1);
            }
            return uint(parseInt(_loc2_));
         }
         return uint(value);
      }
      
      private static function colorDataEquals(a:Object, b:Object) : Boolean
      {
         if(a === b)
         {
            return true;
         }
         if(a == null || b == null)
         {
            return false;
         }
         if(a.mode != b.mode)
         {
            return false;
         }
         return num(a.redMultiplier,1) == num(b.redMultiplier,1) && num(a.greenMultiplier,1) == num(b.greenMultiplier,1) && num(a.bitmap,1) == num(b.bitmap,1) && num(a.alphaMultiplier,1) == num(b.alphaMultiplier,1) && num(a.redOffset,0) == num(b.redOffset,0) && num(a.greenOffset,0) == num(b.greenOffset,0) && num(a.blueOffset,0) == num(b.blueOffset,0) && num(a.alphaOffset,0) == num(b.alphaOffset,0) && parseColor(a.tintColor) == parseColor(b.tintColor) && num(a.tintMultiplier,1) == num(b.tintMultiplier,1) && num(a.brightness,0) == num(b.brightness,0);
      }
      
      private static function filterListEquals(a:Object, b:Object) : Boolean
      {
         var _loc5_:int = 0;
         if(a === b)
         {
            return true;
         }
         var _loc3_:Array = a as Array;
         var _loc4_:Array = b as Array;
         if(_loc3_ == null || _loc4_ == null || _loc3_.length != _loc4_.length)
         {
            return false;
         }
         _loc5_ = 0;
         while(_loc5_ < _loc3_.length)
         {
            if(!filterDataEquals(_loc3_[_loc5_],_loc4_[_loc5_]))
            {
               return false;
            }
            _loc5_++;
         }
         return true;
      }
      
      private static function filterDataEquals(a:Object, b:Object) : Boolean
      {
         if(a === b)
         {
            return true;
         }
         if(a == null || b == null)
         {
            return false;
         }
         if(a.name != b.name)
         {
            return false;
         }
         return num(a.blurX,1) == num(b.blurX,1) && num(a.blurY,1) == num(b.blurY,1) && num(a.quality,1) == num(b.quality,1) && num(a.strength,100) == num(b.strength,100) && num(a.distance,4) == num(b.distance,4) && num(a.angle,45) == num(b.angle,45) && parseColor(a.color) == parseColor(b.color) && num(a.brightness,0) == num(b.brightness,0) && num(a.contrast,0) == num(b.contrast,0) && num(a.saturation,0) == num(b.saturation,0) && num(a.H,0) == num(b.H,0) && a.instanceName === true == (b.instanceName === true) && a.knockout === true == (b.knockout === true);
      }
      
      private static function blendModeFor(code:Object) : String
      {
         if(code == null)
         {
            return "auto";
         }
         switch(int(code))
         {
            case 0:
               return "add";
            case 4:
               return "erase";
            case 7:
               return "normal";
            case 9:
               return "multiply";
            case 10:
               return "normal";
            case 12:
               return "screen";
            default:
               if(!(code in sUnsupportedBlends))
               {
                  sUnsupportedBlends[code] = true;
               }
               return "auto";
         }
      }
      
      private static function frameCountForData(data:Object) : int
      {
         var _loc3_:Array = null;
         var _loc4_:int = 0;
         var _loc5_:int = 0;
         var _loc7_:int = 0;
         var _loc2_:int = 0;
         var _loc6_:Array = data.timeline.layers as Array;
         if(_loc6_ == null)
         {
            return 1;
         }
         for each(var _loc8_:Object in _loc6_)
         {
            _loc3_ = _loc8_.frames as Array;
            _loc4_ = int(_loc3_ ? _loc3_.length : 0);
            _loc5_ = int(_loc4_ ? _loc3_[0].index : 0);
            _loc7_ = 0;
            while(_loc7_ < _loc4_)
            {
               _loc5_ += _loc3_[_loc7_].duration;
               _loc7_++;
            }
            if(_loc5_ > _loc2_)
            {
               _loc2_ = _loc5_;
            }
         }
         return _loc2_ || 1;
      }
      
      private static function timelineHoldsMovieClips(data:Object, atlas:AnimationAtlas) : Boolean
      {
         var _loc8_:int = 0;
         var _loc4_:Array = null;
         var _loc6_:int = 0;
         var _loc10_:Array = null;
         var _loc5_:int = 0;
         var _loc3_:Object = null;
         var _loc12_:String = null;
         var _loc7_:Object = null;
         var _loc9_:* = sHoldsMovieClips[data];
         if(_loc9_ !== undefined)
         {
            return _loc9_;
         }
         sHoldsMovieClips[data] = true;
         var _loc13_:Boolean = false;
         var _loc11_:Array = data.timeline.layers as Array;
         _loc8_ = 0;
         while(!_loc13_ && _loc8_ < _loc11_.length)
         {
            _loc4_ = _loc11_[_loc8_].frames as Array;
            _loc6_ = 0;
            for(; !_loc13_ && _loc4_ && _loc6_ < _loc4_.length; _loc6_++)
            {
               _loc10_ = _loc4_[_loc6_].elements as Array;
               _loc5_ = 0;
               while(!_loc13_ && _loc10_ && _loc5_ < _loc10_.length)
               {
                  _loc3_ = _loc10_[_loc5_].symbolInstance;
                  if(_loc3_ != null)
                  {
                     if(!_loc3_.symbolType || SymbolType.parse(_loc3_.symbolType) == "movieclip")
                     {
                        _loc13_ = true;
                        break;
                     }
                     _loc12_ = _loc3_.symbolName;
                     if(!atlas.hasSymbol(_loc12_))
                     {
                        _loc12_ = atlas.getFallbackSymbolName(_loc12_);
                     }
                     _loc7_ = _loc12_ ? atlas.getSymbolData(_loc12_) : null;
                     if(_loc7_ && timelineHoldsMovieClips(_loc7_,atlas))
                     {
                        _loc13_ = true;
                     }
                  }
                  _loc5_++;
               }
            }
            _loc8_++;
         }
         sHoldsMovieClips[data] = _loc13_;
         return _loc13_;
      }
      
      public function reset() : void
      {
         sMatrix.identity();
         transformationMatrix = sMatrix;
         alpha = 1;
         blendMode = "auto";
         _currentFrame = 0;
         _composedFrame = -1;
         _loopMode = "loop";
         _forcePlayOnce = false;
         _subtreeClamped = false;
         _bitmapData = null;
         _maskContent = false;
         _lastColorData = null;
         _lastFilterData = null;
         _lastMatrixData = null;
         _ownColorMatrix = null;
         _ownColorAlpha = 1;
         _parentColorMatrix = null;
         _composedColorMatrix = null;
         _acfColorMatrix = null;
         _acfScratch = null;
         _ownFolded = null;
         _alphaFoldMatrix = null;
         _boundaryLeading = null;
         _boundaryTrailing = null;
         _boundaryTrailingRgb = null;
         if(_bitmap != null)
         {
            ColorTransformStyle.setColorTransform(_bitmap,null);
         }
         clearFilters();
         forgetComposedKeyframes();
      }
      
      private function forgetComposedKeyframes() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < _numLayers)
         {
            _composedKeyframes[_loc1_] = null;
            _loc1_++;
         }
      }
      
      public function releaseLayers() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Sprite = null;
         var _loc3_:Symbol = null;
         _loc1_ = 0;
         while(_loc1_ < _numLayers)
         {
            _loc2_ = getLayer(_loc1_);
            while(_loc2_.numChildren > 0)
            {
               _loc3_ = _loc2_.removeChildAt(_loc2_.numChildren - 1) as Symbol;
               _atlas.putSymbol(_loc3_);
            }
            _loc1_++;
         }
         _composedFrame = -1;
         forgetComposedKeyframes();
      }
      
      internal function rewindTree() : void
      {
         var _loc2_:int = 0;
         var _loc3_:Sprite = null;
         var _loc4_:int = 0;
         var _loc1_:int = 0;
         var _loc5_:Symbol = null;
         _currentFrame = 0;
         _composedFrame = -1;
         forgetComposedKeyframes();
         _loopMode = "loop";
         _forcePlayOnce = false;
         _subtreeClamped = false;
         _loc2_ = 0;
         while(_loc2_ < _numLayers)
         {
            _loc3_ = getLayer(_loc2_);
            _loc4_ = _loc3_.numChildren;
            _loc1_ = 0;
            while(_loc1_ < _loc4_)
            {
               _loc5_ = _loc3_.getChildAt(_loc1_) as Symbol;
               if(_loc5_ != null)
               {
                  _loc5_.rewindTree();
               }
               _loc1_++;
            }
            _loc2_++;
         }
      }
      
      public function nextFrame() : void
      {
         if(_loopMode != "singleframe")
         {
            currentFrame += 1;
         }
         nextFrame_MovieClips();
      }
      
      public function nextFrame_MovieClips(frames:int = 1) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Sprite = null;
         var _loc5_:int = 0;
         var _loc2_:int = 0;
         if(_type == "movieclip")
         {
            currentFrame += frames;
         }
         if(!holdsMovieClips)
         {
            return;
         }
         _loc3_ = 0;
         while(_loc3_ < _numLayers)
         {
            _loc4_ = getLayer(_loc3_);
            _loc5_ = _loc4_.numChildren;
            _loc2_ = 0;
            while(_loc2_ < _loc5_)
            {
               (_loc4_.getChildAt(_loc2_) as Symbol).nextFrame_MovieClips(frames);
               _loc2_++;
            }
            _loc3_++;
         }
      }
      
      public function setMovieClipLoopMode(loopMode:String) : void
      {
         var _loc3_:int = 0;
         var _loc4_:Sprite = null;
         var _loc5_:int = 0;
         var _loc2_:int = 0;
         forgetComposedKeyframes();
         if(loopMode == "playonce")
         {
            _forcePlayOnce = true;
         }
         else
         {
            _subtreeClamped = false;
         }
         if(_type == "movieclip")
         {
            _loopMode = loopMode;
         }
         _loc3_ = 0;
         while(_loc3_ < _numLayers)
         {
            _loc4_ = getLayer(_loc3_);
            _loc5_ = _loc4_.numChildren;
            _loc2_ = 0;
            while(_loc2_ < _loc5_)
            {
               (_loc4_.getChildAt(_loc2_) as Symbol).setMovieClipLoopMode(loopMode);
               _loc2_++;
            }
            _loc3_++;
         }
      }
      
      public function clearMovieClipsPlayOnce() : void
      {
         var _loc2_:int = 0;
         var _loc3_:Sprite = null;
         var _loc4_:int = 0;
         var _loc1_:int = 0;
         forgetComposedKeyframes();
         _forcePlayOnce = false;
         _subtreeClamped = false;
         if(_type == "movieclip")
         {
            _loopMode = "loop";
         }
         _loc2_ = 0;
         while(_loc2_ < _numLayers)
         {
            _loc3_ = getLayer(_loc2_);
            _loc4_ = _loc3_.numChildren;
            _loc1_ = 0;
            while(_loc1_ < _loc4_)
            {
               (_loc3_.getChildAt(_loc1_) as Symbol).clearMovieClipsPlayOnce();
               _loc1_++;
            }
            _loc2_++;
         }
      }
      
      public function resetMovieClips() : void
      {
         var _loc2_:int = 0;
         var _loc3_:Sprite = null;
         var _loc4_:int = 0;
         var _loc1_:int = 0;
         var _loc5_:Symbol = null;
         _loc2_ = 0;
         while(_loc2_ < _numLayers)
         {
            _loc3_ = getLayer(_loc2_);
            _loc4_ = _loc3_.numChildren;
            _loc1_ = 0;
            while(_loc1_ < _loc4_)
            {
               _loc5_ = _loc3_.getChildAt(_loc1_) as Symbol;
               if(_loc5_ != null)
               {
                  if(_loc5_._type == "movieclip")
                  {
                     _loc5_.currentFrame = 0;
                  }
                  _loc5_.resetMovieClips();
               }
               _loc1_++;
            }
            _loc2_++;
         }
      }
      
      public function update() : void
      {
         var _loc1_:int = 0;
         _loc1_ = 0;
         while(_loc1_ < _numLayers)
         {
            updateLayer(_loc1_);
            _loc1_++;
         }
         _composedFrame = _currentFrame;
      }
      
      private function updateLayer(layerIndex:int) : void
      {
         var _loc6_:int = 0;
         var _loc4_:Object = null;
         var _loc5_:Symbol = null;
         var _loc12_:Symbol = null;
         var _loc13_:String = null;
         var _loc14_:String = null;
         var _loc9_:int = 0;
         var _loc3_:int = 0;
         var _loc7_:Sprite = getLayer(layerIndex);
         var _loc2_:Object = getFrameData(layerIndex,_currentFrame);
         var _loc11_:Array = _loc2_ ? _loc2_.elements : null;
         var _loc8_:int = int(_loc11_ ? _loc11_.length : 0);
         if(_loc2_ != null && _loc2_ == _composedKeyframes[layerIndex] && !_forcePlayOnce && _loc7_.numChildren == _loc8_)
         {
            advanceHeldElements(_loc7_,_loc2_,_loc11_,_loc8_);
            return;
         }
         _loc7_.blendMode = blendModeFor(_loc2_ ? _loc2_.blend : null);
         _loc6_ = 0;
         while(_loc6_ < _loc8_)
         {
            _loc4_ = _loc11_[_loc6_].symbolInstance;
            _loc5_ = _loc7_.numChildren > _loc6_ ? _loc7_.getChildAt(_loc6_) as Symbol : null;
            _loc12_ = null;
            _loc13_ = _loc4_.symbolName;
            if(!_atlas.hasSymbol(_loc13_))
            {
               _loc14_ = _atlas.getFallbackSymbolName(_loc13_);
               if(_loc14_ != null)
               {
                  _loc13_ = _loc14_;
               }
               else
               {
                  _loc13_ = "___atlas_sprite___";
               }
            }
            if(_loc5_ && _loc5_._symbolName == _loc13_)
            {
               _loc12_ = _loc5_;
            }
            else
            {
               if(_loc5_)
               {
                  _loc5_.removeFromParent();
                  _atlas.putSymbol(_loc5_);
               }
               _loc12_ = _atlas.getSymbol(_loc13_);
               _loc7_.addChildAt(_loc12_,_loc6_);
            }
            _loc12_.setMaskContent(_maskContent || _isClipper[layerIndex]);
            _loc12_.pixelSnapping = _pixelSnapping;
            _loc12_.setTransformationMatrix(_loc4_.matrix3D);
            _loc12_.setBitmap(_loc4_.bitmap);
            _loc12_.setColor(_loc4_.color);
            _loc12_.setInheritedColor(_composedColorMatrix);
            _loc12_.setBlend(_loc4_.blend);
            _loc12_.setFilters(_loc4_.filters);
            _loc12_.setType(_loc4_.symbolType);
            _loc12_.setLoop(_loc4_.loop);
            if(_forcePlayOnce)
            {
               _loc12_.clampPlayOnce();
            }
            if(_loc12_.type == "graphic")
            {
               _loc9_ = int(_loc4_.firstFrame);
               _loc3_ = _currentFrame - _loc2_.index;
               if(_loc12_.loopMode == "singleframe")
               {
                  _loc12_.currentFrame = _loc9_;
               }
               else if(_loc12_.loopMode == "loop")
               {
                  _loc12_.currentFrame = _loc9_ + _loc3_;
               }
               else
               {
                  _loc12_.currentFrame = _loc9_ + _loc3_;
               }
            }
            else if(_loc12_._composedFrame != _loc12_._currentFrame)
            {
               _loc12_.update();
            }
            _loc6_++;
         }
         var _loc10_:int = _loc7_.numChildren - _loc8_;
         _loc6_ = 0;
         while(_loc6_ < _loc10_)
         {
            _loc5_ = _loc7_.removeChildAt(_loc8_) as Symbol;
            _atlas.putSymbol(_loc5_);
            _loc6_++;
         }
         if(!_isClipper[layerIndex])
         {
            _loc7_.visible = _loc8_ > 0;
         }
         _composedKeyframes[layerIndex] = _loc2_;
      }
      
      private function advanceHeldElements(layer:Sprite, frameData:Object, elements:Array, numElements:int) : void
      {
         var _loc7_:int = 0;
         var _loc8_:Symbol = null;
         var _loc6_:int = 0;
         var _loc5_:int = _currentFrame - frameData.index;
         _loc7_ = 0;
         while(_loc7_ < numElements)
         {
            _loc8_ = layer.getChildAt(_loc7_) as Symbol;
            if(_loc8_._type == "graphic")
            {
               _loc6_ = int(elements[_loc7_].symbolInstance.firstFrame);
               _loc8_.currentFrame = _loc8_._loopMode == "singleframe" ? _loc6_ : _loc6_ + _loc5_;
            }
            else if(_loc8_._composedFrame != _loc8_._currentFrame)
            {
               _loc8_.update();
            }
            _loc7_++;
         }
      }
      
      private function createLayers() : void
      {
         var _loc1_:int = 0;
         var _loc2_:Sprite = null;
         if(numChildren > 0)
         {
            throw new Error("Method must only be called once");
         }
         _loc1_ = 0;
         while(_loc1_ < _numLayers)
         {
            _loc2_ = new Sprite();
            _loc2_.name = getLayerData(_loc1_).layerName;
            addChild(_loc2_);
            _loc1_++;
         }
         applyMaskLayers();
      }
      
      private function applyMaskLayers() : void
      {
         var _loc1_:int = 0;
         var _loc2_:String = null;
         var _loc3_:int = 0;
         _isClipper = new Vector.<Boolean>(_numLayers,true);
         _loc1_ = 0;
         while(_loc1_ < _numLayers)
         {
            _isClipper[_loc1_] = getLayerData(_loc1_).LT == "Clp";
            if(_isClipper[_loc1_])
            {
               getLayer(_loc1_).visible = false;
            }
            _loc1_++;
         }
         _loc1_ = 0;
         while(_loc1_ < _numLayers)
         {
            _loc2_ = getLayerData(_loc1_).Clpb;
            if(_loc2_ != null)
            {
               _loc3_ = findClipper(_loc2_,_loc1_ + 1);
               if(_loc3_ < 0)
               {
                  _loc3_ = findClipper(_loc2_,0);
               }
               if(_loc3_ >= 0)
               {
                  getLayer(_loc1_).mask = getLayer(_loc3_);
               }
            }
            _loc1_++;
         }
      }
      
      private function findClipper(layerName:String, fromLayer:int) : int
      {
         var _loc3_:int = 0;
         _loc3_ = fromLayer;
         while(_loc3_ < _numLayers)
         {
            if(_isClipper[_loc3_] && getLayerData(_loc3_).layerName == layerName)
            {
               return _loc3_;
            }
            _loc3_++;
         }
         return -1;
      }
      
      internal function get pixelSnapping() : Boolean
      {
         return _pixelSnapping;
      }
      
      internal function set pixelSnapping(value:Boolean) : void
      {
         var _loc2_:int = 0;
         var _loc4_:Sprite = null;
         var _loc3_:int = 0;
         var _loc5_:Symbol = null;
         if(value == _pixelSnapping)
         {
            return;
         }
         _pixelSnapping = value;
         if(_bitmap)
         {
            _bitmap.pixelSnapping = value;
         }
         setRequiresRedraw();
         _loc2_ = 0;
         while(_loc2_ < _numLayers)
         {
            _loc4_ = getLayer(_loc2_);
            _loc3_ = 0;
            while(_loc3_ < _loc4_.numChildren)
            {
               _loc5_ = _loc4_.getChildAt(_loc3_) as Symbol;
               if(_loc5_)
               {
                  _loc5_.pixelSnapping = value;
               }
               _loc3_++;
            }
            _loc2_++;
         }
      }
      
      private function setMaskContent(value:Boolean) : void
      {
         if(value == _maskContent)
         {
            return;
         }
         _maskContent = value;
         _composedFrame = -1;
         forgetComposedKeyframes();
      }
      
      public function setBitmap(data:Object) : void
      {
         var _loc3_:Texture = null;
         var _loc2_:Boolean = false;
         var _loc4_:Boolean = false;
         var _loc5_:Object = null;
         if(data)
         {
            _loc3_ = _atlas.getTexture(data.name);
            _loc2_ = false;
            if(_bitmap)
            {
               if(_loc3_ != _bitmapTexture)
               {
                  _bitmap.texture = _loc3_;
                  _bitmap.readjustSize();
                  _bitmapTexture = _loc3_;
               }
            }
            else
            {
               _bitmap = _atlas.getImage(_loc3_);
               _bitmapTexture = _loc3_;
               _bitmap.pixelSnapping = _pixelSnapping;
               addChild(_bitmap);
               _loc2_ = true;
            }
            _loc4_ = _bitmap.style is MaskStyle || _bitmap.style is MaskColorTransformStyle;
            if(_maskContent && !_loc4_)
            {
               _bitmap.style = new MaskStyle();
               _loc2_ = true;
            }
            else if(!_maskContent && _loc4_)
            {
               _bitmap.style = null;
               _loc2_ = true;
            }
            if(_loc2_)
            {
               ColorTransformStyle.setColorTransform(_bitmap,_composedColorMatrix);
            }
            if(data === _bitmapData)
            {
               return;
            }
            _bitmapData = data;
            _loc5_ = data.position;
            if(_loc5_ == null && data.decomposedMatrix != null)
            {
               _loc5_ = data.decomposedMatrix.position;
            }
            if(_loc5_)
            {
               _bitmap.x = _loc5_.x;
               _bitmap.y = _loc5_.y;
            }
         }
         else if(_bitmap)
         {
            _bitmap.x = _bitmap.y = 0;
            _bitmap.removeFromParent();
            _atlas.putImage(_bitmap);
            _bitmap = null;
            _bitmapTexture = null;
            _bitmapData = null;
         }
      }
      
      override public function render(painter:Painter) : void
      {
         var _loc2_:Image = _bitmap;
         if(_numLayers != 0 || _loc2_ == null || mask != null || filter != null || _loc2_.mask != null || _loc2_.filter != null || !_loc2_.visible || _loc2_.alpha == 0 || _loc2_.scaleX == 0 || _loc2_.scaleY == 0)
         {
            super.render(painter);
            return;
         }
         painter.setStateTo(_loc2_.transformationMatrix,_loc2_.alpha,_loc2_.blendMode);
         _loc2_.render(painter);
      }
      
      private function setTransformationMatrix(data:Object) : void
      {
         if(data === _lastMatrixData)
         {
            return;
         }
         _lastMatrixData = data;
         var _loc2_:Array = data as Array;
         if(_loc2_)
         {
            if(_loc2_.length >= 16)
            {
               sMatrix.setTo(_loc2_[0],_loc2_[1],_loc2_[4],_loc2_[5],_loc2_[12],_loc2_[13]);
            }
            else
            {
               sMatrix.setTo(_loc2_[0],_loc2_[1],_loc2_[2],_loc2_[3],_loc2_[4],_loc2_[5]);
            }
         }
         else
         {
            sMatrix.setTo(data.m00,data.m01,data.m10,data.m11,data.m30,data.m31);
         }
         var _loc3_:Boolean = scaleX == 0 || scaleY == 0;
         transformationMatrix = sMatrix;
         if(_loc3_ || scaleX == 0 || scaleY == 0)
         {
            setRequiresRedraw();
         }
      }
      
      private function setColor(data:Object) : void
      {
         var _loc2_:String = null;
         var _loc3_:Array = null;
         if(colorDataEquals(data,_lastColorData))
         {
            return;
         }
         _lastColorData = data;
         _ownColorMatrix = null;
         _ownColorAlpha = 1;
         if(data)
         {
            _loc2_ = data.mode;
            if(_loc2_ == "AD" || _loc2_ == "Advanced")
            {
               if(num(data.redMultiplier,1) == 1 && num(data.greenMultiplier,1) == 1 && num(data.bitmap,1) == 1 && num(data.redOffset,0) == 0 && num(data.greenOffset,0) == 0 && num(data.blueOffset,0) == 0 && num(data.alphaOffset,0) == 0)
               {
                  _ownColorAlpha = num(data.alphaMultiplier,1);
               }
               else
               {
                  _ownColorMatrix = new <Number>[num(data.redMultiplier,1),0,0,0,num(data.redOffset,0),0,num(data.greenMultiplier,1),0,0,num(data.greenOffset,0),0,0,num(data.bitmap,1),0,num(data.blueOffset,0),0,0,0,num(data.alphaMultiplier,1),num(data.alphaOffset,0)];
               }
            }
            else if(_loc2_ == "T" || _loc2_ == "Tint")
            {
               _ownColorMatrix = ColorTransformStyle.animateTintMatrix(parseColor(data.tintColor),num(data.tintMultiplier,1));
            }
            else if(_loc2_ == "CBRT" || _loc2_ == "Brightness")
            {
               _ownColorMatrix = ColorTransformStyle.animateBrightnessMatrix(num(data.brightness,0));
            }
            else
            {
               _loc3_ = ["Alpha","CA"];
               _ownColorAlpha = _loc3_.indexOf(_loc2_) >= 0 ? num(data.alphaMultiplier,1) : 1;
            }
         }
         updateComposedColor();
      }
      
      internal function setInheritedColor(matrix:Vector.<Number>) : void
      {
         if(ColorTransformStyle.matricesEqual(matrix,_parentColorMatrix))
         {
            return;
         }
         _parentColorMatrix = matrix != null ? ColorTransformStyle.copyMatrix(matrix,_parentColorMatrix) : null;
         updateComposedColor();
      }
      
      private function updateComposedColor() : void
      {
         var _loc5_:int = 0;
         var _loc6_:Sprite = null;
         var _loc7_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:Vector.<Number> = _ownColorMatrix;
         if(_loc4_ == null && _ownColorAlpha != 1 && (_parentColorMatrix != null || _acfColorMatrix != null))
         {
            if(_alphaFoldMatrix == null)
            {
               _alphaFoldMatrix = new <Number>[1,0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0,0,1,0];
            }
            _alphaFoldMatrix[18] = _ownColorAlpha;
            _loc4_ = _alphaFoldMatrix;
         }
         if(_acfColorMatrix != null)
         {
            _ownFolded = ColorTransformStyle.concat(_loc4_,_acfColorMatrix,_ownFolded);
            _loc4_ = _ownFolded;
         }
         if(_loc4_ != null && ColorTransformStyle.isIdentity(_loc4_))
         {
            _loc4_ = null;
         }
         var _loc1_:Vector.<Number> = null;
         var _loc2_:Boolean = _elementFilters != null;
         if(_loc2_ || _numLayers > 0 && _ownColorMatrix != null && hasAlphaRowTransform(_ownColorMatrix))
         {
            updateBoundaryMatrices(_loc4_,_loc2_);
            alpha = _loc4_ == null ? _ownColorAlpha : 1;
            if(!_loc2_ && _parentColorMatrix != null && hasAlphaRowTransform(_parentColorMatrix))
            {
               _loc1_ = alphaRowOnly(_parentColorMatrix,_composedColorMatrix);
            }
         }
         else
         {
            if(_loc4_ != null || _parentColorMatrix != null)
            {
               _loc1_ = ColorTransformStyle.concat(_loc4_,_parentColorMatrix,_composedColorMatrix);
               if(ColorTransformStyle.isIdentity(_loc1_))
               {
                  _loc1_ = null;
               }
            }
            alpha = _loc1_ == null ? _ownColorAlpha : 1;
            clearBoundaryMatrices();
         }
         _composedColorMatrix = _loc1_;
         if(_bitmap != null)
         {
            ColorTransformStyle.setColorTransform(_bitmap,_loc1_);
         }
         _loc5_ = 0;
         while(_loc5_ < _numLayers)
         {
            _loc6_ = getLayer(_loc5_);
            _loc7_ = _loc6_.numChildren;
            _loc3_ = 0;
            while(_loc3_ < _loc7_)
            {
               (_loc6_.getChildAt(_loc3_) as Symbol).setInheritedColor(_loc1_);
               _loc3_++;
            }
            _loc5_++;
         }
      }
      
      private function setFilters(data:Object) : void
      {
         var _loc4_:ColorMatrixFilter = null;
         var _loc7_:Vector.<Number> = undefined;
         var _loc2_:FragmentFilter = null;
         if(filterListEquals(data,_lastFilterData))
         {
            return;
         }
         _lastFilterData = data;
         var _loc3_:Array = _elementFilters;
         _elementFilters = null;
         _acfColorMatrix = null;
         var _loc6_:Array = data as Array;
         if(_loc6_ != null && _loc6_.length > 0)
         {
            for each(var _loc8_:Object in _loc6_)
            {
               if(_loc8_ != null && _loc8_.name == "ACF" && _elementFilters == null)
               {
                  _loc4_ = createFilter(_loc8_) as ColorMatrixFilter;
                  if(_loc4_ != null)
                  {
                     _loc7_ = ColorTransformStyle.concat(_acfColorMatrix,_loc4_.matrix,_acfScratch);
                     _acfScratch = _acfColorMatrix;
                     _acfColorMatrix = _loc7_;
                     _loc4_.dispose();
                  }
               }
               else
               {
                  _loc2_ = createFilter(_loc8_);
                  if(_loc2_ != null)
                  {
                     if(_elementFilters == null)
                     {
                        _elementFilters = [];
                     }
                     _elementFilters.push(_loc2_);
                  }
               }
            }
         }
         updateSymbolFilters();
         updateComposedColor();
         if(_loc3_ != null)
         {
            for each(var _loc5_:FragmentFilter in _loc3_)
            {
               _loc5_.dispose();
            }
         }
      }
      
      private function createFilter(fd:Object) : FragmentFilter
      {
         var _loc4_:* = null;
         var _loc2_:* = null;
         var _loc3_:ColorMatrixFilter = null;
         if(fd == null)
         {
            return null;
         }
         switch(fd.name)
         {
            case "BLF":
               return new BlurFilter(num(fd.blurX,1),num(fd.blurY,1));
            case "GF":
               return new GlowFilter(parseColor(fd.color),num(fd.strength,100) / 100,Math.max(num(fd.blurX,1),num(fd.blurY,1)),1,fd.instanceName === true,fd.knockout === true);
            case "DSF":
               return new DropShadowFilter(num(fd.distance,4),num(fd.angle,45) * 3.141592653589793 / 180,parseColor(fd.color),num(fd.strength,100) / 100,Math.max(num(fd.blurX,1),num(fd.blurY,1)),1,fd.instanceName === true,fd.knockout === true);
            case "ACF":
               _loc3_ = new ColorMatrixFilter();
               if(fd.brightness)
               {
                  _loc3_.adjustBrightness(num(fd.brightness,0) / 100);
               }
               if(fd.contrast)
               {
                  _loc3_.adjustContrast(num(fd.contrast,0) / 100);
               }
               if(fd.saturation)
               {
                  _loc3_.adjustSaturation(num(fd.saturation,0) / 100);
               }
               if(fd.H)
               {
                  _loc3_.adjustHue(num(fd.H,0) / 180);
               }
               return _loc3_;
            default:
               return null;
         }
      }
      
      private function updateBoundaryMatrices(own:Vector.<Number>, filtered:Boolean) : void
      {
         var _loc4_:Boolean = false;
         if(!ColorTransformStyle.matricesEqual(own,_boundaryLeading))
         {
            _boundaryLeading = own != null ? ColorTransformStyle.copyMatrix(own,_boundaryLeading) : null;
            _loc4_ = true;
         }
         var _loc3_:Vector.<Number> = _parentColorMatrix;
         if(!filtered && _loc3_ != null && hasAlphaRowTransform(_loc3_))
         {
            _boundaryTrailingRgb = ColorTransformStyle.copyMatrix(_loc3_,_boundaryTrailingRgb);
            _boundaryTrailingRgb[15] = 0;
            _boundaryTrailingRgb[16] = 0;
            _boundaryTrailingRgb[17] = 0;
            _boundaryTrailingRgb[18] = 1;
            _boundaryTrailingRgb[19] = 0;
            _loc3_ = ColorTransformStyle.isIdentity(_boundaryTrailingRgb) ? null : _boundaryTrailingRgb;
         }
         if(!ColorTransformStyle.matricesEqual(_loc3_,_boundaryTrailing))
         {
            _boundaryTrailing = _loc3_ != null ? ColorTransformStyle.copyMatrix(_loc3_,_boundaryTrailing) : null;
            _loc4_ = true;
         }
         if(_loc4_)
         {
            updateSymbolFilters();
         }
      }
      
      private function clearBoundaryMatrices() : void
      {
         if(_boundaryLeading == null && _boundaryTrailing == null)
         {
            return;
         }
         _boundaryLeading = null;
         _boundaryTrailing = null;
         updateSymbolFilters();
      }
      
      private function updateSymbolFilters() : void
      {
         if(_filterChain != null)
         {
            while(_filterChain.numFilters > 0)
            {
               _filterChain.removeFilterAt(0,false);
            }
         }
         var _loc4_:int = int(_elementFilters ? _elementFilters.length : 0);
         var _loc2_:ColorMatrixFilter = null;
         var _loc1_:ColorMatrixFilter = null;
         if(_boundaryLeading != null)
         {
            if(_leadingColorFilter == null)
            {
               _leadingColorFilter = new ColorMatrixFilter();
            }
            _leadingColorFilter.matrix = _boundaryLeading;
            _loc2_ = _leadingColorFilter;
            _loc4_++;
         }
         if(_boundaryTrailing != null)
         {
            if(_trailingColorFilter == null)
            {
               _trailingColorFilter = new ColorMatrixFilter();
            }
            _trailingColorFilter.matrix = _boundaryTrailing;
            _loc1_ = _trailingColorFilter;
            _loc4_++;
         }
         if(_loc4_ == 0)
         {
            this.filter = null;
         }
         else if(_loc4_ == 1)
         {
            this.filter = _loc2_ ?? (_loc1_ ?? _elementFilters[0]);
         }
         else
         {
            if(_filterChain == null)
            {
               _filterChain = new FilterChain();
            }
            if(_loc2_ != null)
            {
               _filterChain.addFilter(_loc2_);
            }
            if(_elementFilters != null)
            {
               for each(var _loc3_:FragmentFilter in _elementFilters)
               {
                  _filterChain.addFilter(_loc3_);
               }
            }
            if(_loc1_ != null)
            {
               _filterChain.addFilter(_loc1_);
            }
            this.filter = _filterChain;
         }
      }
      
      override public function dispose() : void
      {
         clearFilters();
         super.dispose();
      }
      
      private function clearFilters() : void
      {
         this.filter = null;
         if(_elementFilters != null)
         {
            for each(var _loc1_:FragmentFilter in _elementFilters)
            {
               _loc1_.dispose();
            }
            _elementFilters = null;
         }
         if(_leadingColorFilter != null)
         {
            _leadingColorFilter.dispose();
            _leadingColorFilter = null;
         }
         if(_trailingColorFilter != null)
         {
            _trailingColorFilter.dispose();
            _trailingColorFilter = null;
         }
         if(_filterChain != null)
         {
            while(_filterChain.numFilters > 0)
            {
               _filterChain.removeFilterAt(0,false);
            }
            _filterChain.dispose();
            _filterChain = null;
         }
      }
      
      private function setBlend(data:Object) : void
      {
         blendMode = blendModeFor(data);
      }
      
      private function setLoop(data:String) : void
      {
         if(_forcePlayOnce && _type == "movieclip")
         {
            return;
         }
         _loopMode = data ? LoopMode.parse(data) : "loop";
      }
      
      private function setType(data:String) : void
      {
         if(data)
         {
            _type = SymbolType.parse(data);
         }
      }
      
      private function getNumFrames() : int
      {
         return frameCountForData(_data);
      }
      
      public function get deepestFrameCount() : int
      {
         if(_deepestFrameCount < 0)
         {
            _deepestFrameCount = deepestFramesIn(_data,{});
         }
         return _deepestFrameCount;
      }
      
      private function deepestFramesIn(data:Object, visited:Object) : int
      {
         var _loc4_:Array = null;
         var _loc9_:Array = null;
         var _loc3_:Object = null;
         var _loc11_:String = null;
         var _loc6_:Object = null;
         var _loc8_:int = 0;
         var _loc5_:int = frameCountForData(data);
         var _loc10_:Array = data.timeline.layers as Array;
         if(_loc10_ == null)
         {
            return _loc5_;
         }
         for each(var _loc7_:Object in _loc10_)
         {
            _loc4_ = _loc7_.frames as Array;
            if(_loc4_ != null)
            {
               for each(var _loc12_:Object in _loc4_)
               {
                  if(_loc12_.index == 0)
                  {
                     _loc9_ = _loc12_.elements as Array;
                     if(_loc9_ != null)
                     {
                        for each(var _loc13_:Object in _loc9_)
                        {
                           _loc3_ = _loc13_.symbolInstance;
                           if(_loc3_ != null)
                           {
                              _loc11_ = _loc3_.symbolName;
                              if(!(_loc11_ == null || visited[_loc11_]))
                              {
                                 visited[_loc11_] = true;
                                 _loc6_ = _atlas.getSymbolData(_loc11_);
                                 if(!(_loc6_ == null || _loc6_.timeline == null))
                                 {
                                    _loc8_ = deepestFramesIn(_loc6_,visited);
                                    if(_loc8_ > _loc5_)
                                    {
                                       _loc5_ = _loc8_;
                                    }
                                 }
                              }
                           }
                        }
                     }
                  }
               }
            }
         }
         return _loc5_;
      }
      
      private function getLayer(layerIndex:int) : Sprite
      {
         return getChildAt(layerIndex) as Sprite;
      }
      
      public function getNextLabel(afterLabel:String = null) : String
      {
         return _labels.getNextLabel(afterLabel,_currentFrame);
      }
      
      public function get currentLabel() : String
      {
         return _labels.labelAt(_currentFrame);
      }
      
      public function getFrame(label:String) : int
      {
         return _labels.getFrame(label);
      }
      
      public function hasFrameLabelSuffix(suffix:String) : Boolean
      {
         var _loc4_:int = 0;
         var _loc3_:String = null;
         var _loc2_:int = int(_frameLabels.length);
         _loc4_ = 0;
         while(_loc4_ < _loc2_)
         {
            _loc3_ = _frameLabels[_loc4_].name;
            if(_loc3_.length >= suffix.length && _loc3_.substr(_loc3_.length - suffix.length) == suffix)
            {
               return true;
            }
            _loc4_++;
         }
         return false;
      }
      
      public function hasFrameLabel(label:String) : Boolean
      {
         var _loc2_:Boolean = hasFrameLabelNoClamp(label);
         if(getFrame(label) >= 0)
         {
            clampPlayOnce();
         }
         return _loc2_;
      }
      
      public function hasFrameLabelNoClamp(label:String) : Boolean
      {
         var _loc4_:int = 0;
         var _loc5_:Sprite = null;
         var _loc6_:int = 0;
         var _loc3_:int = 0;
         var _loc7_:Symbol = null;
         var _loc2_:Boolean = getFrame(label) >= 0;
         _loc4_ = 0;
         while(_loc4_ < _numLayers)
         {
            _loc5_ = getLayer(_loc4_);
            _loc6_ = _loc5_.numChildren;
            _loc3_ = 0;
            while(_loc3_ < _loc6_)
            {
               _loc7_ = _loc5_.getChildAt(_loc3_) as Symbol;
               if(_loc7_ != null && _loc7_.hasFrameLabelNoClamp(label))
               {
                  _loc2_ = true;
               }
               _loc3_++;
            }
            _loc4_++;
         }
         return _loc2_;
      }
      
      private function clampPlayOnce() : void
      {
         var _loc2_:int = 0;
         var _loc3_:Sprite = null;
         var _loc4_:int = 0;
         var _loc1_:int = 0;
         var _loc5_:Symbol = null;
         if(_type == "movieclip")
         {
            _loopMode = "playonce";
         }
         _forcePlayOnce = true;
         if(_subtreeClamped)
         {
            return;
         }
         _loc2_ = 0;
         while(_loc2_ < _numLayers)
         {
            _loc3_ = getLayer(_loc2_);
            _loc4_ = _loc3_.numChildren;
            _loc1_ = 0;
            while(_loc1_ < _loc4_)
            {
               _loc5_ = _loc3_.getChildAt(_loc1_) as Symbol;
               if(_loc5_ != null)
               {
                  _loc5_.clampPlayOnce();
               }
               _loc1_++;
            }
            _loc2_++;
         }
         _subtreeClamped = true;
      }
      
      public function areMovieClipsAtFinal() : Boolean
      {
         var _loc2_:int = 0;
         var _loc3_:Sprite = null;
         var _loc4_:int = 0;
         var _loc1_:int = 0;
         var _loc5_:Symbol = null;
         if(_type == "movieclip" && _loopMode != "singleframe" && _currentFrame < _numFrames - 1)
         {
            return false;
         }
         _loc2_ = 0;
         while(_loc2_ < _numLayers)
         {
            _loc3_ = getLayer(_loc2_);
            _loc4_ = _loc3_.numChildren;
            _loc1_ = 0;
            while(_loc1_ < _loc4_)
            {
               _loc5_ = _loc3_.getChildAt(_loc1_) as Symbol;
               if(_loc5_ != null && !_loc5_.areMovieClipsAtFinal())
               {
                  return false;
               }
               _loc1_++;
            }
            _loc2_++;
         }
         return true;
      }
      
      public function get currentFrame() : int
      {
         return _currentFrame;
      }
      
      public function set currentFrame(value:int) : void
      {
         while(value < 0)
         {
            value += _numFrames;
         }
         if(_loopMode == "playonce")
         {
            _currentFrame = MathUtil.clamp(value,0,_numFrames - 1);
         }
         else if(_loopStart > 0 && value >= _numFrames)
         {
            _currentFrame = _loopStart + (value - _loopStart) % (_numFrames - _loopStart);
         }
         else
         {
            _currentFrame = Math.abs(value % _numFrames);
         }
         if(_composedFrame != _currentFrame)
         {
            update();
         }
      }
      
      public function get type() : String
      {
         return _type;
      }
      
      public function set type(value:String) : void
      {
         if(SymbolType.isValid(value))
         {
            _type = value;
            return;
         }
         throw new ArgumentError("Invalid symbol type: " + value);
      }
      
      public function get loopMode() : String
      {
         return _loopMode;
      }
      
      public function set loopMode(value:String) : void
      {
         if(LoopMode.isValid(value))
         {
            _loopMode = value;
            return;
         }
         throw new ArgumentError("Invalid loop mode: " + value);
      }
      
      public function get symbolName() : String
      {
         return _symbolName;
      }
      
      public function get numLayers() : int
      {
         return _numLayers;
      }
      
      public function get numFrames() : int
      {
         return _numFrames;
      }
      
      private function get holdsMovieClips() : Boolean
      {
         if(_holdsMovieClips < 0)
         {
            _holdsMovieClips = timelineHoldsMovieClips(_data,_atlas) ? 1 : 0;
         }
         return _holdsMovieClips == 1;
      }
      
      private function getLayerData(layerIndex:int) : Object
      {
         return _data.timeline.layers[layerIndex];
      }
      
      private function getFrameData(layerIndex:int, frameIndex:int) : Object
      {
         var _loc8_:Object = null;
         var _loc5_:int = 0;
         var _loc7_:int = 0;
         var _loc6_:Array = getLayerData(layerIndex).frames;
         var _loc4_:int = int(_loc6_.length);
         var _loc3_:int = _frameCursors[layerIndex];
         if(_loc3_ >= 0)
         {
            _loc5_ = _loc3_;
            while(_loc5_ <= _loc3_ + 1 && _loc5_ < _loc4_)
            {
               _loc8_ = _loc6_[_loc5_];
               if(_loc8_.index <= frameIndex && _loc8_.index + _loc8_.duration > frameIndex)
               {
                  _frameCursors[layerIndex] = _loc5_;
                  return _loc8_;
               }
               _loc5_++;
            }
         }
         _loc7_ = 0;
         while(_loc7_ < _loc4_)
         {
            _loc8_ = _loc6_[_loc7_];
            if(_loc8_.index <= frameIndex && _loc8_.index + _loc8_.duration > frameIndex)
            {
               if(_loc3_ >= 0)
               {
                  _frameCursors[layerIndex] = _loc7_;
               }
               return _loc8_;
            }
            _loc7_++;
         }
         return null;
      }
      
      private function createFrameCursors() : Vector.<int>
      {
         var _loc5_:int = 0;
         var _loc3_:Array = null;
         var _loc4_:int = 0;
         var _loc6_:Object = null;
         var _loc1_:Object = null;
         var _loc2_:Vector.<int> = new Vector.<int>(_numLayers,true);
         _loc5_ = 0;
         while(_loc5_ < _numLayers)
         {
            _loc3_ = getLayerData(_loc5_).frames;
            _loc4_ = 0;
            while(_loc4_ < _loc3_.length)
            {
               _loc6_ = _loc3_[_loc4_];
               _loc1_ = _loc4_ + 1 < _loc3_.length ? _loc3_[_loc4_ + 1] : null;
               if(!(_loc6_.index is Number && _loc6_.duration is Number && _loc6_.duration >= 1 && (_loc1_ == null || _loc6_.index + _loc6_.duration <= _loc1_.index)))
               {
                  _loc2_[_loc5_] = -1;
                  break;
               }
               _loc4_++;
            }
            _loc5_++;
         }
         return _loc2_;
      }
   }
}

