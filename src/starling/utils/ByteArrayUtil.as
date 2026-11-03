package starling.utils
{
   import flash.utils.ByteArray;
   import starling.errors.AbstractClassError;
   
   public class ByteArrayUtil
   {
      
      public function ByteArrayUtil()
      {
         super();
         throw new AbstractClassError();
      }
      
      public static function startsWithString(bytes:ByteArray, string:String) : Boolean
      {
         var _loc6_:int = 0;
         var _loc3_:int = 0;
         var _loc4_:int = 0;
         var _loc5_:int = int(bytes.length);
         var _loc7_:ByteArray = new ByteArray();
         _loc7_.writeUTFBytes(string);
         if(_loc5_ >= 4 && (bytes[0] == 0 && bytes[1] == 0 && bytes[2] == 254 && bytes[3] == 255) || bytes[0] == 255 && bytes[1] == 254 && bytes[2] == 0 && bytes[3] == 0)
         {
            _loc4_ = 4;
         }
         else if(_loc5_ >= 3 && bytes[0] == 239 && bytes[1] == 187 && bytes[2] == 191)
         {
            _loc4_ = 3;
         }
         else if(_loc5_ >= 2 && (bytes[0] == 254 && bytes[1] == 255) || bytes[0] == 255 && bytes[1] == 254)
         {
            _loc4_ = 2;
         }
         _loc6_ = _loc4_;
         while(_loc6_ < _loc5_)
         {
            _loc3_ = int(bytes[_loc6_]);
            if(_loc3_ != 0 && _loc3_ != 10 && _loc3_ != 13 && _loc3_ != 32)
            {
               return compareByteArrays(bytes,_loc6_,_loc7_,0,_loc7_.length);
            }
            _loc6_++;
         }
         return false;
      }
      
      public static function startsWithBytes(byteArray:ByteArray, firstBytes:Array) : Boolean
      {
         var _loc4_:int = 0;
         var _loc3_:int = 0;
         if(firstBytes.length > byteArray.length)
         {
            return false;
         }
         _loc4_ = 0;
         _loc3_ = int(firstBytes.length);
         while(_loc4_ < _loc3_)
         {
            if(byteArray[_loc4_] != firstBytes[_loc4_])
            {
               return false;
            }
            _loc4_++;
         }
         return true;
      }
      
      public static function compareByteArrays(a:ByteArray, indexA:int, b:ByteArray, indexB:int, numBytes:int = -1) : Boolean
      {
         var _loc6_:int = 0;
         if(numBytes < 0)
         {
            numBytes = MathUtil.min(a.length - indexA,b.length - indexB);
         }
         else if(indexA + numBytes > a.length || indexB + numBytes > b.length)
         {
            throw new RangeError();
         }
         _loc6_ = 0;
         while(_loc6_ < numBytes)
         {
            if(a[indexA + _loc6_] != b[indexB + _loc6_])
            {
               return false;
            }
            _loc6_++;
         }
         return true;
      }
   }
}

