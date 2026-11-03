package NetworkCode
{
   import flash.utils.ByteArray;
   
   public class DcNetworkBuffer extends ByteArray
   {
      
      private static const sSlide:ByteArray = new ByteArray();
      
      public function DcNetworkBuffer()
      {
         super();
         endian = "littleEndian";
      }
      
      public function do_slide() : void
      {
         if(position == length)
         {
            length = 0;
            position = 0;
            return;
         }
         var _loc1_:ByteArray = sSlide;
         _loc1_.length = 0;
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

