package Brain.AssetRepository
{
   import flash.utils.ByteArray;
   
   public class ByteArrayAsset extends Asset
   {
      
      protected var mByteArray:ByteArray;
      
      public function ByteArrayAsset(byteArray:ByteArray)
      {
         super();
         mByteArray = byteArray;
      }
      
      public function get byteArray() : ByteArray
      {
         return mByteArray;
      }
      
      override public function destroy() : void
      {
         mByteArray = null;
         super.destroy();
      }
   }
}

