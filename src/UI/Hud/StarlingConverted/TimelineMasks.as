package UI.Hud.StarlingConverted
{
   import Brain.AssetRepository.SwfAsset;
   import flash.display.DisplayObject;
   import flash.display.DisplayObjectContainer;
   import flash.display.MovieClip;
   import flash.geom.Matrix;
   import flash.geom.Rectangle;
   import flash.utils.ByteArray;
   import flash.utils.Dictionary;
   import flash.utils.getQualifiedClassName;
   
   public class TimelineMasks
   {
      
      private static var sSymbols:Object = {};
      
      private static var sLoaded:Dictionary = new Dictionary(true);
      
      private var mBytes:ByteArray;
      
      private var mBit:int;
      
      private var mByte:int;
      
      private var mSprites:Object = {};
      
      private var mBounds:Object = {};
      
      public function TimelineMasks()
      {
         super();
      }
      
      public static function register(asset:SwfAsset) : void
      {
         if(sLoaded[asset.root])
         {
            return;
         }
         var _loc2_:TimelineMasks = new TimelineMasks();
         _loc2_.read(asset.root.loaderInfo.bytes);
         sLoaded[asset.root] = true;
      }
      
      private static function definition(source:DisplayObject) : Object
      {
         var _loc4_:Object = sSymbols[getQualifiedClassName(source).replace("::",".")];
         if(_loc4_ != null)
         {
            return _loc4_;
         }
         if(source.parent == null)
         {
            return null;
         }
         var _loc2_:Object = definition(source.parent);
         var _loc5_:Array = placements(source.parent,_loc2_);
         var _loc3_:int = source.parent.getChildIndex(source);
         return _loc5_ != null && _loc3_ < _loc5_.length ? {
            "parser":_loc2_.parser,
            "id":_loc5_[_loc3_].id
         } : null;
      }
      
      private static function placements(source:DisplayObject, linked:Object) : Array
      {
         if(linked == null)
         {
            return null;
         }
         var _loc3_:Vector.<Array> = TimelineMasks(linked.parser).mSprites[linked.id] as Vector.<Array>;
         var _loc4_:MovieClip = source as MovieClip;
         return _loc3_ != null && _loc3_.length > 0 ? _loc3_[(_loc4_ != null ? _loc4_.currentFrame - 1 : 0) % _loc3_.length] : null;
      }
      
      internal static function isMask(parent:DisplayObjectContainer, child:DisplayObject) : Boolean
      {
         var _loc4_:Array = placements(parent,definition(parent));
         var _loc3_:int = parent.getChildIndex(child);
         return _loc4_ != null && _loc3_ < _loc4_.length && _loc4_[_loc3_].clip > 0;
      }
      
      internal static function clip(parent:DisplayObjectContainer, child:DisplayObject) : Rectangle
      {
         var _loc7_:Object = null;
         var _loc5_:Rectangle = null;
         var _loc3_:Rectangle = null;
         var _loc4_:Matrix = null;
         var _loc8_:Object = definition(parent);
         var _loc9_:Array = placements(parent,_loc8_);
         var _loc6_:int = parent.getChildIndex(child);
         if(_loc9_ == null || _loc6_ >= _loc9_.length)
         {
            return null;
         }
         for each(_loc7_ in _loc9_)
         {
            if(!(_loc7_.clip < _loc9_[_loc6_].depth || _loc7_.depth >= _loc9_[_loc6_].depth))
            {
               _loc5_ = TimelineMasks(_loc8_.parser).mBounds[_loc7_.id] as Rectangle;
               _loc4_ = _loc7_.matrix;
               if(_loc5_ == null || _loc4_.b != 0 || _loc4_.c != 0)
               {
                  return null;
               }
               _loc5_ = new Rectangle(_loc4_.a * _loc5_.x + _loc4_.tx,_loc4_.d * _loc5_.y + _loc4_.ty,_loc4_.a * _loc5_.width,_loc4_.d * _loc5_.height);
               _loc3_ = _loc3_ != null ? _loc3_.intersection(_loc5_) : _loc5_;
            }
         }
         return _loc3_;
      }
      
      private function read(bytes:ByteArray) : void
      {
         var _loc2_:int = 0;
         var _loc4_:ByteArray = null;
         var _loc3_:uint = bytes.position;
         try
         {
            mBytes = new ByteArray();
            bytes.position = 0;
            bytes.readBytes(mBytes);
            mBytes.endian = "littleEndian";
            mBytes.position = 0;
            _loc2_ = int(mBytes.readUnsignedByte());
            if(_loc2_ == 67)
            {
               _loc4_ = new ByteArray();
               mBytes.position = 8;
               mBytes.readBytes(_loc4_);
               _loc4_.uncompress();
               mBytes.length = 8;
               mBytes.position = 8;
               mBytes.writeBytes(_loc4_);
            }
            mBytes.position = 8;
            rect();
            mBytes.position += 4;
            tags(mBytes.length,null);
            prune();
         }
         finally
         {
            mBytes = null;
            bytes.position = _loc3_;
         }
      }
      
      private function prune() : void
      {
         var _loc4_:String = null;
         var _loc1_:Vector.<Array> = undefined;
         var _loc6_:Array = null;
         var _loc5_:Object = null;
         var _loc7_:Boolean = false;
         var _loc2_:Object = {};
         var _loc3_:Object = {};
         for(_loc4_ in mSprites)
         {
            _loc1_ = mSprites[_loc4_];
            for each(_loc6_ in _loc1_)
            {
               for each(_loc5_ in _loc6_)
               {
                  if(_loc5_.clip > 0)
                  {
                     _loc2_[_loc4_] = true;
                     _loc3_[_loc5_.id] = mBounds[_loc5_.id];
                  }
               }
            }
         }
         do
         {
            _loc7_ = false;
            for(_loc4_ in mSprites)
            {
               if(!_loc2_[_loc4_])
               {
                  _loc1_ = mSprites[_loc4_];
                  for each(_loc6_ in _loc1_)
                  {
                     for each(_loc5_ in _loc6_)
                     {
                        if(_loc2_[_loc5_.id])
                        {
                           _loc2_[_loc4_] = true;
                           _loc7_ = true;
                        }
                     }
                  }
               }
            }
         }
         while(_loc7_);
         for(_loc4_ in mSprites)
         {
            if(!_loc2_[_loc4_])
            {
               delete mSprites[_loc4_];
            }
         }
         mBounds = _loc3_;
      }
      
      private function tags(end:uint, frames:Vector.<Array>) : void
      {
         var _loc15_:int = 0;
         var _loc10_:int = 0;
         var _loc6_:uint = 0;
         var _loc3_:uint = 0;
         var _loc16_:int = 0;
         var _loc7_:int = 0;
         var _loc9_:int = 0;
         var _loc12_:int = 0;
         var _loc8_:int = 0;
         var _loc5_:int = 0;
         var _loc13_:String = null;
         var _loc17_:Object = null;
         var _loc4_:Array = null;
         var _loc18_:String = null;
         var _loc11_:Vector.<Array> = undefined;
         var _loc14_:Object = {};
         while(mBytes.position < end)
         {
            _loc15_ = int(mBytes.readUnsignedShort());
            _loc10_ = _loc15_ >> 6;
            _loc6_ = uint(_loc15_ & 0x3F);
            if(_loc6_ == 63)
            {
               _loc6_ = mBytes.readUnsignedInt();
            }
            _loc3_ = mBytes.position + _loc6_;
            if(_loc10_ == 39)
            {
               _loc16_ = int(mBytes.readUnsignedShort());
               mBytes.position += 2;
               _loc11_ = new Vector.<Array>(0);
               mSprites[_loc16_] = _loc11_;
               tags(_loc3_,_loc11_);
            }
            else if(_loc10_ == 76 || _loc10_ == 56)
            {
               _loc7_ = int(mBytes.readUnsignedShort());
               _loc9_ = 0;
               while(_loc9_ < _loc7_)
               {
                  _loc16_ = int(mBytes.readUnsignedShort());
                  _loc13_ = string();
                  sSymbols[_loc13_.replace("::",".")] = {
                     "parser":this,
                     "id":_loc16_
                  };
                  _loc9_++;
               }
            }
            else if(_loc10_ == 2 || _loc10_ == 22 || _loc10_ == 32 || _loc10_ == 83)
            {
               _loc16_ = int(mBytes.readUnsignedShort());
               mBounds[_loc16_] = rect();
            }
            else if(frames != null && (_loc10_ == 26 || _loc10_ == 70))
            {
               _loc8_ = int(mBytes.readUnsignedByte());
               _loc5_ = int(_loc10_ == 70 ? mBytes.readUnsignedByte() : 0);
               _loc12_ = int(mBytes.readUnsignedShort());
               _loc17_ = _loc14_[_loc12_];
               _loc17_ = _loc17_ != null ? {
                  "depth":_loc12_,
                  "id":_loc17_.id,
                  "clip":_loc17_.clip,
                  "matrix":_loc17_.matrix
               } : {
                  "depth":_loc12_,
                  "id":0,
                  "clip":0,
                  "matrix":new Matrix()
               };
               if((_loc5_ & 8) != 0 || (_loc5_ & 0x10) != 0 && (_loc8_ & 2) != 0)
               {
                  string();
               }
               if((_loc8_ & 2) != 0)
               {
                  _loc17_.id = mBytes.readUnsignedShort();
               }
               if((_loc8_ & 4) != 0)
               {
                  _loc17_.matrix = matrix();
               }
               if((_loc8_ & 8) != 0)
               {
                  color();
               }
               if((_loc8_ & 0x10) != 0)
               {
                  mBytes.position += 2;
               }
               if((_loc8_ & 0x20) != 0)
               {
                  string();
               }
               if((_loc8_ & 0x40) != 0)
               {
                  _loc17_.clip = mBytes.readUnsignedShort();
               }
               _loc14_[_loc12_] = _loc17_;
            }
            else if(frames != null && _loc10_ == 28)
            {
               delete _loc14_[mBytes.readUnsignedShort()];
            }
            else if(frames != null && _loc10_ == 1)
            {
               _loc4_ = [];
               for(_loc18_ in _loc14_)
               {
                  _loc4_.push(_loc14_[_loc18_]);
               }
               _loc4_.sortOn("depth",16);
               frames.push(_loc4_);
            }
            mBytes.position = _loc3_;
            if(_loc10_ == 0)
            {
               break;
            }
         }
      }
      
      private function bits(count:int, signed:Boolean = false) : int
      {
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         _loc3_ = 0;
         while(_loc3_ < count)
         {
            if(mBit == 0)
            {
               mByte = mBytes.readUnsignedByte();
            }
            _loc4_ = _loc4_ << 1 | mByte >> 7 - mBit & 1;
            mBit = mBit + 1 & 7;
            _loc3_++;
         }
         if(signed && count > 0 && (_loc4_ & 1 << count - 1) != 0)
         {
            _loc4_ -= 1 << count;
         }
         return _loc4_;
      }
      
      private function rect() : Rectangle
      {
         var _loc4_:int = bits(5);
         var _loc2_:Number = bits(_loc4_,true) / 20;
         var _loc5_:Number = bits(_loc4_,true) / 20;
         var _loc1_:Number = bits(_loc4_,true) / 20;
         var _loc3_:Number = bits(_loc4_,true) / 20;
         mBit = 0;
         return new Rectangle(_loc2_,_loc1_,_loc5_ - _loc2_,_loc3_ - _loc1_);
      }
      
      private function matrix() : Matrix
      {
         var _loc2_:int = 0;
         var _loc1_:Matrix = new Matrix();
         if(bits(1) != 0)
         {
            _loc2_ = bits(5);
            _loc1_.a = bits(_loc2_,true) / 65536;
            _loc1_.d = bits(_loc2_,true) / 65536;
         }
         if(bits(1) != 0)
         {
            _loc2_ = bits(5);
            _loc1_.b = bits(_loc2_,true) / 65536;
            _loc1_.c = bits(_loc2_,true) / 65536;
         }
         _loc2_ = bits(5);
         _loc1_.tx = bits(_loc2_,true) / 20;
         _loc1_.ty = bits(_loc2_,true) / 20;
         mBit = 0;
         return _loc1_;
      }
      
      private function color() : void
      {
         var _loc4_:int = 0;
         var _loc1_:int = bits(1);
         var _loc2_:int = bits(1);
         var _loc3_:int = bits(4);
         _loc4_ = 0;
         while(_loc4_ < (_loc1_ + _loc2_) * 4)
         {
            bits(_loc3_);
            _loc4_++;
         }
         mBit = 0;
      }
      
      private function string() : String
      {
         var _loc1_:uint = mBytes.position;
         while(mBytes.readUnsignedByte() != 0)
         {
         }
         var _loc2_:uint = mBytes.position;
         mBytes.position = _loc1_;
         var _loc3_:String = mBytes.readUTFBytes(_loc2_ - _loc1_ - 1);
         mBytes.position = _loc2_;
         return _loc3_;
      }
   }
}

