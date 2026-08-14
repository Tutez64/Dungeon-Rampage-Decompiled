package NetworkCode
{
   import flash.utils.ByteArray;
   
   public class DcNetworkBuffer extends ByteArray
   {
      
      public function DcNetworkBuffer()
      {
         super();
         endian = "littleEndian";
      }
      
      public function do_slide() : void
      {
         var _loc1_:DcNetworkPacket = new DcNetworkPacket();
         readBytes(_loc1_);
         length = 0;
         position = 0;
         writeBytes(_loc1_);
         position = 0;
      }
      
      public function eof() : Boolean
      {
         return position == length;
      }
   }
}

