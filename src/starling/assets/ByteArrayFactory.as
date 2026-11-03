package starling.assets
{
   import flash.utils.ByteArray;
   
   public class ByteArrayFactory extends AssetFactory
   {
      
      public function ByteArrayFactory()
      {
         super();
         addExtensions("bin");
         addMimeTypes("application/octet-stream");
      }
      
      override public function canHandle(reference:AssetReference) : Boolean
      {
         return reference.data is ByteArray;
      }
      
      override public function create(reference:AssetReference, helper:AssetFactoryHelper, onComplete:Function, onError:Function) : void
      {
         onComplete(reference.name,reference.data as ByteArray);
      }
   }
}

