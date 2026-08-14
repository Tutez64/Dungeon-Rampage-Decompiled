package Brain.Utils
{
   import flash.utils.ByteArray;
   
   public class Utf8BitArray
   {
      
      public var decodedByteArray:ByteArray;
      
      public function Utf8BitArray()
      {
         super();
         decodedByteArray = new ByteArray();
      }
      
      public function init(base64ByteStr:String) : void
      {
         var _loc2_:int = 0;
         var _loc3_:Number = NaN;
         if(base64ByteStr == null)
         {
            decodedByteArray = new ByteArray();
         }
         else
         {
            decodedByteArray = new ByteArray();
            _loc2_ = 0;
            while(_loc2_ < base64ByteStr.length)
            {
               _loc3_ = base64ByteStr.charCodeAt(_loc2_);
               decodedByteArray.writeByte(_loc3_);
               if(_loc3_ >> 8 != 0)
               {
                  decodedByteArray.writeByte(_loc3_ >> 8);
               }
               _loc2_++;
            }
         }
      }
      
      public function destroy() : void
      {
         decodedByteArray = null;
      }
      
      public function setBit(index:uint) : void
      {
      }
      
      public function getBit(index:uint) : Boolean
      {
         var _loc2_:uint = index / 8;
         var _loc3_:uint = 7 - index % 8;
         if(_loc2_ < decodedByteArray.length)
         {
            return (decodedByteArray[_loc2_] & 1 << _loc3_) != 0;
         }
         return false;
      }
      
      public function getLength() : uint
      {
         return decodedByteArray.length * 8;
      }
   }
}

