package UI.Hud.StarlingConverted
{
   import Brain.Starling.SwfConverter.BakedPicture;
   import flash.display.BitmapData;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.geom.Matrix;
   import flash.geom.Point;
   import flash.geom.Rectangle;
   import flash.utils.Dictionary;
   
   internal class StarlingSweepArt
   {
      
      private static const sDeg:Number = 0.017453292519943295;
      
      private static const sBins:int = 360;
      
      private static const sProbeSide:Number = 96;
      
      private static const sMaxFrames:int = 200;
      
      private static const sEdgePixels:Number = 1.5;
      
      private static var sByClip:Dictionary;
      
      private static var sByKey:Object;
      
      public static var lastRefusal:String;
      
      private static var sDrawn:int;
      
      public var frames:int;
      
      public var cx:Number;
      
      public var cy:Number;
      
      public var arcs:Vector.<Vector.<Number>>;
      
      public var coverFrames:Vector.<int>;
      
      public var bounds:Rectangle;
      
      public function StarlingSweepArt()
      {
         super();
      }
      
      public static function of(clip:MovieClip, onSeek:Function = null) : StarlingSweepArt
      {
         if(sByClip == null)
         {
            sByClip = new Dictionary(true);
         }
         if(sByKey == null)
         {
            sByKey = {};
         }
         var _loc4_:* = sByClip[clip];
         if(_loc4_ !== undefined)
         {
            return _loc4_ as StarlingSweepArt;
         }
         var _loc3_:StarlingSweepArt = null;
         try
         {
            _loc3_ = analyse(clip,onSeek);
         }
         catch(error:Error)
         {
            _loc3_ = null;
            lastRefusal = "error " + error.errorID;
         }
         sByClip[clip] = _loc3_ ?? false;
         return _loc3_;
      }
      
      private static function seek(clip:MovieClip, frame:int, onSeek:Function) : void
      {
         if(onSeek != null)
         {
            onSeek(clip);
         }
         clip.gotoAndStop(frame);
         if(onSeek != null)
         {
            onSeek(clip);
         }
      }
      
      private static function analyse(clip:MovieClip, onSeek:Function) : StarlingSweepArt
      {
         var _loc9_:int = 0;
         var _loc7_:Rectangle = null;
         var _loc12_:String = null;
         var _loc11_:Rectangle = null;
         var _loc5_:* = undefined;
         var _loc4_:StarlingSweepArt = null;
         var _loc6_:int = clip.totalFrames;
         if(_loc6_ < 2 || _loc6_ > 200)
         {
            lastRefusal = "frames " + _loc6_;
            return null;
         }
         var _loc8_:int = clip.currentFrame;
         var _loc10_:Boolean = clip.isPlaying;
         var _loc3_:Boolean = clip.visible;
         try
         {
            clip.visible = true;
            _loc7_ = new Rectangle();
            _loc12_ = _loc6_ + ":";
            _loc9_ = 1;
            while(true)
            {
               if(_loc9_ > _loc6_)
               {
                  if(!(_loc7_.width > 0 && _loc7_.height > 0))
                  {
                     lastRefusal = "no bounds";
                     return null;
                  }
                  _loc12_ += pictureKey(clip,_loc6_,_loc7_,onSeek);
                  _loc5_ = sByKey[_loc12_];
                  if(_loc5_ !== undefined)
                  {
                     return _loc5_ as StarlingSweepArt;
                  }
                  _loc4_ = analyseFrames(clip,_loc6_,_loc7_,onSeek);
                  sByKey[_loc12_] = _loc4_ ?? false;
                  return _loc4_;
               }
               seek(clip,_loc9_,onSeek);
               if(innerTimeline(clip,0))
               {
                  lastRefusal = "inner timeline";
                  return null;
               }
               _loc11_ = clip.getBounds(clip);
               _loc12_ += Math.round(_loc11_.x * 10) + "," + Math.round(_loc11_.y * 10) + "," + Math.round(_loc11_.width * 10) + "," + Math.round(_loc11_.height * 10) + ";";
               if(_loc11_.width > 0 && _loc11_.height > 0)
               {
                  _loc7_ = _loc7_.width > 0 ? _loc7_.union(_loc11_) : _loc11_;
               }
               _loc9_++;
            }
         }
         finally
         {
            if(_loc10_)
            {
               clip.gotoAndPlay(_loc8_);
            }
            else
            {
               clip.gotoAndStop(_loc8_);
            }
            clip.visible = _loc3_;
         }
         return null;
      }
      
      private static function innerTimeline(c:DisplayObjectContainer, depth:int) : Boolean
      {
         var _loc3_:int = 0;
         var _loc4_:DisplayObjectContainer = null;
         if(depth > 6)
         {
            return false;
         }
         _loc3_ = 0;
         while(_loc3_ < c.numChildren)
         {
            _loc4_ = c.getChildAt(_loc3_) as DisplayObjectContainer;
            if(_loc4_ != null)
            {
               if(_loc4_ is MovieClip && MovieClip(_loc4_).totalFrames > 1 || innerTimeline(_loc4_,depth + 1))
               {
                  return true;
               }
            }
            _loc3_++;
         }
         return false;
      }
      
      private static function pictureKey(clip:MovieClip, total:int, b:Rectangle, onSeek:Function) : String
      {
         var _loc5_:int = 0;
         var _loc8_:Vector.<uint> = undefined;
         var _loc10_:Number = NaN;
         var _loc9_:int = 0;
         var _loc6_:Number = 16 / Math.max(b.width,b.height);
         var _loc7_:BitmapData = new BitmapData(Math.ceil(b.width * _loc6_) + 2,Math.ceil(b.height * _loc6_) + 2,true,0);
         var _loc11_:String = "";
         try
         {
            _loc5_ = 1;
            while(_loc5_ <= 4)
            {
               seek(clip,Math.max(1,Math.round(total * _loc5_ / 5)),onSeek);
               _loc7_.fillRect(_loc7_.rect,0);
               _loc7_.draw(clip,new Matrix(_loc6_,0,0,_loc6_,1 - b.x * _loc6_,1 - b.y * _loc6_),null,null,null,true);
               _loc8_ = _loc7_.getVector(_loc7_.rect);
               _loc10_ = 0;
               _loc9_ = 0;
               while(_loc9_ < _loc8_.length)
               {
                  _loc10_ += (_loc8_[_loc9_] >>> 24) * (_loc9_ % 7 + 1);
                  _loc9_++;
               }
               _loc11_ += "|" + Math.round(_loc10_ / 64);
               _loc5_++;
            }
         }
         finally
         {
            _loc7_.dispose();
         }
         return _loc11_;
      }
      
      private static function analyseFrames(clip:MovieClip, total:int, b:Rectangle, onSeek:Function) : StarlingSweepArt
      {
         var _loc13_:BitmapData = null;
         var _loc22_:int = 0;
         var _loc25_:int = 0;
         var _loc19_:int = 0;
         var _loc5_:Number = NaN;
         var _loc32_:int = 0;
         var _loc21_:int = 0;
         var _loc27_:Matrix = null;
         var _loc29_:Vector.<Vector.<uint>> = undefined;
         var _loc26_:Vector.<uint> = undefined;
         var _loc8_:Vector.<uint> = undefined;
         var _loc31_:int = 0;
         var _loc35_:int = 0;
         var _loc34_:int = 0;
         var _loc12_:Number = NaN;
         var _loc17_:Number = NaN;
         var _loc14_:Number = NaN;
         var _loc18_:Number = NaN;
         var _loc9_:int = 0;
         var _loc37_:int = 0;
         var _loc24_:Number = NaN;
         var _loc23_:Number = NaN;
         var _loc11_:int = 0;
         var _loc10_:Vector.<Number> = undefined;
         var _loc15_:StarlingSweepArt = null;
         var _loc16_:Vector.<Vector.<Boolean>> = undefined;
         var _loc28_:Vector.<Boolean> = undefined;
         var _loc33_:Vector.<Boolean> = undefined;
         var _loc36_:int = 0;
         try
         {
            _loc5_ = Math.min(4,96 / Math.max(b.width,b.height));
            _loc32_ = Math.ceil(b.width * _loc5_) + 2;
            _loc21_ = Math.ceil(b.height * _loc5_) + 2;
            _loc27_ = new Matrix(_loc5_,0,0,_loc5_,1 - b.x * _loc5_,1 - b.y * _loc5_);
            _loc13_ = new BitmapData(_loc32_,_loc21_,true,0);
            _loc29_ = new Vector.<Vector.<uint>>(total + 1,true);
            _loc26_ = new Vector.<uint>(_loc32_ * _loc21_,true);
            _loc19_ = 1;
            while(_loc19_ <= total)
            {
               seek(clip,_loc19_,onSeek);
               _loc13_.fillRect(_loc13_.rect,0);
               _loc13_.draw(clip,_loc27_,null,null,null,true);
               _loc8_ = _loc13_.getVector(_loc13_.rect);
               _loc29_[_loc19_] = _loc8_;
               _loc22_ = 0;
               while(_loc22_ < _loc8_.length)
               {
                  if(_loc8_[_loc22_] >>> 24 > _loc26_[_loc22_] >>> 24)
                  {
                     _loc26_[_loc22_] = _loc8_[_loc22_];
                  }
                  _loc22_++;
               }
               _loc19_++;
            }
            _loc31_ = _loc32_;
            var _loc30_:int = _loc21_;
            var _loc7_:int = -1;
            var _loc6_:int = -1;
            _loc35_ = 0;
            while(_loc35_ < _loc21_)
            {
               _loc34_ = 0;
               while(_loc34_ < _loc32_)
               {
                  if(_loc26_[_loc35_ * _loc32_ + _loc34_] >>> 24 > 32)
                  {
                     if(_loc34_ < _loc31_)
                     {
                        _loc31_ = _loc34_;
                     }
                     if(_loc34_ > _loc7_)
                     {
                        _loc7_ = _loc34_;
                     }
                     if(_loc35_ < _loc30_)
                     {
                        _loc30_ = _loc35_;
                     }
                     if(_loc35_ > _loc6_)
                     {
                        _loc6_ = _loc35_;
                     }
                  }
                  _loc34_++;
               }
               _loc35_++;
            }
            if(_loc7_ < 0)
            {
               lastRefusal = "draws nothing";
               return null;
            }
            _loc12_ = Math.min(_loc7_ - _loc31_ + 1,_loc6_ - _loc30_ + 1) / 2;
            if(_loc12_ < 6)
            {
               lastRefusal = "too small";
               return null;
            }
            _loc17_ = (_loc31_ + _loc7_ + 1) / 2;
            _loc14_ = (_loc30_ + _loc6_ + 1) / 2;
            _loc18_ = _loc17_;
            var _loc20_:Number = _loc14_;
            _loc9_ = 2147483647;
            _loc37_ = Math.max(1,total / 6);
            _loc24_ = -2;
            while(_loc24_ <= 2)
            {
               _loc23_ = -2;
               while(_loc23_ <= 2)
               {
                  _loc11_ = 0;
                  _loc19_ = 1;
                  while(_loc19_ <= total && _loc11_ < _loc9_)
                  {
                     _loc10_ = runs(coverage(_loc29_[_loc19_],_loc26_,_loc32_,_loc17_ + _loc23_,_loc14_ + _loc24_,_loc12_,null));
                     _loc11_ += mismatches(_loc29_[_loc19_],_loc26_,_loc10_,_loc32_,_loc21_,_loc17_ + _loc23_,_loc14_ + _loc24_);
                     _loc19_ += _loc37_;
                  }
                  if(_loc11_ < _loc9_)
                  {
                     _loc9_ = _loc11_;
                     _loc18_ = _loc17_ + _loc23_;
                     _loc20_ = _loc14_ + _loc24_;
                  }
                  _loc23_ += 1;
               }
               _loc24_ += 1;
            }
            _loc15_ = new StarlingSweepArt();
            _loc15_.frames = total;
            _loc15_.bounds = b;
            _loc15_.cx = (_loc18_ - 1) / _loc5_ + b.x;
            _loc15_.cy = (_loc20_ - 1) / _loc5_ + b.y;
            _loc15_.arcs = new Vector.<Vector.<Number>>(total + 1,true);
            _loc16_ = new Vector.<Vector.<Boolean>>(total + 1,true);
            _loc28_ = new Vector.<Boolean>(360,true);
            _loc19_ = 1;
            while(_loc19_ <= total)
            {
               _loc33_ = coverage(_loc29_[_loc19_],_loc26_,_loc32_,_loc18_,_loc20_,_loc12_,_loc28_);
               _loc16_[_loc19_] = _loc33_;
               _loc15_.arcs[_loc19_] = runs(_loc33_);
               _loc19_++;
            }
            _loc19_ = 1;
            while(true)
            {
               if(_loc19_ > total)
               {
                  _loc15_.coverFrames = cover(_loc16_,_loc28_,total);
                  if(_loc15_.coverFrames == null)
                  {
                     lastRefusal = "no cover";
                     return null;
                  }
                  return _loc15_;
               }
               _loc36_ = mismatches(_loc29_[_loc19_],_loc26_,_loc15_.arcs[_loc19_],_loc32_,_loc21_,_loc18_,_loc20_);
               if(_loc36_ > Math.max(12,sDrawn / 100))
               {
                  lastRefusal = "frame " + _loc19_ + " differs by " + _loc36_ + "/" + sDrawn;
                  return null;
               }
               _loc19_++;
            }
         }
         finally
         {
            if(_loc13_ != null)
            {
               _loc13_.dispose();
            }
         }
         return null;
      }
      
      private static function runs(covered:Vector.<Boolean>) : Vector.<Number>
      {
         var _loc5_:int = 0;
         var _loc10_:Boolean = false;
         var _loc6_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc9_:Vector.<Number> = new Vector.<Number>(0);
         var _loc4_:Number = 1;
         var _loc7_:int = 0;
         var _loc2_:* = -1;
         _loc7_ = 0;
         while(_loc7_ < 360)
         {
            if(!covered[_loc7_])
            {
               _loc2_ = _loc7_;
               break;
            }
            _loc7_++;
         }
         if(_loc2_ < 0)
         {
            _loc9_.push(0,360);
            return _loc9_;
         }
         var _loc3_:int = -1;
         _loc5_ = 1;
         while(_loc5_ <= 360)
         {
            _loc7_ = _loc2_ + _loc5_;
            _loc10_ = covered[_loc7_ % 360];
            if(_loc10_ && _loc3_ < 0)
            {
               _loc3_ = _loc7_;
            }
            if((!_loc10_ || _loc5_ == 360) && _loc3_ >= 0)
            {
               _loc6_ = _loc3_ * _loc4_;
               _loc8_ = (_loc10_ ? _loc7_ + 1 : _loc7_) * _loc4_;
               if(_loc6_ >= 360)
               {
                  _loc6_ -= 360;
                  _loc8_ -= 360;
               }
               _loc9_.push(_loc6_,_loc8_);
               _loc3_ = -1;
            }
            _loc5_++;
         }
         return _loc9_;
      }
      
      private static function inArcs(arcs:Vector.<Number>, deg:Number) : Boolean
      {
         var _loc3_:int = 0;
         _loc3_ = 0;
         while(_loc3_ + 1 < arcs.length)
         {
            if(deg >= arcs[_loc3_] && deg < arcs[_loc3_ + 1] || deg + 360 >= arcs[_loc3_] && deg + 360 < arcs[_loc3_ + 1])
            {
               return true;
            }
            _loc3_ += 2;
         }
         return false;
      }
      
      private static function edgeDistance(arcs:Vector.<Number>, deg:Number) : Number
      {
         var _loc3_:int = 0;
         var _loc4_:Number = NaN;
         var _loc5_:Number = 360;
         _loc3_ = 0;
         while(_loc3_ < arcs.length)
         {
            _loc4_ = Math.abs(deg - arcs[_loc3_]) % 360;
            if(_loc4_ > 180)
            {
               _loc4_ = 360 - _loc4_;
            }
            if(_loc4_ < _loc5_)
            {
               _loc5_ = _loc4_;
            }
            _loc3_++;
         }
         return _loc5_;
      }
      
      private static function coverage(px:Vector.<uint>, union:Vector.<uint>, w:int, pcx:Number, pcy:Number, radius:Number, any:Vector.<Boolean>) : Vector.<Boolean>
      {
         var _loc9_:int = 0;
         var _loc12_:Number = NaN;
         var _loc8_:Number = NaN;
         var _loc15_:int = 0;
         var _loc11_:Number = NaN;
         var _loc13_:int = 0;
         var _loc10_:uint = 0;
         var _loc14_:Vector.<Boolean> = new Vector.<Boolean>(360,true);
         _loc9_ = 0;
         while(_loc9_ < 360)
         {
            _loc12_ = Math.sin((_loc9_ + 0.5) * 360 / 360 * 0.017453292519943295);
            _loc8_ = Math.cos((_loc9_ + 0.5) * 360 / 360 * 0.017453292519943295);
            _loc15_ = 0;
            _loc11_ = 0.35;
            while(_loc11_ < 0.8)
            {
               _loc13_ = (int(pcy - radius * _loc11_ * _loc8_)) * w + (int(pcx + radius * _loc11_ * _loc12_));
               if(!(_loc13_ < 0 || _loc13_ >= union.length))
               {
                  _loc10_ = uint(union[_loc13_] >>> 24);
                  if(_loc10_ >= 40)
                  {
                     _loc15_ += (px[_loc13_] >>> 24) * 2 >= _loc10_ ? 1 : -1;
                  }
               }
               _loc11_ += 0.2;
            }
            _loc14_[_loc9_] = _loc15_ > 0;
            if(_loc15_ > 0 && any != null)
            {
               any[_loc9_] = true;
            }
            _loc9_++;
         }
         return _loc14_;
      }
      
      private static function mismatches(px:Vector.<uint>, union:Vector.<uint>, arcs:Vector.<Number>, w:int, h:int, pcx:Number, pcy:Number) : int
      {
         var _loc18_:int = 0;
         var _loc17_:int = 0;
         var _loc12_:int = 0;
         var _loc8_:uint = 0;
         var _loc14_:uint = 0;
         var _loc15_:Number = NaN;
         var _loc13_:Number = NaN;
         var _loc9_:Number = NaN;
         var _loc10_:uint = 0;
         var _loc11_:int = 0;
         var _loc19_:int = 0;
         _loc18_ = 0;
         while(_loc18_ < h)
         {
            _loc17_ = 0;
            while(_loc17_ < w)
            {
               _loc12_ = _loc18_ * w + _loc17_;
               _loc8_ = px[_loc12_];
               _loc14_ = union[_loc12_];
               if((_loc8_ | _loc14_) >>> 24 != 0)
               {
                  _loc19_++;
                  _loc15_ = _loc17_ + 0.5 - pcx;
                  var _loc16_:Number = _loc18_ + 0.5 - pcy;
                  _loc13_ = Math.sqrt(_loc15_ * _loc15_ + _loc16_ * _loc16_);
                  if(_loc13_ >= 2)
                  {
                     _loc9_ = Math.atan2(_loc15_,-_loc16_) / 0.017453292519943295;
                     if(_loc9_ < 0)
                     {
                        _loc9_ += 360;
                     }
                     if(!(arcs.length > 0 && edgeDistance(arcs,_loc9_) * 0.017453292519943295 * _loc13_ < 1.5))
                     {
                        _loc10_ = uint(inArcs(arcs,_loc9_) ? _loc14_ : 0);
                        if(_loc10_ != _loc8_)
                        {
                           if(Math.abs((_loc10_ >>> 24) - (_loc8_ >>> 24)) > 64 || _loc8_ >>> 24 > 64 && _loc10_ >>> 24 > 64 && (Math.abs((_loc10_ >>> 16 & 0xFF) - (_loc8_ >>> 16 & 0xFF)) > 64 || Math.abs((_loc10_ >>> 8 & 0xFF) - (_loc8_ >>> 8 & 0xFF)) > 64 || Math.abs((_loc10_ & 0xFF) - (_loc8_ & 0xFF)) > 64))
                           {
                              _loc11_++;
                           }
                        }
                     }
                  }
               }
               _loc17_++;
            }
            _loc18_++;
         }
         sDrawn = _loc19_;
         return _loc11_;
      }
      
      private static function cover(bins:Vector.<Vector.<Boolean>>, any:Vector.<Boolean>, total:int) : Vector.<int>
      {
         var _loc11_:int = 0;
         var _loc10_:int = 0;
         var _loc7_:int = 0;
         var _loc9_:int = 0;
         var _loc4_:Vector.<Boolean> = any.concat();
         var _loc5_:int = 0;
         _loc11_ = 0;
         while(_loc11_ < 360)
         {
            if(_loc4_[_loc11_])
            {
               _loc5_++;
            }
            _loc11_++;
         }
         if(_loc5_ == 0)
         {
            return null;
         }
         var _loc6_:Vector.<int> = new Vector.<int>(0);
         while(_loc5_ > 0 && _loc6_.length < 6)
         {
            _loc10_ = -1;
            var _loc8_:* = 0;
            _loc7_ = 1;
            while(_loc7_ <= total)
            {
               _loc9_ = 0;
               _loc11_ = 0;
               while(_loc11_ < 360)
               {
                  if(_loc4_[_loc11_] && bins[_loc7_][_loc11_])
                  {
                     _loc9_++;
                  }
                  _loc11_++;
               }
               if(_loc9_ > _loc8_)
               {
                  _loc8_ = _loc9_;
                  _loc10_ = _loc7_;
               }
               _loc7_++;
            }
            if(_loc10_ < 0)
            {
               break;
            }
            _loc6_.push(_loc10_);
            _loc11_ = 0;
            while(_loc11_ < 360)
            {
               if(bins[_loc10_][_loc11_] && _loc4_[_loc11_])
               {
                  _loc4_[_loc11_] = false;
                  _loc5_--;
               }
               _loc11_++;
            }
         }
         return _loc5_ == 0 ? _loc6_ : null;
      }
      
      public function bakeDisc(clip:MovieClip, pixelScale:Number, onSeek:Function = null) : BakedPicture
      {
         var _loc6_:BitmapData = null;
         var _loc9_:* = undefined;
         var _loc12_:Matrix = null;
         var _loc10_:Vector.<uint> = undefined;
         var _loc11_:int = 0;
         var _loc13_:Rectangle = null;
         var _loc17_:BakedPicture = null;
         if(pixelScale <= 0)
         {
            return null;
         }
         var _loc5_:Number = pixelScale;
         var _loc14_:int = 3;
         pixelScale = Math.min(pixelScale,(1024 - _loc14_ * 2 - 2) / Math.max(bounds.width,bounds.height));
         var _loc16_:int = Math.floor(bounds.left * pixelScale) - _loc14_;
         var _loc15_:int = Math.floor(bounds.top * pixelScale) - _loc14_;
         var _loc18_:int = Math.ceil(bounds.right * pixelScale) + _loc14_ - _loc16_;
         var _loc20_:int = Math.ceil(bounds.bottom * pixelScale) + _loc14_ - _loc15_;
         var _loc7_:int = clip.currentFrame;
         var _loc19_:Boolean = clip.isPlaying;
         var _loc4_:Boolean = clip.visible;
         try
         {
            clip.visible = true;
            _loc6_ = new BitmapData(_loc18_,_loc20_,true,0);
            _loc12_ = new Matrix(pixelScale,0,0,pixelScale,-_loc16_,-_loc15_);
            for each(var _loc8_:int in coverFrames)
            {
               seek(clip,_loc8_,onSeek);
               _loc6_.fillRect(_loc6_.rect,0);
               _loc6_.draw(clip,_loc12_,null,null,null,true);
               _loc10_ = _loc6_.getVector(_loc6_.rect);
               if(_loc9_ == null)
               {
                  _loc9_ = _loc10_;
               }
               else
               {
                  _loc11_ = 0;
                  while(_loc11_ < _loc10_.length)
                  {
                     if(_loc10_[_loc11_] >>> 24 > _loc9_[_loc11_] >>> 24)
                     {
                        _loc9_[_loc11_] = _loc10_[_loc11_];
                     }
                     _loc11_++;
                  }
               }
            }
            _loc6_.setVector(_loc6_.rect,_loc9_);
            _loc13_ = _loc6_.getColorBoundsRect(4278190080,0,false);
            if(_loc13_.width <= 0 || _loc13_.height <= 0)
            {
               return null;
            }
            _loc17_ = new BakedPicture();
            _loc17_.bitmap = new BitmapData(_loc13_.width + 1 * 2,_loc13_.height + 1 * 2,true,0);
            _loc17_.bitmap.copyPixels(_loc6_,_loc13_,new Point(1,1));
            _loc17_.originX = -_loc16_ - _loc13_.x + 1;
            _loc17_.originY = -_loc15_ - _loc13_.y + 1;
            _loc17_.pixelScale = pixelScale;
            StarlingRaster.limit(_loc17_,_loc5_);
            return _loc17_;
         }
         catch(error:Error)
         {
            return null;
         }
         finally
         {
            if(_loc19_)
            {
               clip.gotoAndPlay(_loc7_);
            }
            else
            {
               clip.gotoAndStop(_loc7_);
            }
            clip.visible = _loc4_;
            if(_loc6_ != null)
            {
               _loc6_.dispose();
            }
         }
         return null;
      }
   }
}

