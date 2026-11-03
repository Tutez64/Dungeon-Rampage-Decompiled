package starling.assets
{
   import flash.utils.ByteArray;
   import starling.utils.ByteArrayUtil;
   
   public class JsonFactory extends AssetFactory
   {
      
      public function JsonFactory()
      {
         super();
         addExtensions("json");
         addMimeTypes("application/json","text/json");
      }
      
      override public function canHandle(reference:AssetReference) : Boolean
      {
         return super.canHandle(reference) || reference.data is ByteArray && (ByteArrayUtil.startsWithString(reference.data as ByteArray,"{") || ByteArrayUtil.startsWithString(reference.data as ByteArray,"["));
      }
      
      override public function create(reference:AssetReference, helper:AssetFactoryHelper, onComplete:Function, onError:Function) : void
      {
         var _loc5_:ByteArray = null;
         var _loc6_:Object = null;
         try
         {
            _loc5_ = reference.data as ByteArray;
            _loc6_ = JSON.parse(_loc5_.readUTFBytes(_loc5_.length));
            onComplete(reference.name,_loc6_);
         }
         catch(e:Error)
         {
            onError("Could not parse JSON: " + e.message);
         }
      }
   }
}

