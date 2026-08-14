package com.adobe.images
{
   import flash.display.BitmapData;
   import flash.geom.*;
   import flash.utils.ByteArray;
   
   public class PNGEncoder
   {
      
      private static var crcTable:Array;
      
      private static var crcTableComputed:Boolean = false;
      
      public function PNGEncoder()
      {
         super();
      }
      
      public static function encode(img:BitmapData) : ByteArray
      {
         var _loc6_:uint = 0;
         var _loc7_:* = 0;
         var _loc2_:ByteArray = new ByteArray();
         _loc2_.writeUnsignedInt(2303741511);
         _loc2_.writeUnsignedInt(218765834);
         var _loc3_:ByteArray = new ByteArray();
         _loc3_.writeInt(img.width);
         _loc3_.writeInt(img.height);
         _loc3_.writeUnsignedInt(134610944);
         _loc3_.writeByte(0);
         writeChunk(_loc2_,1229472850,_loc3_);
         var _loc4_:ByteArray = new ByteArray();
         var _loc5_:* = 0;
         while(_loc5_ < img.height)
         {
            _loc4_.writeByte(0);
            if(!img.transparent)
            {
               _loc7_ = 0;
               while(_loc7_ < img.width)
               {
                  _loc6_ = img.getPixel(_loc7_,_loc5_);
                  _loc4_.writeUnsignedInt(uint((_loc6_ & 0xFFFFFF) << 8 | 0xFF));
                  _loc7_++;
               }
            }
            else
            {
               _loc7_ = 0;
               while(_loc7_ < img.width)
               {
                  _loc6_ = img.getPixel32(_loc7_,_loc5_);
                  _loc4_.writeUnsignedInt(uint((_loc6_ & 0xFFFFFF) << 8 | _loc6_ >>> 24));
                  _loc7_++;
               }
            }
            _loc5_++;
         }
         _loc4_.compress();
         writeChunk(_loc2_,1229209940,_loc4_);
         writeChunk(_loc2_,1229278788,null);
         return _loc2_;
      }
      
      private static function writeChunk(png:ByteArray, type:uint, data:ByteArray) : void
      {
         var _loc8_:uint = 0;
         var _loc9_:uint = 0;
         var _loc10_:uint = 0;
         if(!crcTableComputed)
         {
            crcTableComputed = true;
            crcTable = [];
            _loc9_ = 0;
            while(_loc9_ < 256)
            {
               _loc8_ = _loc9_;
               _loc10_ = 0;
               while(_loc10_ < 8)
               {
                  if(_loc8_ & 1)
                  {
                     _loc8_ = uint(uint(3988292384) ^ uint(_loc8_ >>> 1));
                  }
                  else
                  {
                     _loc8_ = uint(_loc8_ >>> 1);
                  }
                  _loc10_++;
               }
               crcTable[_loc9_] = _loc8_;
               _loc9_++;
            }
         }
         var _loc4_:uint = 0;
         if(data != null)
         {
            _loc4_ = data.length;
         }
         png.writeUnsignedInt(_loc4_);
         var _loc5_:uint = png.position;
         png.writeUnsignedInt(type);
         if(data != null)
         {
            png.writeBytes(data);
         }
         var _loc6_:uint = png.position;
         png.position = _loc5_;
         _loc8_ = 4294967295;
         var _loc7_:* = 0;
         while(_loc7_ < _loc6_ - _loc5_)
         {
            _loc8_ = uint(crcTable[(_loc8_ ^ png.readUnsignedByte()) & uint(255)] ^ uint(_loc8_ >>> 8));
            _loc7_++;
         }
         _loc8_ = uint(_loc8_ ^ uint(4294967295));
         png.position = _loc6_;
         png.writeUnsignedInt(_loc8_);
      }
   }
}

