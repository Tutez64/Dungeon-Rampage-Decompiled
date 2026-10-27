package Brain.Utils
{
   import flash.utils.ByteArray;
   
   public class SplitTestRules
   {
      
      private static const k:Array = [1116352408,1899447441,3049323471,3921009573,961987163,1508970993,2453635748,2870763221,3624381080,310598401,607225278,1426881987,1925078388,2162078206,2614888103,3248222580,3835390401,4022224774,264347078,604807628,770255983,1249150122,1555081692,1996064986,2554220882,2821834349,2952996808,3210313671,3336571891,3584528711,113926993,338241895,666307205,773529912,1294757372,1396182291,1695183700,1986661051,2177026350,2456956037,2730485921,2820302411,3259730800,3345764771,3516065817,3600352804,4094571909,275423344,430227734,506948616,659060556,883997877,958139571,1322822218,1537002063,1747873779,1955562222,2024104815,2227730452,2361852424,2428436474,2756734187,3204031479,3329325298];
      
      private static const h:Array = [1779033703,3144134277,1013904242,2773480762,1359893119,2600822924,528734635,1541459225];
      
      public function SplitTestRules()
      {
         super();
      }
      
      public static function testSha256() : void
      {
         var _loc4_:* = 0;
         var _loc1_:ByteArray = null;
         var _loc3_:ByteArray = null;
         var _loc5_:Array = [fromString(""),fromString("a"),fromString("abc"),fromString("message digest"),fromString("abcdefghijklmnopqrstuvwxyz"),fromString("abcdbcdecdefdefgefghfghighijhijkijkljklmklmnlmnomnopnopq"),fromString("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789"),fromString("12345678901234567890123456789012345678901234567890123456789012345678901234567890"),fromString("The quick brown fox jumps over the lazy dog")];
         var _loc2_:Array = ["E3B0C44298FC1C149AFBF4C8996FB92427AE41E4649B934CA495991B7852B855","CA978112CA1BBDCAFAC231B39A23DC4DA786EFF8147C4E72B9807785AFEE48BB","BA7816BF8F01CFEA414140DE5DAE2223B00361A396177A9CB410FF61F20015AD","F7846F55CF23E14EEBEAB5B4E1550CAD5B509E3348FBC4EFA3A1413D393CB650","71C480DF93D6AE2F1EFAD1447C66C9525E316218CF51FC8D9ED832F2DAF18B73","248D6A61D20638B8E5C026930C3E6039A33CE45964FF2167F6ECEDD419DB06C1","DB4BFCBD4DA0CD85A60C3C37D3FBD8805C77F15FC6B1FDFE614EE0A7C8FDB4C0","F371BC4A311F2B009EEF952DD83CA80E2B60026C8E935592D0F9C308453C813E","d7a8fbb307d7809469ca9abcb0082e4f8d5651e46d3cdb762d02d0bf37c9e592"];
         _loc4_ = 0;
         while(_loc4_ < _loc5_.length)
         {
            _loc1_ = toArray(_loc5_[_loc4_]);
            _loc3_ = hash(_loc1_);
            _loc4_++;
         }
      }
      
      public static function getStringHash(s:String) : String
      {
         return fromArray(hash(toArray(fromString(s))));
      }
      
      public static function Random(s:String, range:uint) : uint
      {
         var _loc3_:String = fromArray(hash(toArray(fromString(s))));
         _loc3_ = _loc3_.substr(0,7);
         var _loc4_:uint = uint("0x" + _loc3_.toUpperCase());
         return uint(_loc4_ % range);
      }
      
      private static function getHashSize() : uint
      {
         return 32;
      }
      
      private static function hash(src:ByteArray) : ByteArray
      {
         var _loc7_:* = 0;
         var _loc6_:uint = src.length;
         var _loc8_:String = src.endian;
         src.endian = "bigEndian";
         var _loc3_:uint = _loc6_ * 8;
         while(src.length % 4 != 0)
         {
            src[src.length] = 0;
         }
         src.position = 0;
         var _loc2_:Array = [];
         _loc7_ = 0;
         while(_loc7_ < src.length)
         {
            _loc2_.push(src.readUnsignedInt());
            _loc7_ += 4;
         }
         var _loc4_:Array = SHA256(_loc2_,_loc3_);
         var _loc9_:ByteArray = new ByteArray();
         var _loc5_:uint = getHashSize() / 4;
         _loc7_ = 0;
         while(_loc7_ < _loc5_)
         {
            _loc9_.writeUnsignedInt(_loc4_[_loc7_]);
            _loc7_++;
         }
         src.length = _loc6_;
         src.endian = _loc8_;
         return _loc9_;
      }
      
      private static function SHA256(x:Array, len:uint) : Array
      {
         var _loc14_:* = 0;
         var _loc16_:* = 0;
         var _loc21_:* = 0;
         var _loc22_:* = 0;
         var _loc15_:* = 0;
         var _loc17_:* = 0;
         var _loc18_:* = 0;
         var _loc20_:* = 0;
         var _loc3_:* = 0;
         var _loc4_:* = 0;
         var _loc19_:* = 0;
         var _loc5_:* = 0;
         var _loc6_:* = 0;
         var _loc25_:* = 0;
         var _loc24_:* = 0;
         x[len >> 5] |= 128 << 24 - len % 32;
         x[(len + 64 >> 9 << 4) + 15] = len;
         var _loc23_:Array = [];
         var _loc7_:uint = uint(_loc14_[0]);
         var _loc8_:uint = uint(_loc14_[1]);
         var _loc9_:uint = uint(_loc14_[2]);
         var _loc10_:uint = uint(_loc14_[3]);
         var _loc11_:uint = uint(_loc14_[4]);
         var _loc12_:uint = uint(_loc14_[5]);
         var _loc13_:uint = uint(_loc14_[6]);
         _loc14_ = uint(_loc14_[7]);
         _loc16_ = 0;
         while(_loc16_ < x.length)
         {
            _loc21_ = _loc7_;
            _loc22_ = _loc8_;
            _loc15_ = _loc9_;
            _loc17_ = _loc10_;
            _loc18_ = _loc11_;
            _loc20_ = _loc12_;
            _loc3_ = _loc13_;
            _loc4_ = _loc14_;
            _loc19_ = 0;
            while(_loc19_ < 64)
            {
               if(_loc19_ < 16)
               {
                  _loc23_[_loc19_] = x[_loc16_ + _loc19_] || 0;
               }
               else
               {
                  _loc5_ = uint(rrol(_loc23_[_loc19_ - 15],7) ^ rrol(_loc23_[_loc19_ - 15],18) ^ _loc23_[_loc19_ - 15] >>> 3);
                  _loc6_ = uint(rrol(_loc23_[_loc19_ - 2],17) ^ rrol(_loc23_[_loc19_ - 2],19) ^ _loc23_[_loc19_ - 2] >>> 10);
                  _loc23_[_loc19_] = _loc23_[_loc19_ - 16] + _loc5_ + _loc23_[_loc19_ - 7] + _loc6_;
               }
               _loc25_ = uint((rrol(_loc7_,2) ^ rrol(_loc7_,13) ^ rrol(_loc7_,22)) + (_loc7_ & _loc8_ ^ _loc7_ & _loc9_ ^ _loc8_ & _loc9_));
               _loc24_ = uint(_loc14_ + (rrol(_loc11_,6) ^ rrol(_loc11_,11) ^ rrol(_loc11_,25)) + (_loc11_ & _loc12_ ^ _loc13_ & ~_loc11_) + k[_loc19_] + _loc23_[_loc19_]);
               _loc14_ = _loc13_;
               _loc13_ = _loc12_;
               _loc12_ = _loc11_;
               _loc11_ = _loc10_ + _loc24_;
               _loc10_ = _loc9_;
               _loc9_ = _loc8_;
               _loc8_ = _loc7_;
               _loc7_ = _loc24_ + _loc25_;
               _loc19_++;
            }
            _loc7_ += _loc21_;
            _loc8_ += _loc22_;
            _loc9_ += _loc15_;
            _loc10_ += _loc17_;
            _loc11_ += _loc18_;
            _loc12_ += _loc20_;
            _loc13_ += _loc3_;
            _loc14_ += _loc4_;
            _loc16_ += 16;
         }
         return [_loc7_,_loc8_,_loc9_,_loc10_,_loc11_,_loc12_,_loc13_,_loc14_];
      }
      
      private static function rrol(num:uint, cnt:uint) : uint
      {
         return num << 32 - cnt | num >>> cnt;
      }
      
      private static function toArray(hex:String) : ByteArray
      {
         var _loc3_:* = 0;
         hex = hex.replace(/\s|:/gm,"");
         var _loc2_:ByteArray = new ByteArray();
         if(hex.length)
         {
            hex = "0" + hex;
         }
         _loc3_ = 0;
         while(_loc3_ < hex.length)
         {
            _loc2_[_loc3_ / 2] = parseInt(hex.substr(_loc3_,2),16);
            _loc3_ += 2;
         }
         return _loc2_;
      }
      
      private static function fromArray(array:ByteArray, colons:Boolean = false) : String
      {
         var _loc4_:* = 0;
         var _loc3_:String = "";
         _loc4_ = 0;
         while(_loc4_ < array.length)
         {
            _loc3_ += ("0" + array[_loc4_].toString(16)).substr(-2,2);
            if(colons)
            {
               if(_loc4_ < array.length - 1)
               {
                  _loc3_ += ":";
               }
            }
            _loc4_++;
         }
         return _loc3_;
      }
      
      private static function toString(hex:String) : String
      {
         var _loc2_:ByteArray = toArray(hex);
         return _loc2_.readUTFBytes(_loc2_.length);
      }
      
      private static function fromString(str:String, colons:Boolean = false) : String
      {
         var _loc3_:ByteArray = new ByteArray();
         _loc3_.writeUTFBytes(str);
         return fromArray(_loc3_,colons);
      }
   }
}

